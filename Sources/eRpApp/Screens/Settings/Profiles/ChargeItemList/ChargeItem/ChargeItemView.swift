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

struct ChargeItemView: View {
    @Perception.Bindable var store: StoreOf<ChargeItemDomain>

    @Dependency(\.uiDateFormatter) var dateFormatter
    @Dependency(\.fhirDateFormatter) var fhirDateFormatter

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                ScrollView {
                    SectionContainer(
                        header: {
                            Text(store.chargeItem.medication?.name ?? "-")
                                .font(.title2.bold())
                                .padding()
                        },
                        footer: {
                            WithPerceptionTracking {
                                if store.showRouteToChargeItemListButton {
                                    Button {
                                        store.send(.routeToChargeItemList)
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text(L10n.stgBtnChargeItemRouteToList)
                                                .font(Font.subheadline)
                                            Image(systemName: SFSymbolName.chevronRight)
                                                .font(Font.subheadline.weight(.semibold))
                                        }
                                    }
                                    .buttonStyle(TertiaryButtonStyle())
                                    .foregroundColor(Colors.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        },
                        content: {
                            SubTitle(
                                title: dateFormatter.relativeDateAndTime(
                                    store.chargeItem.medicationDispense?.whenHandedOver
                                ) ?? "-",
                                description: L10n.stgTxtChargeItemCreator
                            )

                            SubTitle(
                                title: store.chargeItem.pharmacy?.name ?? "-",
                                description: L10n.stgTxtChargeItemRedeemedAt
                            )

                            SubTitle(
                                title: dateFormatter
                                    .relativeDateAndTime(store.chargeItem.enteredDate) ?? "-",
                                description: L10n.stgTxtChargeItemRedeemedOn
                            )
                        }
                    )
                    .sectionContainerStyle(.inline)
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text(store.chargeItem.totalGrossPrice)
                            .font(.title3.bold())

                        Text(L10n.stgTxtChargeItemSum)
                            .font(.body)
                            .foregroundColor(Color(.secondaryLabel))
                    }

                    Spacer()

                    Button {
                        store.send(.redeem)
                    } label: {
                        Text(L10n.stgBtnChargeItemShare)
                    }
                    .buttonStyle(.primaryHuggingNarrowly)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Colors.systemBackgroundSecondary.ignoresSafeArea())
            }
            .background(Colors.systemBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu {
                        Menu {
                            Button(action: {
                                store.send(.alterChargeItem)
                            }, label: {
                                Text(L10n.stgBtnChargeItemAlterViaPharmacy)
                                    .foregroundColor(Colors.primary700)
                            })
                            Button(action: {}, label: {
                                Text(L10n.stgBtnChargeItemAlterViaApp)
                                    .foregroundColor(Colors.primary700)
                            })
                                .disabled(true)

                        } label: {
                            Text(L10n.stgTxtChargeItemAlterTitle)
                                .foregroundColor(Colors.primary700)
                        }
                        Button(role: .destructive,
                               action: {
                                   store.send(.deleteButtonTapped)
                               }, label: {
                                   Text(L10n.stgBtnChargeItemDelete)
                                       .foregroundColor(Colors.red600)
                               })
                    } label: {
                        Label(L10n.ordDetailTxtContact, systemImage: SFSymbolName.ellipsis)
                            .foregroundColor(Colors.primary700)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {}
            }
            .sheet(item: $store.scope(
                state: \.destination?.shareSheet,
                action: \.destination.shareSheet
            )) { scopedStore in
                ShareViewController(store: scopedStore)
            }
            .sheet(item: $store.scope(
                state: \.destination?.idpCardWall,
                action: \.destination.idpCardWall
            )) { store in
                IDPCardWallView(store: store)
            }
            .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))

            // Navigation into matrix code to alter charge item via pharmacy
            NavigationLink(
                item: $store.scope(
                    state: \.destination?.alterChargeItem,
                    action: \.destination.alterChargeItem
                )
            ) { store in
                MatrixCodeView(store: store)
            } label: {
                EmptyView()
            }
            .hidden()
            .accessibility(hidden: true)
        }
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
}

