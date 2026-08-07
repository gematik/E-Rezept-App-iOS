//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import AsyncHelpers
import CodedError
import Combine
import Dependencies
import DependenciesMacros
import FHIRClient
import Foundation
import HTTPClient
import PushNotificationCrypto
import Sharing
import UIKit

/// Orchestrates the FdV-Instanz push-notification registration against the E-Rezept Fachdienst.
///
/// Mirrors `ConsentService`: resolves the per-profile session, ensures the user is authenticated,
/// then performs the registration / channel-configuration calls. The crypto orchestration (iss
/// generation, key-chain initialisation) and APNs registration are implemented here; the raw
/// Fachdienst HTTP calls are delegated to `PushNotificationFachdienstClient` (the transport seam).
/// [REQ:gemF_PushNotification:A_27172] Implements the "FdV-Instanz registrieren" use case
@DependencyClient
struct PushNotificationRegistrationService {
    /// Requests APNs authorization, registers the device and registers the pusher for the profile.
    var register: @Sendable (_ profileId: UUID) async throws -> RegistrationResult
    /// Deregisters the pusher for the profile (POST /pushers/v1/set with kind = null).
    /// [REQ:gemF_PushNotification:A_27184] Lets the user disable push notifications / revoke consent
    var deregister: @Sendable (_ profileId: UUID) async throws -> Void
    /// Subscribes or unsubscribes a group of channels for the profile's pusher, applying the same
    /// state to every `channelId`. A user-facing toggle maps to one or more Fachdienst channels.
    /// [REQ:gemF_PushNotification:A_28210,A_27666] Lets the user manage channel configuration
    var configureChannel: @Sendable (_ profileId: UUID, _ channelIds: [String], _ enabled: Bool) async throws -> Void
    /// Loads the current channel subscription states for the profile's pusher (GET /channels/{pushkey}).
    var loadChannels: @Sendable (_ profileId: UUID) async throws -> [ChannelState]
}

extension PushNotificationRegistrationService {
    enum RegistrationResult: Equatable {
        case registered
        case notAuthenticated
        case permissionDenied
    }
}

@CodedError("702")
enum PushNotificationRegistrationError: Error, Equatable {
    @ErrorCode("01")
    case missingPushGatewayURL
    @ErrorCode("02")
    case missingAppId
    @ErrorCode("03")
    case notRegistered
}

// MARK: - Live orchestration

