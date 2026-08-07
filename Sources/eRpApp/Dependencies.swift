// swiftlint:disable:this file_name
// swiftlint:disable file_length
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
import ComposableArchitecture
import Dependencies
import FeatureCardWall
import Foundation
import XCTestDynamicOverlay

// MARK: - ErxTask

import AsyncAlgorithms
import eRpKit
import ErxTaskRepository
import IDP
import IDPLive
import Settings
import TrustStore
import VAUClient

extension ErxTaskRepository: DependencyKey {
    private static let profile: @Sendable (UUID) async throws -> Profile? = { profileId in
        @Dependency(\.profileDataStore) var profileDataStore
        // After sanitising the database there should be a profile available which is set as the selected profile
        do {
            return try await profileDataStore.fetchProfile(by: profileId).async()
        } catch {
            return nil
        }
    }

    public static let liveValue = ErxTaskRepository { taskId, accessCode, profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.loadRemoteTask(
                taskId: taskId,
                accessCode: accessCode,
                profileId: profileId
            )
        }
        return try await Self.defaultImplementation.loadRemoteTask(
            taskId: taskId,
            accessCode: accessCode,
            profileId: profileId
        )
    } loadLocalTask: { taskId, accessCode in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return Self.demoMode.loadLocalTask(taskId: taskId, accessCode: accessCode)
        }
        return Self.defaultImplementation.loadLocalTask(taskId: taskId, accessCode: accessCode)
    } loadLocalAllTasks: { profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return Self.demoMode.loadLocalAllTasks(profileId: profileId)
        }
        return Self.defaultImplementation.loadLocalAllTasks(profileId: profileId)
    } loadRemoteAllTasks: { locale, profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.loadRemoteAllTasks(locale: locale, profileId: profileId)
        }
        return try await Self.defaultImplementation.loadRemoteAllTasks(locale: locale, profileId: profileId)
    } saveTask: { tasks, profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.saveTask(erxTasks: tasks, profileId: profileId)
        }
        return try await Self.defaultImplementation.saveTask(erxTasks: tasks, profileId: profileId)
    } deleteTask: { erxTasks, profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.deleteTask(erxTasks: erxTasks, profileId: profileId)
        }
        return try await Self.defaultImplementation.deleteTask(erxTasks: erxTasks, profileId: profileId)
    } markTaskEURedeemable: { taskId, profileId, byPatientAuthorization in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.markTaskEURedeemable(taskId, profileId, byPatientAuthorization)
        }
        return try await Self.defaultImplementation.markTaskEURedeemable(taskId, profileId, byPatientAuthorization)
    } redeem: { order in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.redeem(order)
        }
        return try await Self.defaultImplementation.redeem(order)
    } loadLocalCommunications: { profile in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.loadLocalCommunications(profile: profile)
        }
        return try await Self.defaultImplementation.loadLocalCommunications(profile: profile)
    } saveLocalCommunications: { communications, profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.saveLocalCommunications(
                communications: communications,
                profileId: profileId
            )
        }
        return try await Self.defaultImplementation.saveLocalCommunications(
            communications: communications,
            profileId: profileId
        )
    } updateLocalDiGaInfo: { diGaInfo in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.updateLocalDiGaInfo(diGaInfo)
        }
        return try await Self.defaultImplementation.updateLocalDiGaInfo(diGaInfo)
    } countAllUnreadCommunicationsAndChargeItems: { profileId, commProfile in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return Self.demoMode.countAllUnreadCommunicationsAndChargeItems(profileId, commProfile)
        }
        return Self.defaultImplementation.countAllUnreadCommunicationsAndChargeItems(
            profileId,
            commProfile
        )
    } loadRemoteLatestAuditEvents: { locale in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.loadRemoteLatestAuditEvents(locale)
        }
        return try await Self.defaultImplementation.loadRemoteLatestAuditEvents(locale)
    } loadRemoteAuditEvents: { url, locale in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.loadRemoteAuditEvents(url, locale)
        }
        return try await Self.defaultImplementation.loadRemoteAuditEvents(url, locale)
    } loadRemoteChargeItems: { profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.loadRemoteChargeItems(profileId)
        }
        return try await Self.defaultImplementation.loadRemoteChargeItems(profileId)
    } fetchConsents: { profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.fetchConsents(profileId)
        }
        return try await Self.defaultImplementation.fetchConsents(profileId)
    } loadLocalChargeItem: { profileId, chargeItemId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.loadLocalChargeItem(profileId, chargeItemId)
        }
        return try await Self.defaultImplementation.loadLocalChargeItem(profileId, chargeItemId)
    } loadLocalAllChargeItems: { profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.loadLocalAllChargeItems(profileId)
        }
        return try await Self.defaultImplementation.loadLocalAllChargeItems(profileId)
    } saveChargeItems: { chargeItems, profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.saveChargeItems(chargeItems, profileId)
        }
        return try await Self.defaultImplementation.saveChargeItems(chargeItems, profileId)
    } deleteChargeItems: { chargeItems, profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.deleteChargeItems(chargeItems, profileId)
        }
        return try await Self.defaultImplementation.deleteChargeItems(chargeItems, profileId)
    } deleteLocalChargeItems: { chargeItems, profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.deleteLocalChargeItems(chargeItems, profileId)
        }
        return try await Self.defaultImplementation.deleteLocalChargeItems(chargeItems, profileId)
    } grantConsent: { consent, profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.grantConsent(consent, profileId)
        }
        return try await Self.defaultImplementation.grantConsent(consent, profileId)
    } revokeConsent: { category, profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.revokeConsent(category, profileId)
        }
        return try await Self.defaultImplementation.revokeConsent(category, profileId)
    } loadRemoteEuAccessCode: {
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.loadRemoteEuAccessCode()
        }
        return try await Self.defaultImplementation.loadRemoteEuAccessCode()
    } grantEuAccessPermission: { euAccessCode in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.grantEuAccessPermission(euAccessCode)
        }
        return try await Self.defaultImplementation.grantEuAccessPermission(euAccessCode)
    } deleteEuAccessCode: { profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.deleteEuAccessCode(profileId: profileId)
        }
        return try await Self.defaultImplementation.deleteEuAccessCode(profileId: profileId)
    } saveEuCommunication: { euCommunications, profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.saveEuCommunication(
                euCommunications: euCommunications,
                profileId: profileId
            )
        }
        return try await Self.defaultImplementation.saveEuCommunication(
            euCommunications: euCommunications,
            profileId: profileId
        )
    } deleteEuCommunications: { euCommunications, profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.deleteEuCommunications(
                euCommunications: euCommunications,
                profileId: profileId
            )
        }
        return try await Self.defaultImplementation.deleteEuCommunications(
            euCommunications: euCommunications,
            profileId: profileId
        )
    } loadEuCommunications: { countryCode, profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.loadEuCommunications(countryCode: countryCode, profileId: profileId)
        }
        return try await Self.defaultImplementation.loadEuCommunications(
            countryCode: countryCode,
            profileId: profileId
        )
    } loadLatestActiveEuCommunication: { profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return try await Self.demoMode.loadLatestActiveEuCommunication(profileId: profileId)
        }
        return try await Self.defaultImplementation.loadLatestActiveEuCommunication(profileId: profileId)
    }

    public static let previewValue = ErxTaskRepository()
}

