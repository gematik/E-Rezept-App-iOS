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
import eRpKit
import eRpStyleKit
import SwiftUI

extension PrescriptionDetailView {
    struct AccidentInfoView: View {
        let store: Store<PrescriptionDetailDomain.Destinations.AccidentInfoState, PrescriptionDetailDomain.Action>

        var body: some View {
            WithViewStore(store) { viewStore in
                ScrollView(.vertical) {
                    SectionContainer {
                        SubTitle(
                            title: viewStore.accidentInfo.localizedReason,
                            description: L10n.prscDtlTxtAccidentReason
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlAccidentReason)

                        SubTitle(
                            title: viewStore.accidentInfo.date ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtAccidentDate
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlAccidentDate)

                        SubTitle(
                            title: viewStore.accidentInfo.workPlaceIdentifier ?? L10n.prscFdTxtNa.text,
                            description: L10n.prscFdTxtAccidentId
                        )
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlAccidentId)

                    }.sectionContainerStyle(.inline)
                }
                .navigationBarTitle(Text(L10n.prscDtlTxtAccidentReason), displayMode: .inline)
            }
        }
    }
}

extension AccidentInfo {
    var localizedReason: StringAsset {
        switch type {
        case .accident: return L10n.prscDtlTxtAccidentReasonGeneral
        case .workAccident: return L10n.prscDtlTxtAccidentReasonWork
        case .workRelatedDisease: return L10n.prscDtlTxtAccidentReasonWorkRelated
        default:
            return L10n.prscFdTxtNa
        }
    }
}
