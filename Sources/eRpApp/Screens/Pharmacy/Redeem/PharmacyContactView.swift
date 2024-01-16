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
import SwiftUI

// [REQ:BSI-eRp-ePA:O.Purp_2#6,O.Data_6#5] Contact information is collected when needed for redeeming
struct PharmacyContactView: View {
    let store: PharmacyContactDomain.Store
    @ObservedObject var viewStore: ViewStore<PharmacyContactDomain.State, PharmacyContactDomain.Action>

    init(store: PharmacyContactDomain.Store) {
        self.store = store
        viewStore = ViewStore(store) { $0 }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                ScrollView {
                    VStack(spacing: 0) {
                        if viewStore.service.isAVS {
                            SectionContainer(header: {
                                Text(L10n.phaContactTitleContact)
                            }, content: {
                                FormTextFieldView(placeholder: L10n.phaContactPlaceholder.text,
                                                  subtitle: L10n.phaContactTxtPhone,
                                                  text: viewStore.binding(get: \.contactInfo.phone,
                                                                          send: PharmacyContactDomain.Action.setPhone))
                                    .textContentType(.telephoneNumber)
                                    .keyboardType(.phonePad)
                                    .accessibility(identifier: A11y.pharmacyContact.phaContactAddressPhone)

                                FormTextFieldView(placeholder: L10n.phaContactPlaceholder.text,
                                                  subtitle: L10n.phaContactTxtMail,
                                                  text: viewStore.binding(get: \.contactInfo.mail,
                                                                          send: PharmacyContactDomain.Action.setMail),
                                                  showSeparator: false)
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
                                                  text: viewStore.binding(get: \.contactInfo.phone,
                                                                          send: PharmacyContactDomain.Action.setPhone),
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
                                              text: viewStore.binding(get: \.contactInfo.name,
                                                                      send: PharmacyContactDomain.Action.setName))
                                .textContentType(.name)
                                .accessibility(identifier: A11y.pharmacyContact.phaContactAddressName)

                            FormTextFieldView(placeholder: L10n.phaContactPlaceholder.text,
                                              subtitle: L10n.phaContactTxtStreet,
                                              text: viewStore.binding(get: \.contactInfo.street,
                                                                      send: PharmacyContactDomain.Action.setStreet))
                                .textContentType(.streetAddressLine1)
                                .accessibility(identifier: A11y.pharmacyContact.phaContactAddressStreet)

                            FormTextFieldView(placeholder: L10n.phaContactPlaceholder.text,
                                              subtitle: L10n.phaContactTxtZip,
                                              text: viewStore.binding(get: \.contactInfo.zip,
                                                                      send: PharmacyContactDomain.Action.setZip))
                                .textContentType(.postalCode)
                                .keyboardType(.numberPad)
                                .accessibility(identifier: A11y.pharmacyContact.phaContactAddressZip)

                            FormTextFieldView(placeholder: L10n.phaContactPlaceholder.text,
                                              subtitle: L10n.phaContactTxtCity,
                                              text: viewStore.binding(get: \.contactInfo.city,
                                                                      send: PharmacyContactDomain.Action.setCity))
                                .textContentType(.addressCity)
                                .accessibility(identifier: A11y.pharmacyContact.phaContactAddressCity)

                            FormTextFieldView(placeholder: L10n.phaContactPlaceholderDeliveryInfo.text,
                                              subtitle: L10n.phaContactTxtDeliveryInfo,
                                              text: viewStore.binding(
                                                  get: \.contactInfo.deliveryInfo,
                                                  send: PharmacyContactDomain.Action.setDeliveryInfo
                                              ),
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
                        viewStore.send(.closeButtonTapped)
                    },
                    trailing: NavigationBarSaveItem(disabled: !viewStore.state.isNewContactInfo) {
                        viewStore.send(.save)
                    }
                )
                .alert(store: store.scope(state: \.$alertState, action: PharmacyContactDomain.Action.alert))
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
