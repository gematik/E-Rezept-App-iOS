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
import SwiftUI

// [REQ:BSI-eRp-ePA:O.Resi_1#4] View containing the "no system pin" message.
struct DeviceSecuritySystemPinView: View {
    @State var ignorePermanently = false

    var action: (_ ignorePermanently: Bool) -> Void

    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 24) {
                    Text(L10n.secTxtSystemPinHeadline)
                        .font(.headline)
                        .padding(.vertical)
                        .accessibility(identifier: A11y.security.secTxtSystemPinHeadline)
                        .frame(maxWidth: .infinity)

                    HStack {
                        Spacer(minLength: 0)
                        Image(decorative: Asset.Illustrations.womanYellowCircle)
                        Spacer(minLength: 0)
                    }

                    VStack(alignment: .leading) {
                        Text(L10n.secTxtSystemPinTitle)
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.bottom, 8)
                            .accessibility(identifier: A11y.security.secTxtSystemPinTitle)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(L10n.secTxtSystemPinMessage)
                            .accessibility(identifier: A11y.security.secTxtSystemPinMessage)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)

                    OptInCell(
                        text: L10n.secTxtSystemPinSelection,
                        isOn: $ignorePermanently
                    )
                    .accessibility(identifier: A11y.security.secTxtSystemPinSelection)
                    .padding(.horizontal)
                }
            }

            Spacer(minLength: 0)

            GreyDivider()
            PrimaryTextButton(
                text: L10n.secBtnSystemPinDone,
                a11y: A11y.security.secBtnSystemPinDone,
                image: nil
            ) {
                action(ignorePermanently)
            }
            .padding()
        }
    }
}

struct DeviceSecuritySystemPinView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceSecuritySystemPinView { _ in }
    }
}
