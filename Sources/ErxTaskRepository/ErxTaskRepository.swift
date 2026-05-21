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
import Dependencies
import DependenciesMacros
import eRpKit
import Foundation

/// Interface for the app to the ErxTask data layer
/// sourcery: StreamWrapped, SkipCurrent
@DependencyClient
public struct ErxTaskRepository: Sendable {
    /// Loads the ErxTask by its id and accessCode from a remote (server).
    ///
    /// - Parameters:
    ///   - id: the `ErxTask` ID
    ///   - accessCode: when nil only load from local store(s)
    ///   - profileId: The profile identifier to which the item belongs to
    /// - Returns: A `ErxTask` or throws a `ErxRepositoryError`
    public var loadRemoteTask: @Sendable (
        _ taskId: ErxTask.ID,
        _ accessCode: String?,
        _ profileId: UUID
    ) async throws -> ErxTask?

    /// Loads the `ErxTask` by its id and accessCode from disk
    /// - Parameters:
    ///   - id: the `ErxTask` ID
    ///   - accessCode: when nil only look for the `id`
    /// - Returns: A `ErxTask` or throws a `ErxRepositoryError`
    public var loadLocalTask: @Sendable (
        _ taskId: ErxTask.ID,
        _ accessCode: String?
    ) -> AnyPublisher<ErxTask?, ErxRepositoryError> = { _, _ in
        Fail(error: ErxRepositoryError.local(.notImplemented)).eraseToAnyPublisher()
    }

    /// Load all local tasks (from disk)
    /// - Parameter profileId: The profile identifier to which the item belongs to
    /// - Returns: A list of `ErxTask` or throws a `ErxRepositoryError`
    public var loadLocalAllTasks: @Sendable (_ profileId: UUID?) -> AnyPublisher<[ErxTask], ErxRepositoryError>
        = { _ in
            Fail(error: ErxRepositoryError.local(.notImplemented)).eraseToAnyPublisher()
        }

    /// Load all ErxTasks (from remote)
    /// - Parameters:
    ///   - locale: Language locale  in which the result should be returned
    ///   - profileId: The profile identifier to which the item belongs to
    /// - Returns: A list of `ErxTask` or throws a `ErxRepositoryError`
    public var loadRemoteAllTasks: @Sendable (_ locale: String?, _ profileId: UUID?) async throws -> [ErxTask]

    /// Saves an array of `ErxTask`s
    /// - Parameters:
    ///   - erxTasks: the `ErxTask`s to be saved
    ///   - profileId: The profile identifier to which the item belongs to
    /// - Returns: `Void` if successful or throws a `ErxRepositoryError`
    public var saveTask: @Sendable (_ erxTasks: [ErxTask], _ profileId: UUID?) async throws -> Void

    /// Delete an array of `ErxTask`s
    /// - Parameters:
    ///   - erxTasks: the `ErxTask`s to be deleted
    ///   - profileId: The profile identifier to which the item belongs to
    /// - Returns: `Void` if successful or throws a `ErxRepositoryError`
    public var deleteTask: @Sendable (_ erxTasks: [ErxTask], _ profileId: UUID?) async throws -> Void

    /// Marks the `ErxTask` by its id as EU redeemable by a patient
    /// - Parameters:
    ///   - id: the `ErxTask` ID
    ///   - profileId: The profile identifier to which the item belongs to
    ///   - byPatientAuthorization: marks the task as EU redeemable
    /// - Returns: `Void` if successful or throws a `ErxRepositoryError`
    public var markTaskEURedeemable: @Sendable (
        _ taskId: ErxTask.ID,
        _ profileId: UUID,
        _ byPatientAuthorization: Bool
    ) async throws -> Void

    /// Set a redeem request of  an `ErxTask` in the selected pharmacy
    /// Note: The response does not verify that the pharmacy has accepted the order
    /// - Parameter order: Order that contains informations about the task,  redeem option
    ///                     and the pharmacy where the task should be redeemed
    /// - Returns: The `ErxTaskOrder` that has been redeemed or throws a `ErxRepositoryError`
    public var redeem: @Sendable (_ order: ErxTaskOrder) async throws -> ErxTaskOrder

