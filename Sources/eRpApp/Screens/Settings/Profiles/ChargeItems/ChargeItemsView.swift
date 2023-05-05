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

struct ChargeItemsView: View {
    let store: ChargeItemsDomain.Store

    @ObservedObject
    private var viewStore: ViewStore<ViewState, ChargeItemsDomain.Action>

    init(store: ChargeItemsDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let chargeItems: [ChargeItemsDomain.ChargeItemGroup]
        let bottomBannerState: ChargeItemsDomain.BottomBannerState?
        let toolbarMenuState: ChargeItemsDomain.ToolbarMenuState
        let destinationTag: ChargeItemsDomain.Destinations.State.Tag?

        init(state: ChargeItemsDomain.State) {
            chargeItems = state.chargeItemGroups
            bottomBannerState = state.bottomBannerState
            toolbarMenuState = state.toolbarMenuState

            destinationTag = state.destination?.tag
        }
    }

    @State private var editMode: EditMode = .inactive

    var body: some View {
        VStack(spacing: 0) {
            if viewStore.chargeItems.isEmpty {
                Spacer()
                VStack(alignment: .center, spacing: 0) {
                    HStack {
                        Spacer(minLength: 0)
                        Image(decorative: Asset.Illustrations.girlRedCircleLarge)
                        Spacer(minLength: 0)
                    }
                    Text(L10n.stgTxtChargeItemsEmptyListReplacement)
                        .font(Font.headline.weight(.bold))
                        .accessibilityIdentifier(A11y.settings.chargeItems.stgTxtChargeItemsEmptyListReplacement)
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
                        .accessibilityIdentifier(A11y.settings.chargeItems.stgTxtChargeItemsBottomBannerMessage)

                    Spacer()

                    if bottomBanner != .loading {
                        Button(
                            action: {
                                viewStore.send(bottomBanner.action)
                            },
                            label: {
                                Text(bottomBanner.buttonText)
                                    .accessibilityIdentifier(A11y.settings.chargeItems.stgBtnChargeItemsBottomBanner)
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
                                state: /ChargeItemsDomain.Destinations.State.idpCardWall,
                                action: ChargeItemsDomain.Destinations.Action.idpCardWallAction
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
                        state: /ChargeItemsDomain.Destinations.State.chargeItem,
                        action: ChargeItemsDomain.Destinations.Action.chargeItem(action:)
                    ),
                    then: ChargeItemView.init(store:)
                ),
                tag: ChargeItemsDomain.Destinations.State.Tag.chargeItem,
                selection: viewStore.binding(get: \.destinationTag, send: ChargeItemsDomain.Action.setNavigation)
            ) {
                EmptyView()
            }.accessibility(hidden: true)
        }
        .environment(\.editMode, $editMode)
        .alert(
            store.destinationsScope(state: /ChargeItemsDomain.Destinations.State.alert),
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
                            Text(L10n.stgBtnChargeItemsEditingDone)
                        }
                    )
                    .accessibility(identifier: A11y.settings.chargeItems.stgBtnChargeItemsMenuEntryEditingDone)
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
//                                        Text(L10n.stgBtnChargeItemsEditingStart)
//                                    } icon: {
//                                        Image(systemName: SFSymbolName.settings)
//                                    }
//                                }
//                            )
//                            .accessibility(identifier: A11y.settings.chargeItems.stgBtnChargeItemsMenuEntryEdit)

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
                                Text(L10n.stgBtnChargeItemsMenu)
                            } icon: {
                                Image(systemName: SFSymbolName.ellipsis)
                            }
                        }
                    )
                    .accessibilityIdentifier(A11y.settings.chargeItems.stgBtnChargeItemsNavigationBarMenu)
                }
            }
        }
        .navigationTitle(L10n.stgTxtChargeItemsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewStore.send(.onAppear)
        }
    }
}

extension ChargeItemsView {
    private struct ChargeItemListView: View {
        @ObservedObject
        var viewStore: ViewStore<ViewState, ChargeItemsDomain.Action>

        var body: some View {
            List {
                ForEach(viewStore.chargeItems) { group in
                    ChargeItemSection(chargeItemSection: group) { chargeItem in
                        self.viewStore.send(.select(chargeItem))
                    }
                }
            }
            .listStyle(.inset)
            .accessibilityIdentifier(A11y.settings.chargeItems.stgBtnChargeItemsContainer)
        }

        private struct ChargeItemSection: View {
            let chargeItemSection: ChargeItemsDomain.ChargeItemGroup
            var selection: (ChargeItemsDomain.ChargeItem) -> Void

            func delete(at _: IndexSet) {
                // TODO: placeholder for deletion story swiftlint:disable:this todo
            }

            var body: some View {
                Section {
                    ForEach(chargeItemSection.chargeItems) { chargeItem in
                        Cell(chargeItem: chargeItem) {
                            selection(chargeItem)
                        }
                        .accessibilityIdentifier(A11y.settings.chargeItems.stgBtnChargeItemsRow)
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
                            .accessibilityIdentifier(A11y.settings.chargeItems.stgBtnChargeItemsSectionHeaderTitle)

                        Spacer()

                        Text(L10n.stgBtnChargeItemsSum(chargeItemSection.chargeSum))
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Colors.primary)
                            .accessibilityIdentifier(A11y.settings.chargeItems.stgBtnChargeItemsSectionHeaderSum)
                    }
                    .padding(.top, 8)
                }
                .listSectionSeparator(.hidden, edges: .top)
                .headerProminence(.increased)
                .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
            }
        }

        private struct Cell: View {
            let chargeItem: ChargeItemsDomain.ChargeItem

            let selection: () -> Void

            var body: some View {
                Button {
                    selection()
                } label: {
                    Label {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(chargeItem.description)
                                .lineLimit(2)
                                .accessibilityIdentifier(A11y.settings.chargeItems.stgBtnChargeItemsRowTitle)

                            Text(chargeItem.localizedDate)
                                .font(.subheadline)
                                .foregroundColor(Colors.systemLabelSecondary)
                                .padding(.top, 4)
                                .accessibilityIdentifier(A11y.settings.chargeItems.stgBtnChargeItemsRowDate)

                            if !chargeItem.flags.isEmpty {
                                HStack {
                                    ForEach(chargeItem.flags, id: \.self) { flag in
                                        Flag(title: .init(flag))
                                    }
                                }
                                .accessibilityIdentifier(A11y.settings.chargeItems.stgBtnChargeItemsRowTagContainer)
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
                .accessibilityIdentifier(A11y.settings.chargeItems.stgBtnChargeItemsRow)
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

struct ChargeItemsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChargeItemsView(
                store:
                Store(
                    initialState: .init(
                        profileId: UUID(),
                        chargeItemGroups: [],
                        bottomBannerState: .loading
                    ),
                    reducer: ChargeItemsDomain()
                )
            )
        }
    }
}
