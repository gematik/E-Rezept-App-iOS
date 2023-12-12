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

import ComposableArchitecture
import SwiftUI

struct OrderHealthCardContactView: View {
    let store: OrderHealthCardDomain.Store

    @ObservedObject var viewStore: ViewStore<ViewState, OrderHealthCardDomain.Action>

    init(store: OrderHealthCardDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        var insuranceCompany: OrderHealthCardDomain.HealthInsuranceCompany?
        var serviceInquiry: OrderHealthCardDomain.ServiceInquiry?
        var serviceInquiryId: Int
        var isPinServiceAndContact: Bool
        var hasHealthCardAndPinServiceAndContact: Bool
        let routeTag: OrderHealthCardDomain.Destinations.State.Tag?

        init(state: OrderHealthCardDomain.State) {
            insuranceCompany = state.insuranceCompany
            serviceInquiry = state.serviceInquiry
            serviceInquiryId = state.serviceInquiryId
            isPinServiceAndContact = state.isPinServiceAndContact
            hasHealthCardAndPinServiceAndContact = state.isHealthCardAndPinServiceAndContact
            routeTag = state.destination?.tag
        }
    }

    var body: some View {
        VStack(alignment: .center) {
            if viewStore.isPinServiceAndContact || viewStore.hasHealthCardAndPinServiceAndContact {
                Text(L10n.oderEgkContactTitle)
                    .font(Font.largeTitle.weight(.bold))
                    .foregroundColor(Color(.label))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)

                Text(L10n.oderEgkContactSubtitle)
                    .font(.subheadline)
                    .foregroundColor(Colors.systemLabelSecondary)
                    .multilineTextAlignment(.center)

                if let serverInquiry = viewStore.serviceInquiry, let insuranceCompany = viewStore.insuranceCompany {
                    ContactOptionsRowView(
                        healthInsuranceCompany: insuranceCompany,
                        serviceInquiry: serverInquiry
                    )
                }
                Spacer()
            } else {
                ZStack(alignment: .bottom) {
                    Image(Asset.OrderEGK.womanShrug)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 200, height: 200)

                    Text(L10n.oderEgkContactNoTitle)
                        .font(Font.body.weight(.bold))
                        .foregroundColor(Color(.label))
                        .multilineTextAlignment(.center)
                }
                Text(L10n.oderEgkContactNoSubtitle)
                    .font(.subheadline)
                    .foregroundColor(Colors.systemLabelSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .navigationBarItems(
            trailing: NavigationBarCloseItem {
                viewStore.send(.delegate(.close))
            }
            .accessibility(identifier: A11y.cardWall.intro.cdwBtnIntroCancel)
            .accessibility(label: Text(L10n.cdwBtnIntroCancelLabel))
        )
    }
}

extension ContactOptionsRowView {
    init(
        healthInsuranceCompany: OrderHealthCardDomain.HealthInsuranceCompany,
        serviceInquiry: OrderHealthCardDomain.ServiceInquiry
    ) {
        switch serviceInquiry {
        case .pin:
            self.init(
                phone: healthInsuranceCompany.healthCardAndPinPhone,
                web: healthInsuranceCompany.pinUrl,
                email: healthInsuranceCompany.createEmailUrl(for: .pin)
            )
        case .healthCardAndPin:
            self.init(
                phone: healthInsuranceCompany.healthCardAndPinPhone,
                web: healthInsuranceCompany.healthCardAndPinUrl,
                email: healthInsuranceCompany.createEmailUrl(for: .healthCardAndPin)
            )
        }
    }
}

struct OrderHealthCardContactView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrderHealthCardInquiryView(store: OrderHealthCardDomain.Dummies.store)
        }
        NavigationView {
            OrderHealthCardInquiryView(store: OrderHealthCardDomain.Dummies.store)
        }
    }
}