    /// Load All communications of the given profile
    /// - Returns: Array of all unread loaded `ErxTaskCommunication` sorted by timestamp
    /// - Parameter profile: Filters for the passed profile type
    public var loadLocalCommunications: @Sendable (
        _ profile: ErxTask.Communication.Profile
    ) async throws -> [ErxTask.Communication]

    /// Save communications `isRead` property to local data store.
    /// - Parameters:
    ///   - communications: communications where the `isRead` state should be changed.
    ///   - profileId: The profile identifier to which the item belongs to
    /// - Returns: `Void` if successful or throws a `ErxRepositoryError`
    public var saveLocalCommunications: @Sendable (_ communications: [ErxTask.Communication],
                                                   _ profileId: UUID?) async throws -> Void

    /// Updates `DiGaInfo` property to local data store.
    /// - Parameter diGaInfo: new`DiGaInfo` that should be updated.
    /// - Returns: `Void` if successful or throws a `ErxRepositoryError`
    public var updateLocalDiGaInfo: @Sendable (_ diGaInfo: DiGaInfo) async throws -> Void

    /// Returns a count for all unread communications for the given profile
    /// - Parameters:
    ///   - profileId: The profile identifier to which the item belongs to
    ///   - fhirProfile: profile for which you want to have the count
    /// - Returns: A stream of the count if successful or throws a `ErxRepositoryError`
    public var countAllUnreadCommunicationsAndChargeItems: @Sendable ( // swiftlint:disable:this identifier_name
        _ profileId: UUID,
        _ fhirProfile: ErxTask.Communication.Profile
    ) -> AsyncThrowingStream<Int, Swift.Error> = { _, _ in
        AsyncThrowingStream { $0.finish() }
    }

    /// Load all AuditEvent's from a remote (server)
    /// - Parameter locale: Language locale  in which the result should be returned
    /// - Returns: A list of `ErxAuditEvent` as `PagedContent` or throws a `ErxRepositoryError`
    public var loadRemoteLatestAuditEvents: @Sendable (_ locale: String?) async throws -> PagedContent<[ErxAuditEvent]>

    /// Load one page of audit events from a remote (server) from an url previously provided by the server
    /// - Parameters:
    ///   - url: Destination of the request
    ///   - locale: Language locale  in which the result should be returned
    /// - Returns: A list of `ErxAuditEvent` as `PagedContent` or throws a `ErxRepositoryError`
    public var loadRemoteAuditEvents: @Sendable (_ url: URL, _ locale: String?) async throws
        -> PagedContent<[ErxAuditEvent]>

    /// Load all ErxChargeItem's from a remote (server).
    ///
    /// - Parameter profileId: The profile identifier to which the item belongs to
    /// - Returns: A list of all `ErxChargeItems`s or throws a `ErxRepositoryError`
    public var loadRemoteChargeItems: @Sendable (_ profileId: UUID?) async throws -> [ErxSparseChargeItem]

    /// Loads All consents of a given profile
    /// Uses the request headers  ACCESS_TOKEN with the containing insurance id
    ///
    /// - Parameter profileId: The profile whose FHIR session should be used for the request
    /// - Returns: A list of all loaded `ErxConsent` or throws a `ErxRepositoryError`
    public var fetchConsents: @Sendable (_ profileId: UUID) async throws -> [ErxConsent]

    /// Loads the `ErxChargeItem` by its id from disk
    /// - Parameters:
    ///   - profileId: The profile identifier to which the item belongs to
    ///   - sparseChargeItemId: the `ErxChargeItem` ID
    /// - Returns: A `ErxSparseChargeItem` or throws a `ErxRepositoryError`
    public var loadLocalChargeItem: @Sendable (
        _ profileId: UUID?,
        _ sparseChargeItemId: ErxSparseChargeItem.ID
    ) async throws
        -> ErxSparseChargeItem?

