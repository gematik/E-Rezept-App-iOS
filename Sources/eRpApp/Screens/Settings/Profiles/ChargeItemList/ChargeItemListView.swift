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

import CasePaths
import ComposableArchitecture
import eRpKit
import eRpStyleKit
import Foundation
import SwiftUI

struct ChargeItemListView: View {
    let store: ChargeItemListDomain.Store

    @ObservedObject
    private var viewStore: ViewStore<ViewState, ChargeItemListDomain.Action>

    init(store: ChargeItemListDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let chargeItemGroups: [ChargeItemListDomain.ChargeItemGroup]
        let bottomBannerState: ChargeItemListDomain.BottomBannerState?
        let toolbarMenuState: ChargeItemListDomain.ToolbarMenuState
        let destinationTag: ChargeItemListDomain.Destinations.State.Tag?

        init(state: ChargeItemListDomain.State) {
            chargeItemGroups = state.chargeItemGroups
            bottomBannerState = state.bottomBannerState
            toolbarMenuState = state.toolbarMenuState

            destinationTag = state.destination?.tag
        }
    }

    @State private var editMode: EditMode = .inactive

    var body: some View {
        VStack(spacing: 0) {
            if viewStore.chargeItemGroups.isEmpty {
                Spacer()
                VStack(alignment: .center, spacing: 0) {
                    HStack {
                        Spacer(minLength: 0)
                        Image(decorative: Asset.Illustrations.girlRedCircleLarge)
                        Spacer(minLength: 0)
                    }
                    Text(L10n.stgTxtChargeItemListEmptyListReplacement)
                        .font(Font.headline.weight(.bold))
                        .accessibilityIdentifier(A11y.settings.chargeItemList.stgTxtChargeItemListEmptyListReplacement)
                }

                Spacer()
            } else {
                ChargeItemListView(viewStore: viewStore)
            }

            // Bottom banner
            if let bottomBanner = viewStore.bottomBannerState {
                HStack {
                    Text(bottomBanner.message)
                        .font(Font.subheadline)
                        .accessibilityIdentifier(A11y.settings.chargeItemList.stgTxtChargeItemListBottomBannerMessage)

                    Spacer()

                    if bottomBanner != .loading {
                        Button(
                            action: {
                                viewStore.send(bottomBanner.action)
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
                    isPresented: Binding<Bool>(
                        get: { viewStore.destinationTag == .idpCardWall },
                        set: { show in
                            if !show { viewStore.send(.setNavigation(tag: nil)) }
                        }
                    ),
                    onDismiss: {},
                    content: {
                        IfLetStore(
                            store.destinationsScope(
                                state: /ChargeItemListDomain.Destinations.State.idpCardWall,
                                action: ChargeItemListDomain.Destinations.Action.idpCardWallAction
                            ),
                            then: IDPCardWallView.init(store:)
                        )
                    }
                )
                .accessibility(hidden: true)
                .hidden()

            NavigationLink(
                destination: IfLetStore(
                    store.destinationsScope(
                        state: /ChargeItemListDomain.Destinations.State.chargeItem,
                        action: ChargeItemListDomain.Destinations.Action.chargeItem(action:)
                    ),
                    then: ChargeItemView.init(store:)
                ),
                tag: ChargeItemListDomain.Destinations.State.Tag.chargeItem,
                selection: viewStore.binding(get: \.destinationTag, send: ChargeItemListDomain.Action.setNavigation)
            ) {
                EmptyView()
            }.accessibility(hidden: true)
        }
        .environment(\.editMode, $editMode)
        .alert(
            store.destinationsScope(state: /ChargeItemListDomain.Destinations.State.alert),
            dismiss: .nothing
        )
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
                    .accessibility(identifier: A11y.settings.chargeItemList.stgBtnChargeItemListMenuEntryEditingDone)
                } else {
                    Menu(
                        content: {
                            // TODO: reenable when deletion/selection is implemented swiftlint:disable:this todo
//                            Button(
//                                action: { /* insert some action soon */
//                                    withAnimation {
//                                        editMode = .active
//                                    }
//                                },
//                                label: {
//                                    Label {
//                                        Text(L10n.stgBtnChargeItemListEditingStart)
//                                    } icon: {
//                                        Image(systemName: SFSymbolName.settings)
//                                    }
//                                }
//                            )
//                            .accessibility(identifier: A11y.settings.chargeItemList.stgBtnChargeItemListMenuEntryEdit)

                            ForEach(viewStore.state.toolbarMenuState.entries) { entry in
                                Button(
                                    role: entry.destructive ? .destructive : nil,
                                    action: { viewStore.send(entry.action) },
                                    label: { Text(entry.labelText) }
                                )
                                .accessibilityIdentifier(entry.a11y)
                                .disabled(entry.isDisabled)
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
        .onAppear {
            viewStore.send(.onAppear)
        }
    }
}

extension ChargeItemListView {
    private struct ChargeItemListView: View {
        @ObservedObject
        var viewStore: ViewStore<ViewState, ChargeItemListDomain.Action>

        var body: some View {
            List {
                ForEach(viewStore.chargeItemGroups) { group in
                    ChargeItemSection(chargeItemSection: group) { chargeItem in
                        self.viewStore.send(.select(chargeItem))
                    }
                }
            }
            .listStyle(.inset)
            .accessibilityIdentifier(A11y.settings.chargeItemList.stgBtnChargeItemListContainer)
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
                        Cell(chargeItem: chargeItem) {
                            selection(chargeItem)
                        }
                        .accessibilityIdentifier(A11y.settings.chargeItemList.stgBtnChargeItemListRow)
                        // TODO: placeholder for quick actions swiftlint:disable:this todo
//                            .swipeActions(edge: .leading, content: {
//                                Button {
//                                } label: {
//                                    Label("Eingelöst", systemImage: SFSymbolName.checkmark)
//                                }
//                                .tint(Colors.primary600)
//                            })
//                            .swipeActions {
//                                Button(role: .destructive) {
//                                } label: {
//                                    Label("Löschen", systemImage: "minus.circle")
//                                }
//                                .tint(Colors.red600)
//                                Button("Check") {
//                                }
//                                .tint(Colors.primary600)
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
                    Text(title)
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
        NavigationView {
            ChargeItemListView(
                store:
                Store(
                    initialState: .init(
                        profileId: UUID(),
                        chargeItemGroups: [],
                        bottomBannerState: .loading
                    ),
                    reducer: ChargeItemListDomain()
                )
            )
        }
    }
}
