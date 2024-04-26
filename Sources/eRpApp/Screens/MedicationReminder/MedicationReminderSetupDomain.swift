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
import DataKit
import eRpKit
import Foundation
import IDP
import UserNotifications

struct MedicationReminderSetupDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    // sourcery: CodedError = "036"
    enum Error: Swift.Error, Equatable {
        // sourcery: errorCode = "01"
        case generic(String)
    }

    struct State: Equatable {
        init(
            medicationSchedule: MedicationSchedule,
            destination: Destinations.State? = nil
        ) {
            self.destination = destination
            self.medicationSchedule = medicationSchedule
        }

        @PresentationState var destination: Destinations.State?

        @BindingState var medicationSchedule: MedicationSchedule

        @BindingState var focus: Field?

        enum Field: Hashable {
            case time(UUID)
            case dose(UUID)
        }
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = alert
            case alert(ErpAlertState<Action.Alert>)
            // sourcery: AnalyticsScreen = medicationReminder_repetitionDetails
            case repetitionDetails
            // sourcery: AnalyticsScreen = medicationReminder_dosageInstruction
            case dosageInstructionsInfo(DosageInstructionsState)
        }

        enum Action: Equatable {
            case alert(Alert)
            case repetitionDetails(None)
            case dosageInstructionsInfo(None)

            enum None: Equatable {}

            enum Alert {
                case authorization
                case dismiss
            }
        }

        var body: some ReducerProtocol<State, Action> {
            EmptyReducer()
        }

        struct DosageInstructionsState: Equatable {
            let title: String
            let description: String

            init(dosageInstructions: String?) {
                title = L10n.prscDtlTxtDosageInstructions.text

                guard let dosageInstructions = dosageInstructions, !dosageInstructions.isEmpty else {
                    description = L10n.prscDtlTxtMissingDosageInstructions.text
                    return
                }
                let instructions = MedicationReminderParser.parseFromDosageInstructions(dosageInstructions)

                if !instructions.isEmpty {
                    var description = L10n.prscDtlTxtDosageInstructionsFormatted.text + "\n\n"
                    description += instructions.map(\.description).joined(separator: "\n")
                    self.description = description
                } else if dosageInstructions
                    .localizedCaseInsensitiveContains(ErpPrescription.Key.MedicationRequest.dosageInstructionDj) {
                    description = L10n.prscDtlTxtDosageInstructionsDf.text
                } else {
                    description = L10n.prscDtlTxtDosageInstructionsNote.text
                }
            }
        }
    }

    enum Action: BindableAction, Equatable {
        case addButtonPressed
        case delete(IndexSet)
        case repetitionTypeChanged(MedicationSchedule.RepetitionType)
        case save
        case binding(BindingAction<State>)
        case setNavigation(tag: Destinations.State.Tag?)
        case destination(PresentationAction<Destinations.Action>)

        // testing example, should be moved to appDelegate didFinishLaunching
        case authorizationErrorReceived(Error)

        case delegate(Delegate)

        enum Delegate: Equatable {
            case saveButtonTapped(MedicationSchedule)
        }
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce(core)
            .ifLet(\.$destination, action: /Action.destination) {
                Destinations()
            }
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.date) var date
    @Dependency(\.calendar) var calendar
    @Dependency(\.notificationScheduler) var notificationScheduler
    @Dependency(\.medicationScheduleRepository) var medicationScheduleRepository

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .addButtonPressed:
            let hourComponentSuggestion: Int
            let minuteComponentSuggestion: Int
            let amountSuggestion: String
            if let lastEntry = state.medicationSchedule.entries.last {
                hourComponentSuggestion = lastEntry.hourComponent
                minuteComponentSuggestion = lastEntry.minuteComponent
                amountSuggestion = lastEntry.amount
            } else {
                let date = date.now
                hourComponentSuggestion = calendar.component(.hour, from: date)
                minuteComponentSuggestion = calendar.component(.minute, from: date)
                amountSuggestion = "1"
            }
            let scheduleEntry = MedicationSchedule.Entry(
                id: uuid(),
                title: "1",
                hourComponent: hourComponentSuggestion,
                minuteComponent: minuteComponentSuggestion,
                dosageForm: L10n.medReminderTxtTimeScheduleDosageLabel.text,
                amount: amountSuggestion
            )
            state.medicationSchedule.entries.append(scheduleEntry)
            return .none
        case let .delete(indexSet):
            state.medicationSchedule.entries.remove(atOffsets: indexSet)
            return .none
        case let .binding(action):
            switch action {
            case \.$medicationSchedule:
                // Prevents that the user can set a start date after the end date
                if state.medicationSchedule.end < state.medicationSchedule.start {
                    state.medicationSchedule.end = state.medicationSchedule.start
                }
            default:
                break
            }
            return .none
        case .destination:
            return .none
        case let .authorizationErrorReceived(error):
            // todomedicationReminder maybe a more specific error?
            state.destination = .alert(.error(
                error: error,
                alertState: .init(for: error, actions: {
                    ButtonState(role: .cancel, action: .dismiss) {
                        .init(L10n.alertBtnOk)
                    }
                })
            ))
            return .none
        case .save:
            return .run { [medicationSchedule = state.medicationSchedule] send in
                do {
                    _ = try await notificationScheduler.requestAuthorization([.alert, .sound, .badge])
                } catch {
                    await send(.authorizationErrorReceived(.generic(error.localizedDescription)))
                    return
                }
                do {
                    try await medicationScheduleRepository.create(medicationSchedule)
                } catch {
                    // todomedicationReminder maybe another (specific) error?
                    await send(.authorizationErrorReceived(.generic(error.localizedDescription)))
                    return
                }
                await send(.delegate(.saveButtonTapped(medicationSchedule)))
            }
        case let .repetitionTypeChanged(type):
            switch type {
            case .finite:
                state.medicationSchedule.end = date.now
            case .infinite:
                state.medicationSchedule.end = Date.distantFuture
            }
            return .none
        case let .setNavigation(tag: tag):
            switch tag {
            case .repetitionDetails:
                state.destination = .repetitionDetails
            case .dosageInstructionsInfo:
                let dosageInstructionsState = Destinations.DosageInstructionsState(
                    dosageInstructions: state.medicationSchedule.dosageInstructions
                )
                state.destination = .dosageInstructionsInfo(dosageInstructionsState)
            case .none:
                state.destination = nil
            default: break
            }
            return .none
        case .delegate:
            return .none
        }
    }
}

