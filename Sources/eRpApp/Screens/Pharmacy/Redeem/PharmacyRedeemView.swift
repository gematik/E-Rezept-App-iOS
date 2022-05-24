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
import eRpStyleKit
import Pharmacy
import SwiftUI

struct PharmacyRedeemView: View {
    let store: PharmacyRedeemDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, PharmacyRedeemDomain.Action>

    init(store: PharmacyRedeemDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical) {
                VStack {
                    Text(L10n.phaRedeemTxtSubtitle("**\(viewStore.pharmacy.name ?? "")**"))
                        .font(Font.subheadline)
                        .multilineTextAlignment(.center)
                        .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemTxtSubtitle)

                    if let shipmentInfo = viewStore.shipmentInfo {
                        AddressView(
                            shipmentInfo: shipmentInfo,
                            redeemOption: viewStore.redeemType,
                            profile: viewStore.profile
                        ) {
                            viewStore.send(.showPharmacyContact)
                        }
                    } else {
                        MissingAddressView(profile: viewStore.profile) {
                            viewStore.send(.showPharmacyContact)
                        }
                    }
                    PrescriptionView(viewStore: viewStore)
                }
            }

            Spacer()

            RedeemButton(viewStore: viewStore)
                .alert(
                    self.store.scope(state: \.alertState),
                    dismiss: .alertDismissButtonTapped
                )

            RedeemSuccessViewPresentation(store: store).accessibility(hidden: true)
        }
        .onAppear {
            viewStore.send(.registerSelectedShipmentInfoListener)
            viewStore.send(.registerSelectedProfileListener)
        }
        .navigationTitle(L10n.phaRedeemTitle)
        .navigationBarItems(
            trailing: NavigationBarCloseItem { viewStore.send(.close) }
        )
        .navigationBarTitleDisplayMode(.inline)
        .introspectNavigationController { navigationController in
            let navigationBar = navigationController.navigationBar
            navigationBar.barTintColor = UIColor(Colors.systemBackground)
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.shadowColor = UIColor(Colors.systemColorClear)
            navigationBarAppearance.backgroundColor = UIColor(Colors.systemBackground)
            navigationBar.standardAppearance = navigationBarAppearance
        }
        .fullScreenCover(isPresented: viewStore.binding(
            get: { $0.showPharmacyContact },
            send: PharmacyRedeemDomain.Action.dismissPharmacyContactView
        )) {
            IfLetStore(
                store.scope(
                    state: { $0.pharmacyContactState },
                    action: PharmacyRedeemDomain.Action.pharmacyContact(action:)
                ),
                then: PharmacyContactView.init(store:)
            )
        }
    }
}

extension PharmacyRedeemView {
    struct MissingAddressView: View {
        let profile: Profile?
        let action: () -> Void
        var body: some View {
            SingleElementSectionContainer(header: {
                SectionHeaderView(
                    text: L10n.phaRedeemTxtAddress,
                    a11y: A11y.pharmacyRedeem.phaRedeemTxtAddressTitle
                )
            }, content: {
                VStack(spacing: 16) {
                    HStack(alignment: .top, spacing: 0) {
                        ProfileIcon(profile: profile)
                            .padding(.trailing)
                        Text(L10n.phaRedeemTxtMissingAddress)
                            .accessibilityIdentifier(A11y.pharmacyRedeem.phaRedeemTxtMissingAddress)
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    Button(L10n.phaRedeemBtnAddAddress, action: action)
                        .buttonStyle(.secondaryAlt)
                        .padding(.bottom)
                        .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemBtnAddAddress)
                }

            })
                .sectionContainerStyle(.bordered)
        }
    }

    struct ProfileIcon: View {
        let profile: Profile?
        var body: some View {
            if let profile = profile {
                InitialsImage(profile: profile)
                    .frame(width: 40, height: 40, alignment: .center)
            } else {
                Image(systemName: SFSymbolName.house)
                    .font(Font.title3.weight(.bold))
            }
        }
    }

