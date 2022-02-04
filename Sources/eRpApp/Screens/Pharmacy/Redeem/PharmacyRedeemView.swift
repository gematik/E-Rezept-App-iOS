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
import Pharmacy
import SwiftUI

struct PharmacyRedeemView: View {
    let store: PharmacyRedeemDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, PharmacyRedeemDomain.Action>

    init(store: PharmacyRedeemDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical) {
                VStack(spacing: 32) {
                    TitleView(option: viewStore.redeemType, pharmacyName: viewStore.pharmacy.name)

                    if viewStore.redeemType != .onPremise {
                        AddressView(viewStore: viewStore)
                    }

                    PrescriptionView(viewStore: viewStore)
                }
                .padding()
            }

            Spacer()

            RedeemButton(viewStore: viewStore)
                .alert(
                    self.store.scope(state: \.alertState),
                    dismiss: .alertDismissButtonTapped
                )

            RedeemSuccessViewPresentation(store: store).accessibility(hidden: true)
        }
        .navigationTitle(L10n.phaRedeemTitle)
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

    struct TitleView: View {
        let option: RedeemOption
        let pharmacyName: String?

        var body: some View {
            VStack(spacing: 8) {
                Text(option.localizedString)
                    .foregroundColor(Colors.systemLabel)
                    .font(Font.title.bold())
                    .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemTxtTitle)

                Text(L10n.phaRedeemTxtSubtitle(pharmacyName ?? ""))
                    .font(Font.subheadline.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemTxtSubtitle)
            }
        }
    }

    struct AddressView: View {
        @State var viewStore: ViewStore<ViewState, PharmacyRedeemDomain.Action>
        var body: some View {
            VStack(spacing: 16) {
                SectionHeaderView(text: L10n.phaRedeemTxtAddress,
                                  a11y: A11y.pharmacyRedeem.phaRedeemTxtAddressTitle)

                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: SFSymbolName.house)
                        .font(Font.title3.weight(.bold))

                    VStack(alignment: .leading) {
                        Group {
                            Text(viewStore.name)
                            Text(viewStore.address)
                        }
                        .font(Font.subheadline)
                        .fixedSize(horizontal: false, vertical: true)

                        if viewStore.redeemType == .shipment {
                            Text(L10n.phaRedeemTxtAddressFootnote)
                                .font(.footnote)
                                .padding(.top, 8)
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemTxtAddressFootnote)
                        }
                    }

                    Spacer()
                }
                .foregroundColor(Colors.systemLabelSecondary)
                .padding()
                .border(Colors.systemLabelSecondary, width: 0.5, cornerRadius: 16)
            }
        }
    }

    struct PrescriptionView: View {
        @State var viewStore: ViewStore<ViewState, PharmacyRedeemDomain.Action>
        var body: some View {
            VStack(spacing: 0) {
                SectionHeaderView(text: L10n.phaRedeemTxtPrescription,
                                  a11y: A11y.pharmacyRedeem.phaRedeemTxtPrescriptionTitle)

                ForEach(viewStore.prescriptions) { prescription in
                    Button(action: { viewStore.send(.didSelect(prescription.taskID)) },
                           label: {
                               TitleWithSubtitleCellView(
                                   title: prescription.title,
                                   subtitle: prescription.subtitle,
                                   isSelected: prescription.isSelected
                               )
                           })
                }
            }
        }
    }

    struct RedeemButton: View {
        @State var viewStore: ViewStore<ViewState, PharmacyRedeemDomain.Action>
        var body: some View {
            VStack(spacing: 8) {
                GreyDivider()

                if !viewStore.isRedeemButtonEnabled {
                    PrimaryTextButton(text: L10n.phaRedeemBtnRedeem,
                                      a11y: A11y.pharmacyRedeem.phaRedeemBtnRedeem,
                                      isEnabled: viewStore.isRedeemButtonEnabled) {
                        viewStore.send(.showRedeemAlert)
                    }
                    .padding(.horizontal)
                } else {
                    LoadingPrimaryButton(text: L10n.phaRedeemBtnRedeem,
                                         isLoading: viewStore.loadingState.isLoading) {
                        viewStore.send(.showRedeemAlert)
                    }
                    .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemBtnRedeem)
                    .padding(.horizontal)
                }

                Text(L10n.phaRedeemBtnRedeemFootnote)
                    .font(.footnote)
                    .foregroundColor(Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemBtnRedeemFootnote)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
    }

    struct RedeemSuccessViewPresentation: View {
        let store: PharmacyRedeemDomain.Store
        var body: some View {
            WithViewStore(self.store) { viewStore in
                NavigationLink(destination: IfLetStore(
                    store.scope(
                        state: { $0.successViewState },
                        action: PharmacyRedeemDomain.Action.redeemSuccessView(action:)
                    ),
                    then: RedeemSuccessView.init(store:)
                ),
                isActive: viewStore.binding(
                    get: { $0.successViewState != nil },
                    send: PharmacyRedeemDomain.Action.dismissRedeemSuccessView
                )) {
                    EmptyView()
                }
            }
        }
    }
}

extension PharmacyRedeemView {
    struct ViewState: Equatable {
        let redeemType: RedeemOption
        let pharmacy: PharmacyLocation
        let prescriptions: [Prescription]
        let name: String
        let address: String
        let loadingState: LoadingState<Bool, ErxRepositoryError>

        init(state: PharmacyRedeemDomain.State) {
            redeemType = state.redeemOption
            pharmacy = state.pharmacy
            prescriptions = state.erxTasks.map {
                let isSelected = state.selectedErxTasks.contains($0)
                return Prescription($0, isSelected: isSelected)
            }
            if let patient = state.erxTasks.first?.patient {
                name = patient.name ?? ""
                address = patient.address ?? ""
            } else {
                name = ""
                address = ""
            }
            loadingState = state.loadingState
        }

        var isRedeemButtonEnabled: Bool {
            prescriptions.first { $0.isSelected == true } != nil
        }

        struct Prescription: Equatable, Identifiable {
            var id: String { taskID } // swiftlint:disable:this identifier_name
            let taskID: String
            let title: String
            let subtitle: String
            var isSelected = false

            init(_ task: ErxTask, isSelected: Bool) {
                taskID = task.id
                title = task.medication?.name ?? L10n.prscFdTxtNa.text
                subtitle = task
                    .substitutionAllowed ? L10n.phaRedeemTxtPrescriptionSub.text : ""
                self.isSelected = isSelected
            }
        }
    }
}

extension RedeemOption {
    var localizedString: LocalizedStringKey {
        switch self {
        case .onPremise: return L10n.phaRedeemTxtTitleReservation.key
        case .delivery: return L10n.phaRedeemTxtTitleDelivery.key
        case .shipment: return L10n.phaRedeemTxtTitleMail.key
        }
    }
}

struct ReservationView_Previews: PreviewProvider {
    static var previews: some View {
        PharmacyRedeemView(store: PharmacyRedeemDomain.Dummies.store)
    }
}
