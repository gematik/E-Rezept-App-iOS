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

import SwiftUI

struct CameraAuthorizationAlertView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel = CameraAuthorizationAlertViewModel()

    var body: some View {
        Color(.clear)
            .alert(
                L10n.camPermDenyTitle.text,
                isPresented: $viewModel.showAuthorizationAlert,
                actions: {
                    Button(L10n.camPermDenyBtnCancel.text, role: .cancel) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    Button(L10n.camPermDenyBtnSettings) {
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                              UIApplication.shared.canOpenURL(settingsUrl) else {
                            self.presentationMode.wrappedValue.dismiss()
                            return
                        }

                        UIApplication.shared.open(settingsUrl)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                },
                message: { Text(L10n.camPermDenyMessage) }
            )
    }
}
