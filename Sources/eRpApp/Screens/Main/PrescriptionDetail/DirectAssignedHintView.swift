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
        let destinationTag: PrescriptionDetailDomain.Destinations.State.Tag?

        init(state: PrescriptionDetailDomain.State) {
            destinationTag = state.destination?.tag
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { viewStore.send(.setNavigation(tag: .directAssignmentInfo)) }, label: {
                Label(L10n.prscDtlBtnDirectAssignment, systemImage: SFSymbolName.info)
                    .labelStyle(.blueFlag)
            })
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnDirectAssignment)

            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .smallSheet(
                    isPresented: Binding<Bool>(
                        get: { viewStore.destinationTag == .directAssignmentInfo },
                        set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: nil))
                            }
                        }
                    ),
                    onDismiss: {},
                    content: {
                        DirectAssignmentDrawerView()
                    }
                )
                .accessibility(hidden: true)
        }
    }

    struct DirectAssignmentDrawerView: View {
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
            .background(Colors.systemBackground.ignoresSafeArea())
        }
    }
}
