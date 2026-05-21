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

import CasePaths
import Combine
import ComposableArchitecture
import eRpKit
import FeatureHelpers
import IDP
import UIKit

@Reducer
struct RedeemMethodsDomain {
    @ObservableState
    struct State: Equatable {
        var prescriptions: [Prescription]
        @Presents var destination: Destination.State?

        var isEURedeemable: Bool {
            @Shared(.euRedeemPrescriptionsFeature) var euRedeemPrescriptionsFeature: Bool
            @Shared(.isDemoMode) var isDemoMode: Bool
            return (isDemoMode || euRedeemPrescriptionsFeature) && // silent preview for demo mode
                prescriptions.contains(where: \.erxTask.isEURedeemable)
        }
    }

    enum Action: Equatable {
        case closeButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case delegate(Delegate)

        case resetNavigation
        case matrixCodeTapped

        enum Delegate: Equatable {
            case close
            case redeemOverview([Prescription])
            case euRedeemTapped([Prescription])
        }
    }

    @Reducer
    enum Destination {
        // sourcery: AnalyticsScreen = redeem_matrixCode
        case matrixCode(MatrixCodeDomain)
    }

    @Dependency(\.schedulers) var schedulers: Schedulers

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .closeButtonTapped:
                return .send(.delegate(.close))
            case .matrixCodeTapped:
                state.destination = .matrixCode(
                    MatrixCodeDomain.State(
                        type: .erxTask,
                        erxTasks: state.prescriptions.map(\.erxTask)
                    )
                )
                return .none
            case .resetNavigation:
                state.destination = nil
                return .none
            case .destination, .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension SharedReaderKey
    where Self == AppStorageKey<Bool>.Default {
    /// A key to determine whether the app should show the feature eu redeeming of prescriptions.
    /// As soon as this feature goes live, this key should be removed.
    public static var euRedeemPrescriptionsFeature: Self {
        Self[.appStorage("eu_redeem_prescriptions_feature"), default: false]
    }
}

extension RedeemMethodsDomain {
    enum Dummies {
        static let state = State(
            prescriptions: [Prescription.Dummies.prescriptionReady]
        )

        static let store = Store(
            initialState: state
        ) {
            RedeemMethodsDomain()
        }
    }
}

extension RedeemMethodsDomain.Destination.State: Equatable {}
extension RedeemMethodsDomain.Destination.Action: Equatable {}