extension ErxTaskRepository {
    /// Demo mode implementation
    public static var demoMode = {
        @Dependency(\.userSession) var userSession
        return ErxTaskRepository.demoErxTaskRepository(secureUserStore: userSession.secureUserStore)
    }()

    private static var secureUserStore: SecureUserDataStore {
        MemoryStorage()
    }

    /// Default implementation
    public static var defaultImplementation = {
        @Dependency(\.erxRemoteDataStore) var cloud
        @Dependency(\.erxLocalDataStore) var disk

        return ErxTaskRepository { taskId, accessCode, profileId in
            if let accessCode {
                do {
                    guard let remoteTask = try await cloud.fetchTask(
                        by: taskId,
                        accessCode: accessCode,
                        profileId: profileId
                    )
                    .async()
                    else { return nil }
                    _ = try await disk.save(tasks: [remoteTask], in: profileId, updateProfileLastAuthenticated: false)
                        .async()
                    return remoteTask
                } catch let error as LocalStoreError {
                    throw ErxRepositoryError.local(error)
                } catch let error as RemoteStoreError {
                    throw ErxRepositoryError.remote(error)
                }
            } else {
                do {
                    return try await disk.fetchTask(by: taskId, accessCode: accessCode).async()
                } catch let error as LocalStoreError {
                    throw ErxRepositoryError.local(error)
                }
            }
        } loadLocalTask: { taskId, accessCode in
            disk.fetchTask(by: taskId, accessCode: accessCode)
                .mapError(ErxRepositoryError.local)
                .eraseToAnyPublisher()
        } loadLocalAllTasks: { profileId in
            disk.listAllTasks(of: profileId)
                .mapError(ErxRepositoryError.local)
                .eraseToAnyPublisher()
        } loadRemoteAllTasks: { _, profileId in
            do {
                try await loadRemoteLatestTasks(profileId)
                try await loadRemoteLatestCommunications(profileId)
                if let profileId,
                   try await profile(profileId)?.insuranceType == Profile.InsuranceType.pKV {
                    _ = try await loadRemoteLatestChargeItems(profileId)
                }
                return try await disk.listAllTasks(of: profileId).async()
            } catch let error as LocalStoreError {
                throw ErxRepositoryError.local(error)
            } catch let error as RemoteStoreError {
                throw ErxRepositoryError.remote(error)
            }
        } saveTask: { tasks, profileId in
            do {
                _ = try await disk.save(tasks: tasks, in: profileId, updateProfileLastAuthenticated: false).async()
            } catch let error as LocalStoreError {
                throw ErxRepositoryError.local(error)
            }
        } deleteTask: { erxTasks, profileId in
            let schedules = erxTasks.compactMap(\.medicationSchedule)
            // Delete only locally when all tasks are scanned tasks
            if erxTasks.allSatisfy({ $0.source == ErxTask.Source.scanner }) {
                do {
                    _ = try await disk.delete(tasks: erxTasks, in: profileId).async()
                    try await deleteSchedules(schedules)
                } catch let error as LocalStoreError {
                    throw ErxRepositoryError.local(error)
                }
                // Delete remote & locally when at least one is not a scanned task
            } else {
                @Shared(.selectedProfileId) var selectedProfileId: UUID
                do {
                    _ = try await cloud.delete(tasks: erxTasks, profileId: profileId ?? selectedProfileId).async()
                    _ = try await disk.delete(tasks: erxTasks, in: profileId).async()
                    try await deleteSchedules(schedules)
                } catch let error as LocalStoreError {
                    throw ErxRepositoryError.local(error)
                } catch let error as RemoteStoreError {
                    throw ErxRepositoryError.remote(error)
                }
            }
        } markTaskEURedeemable: { taskId, profileId, authorization in
            do {
                _ = try await cloud.markEURedeemable(
                    for: taskId,
                    byPatientAuthorization: authorization,
                    profileId: profileId
                )
                .async()
                var task = try await disk.fetchTask(by: taskId, accessCode: nil).async()
                task?.isSetEURedeemableByPatient = authorization
                if let task {
                    _ = try await disk.save(tasks: [task], in: profileId, updateProfileLastAuthenticated: false).async()
                }
                return
            } catch let error as RemoteStoreError {
                throw ErxRepositoryError.remote(error)
            }
        } redeem: { order in
            @Shared(.selectedProfileId) var selectedProfileId: UUID
            do {
                return try await cloud.redeem(order: order, profileId: selectedProfileId).async()
            } catch let error as RemoteStoreError {
                throw ErxRepositoryError.remote(error)
            }
        } loadLocalCommunications: { profile in
            do {
                return try await disk.listAllCommunications(for: profile).async()
            } catch let error as LocalStoreError {
                throw ErxRepositoryError.local(error)
            }
        } saveLocalCommunications: { communications, profileId in
            do {
                _ = try await disk.save(communications: communications, of: profileId).async()
            } catch let error as LocalStoreError {
                throw ErxRepositoryError.local(error)
            }
        } updateLocalDiGaInfo: { diGaInfo in
            do {
                _ = try await disk.update(diGaInfo: diGaInfo).async()
            } catch let error as LocalStoreError {
                throw ErxRepositoryError.local(error)
            }
        } countAllUnreadCommunicationsAndChargeItems: { profileId, commProfile in
            AsyncThrowingStream { continuation in
                Task {
                    do {
                        let communicationValues = disk.listAllCommunications(for: commProfile)
                            .buffer(
                                size: 1,
                                prefetch: .byRequest,
                                whenFull: .dropOldest
                            ).values
                        let euCommunicationValues = disk.listAllEuCommunication(countryCode: nil, profileId: nil)
                            .buffer(
                                size: 1,
                                prefetch: .byRequest,
                                whenFull: .dropOldest
                            ).values
                        let chargeItemValues = disk.listAllChargeItems(of: profileId)
                            .buffer(
                                size: 1,
                                prefetch: .byRequest,
                                whenFull: .dropOldest
                            ).values

                        for try await (communications, euCommunications, chargeItems) in AsyncAlgorithms
                            .combineLatest(communicationValues, euCommunicationValues, chargeItemValues) {
                            // filter for unique communications
                            let uniqueCommunications = communications.filterUnique()
                            // make sure there is a communication to an existing charge item
                            // since there can be chargeItems without orders
                            let taskIds = uniqueCommunications.map(\.taskIds)
                            let relevantChargeItems = chargeItems.filter { chargeItem in
                                taskIds.contains { task in
                                    task.contains(chargeItem.identifier)
                                }
                            }
                            var count = 0
                            count += uniqueCommunications.filter { $0.isRead == false }.count
                            count += euCommunications.filter { $0.isRead == false }.count
                            count += relevantChargeItems.filter { $0.isRead == false }.count
                            continuation.yield(count)
                        }

                        continuation.finish()
                    } catch let error as LocalStoreError {
                        continuation.finish(throwing: ErxRepositoryError.local(error))
                    }
                }
            }
        } loadRemoteLatestAuditEvents: { locale in
            @Shared(.selectedProfileId) var selectedProfileId: UUID
            do {
                return try await cloud.listAllAuditEvents(after: nil, for: locale, profileId: selectedProfileId).async()
            } catch let error as RemoteStoreError {
                throw ErxRepositoryError.remote(error)
            }
        } loadRemoteAuditEvents: { url, locale in
            @Shared(.selectedProfileId) var selectedProfileId: UUID
            do {
                return try await cloud.listAuditEventsNextPage(from: url, locale: locale, profileId: selectedProfileId)
                    .async()
            } catch let error as RemoteStoreError {
                throw ErxRepositoryError.remote(error)
            }
        } loadRemoteChargeItems: { profileId in
            do {
                _ = try await loadRemoteLatestChargeItems(profileId)
                return try await disk.listAllChargeItems(of: profileId).async()
            } catch let error as LocalStoreError {
                throw ErxRepositoryError.local(error)
            } catch let error as RemoteStoreError {
                throw ErxRepositoryError.remote(error)
            }
        } fetchConsents: { profileId in
            do {
                return try await cloud.fetchConsents(profileId: profileId).async()
            } catch let error as RemoteStoreError {
                throw ErxRepositoryError.remote(error)
            }
        } loadLocalChargeItem: { profileId, chargeItemId in
            do {
                return try await disk.fetchChargeItem(of: profileId, by: chargeItemId).async()
            } catch let error as LocalStoreError {
                throw ErxRepositoryError.local(error)
            }
        } loadLocalAllChargeItems: { profileId in
            do {
                return try await disk.listAllChargeItems(of: profileId).async()
            } catch let error as LocalStoreError {
                throw ErxRepositoryError.local(error)
            }
        } saveChargeItems: { chargeItems, profileId in
            do {
                _ = try await disk.save(chargeItems: chargeItems, of: profileId).async()
            } catch let error as LocalStoreError {
                throw ErxRepositoryError.local(error)
            }
        } deleteChargeItems: { chargeItems, profileId in
            @Shared(.selectedProfileId) var selectedProfileId: UUID
            do {
                _ = try await cloud.delete(chargeItems: chargeItems, profileId: profileId ?? selectedProfileId).async()
                _ = try await disk.delete(of: profileId, chargeItems: chargeItems.map(\.sparseChargeItem)).async()
            } catch let error as LocalStoreError {
                throw ErxRepositoryError.local(error)
            } catch let error as RemoteStoreError {
                throw ErxRepositoryError.remote(error)
            }
        } deleteLocalChargeItems: { chargeItems, profileId in
            do {
                _ = try await disk.delete(of: profileId, chargeItems: chargeItems.map(\.sparseChargeItem)).async()
            } catch let error as LocalStoreError {
                throw ErxRepositoryError.local(error)
            }
        } grantConsent: { consent, profileId in
            do {
                return try await cloud.grantConsent(consent, profileId: profileId).async()
            } catch let error as RemoteStoreError {
                throw ErxRepositoryError.remote(error)
            }
        } revokeConsent: { category, profileId in
            do {
                _ = try await cloud.revokeConsent(category, profileId: profileId).async()
            } catch let error as RemoteStoreError {
                throw ErxRepositoryError.remote(error)
            }
        } loadRemoteEuAccessCode: {
            @Shared(.selectedProfileId) var selectedProfileId: UUID
            do {
                return try await cloud.loadRemoteEuAccessCode(profileId: selectedProfileId).async()
            } catch let error as RemoteStoreError {
                throw ErxRepositoryError.remote(error)
            }
        } grantEuAccessPermission: { euAccessCode in
            @Shared(.selectedProfileId) var selectedProfileId: UUID
            do {
                return try await cloud.grantEuAccessPermission(accessCode: euAccessCode, profileId: selectedProfileId)
                    .async()
            } catch let error as RemoteStoreError {
                throw ErxRepositoryError.remote(error)
            }
        } deleteEuAccessCode: { profileId in
            @Shared(.selectedProfileId) var selectedProfileId: UUID
            do {
                _ = try await cloud.deleteEuAccessCode(profileId: profileId ?? selectedProfileId).async()
            } catch let error as RemoteStoreError {
                throw ErxRepositoryError.remote(error)
            }
        } saveEuCommunication: { euCommunications, profileId in
            do {
                _ = try await disk.save(euCommunications: euCommunications, profileId: profileId).async()
            } catch let error as LocalStoreError {
                throw ErxRepositoryError.local(error)
            }
        } deleteEuCommunications: { euCommunications, profileId in
            do {
                _ = try await disk.delete(euCommunications: euCommunications, profileId: profileId).async()
            } catch let error as LocalStoreError {
                throw ErxRepositoryError.local(error)
            }
        } loadEuCommunications: { countryCode, profileId in
            do {
                return try await disk.listAllEuCommunication(countryCode: countryCode, profileId: profileId).async()
            } catch let error as RemoteStoreError {
                throw ErxRepositoryError.remote(error)
            }
        } loadLatestActiveEuCommunication: { profileId in
            do {
                return try await disk.loadLatestActiveEuCommunication(profileId: profileId).async()
            } catch let error as RemoteStoreError {
                throw ErxRepositoryError.remote(error)
            }
        }
    }()

