//
//  Copyright (c) 2022 gematik GmbH
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

import ComposableArchitecture
import eRpKit
import SwiftUI

struct OrderHealthCardView: View {
    @StateObject var viewModel = ViewModel()
    let closeAction: () -> Void
    @State var inquiryOptionViewVisible = false

    var body: some View {
        List {
            Section(header: Header()) {}
                .textCase(.none)

            Section(
                header: SectionHeaderView(
                    text: L10n.orderEgkTxtPickerInsuranceHeader,
                    a11y: A11y.orderEGK.ogkTxtInsuranceCompanyHeader
                ).padding(.bottom, 8),
                footer: Group {}
            ) {
                Picker(
                    selection: $viewModel.healthInsuranceCompanyId,
                    label: Group {
                        Text(L10n.orderEgkTxtPickerInsurancePlaceholder)
                            .foregroundColor(Color(.label))
                    }
                ) {
                    ForEach(viewModel.insuranceCompanies) { insurance in
                        Text(insurance.name).tag(insurance.id)
                    }
                }
            }
            .textCase(.none)

            if let insuranceCompany = viewModel.insuranceCompany {
                if insuranceCompany.hasContactInformation == false {
                    Section(header: HintView(hint: hint)) { EmptyView() }
                        .textCase(.none)
                } else {
                    if insuranceCompany.serviceInquiryOptions.count > 1 {
                        Section(
                            header: SectionHeaderView(
                                text: L10n.orderEgkTxtPickerServiceHeader,
                                a11y: A11y.orderEGK.ogkTxtServiceSelectionHeader
                            ).padding(.bottom, 8)
                        ) {
                            NavigationLink(
                                destination:
                                OrderHealthCardInquiryOptionsView(
                                    availableInquiries: insuranceCompany.serviceInquiryOptions,
                                    selectedInquiry: $viewModel.serviceInquiryId,
                                    show: $inquiryOptionViewVisible
                                ),
                                isActive: $inquiryOptionViewVisible
                            ) {
                                Text(viewModel.serviceInquiry?.localizedName ?? L10n.orderEgkTxtPickerServiceLabel.key)
                                    .foregroundColor(Color(.label))
                            }
                        }
                        .textCase(.none)
                    }

                    if let serviceInquiry = viewModel.serviceInquiry {
                        Section(
                            header: SectionHeaderView(
                                text: L10n.orderEgkTxtSectionContactInsurance,
                                a11y: A11y.orderEGK.ogkTxtContactCompanyHeader
                            ).padding(.bottom, 8),
                            footer: ContactOptionsRowView(
                                healthInsuranceCompany: insuranceCompany,
                                serviceInquiry: serviceInquiry
                            )
                        ) {
                            EmptyView()
                        }
                        .textCase(.none)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .introspectTableView { tableView in
            tableView.backgroundColor = UIColor.systemBackground
            tableView.separatorStyle = .none
        }
        .respectKeyboardInsets()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: NavigationBarCloseItem {
                closeAction()
            }
            .accessibility(identifier: A11y.orderEGK.ogkBtnCancel)
            .accessibility(label: Text(L10n.cdwBtnCanCancelLabel))
        )
    }

    private let hint = Hint<String>(
        id: A11y.orderEGK.ogkTxtNoSelectionHint,
        title: L10n.orderEgkTxtHintNoContactOptionTitle.text,
        message: L10n.orderEgkTxtHintNoContactOptionMessage.text,
        actionText: nil,
        action: nil,
        imageName: Asset.Illustrations.arztRedCircle.name,
        closeAction: nil,
        style: .important,
        buttonStyle: .tertiary,
        imageStyle: .topAligned
    )

    struct Header: View {
        var body: some View {
            VStack(spacing: 8) {
                Text(L10n.orderEgkTxtHeadline)
                    .foregroundColor(Color(.label))
                    .font(Font.title.bold())
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)
                    .accessibility(identifier: A11y.orderEGK.ogkTxtHeadline)

                VStack(alignment: .leading, spacing: 8) {
                    Group {
                        Text(L10n.orderEgkTxtDescription1)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(L10n.orderEgkTxtDescription2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundColor(Color(.label))
                    .font(Font.body)
                    .accessibilityElement(children: .combine)

                    TertiaryListButton(
                        text: L10n.orderEgkBtnInfoButton,
                        imageName: nil,
                        accessibilityIdentifier: A11y.orderEGK.ogkBtnEgkInfo
                    ) {
                        if let url = URL(string: L10n.orderEgkTxtInfoLink.text) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
            .padding(.top, 16)
        }
    }

    class ViewModel: ObservableObject {
        let insuranceCompanies: [HealthInsuranceCompany]
        var insuranceCompany: HealthInsuranceCompany?
        var serviceInquiry: ServiceInquiry?

        @Published var healthInsuranceCompanyId: UUID {
            didSet {
                insuranceCompany = insuranceCompanies.first { $0.id == healthInsuranceCompanyId }
                if let inquiryId = insuranceCompany?.serviceInquiryOptions.first {
                    serviceInquiryId = inquiryId.rawValue
                } else {
                    serviceInquiryId = -1
                }
            }
        }

        @Published var serviceInquiryId: Int {
            didSet {
                serviceInquiry = ServiceInquiry(rawValue: serviceInquiryId)
            }
        }

        convenience init() {
            let decoder = JSONDecoder()
            let insuranceCompanies: [HealthInsuranceCompany]
            if let url = Bundle.main.url(forResource: "health_insurance_contacts", withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let directory = try? decoder.decode(HealthInsuranceCompanyDirectory.self, from: data) {
                insuranceCompanies = directory.entries
            } else {
                insuranceCompanies = []
            }
            self.init(insuranceCompanies: insuranceCompanies)
        }

        init(
            insuranceCompanies: [OrderHealthCardView.HealthInsuranceCompany],
            insuranceCompany: OrderHealthCardView.HealthInsuranceCompany? = nil,
            serviceInquiry: OrderHealthCardView.ServiceInquiry? = nil
        ) {
            self.insuranceCompanies = insuranceCompanies
            self.insuranceCompany = insuranceCompany
            self.serviceInquiry = serviceInquiry
            healthInsuranceCompanyId = insuranceCompany?.id ?? UUID()
            serviceInquiryId = serviceInquiry?.id ?? -1
        }
    }

    struct HealthInsuranceCompanyDirectory: Decodable {
        let entries: [HealthInsuranceCompany]
    }

    struct HealthInsuranceCompany: Decodable, Identifiable, Hashable {
        let id = UUID() // swiftlint:disable:this identifier_name

        let name: String
        let healthCardAndPinPhone: String
        let healthCardAndPinMail: String
        let healthCardAndPinUrl: String
        let pinUrl: String

        private enum CodingKeys: String, CodingKey {
            case name
            case healthCardAndPinPhone
            case healthCardAndPinMail
            case healthCardAndPinUrl
            case pinUrl
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
            !pinUrl.isEmpty
        }

        var hasContactInformationForHealthCardAndPin: Bool {
            !healthCardAndPinPhone.isEmpty || !healthCardAndPinMail.isEmpty || !healthCardAndPinUrl.isEmpty
        }

        func createEmailUrl(for serviceInquiry: ServiceInquiry) -> URL? {
            let subject: String
            let body: String
            let email: String

            switch serviceInquiry {
            case .healthCardAndPin,
                 .pin:
                subject = L10n.orderEgkTxtMailHealthcardAndPinSubject.text
                body = L10n.orderEgkTxtMailHealthcardAndPinBody.text
                email = healthCardAndPinMail
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

    enum ServiceInquiry: Int, CaseIterable, Identifiable {
        case pin
        case healthCardAndPin

        var id: Int { rawValue } // swiftlint:disable:this identifier_name

        var localizedName: LocalizedStringKey {
            switch self {
            case .pin: return L10n.orderEgkTxtServiceInquiryOnlyPin.key
            case .healthCardAndPin: return L10n.orderEgkTxtServiceInquiryHealthcardAndPin.key
            }
        }
    }
}

extension ContactOptionsRowView {
    init(
        healthInsuranceCompany: OrderHealthCardView.HealthInsuranceCompany,
        serviceInquiry: OrderHealthCardView.ServiceInquiry
    ) {
        switch serviceInquiry {
        case .pin:
            self.init(
                phone: "",
                web: healthInsuranceCompany.pinUrl,
                email: nil
            )
        case .healthCardAndPin:
            self.init(
                phone: healthInsuranceCompany.healthCardAndPinPhone,
                web: healthInsuranceCompany.healthCardAndPinUrl,
                email: healthInsuranceCompany.createEmailUrl(for: .healthCardAndPin)
            )
        }
    }
}

struct OrderHealthCardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrderHealthCardView {}
        }
        NavigationView {
            OrderHealthCardView(viewModel: OrderHealthCardView.ViewModel.dummyViewModel) {}
        }
    }
}

extension OrderHealthCardView.HealthInsuranceCompany {
    static let dummyHealthInsuranceCompany = OrderHealthCardView.HealthInsuranceCompany(
        name: "DummyHealthInsuranceCompany",
        healthCardAndPinPhone: "003012341234",
        healthCardAndPinMail: "app-feedback@gematik.de",
        healthCardAndPinUrl: "",
        pinUrl: "www.gematik.de"
    )
}

extension OrderHealthCardView.ViewModel {
    static let dummyViewModel = OrderHealthCardView.ViewModel(
        insuranceCompanies: [OrderHealthCardView.HealthInsuranceCompany.dummyHealthInsuranceCompany],
        insuranceCompany: OrderHealthCardView.HealthInsuranceCompany.dummyHealthInsuranceCompany,
        serviceInquiry: .healthCardAndPin
    )
}