// swiftlint:disable file_length
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

import ComposableArchitecture
import eRpKit
import eRpStyleKit
import Perception
import Pharmacy
import SwiftUI
import SwiftUIIntrospect

struct PharmacyRedeemView: View {
    @Perception.Bindable var store: StoreOf<PharmacyRedeemDomain>
    static let height: CGFloat = {
        // Compensate display scaling (Settings -> Display & Brightness -> Display -> Standard vs. Zoomed
        // 245 is the standard height for the gif Display
        245 * UIScreen.main.scale / UIScreen.main.nativeScale
    }()

    init(store: StoreOf<PharmacyRedeemDomain>) {
        self.store = store
    }

    var body: some View {
        WithPerceptionTracking {
            VStack {
                ScrollView {
                    HStack(alignment: .top, spacing: 0) {
                        if let redeemOption = store.serviceOptionState.selectedOption,
                           let url = videoURLforSource(redeemOption) {
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

                        PrescriptionView(store: store)

                        PharmacyView(pharmacy: store.pharmacy) {
                            store.send(.delegate(.changePharmacy))
                        }

                        if store.pharmacy != nil {
                            ServiceOptionView(store: store.scope(
                                state: \.serviceOptionState,
                                action: \.serviceOption
                            ))
                                .padding(.horizontal)
                        }

                        if let shipmentInfo = store.selectedShipmentInfo {
                            AddressView(
                                shipmentInfo: shipmentInfo,
                                redeemOption: store.serviceOptionState.selectedOption,
                                hasCompleteContactData: store.hasCompleteContactData,
                                profile: store.profile
                            ) { store.send(.showContact) }
                        } else {
                            MissingAddressView(profile: store.profile) {
                                store.send(.showContact)
                            }
                        }
                    }
                }
                .navigationDestination(
                    item: $store.scope(
                        state: \.destination?.redeemSuccess,
                        action: \.destination.redeemSuccess
                    )
                ) { store in
                    RedeemSuccessView(store: store)
                }
                .navigationDestination(
                    item: $store.scope(
                        state: \.destination?.contact,
                        action: \.destination.contact
                    )
                ) { store in
                    PharmacyContactView(store: store)
                }
                .navigationDestination(
                    item: $store.scope(
                        state: \.destination?.prescriptionSelection,
                        action: \.destination.prescriptionSelection
                    )
                ) { store in
                    PharmacyPrescriptionSelectionView(store: store)
                }
                .alert($store.scope(
                    state: \.destination?.alert?.alert,
                    action: \.destination.alert
                ))

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .fullScreenCover(item: $store.scope(
                        state: \.destination?.cardWall,
                        action: \.destination.cardWall
                    )) { store in
                        CardWallIntroductionView(store: store)
                    }
                    .accessibility(hidden: true)

                Spacer()

                RedeemButton(store: store)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationBarCloseItem { store.send(.delegate(.close)) }
                }
            }
            .task {
                await store.send(.task).finish()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible)
            .toolbarBackground(
                store.serviceOptionState.selectedOption != nil ? Colors.gifBackground : Colors.systemBackground,
                for: .navigationBar
            )
        }
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
        guard let bundle = Bundle.module.path(forResource: videoName, ofType: "mp4")
        else { return nil }
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
        let redeemOption: RedeemOption?
        let hasCompleteContactData: Bool
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
                                    .disabled(true) // Disable profile button tap
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
                            .contentShape(Rectangle())

                            if !hasCompleteContactData, redeemOption != nil {
                                Text(L10n.phaRedeemTxtMissingContactData)
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
        @Perception.Bindable var store: StoreOf<PharmacyRedeemDomain>

        var body: some View {
            WithPerceptionTracking {
                SingleElementSectionContainer(
                    header: {
                        Label(L10n.phaRedeemTxtPrescription)
                            .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemTxtPrescriptionTitle)
                    },
                    content: {
                        if !store.selectedPrescriptions.isEmpty {
                            Button(action: {
                                store.send(.showPrescriptionSelection)
                            }, label: {
                                HStack(spacing: 0) {
                                    VStack(alignment: .leading) {
                                        Text(
                                            "\(store.selectedPrescriptions.count) " +
                                                L10n.phaRedeemTxtPrescription.text
                                        )
                                        .font(Font.body)
                                        .padding(.bottom)
                                        .foregroundColor(Colors.systemLabel)

                                        Text(store.selectedPrescriptions.map(\.title).joined(separator: " & "))
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
                                    store.send(.showPrescriptionSelection)
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
    }

    struct RedeemButton: View {
        @Perception.Bindable var store: StoreOf<PharmacyRedeemDomain>
        var body: some View {
            WithPerceptionTracking {
                VStack(spacing: 8) {
                    GreyDivider()

                    SelfPayerWarningView(erxTasks: store.selectedPrescriptions.map(\.erxTask))
                        .padding()

                    if !store.readyToRedeem {
                        PrimaryTextButton(text: L10n.phaRedeemBtnRedeem,
                                          a11y: A11y.pharmacyRedeem.phaRedeemBtnRedeem,
                                          isEnabled: store.readyToRedeem) {
                            store.send(.redeem)
                        }
                        .padding(.horizontal)
                        .accessibilityDisabledReason(
                            reasonIfDisabled: store.state.accessibilityDisabledReason,
                            isDisabled: !store.readyToRedeem
                        )
                    } else {
                        LoadingPrimaryButton(text: L10n.phaRedeemBtnRedeem,
                                             isLoading: store.orderResponses.inProgress || store.redeemInProgress) {
                            store.send(.redeem)
                        }
                        .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemBtnRedeem)
                        .padding(.horizontal)
                    }
                }.padding(.bottom)
            }
        }
    }
}

private struct DisabledButtonWithReason: ViewModifier {
    let reasonIfDisabled: String
    let isDisabled: Bool

    func body(content: Content) -> some View {
        if isDisabled {
            content.accessibility(value: Text(reasonIfDisabled))
        }
    }
}

extension View {
    func accessibilityDisabledReason(reasonIfDisabled: String, isDisabled: Bool) -> some View {
        modifier(DisabledButtonWithReason(reasonIfDisabled: reasonIfDisabled, isDisabled: isDisabled))
    }
}

extension RedeemOption {
    var isContactDataRequired: Bool {
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
