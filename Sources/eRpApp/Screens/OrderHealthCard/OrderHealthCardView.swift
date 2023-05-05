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

import ComposableArchitecture
import eRpKit
import SwiftUI

struct OrderHealthCardView: View {
    let store: OrderHealthCardDomain.Store

    struct ViewState: Equatable {
        var insuranceCompanies: [OrderHealthCardDomain.HealthInsuranceCompany]
        var insuranceCompany: OrderHealthCardDomain.HealthInsuranceCompany?
        var serviceInquiry: OrderHealthCardDomain.ServiceInquiry?
        var serviceInquiryId: Int
        var textColor: Color
        let routeTag: OrderHealthCardDomain.Destinations.State.Tag?

        init(state: OrderHealthCardDomain.State) {
            insuranceCompanies = state.insuranceCompanies
            insuranceCompany = state.insuranceCompany
            serviceInquiry = state.serviceInquiry
            serviceInquiryId = state.serviceInquiryId
            textColor = state.insuranceCompany != nil ? Colors.systemLabel : Colors.primary700
            routeTag = state.destination?.tag
        }
    }

    var body: some View {
        WithViewStore(store.scope(state: ViewState.init)) { viewStore in
            ScrollView(showsIndicators: true) {
                ContentStruct(store: store)

                if let insuranceCompany = viewStore.insuranceCompany {
                    if insuranceCompany.hasContactInformation == false {
                        Section(header: HintView(hint: hint)) { EmptyView() }
                            .textCase(.none)
                    } else {
                        if insuranceCompany.serviceInquiryOptions.count > 1 {
                            Section(
                                header: SectionHeaderView(
                                    text: L10n.orderEgkTxtPickerServiceHeader,
                                    a11y: A11y.orderEGK.ogkTxtServiceSelectionHeader
                                ).padding([.bottom, .top], 8)
                            ) {
                                Button(action: {
                                    viewStore.send(.setNavigation(tag: .serviceInquiry))
                                }, label: {
                                    Text(viewStore.serviceInquiry?.localizedName ?? L10n.orderEgkTxtPickerServiceLabel
                                        .key).foregroundColor(viewStore.textColor)
                                    Spacer()
                                    Image(systemName: SFSymbolName.chevronRight)
                                        .padding(0)
                                        .foregroundColor(viewStore.textColor)
                                })
                                NavigationLink(
                                    destination:
                                    OrderHealthCardInquiryOptionsView(
                                        availableInquiries: insuranceCompany.serviceInquiryOptions,
                                        selectedInquiry: viewStore.binding(
                                            get: \.serviceInquiryId
                                        ) { newID in
                                            .setService(service: newID)
                                        }
                                    ),
                                    tag: OrderHealthCardDomain.Destinations.State.Tag.serviceInquiry,
                                    selection: viewStore.binding(
                                        get: \.routeTag
                                    ) {
                                        .setNavigation(tag: $0)
                                    }
                                ) {
                                    EmptyView()
                                }
                            }
                            .textCase(.none)
                        }

                        if let serviceInquiry = viewStore.serviceInquiry {
                            Section(
                                header: SectionHeaderView(
                                    text: L10n.orderEgkTxtSectionContactInsurance,
                                    a11y: A11y.orderEGK.ogkTxtContactCompanyHeader
                                ).padding([.bottom, .top], 8),
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
            .onAppear {
                viewStore.send(.loadList)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: NavigationBarCloseItem {
                    viewStore.send(.delegate(.close))
                }
                .accessibility(identifier: A11y.orderEGK.ogkBtnCancel)
                .accessibility(label: Text(L10n.cdwBtnCanCancelLabel))
            )
        }
    }

    private let hint = Hint<String>(
        id: A11y.orderEGK.ogkTxtNoSelectionHint,
        title: L10n.orderEgkTxtHintNoContactOptionTitle.text,
        message: L10n.orderEgkTxtHintNoContactOptionMessage.text,
        actionText: nil,
        action: nil,
        image: .init(name: Asset.Illustrations.arztRedCircle.name),
        closeAction: nil,
        style: .important,
        buttonStyle: .tertiary,
        imageStyle: .topAligned
    )
}

extension OrderHealthCardView {
    struct ContentStruct: View {
        let store: OrderHealthCardDomain.Store

        struct ViewState: Equatable {
            var insuranceCompanies: [OrderHealthCardDomain.HealthInsuranceCompany]
            var insuranceCompany: OrderHealthCardDomain.HealthInsuranceCompany?
            var textColor: Color
            let routeTag: OrderHealthCardDomain.Destinations.State.Tag?

            init(state: OrderHealthCardDomain.State) {
                insuranceCompanies = state.insuranceCompanies
                insuranceCompany = state.insuranceCompany
                textColor = state.insuranceCompany != nil ? Colors.systemLabel : Colors.primary700
                routeTag = state.destination?.tag
            }
        }

        var body: some View {
            WithViewStore(store.scope(state: ViewState.init)) { viewStore in
                VStack {
                    Section(header: OrderHealthCardView.Header()) {}
                        .textCase(.none)

                    Section(
                        header: SectionHeaderView(
                            text: L10n.orderEgkTxtPickerInsuranceHeader,
                            a11y: A11y.orderEGK.ogkTxtServiceSelectionHeader
                        ).padding(.bottom, 8)
                    ) {
                        Button(action: {
                            viewStore.send(.setNavigation(tag: .searchPicker))
                        }, label: {
                            HStack {
                                Text(
                                    viewStore.insuranceCompany?.name ?? L10n.orderEgkTxtPickerInsurancePlaceholder
                                        .text
                                )
                                .foregroundColor(viewStore.textColor)
                                Spacer()
                                Image(systemName: SFSymbolName.chevronRight)
                                    .padding(0)
                                    .foregroundColor(viewStore.textColor)
                            }
                        })
                        NavigationLink(
                            destination:
                            OrderHealthCardView.PickerSearch(store: store),
                            tag: OrderHealthCardDomain.Destinations.State.Tag.searchPicker,
                            selection: viewStore.binding(
                                get: \.routeTag
                            ) {
                                .setNavigation(tag: $0)
                            }
                        ) {
                            EmptyView()
                        }
                    }
                    .textCase(.none)
                }
            }
        }
    }

    struct PickerSearch: View {
        let store: OrderHealthCardDomain.Store

        struct ViewState: Equatable {
            var insuranceCompanies: [OrderHealthCardDomain.HealthInsuranceCompany]
            var searchText: String
            var searchHealthInsurance = [OrderHealthCardDomain.HealthInsuranceCompany]()

            init(state: OrderHealthCardDomain.State) {
                insuranceCompanies = state.insuranceCompanies
                searchText = state.searchText
                searchHealthInsurance = state.searchHealthInsurance
            }
        }

        var body: some View {
            WithViewStore(store.scope(state: ViewState.init)) { viewStore in
                VStack {
                    SearchBar(
                        searchText: viewStore.binding(
                            get: \.searchText
                        ) { newText in
                            .updateSearchText(newPrompt: newText)
                        },
                        prompt: L10n.orderEgkTxtSearchPrompt.key
                    ) {
                        viewStore.send(.searchList)
                    }
                    .padding()

                    List {
                        if !viewStore.searchHealthInsurance.isEmpty {
                            ForEach(viewStore.searchHealthInsurance) { insurance in
                                Button(insurance.name) {
                                    viewStore.send(.selectHealthInsurance(id: insurance.id))
                                }
                            }
                        } else {
                            VStack {
                                Text(L10n.phaSearchTxtNoResultsTitle)
                                    .font(.headline)
                                    .padding(.bottom, 1)
                                Text(L10n.phaSearchTxtNoResults)
                                    .font(.subheadline)
                                    .foregroundColor(Colors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }.listStyle(PlainListStyle())
                }.onAppear {
                    viewStore.send(.resetList)
                }
                .onChange(of: viewStore.searchText) { _ in
                    if viewStore.searchText.isEmpty {
                        viewStore.send(.resetList)
                    }
                }
            }
        }
    }

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
                    }.multilineTextAlignment(.trailing)
                }
            }
        }
    }
}

extension ContactOptionsRowView {
    init(
        healthInsuranceCompany: OrderHealthCardDomain.HealthInsuranceCompany,
        serviceInquiry: OrderHealthCardDomain.ServiceInquiry
    ) {
        switch serviceInquiry {
        case .pin:
            self.init(
                phone: healthInsuranceCompany.healthCardAndPinPhone,
                web: healthInsuranceCompany.pinUrl,
                email: healthInsuranceCompany.createEmailUrl(for: .pin)
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
            OrderHealthCardView(store: OrderHealthCardDomain.Dummies.store)
        }
        NavigationView {
            OrderHealthCardView(store: OrderHealthCardDomain.Dummies.store)
        }
    }
}
