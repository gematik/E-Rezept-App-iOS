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
import ComposableArchitecture
import ConsentService
import eRpKit
import eRpResources
import ErxTaskRepository
import FeatureHelpers
import Foundation

extension MainDomain {
    struct Environment {
        let router: Routing
        var userSessionContainer: UsersSessionContainer
        var userSession: UserSession
        var erxTaskRepository: ErxTaskRepository
        var schedulers: Schedulers
        var fhirDateFormatter: FHIRDateFormatter
        var userDataStore: UserDataStore
        var deviceSecurityManager: DeviceSecurityManager
        var profileSecureDataWiper: ProfileSecureDataWiper
        var profileDataStore: ProfileDataStore
        var consentService: ConsentService

        func checkForTaskDuplicatesThenSave(_ sharedTasks: [SharedTask],
                                            profileId: UUID?) -> Effect<MainDomain.Action> {
            let authoredOn = fhirDateFormatter.stringWithLongUTCTimeZone(from: Date())
            let erxTaskRepository = self.erxTaskRepository

            return .run { [profileId] send in
                do {
                    let tasks = try await checkForTaskDuplicatesInStore(sharedTasks)
                    let erxTasks = tasks.asErxTasks(
                        status: .ready,
                        with: authoredOn,
                        author: L10n.scnTxtAuthor.text
                    ) { L10n.scnTxtMedication($0).text }

                    try await erxTaskRepository.saveTask(erxTasks, profileId)
                    await send(.response(.importReceived(.success(erxTasks))))
                } catch let error as Error {
                    await send(.response(.importReceived(.failure(error))))
                }
            }
        }

        func checkForTaskDuplicatesInStore(_ sharedTasks: [SharedTask]) async throws -> [SharedTask] {
            var deduplicatedTasks = [SharedTask]()
            for task in sharedTasks {
                do {
                    let localTask = try await erxTaskRepository.loadLocalTask(task.id, task.accessCode).async()
                    if localTask == nil {
                        deduplicatedTasks.append(task)
                    }
                } catch let error as ErxRepositoryError {
                    throw MainDomain.Error.repositoryError(error)
                }
            }

            if deduplicatedTasks.isEmpty {
                throw MainDomain.Error.importDuplicate
            } else {
                return deduplicatedTasks
            }
        }

        func setHideWelcomeDrawerOnMainViewToTrue() async throws -> Bool {
            let profileId = userSession.profileId
            return try await profileDataStore.update(profileId: profileId) {
                $0.hideWelcomeDrawerOnMainView = true
            }
            .async(\MainDomain.Error.Cases.localStoreError)
        }

        func setHidePkvConsentDrawerOnMainViewToTrue() async throws -> Bool {
            let profileId = userSession.profileId
            return try await profileDataStore.update(profileId: profileId) {
                $0.hidePkvConsentDrawerOnMainView = true
            }
            .async(\MainDomain.Error.Cases.localStoreError)
        }
    }
}
