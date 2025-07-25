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
import Foundation
import SwiftUI

struct ShareViewController: UIViewControllerRepresentable {
    @Perception.Bindable var store: StoreOf<ShareSheetDomain>

    init(store: StoreOf<ShareSheetDomain>) {
        self.store = store
    }

    func makeUIViewController(
        context _: UIViewControllerRepresentableContext<ShareViewController>
    ) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(
            activityItems: store.state.shareItems(),
            applicationActivities: store.state.servicesToShareItem
        )

        activityViewController.completionWithItemsHandler = { _, success, _, error in
            if success {
                store.send(.delegate(.close(nil)))
            } else if let error = error {
                store.send(.delegate(.close(.shareFailure(error.localizedDescription))))
            } else {
                store.send(.delegate(.close(nil)))
            }
        }

        return activityViewController
    }

    func updateUIViewController(
        _: UIActivityViewController,
        context _: UIViewControllerRepresentableContext<ShareViewController>
    ) {}
}
