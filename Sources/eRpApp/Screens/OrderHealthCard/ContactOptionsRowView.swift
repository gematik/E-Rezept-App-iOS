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

import eRpStyleKit
import SwiftUI

struct ContactOptionsRowView: View {
    let phone: URL?
    let web: URL?
    let email: URL?

    init(phone: String, web: String, email: URL?) {
        self.phone = phone.isEmpty ? nil : URL(string: "tel://" + phone)
        self.web = web.isEmpty ? nil : URL(string: web)
        self.email = email
    }

    var body: some View {
        VStack {
            if let phone = phone {
                ContactCellButtonView(
                    text: L10n.orderEgkTxtContactOptionTelephone.key,
                    a11y: A11y.orderEGK.ogkBtnPhone
                ) {
                    if UIApplication.shared.canOpenURL(phone) {
                        UIApplication.shared.open(phone)
                    }
                }
            }

            if let web = web {
                ContactCellButtonView(text: L10n.orderEgkTxtContactOptionWeb.key, a11y: A11y.orderEGK.ogkBtnWeb) {
                    if UIApplication.shared.canOpenURL(web) {
                        UIApplication.shared.open(web)
                    }
                }
            }

            if let email = email {
                ContactCellButtonView(text: L10n.orderEgkTxtContactOptionMail.key, a11y: A11y.orderEGK.ogkBtnMail) {
                    if UIApplication.shared.canOpenURL(email) {
                        UIApplication.shared.open(email)
                    }
                }
            }
        }
    }

    private struct ContactCellButtonView: View {
        let text: LocalizedStringKey
        var a11y: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                VStack {
                    Text(text, bundle: .module)
                        .fontWeight(.semibold)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Colors.primary600)
                        .padding()
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .buttonStyle(ContactButtonStyle())
            .padding(.horizontal)
            .padding(.vertical, 8)
            .accessibility(identifier: a11y)
        }

        private struct ContactButtonStyle: ButtonStyle {
            func makeBody(configuration: Self.Configuration) -> some View {
                configuration.label
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .opacity(configuration.isPressed ? 0.25 : 1)
                    .background(Colors.systemGray6)
                    .cornerRadius(16)
            }
        }
    }
}

struct ContactOptionsRowView_Previews: PreviewProvider {
    static var previews: some View {
        ContactOptionsRowView(
            phone: "003012345678",
            web: "",
            email: URL(string: "app-feedback@gematik.de")
        )
    }
}