    private static let deleteSchedules: @Sendable ([MedicationSchedule]) async throws -> Void = { schedules in
        @Dependency(\.medicationScheduleRepository) var medicationScheduleRepository
        guard !schedules.isEmpty else { return }
        do {
            _ = try await medicationScheduleRepository.delete(schedules)
        } catch let error as LocalStoreError {
            throw ErxRepositoryError.local(.delete(error: error))
        }
    }

    private static let loadRemoteLatestCommunications: @Sendable (_ profileId: UUID?) async throws
        -> Void = { profileId in
            @Dependency(\.erxRemoteDataStore) var cloud
            @Dependency(\.erxLocalDataStore) var disk
            @Shared(.selectedProfileId) var selectedProfileId: UUID
            let resolvedProfileId = profileId ?? selectedProfileId
            let timestamp = try await disk.fetchLatestTimestampForCommunications(of: profileId).async()
            let communications = try await cloud.listAllCommunications(
                after: timestamp,
                for: .all,
                profileId: resolvedProfileId
            )
            .async()
            _ = try await disk.save(communications: communications, of: profileId).async()
        }

    static let loadRemoteLatestTasks: @Sendable (_ profileId: UUID?) async throws -> Void = { profileId in
        @Dependency(\.erxRemoteDataStore) var cloud
        @Dependency(\.erxLocalDataStore) var disk
        @Shared(.selectedProfileId) var selectedProfileId: UUID
        let resolvedProfileId = profileId ?? selectedProfileId
        let timestamp = try await disk.fetchLatestLastModifiedForErxTasks(of: profileId).async()
        let tasks = try await cloud.listAllTasks(after: timestamp, profileId: resolvedProfileId).async()
        let updatedTasks = try await loadAndUpdateAllDetailedTasks(tasks, resolvedProfileId)
        try await loadRemoteMedicationDispenses(updatedTasks.content, resolvedProfileId)
        let result = try await disk.save(
            tasks: updatedTasks.content,
            in: profileId,
            updateProfileLastAuthenticated: true
        )
        .async()

        if result, tasks.next != nil {
            try await loadRemoteTasksPage(tasks, profileId)
        }
    }

