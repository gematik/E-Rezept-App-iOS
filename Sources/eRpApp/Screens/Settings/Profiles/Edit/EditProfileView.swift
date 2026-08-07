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
import ConsentService
import eRpStyleKit
import FeatureCardWall
import FeatureEURedeem
import IDP
import SwiftUI

struct EditProfileView: View {
    @Bindable var store: StoreOf<EditProfileDomain>

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                VStack {
                    ProfilePictureView(
                        image: store.image,
                        userImageData: store.userImageData,
                        color: store.color,
                        connection: nil,
                        style: .xxLarge,
                        isBorderOn: true
                    ) {
                        store.send(.editProfilePictureTapped)
                    }
                    .padding(.top, 24)

                    Button {
                        store.send(.editProfilePictureTapped)
                    } label: {
                        HStack {
                            Image(systemName: SFSymbolName.pencil)
                            Text(L10n.stgBtnEditPicture)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                .accessibilityLabel(L10n.stgBtnEditProfileEdit)
                .accessibilityElement(children: .combine)

                SingleElementSectionContainer(
                    header: {
                        Text(L10n.stgTxtEditProfileNameSectionTitle)
                            .accessibilityAddTraits(.isHeader)
                    },
                    footer: {
                        if store.name.lengthOfBytes(using: .utf8) == 0 {
                            EmptyProfileError()
                        }

                    },
                    content: {
                        ZStack {
                            TextField(text: $store.name) {
                                Text(L10n.stgTxtEditProfileNamePlaceholder.key, bundle: .module)
                            }
                            .padding()
                            .font(Font.body)
                            .foregroundColor(Colors.systemLabel)
                            .accessibility(label: Text(L10n.stgTxtEditProfileNamePlaceholder.key, bundle: .module))
                            .animation(.easeInOut, value: store.name)
                            .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileNameInput)

                            HStack {
                                Spacer()

                                Image(systemName: SFSymbolName.pencil)
                                    .foregroundColor(Colors.primary)
                                    .padding(.trailing)
                            }
                            .accessibilityHidden(true)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                )

                ConnectedProfile(store: store)

                MyAreaSectionView(store: store)

                Button {
                    store.send(.showDeleteProfileAlert)
                } label: {
                    Text(L10n.stgBtnEditProfileDelete)
                }
                .buttonStyle(eRpStyleKit.PrimaryButtonStyle(enabled: true, destructive: true))
                .accessibility(identifier: A11y.settings.editProfile.stgBtnEditProfileDelete)
                .padding(.vertical)

                // InsuranceDrawerView small sheet presentation
                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .smallSheet(
                        $store.scope(
                            state: \.destination?.insuranceDrawer,
                            action: \.destination.insuranceDrawer
                        )
                    ) { _ in
                        InsuranceDrawerView(root: .settings) {
                            store.send(.resetNavigation, animation: .easeInOut)
                        } gkvInsuredAction: {
                            store.send(.setUserToGKVInsured, animation: .easeInOut)
                        } pkvInsuredAction: {
                            store.send(.setUserToPKVInsured, animation: .easeInOut)
                        } federalInsuredAction: {
                            store.send(.setUserToFederalInsured, animation: .easeInOut)
                        }
                    }
                    .accessibilityHidden(true)
            }
        }
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
        .gesture(TapGesture().onEnded {
            UIApplication.shared.dismissKeyboard()
        })
        .navigationTitle(L10n.stgTxtEditProfileTitle)
        .navigationDestination(
            item: $store.scope(state: \.destination?.editProfilePicture,
                               action: \.destination.editProfilePicture)
        ) { store in
            EditProfilePictureView(store: store)
                .navigationTitle(L10n.editPictureTxt)
                .navigationBarTitleDisplayMode(.inline)
        }
        .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
        .fullScreenCover(
            item: $store.scope(
                state: \.destination?.cardWall,
                action: \.destination.cardWall
            )
        ) { store in
            CardWallIntroductionView(store: store)
        }
        .task {
            await store.send(.task).finish()
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

extension EditProfileView {
    private struct EmptyProfileError: View {
        var body: some View {
            Text(L10n.stgTxtEditProfileEmptyNameErrorMessage)
                .foregroundColor(Colors.red700)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private struct ConnectedProfile: View {
        @Bindable var store: StoreOf<EditProfileDomain>

        var hasConnectingData: Bool {
            if let fullName = store.fullName, !fullName.isEmpty {
                return true
            }
            if let insuranceId = store.insuranceId, !insuranceId.isEmpty {
                return true
            }
            if let can = store.can, !can.isEmpty {
                return true
            }
            return false
        }

        var body: some View {
            if hasConnectingData {
                SectionContainer(header: {
                    Text(L10n.stgTxtEditProfileUserDataSectionTitle)
                        .accessibilityAddTraits(.isHeader)
                }, content: {
                    if let fullName = store.fullName, !fullName.isEmpty {
                        LabeledContent {
                            Text(fullName)
                        } label: {
                            Text(L10n.stgTxtEditProfileLabelName)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibility(label: Text(L10n.stgTxtEditProfileLabelName))
                        .accessibility(value: Text(fullName))
                        .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileName)
                    }

                    EditInsuranceView(store: store)

                    if let can = store.can {
                        LabeledContent {
                            Text(can)
                        } label: {
                            Text(L10n.stgTxtEditProfileLabelCan)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibility(label: Text(L10n.stgTxtEditProfileLabelCan))
                        .accessibility(value: Text(can))
                        .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileCan)
                    }
                    if let insuranceId = store.insuranceId {
                        Button(action: {
                            store.send(.copyKVNR(insuranceId))
                        }, label: {
                            Label {
                                HStack(alignment: .center, spacing: 16) {
                                    LabeledContent {
                                        Text(insuranceId)
                                    } label: {
                                        Text(L10n.stgTxtEditProfileLabelKvnr)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                    HStack {
                                        Image(systemName: store.showCopySuccessInfo ? SFSymbolName
                                            .checkmark : SFSymbolName.copy)
                                        Text(L10n.stgBtnEditProfileCopyKvnr)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                            } icon: { EmptyView() }
                        })
                        .accessibility(label: Text(L10n.stgTxtEditProfileLabelKvnr))
                        .accessibility(value: Text(insuranceId))
                        .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileInsuranceId)
                    }
                })
            } else {
                SingleElementSectionContainer(
                    header: {
                        Text(L10n.stgTxtEditProfileUserDataSectionTitle)
                            .accessibilityAddTraits(.isHeader)
                    },
                    content: {
                        EditInsuranceView(store: store)
                    }
                )
            }

            if store.token != nil {
                // [REQ:BSI-eRp-ePA:O.Auth_14#2|5] The user may use the logout button within each profile
                Button {
                    store.send(.delegate(.logout))
                } label: {
                    Text(L10n.stgBtnEditProfileLogout)
                }
                .buttonStyle(.secondary(isDestructive: true, background: Colors.systemBackgroundSecondary))
                .accessibility(identifier: A11y.settings.editProfile.stgBtnEditProfileLogout)

                Text(L10n.stgTxtEditProfileLogoutInfo)
                    .padding(.horizontal)
                    .font(.footnote)
                    .foregroundColor(Colors.systemLabelSecondary)
                    .padding(.bottom)
                    .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileLogoutInfo)
            } else {
                Button(action: {
                    store.send(.login)
                }, label: {
                    Text(L10n.stgBtnEditProfileLogin)
                })
                .buttonStyle(.primary)
                .padding(.bottom)
                .accessibility(identifier: A11y.settings.editProfile.stgBtnEditProfileLogin)
            }
        }
    }

    private struct EditInsuranceView: View {
        @Bindable var store: StoreOf<EditProfileDomain>

        var body: some View {
            Button(action: {
                store.send(.changeInsurance)
            }, label: {
                Label {
                    HStack(alignment: .center, spacing: 16) {
                        LabeledContent {
                            Text(store.insuranceName)
                        } label: {
                            Text(L10n.stgTxtEditProfileLabelInsuranceCompany)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        HStack {
                            Image(systemName: SFSymbolName.pencil)
                            Text(L10n.stgBtnEditProfileLabelInsuranceCompany)
                                .multilineTextAlignment(.trailing)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                } icon: {
                    EmptyView()
                }
            })
            .accessibilityElement(children: .combine)
            .accessibility(label: Text(L10n.stgTxtEditProfileLabelInsuranceCompany))
            .accessibility(value: Text(store.insuranceName))
            .accessibility(identifier: A11y.settings.editProfile.stgTxtEditProfileInsuranceCompany)
        }
    }

    private struct MyAreaSectionView: View {
        @Bindable var store: StoreOf<EditProfileDomain>

        @Shared(.enablePushNotifications) var enablePushNotifications: Bool

        var body: some View {
            SectionContainer(
                header: {
                    Text(L10n.stgTxtEditProfileMyAreaTitle)
                        .accessibility(identifier: A11y.settings.editProfile
                            .stgTxtEditProfileMyAreaTitle)
                        .accessibilityAddTraits(.isHeader)
                },
                content: {
                    if store.insuranceType.canReceiveChargeItems {
                        Button {
                            store.send(.chargeItemListTapped)
                        } label: {
                            Label {
                                Text(L10n.stgBtnEditProfileChargeItemList)
                            } icon: {
                                Image(systemName: SFSymbolName.euroSign)
                            }
                        }
                        .buttonStyle(.navigation)
                        .accessibilityElement(children: .combine)
                        .accessibility(identifier: A11y.settings.editProfile
                            .stgTxtEditProfileChargeItemListSectionShowChargeItemList)
                    }

                    if store.isEURedeemable {
                        Button {
                            store.send(.showEURedeemConsent)
                        } label: {
                            Label(title: {
                                KeyValuePair(
                                    key: L10n.stgBtnEditProfileEuRedeemConsentTitle.text,
                                    value: store.euRedeemConsentCheck == .granted ?
                                        L10n.stgBtnEditProfileEuRedeemGrantConsent.text : L10n
                                        .stgBtnEditProfileEuRedeemRejectConsent.text
                                )
                            }, icon: {
                                Image(systemName: SFSymbolName.globeEU)
                            })
                        }
                        .buttonStyle(.navigation)
                        .accessibilityElement(children: .combine)
                        .accessibility(identifier: A11y.settings.editProfile
                            .stgBtnEditProfileEuRedeemChangeConsent)
                    }

                    if enablePushNotifications {
                        Button {
                            store.send(.pushNotificationsTapped)
                        } label: {
                            Label {
                                Text(L10n.stgBtnEditProfileNotifications)
                            } icon: {
                                Image(systemName: SFSymbolName.bell)
                            }
                        }
                        .buttonStyle(.navigation)
                        .accessibilityElement(children: .combine)
                        .accessibility(identifier: A11y.settings.editProfile
                            .stgBtnEditProfileSecuritySectionShowAuditEvents)
                    }

                    // [REQ:gemSpec_eRp_FdV:A_19177#2,A_19185#3] Actual Button to open the audit events
                    // [REQ:BSI-eRp-ePA:O.Auth_6#2] Actual Button to open the audit events
                    Button {
                        store.send(.auditEventsTapped)
                    } label: {
                        Label {
                            Text(L10n.stgTxtEditProfileSecurityShowAuditEventsLabel2)
                        } icon: {
                            Image(systemName: SFSymbolName.arrowUpArrowDown)
                        }
                    }
                    .buttonStyle(.navigation)
                    .accessibilityElement(children: .combine)
                    .accessibility(identifier: A11y.settings.editProfile
                        .stgBtnEditProfileSecuritySectionShowAuditEvents)

                    Button {
                        store.send(.registeredDevicesTapped)
                    } label: {
                        Label {
                            Text(L10n.stgBtnEditProfileRegisteredDevices)
                        } icon: {
                            Image(systemName: SFSymbolName.ipadLandscapeAndIphone)
                        }
                    }
                    .buttonStyle(.navigation)
                    .accessibilityElement(children: .combine)
                    .accessibility(identifier: A11y.settings.editProfile
                        .stgTxtEditProfileLoginSectionConnectedDevices)
                }
            )
            .navigationDestination(
                item: $store.scope(state: \.destination?.chargeItemList,
                                   action: \.destination.chargeItemList)
            ) { store in
                ChargeItemListView(store: store)
            }
            .navigationDestination(item: $store.scope(
                state: \.destination?.euRedeemConsent,
                action: \.destination.euRedeemConsent
            )) { store in
                FeatureEURedeem.ConsentView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.auditEvents, action: \.destination.auditEvents)
            ) { store in
                AuditEventsView(store: store)
            }
            .navigationDestination(
                item: $store.scope(
                    state: \.destination?.notificationChannels,
                    action: \.destination.notificationChannels
                )
            ) { store in
                NotificationChannelsView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.registeredDevices,
                                   action: \.destination.registeredDevices)
            ) { store in
                RegisteredDevicesView(store: store)
            }
        }
    }
}

struct ProfileView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                EditProfileView(
                    store: .init(
                        initialState: {
                            var state: EditProfileDomain.State = .init(profile: UserProfile.Dummies.profileE)
                            state.token = IDPToken(accessToken: "", expires: Date(), idToken: "", redirect: "")
                            state.can = "123123"
                            state.fullName = "Test User"
                            return state
                        }()
                    ) {
                        EmptyReducer() // EditProfileDomain()
                    }
                )
            }

            NavigationStack {
                EditProfileView(store: EditProfileDomain.Dummies.store)
            }
        }
    }
}
