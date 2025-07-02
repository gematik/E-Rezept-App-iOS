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
import SwiftUI

@Reducer
struct OrderHealthCardInquiryDomain {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = contactInsuranceCompany_selectMethod
        case contact(OrderHealthCardContactDomain)
    }

    @ObservableState
    struct State: Equatable {
        var insuranceCompany: OrderHealthCardDomain.HealthInsuranceCompany

        var hasContactInformation: Bool {
            insuranceCompany.hasContactInformation
        }

        @Presents var destination: Destination.State?
    }

    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)

        case setService(service: OrderHealthCardDomain.ServiceInquiry)

        case delegate(Delegate)

        enum Delegate: Equatable {
            case close
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .setService(service):
                state.destination = .contact(.init(insuranceCompany: state.insuranceCompany, serviceInquiry: service))
                return .none
            case let .destination(.presented(.contact(.delegate(action)))):
                switch action {
                case .close:
                    return .send(.delegate(.close))
                }
            case .destination,
                 .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension OrderHealthCardInquiryDomain {
    enum Dummies {
        static let state = State(insuranceCompany: .dummyHealthInsuranceCompany)

        static let store = Store(initialState: state) {
            OrderHealthCardInquiryDomain()
        }
    }
}