    private static let loadRemoteTasksPage: @Sendable (
        _ previousPage: PagedContent<[ErxTask]>,
        _ profileId: UUID?
    ) async throws
        -> Void = { previousPage, profileId in
            @Dependency(\.erxRemoteDataStore) var cloud
            @Dependency(\.erxLocalDataStore) var disk
            @Shared(.selectedProfileId) var selectedProfileId: UUID
            let resolvedProfileId = profileId ?? selectedProfileId
            let nextPage = try await cloud.listTasksNextPage(of: previousPage, profileId: resolvedProfileId).async()
            let updatedTasks = try await loadAndUpdateAllDetailedTasks(nextPage, resolvedProfileId)
            try await loadRemoteMedicationDispenses(updatedTasks.content, resolvedProfileId)
            let result = try await disk.save(
                tasks: updatedTasks.content,
                in: profileId,
                updateProfileLastAuthenticated: true
            )
            .async()

            if result, updatedTasks.next != nil {
                try await loadRemoteTasksPage(updatedTasks, profileId)
            }
        }

    private static let loadAndUpdateAllDetailedTasks: @Sendable (
        _ tasks: PagedContent<[ErxTask]>,
        _ profileId: UUID
    ) async throws
        -> PagedContent<[ErxTask]> = { tasks, profileId in
            @Dependency(\.erxRemoteDataStore) var cloud
            @Dependency(\.erxLocalDataStore) var disk
            // Load and update cancelled local ErxTasks
            let cancelledTasks = tasks.content.filter { $0.status == .cancelled }
            var updatedCancelledTasks = [ErxTask]()
            for task in cancelledTasks {
                if var updatedTask = try await disk.fetchTask(by: task.identifier, accessCode: nil).async() {
                    updatedCancelledTasks.append(updatedTask.cancelled(on: task.lastModified))
                }
            }

            let detailedTasks = try await cloud.listDetailedTasks(for: PagedContent(
                content: tasks.content
                    .filter { $0.status != .cancelled },
                next: tasks.next
            ), profileId: profileId)
                .async()

            // Early out if no cancelled tasks are present
            guard !updatedCancelledTasks.isEmpty else {
                return detailedTasks
            }

            return PagedContent(
                content: detailedTasks.content + updatedCancelledTasks,
                next: detailedTasks.next
            )
        }

    private static let loadRemoteMedicationDispenses: @Sendable (
        _ tasks: [ErxTask],
        _ profileId: UUID
    ) async throws -> Void = { tasks, profileId in
        @Dependency(\.erxRemoteDataStore) var cloud
        @Dependency(\.erxLocalDataStore) var disk
        for task in tasks {
            if task.lastMedicationDispense != nil || task.status == .completed {
                let medDispense = try await cloud.listMedicationDispenses(for: task.id, profileId: profileId).async()
                _ = try await disk.save(medicationDispenses: medDispense).async()
            }
        }
    }

    private static let loadRemoteLatestChargeItems: @Sendable (_ profileId: UUID?) async throws -> Void = { profileId in
        @Dependency(\.erxRemoteDataStore) var cloud
        @Dependency(\.erxLocalDataStore) var disk
        @Shared(.selectedProfileId) var selectedProfileId: UUID
        let resolvedProfileId = profileId ?? selectedProfileId
        let timestamp = try await disk.fetchLatestTimestampForChargeItems(of: profileId).async()
        let chargeItems = try await cloud.listAllChargeItems(after: timestamp, profileId: resolvedProfileId).async()
        _ = try await disk.save(chargeItems: chargeItems.map(\.sparseChargeItem), of: profileId).async()
    }
}

import FeatureEURedeem

extension EuRedeemService: DependencyKey {
    public static let liveValue: EuRedeemService = .init { countryCode, profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return EuAccessCode(
                accessCode: "DEMOCODE",
                countryCode: countryCode,
                validUntil: Calendar.current.date(byAdding: .hour, value: 1, to: Date()),
                createdAt: Date()
            )
        }
        return try await Self.defaultValue.grantEuAccessCode(countryCode: countryCode, profileId: profileId)
    } markTaskEURedeemable: { taskId, byPatientAuthorization, profileId in
        try await Self.defaultValue.markTaskEURedeemable(
            taskId: taskId,
            byPatientAuthorization: byPatientAuthorization,
            profileId: profileId
        )
    } deleteEuAccessCode: { profileId in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return
        }
        return try await Self.defaultValue.deleteEuAccessCode(profileId: profileId)
    }

    /// Live implementation of EuRedeemService
    public static let defaultValue = EuRedeemService { countryCode, profileId in
        @Dependency(\.userSessionProvider) var userSessionProvider
        @Dependency(\.euAccessCodeGenerator) var euAccessCodeGenerator
        @Dependency(\.erxTaskRepository) var erxTaskRepository
        @Dependency(\.calendar) var calendar
        @Dependency(\.dateProvider) var dateProvider

        let userSession = userSessionProvider.userSession(for: profileId)
        let loginHandler = userSession.idpSessionLoginHandler
        let isAuthenticatedResult = try await loginHandler.isAuthenticatedOrAuthenticate().async()

        switch isAuthenticatedResult {
        case .success(true):
            do {
                let generatedCode = try await euAccessCodeGenerator.generatAccessCode()
                let euAccessCode = EuAccessCode(
                    accessCode: generatedCode,
                    countryCode: countryCode
                )

                let grantedEuAccessCode = try await erxTaskRepository.grantEuAccessPermission(euAccessCode)

                // Check if we already got an EuAccessCode from this country in the last 7 days
                let localEuCommunications = try await erxTaskRepository.loadEuCommunications(
                    countryCode: countryCode,
                    profileId: profileId
                )

                let todayStart = calendar.startOfDay(for: dateProvider())

                let hasRecentCode: Bool = {
                    guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: todayStart)
                    else { return false }

                    let latestCreatedAt = localEuCommunications
                        .compactMap(\.euAccessCode)
                        .filter { $0.countryCode == countryCode }
                        .compactMap(\.createdAt)
                        .max()

                    return latestCreatedAt.map { date in
                        date >= sevenDaysAgo
                    } ?? false
                }()

                var updatedEuCommunications: [EuCommunication] = []
                if hasRecentCode {
                    updatedEuCommunications.append(
                        EuCommunication(
                            eventType: .refreshedAccessCode,
                            orderId: localEuCommunications.first?.orderId ?? UUID().uuidString,
                            euAccessCode: grantedEuAccessCode,
                            countryCode: countryCode
                        )
                    )
                } else {
                    updatedEuCommunications.append(
                        EuCommunication(
                            eventType: .createdAccessCode,
                            orderId: UUID().uuidString,
                            euAccessCode: grantedEuAccessCode,
                            countryCode: countryCode
                        )
                    )
                }

                // we can only have one active euAccessCode and invalidate this one
                if var latest = try await erxTaskRepository.loadLatestActiveEuCommunication(profileId: profileId) {
                    latest.euAccessCode = nil
                    updatedEuCommunications.append(latest)
                }

                try await erxTaskRepository.saveEuCommunication(
                    euCommunications: updatedEuCommunications,
                    profileId: profileId
                )

                return grantedEuAccessCode
            } catch {
                throw EuRedeemServiceError.from(error)
            }
        case .success(false):
            throw EuRedeemServiceError.noTokenAvailable
        case let .failure(error):
            throw EuRedeemServiceError.loginHandler(error: error)
        }
    } markTaskEURedeemable: { taskId, byPatientAuthorization, profileId in
        do {
            @Dependency(\.erxTaskRepository) var erxTaskRepository
            _ = try await erxTaskRepository.markTaskEURedeemable(
                taskId: taskId,
                profileId: profileId,
                byPatientAuthorization: byPatientAuthorization
            )
            // Only add EuCommunication when we already have an active EuAccessCode
            if var latest = try await erxTaskRepository.loadLatestActiveEuCommunication(profileId: profileId) {
                @Dependency(\.date.now) var now
                let newCommunication = EuCommunication(
                    eventType: byPatientAuthorization ? .addedTask : .removedTask,
                    taskId: taskId,
                    orderId: latest.orderId,
                    timestamp: now,
                    countryCode: latest.countryCode
                )
                try await erxTaskRepository.saveEuCommunication(euCommunications: [newCommunication],
                                                                profileId: profileId)
            }
            return
        } catch {
            throw EuRedeemServiceError.from(error)
        }
    } deleteEuAccessCode: { profileId in
        do {
            @Dependency(\.erxTaskRepository) var erxTaskRepository
            try await erxTaskRepository.deleteEuAccessCode(profileId: profileId)
            if var latest = try await erxTaskRepository.loadLatestActiveEuCommunication(profileId: profileId) {
                latest.eventType = .deletedAccessCode(
                    origin: latest.eventType == .createdAccessCode ? .created : .refreshed
                )
                latest.euAccessCode?.accessCode = nil
                latest.euAccessCode?.validUntil = nil

                try await erxTaskRepository.saveEuCommunication(euCommunications: [latest], profileId: profileId)
            }
        } catch {
            throw EuRedeemServiceError.from(error)
        }
    }
}

