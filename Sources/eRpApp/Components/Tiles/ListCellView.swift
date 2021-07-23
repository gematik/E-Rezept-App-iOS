//
//  Copyright (c) 2021 gematik GmbH
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

struct ListCellView: View {
    @ScaledMetric var iconSize: CGFloat = 22
    var sfSymbolName: String
    var text: LocalizedStringKey
    let accessibility: String

    var body: some View {
        HStack {
            Image(systemName: sfSymbolName)
                .foregroundColor(Colors.primary500)
                .frame(width: iconSize)
                .font(Font.title.weight(.semibold))
                .padding()
            Text(text)
                .foregroundColor(Colors.systemLabel)
            Spacer()
            Image(systemName: SFSymbolName.rightDisclosureIndicator)
                .foregroundColor(Colors.systemLabelTertiary)
                .padding()
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(Colors.systemBackgroundTertiary)
        .accessibility(identifier: accessibility)
    }
}

struct ListCellView_Previews: PreviewProvider {
    static var previews: some View {
        ListCellView(
            sfSymbolName: SFSymbolName.info,
            text: L10n.stgLnoTxtLegalNotice,
            accessibility: A18n.settings.legalNotice.stgLnoTxtLegalNotice
        )
    }
}
