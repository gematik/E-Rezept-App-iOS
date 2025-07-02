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
struct StatusView: View {
    let title: LocalizedStringKey

    var foregroundColor: Color = Colors.systemLabel
    var backgroundColor: Color = Colors.systemBackgroundSecondary

    var body: some View {
        HStack(spacing: 4) {
            Text(title, bundle: .module)
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
