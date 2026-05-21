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
import CombineSchedulers
import Dependencies
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import ErxTaskRepository
import FeatureHelpers
import Foundation
import IdentifiedCollections

// swiftlint:disable function_body_length

extension ErxTaskRepository {
    static func demoErxTaskRepository(
        requestDelayInSeconds: Double = 0.1,
        schedulers: Schedulers = Schedulers(),
        secureUserStore: SecureUserDataStore
    ) -> ErxTaskRepository {
        let store = ErxTaskStore()
        let currentValue: CurrentValueSubject<[ErxTask], ErxRepositoryError> = CurrentValueSubject([])
        let delay: Double = requestDelayInSeconds
        var uiScheduler: AnySchedulerOf<DispatchQueue> {
            schedulers.main
        }

        return ErxTaskRepository(
            loadRemoteTask: { taskId, _, _ in
                if let result = await store.first(where: { $0.id == taskId }) {
                    return result
                } else {
                    return nil
                }
            }, loadLocalTask: { taskId, _ in
                Future {
                    let result = await store.first { $0.id == taskId }
                    if let result {
                        return result
                    } else {
                        return nil
                    }
                }
                .setFailureType(to: ErxRepositoryError.self)
                .eraseToAnyPublisher()
            }, loadLocalAllTasks: { _ in
                currentValue
                    .first()
                    .delay(for: .seconds(delay), scheduler: uiScheduler)
                    .eraseToAnyPublisher()
            }, loadRemoteAllTasks: { _, _ in
                do {
                    let token = try await secureUserStore.token.async()
                    if token != nil {
                        await currentValue.send(store.nextChunkFromStore())
                    }
                    return try await currentValue
                        .delay(for: .seconds(delay), scheduler: uiScheduler, options: .none)
                        .async()
                } catch {
                    throw ErxRepositoryError.remote(RemoteStoreError.notImplemented)
                }
            }, saveTask: { erxTasks, _ in
                for task in erxTasks where await store.contains(task) {
                    await store.update(with: task)
                }
            }, deleteTask: { erxTasks, _ in
                for task in erxTasks where await store.contains(task) {
                    await store.update(with: task)
                }
            }, markTaskEURedeemable: { taskId, _, mark in
                guard var task = await store.first(where: { task in
                    task.id == taskId &&
                        task.isEURedeemable
                }) else { return }
                task.isSetEURedeemableByPatient = mark
                await store.update(with: task)
            }, redeem: { order in
                order
            }, loadLocalCommunications: { _ in
                ErxTask.Communication.Dummies.multipleCommunications1 +
                    ErxTask.Communication.Dummies.multipleCommunications2
            }, saveLocalCommunications: { _, _ in
            }, updateLocalDiGaInfo: { _ in
            }, countAllUnreadCommunicationsAndChargeItems: { _, _ in
                AsyncThrowingStream { continuation in
                    continuation.yield(0)
                    continuation.finish()
                }
            }, loadRemoteLatestAuditEvents: { _ in
                PagedContent(content: [], next: nil)
            }, loadRemoteAuditEvents: { _, _ in
                PagedContent(content: [], next: nil)
            }, loadRemoteChargeItems: { _ in
                []
            }, fetchConsents: { _ in
                []
            }, loadLocalChargeItem: { _, _ in
                nil
            }, loadLocalAllChargeItems: { _ in
                []
            }, saveChargeItems: { _, _ in
            }, deleteChargeItems: { _, _ in
            }, deleteLocalChargeItems: { _, _ in
            }, grantConsent: { consent, _ in
                consent
            }, revokeConsent: { _, _ in
            }, loadRemoteEuAccessCode: {
                nil
            }, grantEuAccessPermission: { _ in
                nil
            }, deleteEuAccessCode: { _ in
            }, saveEuCommunication: { _, _ in
            }, deleteEuCommunications: { _, _ in
            }, loadEuCommunications: { _, _ in
                []
            }, loadLatestActiveEuCommunication: { _ in
                nil
            }
        )
    }

    actor ErxTaskStore {
        private var store = IdentifiedArrayOf<ErxTask>(uniqueElements: ErxTask.Demo.erxTasks)
        private var demoDatesIterator = DemoDatesIterator()
        @Dependency(\.fhirDateFormatter) var fhirDateFormatter

        /// Demo data is loaded in iterations. With every refresh a next chunk is loaded.
        private struct DemoDatesIterator: IteratorProtocol {
            typealias Element = String
            var index = 0
            let demoDates: [String?] = [
                DemoDate.createDemoDate(.sixteenDaysBefore),
                DemoDate.createDemoDate(.dayBeforeYesterday),
                DemoDate.createDemoDate(.yesterday),
                DemoDate.createDemoDate(.today),
            ]

            mutating func next() -> String? {
                defer {
                    if index < demoDates.count - 1 {
                        index += 1
                    }
                }
                return demoDates[index]
            }
        }

        func nextChunkFromStore() -> [ErxTask] {
            let nextDemoDate = demoDatesIterator.next()

            return store.filter { erxTask in
                // convert date strings to real dates for comparison
                if let demoDateString = nextDemoDate,
                   let demoDate = fhirDateFormatter.date(from: demoDateString, format: .yearMonthDay),
                   let authoredOnString = erxTask.authoredOn,
                   let erxDate = fhirDateFormatter.date(from: authoredOnString, format: .yearMonthDay) {
                    let compareResult = Calendar.current.compare(demoDate, to: erxDate, toGranularity: .day)
                    return compareResult == .orderedSame || compareResult == .orderedDescending
                }
                return false
            }
        }

        func first(where predicate: (ErxTask) -> Bool) -> ErxTask? {
            store.first(where: predicate)
        }

        func contains(_ erxTask: ErxTask) -> Bool {
            store.contains(erxTask)
        }

        func update(with erxTask: ErxTask) {
            store.updateOrAppend(erxTask)
        }
    }
}

// swiftlint:enable function_body_length
