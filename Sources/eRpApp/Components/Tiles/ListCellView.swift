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

import eRpStyleKit
import SwiftUI

/// sourcery: StringAssetInitialized
struct ListCellView: View {
    @ScaledMetric var iconSize: CGFloat = 22
    var sfSymbolName: String
    var text: LocalizedStringKey

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: sfSymbolName)
                .foregroundColor(Colors.primary500)
                .frame(width: iconSize)
                .font(Font.body.weight(.semibold))
            Text(text, bundle: .module)
                .foregroundColor(Colors.systemLabel)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 50)
    }
}

struct ListCellView_Previews: PreviewProvider {
    static var previews: some View {
        ListCellView(
            sfSymbolName: SFSymbolName.info,
            text: L10n.stgLnoTxtLegalNotice
        )
    }
}
