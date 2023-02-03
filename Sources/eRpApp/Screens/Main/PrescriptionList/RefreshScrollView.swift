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

struct RefreshScrollView<Content: View, StickyHeader: View>: View {
    let store: PrescriptionListDomain.Store
    let content: Content
    let header: StickyHeader

    let action: () -> Void

    @ObservedObject
    var viewStore: ViewStore<ViewState, PrescriptionListDomain.Action>

    init(
        store: PrescriptionListDomain.Store,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> StickyHeader,
        action: @escaping () -> Void
    ) {
        self.store = store
        self.content = content()
        self.header = header()
        self.action = action
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        var isNotLoading: Bool
        var hasOpenPrescriptions: Bool
        var isReedemable: Bool

        init(state: PrescriptionListDomain.State) {
            isNotLoading = !state.loadingState.isLoading
            hasOpenPrescriptions = !state.prescriptions.filter { !$0.isArchived }.isEmpty
            isReedemable = !state.prescriptions.filter(\.isRedeemable).isEmpty
        }
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ScrollViewWithStickyHeader(
                applyBackgroundBlur: false,
                header: {
                    header
                }, content: {
                    content
                        .padding(.bottom, viewStore.hasOpenPrescriptions ? 80 : 28)
                }
            )

            if viewStore.isReedemable {
                Button {
                    action()
                } label: {
                    Text(L10n.mainBtnRedeem)
                }
                .buttonStyle(.primary)
                .padding(.horizontal, 64)
                .padding(.vertical)
                .accessibilityIdentifier(A11y.mainScreen.erxBtnRedeemPrescriptions)
            }
        }
        .introspectScrollView { scrollView in
            let refreshControl: RefreshControl
            if let control = scrollView.refreshControl as? RefreshControl {
                refreshControl = control
            } else {
                refreshControl = RefreshControl()
                scrollView.refreshControl = refreshControl
            }
            refreshControl.onRefreshAction = {
                viewStore.send(.refresh)
            }
            if viewStore.isNotLoading, refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
        }
    }
}
