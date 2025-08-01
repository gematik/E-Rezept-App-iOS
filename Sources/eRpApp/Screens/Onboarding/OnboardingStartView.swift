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

import eRpStyleKit
import SwiftUI

struct OnboardingStartView: View {
    var action: () -> Void

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image(decorative: Asset.Onboarding.logoNeuFahne)
                        .padding([.top, .leading], 8)
                        .foregroundColor(Colors.primary900)
                    Image(decorative: Asset.Onboarding.logoNeuGematik)
                        .padding(.top, 8)
                        .foregroundColor(Colors.primary900)
                    Spacer()
                }
                .padding()
                .frame(alignment: .topLeading)

                Spacer()
            }

            VStack {
                Spacer()

                VStack(spacing: 0) {
                    Image(decorative: Asset.Onboarding.appLogo)
                        .foregroundColor(Colors.primary900)
                        .padding(.bottom, 16)
                    Text(L10n.onbStrTxtTitle)
                        .foregroundColor(Colors.systemLabel)
                        .font(Font.largeTitle.weight(.bold))
                        .padding(.bottom, 4)
                        .accessibility(identifier: A11y.onboarding.start.onbTxtStartTitle)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(L10n.onbStrTxtSubtitle)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 32)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)

                Button(action: {
                    action()
                }, label: {
                    Text(L10n.onbBtnStart)
                        .accessibility(identifier: A11y.onboarding.start.onbBtnStart)
                        .accessibility(hint: Text(L10n.onbBtnStart))
                        .accessibility(label: Text(L10n.onbBtnStart))
                })
                    .buttonStyle(.primaryHugging)
                    .padding(.bottom, 32)

                Spacer()
            }

            VStack {
                Spacer()
                HStack {
                    Image(decorative: Asset.Onboarding.Start.pharmacistMale)
                        .padding(.bottom, 275)
                    Spacer()
                    Image(decorative: Asset.Onboarding.Start.girl)
                        .padding(.bottom, 15)
                }
                Spacer()
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(decorative: Asset.Onboarding.Start.male).padding(.trailing, 56)
                    Spacer()
                }
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(decorative: Asset.Onboarding.Start.female).padding(.leading, 56)
                    Spacer()
                }
            }

            VStack {
                Spacer()
                HStack {
                    Image(decorative: Asset.Onboarding.Start.pharmacistFemale)
                    Spacer()
                    Image(decorative: Asset.Onboarding.Start.boy).padding(.bottom, 50)
                }
                .padding(.bottom, 70)
            }

            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    Spacer()
                    Image(decorative: Asset.Onboarding.Start.doctorMale)
                }
            }

            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    Spacer()
                    Image(decorative: Asset.Onboarding.Start.disabledMale).padding(.trailing, 16)
                    Spacer()
                    Image(decorative: Asset.Onboarding.Start.baby).padding(.trailing, 16)
                    Spacer()
                }
            }

            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    Image(decorative: Asset.Onboarding.Start.doctorFemale)
                    Spacer()
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct OnboardingStartView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingStartView {}
                .environment(\.locale, .init(identifier: "de"))
            OnboardingStartView {}
                .preferredColorScheme(.dark)
            OnboardingStartView {}
                .previewDevice("iPod touch (7th generation)")
        }
    }
}
