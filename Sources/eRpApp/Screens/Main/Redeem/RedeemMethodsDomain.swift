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

import CasePaths
import Combine
import ComposableArchitecture
import eRpKit
import IDP
import UIKit

@Reducer
struct RedeemMethodsDomain {
    @ObservableState
    struct State: Equatable {
        var prescriptions: [Prescription]
        @Presents var destination: Destination.State?
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
        }
    }

    @Reducer(state: .equatable, action: .equatable)
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