struct OrdersRepositoryDependency: DependencyKey {
    static let liveValue: OrdersRepository? = nil

    static var previewValue: OrdersRepository? = DummyOrdersRepository()

    static var testValue: OrdersRepository? = UnimplementedOrdersRepository()
}

extension DependencyValues {
    var ordersRepository: OrdersRepository {
        get { self[OrdersRepositoryDependency.self] ?? changeableUserSessionContainer.userSession.ordersRepository }
        set { self[OrdersRepositoryDependency.self] = newValue }
    }
}

struct InternalCommunicationProtocolDependency: DependencyKey {
    static let liveValue: InternalCommunicationProtocol = {
        @Dependency(\.userDataStore) var userDataStore
        @Dependency(\.internalCommunicationsRepository) var internalCommunicationsRepository
        return DefaultInternalCommunication(userDataStore: userDataStore,
                                            internalCommunicationsRepository: internalCommunicationsRepository)
    }()

    static var previewValue: InternalCommunicationProtocol = DummyInternalCommunicationProtocol()

    static var testValue: InternalCommunicationProtocol = UnimplementedInternalCommunicationProtocol()
}

extension DependencyValues {
    var internalCommunicationProtocol: InternalCommunicationProtocol {
        get { self[InternalCommunicationProtocolDependency.self] }
        set { self[InternalCommunicationProtocolDependency.self] = newValue }
    }
}

struct ShipmentInfoDataStoreDependency: DependencyKey {
    static let liveValue: ShipmentInfoDataStore? = nil
    static let previewValue: ShipmentInfoDataStore? = DemoShipmentInfoStore()
    static let testValue: ShipmentInfoDataStore? = nil // to-do
}

extension DependencyValues {
    var shipmentInfoDataStore: ShipmentInfoDataStore {
        get {
            self[ShipmentInfoDataStoreDependency.self] ?? changeableUserSessionContainer.userSession
                .shipmentInfoDataStore
        }
        set { self[ShipmentInfoDataStoreDependency.self] = newValue }
    }
}

// MARK: TCA Dependency eRpLocalStorage

import eRpLocalStorage

struct MedicationScheduleStoreDependency: DependencyKey {
    static let liveValue: MedicationScheduleStore = {
        @Dependency(\.coreDataControllerFactory) var coreDataControllerFactory
        return MedicationScheduleCoreDataStore(coreDataControllerFactory: coreDataControllerFactory)
    }()

    static let previewValue: MedicationScheduleStore = UnimplementedMedicationScheduleStore()

    static let testValue: MedicationScheduleStore = UnimplementedMedicationScheduleStore()
}

extension DependencyValues {
    var medicationScheduleStore: MedicationScheduleStore {
        get { self[MedicationScheduleStoreDependency.self] }
        set { self[MedicationScheduleStoreDependency.self] = newValue }
    }
}

struct UserDataStoreDependency: DependencyKey {
    static let liveValue: UserDataStore = UserDefaultsStore(userDefaults: .standard)

    static let previewValue: UserDataStore = DummySessionContainer().localUserStore

    static let testValue: UserDataStore = UnimplementedUserDataStore()
}

extension DependencyValues {
    var userDataStore: UserDataStore {
        get { self[UserDataStoreDependency.self] }
        set { self[UserDataStoreDependency.self] = newValue }
    }
}

struct ModelMigratingDependency: DependencyKey {
    static var liveValue: ModelMigrating = {
        let coreDataFactory = CoreDataControllerFactory.liveValue
        return MigrationManager(
            factory: coreDataFactory,
            erxTaskCoreDataStore: DefaultErxTaskCoreDataStore(
                coreDataControllerFactory: coreDataFactory
            ),
            userDataStore: UserDataStoreDependency.liveValue
        )
    }()

    static let previewValue: ModelMigrating = MigrationManager.failing

    static let testValue: ModelMigrating = UnimplementedModelMigrating()
}

extension DependencyValues {
    var migrationManager: ModelMigrating {
        get { self[ModelMigratingDependency.self] }
        set { self[ModelMigratingDependency.self] = newValue }
    }
}

extension NFCSignatureProvider: DependencyKey {
    /// Note: Virtual EGK implementation and demo mode check could be added here in the future
    public static let liveValue = NFCSignatureProvider { can, pin, challenge, profileID in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return await Self.demoMode.sign(can: can, pin: pin, challenge: challenge, profileId: profileID)
        }

        @Shared(.isVirtualEGKEnabled) var isVirtualEGK
        if isVirtualEGK {
            return await Self.virtualEGK.sign(can: can, pin: pin, challenge: challenge, profileId: profileID)
        }

        return await Self.defaultImplementation.sign(can: can, pin: pin, challenge: challenge, profileId: profileID)
    } signForBiometrics: { can, pin, challenge, registerDataProvider, pairingSession, profileID in
        @Shared(.isDemoMode) var isDemoMode
        if isDemoMode {
            return await Self.demoMode.signForBiometrics(
                can: can,
                pin: pin,
                challenge: challenge,
                registerDataProvider: registerDataProvider,
                pairingSession: pairingSession,
                profileId: profileID
            )
        }

        @Shared(.isVirtualEGKEnabled) var isVirtualEGK
        if isVirtualEGK {
            return await Self.virtualEGK.signForBiometrics(
                can: can,
                pin: pin,
                challenge: challenge,
                registerDataProvider: registerDataProvider,
                pairingSession: pairingSession,
                profileId: profileID
            )
        }

        return await Self.defaultImplementation.signForBiometrics(
            can: can,
            pin: pin,
            challenge: challenge,
            registerDataProvider: registerDataProvider,
            pairingSession: pairingSession,
            profileId: profileID
        )
    }
}

