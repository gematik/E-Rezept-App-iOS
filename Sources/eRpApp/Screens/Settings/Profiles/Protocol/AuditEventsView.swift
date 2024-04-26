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

// [REQ:gemSpec_eRp_FdV:A_19177#1,A_19185#2] View displaying the audit events
// [REQ:BSI-eRp-ePA:O.Auth_5#3] View displaying the audit events
struct AuditEventsView: View {
    let store: AuditEventsDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, AuditEventsDomain.Action>

    init(store: AuditEventsDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let hasMoreContent: Bool
        let showBottomBanner: Bool
        let listState: ListState

        init(state: AuditEventsDomain.State) {
            hasMoreContent = state.nextPageUrl != nil
            showBottomBanner = state.needsAuthentication

            if state.needsAuthentication {
                listState = .needsAuthentication
            } else {
                if let entries = state.entries {
                    if entries.isEmpty {
                        listState = .emptyList
                    } else {
                        listState = .list(entries)
                    }
                } else {
                    listState = .loading
                }
            }
        }

        enum ListState: Equatable {
            case emptyList
            case list(IdentifiedArrayOf<AuditEventsDomain.State.AuditEvent>)
            case needsAuthentication
            case loading
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            AuditEventsListView(viewStore: viewStore)
            // Bottom banner
            if viewStore.showBottomBanner {
                HStack {
                    Text(L10n.stgTxtAuditEventsBannerMessage)
                        .font(Font.subheadline)
                        .accessibilityIdentifier(A11y.settings.auditEvents.stgTxtAuditEventsBottomBannerMessage)

                    Spacer()

                    Button(
                        action: {
                            viewStore.send(.showCardWall)
                        },
                        label: {
                            Text(L10n.stgTxtAuditEventsBannerConnect)
                                .accessibilityIdentifier(A11y.settings.auditEvents
                                    .stgBtnAuditEventsBottomBanner)
                        }
                    )
                    .buttonStyle(.tertiaryFilled)
                    .padding(.leading)
                }

                .padding(.horizontal, 16)
                .padding(.vertical)
                .background(Colors.primary100.ignoresSafeArea())
                .topBorder(strokeWith: 0.5, color: Colors.separator)
            }
        }
        .task {
            await viewStore.send(.task).finish()
        }
        .alert(
            store.scope(state: \.$destination, action: AuditEventsDomain.Action.destination),
            state: /AuditEventsDomain.Destinations.State.alert,
            action: AuditEventsDomain.Destinations.Action.alert
        )
        .fullScreenCover(
            store: store.scope(state: \.$destination, action: AuditEventsDomain.Action.destination),
            state: /AuditEventsDomain.Destinations.State.cardWall,
            action: AuditEventsDomain.Destinations.Action.cardWall(action:),
            content: CardWallIntroductionView.init(store:)
        )
        .navigationTitle(L10n.stgTxtAuditEventsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
    }

    struct AuditEventsListView: View {
        @ObservedObject var viewStore: ViewStore<ViewState, AuditEventsDomain.Action>

        var body: some View {
            switch viewStore.listState {
            case let .list(entries):
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        Group {
                            ForEach(entries) { entry in
                                VStack(alignment: .leading, spacing: 4) {
                                    if let title = entry.title {
                                        Text(title, placeholder: L10n.stgTxtAuditEventsMissingTitle)
                                            .font(.body.weight(.semibold))
                                            .multilineTextAlignment(.leading)
                                            .accessibility(identifier: A11y.settings.auditEvents
                                                .stgCtnAuditEventsEventTitle)
                                    }
                                    Text(entry.description, placeholder: L10n.stgTxtAuditEventsMissingDescription)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.leading)
                                        .accessibility(identifier: A11y.settings.auditEvents
                                            .stgCtnAuditEventsEventDescription)
                                    Text(entry.date, placeholder: L10n.stgTxtAuditEventsMissingDate)
                                        .font(.subheadline)
                                        .foregroundColor(Color(.secondaryLabel))
                                        .multilineTextAlignment(.leading)
                                        .accessibility(identifier: A11y.settings.auditEvents.stgCtnAuditEventsEventDate)
                                }
                                .task {
                                    if entry.id == entries.last?.id {
                                        viewStore.send(.loadNextPage)
                                    }
                                }
                                .redacted(reason: entry.id == entries.last?.id && viewStore
                                    .hasMoreContent ? .placeholder : .init())
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                .accessibilityElement(children: .contain)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemBackground))

                                GreyDivider()
                            }
                        }
                        .accessibilityElement(children: .contain)
                        .accessibility(identifier: A11y.settings.auditEvents.stgCtnAuditEventsEvents)
                    }
                }
            case .emptyList:
                VStack(alignment: .center, spacing: 8) {
                    Spacer()
                    Text(L10n.stgTxtAuditEventsNoProtocolTitle)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier(A11y.settings.auditEvents.stgTxtAuditEventsNoProtocolTitle)
                    Text(L10n.stgTxtAuditEventsNoProtocolDescription)
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier(A11y.settings.auditEvents.stgTxtAuditEventsNoProtocolDescription)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
            case .needsAuthentication:
                VStack(alignment: .center, spacing: 8) {
                    Spacer()
                    Text(L10n.stgTxtAuditEventsTitle)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier(A11y.settings.auditEvents.stgTxtAuditEventsNoProtocolTitle)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
            case .loading:
                VStack {
                    Spacer()

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .accessibilityIdentifier(A11y.settings.auditEvents.stgTxtAuditEventsActivityIndicator)

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

struct AuditsEventView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AuditEventsView(store: AuditEventsDomain.Dummies.store)
        }
    }
}
