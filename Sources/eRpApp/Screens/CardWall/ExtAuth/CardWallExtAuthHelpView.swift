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

import ComposableArchitecture
import eRpStyleKit
import SwiftUI

struct CardWallExtAuthHelpView: View {
    @Perception.Bindable var store: StoreOf<CardWallExtAuthHelpDomain>

    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                switch store.insuranceType {
                case .gKV, .unknown:
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.cdwTxtExtauthHelpCaption)
                            .font(.title.bold())

                        Text(L10n.cdwTxtExtauthHelpDescription)
                            .font(.footnote)
                            .foregroundColor(Colors.systemLabelSecondary)
                            .padding(.bottom, 32)

                        VStack(alignment: .leading, spacing: 32) {
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
                case .pKV:
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.cdwTxtExtauthHelpCaption)
                            .font(.title.bold())

                        Text(L10n.cdwTxtExtauthHelpDescription)
                            .font(.footnote)
                            .foregroundColor(Colors.systemLabelSecondary)
                            .padding(.bottom, 32)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.cdwTxtExtauthHelpTitlePkv1)
                                .font(.body.weight(.bold))
                            HStack(alignment: .top) {
                                OnboardingFeatureCheckmarkView()
                                Text(L10n.cdwTxtExtauthHelpInfoPkv1)
                                    .font(.body)
                            }
                            HStack(alignment: .top) {
                                OnboardingFeatureCheckmarkView()
                                Text(L10n.cdwTxtExtauthHelpInfoPkv2)
                                    .font(.body)
                            }
                            HStack(alignment: .top) {
                                OnboardingFeatureCheckmarkView()
                                Text(L10n.cdwTxtExtauthHelpInfoPkv3)
                                    .font(.body)
                            }.padding(.bottom, 32)

                            Text(L10n.cdwTxtExtauthHelpTitlePkv2)
                                .font(.body.weight(.bold))
                            HStack(alignment: .top) {
                                OnboardingFeatureCheckmarkView()
                                Text(L10n.cdwTxtExtauthHelpInfoPkv4)
                                    .font(.body)
                            }.padding(.bottom, 32)

                            Text(L10n.cdwTxtExtauthHelpTitlePkv3)
                                .font(.body.weight(.bold))
                            HStack(alignment: .top) {
                                OnboardingFeatureCheckmarkView()
                                Text(L10n.cdwTxtExtauthHelpInfoPkv5)
                                    .font(.body)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(L10n.cdwTxtExtauthHelpTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview("GVK") {
    NavigationStack {
        CardWallExtAuthHelpView(
            store: CardWallExtAuthHelpDomain.Dummies.store
        )
    }
}

#Preview("PKV") {
    NavigationStack {
        CardWallExtAuthHelpView(
            store: CardWallExtAuthHelpDomain.Dummies.store(
                for: CardWallExtAuthHelpDomain.Dummies.pkvState
            )
        )
    }
}