extension ProfileCoreDataStore: DependencyKey {
    public static let liveValue = ProfileCoreDataStore(
        coreDataControllerFactory: CoreDataControllerFactory.liveValue
    )

    // should be unimplemented
    // public static let previewValue: ProfileCoreDataStore
}

extension DependencyValues {
    var profileCoreDataStore: ProfileCoreDataStore {
        get { self[ProfileCoreDataStore.self] }
        set { self[ProfileCoreDataStore.self] = newValue }
    }
}

struct ProfileDataStoreDependency: DependencyKey {
    static let initialValue: ProfileDataStore = ProfileCoreDataStore.liveValue

    static let liveValue: ProfileDataStore? = nil

    static let previewValue: ProfileDataStore? = DemoProfileDataStore()

    static let testValue: ProfileDataStore? = UnimplementedProfileDataStore()
}

extension DependencyValues {
    var profileDataStore: ProfileDataStore {
        get { self[ProfileDataStoreDependency.self] ?? changeableUserSessionContainer.userSession.profileDataStore }
        set { self[ProfileDataStoreDependency.self] = newValue }
    }
}

// MARK: TCA Dependency IDP

struct IDPSessionDependency: DependencyKey {
    static let liveValue: IDPSession? = nil

    static let previewValue: IDPSession? = DemoIDPSession(storage: MemoryStorage())

    static let testValue: IDPSession? = UnimplementedIDPSession()
}

extension DependencyValues {
    var idpSession: IDPSession {
        get { self[IDPSessionDependency.self] ?? changeableUserSessionContainer.userSession.idpSession }
        set { self[IDPSessionDependency.self] = newValue }
    }
}

@DependencyClient
struct SecureEnclaveSignatureProviderFactory {
    let construct: (_ profileId: UUID) -> SecureEnclaveSignatureProvider
}

extension SecureEnclaveSignatureProviderFactory: DependencyKey {
    static let liveValue = SecureEnclaveSignatureProviderFactory { profileId in
        @Shared(.isDemoMode) var isDemoMode

        if isDemoMode {
            return DummySecureEnclaveSignatureProvider()
        }

        @Dependency(\.schedulers) var schedulers
        let secureUserStore = KeychainStorage(
            profileId: profileId,
            schedulers: schedulers
        )
        #if ENABLE_DEBUG_VIEW && targetEnvironment(simulator)
        return DefaultSecureEnclaveSignatureProvider(
            storage: secureUserStore,
            keyIdentifierGenerator: { try generateSecureRandom(length: 32) },
            privateKeyContainerProvider: { try PrivateKeyContainer.createFromKeyChain(with: $0) }
        )
        #else
        return DefaultSecureEnclaveSignatureProvider(
            storage: secureUserStore
        )
        #endif
    }

    static let previewValue = SecureEnclaveSignatureProviderFactory { _ in
        DummySecureEnclaveSignatureProvider()
    }
}

extension DependencyValues {
    var secureEnclaveSignatureProviderFactory: SecureEnclaveSignatureProviderFactory {
        get { self[SecureEnclaveSignatureProviderFactory.self] }
        set { self[SecureEnclaveSignatureProviderFactory.self] = newValue }
    }
}

struct ExtAuthRequestStorageDependency: DependencyKey {
    static var liveValue: ExtAuthRequestStorage?

    static var previewValue: ExtAuthRequestStorage? = DummyExtAuthRequestStorage()

    static var testValue: ExtAuthRequestStorage? = UnimplementedExtAuthRequestStorage()
}

extension DependencyValues {
    var extAuthRequestStorage: ExtAuthRequestStorage {
        get {
            self[ExtAuthRequestStorageDependency.self] ?? changeableUserSessionContainer.userSession
                .extAuthRequestStorage
        }
        set { self[ExtAuthRequestStorageDependency.self] = newValue }
    }
}

// MARK: Pharmacy

import HTTPClient
import HTTPClientLive
import Pharmacy

