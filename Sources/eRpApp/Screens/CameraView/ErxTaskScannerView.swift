//
//  Copyright (c) 2021 gematik GmbH
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

import AudioToolbox
import ComposableArchitecture
import eRpKit
import SwiftUI

struct ErxTaskScannerView: View {
    let store: ScannerDomain.Store

    init(store: ScannerDomain.Store) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                AVScannerView(erxCodeTypes: [.dataMatrix],
                              supportedCodeTypes: [.dataMatrix, .qr, .aztec],
                              scanning: viewStore.scanState.isIdle) {
                    if viewStore.state.scanState.isIdle {
                        viewStore.send(.analyse(scanOutput: $0))
                    }
                }
                .edgesIgnoringSafeArea(.all)

                ScannerOverlay(store: store)

                CameraAuthorizationAlertView()
            }
            .onChange(of: viewStore.scanState, perform: hapticAndAudioFeedback)
            .alert(
                self.store.scope(state: \.alertState),
                dismiss: .alertDismissButtonTapped
            )
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
