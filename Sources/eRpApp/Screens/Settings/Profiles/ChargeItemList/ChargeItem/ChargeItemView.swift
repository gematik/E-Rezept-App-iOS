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

    @ObservedObject
    private var viewStore: ViewStore<ViewState, ChargeItemDomain.Action>

    init(store: ChargeItemDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let chargeItem: ErxChargeItem

        init(state: ChargeItemDomain.State) {
            chargeItem = state.chargeItem
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

                Button {} label: {
                    Label(L10n.stgBtnChargeItemShare)
                }
                .buttonStyle(.primaryHugging)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Colors.systemBackgroundSecondary.ignoresSafeArea())
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
    static var previews: some View {
        NavigationView {
            ChargeItemView(
                store: .init(
                    initialState: .init(
                        chargeItem: .init(
                            identifier: "abc",
                            fhirData: Data(),
                            enteredDate: "2023-01-1T15:57:45.000+02:00",
                            medication: nil,
                            medicationRequest: .init(),
                            patient: nil,
                            practitioner: nil,
                            organization: nil,
                            medicationDispense: nil
                        )
                    ),
                    reducer: EmptyReducer()
                )
            )
        }
    }
}
