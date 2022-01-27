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

import ComposableArchitecture
import eRpKit
import SwiftUI

struct OnboardingNewProfileView: View {
    let store: OnboardingNewProfileDomain.Store

    @ObservedObject
    var viewStore: ViewStore<OnboardingNewProfileDomain.State, OnboardingNewProfileDomain.Action>

    init(store: OnboardingNewProfileDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack {
                TitleView()
                PrimaryTextFieldView(
                    placeholder: L10n.onbPrfTxtPlaceholder,
                    text: viewStore.binding(get: \.name, send: OnboardingNewProfileDomain.Action.setName),
                    a11y: A11y.onboarding.newProfile.onbPrfTxtField
                )

                FootnoteView(text: L10n.onbPrfTxtFootnote, a11y: A11y.onboarding.newProfile.onbPrfTxtFootnote)
            }
            .padding()
        }
        .alert(store.scope(state: \.alertState), dismiss: OnboardingNewProfileDomain.Action.dismissAlert)
    }

    private struct TitleView: View {
        var body: some View {
            Text(L10n.onbPrfTxtTitle)
                .multilineTextAlignment(.center)
                .foregroundColor(Colors.primary900)
                .font(Font.title2.weight(.bold))
                .accessibility(identifier: A11y.onboarding.newProfile.onbPrfTxtTitle)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 32)
                .padding(.top)
        }
    }
}

struct OnboardingNewProfileView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingNewProfileView(
                store: OnboardingNewProfileDomain.Dummies.store(
                    with: OnboardingNewProfileDomain.State(name: "Anna Vetter")
                )
            )
            OnboardingNewProfileView(
                store: OnboardingNewProfileDomain.Dummies.store
            )
            OnboardingNewProfileView(
                store: OnboardingNewProfileDomain.Dummies.store
            )
            .preferredColorScheme(.dark)
        }
    }
}
