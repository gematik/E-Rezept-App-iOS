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
                        .padding([.horizontal, .top])
                        .font(Font.subheadline)
                        .multilineTextAlignment(.center)
                        .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemTxtSubtitle)

                    if let shipmentInfo = viewStore.shipmentInfo {
                        AddressView(
                            shipmentInfo: shipmentInfo,
                            redeemOption: viewStore.redeemType,
                            profile: viewStore.profile
                        ) {
                            viewStore.send(.setNavigation(tag: .contact))
                        }
                    } else {
                        MissingAddressView(profile: viewStore.profile) {
                            viewStore.send(.setNavigation(tag: .contact))
                        }
                    }
                    PrescriptionView(viewStore: viewStore)
                }
            }
            .redeemNavigation(for: store)

            Spacer()

            RedeemButton(viewStore: viewStore)
                .alert(
                    store.destinationsScope(state: /PharmacyRedeemDomain.Destinations.State.alert),
                    dismiss: .setNavigation(tag: .none)
                )
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
    }
}

extension PharmacyRedeemView {
    struct MissingAddressView: View {
        let profile: Profile?
        let action: () -> Void
        var body: some View {
            SingleElementSectionContainer(header: {
                Label(L10n.phaRedeemTxtAddress)
                    .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemTxtAddressTitle)
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
                ProfilePictureView(profile: profile)
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
                    Label(L10n.phaRedeemTxtAddress)
                        .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemTxtAddressTitle)
                },
                content: {
                    Button(action: action) {
                        VStack(spacing: 16) {
                            HStack(alignment: .top, spacing: 16) {
                                ProfileIcon(profile: profile)
                                VStack(alignment: .leading) {
                                    HStack(spacing: 0) {
                                        if let name = shipmentInfo.name {
                                            Text(name)
                                                .font(Font.body.weight(.semibold))
                                                .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemAddressName)
                                        }

                                        Spacer()
                                        Image(systemName: SFSymbolName.squareAndPencil)
                                            .font(Font.body.weight(.semibold))
                                            .foregroundColor(Colors.systemLabelSecondary)
                                    }.padding(.bottom, 1)

                                    if let street = shipmentInfo.street {
                                        Text(street)
                                            .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemAddressStreet)
                                    }
                                    if let addressDetail = shipmentInfo.addressDetail {
                                        Text(addressDetail)
                                            .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemAddressDetail)
                                    }
                                    HStack {
                                        if let zip = shipmentInfo.zip {
                                            Text(zip)
                                                .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemAddressZip)
                                        }
                                        if let city = shipmentInfo.city {
                                            Text(city)
                                                .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemAddressCity)
                                        }
                                    }
                                    if let phone = shipmentInfo.phone {
                                        HStack {
                                            Image(systemName: SFSymbolName.phone)
                                                .font(Font.subheadline.weight(.semibold))
                                                .foregroundColor(Colors.systemLabelSecondary)
                                            Text(phone)
                                        }
                                        .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemAddressPhone)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(RoundedRectangle(cornerRadius: 8)
                                            .fill(Colors.systemBackgroundSecondary))
                                    }
                                    if let mail = shipmentInfo.mail {
                                        HStack {
                                            Image(systemName: SFSymbolName.envelope)
                                                .font(Font.subheadline.weight(.semibold))
                                                .foregroundColor(Colors.systemLabelSecondary)
                                            Text(mail)
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
                            if shipmentInfo.phone == nil, redeemOption.isPhoneRequired {
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
        @ObservedObject var viewStore: ViewStore<ViewState, PharmacyRedeemDomain.Action>
        var body: some View {
            SingleElementSectionContainer(
                header: {
                    Label(L10n.phaRedeemTxtPrescription)
                        .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemTxtPrescriptionTitle)
                },
                content: {
                    ForEach(viewStore.prescriptions.indices, id: \.self) { index in
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
        @ObservedObject var viewStore: ViewStore<ViewState, PharmacyRedeemDomain.Action>
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
                                         isLoading: viewStore.requests.inProgress) {
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

    struct RedeemNavigation: ViewModifier {
        let store: PharmacyRedeemDomain.Store
        @ObservedObject var viewStore: ViewStore<ViewState, PharmacyRedeemDomain.Action>

        init(store: PharmacyRedeemDomain.Store) {
            self.store = store
            viewStore = ViewStore(store.scope(state: ViewState.init))
        }

        struct ViewState: Equatable {
            let destinationTag: PharmacyRedeemDomain.Destinations.State.Tag?

            init(state: PharmacyRedeemDomain.State) {
                destinationTag = state.destination?.tag
            }
        }

        // swiftlint:disable:next function_body_length
        func body(content: Content) -> some View {
            Group {
                content

                NavigationLink(
                    destination: IfLetStore(
                        store.destinationsScope(
                            state: /PharmacyRedeemDomain.Destinations.State.redeemSuccess,
                            action: PharmacyRedeemDomain.Destinations.Action.redeemSuccessView(action:)
                        ),
                        then: RedeemSuccessView.init(store:)
                    ),
                    tag: PharmacyRedeemDomain.Destinations.State.Tag.redeemSuccess,
                    selection: viewStore.binding(get: \.destinationTag) { .setNavigation(tag: $0) }
                ) {}
                    .hidden()
                    .accessibility(hidden: true)

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .fullScreenCover(
                        isPresented: Binding<Bool>(
                            get: { viewStore.destinationTag == .cardWall },
                            set: { show in
                                if !show {
                                    viewStore.send(.setNavigation(tag: nil))
                                }
                            }
                        ),
                        onDismiss: {},
                        content: {
                            IfLetStore(
                                store.destinationsScope(
                                    state: /PharmacyRedeemDomain.Destinations.State.cardWall,
                                    action: PharmacyRedeemDomain.Destinations.Action.cardWall(action:)
                                ),
                                then: CardWallIntroductionView.init(store:)
                            )
                        }
                    )
                    .accessibility(hidden: true)
                    .hidden()
            }
            .fullScreenCover(
                isPresented: Binding<Bool>(
                    get: { viewStore.state.destinationTag == .contact },
                    set: { show in
                        if !show {
                            viewStore.send(.setNavigation(tag: nil))
                        }
                    }
                ),
                onDismiss: {},
                content: {
                    IfLetStore(
                        store.destinationsScope(
                            state: /PharmacyRedeemDomain.Destinations.State.contact,
                            action: PharmacyRedeemDomain.Destinations.Action.pharmacyContact(action:)
                        ),
                        then: PharmacyContactView.init(store:)
                    )
                }
            )
        }
    }
}

extension View {
    func redeemNavigation(for store: PharmacyRedeemDomain.Store) -> some View {
        modifier(
            PharmacyRedeemView.RedeemNavigation(store: store)
        )
    }
}

extension PharmacyRedeemView {
    struct ViewState: Equatable {
        let redeemType: RedeemOption
        let pharmacy: PharmacyLocation
        let prescriptions: [Prescription]
        let shipmentInfo: ShipmentInfo?
        let requests: IdentifiedArrayOf<OrderResponse>
        let profile: Profile?

        init(state: PharmacyRedeemDomain.State) {
            redeemType = state.redeemOption
            pharmacy = state.pharmacy
            prescriptions = state.erxTasks.map {
                let isSelected = state.selectedErxTasks.contains($0)
                return Prescription($0, isSelected: isSelected)
            }
            shipmentInfo = state.selectedShipmentInfo
            requests = state.orderResponses
            profile = state.profile
        }

        var isRedeemButtonEnabled: Bool {
            prescriptions.first { $0.isSelected == true } != nil
        }

        struct Prescription: Equatable, Identifiable {
            var id: String { taskID }
            let taskID: String
            let title: String
            let subtitle: String
            var isSelected = false

            init(_ task: ErxTask, isSelected: Bool) {
                taskID = task.id
                title = task.medication?.displayName ?? L10n.prscFdTxtNa.text
                subtitle = task
                    .medicationRequest.substitutionAllowed ? L10n.phaRedeemTxtPrescriptionSub.text : ""
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

extension ProfilePictureView {
    init(profile: Profile) {
        self.init(
            image: profile.image.viewModelPicture,
            userImageData: profile.userImageData,
            color: profile.color.viewModelColor,
            connection: nil,
            style: .small
        ) {}
    }
}

struct PharmacyRedeemView_Previews: PreviewProvider {
    static var previews: some View {
        PharmacyRedeemView(store: PharmacyRedeemDomain.Dummies.store)
    }
}
