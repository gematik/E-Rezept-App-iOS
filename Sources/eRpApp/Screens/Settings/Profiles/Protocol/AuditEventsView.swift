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

struct AuditEventsView: View {
    let store: AuditEventsDomain.Store
    @ObservedObject
    var viewStore: ViewStore<AuditEventsDomain.State, AuditEventsDomain.Action>

    init(store: AuditEventsDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(spacing: 0) {
            if let entries = viewStore.entries,
               !entries.isEmpty {
                PageNavigationControl(viewStore: viewStore)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        if let lastUpdated = viewStore.lastUpdated {
                            Text(L10n.stgTxtAuditEventsLastUpdated(lastUpdated))
                                .font(.footnote)
                                .foregroundColor(Color(.secondaryLabel))
                                .accessibility(identifier: A11y.settings.auditEvents.stgCtnAuditEventsEvents)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                        }

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
            } else if viewStore.entries != nil {
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
            } else {
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
        .onAppear {
            viewStore.send(.loadPageList)
        }
        .navigationTitle(L10n.stgTxtAuditEventsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
    }
}

extension AuditEventsView {
    struct PageNavigationControl: View {
        @ObservedObject
        var viewStore: ViewStore<AuditEventsDomain.State, AuditEventsDomain.Action>

        var body: some View {
            HStack {
                Button {
                    if let previousPage = viewStore.previousPage {
                        viewStore.send(.loadPage(previousPage))
                    }
                } label: {
                    Text(L10n.stgTxtAuditEventsPrevious)
                }
                .disabled(viewStore.state.previousPage == nil)
                .accessibility(identifier: A11y.settings.auditEvents.stgCtnAuditEventsNavigationPrevious)

                Spacer()

                Text(L10n.stgTxtAuditEventsPageSelectionOf(
                    viewStore.selectedPage?.name ?? "",
                    String(viewStore.state.pages?.count ?? 0)
                ))
                    .foregroundColor(Color(.secondaryLabel))
                    .font(.subheadline)
                    .accessibility(identifier: A11y.settings.auditEvents.stgCtnAuditEventsNavigationPageIndicator)

                Spacer()

                Button {
                    if let nextPage = viewStore.nextPage {
                        viewStore.send(.loadPage(nextPage))
                    }
                } label: {
                    Text(L10n.stgTxtAuditEventsNext)
                }
                .disabled(viewStore.state.nextPage == nil)
                .accessibility(identifier: A11y.settings.auditEvents.stgCtnAuditEventsNavigationNext)
            }
            .accessibilityElement(children: .contain)
            .accessibility(identifier: A11y.settings.auditEvents.stgCtnAuditEventsEvents)
            .accentColor(Colors.primary600)
            .padding()
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
