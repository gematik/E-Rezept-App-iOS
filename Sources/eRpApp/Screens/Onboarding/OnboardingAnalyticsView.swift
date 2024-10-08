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

import ComposableArchitecture
import eRpStyleKit
import SwiftUI

struct OnboardingAnalyticsView: View {
    var action: () -> Void

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    TitleView()
                        .padding()

                    // [REQ:gemSpec_eRp_FdV:A_19184] Information for the user what is collected
                    VStack(alignment: .leading, spacing: 16) {
                        Group {
                            Text(L10n.onbAnaTxtHeader)
                                .font(Font.body.weight(.semibold))

                            Label(title: {
                                Text(L10n.onbAnaTxtUsability)
                            }, icon: {
                                Image(systemName: SFSymbolName.sparkles)
                                    .foregroundColor(Colors.primary600)
                                    .font(.title3)
                            })

                            Label(title: {
                                Text(L10n.onbAnaTxtCrash)
                            }, icon: {
                                Image(systemName: SFSymbolName.boltFill)
                                    .foregroundColor(Colors.primary600)
                                    .font(.title2)
                            })

                            Label(title: {
                                Text(L10n.onbAnaTxtAnonymouse)
                            }, icon: {
                                Image(systemName: SFSymbolName.person)
                                    .foregroundColor(Colors.primary600)
                                    .font(.title2)
                            })
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                    }
                    .padding()
                }
            }
            Spacer()

            Text(L10n.onbAnaTxtChangeable)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .foregroundColor(Colors.systemLabelSecondary)
                .padding(.bottom, 8)

            Button(action: action) {
                Text(L10n.onbAnaBtnNext)
                    .padding()
                    .padding(.horizontal, 64)
            }
            .accessibility(identifier: A18n.onboarding.analytics.onbAnaBtnContinue)
            .font(Font.body.weight(.semibold))
            .foregroundColor(Colors.systemColorWhite)
            .background(Colors.primary600)
            .cornerRadius(16)
        }
    }
}

extension OnboardingAnalyticsView {
    struct TitleView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(decorative: Asset.Onboarding.handsCircle)
                        .accessibilityHidden(true)

                    Spacer()
                }
                .padding(.top, 10)

                Text(L10n.onbAnaTxtTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .font(Font.title.weight(.bold))
                    .accessibility(identifier: A18n.onboarding.legalInfo.onbTxtLegalInfoTitle)
                    .padding(.top, 22)
            }
        }
    }
}

struct OnboardingAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingAnalyticsView {}
    }
}
