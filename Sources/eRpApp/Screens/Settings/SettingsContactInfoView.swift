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

struct SettingsContactInfoView: View {
    var body: some View {
        SectionContainer(header: {
            Label(title: { Text(L10n.stgTxtHeaderContactInfo) }, icon: {})
                .accessibilityIdentifier(A11y.settings.contact.stgConHeaderContact)
        }, footer: {
            Label(title: {
                Text(
                    L10n.stgConHotlineAva
                )
            }, icon: {})
                .accessibilityIdentifier(A11y.settings.contact.stgConTxtFootnote)
        }, content: {
            Button(action: {
                guard let url = URL(string: "https://gematik.shortcm.li/E-Rezept-App_Feedback"),
                      UIApplication.shared.canOpenURL(url) else { return }

                UIApplication.shared.open(url)
            }, label: {
                Label(L10n.stgConTextSurvey, systemImage: SFSymbolName.chartBarAxis)
            })
                .accessibility(identifier: A11y.settings.contact.stgConTxtSurvey)
                .buttonStyle(.navigation)

            Button(action: {
                if let email: URL = Self.createEmailUrl() {
                    if UIApplication.shared.canOpenURL(email) {
                        UIApplication.shared.open(email)
                    }
                }
            }, label: {
                Label(L10n.stgConTextMail, systemImage: SFSymbolName.textBubble)
            })
                .accessibility(identifier: A11y.settings.contact.stgConTxtMail)
                .buttonStyle(.navigation)

            Button(action: {
                guard let url = URL(string: "https://www.das-e-rezept-fuer-deutschland.de/ext/community"),
                      UIApplication.shared.canOpenURL(url) else { return }

                UIApplication.shared.open(url)
            }, label: {
                Label(L10n.stgConBtnGemmunity, systemImage: SFSymbolName.person2)
            })
                .accessibility(identifier: A11y.settings.contact.stgConTxtSurvey)
                .buttonStyle(.navigation)

            Button(action: {
                let phoneNumberformatted = "tel://" + L10n.stgConHotlineContact.text
                guard let url = URL(string: phoneNumberformatted) else { return }
                UIApplication.shared.open(url)
            }, label: {
                Label(L10n.stgConTextContactHotline, systemImage: SFSymbolName.phone)
            })
                .accessibility(identifier: A11y.settings.contact.stgConHotlineContact)
                .buttonStyle(.navigation)
        })
    }

    private static func createEmailUrl() -> URL? {
        var urlString = URLComponents(string: "mailto:\(L10n.stgConFbkMail.text)")
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "subject", value: L10n.stgConFbkSubjectMail.text))

        urlString?.queryItems = queryItems

        return urlString?.url
    }
}

struct ContactInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsContactInfoView()
    }
}
