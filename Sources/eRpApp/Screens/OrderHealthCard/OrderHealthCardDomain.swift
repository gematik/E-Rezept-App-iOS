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
import eRpKit
import SwiftUI

@Reducer
struct OrderHealthCardDomain {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = contactInsuranceCompany_selectReason
        case serviceInquiry(OrderHealthCardInquiryDomain)
    }

    @ObservableState
    struct State: Equatable {
        var insuranceCompanies: [HealthInsuranceCompany] = []
        var filteredInsuranceCompanies: [HealthInsuranceCompany] = []
        var searchText: String = ""

        @Presents var destination: Destination.State?
    }

    enum ServiceInquiry: Int, CaseIterable, Identifiable {
        case pin
        case healthCardAndPin

        var id: Int { rawValue }
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)

        case loadList
        case searchList
        case selectHealthInsurance(HealthInsuranceCompany)
        case resetList

        case destination(PresentationAction<Destination.Action>)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case close
        }
    }

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loadList:
            let decoder = JSONDecoder()
            let insuranceCompanies: [HealthInsuranceCompany]
            if let url = Bundle.module.url(forResource: "health_insurance_contacts", withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let directory = try? decoder
               .decode([HealthInsuranceCompany].self, from: data) {
                insuranceCompanies = directory
            } else {
                insuranceCompanies = []
            }

            state.insuranceCompanies = insuranceCompanies
            return .none
        case .searchList:
            var result = [HealthInsuranceCompany]()
            for insurance in state.insuranceCompanies
                where insurance.name.lowercased().contains(state.searchText.lowercased()) {
                result.append(insurance)
            }
            state.filteredInsuranceCompanies = result
            return .none
        case let .selectHealthInsurance(insuranceCompany):
            state.destination = .serviceInquiry(.init(insuranceCompany: insuranceCompany))
            return .none
        case .resetList:
            state.filteredInsuranceCompanies = state.insuranceCompanies
            return .none
        case let .destination(.presented(.serviceInquiry(.delegate(action)))):
            switch action {
            case .close:
                return .send(.delegate(.close))
            }
        case .delegate,
             .destination,
             .binding:
            return .none
        }
    }
}

extension OrderHealthCardDomain {
    struct HealthInsuranceCompany: Decodable, Identifiable, Hashable {
        let id = UUID()
        let name: String
        let healthCardAndPinPhone: String
        let healthCardAndPinMail: String
        let healthCardAndPinUrl: String
        let pinUrl: String
        let subjectCardAndPinMail: String
        let bodyCardAndPinMail: String
        let subjectPinMail: String
        let bodyPinMail: String

        private enum CodingKeys: String, CodingKey {
            case name
            case healthCardAndPinPhone
            case healthCardAndPinMail
            case healthCardAndPinUrl
            case pinUrl
            case subjectCardAndPinMail
            case bodyCardAndPinMail
            case subjectPinMail
            case bodyPinMail
        }

        var serviceInquiryOptions: [ServiceInquiry] {
            var options = [ServiceInquiry]()
            if hasContactInformationForHealthCardAndPin {
                options.append(.healthCardAndPin)
            }
            if hasContactInformationForPin {
                options.append(.pin)
            }

            return options
        }

        var hasContactInformation: Bool {
            hasContactInformationForPin || hasContactInformationForHealthCardAndPin
        }

        var hasContactInformationForPin: Bool {
            !healthCardAndPinPhone.isEmpty || !pinUrl.isEmpty || !healthCardAndPinMail.isEmpty
        }

        var hasContactInformationForHealthCardAndPin: Bool {
            !healthCardAndPinPhone.isEmpty || !healthCardAndPinMail.isEmpty || !healthCardAndPinUrl.isEmpty
        }

        func createEmailUrl(for serviceInquiry: ServiceInquiry) -> URL? {
            let subject: String
            let body: String
            let email: String

            switch serviceInquiry {
            case .healthCardAndPin:
                subject = subjectCardAndPinMail
                body = bodyCardAndPinMail
                email = healthCardAndPinMail
            case .pin:
                subject = subjectPinMail
                body = bodyPinMail
                email = !subjectPinMail.isEmpty && !bodyPinMail.isEmpty ? healthCardAndPinMail : ""
            }

            guard !email.isEmpty else {
                return nil
            }
            var urlString = URLComponents(string: "mailto:\(email)")
            var queryItems = [URLQueryItem]()

            queryItems.append(URLQueryItem(name: "subject", value: subject))
            queryItems.append(URLQueryItem(name: "body", value: body))
            urlString?.queryItems = queryItems

            return urlString?.url
        }

        static let dummyHealthInsuranceCompany = OrderHealthCardDomain.HealthInsuranceCompany(
            name: "DummyHealthInsuranceCompany",
            healthCardAndPinPhone: "003012341234",
            healthCardAndPinMail: "app-feedback@gematik.de",
            healthCardAndPinUrl: "",
            pinUrl: "www.gematik.de",
            subjectCardAndPinMail: "#eGKPIN# Bestellung einer NFC-fähigen Gesundheitskarte und PIN",
            bodyCardAndPinMail: "",
            subjectPinMail: "#PIN# Bestellung einer PIN zur Gesundheitskarte",
            bodyPinMail: ""
        )
    }
}

extension OrderHealthCardDomain {
    enum Dummies {
        static let state = State(
            insuranceCompanies: [OrderHealthCardDomain.HealthInsuranceCompany.dummyHealthInsuranceCompany]
        )

        static let store = storeFor(state)

        static func storeFor(_ state: State) -> StoreOf<OrderHealthCardDomain> {
            Store(
                initialState: state
            ) {
                OrderHealthCardDomain()
            }
        }
    }
}
