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
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import Nimble
import XCTest

@MainActor
final class MedicationReminderListDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<MedicationReminderListDomain>

    let mainQueue = DispatchQueue.immediate
    var mockUserProfileService: MockUserProfileService!

    override func setUp() {
        super.setUp()
        mockUserProfileService = MockUserProfileService()
    }

    func testLoadMedicationSchedule() async {
        let sut = TestStore(initialState: .init()) {
            MedicationReminderListDomain()
        } withDependencies: { dependencies in
            dependencies.medicationScheduleRepository.read = { _ in
                MedicationReminderListDomainTests.FixturesB.medicationSchedule1
            }
            dependencies.schedulers = Schedulers(uiScheduler: mainQueue.eraseToAnyScheduler())
            dependencies.userProfileService = mockUserProfileService
        }
        await sut.send(.loadProfileMedicationReminder([MedicationReminderListDomainTests.FixturesB.profileErxTask]))

        await sut.receive(.profileMedicationReminderReceived(
            [MedicationReminderListDomainTests.FixturesB.medicationSchedule1],
            MedicationReminderListDomainTests.FixturesB.profileErxTask
        )) { state in
            state.profileMedicationReminder = [MedicationReminderListDomain.ProfileMedicationReminder(
                profile: MedicationReminderListDomainTests.FixturesB.profileErxTask,
                medicationProfileReminderList: [MedicationReminderListDomainTests.FixturesB.medicationSchedule1]
            )]
        }
    }

    func testLoadingMedicationScheduleFailure() async {
        let sut = TestStore(initialState: .init()) {
            MedicationReminderListDomain()
        } withDependencies: { dependencies in
            dependencies.medicationScheduleRepository.read = { _ in
                MedicationReminderListDomainTests.FixturesB.medicationSchedule1
            }
            dependencies.schedulers = Schedulers(uiScheduler: mainQueue.eraseToAnyScheduler())
            dependencies.userProfileService = mockUserProfileService
        }

        let error = MedicationReminderListDomain.Error.generic("Failed to load")

        await sut.send(.profileMedicationReminderFailed(error)) { state in
            state.destination = .alert(
                .init(for: error, actions: {
                    ButtonState(role: .cancel, action: .dismiss) {
                        TextState(L10n.alertBtnOk)
                    }
                })
            )
        }
    }

    func testSelectedMedicationSchedule() async {
        let sut = TestStore(initialState: .init()) {
            MedicationReminderListDomain()
        } withDependencies: { dependencies in
            dependencies.medicationScheduleRepository.read = { _ in
                MedicationReminderListDomainTests.FixturesB.medicationSchedule1
            }
            dependencies.schedulers = Schedulers(uiScheduler: mainQueue.eraseToAnyScheduler())
            dependencies.userProfileService = mockUserProfileService
        }

        await sut
            .send(.selectMedicationReminder(MedicationReminderListDomainTests.FixturesB.medicationSchedule1)) { state in
                state.destination = .medicationReminder(.init(
                    medicationSchedule: MedicationReminderListDomainTests.FixturesB.medicationSchedule1
                ))
            }
    }

    func testLoadProfiles() async {
        let sut = TestStore(initialState: .init()) {
            MedicationReminderListDomain()
        } withDependencies: { dependencies in
            dependencies.medicationScheduleRepository.read = { _ in
                MedicationReminderListDomainTests.FixturesB.medicationSchedule1
            }
            dependencies.schedulers = Schedulers(uiScheduler: mainQueue.eraseToAnyScheduler())
            dependencies.userProfileService = mockUserProfileService
        }
        let expectedProfiles = [
            UserProfile.Fixtures.theo,
            UserProfile.Fixtures.olafOffline,
        ]

        mockUserProfileService.userProfilesPublisherReturnValue = Just(expectedProfiles)
            .setFailureType(to: UserProfileServiceError.self)
            .eraseToAnyPublisher()

        await sut.send(.loadAllProfiles)

        await sut.receive(.loadReceived(.success(expectedProfiles)))

        await sut.receive(.loadProfileMedicationReminder(expectedProfiles))

        await sut.receive(.profileMedicationReminderReceived([], expectedProfiles.first!)) { state in
            state.profileMedicationReminder = [MedicationReminderListDomain.ProfileMedicationReminder(
                profile: expectedProfiles.first!,
                medicationProfileReminderList: []
            )]
        }

        await sut.receive(.profileMedicationReminderReceived([], expectedProfiles.last!)) { state in
            state.profileMedicationReminder = [MedicationReminderListDomain.ProfileMedicationReminder(
                profile: expectedProfiles.first!,
                medicationProfileReminderList: []
            ), MedicationReminderListDomain.ProfileMedicationReminder(
                profile: expectedProfiles.last!,
                medicationProfileReminderList: []
            )]
        }
    }

    func testLoadingProfileFailure() async {
        let sut = TestStore(initialState: .init()) {
            MedicationReminderListDomain()
        } withDependencies: { dependencies in
            dependencies.medicationScheduleRepository.read = { _ in
                MedicationReminderListDomainTests.FixturesB.medicationSchedule1
            }
            dependencies.schedulers = Schedulers(uiScheduler: mainQueue.eraseToAnyScheduler())
            dependencies.userProfileService = mockUserProfileService
        }
        let error = UserProfileServiceError.localStoreError(.notImplemented)

        await sut.send(.loadReceived(.failure(error))) { state in
            state.destination = .alert(
                .init(for: error, actions: {
                    ButtonState(role: .cancel, action: .dismiss) {
                        TextState(L10n.alertBtnOk)
                    }
                })
            )
        }
    }
}

extension MedicationReminderListDomainTests {
    enum FixturesB {
        static let medicationSchedule1 = MedicationSchedule(
            start: .now,
            end: .distantFuture,
            title: "Test Title",
            dosageInstructions: "Test instructions",
            taskId: "123.123.123",
            isActive: true,
            entries: .init()
        )

        static let profileErxTask = UserProfile(
            from: Profile(name: "OlafTest", erxTasks: [ErxTask.Fixtures.erxTask1]),
            isAuthenticated: false,
            activityIndicating: false
        )
    }
}
