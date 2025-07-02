//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import ComposableArchitecture
import eRpStyleKit
import Perception
import SwiftUI

// [REQ:gemSpec_eRp_FdV:A_19177#1,A_19185#2] View displaying the audit events
// [REQ:BSI-eRp-ePA:O.Auth_6#3] View displaying the audit events
struct AuditEventsView: View {
    @Perception.Bindable var store: StoreOf<AuditEventsDomain>

    init(store: StoreOf<AuditEventsDomain>) {
        self.store = store
    }

    enum ListState: Equatable {
        case emptyList
        case list(IdentifiedArrayOf<AuditEventsDomain.State.AuditEvent>)
        case needsAuthentication
        case loading
    }

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                AuditEventsListView(store: store)
                // Bottom banner
                if store.needsAuthentication {
                    HStack {
                        Text(L10n.stgTxtAuditEventsBannerMessage)
                            .font(Font.subheadline)
                            .accessibilityIdentifier(A11y.settings.auditEvents.stgTxtAuditEventsBottomBannerMessage)

                        Spacer()

                        Button(
                            action: {
                                store.send(.showCardWall)
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
                await store.send(.task).finish()
            }
            .alert($store.scope(
                state: \.destination?.alert?.alert,
                action: \.destination.alert
            ))
            .fullScreenCover(
                item: $store.scope(state: \.destination?.cardWall, action: \.destination.cardWall),
                content: CardWallIntroductionView.init(store:)
            )
            .navigationTitle(L10n.stgTxtAuditEventsTitle)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.secondarySystemBackground).ignoresSafeArea())
        }
    }

    struct AuditEventsListView: View {
        @Perception.Bindable var store: StoreOf<AuditEventsDomain>

        var listState: ListState {
            if store.needsAuthentication {
                return .needsAuthentication
            } else {
                if let entries = store.entries {
                    if entries.isEmpty {
                        return .emptyList
                    } else {
                        return .list(entries)
                    }
                } else {
                    return .loading
                }
            }
        }

        var body: some View {
            WithPerceptionTracking {
                switch listState {
                case let .list(entries):
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            Group {
                                ForEach(entries) { entry in
                                    WithPerceptionTracking {
                                        VStack(alignment: .leading, spacing: 4) {
                                            if let title = entry.title {
                                                Text(title, placeholder: L10n.stgTxtAuditEventsMissingTitle)
                                                    .font(.body.weight(.semibold))
                                                    .multilineTextAlignment(.leading)
                                                    .accessibility(identifier: A11y.settings.auditEvents
                                                        .stgCtnAuditEventsEventTitle)
                                            }
                                            Text(
                                                entry.description,
                                                placeholder: L10n.stgTxtAuditEventsMissingDescription
                                            )
                                            .font(.subheadline)
                                            .multilineTextAlignment(.leading)
                                            .accessibility(identifier: A11y.settings.auditEvents
                                                .stgCtnAuditEventsEventDescription)
                                            if let telematikIdInfo = entry.telematikIdInfo {
                                                Text(telematikIdInfo)
                                                    .font(.subheadline)
                                                    .multilineTextAlignment(.leading)
                                                    .accessibility(identifier: A11y.settings.auditEvents
                                                        .stgCtnAuditEventsEventTelematikIdInfo)
                                            }
                                            Text(entry.date, placeholder: L10n.stgTxtAuditEventsMissingDate)
                                                .font(.subheadline)
                                                .foregroundColor(Color(.secondaryLabel))
                                                .multilineTextAlignment(.leading)
                                                .accessibility(identifier: A11y.settings.auditEvents
                                                    .stgCtnAuditEventsEventDate)
                                        }
                                        .task {
                                            if entry.id == entries.last?.id {
                                                store.send(.loadNextPage)
                                            }
                                        }
                                        .redacted(reason: entry.id == entries.last?.id
                                            && store.nextPageUrl != nil
                                            ? .placeholder : .init())
                                        .padding(.horizontal)
                                        .padding(.vertical, 12)
                                        .accessibilityElement(children: .contain)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemBackground))

                                        GreyDivider()
                                    }
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
}

struct AuditsEventView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuditEventsView(store: AuditEventsDomain.Dummies.store)
        }
    }
}
