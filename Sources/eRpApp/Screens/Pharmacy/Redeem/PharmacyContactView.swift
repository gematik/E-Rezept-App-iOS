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
            NavigationView {
                VStack(alignment: .leading) {
                    ScrollView {
                        VStack(spacing: 0) {
                            if store.service.isAVS {
                                SectionContainer(header: {
                                    Text(L10n.phaContactTitleContact)
                                }, content: {
                                    FormTextFieldView(
                                        placeholder: L10n.phaContactPlaceholder.text,
                                        subtitle: L10n.phaContactTxtPhone,
                                        text: $store.contactInfo.phone
                                    )
                                    .textContentType(.telephoneNumber)
                                    .keyboardType(.phonePad)
                                    .accessibility(identifier: A11y.pharmacyContact.phaContactAddressPhone)

                                    FormTextFieldView(
                                        placeholder: L10n.phaContactPlaceholder.text,
                                        subtitle: L10n.phaContactTxtMail,
                                        text: $store.contactInfo.mail,
                                        showSeparator: false
                                    )
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .accessibility(identifier: A11y.pharmacyContact.phaContactAddressMail)
                                })
                            } else {
                                SingleElementSectionContainer(header: {
                                    Text(L10n.phaContactTitleContact)
                                }, content: {
                                    FormTextFieldView(placeholder: L10n.phaContactPlaceholder.text,
                                                      subtitle: L10n.phaContactTxtPhone,
                                                      text: $store.contactInfo.phone,
                                                      showSeparator: false)
                                        .textContentType(.telephoneNumber)
                                        .keyboardType(.phonePad)
                                        .accessibility(identifier: A11y.pharmacyContact.phaContactAddressPhone)
                                })
                            }

                            SectionContainer(header: {
                                Text(L10n.phaContactTitleAddress)
                            }, content: {
                                FormTextFieldView(placeholder: L10n.phaContactPlaceholder.text,
                                                  subtitle: L10n.phaContactTxtName,
                                                  text: $store.contactInfo.name)
                                    .textContentType(.name)
                                    .accessibility(identifier: A11y.pharmacyContact.phaContactAddressName)

                                FormTextFieldView(placeholder: L10n.phaContactPlaceholder.text,
                                                  subtitle: L10n.phaContactTxtStreet,
                                                  text: $store.contactInfo.street)
                                    .textContentType(.streetAddressLine1)
                                    .accessibility(identifier: A11y.pharmacyContact.phaContactAddressStreet)

                                FormTextFieldView(placeholder: L10n.phaContactPlaceholder.text,
                                                  subtitle: L10n.phaContactTxtZip,
                                                  text: $store.contactInfo.zip)
                                    .textContentType(.postalCode)
                                    .keyboardType(.numberPad)
                                    .accessibility(identifier: A11y.pharmacyContact.phaContactAddressZip)

                                FormTextFieldView(placeholder: L10n.phaContactPlaceholder.text,
                                                  subtitle: L10n.phaContactTxtCity,
                                                  text: $store.contactInfo.city)
                                    .textContentType(.addressCity)
                                    .accessibility(identifier: A11y.pharmacyContact.phaContactAddressCity)

                                FormTextFieldView(placeholder: L10n.phaContactPlaceholderDeliveryInfo.text,
                                                  subtitle: L10n.phaContactTxtDeliveryInfo,
                                                  text: $store.contactInfo.deliveryInfo,
                                                  showSeparator: false)
                                    .accessibility(identifier: A11y.pharmacyContact.phaContactAddressInfo)
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