    struct AddressView: View {
        let shipmentInfo: ShipmentInfo
        let redeemOption: RedeemOption
        let profile: Profile?
        let action: () -> Void
        var body: some View {
            SingleElementSectionContainer(
                header: {
                    SectionHeaderView(text: L10n.phaRedeemTxtAddress,
                                      a11y: A11y.pharmacyRedeem.phaRedeemTxtAddressTitle)
                },
                content: {
                    Button(action: action) {
                        VStack(spacing: 16) {
                            HStack(alignment: .top, spacing: 16) {
                                ProfileIcon(profile: profile)
                                VStack(alignment: .leading) {
                                    HStack {
                                        if let name = shipmentInfo.name {
                                            Text(name)
                                                .font(Font.subheadline.weight(.semibold))
                                                .padding(.bottom, 8)
                                                .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemAddressName)
                                        }

                                        Spacer()
                                        Image(systemName: SFSymbolName.squareAndPencil)
                                            .font(Font.body.weight(.semibold))
                                            .foregroundColor(Colors.systemLabelSecondary)
                                    }

                                    if let street = shipmentInfo.street {
                                        Text(street)
                                            .font(.subheadline)
                                            .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemAddressStreet)
                                    }
                                    if let addressDetail = shipmentInfo.addressDetail {
                                        Text(addressDetail)
                                            .font(.subheadline)
                                            .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemAddressDetail)
                                    }
                                    HStack {
                                        if let zip = shipmentInfo.zip {
                                            Text(zip)
                                                .font(.subheadline)
                                                .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemAddressZip)
                                        }
                                        if let city = shipmentInfo.city {
                                            Text(city)
                                                .font(.subheadline)
                                                .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemAddressCity)
                                        }
                                    }
                                    if let phone = shipmentInfo.phone {
                                        HStack {
                                            Image(systemName: SFSymbolName.phone)
                                                .font(Font.footnote.weight(.semibold))
                                                .foregroundColor(Colors.systemLabelSecondary)
                                            Text(phone)
                                                .font(.subheadline)
                                        }
                                        .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemAddressPhone)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(RoundedRectangle(cornerRadius: 8)
                                            .fill(Colors.systemBackgroundSecondary))
                                    }
                                    if let mail = shipmentInfo.mail {
                                        HStack {
                                            Image(systemName: SFSymbolName.mail)
                                                .font(Font.footnote.weight(.semibold))
                                                .foregroundColor(Colors.systemLabelSecondary)
                                            Text(mail)
                                                .font(.subheadline)
                                        }
                                        .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemAddressMail)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(RoundedRectangle(cornerRadius: 8)
                                            .fill(Colors.systemBackgroundSecondary))
                                    }
                                    if let deliveryInfo = shipmentInfo.deliveryInfo {
                                        Text(deliveryInfo)
                                            .font(Font.subheadline)
                                            .foregroundColor(Colors.systemLabelSecondary)
                                            .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemAddressInfo)
                                    }
                                }
                                .fixedSize(horizontal: false, vertical: true)
                            }
                            if shipmentInfo.phone == nil && redeemOption.isPhoneRequired {
                                Text(L10n.phaRedeemTxtMissingPhone)
                                    .font(Font.body.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 52, alignment: .center)
                                    .background(Colors.red100)
                                    .foregroundColor(Colors.red900)
                                    .cornerRadius(16)
                                    .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemTxtMissingPhone)
                            }
                        }
                    }
                    .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemBtnEditAddress)
                    .buttonStyle(.plain)
                    .padding()
                }
            )
            .sectionContainerStyle(.bordered)
        }
    }

    struct PrescriptionView: View {
        @State var viewStore: ViewStore<ViewState, PharmacyRedeemDomain.Action>
        var body: some View {
            SingleElementSectionContainer(
                header: {
                    SectionHeaderView(text: L10n.phaRedeemTxtPrescription,
                                      a11y: A11y.pharmacyRedeem.phaRedeemTxtPrescriptionTitle)
                },
                content: {
                    ForEach(viewStore.prescriptions.indices) { index in
                        Button(action: { viewStore.send(.didSelect(viewStore.prescriptions[index].taskID)) },
                               label: {
                                   TitleWithSubtitleCellView(
                                       title: viewStore.prescriptions[index].title,
                                       subtitle: viewStore.prescriptions[index].subtitle,
                                       isSelected: viewStore.prescriptions[index].isSelected
                                   )
                               })
                            .sectionContainerIsLastElement(index == viewStore.prescriptions.count - 1)
                    }
                }
            )
            .sectionContainerStyle(.bordered)
        }
    }

    struct RedeemButton: View {
        @State var viewStore: ViewStore<ViewState, PharmacyRedeemDomain.Action>
        var body: some View {
            VStack(spacing: 8) {
                GreyDivider()

                if !viewStore.isRedeemButtonEnabled {
                    PrimaryTextButton(text: L10n.phaRedeemBtnRedeem,
                                      a11y: A11y.pharmacyRedeem.phaRedeemBtnRedeem,
                                      isEnabled: viewStore.isRedeemButtonEnabled) {
                        viewStore.send(.redeem)
                    }
                    .padding(.horizontal)
                } else {
                    LoadingPrimaryButton(text: L10n.phaRedeemBtnRedeem,
                                         isLoading: viewStore.loadingState.isLoading) {
                        viewStore.send(.redeem)
                    }
                    .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemBtnRedeem)
                    .padding(.horizontal)
                }

                Text(L10n.phaRedeemBtnRedeemFootnote)
                    .font(.footnote)
                    .foregroundColor(Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemBtnRedeemFootnote)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
    }

    struct RedeemSuccessViewPresentation: View {
        let store: PharmacyRedeemDomain.Store
        var body: some View {
            WithViewStore(self.store) { viewStore in
                NavigationLink(destination: IfLetStore(
                    store.scope(
                        state: { $0.successViewState },
                        action: PharmacyRedeemDomain.Action.redeemSuccessView(action:)
                    ),
                    then: RedeemSuccessView.init(store:)
                ),
                isActive: viewStore.binding(
                    get: { $0.successViewState != nil },
                    send: PharmacyRedeemDomain.Action.dismissRedeemSuccessView
                )) {
                    EmptyView()
                }
            }
        }
    }
}

