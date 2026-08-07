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
import Dependencies
import eRpResources
import eRpStyleKit
import FeatureHelpers
import SwiftUI

public struct MessageThreadListView: View {
    @Bindable var store: StoreOf<MessageThreadListDomain>
    @Dependency(\.uiDateFormatter) var uiDateFormatter

    public init(store: StoreOf<MessageThreadListDomain>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !store.filteredMessages.isEmpty || store.isLoading {
                    ScrollView(.vertical) {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            if let profileName = store.profileName {
                                Text(L10n.msgTxtProfileSubtitle(profileName))
                                    .font(.subheadline)
                                    .foregroundColor(Colors.systemLabelSecondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                    .padding(.bottom, 8)
                            }

                            Toggle(isOn: Binding(
                                get: { store.hideCompleted },
                                set: { _ in store.send(.toggleHideCompleted) }
                            )) {
                                Text(L10n.msgBtnHideCompleted)
                            }
                            .toggleStyle(.switch)
                            .tint(Colors.primary500)
                            .padding(.horizontal)
                            .padding(.vertical, 8)

                            ForEach(store.filteredMessages) { message in
                                Button {
                                    store.send(.didSelect(message.id))
                                } label: {
                                    MessageCellView(
                                        message: message,
                                        uiDateFormatter: uiDateFormatter
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .redacted(reason: store.isLoading ? .placeholder : .init())
                        .accessibilityElement(children: .contain)
                        .accessibility(identifier: A11y.orders.list.ordTxtList)
                    }
                } else {
                    NoMessagesView()
                }
            }
            .navigationDestination(
                item: $store.scope(
                    state: \.destination?.orderDetail,
                    action: \.destination.orderDetail
                )
            ) { store in
                MessageThreadView(store: store)
            }
            .navigationBarTitle(L10n.msgTxtTitle, displayMode: .automatic)
            .accessibility(identifier: A11y.orders.list.msgTxtTitle)
            .alert($store.scope(
                state: \.destination?.alert?.alert,
                action: \.destination.alert
            ))
            .task {
                await store.send(.task).finish()
            }
            .toolbar {}
        }
        .tint(Colors.primary700)
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Message Cell

    struct MessageCellView: View {
        let message: CommunicationMessage
        let uiDateFormatter: UIDateFormatter

        var body: some View {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 8) {
                    MessageThumbnailView(message: message)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(message.title)
                            .font(.body.weight(.semibold))
                            .foregroundColor(Colors.systemLabel)
                            .lineLimit(1)

                        Text(message.latestMessage)
                            .font(.subheadline)
                            .foregroundColor(Colors.systemLabel)
                            .lineLimit(1)

                        MessageChipView(message: message)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .trailing, spacing: 8) {
                        Text(uiDateFormatter.relativeDate(message.lastUpdated) ?? "")
                            .font(.caption2)
                            .foregroundColor(Colors.systemLabelSecondary)

                        HStack(spacing: 0) {
                            if message.hasUnreadMessages {
                                Text(L10n.ordListStatusNew)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundColor(Colors.primary900)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Colors.primary100)
                                    .cornerRadius(16)
                            }

                            Image(systemName: SFSymbolName.chevronForward)
                                .font(.body.weight(.semibold))
                                .foregroundColor(Colors.systemLabelSecondary)
                                .frame(width: 22, height: 22)
                        }
                    }
                    .frame(width: 60)
                }
                .padding(16)

                Divider()
                    .padding(.leading, 56)
            }
        }
    }

    // MARK: - Thumbnail

    struct MessageThumbnailView: View {
        let message: CommunicationMessage

        var body: some View {
            switch message {
            case .order, .euOrder:
                ZStack {
                    Circle()
                        .fill(Colors.secondary100)
                        .frame(width: 32, height: 32)
                    Image(systemName: SFSymbolName.plus)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Colors.secondary600)
                }
            case .internalCommunication:
                ZStack {
                    Circle()
                        .fill(Colors.primary100)
                        .frame(width: 32, height: 32)
                    Image(systemName: SFSymbolName.envelope)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Colors.primary600)
                }
            }
        }
    }

    // MARK: - Chip

    struct MessageChipView: View {
        let message: CommunicationMessage

        var body: some View {
            switch message {
            case .internalCommunication:
                Text(chipText)
                    .font(.caption)
                    .foregroundColor(Colors.systemLabelSecondary)
            case .order, .euOrder:
                if !chipText.isEmpty {
                    Text(chipText)
                        .font(.system(size: 12))
                        .foregroundColor(chipTextColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(chipBackgroundColor)
                        .cornerRadius(16)
                }
            }
        }

        private var chipText: String {
            switch message {
            case let .internalCommunication(comm):
                return comm.messages.first.map { message in
                    if message.version == "0.0.0" {
                        return L10n.internMsgWelcomeChip.text
                    }
                    return L10n.internMsgChangeLogChip(message.version).text
                } ?? ""
            case .order, .euOrder:
                let entries = message.timelineEntries
                guard let firstEntry = entries.first else { return "" }
                var parts: [String] = []
                parts.append(firstEntry.text)
                let count = message.tasksCount
                if count > 0 {
                    parts.append(L10n.ordListStatusCount(count).text)
                }
                return parts.joined(separator: " · ")
            }
        }

        private var chipBackgroundColor: Color {
            if message.hasUnreadMessages {
                return Colors.primary100
            }
            return Colors.systemBackgroundSecondary
        }

        private var chipTextColor: Color {
            if message.hasUnreadMessages {
                return Colors.primary900
            }
            return Colors.systemLabel
        }
    }

    // MARK: - Empty State

    struct NoMessagesView: View {
        var body: some View {
            VStack(spacing: 8) {
                Spacer()
                Text(L10n.msgTxtEmptyListTitle)
                    .font(.headline)
                Text(L10n.ordTxtEmptyListMessage)
                    .font(.subheadline)
                    .foregroundColor(Colors.systemLabelSecondary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding()
            .accessibility(identifier: A11y.orders.list.ordTxtEmptyList)
        }
    }
}

#Preview {
    MessageThreadListView(store: MessageThreadListDomain.Dummies.store)
}
