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

struct GreyDivider: View {
    let topPadding: CGFloat?

    init(topPadding: CGFloat? = 1) {
        self.topPadding = topPadding
    }

    var body: some View {
        Divider().foregroundColor(Colors.separator)
            .shadow(color: Colors.separator, radius: 4, x: 0, y: -2)
            .padding(.top, topPadding)
    }
}

struct GreyDivider_Previews: PreviewProvider {
    static var previews: some View {
        GreyDivider()
    }
}
