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

struct OnboardingNextButton: View {
    let isEnabled: Bool
    let action: () -> Void
    @ScaledMetric var iconSize: CGFloat = 56
    var maxIconSize: CGFloat { 56 * 2 }

    var body: some View {
        Button(action: action) {
            Image(systemName: SFSymbolName.arrowRightCircleFill)
                .resizable()
                .frame(width: iconSize, height: iconSize, alignment: .center)
                .imageScale(.large)
                .accessibility(identifier: A18n.onboarding.start.onbBtnNext)
                .accessibility(hint: Text(L10n.onbBtnNextHint))
                .accessibility(label: Text(L10n.onbBtnNextHint))
                .padding(.all, 30)
        }
        .disabled(!isEnabled)
        .accentColor(isEnabled ? Colors.primary : Color(.systemGray))
    }
}

struct OnboardingNextButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingNextButton(isEnabled: true) {}
            OnboardingNextButton(isEnabled: true) {}
                .preferredColorScheme(.dark)
            OnboardingNextButton(isEnabled: false) {}
            OnboardingNextButton(isEnabled: false) {}
                .preferredColorScheme(.dark)
        }
    }
}
