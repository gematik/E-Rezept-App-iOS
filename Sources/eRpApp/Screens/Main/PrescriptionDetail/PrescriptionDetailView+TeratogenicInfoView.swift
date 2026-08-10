//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import ComposableArchitecture
import eRpKit
import eRpStyleKit
import SwiftUI

extension PrescriptionDetailView {
    struct TeratogenicInfoView: View {
        @Bindable var store: StoreOf<TeratogenicInfoDomain>

        var body: some View {
            ScrollView(.vertical) {
                SectionContainer {
                    LabeledContent {
                        Text(store.teratogenicInfo.safetyMeasuresCompliance ? L10n.prscDtlTxtYes : L10n.prscDtlTxtNo)
                    } label: {
                        Text(L10n.prscDtlTxtTeratogenicSafetyMeasures)
                    }

                    LabeledContent {
                        Text(store.teratogenicInfo.informationMaterialProvided
                            ? L10n.prscDtlTxtYes : L10n.prscDtlTxtNo)
                    } label: {
                        Text(L10n.prscDtlTxtTeratogenicInformationMaterial)
                    }

                    LabeledContent {
                        Text(store.teratogenicInfo.expertKnowledgeDeclaration
                            ? L10n.prscDtlTxtYes : L10n.prscDtlTxtNo)
                    } label: {
                        Text(L10n.prscDtlTxtTeratogenicExpertKnowledge)
                    }

                    LabeledContent {
                        Text(store.teratogenicInfo.offLabelUse ? L10n.prscDtlTxtYes : L10n.prscDtlTxtNo)
                    } label: {
                        Text(L10n.prscDtlTxtTeratogenicOffLabel)
                    }

                    LabeledContent {
                        Text(store.teratogenicInfo.womanOfChildbearingAge ? L10n.prscDtlTxtYes : L10n.prscDtlTxtNo)
                    } label: {
                        Text(L10n.prscDtlTxtTeratogenicWomanOfChildbearingAge)
                    }
                }.sectionContainerStyle(.inline)
            }
            .navigationBarTitle(Text(L10n.prscDtlTxtTeratogenicInfo), displayMode: .inline)
        }
    }
}

#Preview {
    NavigationStack {
        PrescriptionDetailView.TeratogenicInfoView(
            store: Store(
                initialState: TeratogenicInfoDomain.State(
                    teratogenicInfo: .init(
                        offLabelUse: false,
                        womanOfChildbearingAge: true,
                        safetyMeasuresCompliance: true,
                        informationMaterialProvided: true,
                        expertKnowledgeDeclaration: false
                    )
                )
            ) {
                TeratogenicInfoDomain()
            }
        )
    }
}
