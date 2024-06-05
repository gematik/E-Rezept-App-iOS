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
import eRpKit
import eRpStyleKit
import MapKit
import Perception
import SwiftUI
import SwiftUIIntrospect

struct PharmacyDetailView: View {
    @Perception.Bindable var store: StoreOf<PharmacyDetailDomain>
    let isRedeemRecipe: Bool

    init(store: StoreOf<PharmacyDetailDomain>, isRedeemRecipe: Bool = true) {
        self.store = store
        self.isRedeemRecipe = isRedeemRecipe
    }

    static let uiTestsRunning = ProcessInfo.processInfo.environment["UITEST.SCENARIO_NAME"] != nil

    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.pharmacy.name ?? L10n.phaDetailTxtSubtitleFallback.text)
                        .foregroundColor(Colors.systemLabel)
                        .font(.title2)
                        .bold()
                        .accessibility(identifier: A11y.pharmacyDetail.phaDetailTxtSubtitle)

                    if let address = store.pharmacy.address?.fullAddress {
                        TertiaryButton(text: LocalizedStringKey(address),
                                       isEnabled: store.pharmacy.canBeDisplayedInMap,
                                       imageName: SFSymbolName.map) {
                            store.send(.openMapApp)
                        }
                        .accessibility(identifier: A11y.pharmacyDetail.phaDetailBtnLocation)
                        .padding(.bottom, 24)
                    }

                    // TODO: this is currently wrong but necessary to showcase the tests swiftlint:disable:this todo
                    if !store.erxTasks.isEmpty || PharmacyDetailView.uiTestsRunning {
                        VStack(spacing: 8) {
                            if store.reservationService.hasService {
                                if store.reservationService.hasServiceAfterLogin {
                                    PrimaryTextButtonBorder(
                                        text: L10n.phaDetailBtnLocation.key,
                                        note: L10n.phaDetailBtnLoginNote.key
                                    ) {
                                        store.send(.showPharmacyRedeemOption(.onPremise))
                                    }
                                    .accessibility(identifier: A11y.pharmacyDetail.phaDetailBtnPickupViaLogin)
                                } else {
                                    DefaultTextButton(text: L10n.phaDetailBtnLocation,
                                                      a11y: A11y.pharmacyDetail.phaDetailBtnPickup,
                                                      style: .primary) {
                                        store.send(.showPharmacyRedeemOption(.onPremise))
                                    }
                                }
                            }
                            if store.deliveryService.hasService {
                                if store.deliveryService.hasServiceAfterLogin {
                                    PrimaryTextButtonBorder(
                                        text: L10n.phaDetailBtnHealthcareService.key,
                                        note: L10n.phaDetailBtnLoginNote.key
                                    ) {
                                        store.send(.showPharmacyRedeemOption(.delivery))
                                    }
                                    .accessibility(identifier: A11y.pharmacyDetail.phaDetailBtnDeliveryViaLogin)
                                } else {
                                    DefaultTextButton(
                                        text: L10n.phaDetailBtnHealthcareService,
                                        a11y: A11y.pharmacyDetail.phaDetailBtnDelivery,
                                        style: store.reservationService.hasService ? .secondary : .primary
                                    ) {
                                        store.send(.showPharmacyRedeemOption(.delivery))
                                    }
                                }
                            }

                            if store.shipmentService.hasService {
                                if store.shipmentService.hasServiceAfterLogin {
                                    PrimaryTextButtonBorder(
                                        text: L10n.phaDetailBtnOrganization.key,
                                        note: L10n.phaDetailBtnLoginNote.key
                                    ) {
                                        store.send(.showPharmacyRedeemOption(.shipment))
                                    }
                                    .accessibility(identifier: A11y.pharmacyDetail.phaDetailBtnShipmentViaLogin)
                                } else {
                                    DefaultTextButton(
                                        text: L10n.phaDetailBtnOrganization,
                                        a11y: A11y.pharmacyDetail.phaDetailBtnShipment,
                                        style: (!store.reservationService.hasService &&
                                            !store.deliveryService.hasService) ? .primary : .secondary
                                    ) {
                                        store.send(.showPharmacyRedeemOption(.shipment))
                                    }
                                }
                            }
                        }
                    }

                    if isRedeemRecipe {
                        HintView<PharmacyDetailDomain.Action>(
                            hint: Hint(id: A11y.pharmacyDetail.phaDetailHint,
                                       message: L10n.phaDetailHintMessage.text,
                                       image: .init(name: Asset.Illustrations.infoLogo.name))
                        )
                        .padding(.top, 12)
                        .padding(.bottom, 32)
                    }

                    if !store.state.pharmacy.hoursOfOperation.isEmpty {
                        OpeningHoursView(dailyOpenHours: store.pharmacyViewModel.openingHours)
                            .padding(.bottom, 8)
                    }

                    ContactView(store: store)

                    Footer()
                        .padding(.top, 4)

                    NavigationLink(
                        item: $store.scope(
                            state: \.destination?.redeemViaAVS,
                            action: \.destination.redeemViaAVS
                        )
                    ) { store in
                        PharmacyRedeemView(store: store)
                    } label: {
                        EmptyView()
                    }
                    .accessibility(hidden: true)
                    .hidden()

                    NavigationLink(
                        item: $store.scope(
                            state: \.destination?.redeemViaErxTaskRepository,
                            action: \.destination.redeemViaErxTaskRepository
                        )
                    ) { store in
                        PharmacyRedeemView(store: store)
                    } label: {
                        EmptyView()
                    }
                    .accessibility(hidden: true)
                    .hidden()
                }.padding()
            }
            .task {
                await store.send(.loadCurrentProfile).finish()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        action: { store.send(.toggleIsFavorite) },
                        label: {
                            Image(systemName: store.pharmacy.isFavorite ? SFSymbolName.starFill : SFSymbolName.star)
                                .foregroundColor(Colors.starYellow)
                        }
                    )
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if isRedeemRecipe {
                        NavigationBarCloseItem {
                            store.send(.delegate(.close))
                        }
                    }
                }
            }
            .introspect(.navigationView(style: .stack), on: .iOS(.v15, .v16, .v17)) { navigationController in
                let navigationBar = navigationController.navigationBar
                navigationBar.barTintColor = UIColor(Colors.systemBackground)
                let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.shadowColor = UIColor(Colors.systemColorClear)
                navigationBarAppearance.backgroundColor = UIColor(Colors.systemBackground)
                navigationBar.standardAppearance = navigationBarAppearance
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
        @Perception.Bindable var store: StoreOf<PharmacyDetailDomain>

        var body: some View {
            WithPerceptionTracking {
                VStack {
                    SectionHeaderView(text: L10n.phaDetailContact,
                                      a11y: A11y.pharmacyDetail.phaDetailContact)

                    if let phone = store.pharmacy.telecom?.phone {
                        Button(action: { store.send(.openPhoneApp) }, label: {
                            DetailedIconCellView(title: L10n.phaDetailPhone,
                                                 value: phone,
                                                 imageName: SFSymbolName.phone,
                                                 a11y: A11y.pharmacyDetail.phaDetailPhone)
                        })
                    }
                    if let email = store.pharmacy.telecom?.email {
                        Button(action: { store.send(.openMailApp) }, label: {
                            DetailedIconCellView(title: L10n.phaDetailMail,
                                                 value: email,
                                                 imageName: SFSymbolName.mail,
                                                 a11y: A11y.pharmacyDetail.phaDetailMail)
                        })
                    }
                    if let web = store.pharmacy.telecom?.web {
                        Button(action: { store.send(.openBrowserApp) }, label: {
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
                store: StoreOf<PharmacyDetailDomain>(
                    initialState: PharmacyDetailDomain.State(
                        erxTasks: PharmacyDetailDomain.Dummies.prescriptions,
                        pharmacyViewModel: PharmacyDetailDomain.Dummies.pharmacyInactiveViewModel
                    )
                ) {
                    PharmacyDetailDomain()
                }
            )
        }

        NavigationView {
            PharmacyDetailView(
                store: StoreOf<PharmacyDetailDomain>(
                    initialState: .init(
                        erxTasks: PharmacyDetailDomain.Dummies.prescriptions,
                        pharmacyViewModel: PharmacyDetailDomain.Dummies.pharmacyInactiveViewModel
                    )
                ) {
                    PharmacyDetailDomain()
                }
            )
        }
    }
}
