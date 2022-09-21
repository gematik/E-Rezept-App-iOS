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

import Combine
import ComposableArchitecture
import eRpKit
import eRpStyleKit
import SwiftUI

struct ResetRetryCounterCanView: View {
    let store: ResetRetryCounterDomain.Store
    @ObservedObject var viewStore: ViewStore<ResetRetryCounterDomain.State, ResetRetryCounterDomain.Action>

    init(store: ResetRetryCounterDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack {
            CANView(store: store)

            Spacer(minLength: 0)

            GreyDivider()

            NavigationLink(
                isActive: .init(
                    get: {
                        viewStore.state.route != ResetRetryCounterDomain.Route.introduction &&
                            viewStore.state.route != ResetRetryCounterDomain.Route.can
                    },
                    set: { active in
                        if active {
                            viewStore.send(.advance)
                        } else {
                            viewStore.send(.setNavigation(tag: .can))
                        }
                    }
                ),
                destination: {
                    ResetRetryCounterPukView(store: store)
                },
                label: {
                    EmptyView()
                }
            )
            .accessibility(hidden: true)

            Button(
                action: { viewStore.send(.advance) },
                label: { Text(L10n.stgBtnCardResetAdvance) }
            )
            .disabled(!viewStore.canMayAdvance)
            .buttonStyle(eRpStyleKit.PrimaryButtonStyle(enabled: viewStore.canMayAdvance, destructive: false))
            .accessibility(identifier: A11y.settings.card.stgBtnCardResetAdvance)
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private struct CANView: View {
        var store: ResetRetryCounterDomain.Store
        @State var showAnimation = true
        @State var scannedCan: ScanCAN?

        var body: some View {
            WithViewStore(store) { viewStore in
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 8) {
                        if showAnimation {
                            HStack(alignment: .center) {
                                Spacer()
                                Image(Asset.CardWall.cardwallCard)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 343, maxHeight: 215, alignment: .center)
                                    .accessibility(identifier: A11y.cardWall.canInput.cdwImgCanCard)
                                    .accessibility(label: Text(L10n.cdwImgCanCardLabel))
                                    .padding(.bottom, 24)
                                    .transition(.asymmetric(insertion: .move(edge: .trailing),
                                                            removal: .move(edge: .leading)))

                                Spacer()
                            }
                        }
                        Text(L10n.cdwTxtCanSubtitle)
                            .foregroundColor(Colors.systemLabel)
                            .font(.title2)
                            .bold()
                            .padding(.top)
                            .accessibility(identifier: A11y.cardWall.canInput.cdwTctCanHeader)

                        Text(L10n.cdwTxtCanDescription)
                            .foregroundColor(Colors.systemLabel)
                            .font(.body)
                            .accessibility(identifier: A11y.cardWall.canInput.cdwTxtCanInstruction)
                    }
                    .padding()

                    CardWallCANInputView(
                        can: viewStore.binding(get: \.can) { .canUpdateCan($0) }
                    ) {}
                        .padding(.top)
                }
                .onReceive(NotificationCenter.default
                    .publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
                        withAnimation {
                            showAnimation = false
                        }
                }
                .onReceive(NotificationCenter.default
                    .publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
                        UIApplication.shared.dismissKeyboard()
                        withAnimation {
                            showAnimation = true
                        }
                }
            }
            .respectKeyboardInsets()
            .onTapGesture {
                UIApplication.shared.dismissKeyboard()
            }
        }
    }
}

struct ResetRetryCounterCanView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ResetRetryCounterCanView(
                store: ResetRetryCounterDomain.Dummies.store
            )
        }
    }
}
