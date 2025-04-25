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

import CasePaths
import ComposableArchitecture
import eRpKit
import eRpStyleKit
import Foundation
import SwiftUI

struct ChargeItemListView: View {
    @Perception.Bindable var store: StoreOf<ChargeItemListDomain>

    @State private var editMode: EditMode = .inactive

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                if store.chargeItemGroups.isEmpty {
                    Spacer()
                    VStack(alignment: .center, spacing: 0) {
                        HStack {
                            Spacer(minLength: 0)
                            Image(decorative: Asset.Illustrations.girlRedCircleLarge)
                            Spacer(minLength: 0)
                        }
                        Text(L10n.stgTxtChargeItemListEmptyListReplacement)
                            .font(Font.headline.weight(.bold))
                            .accessibilityIdentifier(A11y.settings.chargeItemList
                                .stgTxtChargeItemListEmptyListReplacement)
                    }

                    Spacer()
                } else {
                    _ChargeItemListView(store: store)
                }

                // Bottom banner
                if let bottomBanner = store.bottomBannerState {
                    HStack {
                        Text(bottomBanner.message)
                            .font(Font.subheadline)
                            .accessibilityIdentifier(A11y.settings.chargeItemList
                                .stgTxtChargeItemListBottomBannerMessage)

                        Spacer()

                        if bottomBanner != .loading {
                            Button(
                                action: {
                                    store.send(bottomBanner.action)
                                },
                                label: {
                                    Text(bottomBanner.buttonText)
                                        .accessibilityIdentifier(A11y.settings.chargeItemList
                                            .stgBtnChargeItemListBottomBanner)
                                }
                            )
                            .buttonStyle(.tertiaryFilled)
                            .padding(.leading)
                        } else {
                            ProgressView()
                                .font(.subheadline)
                                .colorScheme(.dark)
                                .padding(SwiftUI.EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .background(Colors.disabled)
                                .cornerRadius(8)
                        }
                    }

                    .padding(.horizontal, 16)
                    .padding(.vertical)
                    .background((bottomBanner == .loading ? Colors.systemBackgroundSecondary : Colors.primary100)
                        .ignoresSafeArea())
                    .topBorder(strokeWith: 0.5, color: Colors.separator)
                }

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .sheet(
                        item: $store.scope(
                            state: \.destination?.idpCardWall,
                            action: \.destination.idpCardWall
                        )
                    ) { store in
                        IDPCardWallView(store: store)
                    }
                    .accessibility(hidden: true)
                    .hidden()
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.chargeItem, action: \.destination.chargeItem)
            ) { store in
                ChargeItemView(store: store)
            }
            .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
            .toast($store.scope(state: \.destination?.toast, action: \.destination.toast))
            .environment(\.editMode, $editMode)
            .keyboardShortcut(.defaultAction) // workaround: this makes the alert's primary button bold
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if editMode.isEditing {
                        Button(
                            action: { /* insert some action soon */
                                withAnimation {
                                    editMode = .inactive
                                }
                            },
                            label: {
                                Text(L10n.stgBtnChargeItemListEditingDone)
                            }
                        )
                        .accessibility(identifier: A11y.settings.chargeItemList
                            .stgBtnChargeItemListMenuEntryEditingDone)
                    } else {
                        Menu(
                            content: {
                                // TODO: reenable when deletion/selection is implemented swiftlint:disable:this todo
//                                Button(
//                                    action: { /* insert some action soon */
//                                        withAnimation {
//                                            editMode = .active
//                                        }
//                                    },
//                                    label: {
//                                        Label {
//                                            Text(L10n.stgBtnChargeItemListEditingStart)
//                                        } icon: {
//                                            Image(systemName: SFSymbolName.settings)
//                                        }
//                                    }
//                                )
//                                .accessibility(identifier: A11y.settings.chargeItemList
//                                    .stgBtnChargeItemListMenuEntryEdit)
                                ForEach(store.toolbarMenuState.entries) { entry in
                                    Button(
                                        role: entry.destructive ? .destructive : nil,
                                        action: { store.send(entry.action) },
                                        label: { Text(entry.labelText) }
                                    )
                                    .accessibilityIdentifier(entry.a11y)
                                }
                            },
                            label: {
                                Label {
                                    Text(L10n.stgBtnChargeItemListMenu)
                                } icon: {
                                    Image(systemName: SFSymbolName.ellipsis)
                                }
                            }
                        )
                        .accessibilityIdentifier(A11y.settings.chargeItemList.stgBtnChargeItemListNavigationBarMenu)
                    }
                }
            }
            .navigationTitle(L10n.stgTxtChargeItemListTitle)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await store.send(.task).finish()
            }
        }
    }
}

extension ChargeItemListView {
    private struct _ChargeItemListView: View {
        @Perception.Bindable var store: StoreOf<ChargeItemListDomain>

