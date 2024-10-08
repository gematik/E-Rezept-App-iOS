//
//  Copyright (c) 2024 gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or – as soon they will be approved by
//  the European Commission - subsequent versions of the EUPL (the Licence);
//  You may not use this work except in compliance with the Licence.
//  You may obtain a copy of the Licence at:
//
//      https://joinup.ec.europa.eu/software/page/eupl
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the Licence for the specific language governing permissions and
//  limitations under the Licence.
//
//

import Combine
import CombineSchedulers
import ComposableArchitecture
import eRpKit
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
        var chargeItemConsentService: ChargeItemConsentService

        enum DrawerEvaluationResult {
            case welcomeDrawer
            case consentDrawer
            case none
        }

        func showDrawerEvaluation() async -> DrawerEvaluationResult {
            // show welcome drawer?
            if !userDataStore.hideWelcomeDrawer {
                return .welcomeDrawer
            }

            // show consent drawer?
            do {
                let profile = try await userSession.profile().async(/MainDomain.Error.localStoreError)
                if profile.insuranceType == .pKV,
                   profile.hidePkvConsentDrawerOnMainView == false,
                   // Only if the service responded successfully that the consent has not been granted yet
                   // (== .success(false)) we want to show the consent drawer. Otherwise we don't.
                   case .notGranted = try await chargeItemConsentService.checkForConsent(profile.id) {
                    return .consentDrawer
                }
            } catch {
                // fall-through in case of any error
            }

            return .none
        }

        func checkForTaskDuplicatesThenSave(_ sharedTasks: [SharedTask]) -> Effect<MainDomain.Action> {
            let authoredOn = fhirDateFormatter.stringWithLongUTCTimeZone(from: Date())
            let erxTaskRepository = self.erxTaskRepository

            return .publisher(
                checkForTaskDuplicatesInStore(sharedTasks)
                    .flatMap { tasks -> AnyPublisher<[ErxTask], MainDomain.Error> in
                        let erxTasks = tasks.asErxTasks(
                            status: .ready,
                            with: authoredOn,
                            author: L10n.scnTxtAuthor.text
                        ) { L10n.scnTxtMedication($0).text }

                        return erxTaskRepository.save(
                            erxTasks: erxTasks
                        )
                        .map { _ in erxTasks }
                        .mapError(MainDomain.Error.repositoryError)
                        .eraseToAnyPublisher()
                    }
                    .catchToPublisher()
                    .map { .response(.importReceived($0)) }
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
        }

        func checkForTaskDuplicatesInStore(_ sharedTasks: [SharedTask])
            -> AnyPublisher<[SharedTask], MainDomain.Error> {
            let findPublishers: [AnyPublisher<SharedTask?, Never>] = sharedTasks.map { sharedTask in
                self.erxTaskRepository.loadLocal(by: sharedTask.id, accessCode: sharedTask.accessCode)
                    .first()
                    .map { erxTask -> SharedTask? in
                        if erxTask != nil {
                            return nil // by returning nil we sort out previously stored tasks
                        } else {
                            return sharedTask
                        }
                    }
                    .catch { _ in Just(.none) }
                    .eraseToAnyPublisher()
            }

            return Publishers.MergeMany(findPublishers)
                .collect(findPublishers.count)
                .flatMap { optionalTasks -> AnyPublisher<[SharedTask], MainDomain.Error> in
                    let tasks = optionalTasks.compactMap { $0 }
                    if tasks.isEmpty {
                        return Fail(error: MainDomain.Error.importDuplicate)
                            .eraseToAnyPublisher()
                    } else {
                        return Just(tasks)
                            .setFailureType(to: MainDomain.Error.self)
                            .eraseToAnyPublisher()
                    }
                }
                .receive(on: schedulers.main)
                .eraseToAnyPublisher()
        }

        func setHidePkvConsentDrawerOnMainViewToTrue() async throws -> Bool {
            let profileId = userSession.profileId
            return try await profileDataStore.update(profileId: profileId) {
                $0.hidePkvConsentDrawerOnMainView = true
            }
            .async(/MainDomain.Error.localStoreError)
        }
    }
}
