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

import ComposableArchitecture
import eRpKit
import eRpStyleKit
import Pharmacy
import SwiftUI

// swiftlint:disable file_length
struct PharmacyRedeemView: View {
    let store: PharmacyRedeemDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, PharmacyRedeemDomain.Action>
    static let height: CGFloat = {
        // Compensate display scaling (Settings -> Display & Brightness -> Display -> Standard vs. Zoomed
        // 245 is the standard height for the gif Display
        245 * UIScreen.main.scale / UIScreen.main.nativeScale
    }()

    init(store: PharmacyRedeemDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    var body: some View {
        VStack {
            ScrollView {
                HStack(alignment: .top, spacing: 0) {
                    if let url = videoURLforSource(.onPremise) {
                        LoopingVideoPlayerContainerView(withURL: url)
                            .frame(maxWidth: nil, maxHeight: Self.height)
                            .scaledToFill()
                    }
                }
                .cornerRadius(32, corners: [.bottomLeft, .bottomRight])

                VStack {
                    Text(L10n.phaRedeemTxtHeader)
                        .font(Font.title.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top)
                        .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemTxtTitle)

                    PharmacyView(pharmacy: viewStore.pharmacy) {
                        viewStore.send(.changePharmacy(viewStore.pharmacyState))
                    }

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
        }
        .alert(
            store.scope(state: \.$destination, action: PharmacyRedeemDomain.Action.destination),
            state: /PharmacyRedeemDomain.Destinations.State.alert,
            action: PharmacyRedeemDomain.Destinations.Action.alert
        )
        .task {
            await viewStore.send(.task).finish()
        }
        .navigationBarTitleDisplayMode(.inline)
        // Because of issues with Introspect only change the color when iOS 16 is available
        .backport.navigationBarToolBarBackground(color: Colors.gifBackground)
    }

    private func videoURLforSource(_ option: RedeemOption) -> URL? {
        var videoName = ""

        switch option {
        case .onPremise:
            videoName = "animation_reservierung"
        case .delivery:
            videoName = "animation_botendienst"
        case .shipment:
            videoName = "animation_versand"
        }

        guard let bundle = Bundle.main.path(forResource: videoName,
                                            ofType: "mp4") else {
            return nil
        }

        return URL(fileURLWithPath: bundle)
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
                        PharmacyRedeemView.ProfileIcon(profile: profile)
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

    struct PharmacyView: View {
        let pharmacy: PharmacyLocation?
        let action: () -> Void

        var body: some View {
            SingleElementSectionContainer(header: {
                Text(L10n.phaRedeemTxtPharmacyHeader)
            }, content: {
                if let pharmacy = pharmacy {
                    Button(action: action) {
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                if let name = pharmacy.name {
                                    Text(name)
                                        .padding(.bottom, 4)
                                        .font(Font.body)
                                        .foregroundColor(Colors.systemLabel)
                                        .accessibilityIdentifier(A11y.pharmacyRedeem.phaRedeemTxtEditPharmacyName)
                                }
                                if let address = pharmacy.address?.fullAddressBreak {
                                    Text(address)
                                        .font(Font.subheadline)
                                        .foregroundColor(Colors.systemLabelSecondary)
                                        .accessibilityIdentifier(A11y.pharmacyRedeem.phaRedeemTxtEditPharmacyAdress)
                                }
                            }
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Text(L10n.phaRedeemBtnChangePharmacy)
                                .font(Font.subheadline.weight(.semibold))
                                .padding(.leading)
                                .multilineTextAlignment(.trailing)
                                .fixedSize(horizontal: true, vertical: false)
                                .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemTxtEditPharmacy)
                        }.padding()
                    }
                    .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemBtnEditPharmacy)
                } else {
                    VStack(spacing: 16) {
                        Text(L10n.phaRedeemTxtSelectPharamcy)
                            .padding(.top)
                            .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemTxtAddPharmacy)

                        Button(L10n.phaRedeemBtnSelectPharmacy, action: action)
                            .buttonStyle(.secondaryAlt)
                            .padding(.bottom)
                            .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemBtnAddPharmacy)
                    }
                }
            }).sectionContainerStyle(.bordered)
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
                                PharmacyRedeemView.ProfileIcon(profile: profile)
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
                    .buttonStyle(.plain)
                    .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemBtnEditAddress)
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
                    if !viewStore.prescriptions.isEmpty {
                        Button(action: {
                            viewStore.send(.setNavigation(tag: .prescriptionSelection))
                        }, label: {
                            HStack(spacing: 0) {
                                VStack(alignment: .leading) {
                                    Text("\(viewStore.prescriptions.count) " + L10n.phaRedeemTxtPrescription.text)
                                        .font(Font.body)
                                        .padding(.bottom)
                                        .foregroundColor(Colors.systemLabel)

                                    Text(viewStore.prescriptions.map(\.title).joined(separator: ", "))
                                        .font(Font.subheadline)
                                        .foregroundColor(Colors.systemLabelSecondary)
                                        .lineLimit(1)
                                }
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Text(L10n.phaRedeemBtnChangePrescription)
                                    .font(Font.subheadline.weight(.semibold))
                                    .multilineTextAlignment(.trailing)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .padding(.leading)
                                    .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemTxtEditPrescription)
                            }
                            .padding()
                        })
                            .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemBtnEditPrescription)
                    } else {
                        VStack(spacing: 16) {
                            Text(L10n.phaRedeemTxtSelectPrescription)
                                .padding(.top)
                                .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemTxtAddPrescription)

                            Button(L10n.phaRedeemBtnSelectPrescription) {
                                viewStore.send(.setNavigation(tag: .prescriptionSelection))
                            }
                            .buttonStyle(.secondaryAlt)
                            .padding(.bottom)
                            .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemBtnAddPrescription)
                        }
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
                    .padding(.bottom)
                } else {
                    LoadingPrimaryButton(text: L10n.phaRedeemBtnRedeem,
                                         isLoading: viewStore.requests.inProgress) {
                        viewStore.send(.redeem)
                    }
                    .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemBtnRedeem)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
    }

    struct RedeemNavigation: ViewModifier {
        let store: PharmacyRedeemDomain.Store
        @ObservedObject var viewStore: ViewStore<ViewState, PharmacyRedeemDomain.Action>

        init(store: PharmacyRedeemDomain.Store) {
            self.store = store
            viewStore = ViewStore(store, observe: ViewState.init)
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

                NavigationLinkStore(
                    store.scope(state: \.$destination, action: PharmacyRedeemDomain.Action.destination),
                    state: /PharmacyRedeemDomain.Destinations.State.redeemSuccess,
                    action: PharmacyRedeemDomain.Destinations.Action.redeemSuccessView(action:),
                    onTap: { viewStore.send(.setNavigation(tag: .redeemSuccess)) },
                    destination: RedeemSuccessView.init(store:),
                    label: {}
                )
                .hidden()
                .accessibility(hidden: true)

                NavigationLinkStore(
                    store.scope(state: \.$destination, action: PharmacyRedeemDomain.Action.destination),
                    state: /PharmacyRedeemDomain.Destinations.State.prescriptionSelection,
                    action: PharmacyRedeemDomain.Destinations.Action.prescriptionSelection(action:),
                    onTap: { viewStore.send(.setNavigation(tag: .prescriptionSelection)) },
                    destination: PharmacyPrescriptionSelectionView.init(store:),
                    label: {}
                )
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
                                store.scope(state: \.$destination, action: PharmacyRedeemDomain.Action.destination),
                                state: /PharmacyRedeemDomain.Destinations.State.cardWall,
                                action: PharmacyRedeemDomain.Destinations.Action.cardWall(action:),
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
                        store.scope(state: \.$destination, action: PharmacyRedeemDomain.Action.destination),
                        state: /PharmacyRedeemDomain.Destinations.State.contact,
                        action: PharmacyRedeemDomain.Destinations.Action.pharmacyContact(action:),
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
        let pharmacyState: PharmacyRedeemDomain.State

        init(state: PharmacyRedeemDomain.State) {
            redeemType = state.redeemOption
            pharmacy = state.pharmacy
            prescriptions = state.selectedErxTasks.map { Prescription($0) }
            shipmentInfo = state.selectedShipmentInfo
            requests = state.orderResponses
            profile = state.profile
            pharmacyState = state
        }

        var isRedeemButtonEnabled: Bool {
            prescriptions != []
        }

        struct Prescription: Equatable, Identifiable {
            var id: String { taskID }
            let taskID: String
            let title: String

            init(_ task: ErxTask) {
                taskID = task.id
                title = task.medication?.displayName ?? L10n.prscFdTxtNa.text
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
