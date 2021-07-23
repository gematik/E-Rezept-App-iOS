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

struct GreyDivider: View {
    var body: some View {
        Divider().foregroundColor(Colors.separator)
            .shadow(color: Colors.separator, radius: 4, x: 0, y: -2)
            .padding(.top, 1)
    }
}

struct GreyDivider_Previews: PreviewProvider {
    static var previews: some View {
        GreyDivider()
    }
}
