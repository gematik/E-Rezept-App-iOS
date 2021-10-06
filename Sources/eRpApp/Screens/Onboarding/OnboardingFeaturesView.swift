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

struct OnboardingFeaturesView: View {
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Image(decorative: Asset.Onboarding.handMitKarte)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding([.top, .leading], 8)
                        .accessibility(identifier: A18n.onboarding.features.onbImgHandWithCard)
                        .accessibility(hint: Text(L10n.onbImgGematikLogo))
                        .accessibility(sortPriority: 1.0)
                        .padding()
                        .frame(maxHeight: geometry.size.height * 0.5)

                    Text(L10n.onbFeaTxtTitle)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Colors.primary900)
                        .font(Font.title3.weight(.bold))
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibility(identifier: A18n.onboarding.features.onbTxtFeaturesTitle)
                        .padding([.leading, .trailing])

                    VStack(spacing: 8) {
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {
                                OnboardingFeatureCheckmarkView()

                                Text(L10n.onbFeaTxtFeature1)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding()

                            HStack(alignment: .top) {
                                OnboardingFeatureCheckmarkView()

                                Text(L10n.onbFeaTxtFeature2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding([.leading, .trailing])

                            HStack(alignment: .top) {
                                OnboardingFeatureCheckmarkView()

                                Text(L10n.onbFeaTxtFeature3)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding()
                        }

                    }.padding([.leading, .trailing])
                        .accessibilityElement(children: .combine)
                        .accessibility(sortPriority: 2.0)

                    Spacer()
                }
            }
        }
    }
}

struct OnboardingFeaturesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingFeaturesView()
            OnboardingFeaturesView()
                .preferredColorScheme(.dark)
            OnboardingFeaturesView()
                .previewDevice("iPod touch (7th generation)")
        }
    }
}
