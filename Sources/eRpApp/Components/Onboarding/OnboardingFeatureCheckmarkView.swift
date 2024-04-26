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

struct OnboardingFeatureCheckmarkView: View {
    @ScaledMetric var iconSize: CGFloat = 24
    var body: some View {
        Image(systemName: SFSymbolName.checkmarkCircleFill)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: iconSize)
            .font(Font.title3.weight(.bold))
            .foregroundColor(Colors.secondary600)
            .padding(.top, 2)
            .padding(.trailing, 8)
    }
}

struct OnboardingFeatureCheckmarkView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingFeatureCheckmarkView()
            OnboardingFeatureCheckmarkView()
                .preferredColorScheme(.dark)
        }
    }
}
