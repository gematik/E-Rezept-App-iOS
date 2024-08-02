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

    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(store.pharmacy.name ?? L10n.phaDetailTxtSubtitleFallback.text)
                                .font(.title2)
                                .accessibility(identifier: A11y.pharmacyDetail.phaDetailTxtSubtitle)

                            if let address = store.pharmacy.address?.fullAddress {
                                TertiaryButton(text: LocalizedStringKey(address),
                                               isEnabled: store.pharmacy.canBeDisplayedInMap,
                                               imageName: SFSymbolName.map) {
                                    store.send(.openMapApp)
                                }
                                .accessibility(identifier: A11y.pharmacyDetail.phaDetailBtnLocation)
                            }
                        }
                        Button(
                            action: { store.send(.toggleIsFavorite) },
                            label: {
                                Image(systemName: store.pharmacy.isFavorite ? SFSymbolName.starFill : SFSymbolName.star)
                                    .foregroundColor(store.pharmacy.isFavorite ? Colors.starYellow : Color.gray)
                                    .font(.title3)
                            }
                        )
                    }.padding(.bottom, 24)

                    if !(serviceIsMissing.count == 3) {
                        HStack(alignment: .top, spacing: 16) {
                            if store.reservationService.hasService {
                                Button(
                                    action: { store.send(.tappedRedeemOption(.onPremise)) },
                                    label: {
                                        Label {
                                            Text(L10n.phaDetailBtnPickup)
                                        } icon: {
                                            Image(asset: Asset.Pharmacy.btnApoLarge)
                                                .resizable()
                                                .padding(4)
                                        }
                                    }
                                ).buttonStyle(PictureButtonStyle(style: .supplyLarge, active: false, width: .narrow))
                                    .opacity(store.hasRedeemableTasks ? 1 : 0.25)
                                    .accessibility(identifier: store.reservationService.hasServiceAfterLogin ? A11y
                                        .pharmacyDetail.phaDetailBtnPickupViaLogin : A11y.pharmacyDetail
                                        .phaDetailBtnPickup)
                            }

                            if store.deliveryService.hasService {
                                Button(
                                    action: { store.send(.tappedRedeemOption(.delivery)) },
                                    label: {
                                        Label {
                                            Text(L10n.phaDetailBtnDelivery)
                                        } icon: {
                                            Image(asset: Asset.Pharmacy.btnCarLarge)
                                                .resizable()
                                                .padding(4)
                                        }
                                    }
                                ).buttonStyle(PictureButtonStyle(style: .supplyLarge, active: false, width: .narrow))
                                    .opacity(store.hasRedeemableTasks ? 1 : 0.25)
                                    .accessibility(identifier: store.deliveryService.hasServiceAfterLogin ? A11y
                                        .pharmacyDetail.phaDetailBtnDeliveryViaLogin : A11y.pharmacyDetail
                                        .phaDetailBtnDelivery)
                            }

                            if store.shipmentService.hasService {
                                Button(
                                    action: { store.send(.tappedRedeemOption(.shipment)) },
                                    label: {
                                        Label {
                                            Text(L10n.phaDetailBtnShipment)
                                        } icon: {
                                            Image(asset: Asset.Pharmacy.btnLkwLarge)
                                                .resizable()
                                                .padding(4)
                                        }
                                    }
                                ).buttonStyle(PictureButtonStyle(style: .supplyLarge, active: false, width: .narrow))
                                    .opacity(store.hasRedeemableTasks ? 1 : 0.25)
                                    .accessibility(identifier: store.shipmentService.hasServiceAfterLogin ? A11y
                                        .pharmacyDetail.phaDetailBtnShipmentViaLogin : A11y.pharmacyDetail
                                        .phaDetailBtnShipment)
                            }

                            ForEach(Array(serviceIsMissing.enumerated()), id: \.offset) { _ in
                                EmptyService()
                            }

                        }.frame(maxWidth: .infinity, alignment: .center)
                    }

                    if store.inRedeemProcess {
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

                    if !store.onMapView {
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
                    }
                }.padding()
            }.navigationBarTitleDisplayMode(.inline)
                .task {
                    await store.send(.task).finish()
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if store.inRedeemProcess {
                            NavigationBarCloseItem {
                                store.send(.delegate(.close))
                            }
                        }
                    }
                }
                .toast($store.scope(state: \.destination?.toast, action: \.destination.toast))
        }
    }

    var serviceIsMissing: [Bool] {
        [store.shipmentService.hasService,
         store.deliveryService.hasService,
         store.reservationService.hasService].filter { !$0 }
    }
}

extension PharmacyDetailView {
    struct EmptyService: View {
        var body: some View {
            Button(
                action: {},
                label: {
                    Label {
                        Text("")
                    } icon: {
                        Image(systemName: "")
                            .resizable()
                            .padding(4)
                    }
                }
            ).buttonStyle(PictureButtonStyle(style: .supplyLarge, active: false, width: .narrow))
                .hidden()
        }
    }

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
                        .foregroundColor(Colors.systemLabel)
                        .fontWeight(dailyOpenHour.openingState.isOpen ? .semibold : .regular)
                        .accessibility(hint: dailyOpenHour.openingState
                            .isOpen ? Text(L10n.phaDetailOpeningToday) : Text(""))
                    Spacer(minLength: 0)
                    VStack(alignment: .trailing) {
                        ForEach(dailyOpenHour.entries, id: \.self) { hop in
                            Text("\(hop.openingTime ?? "") - \(hop.closingTime ?? "")")
                                .fontWeight(hop.openingState.isOpen ? .semibold : .regular)
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
                        prescriptions: PharmacyDetailDomain.Dummies.prescriptions,
                        inRedeemProcess: false,
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
                        prescriptions: PharmacyDetailDomain.Dummies.prescriptions,
                        inRedeemProcess: false,
                        pharmacyViewModel: PharmacyDetailDomain.Dummies.pharmacyInactiveViewModel
                    )
                ) {
                    PharmacyDetailDomain()
                }
            )
        }
    }
}
