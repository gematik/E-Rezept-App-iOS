//
//  Copyright (c) 2023 gematik GmbH
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

enum OrderHealthCardDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    enum Route: Equatable {
        case searchPicker
        case serviceInquiry
    }

    struct State: Equatable {
        var insuranceCompanies = [HealthInsuranceCompany]()
        var insuranceCompany: HealthInsuranceCompany?
        var serviceInquiry: ServiceInquiry?
        var searchText: String = ""
        var searchHealthInsurance = [HealthInsuranceCompany]()
        var route: Route?
        var healthInsuranceCompanyId: UUID?
        var serviceInquiryId: Int = -1
    }

    enum ServiceInquiry: Int, CaseIterable, Identifiable {
        case pin
        case healthCardAndPin

        var id: Int { rawValue }

        var localizedName: LocalizedStringKey {
            switch self {
            case .pin: return L10n.orderEgkTxtServiceInquiryOnlyPin.key
            case .healthCardAndPin: return L10n.orderEgkTxtServiceInquiryHealthcardAndPin.key
            }
        }
    }

    enum Action: Equatable {
        case loadList
        case updateSearchText(newPrompt: String)
        case searchList
        case setService(service: Int)
        case selectHealthInsurance(id: UUID)
        case setNavigation(tag: Route.Tag?)
        case resetList
        case close
    }

    struct Environment {}

    private static let domainReducer = Reducer { state, action, _ in
        switch action {
        case .loadList:
            let decoder = JSONDecoder()
            let insuranceCompanies: [HealthInsuranceCompany]
            if let url = Bundle.main.url(forResource: "health_insurance_contacts", withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let directory = try? decoder
               .decode([HealthInsuranceCompany].self, from: data) {
                insuranceCompanies = directory
            } else {
                insuranceCompanies = []
            }

            state.insuranceCompanies = insuranceCompanies
            return .none
        case .setNavigation(tag: .serviceInquiry):
            state.route = .serviceInquiry
            return .none
        case .setNavigation(tag: .searchPicker):
            state.route = .searchPicker
            return .none
        case let .updateSearchText(newPrompt):
            state.searchText = newPrompt
            return .none
        case .searchList:
            var result = [HealthInsuranceCompany]()
            for insurance in state.insuranceCompanies {
                if insurance.name.lowercased().contains(state.searchText.lowercased()) {
                    result.append(insurance)
                }
            }
            state.searchHealthInsurance = result
            return .none
        case let .setService(service):
            state.serviceInquiryId = service
            state.route = nil

            state.serviceInquiry = ServiceInquiry(rawValue: state.serviceInquiryId)

            return .none
        case let .selectHealthInsurance(id):
            state.healthInsuranceCompanyId = id
            state.route = nil

            state.insuranceCompany = state.insuranceCompanies.first { $0.id == state.healthInsuranceCompanyId }
            if let inquiryId = state.insuranceCompany?.serviceInquiryOptions.first {
                state.serviceInquiryId = inquiryId.rawValue
                state.serviceInquiry = ServiceInquiry(rawValue: state.serviceInquiryId)
            } else {
                state.serviceInquiryId = -1
            }
            return .none
        case .resetList:
            state.searchHealthInsurance = state.insuranceCompanies
            return .none
        case .setNavigation(tag: nil):
            state.route = nil
            return .none
        case .close,
             .setNavigation:
            return .none
        }
    }

    static let reducer = Reducer.combine(
        domainReducer
    )
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
            !pinUrl.isEmpty || !subjectPinMail.isEmpty || !bodyPinMail.isEmpty
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
    }
}

extension OrderHealthCardDomain.Environment {}

extension OrderHealthCardDomain.HealthInsuranceCompany {
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

extension OrderHealthCardDomain {
    enum Dummies {
        static let state = State(
            insuranceCompanies: [OrderHealthCardDomain.HealthInsuranceCompany.dummyHealthInsuranceCompany],
            insuranceCompany: OrderHealthCardDomain.HealthInsuranceCompany.dummyHealthInsuranceCompany,
            serviceInquiry: .healthCardAndPin,
            healthInsuranceCompanyId: UUID(),
            serviceInquiryId: 1
        )

        static let environment = Environment()

        static let store = storeFor(state)

        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: reducer,
                  environment: environment)
        }
    }
}
