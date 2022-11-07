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
import eRpKit
import MapKit
import SwiftUI

struct PharmacyDetailView: View {
    let store: PharmacyDetailDomain.Store
    let isRedeemRecipe: Bool

    init(store: PharmacyDetailDomain.Store, isRedeemRecipe: Bool = true) {
        self.store = store
        self.isRedeemRecipe = isRedeemRecipe
    }

    struct ViewState: Equatable {
        let isErxReady: Bool
        let hasTasks: Bool
        let pharmacy: PharmacyLocation
        let reservationService: RedeemServiceOption
        let deliveryService: RedeemServiceOption
        let shipmentService: RedeemServiceOption
        let pharmacyViewModel: PharmacyLocationViewModel

        init(state: PharmacyDetailDomain.State) {
            isErxReady = state.pharmacy.isErxReady
            hasTasks = !state.erxTasks.isEmpty
            pharmacy = state.pharmacy
            reservationService = state.reservationService
            deliveryService = state.deliveryService
            shipmentService = state.shipmentService
            pharmacyViewModel = state.pharmacyViewModel
        }
    }

    var body: some View {
        WithViewStore(store.scope(state: ViewState.init)) { viewStore in
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    if viewStore.isErxReady {
                        ErxReadinessBadge(detailedText: true)
                    }

                    Text(viewStore.pharmacy.name ?? L10n.phaDetailTxtSubtitleFallback.text)
                        .foregroundColor(Colors.systemLabel)
                        .font(.title2)
                        .bold()
                        .accessibility(identifier: A11y.pharmacyDetail.phaDetailTxtSubtitle)

                    if let address = viewStore.pharmacy.address?.fullAddress {
                        TertiaryButton(text: LocalizedStringKey(address),
                                       isEnabled: viewStore.pharmacy.canBeDisplayedInMap,
                                       imageName: SFSymbolName.map) {
                            viewStore.send(.openMapApp)
                        }
                        .accessibility(identifier: A11y.pharmacyDetail.phaDetailBtnLocation)
                        .padding(.bottom, 24)
                    }

                    if viewStore.isErxReady && viewStore.hasTasks {
                        VStack(spacing: 8) {
                            if viewStore.reservationService.hasService {
                                if viewStore.reservationService.hasServiceAfterLogin {
                                    PrimaryTextButtonBorder(
                                        text: L10n.phaDetailBtnLocation.key,
                                        note: L10n.phaDetailBtnLoginNote.key
                                    ) {
                                        viewStore.send(.showPharmacyRedeemOption(.onPremise))
                                    }
                                    .accessibility(identifier: A11y.pharmacyDetail.phaDetailBtnLocation)
                                } else {
                                    DefaultTextButton(text: L10n.phaDetailBtnLocation,
                                                      a11y: A11y.pharmacyDetail.phaDetailBtnLocation,
                                                      style: .primary) {
                                        viewStore.send(.showPharmacyRedeemOption(.onPremise))
                                    }
                                }
                            }
                            if viewStore.deliveryService.hasService {
                                if viewStore.deliveryService.hasServiceAfterLogin {
                                    PrimaryTextButtonBorder(
                                        text: L10n.phaDetailBtnHealthcareService.key,
                                        note: L10n.phaDetailBtnLoginNote.key
                                    ) {
                                        viewStore.send(.showPharmacyRedeemOption(.delivery))
                                    }
                                    .accessibility(identifier: A11y.pharmacyDetail.phaDetailBtnHealthcareService)
                                } else {
                                    DefaultTextButton(
                                        text: L10n.phaDetailBtnHealthcareService,
                                        a11y: A11y.pharmacyDetail.phaDetailBtnHealthcareService,
                                        style: viewStore.reservationService.hasService ? .secondary : .primary
                                    ) {
                                        viewStore.send(.showPharmacyRedeemOption(.delivery))
                                    }
                                }
                            }

                            if viewStore.shipmentService.hasService {
                                if viewStore.shipmentService.hasServiceAfterLogin {
                                    PrimaryTextButtonBorder(
                                        text: L10n.phaDetailBtnOrganization.key,
                                        note: L10n.phaDetailBtnLoginNote.key
                                    ) {
                                        viewStore.send(.showPharmacyRedeemOption(.shipment))
                                    }
                                    .accessibility(identifier: A11y.pharmacyDetail.phaDetailBtnOrganization)
                                } else {
                                    DefaultTextButton(
                                        text: L10n.phaDetailBtnOrganization,
                                        a11y: A11y.pharmacyDetail.phaDetailBtnOrganization,
                                        style: (!viewStore.reservationService.hasService &&
                                            !viewStore.deliveryService.hasService) ? .primary : .secondary
                                    ) {
                                        viewStore.send(.showPharmacyRedeemOption(.shipment))
                                    }
                                }
                            }
                        }
                    } // if viewStore.pharmacy.isErxReady

                    if viewStore.pharmacy.isErxReady {
                        if isRedeemRecipe {
                            HintView<PharmacyDetailDomain.Action>(
                                hint: Hint(id: A11y.pharmacyDetail.phaDetailHint,
                                           message: L10n.phaDetailHintMessage.text,
                                           image: .init(name: Asset.Illustrations.info.name))
                            )
                            .padding(.top, 12)
                            .padding(.bottom, 32)
                        }
                    } else {
                        HintView<PharmacyDetailDomain.Action>(
                            hint: Hint(id: A11y.pharmacyDetail.phaDetailHintNotErxReady,
                                       title: L10n.phaDetailHintNotErxReadyTitle.text,
                                       message: L10n.phaDetailHintNotErxReadyMessage.text,
                                       image: .init(
                                           name: Asset.Illustrations.pharmacistArmRedCirle.name,
                                           accessibilityName: L10n.phaDetailHintNotErxReadyPic.text
                                       ),
                                       style: .important)
                        )
                    }

                    if !viewStore.state.pharmacy.hoursOfOperation.isEmpty {
                        OpeningHoursView(dailyOpenHours: viewStore.state.pharmacyViewModel.openingHours)
                            .padding(.bottom, 8)
                    }

                    ContactView(store: store)

                    Footer()
                        .padding(.top, 4)

                    RedeemViewViaErxTaskRepoNavigation(store: store).accessibility(hidden: true)
                    RedeemViewViaAVSNavigation(store: store).accessibility(hidden: true)
                }.padding()
            }
            .onAppear {
                viewStore.send(.loadCurrentProfile)
            }
            .navigationBarItems(
                trailing: trailingNavigationBarItem()
            )
            .introspectNavigationController { navigationController in
                let navigationBar = navigationController.navigationBar
                navigationBar.barTintColor = UIColor(Colors.systemBackground)
                let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.shadowColor = UIColor(Colors.systemColorClear)
                navigationBarAppearance.backgroundColor = UIColor(Colors.systemBackground)
                navigationBar.standardAppearance = navigationBarAppearance
            }
        }
    }

    // TODO: rebuild view structure,  // swiftlint:disable:this todo
    // also `trailingNavigationBarItem` and alike are deprecating (Use `toolbar(content:)`)
    @ViewBuilder
    private func trailingNavigationBarItem() -> some View {
        WithViewStore(store.stateless) { viewStore in
            if isRedeemRecipe {
                NavigationBarCloseItem {
                    viewStore.send(.close)
                }
            } else {
                EmptyView()
            }
        }
    }
}

