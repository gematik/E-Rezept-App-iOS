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

struct OnboardingStartView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Image(decorative: Asset.Onboarding.logoNeuFahne)
                        .padding([.top, .leading], 8)
                        .foregroundColor(Colors.primary900)
                        .accessibility(sortPriority: 1.0)
                    Image(decorative: Asset.Onboarding.logoNeuGematik)
                        .padding(.top, 8)
                        .foregroundColor(Colors.primary900)
                        .accessibility(identifier: A18n.onboarding.start.onbImgGematikLogo)
                        .accessibility(label: Text(L10n.onbImgGematikLogo))
                        .accessibility(sortPriority: 1.0)
                    Spacer()
                }.padding()

                VStack(spacing: 8) {
                    Image(decorative: Asset.Onboarding.appLogo)
                        .foregroundColor(Colors.primary900)
                        .accessibility(sortPriority: 1.0)
                        .padding(.bottom, -30)
                    Text(L10n.onbStrTxtTitle)
                        .foregroundColor(Colors.systemLabel)
                        .font(Font.largeTitle.weight(.bold))
                        .accessibility(identifier: A18n.onboarding.start.onbTxtStartTitle)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(L10n.onbStrTxtSubtitle)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }.padding([.leading, .trailing])
                    .accessibilityElement(children: .combine)
                    .accessibility(sortPriority: 2.0)

                Spacer()

                HStack(alignment: .bottom) {
                    Image(decorative: Asset.Onboarding.boyGrannyGrandpa)
                        .resizable()
                        .scaledToFit()
                        .accessibility(identifier: A18n.onboarding.start.onbImgMan1)
                        .accessibility(hint: Text(L10n.onbImgMan1))
                        .accessibility(sortPriority: 3.0)
                        .frame(maxHeight: geometry.size.height * 0.5)

                    Spacer()
                }
            }
        }
    }
}

struct OnboardingStartView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingStartView()
            OnboardingStartView()
                .preferredColorScheme(.dark)
            OnboardingStartView()
                .previewDevice("iPod touch (7th generation)")
        }
    }
}
