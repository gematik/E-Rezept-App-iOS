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
import eRpStyleKit
import SwiftUI

struct PharmacyContactView: View {
    let store: PharmacyContactDomain.Store
    @ObservedObject
    var viewStore: ViewStore<PharmacyContactDomain.State, PharmacyContactDomain.Action>

    init(store: PharmacyContactDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                ScrollView {
                    VStack(spacing: 0) {
                        SingleElementSectionContainer(header: {
                            Text(L10n.phaContactTitleContact)
                        }, content: {
                            FormTextFieldView(placeholder: L10n.phaContactPlaceholder,
                                              subtitle: L10n.phaContactTxtPhone,
                                              text: viewStore.binding(\.$contactInfo.phone),
                                              showSeparator: false)
                                .textContentType(.telephoneNumber)
                                .keyboardType(.phonePad)
                                .accessibility(identifier: A11y.pharmacyContact.phaContactAddressPhone)
                        })

                        SectionContainer(header: {
                            Text(L10n.phaContactTitleAddress)
                        }, content: {
                            FormTextFieldView(placeholder: L10n.phaContactPlaceholder,
                                              subtitle: L10n.phaContactTxtName,
                                              text: viewStore.binding(\.$contactInfo.name))
                                .textContentType(.name)
                                .accessibility(identifier: A11y.pharmacyContact.phaContactAddressName)

                            FormTextFieldView(placeholder: L10n.phaContactPlaceholder,
                                              subtitle: L10n.phaContactTxtStreet,
                                              text: viewStore.binding(\.$contactInfo.street))
                                .textContentType(.streetAddressLine1)
                                .accessibility(identifier: A11y.pharmacyContact.phaContactAddressStreet)

                            FormTextFieldView(placeholder: L10n.phaContactPlaceholderAddress,
                                              subtitle: L10n.phaContactTxtAddressDetails,
                                              text: viewStore.binding(\.$contactInfo.addressDetail))
                                .textContentType(.streetAddressLine2)
                                .accessibility(identifier: A11y.pharmacyContact.phaContactAddressDetail)

                            FormTextFieldView(placeholder: L10n.phaContactPlaceholder,
                                              subtitle: L10n.phaContactTxtZip,
                                              text: viewStore.binding(\.$contactInfo.zip))
                                .textContentType(.postalCode)
                                .keyboardType(.numberPad)
                                .accessibility(identifier: A11y.pharmacyContact.phaContactAddressZip)

                            FormTextFieldView(placeholder: L10n.phaContactPlaceholder,
                                              subtitle: L10n.phaContactTxtCity,
                                              text: viewStore.binding(\.$contactInfo.city))
                                .textContentType(.addressCity)
                                .accessibility(identifier: A11y.pharmacyContact.phaContactAddressCity)

                            FormTextFieldView(placeholder: L10n.phaContactPlaceholderDeliveryInfo,
                                              subtitle: L10n.phaContactTxtDeliveryInfo,
                                              text: viewStore.binding(\.$contactInfo.deliveryInfo),
                                              showSeparator: false)
                                .accessibility(identifier: A11y.pharmacyContact.phaContactAddressInfo)
                        })
                    }
                }
                .accentColor(Colors.primary700)
                .background(Color(.secondarySystemBackground).ignoresSafeArea())
                .navigationBarTitle(L10n.phaContactTitleContact, displayMode: .inline)
                .navigationBarItems(
                    leading: NavigationBarCloseItem {
                        viewStore.send(.close)
                    },
                    trailing: NavigationBarSaveItem(disabled: !viewStore.state.isNewContactInfo) {
                        viewStore.send(.save)
                    }
                )
                .alert(
                    store.scope(state: \.alertState),
                    dismiss: .alertDismissButtonTapped
                )
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
