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
        VStack(spacing: 16) {
            if let phone = phone {
                PrimaryTextButtonBorder(text: L10n.orderEgkTxtContactOptionTelephone,
                                        image: Image(systemName: SFSymbolName.phone)) {
                    if UIApplication.shared.canOpenURL(phone) {
                        UIApplication.shared.open(phone)
                    }
                }
                .accessibility(identifier: A11y.orderEGK.ogkBtnPhone)
            }

            if let web = web {
                PrimaryTextButtonBorder(text: L10n.orderEgkTxtContactOptionWeb,
                                        image: Image(systemName: SFSymbolName.safari)) {
                    if UIApplication.shared.canOpenURL(web) {
                        UIApplication.shared.open(web)
                    }
                }
                .accessibility(identifier: A11y.orderEGK.ogkBtnWeb)
            }

            if let email = email {
                PrimaryTextButtonBorder(text: L10n.orderEgkTxtContactOptionMail,
                                        image: Image(systemName: SFSymbolName.envelope)) {
                    if UIApplication.shared.canOpenURL(email) {
                        UIApplication.shared.open(email)
                    }
                }
                .accessibility(identifier: A11y.orderEGK.ogkBtnMail)
            }
        }
    }

    private struct ContactCellButtonView: View {
        let symbolName: String
        let text: LocalizedStringKey
        var a11y: String
        var isEnabled = true
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                VStack {
                    Image(systemName: symbolName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 46)
                        .font(.largeTitle)
                        .foregroundColor(isEnabled ? Asset.Colors.primary600.color : Color(.systemGray))
                        .padding(.bottom)
                    Text(text)
                        .foregroundColor(isEnabled ? Asset.Colors.primary600.color : Color(.systemGray))
                }
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .border(Colors.separator, cornerRadius: 16)
            .accessibility(identifier: a11y)
            .if(!isEnabled) {
                $0.accessibility(value: Text(L10n.buttonTxtIsInactiveValue))
            }
            .disabled(!isEnabled)
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
