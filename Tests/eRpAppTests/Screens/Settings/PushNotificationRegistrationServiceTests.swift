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

import Combine
import ConcurrencyExtras
import Dependencies
@testable import eRpFeatures
import eRpKit
import FHIRClient
import HTTPClient
import Nimble
import PushNotificationCrypto
import Sharing
import XCTest

@MainActor
final class PushNotificationRegistrationServiceTests: XCTestCase {
    static let testProfileId = UUID()
    static let testKeyIdentifier = UUID(uuidString: "f47ac10b-58cc-4372-a567-0e02b2c3d479")!

    var mockUserSessionProvider: UserSessionProviderMock!
    var mockUserSession: MockUserSession!
    var mockLoginHandler: LoginHandlerMock!
    var mockUserDataStore: UserDataStoreMock!

    override func invokeTest() {
        mockUserSessionProvider = UserSessionProviderMock()
        mockUserDataStore = UserDataStoreMock()
        // Selects an `AppConfiguration` whose `pushGateway` host is populated.
        mockUserDataStore.serverEnvironmentName = "RU"

        withDependencies { dependencies in
            dependencies.userSessionProvider = mockUserSessionProvider
            dependencies.userDataStore = mockUserDataStore
        } operation: {
            super.invokeTest()
        }
    }

    override func setUp() {
        super.setUp()
        mockUserSession = MockUserSession()
        mockLoginHandler = LoginHandlerMock()
        mockUserSession.idpSessionLoginHandler = mockLoginHandler
        mockUserSessionProvider.userSessionForUuidUUIDUserSessionReturnValue = mockUserSession
    }

    private func authenticated(_ value: Bool) {
        mockLoginHandler.isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverReturnValue =
            Just(.success(value)).eraseToAnyPublisher()
    }

    // MARK: - register

    func testRegister_happyPath_postsPusherAndInitializesKeyChain() async throws {
        authenticated(true)

        let iss = Data([0x01, 0x02, 0x03, 0x04])
        let capturedRegistration = LockIsolated<PusherRegistration?>(nil)
        let capturedKeyChain = LockIsolated<CapturedKeyChain?>(nil)

        let result = try await withDependencies { dependencies in
            dependencies.uuid = .constant(Self.testKeyIdentifier)
            dependencies.apnsRegistrationService.requestAuthorizationAndRegister = {
                Data([0xAB, 0xCD, 0xEF])
            }
            dependencies.pushNotificationCrypto.createInitialSharedSecret = {
                (iss: iss, timeCreated: "2023-10")
            }
            dependencies.pushNotificationCrypto.initializeKeyChain = { iss, time, keyId in
                capturedKeyChain.setValue(CapturedKeyChain(iss: iss, time: time, keyId: keyId))
            }
            dependencies.pushNotificationFachdienstClient.setPusher = { _, registration in
                capturedRegistration.setValue(registration)
            }
        } operation: {
            try await PushNotificationRegistrationService.liveValue.register(Self.testProfileId)
        }

        expect(result) == .registered

        let registration = try XCTUnwrap(capturedRegistration.value)
        expect(registration.pushkey) == "abcdef"
        expect(registration.initialSharedSecret) == "01020304"
        expect(registration.timeISSCreated) == "2023-10"
        expect(registration.keyIdentifier) == Self.testKeyIdentifier.uuidString
        expect(registration.appId) == "\(Bundle.main.bundleIdentifier ?? "").apns"
        expect(registration.pushGatewayURL).to(endWith("/push/v1/"))

        // Key chain is initialised with the same iss/time/keyIdentifier after the FD response.
        let keyChain = try XCTUnwrap(capturedKeyChain.value)
        expect(keyChain.iss) == iss
        expect(keyChain.time) == "2023-10"
        expect(keyChain.keyId) == Self.testKeyIdentifier.uuidString

        // The registration is persisted locally for later deregistration / channel config.
        @Shared(.pushNotificationRegistrations) var registrations
        let stored = try XCTUnwrap(registrations[Self.testProfileId.uuidString])
        expect(stored.keyIdentifier) == Self.testKeyIdentifier.uuidString
        expect(stored.pushkey) == "abcdef"
        expect(stored.channels).to(beEmpty())
    }

    func testRegister_notAuthenticated_doesNotCallFachdienst() async throws {
        authenticated(false)

        let setPusherCalled = LockIsolated(false)

        let result = try await withDependencies { dependencies in
            dependencies.pushNotificationFachdienstClient.setPusher = { _, _ in
                setPusherCalled.setValue(true)
            }
        } operation: {
            try await PushNotificationRegistrationService.liveValue.register(Self.testProfileId)
        }

        expect(result) == .notAuthenticated
        expect(setPusherCalled.value) == false

        @Shared(.pushNotificationRegistrations) var registrations
        expect(registrations[Self.testProfileId.uuidString]).to(beNil())
    }

