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

struct OnboardingAnalyticsDetailView: View {
    @Perception.Bindable var store: StoreOf<OnboardingDomain>

    @State var calculatedHeight = CGFloat(1)

    var body: some View {
        WithPerceptionTracking {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(L10n.onbAnaDtlTxtTitle)
                            .font(.title2)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.onbAnaDtlTxtSubtitleWhy)
                                .font(.body.weight(.bold))
                            Text(L10n.onbAnaDtlTxtBodyWhy)
                                .font(.body)
                        }

                        VStack(alignment: .leading, spacing: 0) {
                            Text(L10n.onbAnaDtlTxtSubtitleHow)
                                .font(.body.weight(.bold))
                                .padding(.bottom, 8)
                            Text(L10n.onbAnaDtlTxtBodyHowPart1)
                                .font(.body)
                            UIKitTextView(
                                attributedString: list(input: L10n.onbAnaDtlTxtBodyHowPart2.text),
                                calculatedHeight: $calculatedHeight,
                                font: .preferredFont(forTextStyle: .body),
                                foregroundColor: .label
                            ) { _ in }
                                .frame(height: calculatedHeight)
                        }

                        Text(L10n.onbAnaDtlTxtBodyHowPart3)
                            .font(.body)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.onbAnaDtlTxtSubtitleOptOut)
                                .font(.body.weight(.bold))
                            Text(L10n.onbAnaDtlTxtBodyOptOut)
                                .font(.body)
                        }
                    }
                }
                Spacer()

                // [REQ:BSI-eRp-ePA:O.Purp_3#4] Button allows tracking
                Button(action: {
                    store.send(.allowTracking)
                }, label: {
                    Text(L10n.onbAnaBtnAllow)
                        .padding(.horizontal, 64)
                        .padding(.vertical)
                })
                    .accessibility(identifier: A18n.onboarding.analytics.onbAnaBtnAllow)
                    .font(Font.body.weight(.semibold))
                    .foregroundColor(Colors.systemColorWhite)
                    .background(Colors.primary700)
                    .cornerRadius(16)

                // [REQ:BSI-eRp-ePA:O.Purp_3#4] Button denies tracking
                Button(action: {
                    store.send(.denyTracking)
                }, label: {
                    Text(L10n.onbAnaBtnDeny)
                        .padding(.horizontal, 71)
                        .padding(.vertical)
                })
                    .accessibility(identifier: A18n.onboarding.analytics.onbAnaBtnDeny)
                    .font(Font.body.weight(.semibold))
                    .foregroundColor(Colors.systemColorWhite)
                    .background(Colors.primary700)
                    .cornerRadius(16)
            }
            .padding()
        }
    }

    func list(input: String) -> AttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.firstLineHeadIndent = 5
        paragraph.headIndent = 17

        let output = NSAttributedString(
            string: input,
            attributes: [.paragraphStyle: paragraph]
        )
        return AttributedString(output)
    }
}

#Preview {
    OnboardingAnalyticsDetailView(
        store: .init(
            initialState: OnboardingDomain.Dummies.state
        ) {
            OnboardingDomain()
        }
    )
}
