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

struct ChargeItemView: View {
    let store: ChargeItemDomain.Store

    @ObservedObject private var viewStore: ViewStore<ViewState, ChargeItemDomain.Action>

    init(store: ChargeItemDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let chargeItem: ErxChargeItem
        let destinationTag: ChargeItemDomain.Destinations.State.Tag?

        init(state: ChargeItemDomain.State) {
            chargeItem = state.chargeItem

            destinationTag = state.destination?.tag
        }
    }

    @Dependency(\.uiDateFormatter) var dateFormatter
    @Dependency(\.fhirDateFormatter) var fhirDateFormatter

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                SectionContainer(
                    header: {
                        Text(viewStore.chargeItem.medication?.name ?? "-")
                            .font(.title2.bold())
                            .padding()
                    },
                    footer: {
                        Button {
                            // TODO: do something swiftlint:disable:this todo
                        } label: {
                            Label(L10n.stgBtnChargeItemMore)
                        }
                        .buttonStyle(.quartary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    },
                    content: {
                        SubTitle(
                            title: dateFormatter.relativeDateAndTime(
                                viewStore.chargeItem.medicationDispense?.whenHandedOver
                            ) ?? "-",
                            description: L10n.stgTxtChargeItemCreator
                        )

                        SubTitle(
                            title: viewStore.chargeItem.pharmacy?.name ?? "-",
                            description: L10n.stgTxtChargeItemRedeemedAt
                        )

                        SubTitle(
                            title: dateFormatter.relativeDateAndTime(viewStore.chargeItem.enteredDate) ?? "-",
                            description: L10n.stgTxtChargeItemRedeemedOn
                        )

                        HStack {
                            // TODO: placeholder swiftlint:disable:this todo
                            Flag(title: "Versicherung")
                        }
                    }
                )
            }

            HStack {
                VStack(alignment: .leading) {
                    Text(viewStore.chargeItem.totalGrossPrice)
                        .font(.title3.bold())

                    Text(L10n.stgTxtChargeItemSum)
                        .font(.body)
                        .foregroundColor(Color(.secondaryLabel))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    viewStore.send(.redeem)
                } label: {
                    Label(L10n.stgBtnChargeItemShare)
                }
                .buttonStyle(.primaryHugging)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Colors.systemBackgroundSecondary.ignoresSafeArea())

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
                                state: /ChargeItemDomain.Destinations.State.idpCardWall,
                                action: ChargeItemDomain.Destinations.Action.idpCardWallAction
                            ),
                            then: IDPCardWallView.init(store:)
                        )
                    }
                )
                .accessibility(hidden: true)
                .hidden()
        }
        .alert(
            store.destinationsScope(state: /ChargeItemDomain.Destinations.State.alert),
            dismiss: .nothing
        )
        .sheet(
            isPresented: viewStore.binding(
                get: { $0.destinationTag == ChargeItemDomain.Destinations.State.Tag.shareSheet },
                send: { show in
                    if !show {
                        return .setNavigation(tag: nil)
                    }
                    return .nothing
                }
            )
        ) {
            IfLetStore(
                store.destinationsScope(
                    state: /ChargeItemDomain.Destinations.State.shareSheet
                )
            ) { store in
                WithViewStore(store) { sheetViewStore in
                    ShareViewController(itemsToShare: sheetViewStore.state)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive,
                           action: {
                               viewStore.send(.deleteButtonTapped)
                           }, label: {
                               Text(L10n.stgBtnChargeItemDelete)
                                   .foregroundColor(Colors.red600)
                           })
                } label: {
                    Label(L10n.ordDetailTxtContact, systemImage: SFSymbolName.ellipsis)
                        .foregroundColor(Colors.primary700)
                }
            }
        }
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
}

struct ChargeItemView_Preview: PreviewProvider {
    static let chargeItemAsFHIRData = DummyChargeItemListDomainService.chargeItemAsFHIRData

    static var previews: some View {
        NavigationView {
            ChargeItemView(
                store: .init(
                    initialState: .init(
                        profileId: UUID(),
                        chargeItem: .init(
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
                                multiplePrescription: .init(mark: false)
                            ),
                            patient: .init(
                                name: "Günther Angermänn",
                                address: "Weiherstr. 74a\n67411 Büttnerdorf",
                                birthDate: "1976-04-30",
                                status: "1",
                                insurance: "Künstler-Krankenkasse Baden-Württemberg",
                                insuranceId: "X110465770"
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
                    ),
                    reducer: ChargeItemDomain()
                )
            )
        }
    }
}
