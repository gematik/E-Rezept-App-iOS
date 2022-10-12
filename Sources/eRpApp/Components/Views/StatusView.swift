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

import SwiftUI

/// sourcery: StringAssetInitialized
struct StatusView: View {
    let title: LocalizedStringKey

    var foregroundColor: Color = Colors.systemLabel
    var backgroundColor: Color = Colors.systemBackgroundSecondary

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .foregroundColor(foregroundColor)
        }
        .font(Font.caption2.weight(.semibold))
        .padding(.init(top: 2.5, leading: 8, bottom: 2.5, trailing: 8))
        .background(backgroundColor)
        .cornerRadius(8)
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            StatusView(title: "Neu", backgroundColor: Colors.primary100)
            StatusView(title: "1 Rezept", foregroundColor: Colors.systemLabelSecondary)
        }
    }
}