extension PushNotificationRegistrationService: DependencyKey {
    static var liveValue: PushNotificationRegistrationService {
        @Dependency(\.userSessionProvider) var userSessionProvider
        @Dependency(\.apnsRegistrationService) var apnsRegistrationService
        @Dependency(\.pushNotificationCrypto) var crypto
        @Dependency(\.pushNotificationFachdienstClient) var fachdienst
        @Dependency(\.uuid) var uuid
        @Dependency(\.userDataStore.appConfiguration) var appConfiguration

        @Sendable
        func isAuthenticated(_ profileId: UUID) async throws -> Bool {
            let loginHandler = userSessionProvider.userSession(for: profileId).idpSessionLoginHandler
            switch try await loginHandler.isAuthenticated().async() {
            case .success(true): return true
            default: return false
            }
        }

        return PushNotificationRegistrationService(
            register: { profileId in
                guard try await isAuthenticated(profileId) else { return .notAuthenticated }

                // [REQ:gemF_PushNotification:A_27173] Obtain the pushkey from the push provider (APNs)
                let deviceToken: Data
                do {
                    deviceToken = try await apnsRegistrationService.requestAuthorizationAndRegister()
                } catch APNSRegistrationError.permissionDenied {
                    return .permissionDenied
                }
                let pushkey = deviceToken.hexEncodedString()

                // [REQ:gemF_PushNotification:A_27174] Generate iss + time_iss_created
                let (iss, timeISSCreated) = crypto.createInitialSharedSecret()
                let keyIdentifier = uuid().uuidString

                // [REQ:gemF_PushNotification:A_27168] app_id is the host bundle identifier
                guard let appId = Self.appId() else { throw PushNotificationRegistrationError.missingAppId }
                guard let gateway = appConfiguration.pushGateway else {
                    throw PushNotificationRegistrationError.missingPushGatewayURL
                }
                // The push gateway `data.url` must carry the well-known `/push/v1/` path that the
                // Fachdienst extends (notify*). The config only holds the gateway host.
                let pushGatewayURL = Self.pushGatewayURL(for: gateway)

                // [REQ:gemF_PushNotification:A_27175] POST /pushers/v1/set at the Fachdienst
                // [REQ:gemF_PushNotification:A_27396] No personal/KVNR data in the registration payload
                let registration = await PusherRegistration(
                    appId: appId,
                    pushkey: pushkey,
                    appDisplayName: Self.appDisplayName,
                    deviceDisplayName: Self.deviceDisplayName(),
                    lang: Self.preferredLanguage,
                    pushGatewayURL: pushGatewayURL,
                    initialSharedSecret: iss.hexEncodedString(),
                    timeISSCreated: timeISSCreated,
                    keyIdentifier: keyIdentifier
                )
                try await fachdienst.setPusher(profileId, registration)

                // [REQ:gemF_PushNotification:A_27176,A_27177] Initial key derivation + persistence
                // [REQ:gemF_PushNotification:A_27375] iss itself is not persisted - dropped after derivation
                try crypto.initializeKeyChain(iss, timeISSCreated, keyIdentifier)

                @Shared(.pushNotificationRegistrations) var registrations
                $registrations.withLock { state in
                    state[profileId.uuidString] = .init(keyIdentifier: keyIdentifier, pushkey: pushkey, channels: [])
                }
                return .registered
            },
            deregister: { profileId in
                @Shared(.pushNotificationRegistrations) var registrations
                guard let local = registrations[profileId.uuidString] else { return }
                guard let appId = Self.appId() else { throw PushNotificationRegistrationError.missingAppId }
                try await fachdienst.deletePusher(profileId, local.pushkey, appId)
                $registrations.withLock { $0[profileId.uuidString] = nil }
            },
            configureChannel: { profileId, channelIds, enabled in
                @Shared(.pushNotificationRegistrations) var registrations
                guard let local = registrations[profileId.uuidString] else {
                    throw PushNotificationRegistrationError.notRegistered
                }
                try await fachdienst.setChannels(
                    profileId,
                    local.pushkey,
                    channelIds.map { .init(channelId: $0, enabled: enabled) }
                )
                $registrations.withLock { state in
                    var channels = Set(state[profileId.uuidString]?.channels ?? [])
                    if enabled {
                        channels.formUnion(channelIds)
                    } else {
                        channels.subtract(channelIds)
                    }
                    state[profileId.uuidString]?.channels = Array(channels)
                }
            },
            loadChannels: { profileId in
                @Shared(.pushNotificationRegistrations) var registrations
                guard let local = registrations[profileId.uuidString] else {
                    throw PushNotificationRegistrationError.notRegistered
                }
                return try await fachdienst.getChannels(profileId, local.pushkey)
            }
        )
    }

    /// app_id used for the registration: the host bundle identifier (e.g. "de.gematik.erp4ios.eRezept.apns").
    static func appId() -> String? {
        "\(Bundle.main.bundleIdentifier ?? "dummy.app.identifier").apns"
    }

    /// Well-known path the push gateway `data.url` must carry; the Fachdienst extends it (notify*).
    /// Note: this is the push *gateway* path and is independent of the FD's `/pushers/v1` route
    /// versioning — the FD validates that `data.url` ends with `/push/v1/`.
    static let pushGatewayPath = "push/v1/"

    /// Builds the push gateway `data.url` from the configured gateway host, ensuring exactly one
    /// `/push/v1/` path segment with a trailing slash.
    static func pushGatewayURL(for gateway: URL) -> String {
        let base = gateway.absoluteString
        let trimmed = base.hasSuffix("/") ? String(base.dropLast()) : base
        return "\(trimmed)/\(pushGatewayPath)"
    }

    /// app_display_name for the pusher (the localized app name; not personal data).
    static var appDisplayName: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
            ?? (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String)
            ?? "E-Rezept"
    }

    /// Preferred language for notifications (e.g. "de").
    static var preferredLanguage: String {
        Locale.current.language.languageCode?.identifier ?? "de"
    }

    /// device_display_name for the pusher. Uses the device model (e.g. "iPhone") to avoid any
    /// personal data such as a user-assigned device name (A_27396).
    static func deviceDisplayName() async -> String {
        await MainActor.run { UIDevice.current.model }
    }
}

