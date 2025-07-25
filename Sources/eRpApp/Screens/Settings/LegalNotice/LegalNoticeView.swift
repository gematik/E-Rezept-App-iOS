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
import eRpStyleKit
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
    /// sourcery: StringAssetInitialized
    struct LegalNoticeSectionView: View {
        var title: LocalizedStringKey?
        var text: LocalizedStringKey
        var body: some View {
            if let title = title {
                Text(title, bundle: .module)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .padding(.top, 20)
            }
            Text(text, bundle: .module)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.top, 1)
        }
    }

    /// sourcery: StringAssetInitialized
    struct LegalNoticeContactView: View {
        @ScaledMetric var iconSize: CGFloat = 22
        var title: LocalizedStringKey?
        var webLink: URL?
        var emailLink: URL?
        var phoneLink: URL?

        var body: some View {
            if let title = title {
                Text(title, bundle: .module)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .padding(.top, 20)
            }
            if let webLink = webLink {
                HStack {
                    Image(systemName: SFSymbolName.network)
                        .frame(width: iconSize)
                        .foregroundColor(Colors.primary700)
                    Link(L10n.stgLnoLinkTextContact, destination: webLink)
                        .foregroundColor(Colors.primary700)
                        .accessibility(identifier: A18n.settings.legalNotice.stgLnoLinkContact)
                }
                .padding(.top, 1)
            }
            if let emailLink = emailLink {
                HStack {
                    Image(systemName: SFSymbolName.mail)
                        .frame(width: iconSize)
                        .foregroundColor(Colors.primary700)
                    Link(L10n.stgLnoMailTextContact, destination: emailLink)
                        .foregroundColor(Colors.primary700)
                        .accessibility(identifier: A18n.settings.legalNotice.stgLnoMailContact)
                }
                .padding(.top, 1)
            }
            if let phoneLink = phoneLink {
                HStack {
                    Image(systemName: SFSymbolName.phone)
                        .frame(width: iconSize)
                        .foregroundColor(Colors.primary700)
                    Link(L10n.stgLnoPhoneTextContact, destination: phoneLink)
                        .foregroundColor(Colors.primary700)
                        .accessibility(identifier: A18n.settings.legalNotice.stgLnoPhoneContact)
                }
                .padding(.top, 1)
            }
        }
    }

    struct LegalNoticeFooterView: View {
        var body: some View {
            VStack {
                Image(asset: Asset.Settings.LegalNotice.gematikLogo)
                    .foregroundColor(Colors.primary900)
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
        }
    }
}
