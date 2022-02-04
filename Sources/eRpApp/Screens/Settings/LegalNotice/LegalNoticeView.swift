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
import SwiftUI

struct LegalNoticeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                LegalNoticeSectionView(
                    title: L10n.stgLnoTxtTitleIssuer,
                    text: L10n.stgLnoTxtTextIssuer
                )
                LegalNoticeSectionView(
                    title: nil,
                    text: L10n.stgLnoTxtTextTaxAndMore
                )
                LegalNoticeSectionView(
                    title: L10n.stgLnoTxtTitleResponsible,
                    text: L10n.stgLnoTxtTextResponsible
                )
                LegalNoticeContactView(
                    title: L10n.stgLnoTxtTitleContact,
                    webLink: URL(string: "\(L10n.stgLnoLinkContact.text)"),
                    emailLink: URL(string: "mailto:\(L10n.stgLnoMailContact.text)"),
                    phoneLink: URL(string: "tel:\(L10n.stgLnoPhoneContact.text)")
                )
                LegalNoticeSectionView(
                    title: L10n.stgLnoTxtTitleNote,
                    text: L10n.stgLnoTxtTextNote
                )
                LegalNoticeFooterView()
            }
            .padding()
        }
        .navigationBarTitle(Text(L10n.stgLnoTxtLegalNotice), displayMode: .inline)
    }
}

extension LegalNoticeView {
    struct LegalNoticeSectionView: View {
        var title: LocalizedStringKey?
        var text: LocalizedStringKey
        var body: some View {
            if let title = title {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .padding(.top, 20)
            }
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.top, 1)
        }
    }

    struct LegalNoticeContactView: View {
        @ScaledMetric var iconSize: CGFloat = 22
        var title: LocalizedStringKey?
        var webLink: URL?
        var emailLink: URL?
        var phoneLink: URL?

        var body: some View {
            if let title = title {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .padding(.top, 20)
            }
            if let webLink = webLink {
                HStack {
                    Image(systemName: SFSymbolName.network)
                        .frame(width: iconSize)
                        .foregroundColor(Asset.Colors.primary600.color)
                    Link(L10n.stgLnoLinkTextContact, destination: webLink)
                        .foregroundColor(Asset.Colors.primary600.color)
                        .accessibility(identifier: A18n.settings.legalNotice.stgLnoLinkContact)
                }
                .padding(.top, 1)
            }
            if let emailLink = emailLink {
                HStack {
                    Image(systemName: SFSymbolName.mail)
                        .frame(width: iconSize)
                        .foregroundColor(Asset.Colors.primary600.color)
                    Link(L10n.stgLnoMailTextContact, destination: emailLink)
                        .foregroundColor(Asset.Colors.primary600.color)
                        .accessibility(identifier: A18n.settings.legalNotice.stgLnoMailContact)
                }
                .padding(.top, 1)
            }
            if let phoneLink = phoneLink {
                HStack {
                    Image(systemName: SFSymbolName.phone)
                        .frame(width: iconSize)
                        .foregroundColor(Asset.Colors.primary600.color)
                    Link(L10n.stgLnoPhoneTextContact, destination: phoneLink)
                        .foregroundColor(Asset.Colors.primary600.color)
                        .accessibility(identifier: A18n.settings.legalNotice.stgLnoPhoneContact)
                }
                .padding(.top, 1)
            }
        }
    }

    struct LegalNoticeFooterView: View {
        var body: some View {
            VStack {
                Image(Asset.Settings.LegalNotice.gematikLogo)
                    .foregroundColor(Asset.Colors.primary900.color)
                Text(L10n.stgLnoYouKnowUs)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.top, 1)
            }
            .padding(.top, 20)
        }
    }
}

struct LegalNoticeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LegalNoticeView()
        }.generateVariations(selection: .devices, oneDark: true)
    }
}