    /// Load all local charge items (from disk)
    /// - Parameter profileId: The profile identifier to which the item belongs to
    /// - Returns: A list of all `ErxChargeItems`s or throws a `ErxRepositoryError`
    public var loadLocalAllChargeItems: @Sendable (_ profileId: UUID?) async throws -> [ErxSparseChargeItem]

    /// Saves an array of `ErxChargeItem`s
    /// - Parameters:
    ///   - chargeItems: the `ErxChargeItem`s to be saved
    ///   - profileId: The profile identifier to which the item belongs to
    /// - Returns: `Void` if successful or throws a `ErxRepositoryError`
    public var saveChargeItems: @Sendable (_ chargeItems: [ErxSparseChargeItem], _ profileId: UUID?) async throws
        -> Void

    /// Delete an array of `ErxChargeItem`s from a remote (server) and local (disk)
    /// - Parameters:
    ///   - chargeItems: the `ErxChargeItem`s to be deleted
    ///   - profileId: The profile identifier to which the item belongs to
    /// - Returns: `Void` if successful or throws a `ErxRepositoryError`
    public var deleteChargeItems: @Sendable (_ chargeItems: [ErxChargeItem], _ profileId: UUID?) async throws -> Void

    /// Delete an array of `ErxChargeItem`s from local (disk)
    /// - Parameters:
    ///   - chargeItems: the `ErxChargeItem`s to be deleted
    ///   - profileId: The profile identifier to which the item belongs to
    /// - Returns: `Void` if successful or throws a `ErxRepositoryError`
    public var deleteLocalChargeItems: @Sendable (_ chargeItems: [ErxChargeItem], _ profileId: UUID?) async throws
        -> Void

    /// Send a grant consent request of  an `ErxConsent`
    ///
    /// - Parameters:
    ///   - consent: Consent that contains information about the type of consent
    ///                         and insurance id which the consent will be granted for
    ///   - profileId: The profile whose FHIR session should be used for the request
    /// - Returns: The `ErxConsent` that was granted  or throws a `ErxRepositoryError`
    public var grantConsent: @Sendable (_ consent: ErxConsent, _ profileId: UUID) async throws -> ErxConsent?

    /// Delete an consent of `ErxConsent` to revoke it
    /// - Parameters:
    ///   - category: the `ErxConsent.Category`of the consent to be revoked
    ///   - profileId: The profile whose FHIR session should be used for the request
    /// - Returns: `Void` if successful or throws a `ErxRepositoryError`
    public var revokeConsent: @Sendable (_ category: ErxConsent.Category, _ profileId: UUID) async throws -> Void

    public var loadRemoteEuAccessCode: @Sendable () async throws -> EuAccessCode?

    public var grantEuAccessPermission: @Sendable (_ accessCode: EuAccessCode) async throws -> EuAccessCode?

    public var deleteEuAccessCode: @Sendable (_ profileId: UUID?) async throws -> Void

    public var saveEuCommunication: @Sendable (_ euCommunications: [EuCommunication], _ profileId: UUID?) async throws
        -> Void

    public var deleteEuCommunications: @Sendable (_ euCommunications: [EuCommunication],
                                                  _ profileId: UUID?) async throws -> Void

    public var loadEuCommunications: @Sendable (_ countryCode: String?, _ profileId: UUID?) async throws
        -> [EuCommunication]

    public var loadLatestActiveEuCommunication: @Sendable (_ profileId: UUID?) async throws -> EuCommunication?
}

extension DependencyValues {
    /// Access to the `ErxTaskRepository` dependency.
    public var erxTaskRepository: ErxTaskRepository {
        get { self[ErxTaskRepository.self] }
        set { self[ErxTaskRepository.self] = newValue }
    }
}

extension ErxTaskRepository: TestDependencyKey {
    public static let testValue: ErxTaskRepository = Self()
}
