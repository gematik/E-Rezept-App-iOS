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

import ComposableArchitecture

/// Domain handling the EU prescription redemption flow
@Reducer
public struct EURedeemDomain {
    /// State for the EU redemption flow
    @ObservableState
    public struct State: Equatable {
        /// First redeem of a eu prescription for this profile
        public var firstRedeem = true
        /// Navigation path for the redemption flow
        public var path = StackState<Path.State>()
        /// State for the selection screen
        public var selection = EURedeemSelectionDomain.State()
        /// Initializer for the state
        public init(path: StackState<Path.State> = StackState(),
                    selection: EURedeemSelectionDomain.State? = nil) {
            self.path = path
            self.selection = selection ?? .init(prescriptions: EURedeemSelectionDomain.Dummies.prescriptions)
        }
    }

    /// Actions for the EU redemption flow
    @CasePathable
    public enum Action: Equatable {
        /// Navigation path actions
        case path(StackActionOf<Path>)
        /// Selection screen actions
        case selection(EURedeemSelectionDomain.Action)
    }

    /// Navigation path cases for the redemption flow
    @Reducer(state: .equatable, action: .equatable)
    public enum Path {
        /// Country selection screen
        case countrySelection(CountrySelectionDomain)
        /// Prescription selection screen
        case prescriptionSelection(SelectEUPrescriptionsDomain)
        /// Instructions screen
        case instructions(InstructionsDomain)
        /// Code display screen
        case code(CodeDomain)
    }

    /// Initialize the domain
    public init() {}

    /// Reducer body
    public var body: some Reducer<State, Action> {
        Scope(state: \.selection, action: \.selection) {
            EURedeemSelectionDomain()
        }
        Reduce(self.core)
            .forEach(\.path, action: \.path)
    }

    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .selection(.delegate(delegate)):
            switch delegate {
            case .selectInstructionButtonTapped:
                state.path.append(.instructions(.init()))
                return .none
            case .redeemButtonTapped:
                state.path.append(.instructions(.init()))
                return .none
            case .selectCountryButtonTapped:
                state.path.append(.countrySelection(.init(countries: EURedeemSelectionDomain.Dummies.countries)))
                return .none
            case .selectPrescriptionsButtonTapped:
                state.path.append(.prescriptionSelection(
                    SelectEUPrescriptionsDomain.State(
                        prescriptions: state.selection.prescriptions,
                        patientName: "Ada Muster"
                    )
                ))
                return .none
            case .close:
                return .none
            }
        case let .path(.element(id: _, action: .countrySelection(.selectCountry(country)))):
            state.selection.selectedCountry = country
            state.path.removeLast()
            return .none
        case let .path(.element(id: _,
                                action: .prescriptionSelection(.delegate(.didSelectPrescriptions(prescriptions))))):
            state.selection.prescriptions = prescriptions
            return .none
        case .path(.element(id: _, action: .instructions(.delegate(.continueButtonTapped)))):
            state.path.append(.code(.init()))
            return .none
        case .path, .selection:
            return .none
        }
    }
}
