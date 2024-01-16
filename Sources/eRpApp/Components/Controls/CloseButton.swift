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

import SwiftUI

struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: SFSymbolName.crossIconPlain)
                .font(Font.caption.weight(.bold))
                .foregroundColor(Color(.secondaryLabel))
                .padding(6)
                .background(Circle().foregroundColor(Color(.systemGray6)))
                .padding()
        }
    }
}

struct CloseButton_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Text("see close button top trailing ^")
                .navigationBarItems(trailing: CloseButton {})
        }
    }
}