        var body: some View {
            WithPerceptionTracking {
                List {
                    ForEach(store.chargeItemGroups) { group in
                        ChargeItemSection(chargeItemSection: group) { chargeItem in
                            store.send(.select(chargeItem))
                        }
                    }
                }
                .listStyle(.inset)
                .accessibilityIdentifier(A11y.settings.chargeItemList.stgBtnChargeItemListContainer)
            }
        }

        private struct ChargeItemSection: View {
            let chargeItemSection: ChargeItemListDomain.ChargeItemGroup
            var selection: (ChargeItemListDomain.ChargeItem) -> Void

            func delete(at _: IndexSet) {
                // TODO: placeholder for deletion story swiftlint:disable:this todo
            }

            var body: some View {
                Section {
                    ForEach(chargeItemSection.chargeItems) { chargeItem in
                        _ChargeItemListView.Cell(chargeItem: chargeItem) {
                            selection(chargeItem)
                        }
                        .accessibilityIdentifier(A11y.settings.chargeItemList.stgBtnChargeItemListRow)
                        // TODO: placeholder for quick actions swiftlint:disable:this todo
//                            .swipeActions(edge: .leading, content: {
//                                Button {
//                                } label: {
//                                    Label("Eingelöst", systemImage: SFSymbolName.checkmark)
//                                }
//                                .tint(Colors.primary700)
//                            })
//                            .swipeActions {
//                                Button(role: .destructive) {
//                                } label: {
//                                    Label("Löschen", systemImage: "minus.circle")
//                                }
//                                .tint(Colors.red600)
//                                Button("Check") {
//                                }
//                                .tint(Colors.primary700)
//                            }
                    }
                    // TODO: placeholder for deletion story swiftlint:disable:this todo
//                    .onDelete(perform: delete)
                } header: {
                    HStack {
                        Text(chargeItemSection.title)
                            .accessibilityIdentifier(A11y.settings.chargeItemList
                                .stgBtnChargeItemListSectionHeaderTitle)

                        Spacer()

                        Text(L10n.stgBtnChargeItemListSum(chargeItemSection.chargeSum))
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Colors.primary)
                            .accessibilityIdentifier(A11y.settings.chargeItemList.stgBtnChargeItemListSectionHeaderSum)
                    }
                    .padding(.top, 8)
                }
                .listSectionSeparator(.hidden, edges: .top)
                .headerProminence(.increased)
                .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
            }
        }

        private struct Cell: View {
            let chargeItem: ChargeItemListDomain.ChargeItem

            let selection: () -> Void

            var body: some View {
                Button {
                    selection()
                } label: {
                    Label {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(chargeItem.description)
                                .lineLimit(2)
                                .accessibilityIdentifier(A11y.settings.chargeItemList.stgBtnChargeItemListRowTitle)

                            Text(chargeItem.localizedDate)
                                .font(.subheadline)
                                .foregroundColor(Colors.systemLabelSecondary)
                                .padding(.top, 4)
                                .accessibilityIdentifier(A11y.settings.chargeItemList.stgBtnChargeItemListRowDate)

                            if !chargeItem.flags.isEmpty {
                                HStack {
                                    ForEach(chargeItem.flags, id: \.self) { flag in
                                        Flag(title: .init(flag))
                                    }
                                }
                                .accessibilityIdentifier(A11y.settings.chargeItemList
                                    .stgBtnChargeItemListRowTagContainer)
                                .padding(.top, 16)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()
                    } icon: {
                        Image(systemName: SFSymbolName.chevronForward)
                            .foregroundColor(Color(.tertiaryLabel))
                            .font(.body.weight(.semibold))
                    }
                    .labelStyle(TrailingIconLabelStyle2())
                }
                .accessibilityIdentifier(A11y.settings.chargeItemList.stgBtnChargeItemListRow)
            }

            private struct Flag: View {
                let title: LocalizedStringKey

                var body: some View {
                    Text(title, bundle: .module)
                        .font(.subheadline)
                        .padding(.init(top: 8, leading: 12, bottom: 8, trailing: 12))
                        .background(Colors.primary100)
                        .cornerRadius(8)
                }
            }

            /// `LabelStyle` switching the icon to be trailing instead of leading.
            public struct TrailingIconLabelStyle2: LabelStyle {
                public func makeBody(configuration: Configuration) -> some View {
                    HStack {
                        configuration.title

                        Spacer()

                        configuration.icon
                            .font(.body.weight(.semibold))
                            .foregroundColor(Colors.systemLabelSecondary)
                    }
                }
            }
        }
    }
}

struct ChargeItemListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChargeItemListView(
                store:
                Store(
                    initialState: .init(
                        profileId: UUID(),
                        chargeItemGroups: [ChargeItemListDomain.ChargeItemGroup](),
                        bottomBannerState: .loading
                    )
                ) {
                    ChargeItemListDomain()
                }
            )
        }
    }
}
