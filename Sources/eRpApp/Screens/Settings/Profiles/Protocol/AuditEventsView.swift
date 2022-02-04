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
        VStack {
            if let entries = viewStore.entries,
               !entries.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        if let lastUpdated = viewStore.lastUpdated {
                            Text(lastUpdated)
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
                                    Text(entry.title, placeholder: L10n.stgTxtAuditEventsMissingTitle)
                                        .font(.body.weight(.semibold))
                                        .multilineTextAlignment(.leading)
                                        .accessibility(identifier: A11y.settings.auditEvents
                                            .stgCtnAuditEventsEventTitle)
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
                                .frame(maxWidth: .infinity, alignment: .center)
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
            viewStore.send(.load)
        }
        .navigationTitle(L10n.stgTxtAuditEventsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
    }
}
