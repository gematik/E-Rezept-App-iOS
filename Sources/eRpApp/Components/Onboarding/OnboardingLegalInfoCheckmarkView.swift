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

struct OnboardingLegalInfoCheckmarkView: View {
    @ScaledMetric var iconSize: CGFloat = 24
    var maxIconSize: CGFloat { 24 * 3 }
    @Binding<Bool> var isAccepted: Bool

    var body: some View {
        Image(systemName: isAccepted ? SFSymbolName.checkmarkCircleFill : SFSymbolName.circle)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: iconSize > maxIconSize ? maxIconSize : iconSize)
            .font(Font.title3.weight(.bold))
            .foregroundColor(isAccepted ? Colors.primary700 : Colors.systemLabelTertiary)
            .padding([.leading, .trailing], 8)
    }
}

struct OnboardingLegalInfoCheckmarkView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingLegalInfoCheckmarkView(isAccepted: .constant(false))
            OnboardingLegalInfoCheckmarkView(isAccepted: .constant(false))
                .preferredColorScheme(.dark)
        }
    }
}
