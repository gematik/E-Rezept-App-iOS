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
import eRpStyleKit
import Foundation
import IDP
import Pharmacy
import SwiftUI

@Reducer
struct DiGaInsuranceListDomain {
    @ObservableState
    struct State: Equatable {
        var selectedInsurance: Insurance?
        var insurances: [Insurance] = []
        var filteredinsurances: [Insurance] = []
        var searchText: String = ""
        var isLoading = false
        @Presents var destination: Destination.State?
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        @ReducerCaseEphemeral
        // sourcery: AnalyticsScreen = alert
        case alert(ErpAlertState<Alert>)

        enum Alert {
            case dismiss
        }
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case task
        case searchList(String)
        case selectInsurance(Insurance)
        case response(Response)
        case destination(PresentationAction<Destination.Action>)

        enum Response: Equatable {
            case receivedInsurances(Result<[Insurance], PharmacyRepositoryError>)
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.pharmacyRepository) var pharmacyRepository: PharmacyRepository

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            state.isLoading = true
            return .publisher(
                pharmacyRepository.fetchAllInsurances()
                    .catchToPublisher()
                    .map { Action.response(.receivedInsurances($0)) }
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
        case let .response(.receivedInsurances(result)):
            switch result {
            case let .success(insurances):
                let sortedResult = insurances.sortedInsruance()
                state.insurances = sortedResult
                state.filteredinsurances = sortedResult
                state.isLoading = false
                return .none
            case let .failure(error):
                state.isLoading = false
                state.destination = .alert(.init(for: error))
                return .none
            }
        case let .searchList(newString):
            guard !newString.isEmpty else {
                state.filteredinsurances = state.insurances
                return .none
            }
            state.filteredinsurances = state.insurances.compactMap { insurance in
                guard let insuranceName = insurance.name,
                      insuranceName.lowercased().contains(newString.lowercased()) else { return nil }
                return insurance
            }
            .sortedInsruance()
            return .none
        case .selectInsurance,
             .response,
             .binding,
             .destination:
            return .none
        }
    }
}

extension Array where Element == Insurance {
    func sortedInsruance() -> [Insurance] {
        sorted { first, second in
            guard let firstName = first.name?.lowercased(),
                  let secondName = second.name?.lowercased()
            else { return true }
            return firstName < secondName
        }
    }
}

extension Asset.InsuranceLogo {
    static func imageAsset(for name: String?) -> ImageAsset {
        guard let name = name else {
            return Asset.InsuranceLogo.fallback
        }
        return allImagesHelper.first { $0.name == name } ?? Asset.InsuranceLogo.fallback
    }

    static let allImagesHelper: [ImageAsset] = [
        Asset.InsuranceLogo._8010000000001,
        Asset.InsuranceLogo._8010000000003,
        Asset.InsuranceLogo._8010000000006,
        Asset.InsuranceLogo._8010000000008,
        Asset.InsuranceLogo._8010000000011,
        Asset.InsuranceLogo._8010000000012,
        Asset.InsuranceLogo._8010000000015,
        Asset.InsuranceLogo._8010000000016,
        Asset.InsuranceLogo._8010000000018,
        Asset.InsuranceLogo._8010000000019,
        Asset.InsuranceLogo._8010000000020,
        Asset.InsuranceLogo._8010000000022,
        Asset.InsuranceLogo._8010000000024,
        Asset.InsuranceLogo._8010000000025,
        Asset.InsuranceLogo._8010000000026,
        Asset.InsuranceLogo._8010000000027,
        Asset.InsuranceLogo._8010000000028,
        Asset.InsuranceLogo._8010000000031,
        Asset.InsuranceLogo._8010000000033,
        Asset.InsuranceLogo._8010000000036,
        Asset.InsuranceLogo._8010000000037,
        Asset.InsuranceLogo._8010000000038,
        Asset.InsuranceLogo._8010000000039,
        Asset.InsuranceLogo._8010000000041,
        Asset.InsuranceLogo._8010000000042,
        Asset.InsuranceLogo._8010000000043,
        Asset.InsuranceLogo._8010000000045,
        Asset.InsuranceLogo._8010000000046,
        Asset.InsuranceLogo._8010000000048,
        Asset.InsuranceLogo._8010000000050,
        Asset.InsuranceLogo._8010000000052,
        Asset.InsuranceLogo._8010000000053,
        Asset.InsuranceLogo._8010000000054,
        Asset.InsuranceLogo._8010000000055,
        Asset.InsuranceLogo._8010000000057,
        Asset.InsuranceLogo._8010000000058,
        Asset.InsuranceLogo._8010000000061,
        Asset.InsuranceLogo._8010000000062,
        Asset.InsuranceLogo._8010000000063,
        Asset.InsuranceLogo._8010000000064,
        Asset.InsuranceLogo._8010000000068,
        Asset.InsuranceLogo._8010000000073,
        Asset.InsuranceLogo._8010000000074,
        Asset.InsuranceLogo._8010000000075,
        Asset.InsuranceLogo._8010000000076,
        Asset.InsuranceLogo._8010000000081,
        Asset.InsuranceLogo._8010000000082,
        Asset.InsuranceLogo._8010000000084,
        Asset.InsuranceLogo._8010000000085,
        Asset.InsuranceLogo._8010000000086,
        Asset.InsuranceLogo._8010000000087,
        Asset.InsuranceLogo._8010000000089,
        Asset.InsuranceLogo._8010000000090,
        Asset.InsuranceLogo._8010000000091,
        Asset.InsuranceLogo._8010000000094,
        Asset.InsuranceLogo._8010000000095,
        Asset.InsuranceLogo._8010000000096,
        Asset.InsuranceLogo._8010000000097,
        Asset.InsuranceLogo._8010000000098,
        Asset.InsuranceLogo._8010000000099,
        Asset.InsuranceLogo._8010000000100,
        Asset.InsuranceLogo._8010000000101,
        Asset.InsuranceLogo._8010000000103,
        Asset.InsuranceLogo._8010000000104,
        Asset.InsuranceLogo._8010000000105,
        Asset.InsuranceLogo._8010000000207,
        Asset.InsuranceLogo._8010000000208,
        Asset.InsuranceLogo._8010000000229,
        Asset.InsuranceLogo._925920000001,
        Asset.InsuranceLogo._925920000007,
        Asset.InsuranceLogo._925920000008,
        Asset.InsuranceLogo._925920000009,
        Asset.InsuranceLogo._925920000010,
        Asset.InsuranceLogo._925920000014,
        Asset.InsuranceLogo._925920000015,
        Asset.InsuranceLogo._925920000019,
        Asset.InsuranceLogo._925920000023,
        Asset.InsuranceLogo._925920000025,
        Asset.InsuranceLogo._925920000026,
        Asset.InsuranceLogo._925920000027,
        Asset.InsuranceLogo._925920000028,
        Asset.InsuranceLogo._925920000030,
        Asset.InsuranceLogo._925920000032,
        Asset.InsuranceLogo._925920000033,
        Asset.InsuranceLogo._925920000034,
        Asset.InsuranceLogo._925920000035,
        Asset.InsuranceLogo.fallback,
    ]
}

extension DiGaInsuranceListDomain {
    enum Dummies {
        static let state = State()

        static let store = Store(
            initialState: state
        ) {
            DiGaInsuranceListDomain()
        }

        static func storeFor(_ state: State) -> StoreOf<DiGaInsuranceListDomain> {
            Store(
                initialState: state
            ) {
                DiGaInsuranceListDomain()
            }
        }
    }
}
