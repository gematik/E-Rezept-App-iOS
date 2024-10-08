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

// [REQ:BSI-eRp-ePA:O.Arch_6#5,O.Resi_2#5] Jailbreak information view
struct DeviceSecurityRootedDeviceView: View {
    @State var ignoreWarning = false

    var action: () -> Void

    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 24) {
                    Text(L10n.secTxtSystemRootDetectionHeadline)
                        .font(.headline)
                        .padding(.vertical)
                        .accessibility(identifier: A11y.security.secTxtSystemRootDetectionHeadline)
                        .frame(maxWidth: .infinity)

                    HStack {
                        Spacer(minLength: 0)
                        Image(decorative: Asset.Illustrations.womanRedCircle)
                        Spacer(minLength: 0)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.secTxtSystemRootDetectionTitle)
                            .font(.title3)
                            .fontWeight(.bold)
                            .accessibility(identifier: A11y.security.secTxtSystemRootDetectionTitle)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(L10n.secTxtSystemRootDetectionMessage)
                            .accessibility(identifier: A11y.security.secTxtSystemRootDetectionMessage)
                            .fixedSize(horizontal: false, vertical: true)

                        Button(action: {
                            guard let url =
                                URL(
                                    // swiftlint:disable:next line_length
                                    string: "https://web.archive.org/web/20131101181908/https://www.bsi.bund.de/SharedDocs/Downloads/DE/BSI/Grundschutz/Download/Ueberblickspapier_Apple_iOS_pdf.pdf?__blob=publicationFile"
                                )
                            else {
                                return
                            }
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }, label: {
                            VStack(alignment: .leading) {
                                Text(L10n.secTxtSystemRootDetectionFootnote)
                                    .font(.footnote)
                                    .foregroundColor(Color(.secondaryLabel))
                                    .accessibility(identifier: A11y.security.secTxtSystemRootDetectionFootnote)
                                    .fixedSize(horizontal: false, vertical: true)

                                HStack {
                                    Spacer()

                                    Text(L10n.secBtnSystemRootDetectionMore)
                                        .font(.footnote)
                                        .foregroundColor(Colors.primary600)
                                        .accessibility(identifier: A11y.security.secBtnSystemRootDetectionFootnoteMore)
                                }
                            }
                        })
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)

                    OptInCell(
                        text: L10n.secTxtSystemRootDetectionSelection,
                        isOn: $ignoreWarning
                    )
                    .accessibility(identifier: A11y.security.secTxtSystemRootDetectionSelection)
                    .padding(.horizontal)
                }
            }

            Spacer(minLength: 0)

            GreyDivider()

            PrimaryTextButton(
                text: L10n.secBtnSystemRootDetectionDone,
                a11y: A11y.security.secBtnSystemRootDetectionDone,
                image: nil,
                isEnabled: ignoreWarning
            ) {
                action()
            }
            .padding()
        }
    }
}

struct DeviceSecurityRootedDeviceView_Preview: PreviewProvider {
    static var previews: some View {
        DeviceSecurityRootedDeviceView {}
    }
}
