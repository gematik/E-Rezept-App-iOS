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

struct AppAuthenticationWithBiometricsView: View {
    @Perception.Bindable var store: StoreOf<AppAuthenticationBiometricsDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 8) {
                switch store.biometryType {
                case .faceID:
                    FaceIDView {
                        store.send(.startAuthenticationChallenge)
                    }
                case .touchID:
                    TouchIDView {
                        store.send(.startAuthenticationChallenge)
                    }
                }
            }
            .padding(.vertical)
            .onAppear {
                if store.startImmediateAuthenticationChallenge {
                    store.send(.startAuthenticationChallenge)
                }
            }
            .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
        }
    }

    struct FaceIDView: View {
        let action: () -> Void

        var body: some View {
            PrimaryTextButton(
                text: L10n.authBtnBiometricsFaceid,
                a11y: A18n.auth.authBtnBiometricsFaceid,
                image: Image(systemName: SFSymbolName.faceId),
                useFullWidth: false,
                action: action
            )
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    struct TouchIDView: View {
        let action: () -> Void

        var body: some View {
            PrimaryTextButton(
                text: L10n.authBtnBiometricsTouchid,
                a11y: A18n.auth.authBtnBiometricsTouchid,
                image: Image(systemName: SFSymbolName.touchId),
                useFullWidth: false,
                action: action
            )
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct AppAuthenticationWithBiometricsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppAuthenticationWithBiometricsView(
                store: StoreOf<AppAuthenticationBiometricsDomain>(
                    initialState: AppAuthenticationBiometricsDomain.State(
                        biometryType: .faceID,
                        startImmediateAuthenticationChallenge: false
                    )
                ) {
                    AppAuthenticationBiometricsDomain()
                }
            )
        }
    }
}
