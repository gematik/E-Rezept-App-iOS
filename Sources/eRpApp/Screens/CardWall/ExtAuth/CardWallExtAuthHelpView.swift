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

struct CardWallExtAuthHelpView: View {
    var body: some View {
        // SF / Body
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.cdwTxtExtauthHelpCaption)
                    .font(.title.bold())

                Text(L10n.cdwTxtExtauthHelpDescription)
                    .font(.footnote)
                    .foregroundColor(Colors.systemLabelSecondary)
                    .padding(.bottom, 32)

                VStack(spacing: 32) {
                    HStack(alignment: .top) {
                        OnboardingFeatureCheckmarkView()
                        Text(L10n.cdwTxtExtauthHelpInfo1)
                            .font(.body)
                    }
                    HStack(alignment: .top) {
                        OnboardingFeatureCheckmarkView()
                        Text(L10n.cdwTxtExtauthHelpInfo2)
                            .font(.body)
                    }
                    HStack(alignment: .top) {
                        OnboardingFeatureCheckmarkView()
                        Text(L10n.cdwTxtExtauthHelpInfo3)
                            .font(.body)
                    }
                    HStack(alignment: .top) {
                        OnboardingFeatureCheckmarkView()
                        Text(L10n.cdwTxtExtauthHelpInfo4)
                            .font(.body)
                    }
                    HStack(alignment: .top) {
                        OnboardingFeatureCheckmarkView()
                        Text(L10n.cdwTxtExtauthHelpInfo5)
                            .font(.body)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(L10n.cdwTxtExtauthHelpTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        CardWallExtAuthHelpView()
    }
}
