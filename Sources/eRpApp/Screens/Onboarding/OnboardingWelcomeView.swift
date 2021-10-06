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

struct OnboardingWelcomeView: View {
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    VStack(alignment: .leading) {
                        Text(L10n.onbWelTxtTitle)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Colors.primary900)
                            .font(Font.title.weight(.bold))
                            .accessibility(identifier: A18n.onboarding.welcome.onbTxtWelcomeTitle)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top)

                        Text(L10n.onbWelTxtExplanation)
                            .foregroundColor(Colors.systemLabel)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top)
                    }
                    .padding([.leading, .trailing])
                    .accessibilityElement(children: .combine)

                    Spacer()

                    HStack(alignment: .bottom) {
                        Image(decorative: Asset.Onboarding.apotheker)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .accessibility(identifier: A18n.onboarding.welcome.onbImgFrau1)
                            .accessibility(hint: Text(L10n.onbWelImgFrau1))
                            .accessibility(sortPriority: 1.0)
                            .frame(maxHeight: geometry.size.height * 0.6)

                        Spacer()
                    }
                }.frame(minHeight: geometry.size.height)
            }
        }
    }
}

struct OnboardingWelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingWelcomeView()
            OnboardingWelcomeView()
                .preferredColorScheme(.dark)
            OnboardingWelcomeView()
                .previewDevice("iPod touch (7th generation)")
        }
    }
}
