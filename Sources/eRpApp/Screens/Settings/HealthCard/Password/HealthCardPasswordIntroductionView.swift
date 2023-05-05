//
//  Copyright (c) 2023 gematik GmbH
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

import Combine
import ComposableArchitecture
import eRpKit
import eRpStyleKit
import SwiftUI

struct HealthCardPasswordIntroductionView: View {
    let store: HealthCardPasswordDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, HealthCardPasswordDomain.Action>

    init(store: HealthCardPasswordDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let mode: HealthCardPasswordDomain.Mode
        let destinationTag: HealthCardPasswordDomain.Destinations.State.Tag

        init(state: HealthCardPasswordDomain.State) {
            mode = state.mode
            destinationTag = state.destination.tag
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 8) {
                        // headline
                        viewStore.mode.headLineText
                            .font(.title.bold())
                            .accessibility(identifier: A11y.settings.card.stgTxtCardResetIntroHeadline)

                        VStack(alignment: .leading, spacing: 16) {
                            // subheadline
                            Text(L10n.stgTxtCardResetIntroSubheadline)
                                .font(Font.body.weight(.semibold))

                            // 1st checkmark
                            Label(
                                title: { Text(L10n.stgTxtCardResetIntroNeedYourCard) },
                                icon: {
                                    Image(systemName: SFSymbolName.checkmarkCircleFill)
                                        .foregroundColor(Colors.secondary500)
                                        .font(.title3)
                                }
                            )
                            .accessibility(identifier: A11y.settings.card.stgTxtCardResetIntroNeedYourCard)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)

                            // 2nd checkmark
                            Label(
                                title: { viewStore.mode.checkmarkText },
                                icon: {
                                    Image(systemName: SFSymbolName.checkmarkCircleFill)
                                        .foregroundColor(Colors.secondary500)
                                        .font(.title3)
                                }
                            )
                            .accessibility(identifier: A11y.settings.card.stgTxtCardResetIntroNeedYourCardsPin)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)

                            // Hint
                            VStack(spacing: 8) {
                                viewStore.mode.hintText
                                    .foregroundColor(Color(.secondaryLabel))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .font(.subheadline)
                        }
                        .padding(.top, 32)
                    }.padding()
                }
            }

            Spacer(minLength: 0)

            GreyDivider()

            NavigationLink(
                isActive: .init(
                    get: {
                        viewStore.destinationTag != .introduction
                    },
                    set: { active in
                        if active {
                            viewStore.send(.advance)
                        } else {
                            viewStore.send(.setNavigation(tag: .introduction))
                        }
                    }
                ),
                destination: {
                    HealthCardPasswordCanView(store: store)
                },
                label: {
                    Text(L10n.stgBtnCardResetAdvance)
                }
            )
            .buttonStyle(eRpStyleKit.PrimaryButtonStyle(enabled: true, destructive: false))
            .accessibility(identifier: A11y.settings.card.stgBtnCardResetAdvance)
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension HealthCardPasswordDomain.Mode { // swiftlint:disable:this no_extension_access_modifier
    var headLineText: Text {
        switch self {
        case .forgotPin: return Text(L10n.stgTxtCardResetIntroForgotPin)
        case .setCustomPin: return Text(L10n.stgTxtCardResetIntroCustomPin)
        case .unlockCard: return Text(L10n.stgTxtCardResetIntroUnlockCard)
        }
    }

    var checkmarkText: Text {
        switch self {
        case .forgotPin: return Text(L10n.stgTxtCardResetIntroNeedYourCardsPuk)
        case .setCustomPin: return Text(L10n.stgTxtCardResetIntroNeedYourCardsPin)
        case .unlockCard: return Text(L10n.stgTxtCardResetIntroNeedYourCardsPuk)
        }
    }

    var hintText: Text {
        switch self {
        case .forgotPin: return Text(L10n.stgTxtCardResetIntroHint)
        case .setCustomPin: return Text(L10n.stgTxtCardResetIntroHintCustomPin)
        case .unlockCard: return Text(L10n.stgTxtCardResetIntroHint)
        }
    }
}

struct HealthCardPasswordIntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HealthCardPasswordIntroductionView(
                store: HealthCardPasswordDomain.Dummies.store
            )
        }
    }
}