extension PharmacyDetailView {
    struct OpeningHoursView: View {
        let dailyOpenHours: [PharmacyLocationViewModel.OpeningHoursDay]

        var body: some View {
            SectionHeaderView(
                text: L10n.phaDetailOpeningTime,
                a11y: ""
            ).padding(.bottom, 8)

            ForEach(dailyOpenHours, id: \.self) { dailyOpenHour in
                HStack(alignment: .top) {
                    Text(dailyOpenHour.dayOfWeekLocalizedDisplayName)
                        .font(Font.body)
                        .foregroundColor(dailyOpenHour.openingState.isOpen ? Colors.secondary600 : Colors.systemLabel)
                        .accessibility(hint: dailyOpenHour.openingState
                            .isOpen ? Text(L10n.phaDetailOpeningToday) : Text(""))
                    Spacer(minLength: 0)
                    VStack(alignment: .trailing) {
                        ForEach(dailyOpenHour.entries, id: \.self) { hop in
                            Text("\(hop.openingTime ?? "") - \(hop.closingTime ?? "")")
                                .accessibility(label: makeAccessibilityText(opening: hop.openingTime ?? "",
                                                                            closing: hop.closingTime ?? ""))
                                .font(Font.monospacedDigit(.body)())
                                .foregroundColor(
                                    hop.openingState.isOpen ?
                                        Colors.secondary600 : Colors.systemLabelSecondary
                                )
                        }
                    }
                }
                .padding(.vertical, 8)
                Divider()
            }
        }