// MARK: - Transport (Client-FD Push API, OpenAPI 1.2.0)

/// HTTP transport to the E-Rezept Fachdienst push endpoints (`/pushers/v1`, `/channels/v1/...`),
/// routed through the per-profile authenticated VAU channel via the cached erp `FHIRClient`.
@DependencyClient
struct PushNotificationFachdienstClient {
    /// POST /pushers/v1/set — create/update the pusher registration.
    var setPusher: @Sendable (_ profileId: UUID, _ registration: PusherRegistration) async throws -> Void
    /// POST /pushers/v1/set with kind = null — delete the pusher registration.
    var deletePusher: @Sendable (_ profileId: UUID, _ pushkey: String, _ appId: String) async throws -> Void
    /// POST /channels/v1/{pushkey} — subscribe/unsubscribe channels.
    var setChannels: @Sendable (_ profileId: UUID, _ pushkey: String, _ channels: [ChannelSubscription]) async throws
        -> Void
    /// GET /channels/v1/{pushkey} — current channel subscription states for a device.
    var getChannels: @Sendable (_ profileId: UUID, _ pushkey: String) async throws -> [ChannelState]
}

extension PushNotificationFachdienstClient: DependencyKey {
    static var liveValue: PushNotificationFachdienstClient {
        @Dependency(\.fhirClientServiceFactory) var fhirClientServiceFactory

        @Sendable
        func post(_ profileId: UUID, path: String, body: some Encodable) async throws {
            let client = fhirClientServiceFactory.erpClientForProfile(profileId)
            let operation = try PushAPIOperation(path: path, body: Self.encode(body))
            try await client.execute(operation: operation).async()
        }

        @Sendable
        func get<Value: Decodable>(_ profileId: UUID, path: String) async throws -> Value {
            let client = fhirClientServiceFactory.erpClientForProfile(profileId)
            let operation = PushGetOperation<Value>(path: path)
            return try await client.execute(operation: operation).async()
        }

        return PushNotificationFachdienstClient(
            setPusher: { profileId, registration in
                try await post(profileId, path: "pushers/v1/set", body: PusherWire(registration: registration))
            },
            deletePusher: { profileId, pushkey, appId in
                try await post(
                    profileId,
                    path: "pushers/v1/set",
                    body: PusherDeletionWire(appId: appId, pushkey: pushkey)
                )
            },
            setChannels: { profileId, pushkey, channels in
                let escaped = pushkey.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? pushkey
                try await post(profileId, path: "channels/v1/\(escaped)", body: ChannelsWire(channels: channels))
            },
            getChannels: { profileId, pushkey in
                let escaped = pushkey.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? pushkey
                let wire: ChannelsGetWire = try await get(profileId, path: "channels/v1/\(escaped)")
                return wire.channels.map { ChannelState(id: $0.id, status: $0.status) }
            }
        )
    }

    static func encode(_ value: some Encodable) throws -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try encoder.encode(value)
    }
}

/// Generic `FHIRClientOperation` for the JSON push API. Resolves against the erp client's `base`
/// server (inner VAU request URL); the response body is an empty object on success.
private struct PushAPIOperation: FHIRClientOperation {
    typealias Value = Void

    let path: String
    let body: Data?

    var relativeUrlString: String? {
        path
    }

    var httpHeaders: [String: String] {
        var headers = ["Content-Type": "application/json", "Accept": "application/json"]
        // The VAU inner request is serialized manually (URLRequest+Serialize); Content-Length is not
        // derived automatically, so the FD's HTTP parser rejects the body unless we set it explicitly.
        if let dataLength = body?.count, dataLength > 0 {
            headers["Content-Length"] = String(dataLength)
        }
        return headers
    }

    var httpMethod: HTTPMethod {
        .post
    }

    var httpBody: Data? {
        body
    }

    func handle(response _: FHIRClient.Response) throws {}
}

/// Generic `FHIRClientOperation` for reading JSON from the push API. Resolves against the erp
/// client's `base` server (inner VAU request URL) and decodes the response body into `Value`.
private struct PushGetOperation<Value: Decodable>: FHIRClientOperation {
    let path: String

    var relativeUrlString: String? {
        path
    }

    var httpHeaders: [String: String] {
        ["Accept": "application/json"]
    }

    var httpMethod: HTTPMethod {
        .get
    }