extension PharmacyRedeemView {
    struct ViewState: Equatable {
        let redeemType: RedeemOption
        let pharmacy: PharmacyLocation
        let prescriptions: [Prescription]
        let shipmentInfo: ShipmentInfo?
        let loadingState: LoadingState<Bool, ErxRepositoryError>
        let profile: Profile?
        let showPharmacyContact: Bool

        init(state: PharmacyRedeemDomain.State) {
            redeemType = state.redeemOption
            pharmacy = state.pharmacy
            prescriptions = state.erxTasks.map {
                let isSelected = state.selectedErxTasks.contains($0)
                return Prescription($0, isSelected: isSelected)
            }
            shipmentInfo = state.selectedShipmentInfo
            loadingState = state.loadingState
            profile = state.profile
            showPharmacyContact = state.pharmacyContactState != nil
        }

        var isRedeemButtonEnabled: Bool {
            prescriptions.first { $0.isSelected == true } != nil
        }

        struct Prescription: Equatable, Identifiable {
            var id: String { taskID } // swiftlint:disable:this identifier_name
            let taskID: String
            let title: String
            let subtitle: String
            var isSelected = false

            init(_ task: ErxTask, isSelected: Bool) {
                taskID = task.id
                title = task.medication?.name ?? L10n.prscFdTxtNa.text
                subtitle = task
                    .substitutionAllowed ? L10n.phaRedeemTxtPrescriptionSub.text : ""
                self.isSelected = isSelected
            }
        }
    }
}

extension RedeemOption {
    var localizedString: LocalizedStringKey {
        switch self {
        case .onPremise: return L10n.phaRedeemTxtTitleReservation.key
        case .delivery: return L10n.phaRedeemTxtTitleDelivery.key
        case .shipment: return L10n.phaRedeemTxtTitleMail.key
        }
    }

    var isPhoneRequired: Bool {
        switch self {
        case .onPremise: return false
        case .delivery, .shipment: return true
        }
    }
}

extension InitialsImage {
    init(profile: Profile) {
        self.init(
            backgroundColor: profile.color.viewModelColor.background,
            text: profile.emoji ?? profile.name.acronym(),
            size: .extraLarge
        )
    }
}

struct ReservationView_Previews: PreviewProvider {
    static var previews: some View {
        PharmacyRedeemView(store: PharmacyRedeemDomain.Dummies.store)
    }
}
