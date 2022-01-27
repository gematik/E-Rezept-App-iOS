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
import SwiftUI

struct DeviceSecurityView: View {
    let store: DeviceSecurityDomain.Store
    @ObservedObject private var viewStore: ViewStore<DeviceSecurityDomain.State, DeviceSecurityDomain.Action>

    init(store: DeviceSecurityDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack {
            switch viewStore.warningType {
            case .jailbreakDetected:
                DeviceSecurityRootedDeviceView {
                    viewStore.send(.acceptRootedDevice)
                }
            case .devicePinMissing:
                DeviceSecuritySystemPinView { ignorePermanently in
                    viewStore.send(.acceptMissingPin(permanently: ignorePermanently))
                }
            default: EmptyView()
            }
        }
    }
}

struct DeviceSecurityView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceSecurityView(
            store: DeviceSecurityDomain.Dummies.store
        )
    }
}
