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

extension AppAuthenticationPasswordDomain.State {
    var showUnsuccessfulAttemptMessage: Bool {
        !(lastMatchResultSuccessful ?? true)
    }
}

struct AppAuthenticationPasswordView: View {
    @Perception.Bindable var store: StoreOf<AppAuthenticationPasswordDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading) {
                SecureFieldWithReveal(titleKey: L10n.authTxtPasswordPlaceholder,
                                      accessibilityLabelKey: L10n.authTxtPasswordLabel,
                                      text: $store.password.sending(\.setPassword),
                                      textContentType: .password) {
                    store.send(.loginButtonTapped, animation: .default)
                }
                .padding()
                .font(Font.body)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            store.showUnsuccessfulAttemptMessage ? Colors.red600 : Color(.systemGray3),
                            lineWidth: 1
                        )
                )
                .padding(.horizontal)
                .accessibility(identifier: A11y.auth.authEdtPasswordInput)

                if store.showUnsuccessfulAttemptMessage {
                    UnsuccessfulAttemptMessageView()
                        .padding(.horizontal)
                        .padding(.top, 4)
                }

                PrimaryTextButton(
                    text: L10n.authBtnPasswordContinue,
                    a11y: A11y.auth.authBtnPasswordContinue,
                    isEnabled: !store.password.isEmpty,
                    useFullWidth: false
                ) {
                    store.send(.loginButtonTapped, animation: .default)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)

                if store.showUnsuccessfulAttemptMessage {
                    FooterView()
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
            .padding(.vertical)
        }
    }

    private struct UnsuccessfulAttemptMessageView: View {
        var body: some View {
            Text(L10n.authTxtPasswordFailure)
                .foregroundColor(Colors.red600)
                .font(.footnote)
                .accessibility(identifier: A11y.auth.authTxtPasswordFailure)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    struct FooterView: View {
        @State var calculatedHeight = CGFloat(100)
        var body: some View {
            VStack {
                LinksAwareTextView(
                    text: L10n.authTxtBiometricsFooter.text,
                    links: [
                        L10n.authTxtBiometricsFooterUrlDisplay.text:
                            L10n.authTxtBiometricsFooterUrlLink.text,
                        L10n.authTxtBiometricsFooterEmailDisplay.text:
                            L10n.authTxtBiometricsFooterEmailLink.text,
                    ],
                    calculatedHeight: $calculatedHeight
                )
                .frame(height: calculatedHeight)
                .padding(5)
            }
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.systemGray3)),
                alignment: .top
            )
        }
    }
}

struct AppAuthenticationPasswordView_Preview: PreviewProvider {
    static var previews: some View {
        AppAuthenticationPasswordView(store: AppAuthenticationPasswordDomain.Dummies.store)

        AppAuthenticationPasswordView(
            store: AppAuthenticationPasswordDomain.Dummies.storeFor(
                AppAuthenticationPasswordDomain.State(
                    password: "ABC",
                    lastMatchResultSuccessful: false
                )
            )
        )
    }
}
