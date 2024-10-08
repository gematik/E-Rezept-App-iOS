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
import eRpStyleKit
import Perception
import SwiftUI

// [REQ:BSI-eRp-ePA:O.Purp_2#6,O.Data_6#5] Contact information is collected when needed for redeeming
struct PharmacyContactView: View {
    @Perception.Bindable var store: StoreOf<PharmacyContactDomain>

    init(store: StoreOf<PharmacyContactDomain>) {
        self.store = store
    }

    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 0) {
                        if store.service.isAVS {
                            SectionContainer(header: {
                                Text(L10n.phaContactTitleContact)
                            }, content: {
                                LabeledContent(L10n.phaContactTxtPhone) {
                                    TextField(L10n.phaContactPlaceholder, text: $store.contactInfo.phone)
                                        .accessibility(identifier: A11y.pharmacyContact.phaContactAddressPhone)
                                }
                                .textContentType(.telephoneNumber)
                                .keyboardType(.phonePad)

                                LabeledContent(L10n.phaContactTxtMail) {
                                    TextField(L10n.phaContactPlaceholder, text: $store.contactInfo.mail)
                                        .accessibility(identifier: A11y.pharmacyContact.phaContactAddressMail)
                                }
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                            })
                        } else {
                            SingleElementSectionContainer(header: {
                                Text(L10n.phaContactTitleContact)
                            }, content: {
                                LabeledContent(L10n.phaContactTxtPhone) {
                                    TextField(L10n.phaContactPlaceholder, text: $store.contactInfo.phone)
                                        .accessibility(identifier: A11y.pharmacyContact.phaContactAddressPhone)
                                }
                                .textContentType(.telephoneNumber)
                                .keyboardType(.phonePad)
                            })
                        }

                        SectionContainer(header: {
                            Text(L10n.phaContactTitleAddress)
                        }, content: {
                            LabeledContent(L10n.phaContactTxtName) {
                                TextField(L10n.phaContactPlaceholder, text: $store.contactInfo.name)
                                    .accessibility(identifier: A11y.pharmacyContact.phaContactAddressName)
                            }
                            .textContentType(.name)

                            LabeledContent(L10n.phaContactTxtStreet) {
                                TextField(L10n.phaContactPlaceholder, text: $store.contactInfo.street)
                                    .accessibility(identifier: A11y.pharmacyContact.phaContactAddressStreet)
                            }
                            .textContentType(.streetAddressLine1)

                            LabeledContent(L10n.phaContactTxtZip) {
                                TextField(L10n.phaContactPlaceholder, text: $store.contactInfo.zip)
                                    .accessibility(identifier: A11y.pharmacyContact.phaContactAddressZip)
                            }
                            .textContentType(.postalCode)
                            .keyboardType(.numberPad)

                            LabeledContent(L10n.phaContactTxtCity) {
                                TextField(L10n.phaContactPlaceholder, text: $store.contactInfo.city)
                                    .accessibility(identifier: A11y.pharmacyContact.phaContactAddressCity)
                            }
                            .textContentType(.addressCity)

                            LabeledContent(L10n.phaContactTxtDeliveryInfo) {
                                TextField(L10n.phaContactPlaceholderDeliveryInfo,
                                          text: $store.contactInfo.deliveryInfo)
                                    .accessibility(identifier: A11y.pharmacyContact.phaContactAddressInfo)
                            }
                        })
                    }
                }
                .accentColor(Colors.primary600)
                .background(Color(.secondarySystemBackground).ignoresSafeArea())
                .navigationBarTitle(L10n.phaContactTitleContact, displayMode: .inline)
                .navigationBarItems(
                    leading: NavigationBarCloseItem {
                        store.send(.closeButtonTapped)
                    },
                    trailing: NavigationBarSaveItem(disabled: !store.state.isNewContactInfo) {
                        store.send(.save)
                    }
                )
                .alert($store.scope(
                    state: \.alertState,
                    action: \.alert
                ))
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }

    private struct NavigationBarSaveItem: View {
        let disabled: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text(L10n.phaContactBtnSave)
                    .font(.body)
                    .foregroundColor(disabled ? Colors.disabled : Colors.primary700)
            }
            .disabled(disabled)
            .accessibility(identifier: A11y.pharmacyContact.phaContactBtnSave)
        }
    }
}

struct PharmacyContactView_Previews: PreviewProvider {
    static var previews: some View {
        PharmacyContactView(store: PharmacyContactDomain.Dummies.store)
    }
}