        func makeAccessibilityText(opening: String, closing: String) -> Text {
            Text("""
            \(opening)
            \(L10n.phaDetailOpeningTimeVoice.text)
            \(L10n.phaDetailOpeningUntil.text)
            \(closing)
            \(L10n.phaDetailOpeningTimeVoice.text)
            """)
        }
    }

    struct ContactView: View {
        let store: PharmacyDetailDomain.Store
        var body: some View {
            VStack {
                WithViewStore(store
                    .scope(state: \.pharmacy.telecom)) { viewStore in
                        SectionHeaderView(text: L10n.phaDetailContact,
                                          a11y: A11y.pharmacyDetail.phaDetailContact)

                        if let phone = viewStore.state?.phone {
                            Button(action: { viewStore.send(.openPhoneApp) }, label: {
                                DetailedIconCellView(title: L10n.phaDetailPhone,
                                                     value: phone,
                                                     imageName: SFSymbolName.phone,
                                                     a11y: A11y.pharmacyDetail.phaDetailPhone)
                            })
                        }
                        if let email = viewStore.state?.email {
                            Button(action: { viewStore.send(.openMailApp) }, label: {
                                DetailedIconCellView(title: L10n.phaDetailMail,
                                                     value: email,
                                                     imageName: SFSymbolName.mail,
                                                     a11y: A11y.pharmacyDetail.phaDetailMail)
                            })
                        }
                        if let web = viewStore.state?.web {
                            Button(action: { viewStore.send(.openBrowserApp) }, label: {
                                DetailedIconCellView(title: L10n.phaDetailWeb,
                                                     value: web,
                                                     imageName: SFSymbolName.arrowUpForward,
                                                     a11y: A11y.pharmacyDetail.phaDetailWeb)
                            })
                        }
                }
            }
        }
    }

    struct RedeemViewViaAVSNavigation: View {
        let store: PharmacyDetailDomain.Store
        var body: some View {
            WithViewStore(store.scope(state: \.route?.tag)) { viewStore in
                NavigationLink(
                    destination: destination,
                    tag: PharmacyDetailDomain.Route.Tag.redeemViaAVS,
                    selection: viewStore.binding(
                        get: { $0 },
                        send: { .setNavigation(tag: $0) }
                    )
                ) {}
                    .hidden()
                    .accessibility(hidden: true)
            }
        }

        var destination: some View {
            IfLetStore(
                scopedStore,
                then: PharmacyRedeemView.init(store:)
            )
        }