    var httpBody: Data? {
        nil
    }

    func handle(response: FHIRClient.Response) throws -> Value {
        try JSONDecoder().decode(Value.self, from: response.body)
    }
}

// MARK: - Models

/// Domain-level registration payload assembled by `PushNotificationRegistrationService`.
struct PusherRegistration: Equatable {
    let appId: String
    let pushkey: String
    let appDisplayName: String
    let deviceDisplayName: String
    let lang: String
    let pushGatewayURL: String
    let initialSharedSecret: String
    let timeISSCreated: String
    let keyIdentifier: String
}

struct ChannelSubscription: Equatable {
    let channelId: String
    let enabled: Bool
}

/// Current subscription state of a channel as returned by `GET /push/v1/channels/{pushkey}`.
struct ChannelState: Equatable {
    let id: String
    let status: Status

    enum Status: String, Decodable, Equatable {
        case enabled
        case disabled
        case notSet = "not_set"
    }
}

// MARK: - Wire models (snake_case via JSONEncoder.keyEncodingStrategy = .convertToSnakeCase)

private struct PusherWire: Encodable {
    let lang: String
    let kind = "http"
    let appDisplayName: String
    let deviceDisplayName: String
    let appId: String
    let pushkey: String
    let data: DataWire
    let encryption: EncryptionWire
    let append = false

    init(registration: PusherRegistration) {
        lang = registration.lang
        appDisplayName = registration.appDisplayName
        deviceDisplayName = registration.deviceDisplayName
        appId = registration.appId
        pushkey = registration.pushkey
        data = DataWire(url: registration.pushGatewayURL)
        encryption = EncryptionWire(
            timeIssCreated: registration.timeISSCreated,
            iss: registration.initialSharedSecret,
            keyIdentifier: registration.keyIdentifier
        )
    }

    struct DataWire: Encodable {
        let url: String
    }

    struct EncryptionWire: Encodable {
        let method = "aes-hmac-sha256"
        let timeIssCreated: String
        let iss: String
        let keyIdentifier: String
    }
}

private struct PusherDeletionWire: Encodable {
    let appId: String
    let pushkey: String

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(appId, forKey: .appId)
        try container.encode(pushkey, forKey: .pushkey)
        // kind = null signals deletion of the pusher.
        try container.encodeNil(forKey: .kind)
    }

    enum CodingKeys: String, CodingKey {
        case appId
        case pushkey
        case kind
    }
}

private struct ChannelsWire: Encodable {
    let channels: [ChannelWire]

    init(channels: [ChannelSubscription]) {
        self.channels = channels.map { ChannelWire(id: $0.channelId, status: $0.enabled ? "enabled" : "disabled") }
    }

    struct ChannelWire: Encodable {
        let id: String
        let status: String
    }
}

/// Decodes the `GET /push/v1/channels/{pushkey}` response body.
private struct ChannelsGetWire: Decodable {
    let channels: [ChannelWire]

    struct ChannelWire: Decodable {
        let id: String
        let status: ChannelState.Status
    }
}

/// Locally persisted state for a profile's pusher registration.
struct PushNotificationRegistrationState: Equatable, Codable {
    var keyIdentifier: String
    var pushkey: String
    var channels: [String]
}

extension SharedReaderKey
    where Self == FileStorageKey<[String: PushNotificationRegistrationState]>.Default {
    /// Per-profile (keyed by profile UUID string) local push-registration state.
    static var pushNotificationRegistrations: Self {
        Self[.fileStorage(.pushNotificationRegistrationsURL), default: [:]]
    }
}

extension URL {
    static var pushNotificationRegistrationsURL: Self {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appending(path: "pushNotificationRegistrations.json")
    }
}

extension DependencyValues {
    var pushNotificationRegistrationService: PushNotificationRegistrationService {
        get { self[PushNotificationRegistrationService.self] }
        set { self[PushNotificationRegistrationService.self] = newValue }
    }

    var pushNotificationFachdienstClient: PushNotificationFachdienstClient {
        get { self[PushNotificationFachdienstClient.self] }
        set { self[PushNotificationFachdienstClient.self] = newValue }
    }
}

private extension Data { // swiftlint:disable:this no_extension_access_modifier
    func hexEncodedString() -> String {
        map { String(format: "%02x", $0) }.joined()
    }
}
