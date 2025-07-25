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

import AudioToolbox
import ComposableArchitecture
import eRpKit
import SwiftUI

struct ErxTaskScannerView: View {
    @Perception.Bindable var store: StoreOf<ScannerDomain>

    var body: some View {
        WithPerceptionTracking {
            ZStack {
                AVScannerView(erxCodeTypes: [.dataMatrix, .qr],
                              supportedCodeTypes: [.dataMatrix, .qr, .aztec],
                              scanning: store.scanState.isIdle) {
                    if store.state.scanState.isIdle {
                        // [REQ:BSI-eRp-ePA:O.Purp_2#1,O.Data_6#3] Scanning tasks contains purpose related data input
                        // [REQ:BSI-eRp-ePA:O.Source_1#1] Scanning tasks starts with scanner callback
                        store.send(.analyse(scanOutput: $0))
                    }
                }
                .edgesIgnoringSafeArea(.all)

                ScannerOverlay(store: store)

                CameraAuthorizationAlertView()
            }
            .onChange(of: store.scanState, perform: hapticAndAudioFeedback)
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
        }
    }

    private func hapticAndAudioFeedback(for state: LoadingState<[ScannedErxTask], ScannerDomain.Error>) {
        // For more info on the SystemSoundIDs: https://github.com/TUNER88/iOSSystemSoundsLibrary
        if state.isValue {
            AudioServicesPlayAlertSound(SystemSoundID(1111)) // JBL_Confirm
        }
        if case let LoadingState.error(error) = state, error.isDuplicate {
            AudioServicesPlayAlertSound(SystemSoundID(1115)) // JBL_Ambiguous
        }
        if case let LoadingState.error(error) = state, error.isFailure {
            AudioServicesPlayAlertSound(SystemSoundID(1116)) // JBL_NoMatch
        }
    }
}

struct ErxTaskScannerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ErxTaskScannerView(store: ScannerDomain.Dummies.store)
            ErxTaskScannerView(store: ScannerDomain.Dummies.store)
                .preferredColorScheme(.dark)
        }
    }
}