extension PharmacyRepository: DependencyKey {
    public static let liveValue: PharmacyRepository = Self(
        updateFromRemote: { telematikId in
            do {
                @Dependency(\.coreDataControllerFactory) var coreDataControllerFactory
                let disk = PharmacyCoreDataStore(coreDataControllerFactory: coreDataControllerFactory)
                @Dependency(\.pharmacyRemoteDataStore) var cloud
                // Fetch the remote pharmacy asynchronously
                guard let remotePharmacy = try await cloud.fetchPharmacy(telematikId) else {
                    throw PharmacyRepositoryError.remote(.notFound)
                }

                // Update local disk store asynchronously
                let pharmacyInStore = try await disk
                    .update(telematikId: telematikId) { pharmacyInStore in
                        pharmacyInStore.name = remotePharmacy.name
                        pharmacyInStore.telecom = remotePharmacy.telecom
                        pharmacyInStore.position = remotePharmacy.position
                        pharmacyInStore.address = remotePharmacy.address
                        pharmacyInStore.id = remotePharmacy.id
                    }
                    .async()

                // Merge additional remote properties
                var updated = pharmacyInStore
                updated.types = remotePharmacy.types
                updated.status = remotePharmacy.status
                updated.hoursOfOperation = remotePharmacy.hoursOfOperation
                updated.physicalFeatures = remotePharmacy.physicalFeatures
                updated.specialities = remotePharmacy.specialities
                updated.emergencyServiceHours = remotePharmacy.emergencyServiceHours
                updated.specialClosingHours = remotePharmacy.specialClosingHours

                return updated

            } catch let error as PharmacyRemoteStoreError {
                throw PharmacyRepositoryError.remote(error)
            } catch let error as LocalStoreError {
                throw PharmacyRepositoryError.local(error)
            }
        },
        loadCached: { telematikId in
            do {
                @Dependency(\.coreDataControllerFactory) var coreDataControllerFactory
                let disk = PharmacyCoreDataStore(coreDataControllerFactory: coreDataControllerFactory)
                let localPharmacy = try await disk.fetchPharmacy(by: telematikId).first().async()

                if let pharmacy = localPharmacy {
                    return pharmacy
                } else {
                    @Dependency(\.pharmacyRemoteDataStore) var cloud
                    let remotePharmacy = try await cloud.fetchPharmacy(telematikId)
                    guard let pharmacy = remotePharmacy else { return nil }
                    _ = try await disk.save(pharmacies: [pharmacy]).async()
                    return pharmacy
                }
            } catch let error as LocalStoreError {
                throw PharmacyRepositoryError.local(error)
            }
        },
        searchRemote: { searchTerm, position, filter in
            do {
                @Dependency(\.coreDataControllerFactory) var coreDataControllerFactory
                let disk = PharmacyCoreDataStore(coreDataControllerFactory: coreDataControllerFactory)
                @Dependency(\.pharmacyRemoteDataStore) var cloud
                let remotePharmacies = try await cloud.searchPharmacies(searchTerm, position, filter)

                let localPharmacies = try await disk.listPharmacies(count: nil).async()

                let merged = remotePharmacies.map { remote in
                    var copy = remote
                    if let local = localPharmacies.first(where: { $0.telematikID == remote.telematikID }) {
                        copy.updateLocalStoredProperties(with: local)
                    }
                    return copy
                }

                if filter.contains(.delivery) {
                    return merged.filter(\.hasDeliveryService)
                }

                return merged
            } catch let error as PharmacyRemoteStoreError {
                throw PharmacyRepositoryError.remote(error)
            } catch let error as LocalStoreError {
                throw PharmacyRepositoryError.local(error)
            }
        },
        loadLocalById: { telematikId in
            do {
                @Dependency(\.coreDataControllerFactory) var coreDataControllerFactory
                let disk = PharmacyCoreDataStore(coreDataControllerFactory: coreDataControllerFactory)
                return try await disk.fetchPharmacy(by: telematikId).async()
            } catch let error as LocalStoreError {
                throw PharmacyRepositoryError.local(error)
            }
        },
        loadLocalCount: { count in
            do {
                @Dependency(\.coreDataControllerFactory) var coreDataControllerFactory
                let disk = PharmacyCoreDataStore(coreDataControllerFactory: coreDataControllerFactory)
                return try await disk.listPharmacies(count: count)
                    // For now this method is called by PharmacySearchDomain only for populating the overview
                    // Here we only want to show pharmacies that
                    //  - have been "used" at least once before and/or
                    //  - are currently marked as favourite
                    .map { (pharmacyLocations: [PharmacyLocation]) -> [PharmacyLocation] in
                        pharmacyLocations.filter { $0.isFavorite || $0.lastUsed != nil }
                    }
                    .async()
            } catch let error as LocalStoreError {
                throw PharmacyRepositoryError.local(error)
            }
        },
        saveMultiple: { pharmacies in
            do {
                @Dependency(\.coreDataControllerFactory) var coreDataControllerFactory
                let disk = PharmacyCoreDataStore(coreDataControllerFactory: coreDataControllerFactory)
                return try await disk.save(pharmacies: pharmacies).async()
            } catch let error as LocalStoreError {
                throw PharmacyRepositoryError.local(error)
            }
        },
        deleteMultiple: { pharmacies in
            do {
                @Dependency(\.coreDataControllerFactory) var coreDataControllerFactory
                let disk = PharmacyCoreDataStore(coreDataControllerFactory: coreDataControllerFactory)
                return try await disk.delete(pharmacies: pharmacies).async()
            } catch let error as LocalStoreError {
                throw PharmacyRepositoryError.local(error)
            }
        },
        fetchInsurance: { ikNumber in
            do {
                @Dependency(\.pharmacyRemoteDataStore) var cloud
                return try await cloud.fetchInsurance(ikNumber)
            } catch let error as PharmacyRemoteStoreError {
                throw PharmacyRepositoryError.remote(error)
            }
        },
        fetchAllInsurances: {
            do {
                @Dependency(\.pharmacyRemoteDataStore) var cloud
                return try await cloud.fetchAllInsurances()
            } catch let error as PharmacyRemoteStoreError {
                throw PharmacyRepositoryError.remote(error)
            }
        }, fetchEuCountries: {
            do {
                @Dependency(\.pharmacyRemoteDataStore) var cloud
                return try await cloud.fetchEuCountries()
            } catch let error as PharmacyRemoteStoreError {
                throw PharmacyRepositoryError.remote(error)
            }
        }
    )
}

extension PharmacyRemoteDataStore: DependencyKey {
    public static let liveValue: PharmacyRemoteDataStore = Self { searchTerm, position, filter in
        @Dependency(\.fhirClientServiceFactory) var fhirClient
        @Dependency(\.fhirVZDSession) var fhirVZDSession
        let token = try await fhirVZDSession.autoRefreshedToken().accessToken

        let remoteFilter: [PharmacyRemoteDataStoreFilter]
        if position != nil {
            remoteFilter = Self.apiFiltersForNearbySearch(filter: filter)
        } else {
            remoteFilter = Self.apiFiltersForNormalSearch(filter: filter)
        }

        return try await fhirClient.client()
            .searchPharmacies(by: searchTerm, position: position, filter: remoteFilter, accessToken: token)
            .async()
    } fetchPharmacy: { telematikId in
        @Dependency(\.fhirClientServiceFactory) var fhirClient
        @Dependency(\.fhirVZDSession) var fhirVZDSession
        let token = try await fhirVZDSession.autoRefreshedToken().accessToken
        return try await fhirClient.client().fetchPharmacy(by: telematikId, accessToken: token).async()
    } fetchInsurance: { ikNumber in
        @Dependency(\.fhirClientServiceFactory) var fhirClient
        @Dependency(\.fhirVZDSession) var fhirVZDSession
        let token = try await fhirVZDSession.autoRefreshedToken().accessToken
        return try await fhirClient.client().fetchInsurance(by: ikNumber, accessToken: token).async()
    } fetchAllInsurances: {
        @Dependency(\.fhirClientServiceFactory) var fhirClient
        @Dependency(\.fhirVZDSession) var fhirVZDSession
        let token = try await fhirVZDSession.autoRefreshedToken().accessToken
        return try await fhirClient.client().fetchAllInsurances(accessToken: token).async()
    } fetchEuCountries: {
        @Dependency(\.fhirClientServiceFactory) var fhirClient
        @Dependency(\.fhirVZDSession) var fhirVZDSession
        let token = try await fhirVZDSession.autoRefreshedToken().accessToken
        return try await fhirClient.client().fetchEuCountries(accessToken: token).async()
    }
}

extension PharmacyRemoteDataStore {
    static func apiFiltersForNearbySearch(filter: [PharmacyRepositoryFilter])
        -> [PharmacyRemoteDataStoreFilter] {
        var result: [PharmacyRemoteDataStoreFilter] = []

        let filterTexts: [String] = filter.compactMap {
            switch $0 {
            case .ready:
                return nil
            case .shipment:
                return "Versand"
            case .delivery:
                return "Botendienst"
            case .pickup:
                return "Handverkauf"
            case let .characteristic(value):
                return nearbySearchText(for: value)
            case let .specialty(value):
                return nearbySearchText(for: value)
            }
        }
        if !filterTexts.isEmpty {
            result.append(PharmacyRemoteDataStoreFilter(key: "text", value: filterTexts.joined(separator: " ")))
        }

        return result
    }

    /// Maps characteristic codes to their German keyword for the `text` search parameter
    /// in the `nearPharmacy` operation, which does not support the `characteristic` query parameter.
    private static func nearbySearchText(for characteristic: PharmacyRepositoryFilter.Characteristic) -> String {
        switch characteristic {
        case .parking: return "Parkmöglichkeit"
        case .publicTransport: return "ÖPNV"
        case .barrierFree: return "Barrierefrei"
        case .pickupAutomat: return "Abholautomat"
        }
    }

    /// Maps specialty codes to their main German keyword for the `text` search parameter
    /// in the `nearPharmacy` operation, which does not support the `specialty` query parameter.
    private static func nearbySearchText(for specialty: PharmacyRepositoryFilter.Specialty) -> String {
        switch specialty {
        case .sterileCompounding: return "Sterilherstellung"
        case .hypertension: return "Bluthochdruck"
        case .inhalationTechnique: return "Inhalationstechnik"
        case .polymedication: return "Polymedikation"
        case .oralCancerTherapy: return "Krebstherapie"
        case .organTransplantation: return "Organtransplantation"
        case .vaccination: return "Impfung"
        case .bodyMeasurements: return "Körperwerte"
        case .allergyTest: return "Allergietest"
        case .travelMedicineConsultation: return "Reisemedizin"
        }
    }

