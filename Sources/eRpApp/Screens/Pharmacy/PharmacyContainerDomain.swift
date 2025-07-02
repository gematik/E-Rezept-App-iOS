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

@Reducer
struct PharmacyContainerDomain {
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()

        // Child domain states
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
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Path {
        // sourcery: AnalyticsScreen = pharmacySearch
        case redeem(PharmacyRedeemDomain)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.pharmacySearch, action: \.pharmacySearch) {
            PharmacySearchDomain()
        }

        Reduce(self.core)
            .forEach(\.path, action: \.path)
    }

    // swiftlint:disable:next function_body_length
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
                @Dependency(\.schedulers) var schedulers
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
        case .path, .pharmacySearch:
            return .none
        }
    }
}
