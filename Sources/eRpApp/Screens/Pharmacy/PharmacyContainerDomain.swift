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
import eRpKit
import FeatureEURedeem
import Foundation

@Reducer
struct PharmacyContainerDomain {
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()

        /// Child domain states
        var pharmacySearch: PharmacySearchDomain.State
    }

    enum Action: Equatable {
        case path(StackActionOf<Path>)
        case pharmacySearch(PharmacySearchDomain.Action)
        case redeem(
            prescriptions: [Prescription],
            selectedPrescriptions: [Prescription],
            pharmacy: PharmacyLocation,
            option: RedeemOption
        )
        case euRedeemSelection
        case euRedeemInstructions(_ isRedeeming: Bool, countryCode: String?)
        case euRedeemCode(countryCode: String)
        case euNoCountryAlert
    }

    @Reducer
    enum Path {
        // sourcery: AnalyticsScreen = pharmacySearch
        case redeem(PharmacyRedeemDomain)

        /// EU redeem selection screen
        case euRedeemSelection(EURedeemSelectionDomain)
        /// Country selection screen
        case countrySelection(CountrySelectionDomain)
        /// Prescription selection screen
        case prescriptionSelection(SelectEUPrescriptionsDomain)
        /// Instructions screen
        case instructions(InstructionsDomain)
        /// Code display screen
        case code(CodeDomain)
    }

    @Dependency(\.schedulers) var schedulers
    @Dependency(\.userDataStore) var userDataStore: UserDataStore
    @Dependency(\.userProfileService) var userProfileService: UserProfileService

    var body: some Reducer<State, Action> {
        Scope(state: \.pharmacySearch, action: \.pharmacySearch) {
            PharmacySearchDomain()
        }

        Reduce(core)
            .forEach(\.path, action: \.path)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .pharmacySearch(.destination(.presented(
            .pharmacyMapSearch(.destination(.presented(
                .pharmacy(.delegate(.redeem(
                    prescriptions: prescriptions,
                    selectedPrescriptions: selectedPrescriptions,
                    pharmacy: pharmacy,
                    option: redeemOption
                )))
            )))
        ))),
        let .pharmacySearch(.destination(.presented(
            .pharmacyDetail(.delegate(.redeem(
                prescriptions: prescriptions,
                selectedPrescriptions: selectedPrescriptions,
                pharmacy: pharmacy,
                option: redeemOption
            )))
        ))):
            state.pharmacySearch.destination = nil

            return .run { send in
                // wait for running effects to finish
                try await schedulers.main.sleep(for: 0.05)
                await send(.redeem(
                    prescriptions: prescriptions,
                    selectedPrescriptions: selectedPrescriptions,
                    pharmacy: pharmacy,
                    option: redeemOption
                ))
            }
        case let .path(.element(id: _, action: .redeem(.delegate(delegate)))):
            switch delegate {
            case .changePharmacy:
                state.path.removeAll()
            case .close:
                guard !state.path.isEmpty else {
                    reportIssue("PharmacyRedeemDomain should always be the last element in the path. \(state.path)")
                    return .none
                }
                state.path.removeLast()
            }
            return .none
        case let .redeem(
            prescriptions: prescriptions,
            selectedPrescriptions: selectedPrescriptions,
            pharmacy: pharmacy,
            option: redeemOption
        ):
            state.path.append(.redeem(PharmacyRedeemDomain.State(
                prescriptions: Shared(value: prescriptions),
                selectedPrescriptions: Shared(value: selectedPrescriptions),
                pharmacy: pharmacy,
                serviceOptionState: .init(
                    prescriptions: Shared(value: prescriptions),
                    selectedOption: redeemOption
                )
            )))
            return .none
        case .pharmacySearch(.delegate(.euRedeemTapped)),
             .pharmacySearch(.destination(.presented(.pharmacyMapSearch(.delegate(.euRedeemTapped))))):
            state.pharmacySearch.destination = nil
            return .run { send in
                // wait for running effects to finish
                try await schedulers.main.sleep(for: 0.05)
                await send(.euRedeemSelection)
            }
        case .euRedeemSelection:
            state.path.append(.euRedeemSelection(.init()))
            return .none
        case let .euRedeemInstructions(isRedeeming, countryCode: countryCode):
            state.path.append(.instructions(.init(isRedeeming: isRedeeming, countryCode: countryCode)))
            return .none
        case let .euRedeemCode(countryCode):
            state.path.append(.code(.init(countryCode: countryCode)))
            return .none
        case let .path(.element(id: _, action: .countrySelection(.selectCountry(country)))):
            state.path.removeLast()
            guard let id = state.path.ids.last
            else { return .none }
            state.path[id: id, case: \.euRedeemSelection]?.selectedCountry = country
            return .none
        case let .path(.popFrom(id: id)):
            // Back navigation from PrescriptionSelection to EURedeemSelection
            if let path = state.path[id: id, case: \.prescriptionSelection] {
                let prescriptions = path.prescriptions.filter(\.isSetEURedeemableByPatient)
                guard state.path.ids.count > 1 else { return .none }
                let previousId = state.path.ids[state.path.index(before: state.path.endIndex - 1)]
                state.path[id: previousId, case: \.euRedeemSelection]?.$selectedPrescriptions
                    .withLock { $0 = prescriptions }
            }
            return .none
        case let .path(.element(id: id, action: .euRedeemSelection(.delegate(delegate)))):
            switch delegate {
            case .selectPrescriptionsButtonTapped:
                state.path.append(.prescriptionSelection(.init()))
                return .none
            case .selectCountryButtonTapped:
                state.path.append(.countrySelection(.init()))
                return .none
            case let .selectInstructionButtonTapped(countryCode: countryCode):
                return .send(.euRedeemInstructions(false, countryCode: countryCode))
            case .redeemPrescriptions:
                return .run { [path = state.path, userDataStore = self.userDataStore] send in
                    let hideEURedeemInstructions = try await userDataStore.hideEURedeemInstructions.async()
                    guard let code = path[id: id, case: \.euRedeemSelection]?.selectedCountry?.countryCode else {
                        await send(.euNoCountryAlert)
                        return
                    }
                    if hideEURedeemInstructions {
                        await send(.euRedeemCode(countryCode: code))
                    } else {
                        userDataStore.set(hideEURedeemInstructions: true)
                        await send(.euRedeemInstructions(true, countryCode: code))
                    }
                }
            case .back:
                _ = state.path.dropLast()
                return .none
            case .close:
                state.path.removeAll()
                return .none
            case .unlockCardClose:
                return .none
            }
        case .euNoCountryAlert:
            guard let id = state.path.ids.last
            else { return .none }
            state.path[id: id, case: \.euRedeemSelection]?
                .destination = .alert(EURedeemSelectionDomain.AlertStates.noCountryCode)
            return .none
        case let .path(.element(id: id, action: .instructions(.delegate(delegate)))):
            switch delegate {
            case .continueButtonTapped:
                state.path.removeLast()
                guard let id = state.path.ids.last
                else { return .none }

                guard let code = state.path[id: id, case: \.euRedeemSelection]?.selectedCountry?.countryCode else {
                    state.path[id: id, case: \.euRedeemSelection]?
                        .destination = .alert(EURedeemSelectionDomain.AlertStates.noCountryCode)
                    return .none
                }
                return .send(.euRedeemCode(countryCode: code))
            case .close:
                state.path.removeAll()
                return .none
            }
        case let .path(.element(id: _, action: .code(.delegate(delegate)))):
            switch delegate {
            case .takeReceipt:
                state.path.removeAll()
                return .none
            case .close:
                state.path.removeAll()
                return .none
            }
        case .path, .pharmacySearch:
            return .none
        }
    }
}

extension PharmacyContainerDomain.Path.State: Equatable {}
extension PharmacyContainerDomain.Path.Action: Equatable {}