    func testRegister_permissionDenied_doesNotCallFachdienstOrInitKeyChain() async throws {
        authenticated(true)

        let setPusherCalled = LockIsolated(false)
        let initKeyChainCalled = LockIsolated(false)

        let result = try await withDependencies { dependencies in
            dependencies.apnsRegistrationService.requestAuthorizationAndRegister = {
                throw APNSRegistrationError.permissionDenied
            }
            dependencies.pushNotificationCrypto.initializeKeyChain = { _, _, _ in
                initKeyChainCalled.setValue(true)
            }
            dependencies.pushNotificationFachdienstClient.setPusher = { _, _ in
                setPusherCalled.setValue(true)
            }
        } operation: {
            try await PushNotificationRegistrationService.liveValue.register(Self.testProfileId)
        }

        expect(result) == .permissionDenied
        expect(setPusherCalled.value) == false
        expect(initKeyChainCalled.value) == false
    }

    // MARK: - deregister

    func testDeregister_callsDeletePusherAndClearsLocalState() async throws {
        @Shared(.pushNotificationRegistrations) var registrations
        $registrations.withLock {
            $0[Self.testProfileId.uuidString] = .init(keyIdentifier: "kid", pushkey: "the-pushkey", channels: ["c1"])
        }

        let capturedPushkey = LockIsolated<String?>(nil)

        try await withDependencies { dependencies in
            dependencies.pushNotificationFachdienstClient.deletePusher = { _, pushkey, _ in
                capturedPushkey.setValue(pushkey)
            }
        } operation: {
            try await PushNotificationRegistrationService.liveValue.deregister(Self.testProfileId)
        }

        expect(capturedPushkey.value) == "the-pushkey"
        expect(registrations[Self.testProfileId.uuidString]).to(beNil())
    }

    func testDeregister_whenNotRegistered_isNoOp() async throws {
        let deleteCalled = LockIsolated(false)

        try await withDependencies { dependencies in
            dependencies.pushNotificationFachdienstClient.deletePusher = { _, _, _ in
                deleteCalled.setValue(true)
            }
        } operation: {
            try await PushNotificationRegistrationService.liveValue.deregister(Self.testProfileId)
        }

        expect(deleteCalled.value) == false
    }

    // MARK: - configureChannel

    func testConfigureChannel_enable_updatesLocalChannels() async throws {
        @Shared(.pushNotificationRegistrations) var registrations
        $registrations.withLock {
            $0[Self.testProfileId.uuidString] = .init(keyIdentifier: "kid", pushkey: "pk", channels: [])
        }

        let capturedChannels = LockIsolated<[ChannelSubscription]>([])

        // A user-facing toggle maps to a group of Fachdienst channels; all are set together.
        let group = ["erp.task.accept", "erp.task.close"]

        try await withDependencies { dependencies in
            dependencies.pushNotificationFachdienstClient.setChannels = { _, _, channels in
                capturedChannels.setValue(channels)
            }
        } operation: {
            try await PushNotificationRegistrationService.liveValue
                .configureChannel(Self.testProfileId, group, true)
        }

        let channels = capturedChannels.value
        expect(channels.count) == 2
        expect(channels.map(\.channelId)) == group
        expect(channels.allSatisfy(\.enabled)) == true
        expect(Set(registrations[Self.testProfileId.uuidString]?.channels ?? [])) == Set(group)
    }

    func testConfigureChannel_whenNotRegistered_throwsNotRegistered() async {
        var didThrow = false
        do {
            try await PushNotificationRegistrationService.liveValue
                .configureChannel(Self.testProfileId, ["erp.task.activate"], true)
        } catch {
            expect { throw error }.to(throwError(PushNotificationRegistrationError.notRegistered))
            didThrow = true
        }
        expect(didThrow) == true
    }

    // MARK: - loadChannels

    func testLoadChannels_delegatesToFachdienstWithLocalPushkey() async throws {
        @Shared(.pushNotificationRegistrations) var registrations
        $registrations.withLock {
            $0[Self.testProfileId.uuidString] = .init(keyIdentifier: "kid", pushkey: "the-pushkey", channels: [])
        }

        let capturedPushkey = LockIsolated<String?>(nil)
        let expected = [ChannelState(id: "erp.task.activate", status: .enabled)]

        let result = try await withDependencies { dependencies in
            dependencies.pushNotificationFachdienstClient.getChannels = { _, pushkey in
                capturedPushkey.setValue(pushkey)
                return expected
            }
        } operation: {
            try await PushNotificationRegistrationService.liveValue.loadChannels(Self.testProfileId)
        }

        expect(capturedPushkey.value) == "the-pushkey"
        expect(result) == expected
    }

    func testLoadChannels_whenNotRegistered_throwsNotRegistered() async {
        var didThrow = false
        do {
            _ = try await PushNotificationRegistrationService.liveValue.loadChannels(Self.testProfileId)
        } catch {
            expect { throw error }.to(throwError(PushNotificationRegistrationError.notRegistered))
            didThrow = true
        }
        expect(didThrow) == true
    }

