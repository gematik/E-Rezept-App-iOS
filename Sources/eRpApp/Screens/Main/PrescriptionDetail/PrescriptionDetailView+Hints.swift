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
import eRpStyleKit
import SwiftUI

extension PrescriptionDetailView {
    struct ChargeItemHintView: View {
        @Perception.Bindable var store: StoreOf<PrescriptionDetailDomain>

        var body: some View {
            WithPerceptionTracking {
                VStack {
                    if store.chargeItem != nil {
                        Button(action: {
                            store.send(.setNavigation(tag: .chargeItem))
                        }, label: {
                            Text(L10n.prscDtlBtnPkvInvoice)
                        })
                            .buttonStyle(.primaryHuggingNarrowly)
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlBtnPkvInvoice)
                    } else {
                        switch store.chargeItemConsentState {
                        case .granted:
                            HintView<PrescriptionDetailDomain.Action>(
                                hint: Hints.noInvoiceForTask
                            )
                            .border(Colors.primary300, width: 0.5, cornerRadius: 16)
                        case .notGranted:
                            HintView<PrescriptionDetailDomain.Action>(
                                hint: Hints.activateInvoice,
                                textAction: { store.send(.showGrantConsentAlert) }
                            )
                            .border(Colors.primary300, width: 0.5, cornerRadius: 16)
                        case .notAuthenticated:
                            EmptyView()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }

    enum Hints {
        static let activateInvoice = Hint<PrescriptionDetailDomain.Action>(
            id: A11y.prescriptionDetails.prscDtlHintPkvActivate,
            title: L10n.prscDtlTxtPkvHintActivateTitle.text,
            message: L10n.prscDtlTxtPkvHintActivateMsg.text,
            actionText: L10n.prscDtlBtnPkvHintActivate,
            actionImageName: SFSymbolName.arrowRight,
            image: AccessibilityImage(
                name: Asset.Prescriptions.Details.refreshLamp.name,
                accessibilityName: A11y.prescriptionDetails.prscDtlImgHintPkvActivate
            ),
            buttonStyle: .tertiary
        )

        static let noInvoiceForTask = Hint<PrescriptionDetailDomain.Action>(
            id: A11y.prescriptionDetails.prscDtlHintPkvNoInvoice,
            title: L10n.prscDtlTxtPkvHintNoInvoiceTitle.text,
            message: L10n.prscDtlTxtPkvHintNoInvoiceMsg.text,
            image: AccessibilityImage(
                name: Asset.Prescriptions.Details.lampIcon.name,
                accessibilityName: A11y.prescriptionDetails.prscDtlImgHintPkvNoInvoice
            ),
            buttonStyle: .tertiary
        )
    }
}