extension MedicationSchedule {
    enum RepetitionType {
        case finite
        case infinite
    }

    var repetitionType: RepetitionType {
        end == Date.distantFuture ? .infinite : .finite
    }
}

extension MedicationReminderSetupDomain {
    enum Dummies {
        static let state = State(medicationSchedule: MedicationSchedule.mock1)

        static let store = Store(
            initialState: state
        ) {
            MedicationReminderSetupDomain()
        }

        static func storeFor(_ state: State) -> Store {
            Store(
                initialState: state
            ) {
                MedicationReminderSetupDomain()
            }
        }
    }
}

extension MedicationSchedule {
    static var mock1: Self {
        @Dependency(\.uuid) var uuid
        @Dependency(\.date) var date

        return MedicationSchedule(
            id: uuid(),
            start: date(),
            end: date().addingTimeInterval(60 * 60 * 24 * 7),
            title: "Medication Title",
            dosageInstructions: "Medication Instructions",
            taskId: "123.4567.890",
            isActive: false,
            entries: IdentifiedArray(
                uniqueElements: [
                    .mock1,
                ]
            )
        )
    }

    static var mock2: Self {
        @Dependency(\.uuid) var uuid
        @Dependency(\.date) var date

        let entryMock1 = Entry(
            id: uuid(),
            title: "Entry1 Title",
            hourComponent: 10,
            minuteComponent: 5,
            dosageForm: "Dosage(s)",
            amount: "2"
        )
        let entryMock2 = Entry(
            id: uuid(),
            title: "Entry2 Title",
            hourComponent: 14,
            minuteComponent: 5,
            dosageForm: "Dosage(s)",
            amount: "1"
        )
        let entryMock3 = Entry(
            id: uuid(),
            title: "Entry3 Title",
            hourComponent: 0,
            minuteComponent: 0,
            dosageForm: "Dosage(s)",
            amount: "3"
        )
        let entryMock4 = Entry(
            id: uuid(),
            title: "Entry4 Title",
            hourComponent: 16,
            minuteComponent: 0,
            dosageForm: "Dosage(s)",
            amount: "2"
        )

        return MedicationSchedule(
            id: uuid(),
            start: date(),
            end: date().addingTimeInterval(60 * 60 * 24 * 7),
            title: "Gerafenac Salbe 30 mg",
            dosageInstructions: "Some Medication Instructions",
            taskId: "123.4567.891",
            isActive: true,
            entries: IdentifiedArray(
                uniqueElements: [
                    entryMock1,
                    entryMock2,
                    entryMock3,
                    entryMock4,
                ]
            )
        )
    }
}

extension MedicationSchedule.Entry {
    static var mock1: Self {
        @Dependency(\.uuid) var uuid
        @Dependency(\.date) var date
        @Dependency(\.calendar) var calendar

        let entryDate = date().addingTimeInterval(60 * 5)
        return MedicationSchedule.Entry(
            id: uuid(),
            title: "Entry Title",
            hourComponent: calendar.component(.hour, from: entryDate),
            minuteComponent: calendar.component(.minute, from: entryDate),
            dosageForm: "Dosage(s)",
            amount: "1"
        )
    }
}
