//
//  Copyright (c) 2021 gematik GmbH
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
import MapKit
import Pharmacy
import SwiftUI

struct PharmacyDetailView: View {
    let store: PharmacyDetailDomain.Store

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    if viewStore.pharmacy.isErxReady {
                        ErxReadinessBadge(detailedText: true)
                    }

                    Text(viewStore.state.pharmacy.name ??
                        NSLocalizedString("pha_detail_txt_subtitle_fallback", comment: ""))
                        .foregroundColor(Colors.systemLabel)
                        .font(.title2)
                        .bold()
                        .accessibility(identifier: A11y.pharmacyDetail.phaDetailTxtSubtitle)

                    if let address = viewStore.state.pharmacy.address?.fullAddress {
                        TertiaryButton(text: LocalizedStringKey(address),
                                       isEnabled: viewStore.state.pharmacy.canBeDisplayedInMap,
                                       imageName: SFSymbolName.map) {
                            viewStore.send(.openMapApp)
                        }
                        .accessibility(identifier: A11y.pharmacyDetail.phaDetailBtnLocation)
                        .padding(.bottom, 24)
                    }

                    if viewStore.pharmacy.isErxReady {
                        VStack(spacing: 8) {
                            if viewStore.state.pharmacy.hasReservationService {
                                DefaultTextButton(text: L10n.phaDetailBtnLocation,
                                                  a11y: A11y.pharmacyDetail.phaDetailBtnLocation,
                                                  style: .primary) {
                                    viewStore.send(.showPharmacyRedeemView(.onPremise))
                                }
                            }

                            if viewStore.state.pharmacy.hasDeliveryService {
                                DefaultTextButton(
                                    text: L10n.phaDetailBtnHealthcareService,
                                    a11y: A11y.pharmacyDetail.phaDetailBtnHealthcareService,
                                    style: viewStore.state.pharmacy.hasReservationService ? .secondary : .primary
                                ) {
                                    viewStore.send(.showPharmacyRedeemView(.delivery))
                                }
                            }

                            if viewStore.state.pharmacy.hasMailService {
                                DefaultTextButton(
                                    text: L10n.phaDetailBtnOrganization,
                                    a11y: A11y.pharmacyDetail.phaDetailBtnOrganization,
                                    style: (!viewStore.state.pharmacy.hasReservationService &&
                                        !viewStore.state.pharmacy.hasDeliveryService) ? .primary : .secondary
                                ) {
                                    viewStore.send(.showPharmacyRedeemView(.shipment))
                                }
                            }
                        }
                    } // if viewStore.pharmacy.isErxReady

                    if viewStore.pharmacy.isErxReady {
                        HintView<PharmacyDetailDomain.Action>(
                            hint: Hint(id: A11y.pharmacyDetail.phaDetailHint,
                                       message: NSLocalizedString("pha_detail_hint_message", comment: ""),
                                       imageName: Asset.Illustrations.info.name)
                        )
                        .padding(.top, 12)
                        .padding(.bottom, 32)
                    } else {
                        HintView<PharmacyDetailDomain.Action>(
                            hint: Hint(id: A11y.pharmacyDetail.phaDetailHintNotErxReady,
                                       title: NSLocalizedString("pha_detail_hint_not_erx_ready_title", comment: ""),
                                       message: NSLocalizedString("pha_detail_hint_not_erx_ready_message", comment: ""),
                                       imageName: Asset.Illustrations.pharmacistArmRedCirle.name,
                                       style: .important)
                        )
                    }

                    if !viewStore.state.pharmacy.hoursOfOperation.isEmpty {
                        OpeningHoursView(dailyOpenHours: viewStore.state.pharmacyViewModel.days)
                            .padding(.bottom, 8)
                    }

                    ContactView(store: store)

                    Footer()
                        .padding(.top, 4)

                    RedeemViewPresentation(store: store).accessibility(hidden: true)
                }.padding()
            }
            .navigationBarTitle(L10n.phaDetailTxtTitle, displayMode: .inline)
            .navigationBarItems(
                trailing: NavigationBarCloseItem { viewStore.send(.close) }
            )
            .navigationBarTitleDisplayMode(.inline)
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

    struct OpeningHoursView: View {
        let dailyOpenHours: [PharmacyLocationViewModel.DailyOpenHours]

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
                    Spacer(minLength: 0)
                    VStack(alignment: .trailing) {
                        ForEach(dailyOpenHour.entries, id: \.self) { hop in
                            Text("\(hop.openingTime ?? "") - \(hop.closingTime ?? "")")
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
    }

    struct ContactView: View {
        let store: PharmacyDetailDomain.Store
        var body: some View {
            VStack {
                WithViewStore(store) { viewStore in
                    SectionHeaderView(text: L10n.phaDetailContact,
                                      a11y: A11y.pharmacyDetail.phaDetailContact)

                    if let phone = viewStore.state.pharmacy.telecom?.phone {
                        Button(action: { viewStore.send(.openPhoneApp) }, label: {
                            DetailedIconCellView(title: L10n.phaDetailPhone,
                                                 value: phone,
                                                 imageName: SFSymbolName.phone,
                                                 a11y: A11y.pharmacyDetail.phaDetailPhone)
                        })
                    }
                    if let email = viewStore.state.pharmacy.telecom?.email {
                        Button(action: { viewStore.send(.openMailApp) }, label: {
                            DetailedIconCellView(title: L10n.phaDetailMail,
                                                 value: email,
                                                 imageName: SFSymbolName.mail,
                                                 a11y: A11y.pharmacyDetail.phaDetailMail)
                        })
                    }
                    if let web = viewStore.state.pharmacy.telecom?.web {
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

    struct RedeemViewPresentation: View {
        let store: PharmacyDetailDomain.Store
        var body: some View {
            WithViewStore(store) { viewStore in
                NavigationLink(destination: IfLetStore(
                    store.scope(
                        state: { $0.pharmacyRedeemState },
                        action: PharmacyDetailDomain.Action.pharmacyRedeem(action:)
                    ),
                    then: PharmacyRedeemView.init(store:)
                ),
                isActive: viewStore.binding(
                    get: { $0.isPharmacyRedeemViewPresented },
                    send: PharmacyDetailDomain.Action.dismissPharmacyRedeemView
                )) {
                    EmptyView()
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
                    guard let url = URL(string: "https://www.gematik.de/anwendungen/e-rezept/faq/meine_apotheke/"),
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