    static func apiFiltersForNormalSearch(filter: [PharmacyRepositoryFilter])
        -> [PharmacyRemoteDataStoreFilter] {
        var result: [PharmacyRemoteDataStoreFilter] = filter.compactMap {
            switch $0 {
            case .ready, .characteristic, .specialty:
                return nil
            case .shipment:
                return PharmacyRemoteDataStoreFilter(key: "specialty", value: Specialty.shipment.rawValue)
            case .delivery:
                return PharmacyRemoteDataStoreFilter(key: "specialty", value: Specialty.delivery.rawValue)
            case .pickup:
                return PharmacyRemoteDataStoreFilter(key: "specialty", value: Specialty.pickup.rawValue)
            }
        }

        result.append(contentsOf: characteristicFilters(from: filter))
        result.append(contentsOf: specialtyFilters(from: filter))

        return result
    }

    /// Collects all `.characteristic` filter values into individual `characteristic` query parameters.
    /// Repeating the same FHIR search parameter produces AND semantics.
    private static func characteristicFilters(from filter: [PharmacyRepositoryFilter])
        -> [PharmacyRemoteDataStoreFilter] {
        filter.compactMap {
            guard case let .characteristic(value) = $0 else { return nil }
            return PharmacyRemoteDataStoreFilter(key: "characteristic", value: value.rawValue)
        }
    }

    /// Collects all `.specialty` filter values into individual `specialty` query parameters.
    /// Repeating the same FHIR search parameter produces AND semantics.
    private static func specialtyFilters(from filter: [PharmacyRepositoryFilter])
        -> [PharmacyRemoteDataStoreFilter] {
        filter.compactMap {
            guard case let .specialty(value) = $0 else { return nil }
            return PharmacyRemoteDataStoreFilter(key: "specialty", value: value.rawValue)
        }
    }
}

import FHIRVZD

extension FHIRVZDSession: DependencyKey {
    public static let liveValue: FHIRVZDSession = .init {
        @Dependency(\.fhirVZDClient) var client
        @Dependency(\.date.now) var now
        @Shared(.fhirVZDToken) var token
        @Dependency(\.userDataStore.appConfiguration) var appConfiguration

        let config = FHIRVZDClient.Configuration(
            eRezeptAPIServer: appConfiguration.eRezept,
            eRezeptAdditionalHeader: appConfiguration.eRezeptAdditionalHeader
        )
        // Return stored token if still valid (more than 15 min)
        if let token, token.expires >= now.addingTimeInterval(-60 * 15) {
            return token
        }
        // Otherwise refresh and store new token
        let newToken = try await client.refresh(config)
        $token.withLock { $0 = newToken }
        return newToken
    }

    public static let testValue = FHIRVZDSession()
}

extension DependencyValues {
    var fhirVZDSession: FHIRVZDSession {
        get { self[FHIRVZDSession.self] }
        set { self[FHIRVZDSession.self] = newValue }
    }
}

// MARK: BfArM

import BfArM

extension BfArMSession: DependencyKey {
    public static let liveValue: BfArMSession = .init { pzn in
        @Dependency(\.bfarmClient) var client
        @Dependency(\.userDataStore.appConfiguration) var appConfiguration

        let config = BfArMClient.Configuration(
            eRezeptAPIServer: appConfiguration.eRezept,
            eRezeptAdditionalHeader: appConfiguration.eRezeptAdditionalHeader
        )

        return try await client.bfarmInfo(pzn, config)
    } fetchCachedImage: { url in
        @Dependency(\.bfarmClient) var client
        @Dependency(\.userDataStore.appConfiguration) var appConfiguration

        let config = BfArMClient.Configuration(
            eRezeptAPIServer: appConfiguration.eRezept,
            eRezeptAdditionalHeader: appConfiguration.eRezeptAdditionalHeader
        )

        return try await client.fetchCachedImage(url, config)
    }

    public static let testValue = BfArMSession()
}

extension DependencyValues {
    var bfArMSession: BfArMSession {
        get { self[BfArMSession.self] }
        set { self[BfArMSession.self] = newValue }
    }
}

// MARK: factories

struct LoginHandlerServiceFactory {
    let construct: (_ idpSession: IDPSession, _ signatureProvider: SecureEnclaveSignatureProvider) -> LoginHandler

    init(construct: @escaping (_ idpSession: IDPSession, _ signatureProvider: SecureEnclaveSignatureProvider)
        -> LoginHandler) {
        self.construct = construct
    }
}

extension LoginHandlerServiceFactory: DependencyKey {
    static var liveValue = LoginHandlerServiceFactory(construct: DefaultLoginHandler.init)
}

extension DependencyValues {
    var loginHandlerServiceFactory: LoginHandlerServiceFactory {
        get { self[LoginHandlerServiceFactory.self] }
        set { self[LoginHandlerServiceFactory.self] = newValue }
    }
}

@DependencyClient
struct ErxTaskCoreDataStoreFactory {
    var construct: (CoreDataControllerFactory) -> ErxLocalDataStore = { _ in { fatalError("Not Implemented") }() }
}

extension ErxTaskCoreDataStoreFactory: DependencyKey {
    static var liveValue = ErxTaskCoreDataStoreFactory(construct: DefaultErxTaskCoreDataStore.init)
}

extension DependencyValues {
    var erxTaskCoreDataStoreFactory: ErxTaskCoreDataStoreFactory {
        get { self[ErxTaskCoreDataStoreFactory.self] }
        set { self[ErxTaskCoreDataStoreFactory.self] = newValue }
    }
}

struct ErxLocalDataStoreDependency: DependencyKey {
    static let liveValue: ErxLocalDataStore = {
        @Dependency(\.coreDataControllerFactory) var coreDataControllerFactory

        return DefaultErxTaskCoreDataStore(coreDataControllerFactory: coreDataControllerFactory)
    }()
}

extension DependencyValues {
    var erxLocalDataStore: ErxLocalDataStore {
        get { self[ErxLocalDataStoreDependency.self] }
        set { self[ErxLocalDataStoreDependency.self] = newValue }
    }
}

import eRpRemoteStorage
import FHIRClient

struct ErxRemoteDataStoreDependencyKey: DependencyKey {
    static var liveValue: ErxRemoteDataStore = {
        @Dependency(\.fhirClientServiceFactory) var fhirClientServiceFactory

        return ErxTaskFHIRDataStore { profileId in
            fhirClientServiceFactory.erpClientForProfile(profileId)
        }
    }()
}

extension DependencyValues {
    var erxRemoteDataStore: ErxRemoteDataStore {
        get { self[ErxRemoteDataStoreDependencyKey.self] }
        set { self[ErxRemoteDataStoreDependencyKey.self] = newValue }
    }
}

import FeatureCommunication

extension InternalCommunicationClient: DependencyKey {
    public static var liveValue: InternalCommunicationClient = {
        @Dependency(\.userDataStore) var userDataStore

        return Self.live(userDataStore: userDataStore)
    }()
}

// swiftlint:enable file_length