        var scopedStore: Store<PharmacyRedeemDomain.State?, PharmacyRedeemDomain.Action> {
            store.scope(
                state: (\PharmacyDetailDomain.State.route)
                    .appending(path: /PharmacyDetailDomain.Route.redeemViaAVS)
                    .extract(from:),
                action: PharmacyDetailDomain.Action.pharmacyRedeemViaAVS(action:)
            )
        }
    }

    struct RedeemViewViaErxTaskRepoNavigation: View {
        let store: PharmacyDetailDomain.Store
        var body: some View {
            WithViewStore(store.scope(state: \.route?.tag)) { viewStore in
                NavigationLink(
                    destination: destination,
                    tag: PharmacyDetailDomain.Route.Tag.redeemViaErxTaskRepository,
                    selection: viewStore.binding(
                        get: { $0 },
                        send: { .setNavigation(tag: $0) }
                    )
                ) {}
                    .hidden()
                    .accessibility(hidden: true)
                // This is a workaround due to a SwiftUI bug where never 2 NavigationLink
                // should be on the same view. See:
                // https://forums.swift.org/t/14-5-beta3-navigationlink-unexpected-pop/45279
                NavigationLink(destination: EmptyView()) {
                    EmptyView()
                }.accessibility(hidden: true)
            }
        }

        var destination: some View {
            IfLetStore(
                scopedStore,
                then: PharmacyRedeemView.init(store:)
            )
        }

        var scopedStore: Store<PharmacyRedeemDomain.State?, PharmacyRedeemDomain.Action> {
            store.scope(
                state: (\PharmacyDetailDomain.State.route)
                    .appending(path: /PharmacyDetailDomain.Route.redeemViaErxTaskRepository)
                    .extract(from:),
                action: PharmacyDetailDomain.Action.pharmacyRedeemViaErxTaskRepository(action:)
            )
        }
    }

    struct Footer: View {
        var text: Text = {
            Text(L10n.phaDetailTxtFooterStart)
                .foregroundColor(Color(.secondaryLabel)) +
                Text(L10n.phaDetailTxtFooterMid)
                .foregroundColor(Colors.primary) +
                Text(L10n.phaDetailTxtFooterEnd)
                .foregroundColor(Color(.secondaryLabel))
        }()

        var body: some View {
            VStack(alignment: .trailing, spacing: 8) {
                Button(action: {
                    guard let url = URL(string: "https://mein-apothekenportal.de"),
                          UIApplication.shared.canOpenURL(url) else { return }

                    UIApplication.shared.open(url)
                }, label: {
                    text
                        .multilineTextAlignment(.leading)
                })
                Button(action: {
                    guard let url = URL(string: "https://www.gematik.de/anwendungen/e-rezept/faq/meine-apotheke/"),
                          UIApplication.shared.canOpenURL(url) else { return }

                    UIApplication.shared.open(url)
                }, label: {
                    Text(L10n.phaDetailBtnFooter)
                        .foregroundColor(Colors.primary)
                })
            }
            .font(.footnote)
        }
    }
}

struct PharmacyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PharmacyDetailView(store: PharmacyDetailDomain.Dummies.store)
        }

        NavigationView {
            PharmacyDetailView(
                store: PharmacyDetailDomain.Store(
                    initialState: PharmacyDetailDomain.State(
                        erxTasks: PharmacyDetailDomain.Dummies.prescriptions,
                        pharmacyViewModel: PharmacyDetailDomain.Dummies.pharmacyInactiveViewModel
                    ),
                    reducer: PharmacyDetailDomain.Reducer.empty,
                    environment: PharmacyDetailDomain.Dummies.environment
                )
            )
        }

        NavigationView {
            PharmacyDetailView(
                store: PharmacyDetailDomain.Dummies.storeFor(
                    PharmacyDetailDomain.State(
                        erxTasks: PharmacyDetailDomain.Dummies.prescriptions,
                        pharmacyViewModel: PharmacyDetailDomain.Dummies.pharmacyInactiveViewModel
                    )
                )
            )
        }
    }
}