struct ChargeItemView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChargeItemView(
                store: .init(
                    initialState: .init(
                        profileId: UUID(),
                        chargeItem: ErxChargeItem.Dummies.dummy
                    )
                ) {
                    ChargeItemDomain()
                }
            )
        }
    }
}

extension ErxChargeItem {
    static let chargeItemAsFHIRData = DummyChargeItemListDomainService.chargeItemAsFHIRData

    enum Dummies {
        static let dummy = ErxChargeItem(
            identifier: "chargeItem_id_12",
            fhirData: chargeItemAsFHIRData,
            enteredDate: "2023-02-17T14:07:46.964+00:00",
            medication: ErxMedication(
                name: "Schmerzmittel",
                profile: ErxMedication.ProfileType.pzn,
                drugCategory: .avm,
                pzn: "17091124",
                amount: ErxMedication.Ratio(
                    numerator: ErxMedication.Quantity(
                        value: "1",
                        unit: "Stk"
                    ),
                    denominator: ErxMedication.Quantity(value: "1")
                ),
                dosageForm: "TAB",
                normSizeCode: "NB"
            ),
            medicationRequest: .init(
                authoredOn: "2023-02-02T14:07:46.964+00:00",
                dosageInstructions: "1-0-0-0",
                substitutionAllowed: true,
                hasEmergencyServiceFee: false,
                bvg: false,
                coPaymentStatus: .subjectToCharge,
                multiplePrescription: .init(mark: false),
                quantity: .init(value: "17", unit: "Packungen")
            ),
            patient: .init(
                name: "Günther Angermänn",
                address: "Weiherstr. 74a\n67411 Büttnerdorf",
                birthDate: "1976-04-30",
                status: "1",
                insurance: "Künstler-Krankenkasse Baden-Württemberg",
                insuranceId: "X110465770",
                coverageType: .PKV
            ),
            practitioner: ErxPractitioner(
                lanr: "443236256",
                name: "Dr. Dr. Schraßer",
                qualification: "Super-Facharzt für alles Mögliche",
                address: "Halligstr. 98 85005 Alt Mateo"
            ),
            organization: ErxOrganization(
                identifier: "734374849",
                name: "Arztpraxis Schraßer",
                phone: "(05808) 9632619",
                email: "andre.teufel@xn--schffer-7wa.name",
                address: "Halligstr. 98\n85005, Alt Mateo"
            ),
            pharmacy: .init(
                identifier: "012876",
                name: "Pharmacy Name",
                address: "Pharmacy Street 2\n13267, Berlin",
                country: "DE"
            ),
            invoice: .init(
                totalAdditionalFee: 5.0,
                totalGross: 345.34,
                currency: "EUR",
                chargeableItems: [
                    DavInvoice.ChargeableItem(
                        factor: 2.0,
                        price: 5.12,
                        pzn: "pzn_123",
                        ta1: "ta1_456",
                        hmrn: "hmrn_789"
                    ),
                ]
            ),
            medicationDispense: .init(
                identifier: "e00e96a2-6dae-4036-8e72-42b5c21fdbf3",
                whenHandedOver: "2023-02-17",
                taskId: "abc"
            ),
            prescriptionSignature: .init(
                when: "2023-02-17T14:07:47.806+00:00",
                sigFormat: "application/pkcs7-mime",
                data: "vDAo+tog=="
            ),
            receiptSignature: .init(
                when: "2023-02-17T14:07:47.808+00:00",
                sigFormat: "application/pkcs7-mime",
                data: "Mb3ej1h4E="
            ),
            dispenseSignature: .init(
                when: "2023-02-17T14:07:47.809+00:00",
                sigFormat: "application/pkcs7-mime",
                data: "aOEsSfDw=="
            )
        )
    }
}
