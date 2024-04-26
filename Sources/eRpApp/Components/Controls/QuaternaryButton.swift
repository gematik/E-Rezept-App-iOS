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

struct QuaternaryButton: View {
    var text: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text, bundle: .module)
                .fontWeight(.semibold)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(Colors.systemColorWhite)
                .padding(.horizontal)
                .padding(.vertical, 4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(QuaternaryButtonStyle())
    }
}

struct QuaternaryButtonStyle: ButtonStyle {
    private var isEnabled: Bool

    init(enabled: Bool = true) {
        isEnabled = enabled
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(Colors.primary)
            .cornerRadius(8)
    }
}

struct QuarternaryButton_Previews: PreviewProvider {
    static var previews: some View {
        QuaternaryButton(text: "Jetzt Einlösen") {}
    }
}