    // MARK: - getChannels (transport)

    func testGetChannels_getsPushkeyPathAndDecodesChannelStates() async throws {
        let json = Data("""
        {
          "channels": [
            { "id": "erp.task.activate", "status": "enabled" },
            { "id": "erp.communication.new", "status": "disabled" },
            { "id": "erp.task.close", "status": "not_set" }
          ]
        }
        """.utf8)

        let capturedRequest = LockIsolated<URLRequest?>(nil)
        let stub = StubHTTPClient(capturedRequest: capturedRequest, responseData: json, status: .ok)
        let fhirClient = try FHIRClient(
            server: XCTUnwrap(URL(string: "https://this.is.the.inner.vau.request/")),
            httpClient: stub,
            receiveQueue: .immediate
        )

        let result = try await withDependencies { dependencies in
            dependencies.fhirClientServiceFactory.erpClientForProfile = { _ in fhirClient }
        } operation: {
            try await PushNotificationFachdienstClient.liveValue.getChannels(Self.testProfileId, "device pushkey")
        }

        expect(result) == [
            ChannelState(id: "erp.task.activate", status: .enabled),
            ChannelState(id: "erp.communication.new", status: .disabled),
            ChannelState(id: "erp.task.close", status: .notSet),
        ]

        // GET against the percent-encoded pushkey path under /channels/v1/.
        let request = try XCTUnwrap(capturedRequest.value)
        expect(request.httpMethod) == "GET"
        expect(request.url?.absoluteString) ==
            "https://this.is.the.inner.vau.request/channels/v1/device%20pushkey"
    }

    // MARK: - setPusher (transport)

    func testSetPusher_postsWithContentLengthHeaderMatchingBody() async throws {
        let capturedRequest = LockIsolated<URLRequest?>(nil)
        let stub = StubHTTPClient(capturedRequest: capturedRequest, responseData: Data("{}".utf8), status: .ok)
        let fhirClient = try FHIRClient(
            server: XCTUnwrap(URL(string: "https://this.is.the.inner.vau.request/")),
            httpClient: stub,
            receiveQueue: .immediate
        )

        let registration = PusherRegistration(
            appId: "de.gematik.erp4ios.eRezept.apns",
            pushkey: "abc123",
            appDisplayName: "E-Rezept",
            deviceDisplayName: "iPhone",
            lang: "de",
            pushGatewayURL: "https://gw.example.com/push/v1/",
            initialSharedSecret: "00112233",
            timeISSCreated: "2026-07",
            keyIdentifier: "5EBB1486-7430-42C0-B9AA-B57CA6C90EA4"
        )

        try await withDependencies { dependencies in
            dependencies.fhirClientServiceFactory.erpClientForProfile = { _ in fhirClient }
        } operation: {
            try await PushNotificationFachdienstClient.liveValue.setPusher(Self.testProfileId, registration)
        }

        let request = try XCTUnwrap(capturedRequest.value)
        expect(request.httpMethod) == "POST"
        expect(request.url?.absoluteString) == "https://this.is.the.inner.vau.request/pushers/v1/set"
        // Content-Length must be set explicitly: the VAU inner request is serialized manually and the
        // FD's HTTP parser rejects the body ("Content-Length missing or too low") without it.
        let body = try XCTUnwrap(request.httpBody)
        expect(request.value(forHTTPHeaderField: "Content-Length")) == String(body.count)
    }

    // MARK: - pushGatewayURL helper

    func testPushGatewayURL_appendsPushV1Path() throws {
        let withSlash = try XCTUnwrap(URL(string: "https://gw.example.com/"))
        let withoutSlash = try XCTUnwrap(URL(string: "https://gw.example.com"))

        expect(PushNotificationRegistrationService.pushGatewayURL(for: withSlash)) ==
            "https://gw.example.com/push/v1/"
        expect(PushNotificationRegistrationService.pushGatewayURL(for: withoutSlash)) ==
            "https://gw.example.com/push/v1/"
    }
}

extension PushNotificationRegistrationServiceTests {
    /// Captures the arguments passed to `pushNotificationCrypto.initializeKeyChain`.
    struct CapturedKeyChain {
        let iss: Data
        let time: String
        let keyId: String
    }
}

/// Minimal `HTTPClient` stub that records the outgoing request and returns a canned response.
private struct StubHTTPClient: HTTPClient {
    let capturedRequest: LockIsolated<URLRequest?>
    let responseData: Data
    let status: HTTPStatusCode

    var interceptors: [Interceptor] {
        []
    }

    func send(
        request: URLRequest,
        interceptors _: [Interceptor],
        redirect _: RedirectHandler?
    ) async throws -> HTTPResponse {
        capturedRequest.setValue(request)
        let httpResponse = HTTPURLResponse(
            url: request.url!,
            statusCode: status.rawValue,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        return (responseData, httpResponse, status)
    }
}
