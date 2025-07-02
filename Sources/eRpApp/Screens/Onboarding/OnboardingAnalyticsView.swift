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

struct OnboardingAnalyticsView: View {
    @Perception.Bindable var store: StoreOf<OnboardingDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                ScrollView {
                    VStack {
                        OnboardingProgressView(currentPage: .third)

                        TitleView {
                            store.send(.showAnalyticsDetail)
                        }
                        .padding(.bottom)

                        // [REQ:gemSpec_eRp_FdV:A_19184] Information for the user what is collected
                        VStack(alignment: .leading, spacing: 16) {
                            Group {
                                Label(title: {
                                    Text(L10n.onbAnaTxtUsability)
                                }, icon: {
                                    Image(systemName: SFSymbolName.wandAndRays)
                                        .foregroundColor(Colors.primary700)
                                        .font(.title3.weight(.bold))
                                })

                                Label(title: {
                                    Text(L10n.onbAnaTxtAccessibility)
                                }, icon: {
                                    Image(systemName: SFSymbolName.accessibility)
                                        .foregroundColor(Colors.primary700)
                                        .font(.title3.weight(.bold))
                                })

                                Label(title: {
                                    Text(L10n.onbAnaTxtCrash)
                                }, icon: {
                                    Image(systemName: SFSymbolName.ant)
                                        .foregroundColor(Colors.primary700)
                                        .font(.title3.weight(.bold))
                                })
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                        }
                        .padding(.vertical)
                    }
                }
                Spacer()

                Text(L10n.onbAnaTxtChangeable)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Colors.systemLabelSecondary)
                    .padding(.horizontal)
                    .padding(.bottom, 8)

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
}

extension OnboardingAnalyticsView {
    struct TitleView: View {
        var action: () -> Void
        @State var calculatedHeight = CGFloat(1)

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(L10n.onbAnaTxtTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .font(Font.title.weight(.bold))
                    .accessibility(identifier: A11y.onboarding.analytics.onbAnaTxtTitle)
                    .padding(.top, 22)

                UIKitTextView(
                    attributedString: attributedSubtitle,
                    calculatedHeight: $calculatedHeight,
                    font: .preferredFont(forTextStyle: .subheadline),
                    foregroundColor: .secondaryLabel
                ) { _ in
                    action()
                }
                .frame(height: calculatedHeight)
                .accessibilityElement(children: .contain)
                .accessibility(identifier: A11y.onboarding.analytics.onbAnaTxtSubtitle)
                .padding(.top, 8)
            }
        }

        var attributedSubtitle: AttributedString {
            let text = L10n.onbAnaTxtSubtitleWithLink(
                Markdown.analytics(L10n.onbAnaBtnSubtitleLink.text).link
            ).text
            return (try? AttributedString(markdown: text)) ?? AttributedString(text)
        }
    }

    enum Markdown: Equatable {
        case analytics(_ name: String)

        var link: String {
            switch self {
            case let .analytics(name):
                return "[\(name)](screen://OnboardingAnalyticsDetailView)"
            }
        }
    }
}

#Preview {
    OnboardingAnalyticsView(
        store: .init(
            initialState: OnboardingDomain.Dummies.state
        ) {
            OnboardingDomain()
        }
    )
}
