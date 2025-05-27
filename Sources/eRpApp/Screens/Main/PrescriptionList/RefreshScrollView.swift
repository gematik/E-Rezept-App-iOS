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
import Perception
import SwiftUI
import SwiftUIIntrospect

struct RefreshScrollView<Content: View, StickyHeader: View>: View {
    @Perception.Bindable var store: StoreOf<PrescriptionListDomain>
    let content: Content
    let header: StickyHeader

    let action: () -> Void

    init(
        store: StoreOf<PrescriptionListDomain>,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> StickyHeader,
        action: @escaping () -> Void
    ) {
        self.store = store
        self.content = content()
        self.header = header()
        self.action = action
    }

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottomLeading) {
                ScrollViewWithStickyHeader(
                    applyBackgroundBlur: false,
                    header: {
                        header
                    }, content: {
                        let hasOpenPrescriptions = !store.prescriptions.filter { !$0.isArchived }.isEmpty
                        content
                            .padding(.bottom, hasOpenPrescriptions ? 80 : 28)
                    }
                )
                .introspect(.scrollView, on: .iOS(.v15, .v16, .v17, .v18)) { scrollView in
                    let refreshControl: RefreshControl
                    if let control = scrollView.refreshControl as? RefreshControl {
                        refreshControl = control
                    } else {
                        refreshControl = RefreshControl()
                        scrollView.refreshControl = refreshControl
                    }
                    refreshControl.onRefreshAction = {
                        store.send(.refresh)
                    }
                    if !store.loadingState.isLoading, refreshControl.isRefreshing {
                        refreshControl.endRefreshing()
                    }
                }

                let isReedemable = !store.prescriptions.filter(\.isPharmacyRedeemable).isEmpty
                if isReedemable {
                    HStack {
                        Spacer()
                        Button {
                            action()
                        } label: {
                            if store.showRedeemDiGaButton {
                                Text(L10n.digaDtlBtnMainRequest)
                            } else {
                                Text(L10n.mainBtnRedeem)
                            }
                        }
                        .buttonStyle(.primaryHugging)
                        .padding(.vertical)
                        .accessibilityIdentifier(A11y.mainScreen.erxBtnRedeemPrescriptions)
                        Spacer()
                    }
                }
            }
        }
    }
}
