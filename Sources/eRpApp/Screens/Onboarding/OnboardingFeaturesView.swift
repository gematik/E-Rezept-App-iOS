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

struct OnboardingFeaturesView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 0) {
                TitleView()

                FeatureView(title: L10n.onbFeaTxtFeature1, systemImage: SFSymbolName.paperplane)
                FeatureView(title: L10n.onbFeaTxtFeature2, systemImage: SFSymbolName.pills)
                FeatureView(title: L10n.onbFeaTxtFeature3, systemImage: SFSymbolName.trayAndArrowDown)

                Spacer(minLength: 110)
            }
            .padding()
            .labelStyle(.plain)
        }
    }

    private struct TitleView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(decorative: Asset.Onboarding.womanWithPhone)
                    Spacer()
                }
                .padding(.top, 10)

                Text(L10n.onbWelTxtTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .font(Font.title.weight(.bold))
                    .accessibility(identifier: A18n.onboarding.welcome.onbTxtWelcomeTitle)
                    .padding(.top, 22)
                    .padding(.bottom, 14)
            }
        }
    }

    private struct FeatureView: View {
        let title: StringAsset
        let systemImage: String

        var body: some View {
            HStack {
                Image(systemName: systemImage)
                    .font(Font.headline.weight(.semibold))
                    .foregroundColor(Colors.primary)
                    .padding(.trailing)
                Text(title)
            }
            .padding(.vertical, 10)
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
