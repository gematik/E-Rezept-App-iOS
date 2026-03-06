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
import SwiftUI

public struct EURedeemView: View {
    @Bindable var store: StoreOf<EURedeemDomain>

    public init(store: StoreOf<EURedeemDomain>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            EURedeemSelectionView(store: store.scope(state: \.selection, action: \.selection))
        } destination: { store in
            switch store.case {
            case let .countrySelection(countrySelectionStore):
                CountrySelectionView(store: countrySelectionStore)
            case let .prescriptionSelection(prescriptionSelectionStore):
                SelectEUPrescriptionsView(store: prescriptionSelectionStore)
            case let .instructions(instructionsStore):
                InstructionsView(store: instructionsStore)
            case let .code(codeStore):
                CodeView(store: codeStore)
            }
        }
    }
}

#Preview("EURedeemView") {
    EURedeemView(store: Store(initialState: EURedeemDomain.State(selection: .init(
        prescriptions: Shared(value: EURedeemSelectionDomain.Dummies.prescriptions)
    ))) {
        EURedeemDomain()
    })
}
