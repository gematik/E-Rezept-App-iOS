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

import ComposableArchitecture
import SwiftUI

struct DirectAssignedHintView: View {
    let store: PrescriptionDetailDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, PrescriptionDetailDomain.Action>

    init(store: PrescriptionDetailDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let routeTag: PrescriptionDetailDomain.Route.Tag?

        init(state: PrescriptionDetailDomain.State) {
            routeTag = state.route?.tag
        }
    }

    var body: some View {
        Button(
            action: { viewStore.send(.showDirectAssignment) },
            label: {
                DirectAssignmentButton()
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnDirectAssignment)
            }
        )
        .sheet(
            isPresented: Binding<Bool>(
                get: { viewStore.routeTag == .directAssignment },
                set: { show in
                    if !show {
                        viewStore.send(.setNavigation(tag: nil))
                    }
                }
            ),
            onDismiss: {},
            content: {
                NavigationView {
                    DirectAssignmentView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                CloseButton { viewStore.send(.setNavigation(tag: nil)) }
                                    .embedToolbarContent()
                                    .accessibilityIdentifier(A11y.directAssignment.davBtnClose)
                            }
                        }
                        .navigationTitle("")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .accentColor(Colors.primary600)
                .navigationViewStyle(StackNavigationViewStyle())
            }
        )
    }

    struct DirectAssignmentView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.davTxtDirectAssignmentTitle)
                    .font(.headline)
                    .accessibilityIdentifier(A11y.directAssignment.davTxtDirectAssignmentTitle)
                Text(L10n.davTxtDirectAssignmentHint)
                    .font(Font.body)
                    .foregroundColor(Colors.systemLabelSecondary)
                    .accessibilityIdentifier(A11y.directAssignment.davTxtDirectAssignmentHint)
                Spacer()
            }
            .padding()
        }
    }

    struct DirectAssignmentButton: View {
        var body: some View {
            HStack(spacing: 8) {
                Text(L10n.prscDtlBtnDirectAssignment)
                    .font(Font.subheadline)
                    .foregroundColor(Colors.primary900)
                Image(systemName: SFSymbolName.info)
                    .font(Font.subheadline.weight(.semibold))
                    .foregroundColor(Colors.primary600)
            }
            .padding(.init(top: 8, leading: 12, bottom: 8, trailing: 12))
            .background(Colors.primary100)
            .cornerRadius(8)
        }
    }
}
