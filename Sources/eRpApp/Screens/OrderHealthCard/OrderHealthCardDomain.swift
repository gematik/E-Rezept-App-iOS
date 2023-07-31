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

struct OrderHealthCardDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct State: Equatable {
        var insuranceCompanies = [HealthInsuranceCompany]()
        var insuranceCompany: HealthInsuranceCompany?
        var serviceInquiry: ServiceInquiry?
        var searchText: String = ""
        var searchHealthInsurance = [HealthInsuranceCompany]()
        var healthInsuranceCompanyId: UUID?
        var serviceInquiryId: Int = -1

        var isPinServiceAndContact: Bool {
            if serviceInquiry == .pin, insuranceCompany?.hasContactInformationForPin == true {
                return true
            } else {
                return false
            }
        }

        var isHealthCardAndPinServiceAndContact: Bool {
            if serviceInquiry == .healthCardAndPin, insuranceCompany?.hasContactInformationForHealthCardAndPin == true {
                return true
            } else {
                return false
            }
        }

        var destination: Destinations.State? = .searchPicker
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
        case setService(service: ServiceInquiry)
        case selectHealthInsurance(id: UUID)
        case resetList
        case advance

        case destination(Destinations.Action)
        case setNavigation(tag: Destinations.State.Tag?)

        case delegate(Delegate)

        enum Delegate: Equatable {
            case close
        }
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = contactInsuranceCompany_selectKK
            case searchPicker
            // sourcery: AnalyticsScreen = contactInsuranceCompany_selectReason
            case serviceInquiry
            // sourcery: AnalyticsScreen = contactInsuranceCompany_selectMethod
            case contactOptions
        }

        enum Action: Equatable {}

        var body: some ReducerProtocol<State, Action> {
            EmptyReducer()
        }
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
            .ifLet(\.destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
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
            state.destination = .serviceInquiry
            return .none
        case .setNavigation(tag: .searchPicker):
            state.destination = .searchPicker
            return .none
        case .setNavigation(tag: .contactOptions):
            state.destination = .contactOptions
            return .none
        case .advance:
            switch state.destination {
            case .searchPicker:
                state.destination = .serviceInquiry
                return .none
            case .serviceInquiry:
                state.destination = .contactOptions
                return .none
            case .contactOptions,
                 .none:
                return .none
            }
        case let .updateSearchText(newPrompt):
            state.searchText = newPrompt
            return .none
        case .searchList:
            var result = [HealthInsuranceCompany]()
            for insurance in state.insuranceCompanies
                where insurance.name.lowercased().contains(state.searchText.lowercased()) {
                result.append(insurance)
            }
            state.searchHealthInsurance = result
            return .none
        case let .setService(service):
            state.serviceInquiryId = service.id
            state.serviceInquiry = service
            return EffectTask(value: .advance)
        case let .selectHealthInsurance(id):
            state.healthInsuranceCompanyId = id
            state.insuranceCompany = state.insuranceCompanies.first { $0.id == state.healthInsuranceCompanyId }
            if let inquiryId = state.insuranceCompany?.serviceInquiryOptions.first {
                state.serviceInquiryId = inquiryId.rawValue
                state.serviceInquiry = ServiceInquiry(rawValue: state.serviceInquiryId)
            } else {
                state.serviceInquiryId = -1
            }
            return EffectTask(value: .advance)
        case .resetList:
            state.searchHealthInsurance = state.insuranceCompanies
            return .none
        case .setNavigation(tag: nil):
            state.destination = nil
            return .none
        case .delegate,
             .setNavigation:
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
    }
}

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

        static let store = storeFor(state)

        static func storeFor(_ state: State) -> Store {
            Store(initialState: state, reducer: OrderHealthCardDomain())
        }
    }
}
