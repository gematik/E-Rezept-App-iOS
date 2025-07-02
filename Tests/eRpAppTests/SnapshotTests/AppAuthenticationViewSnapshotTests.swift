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

import CombineSchedulers
import ComposableArchitecture
@testable import eRpFeatures
import SnapshotTesting
import SwiftUI
import XCTest

final class AppAuthenticationViewSnapshotTests: ERPSnapshotTestCase {
    func testAppAuthenticationViewWithPassword() {
        let sut = AppAuthenticationView(
            store: StoreOf<AppAuthenticationDomain>(
                initialState: AppAuthenticationDomain.State(
                    didCompleteAuthentication: false,
                    subdomain: .password(AppAuthenticationPasswordDomain.State()),
                    failedAuthenticationsCount: 0
                )
            ) {
                EmptyReducer()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testAppAuthenticationViewWithViewWithPasswordAndFailedAuthentications() {
        let sut = AppAuthenticationView(
            store: StoreOf<AppAuthenticationDomain>(
                initialState: AppAuthenticationDomain.State(
                    didCompleteAuthentication: false,
                    subdomain: .password(AppAuthenticationPasswordDomain.State(lastMatchResultSuccessful: false)),
                    failedAuthenticationsCount: 1
                )
            ) {
                EmptyReducer()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testAppAuthenticationViewWithFaceID() {
        let sut = AppAuthenticationView(
            store: StoreOf<AppAuthenticationDomain>(
                initialState: AppAuthenticationDomain.State(
                    didCompleteAuthentication: false,
                    subdomain: .biometrics(AppAuthenticationBiometricsDomain.State(
                        biometryType: .faceID,
                        startImmediateAuthenticationChallenge: false
                    )),
                    failedAuthenticationsCount: 0
                )
            ) {
                EmptyReducer()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testAppAuthenticationViewWithTouchID() {
        let sut = AppAuthenticationView(
            store: StoreOf<AppAuthenticationDomain>(
                initialState: AppAuthenticationDomain.State(
                    didCompleteAuthentication: false,
                    subdomain: .biometrics(AppAuthenticationBiometricsDomain.State(
                        biometryType: .touchID,
                        startImmediateAuthenticationChallenge: false
                    )),
                    failedAuthenticationsCount: 0
                )
            ) {
                EmptyReducer()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testAppAuthenticationViewWithTouchIDWithFailedAuthentications() {
        let sut = AppAuthenticationView(
            store: StoreOf<AppAuthenticationDomain>(
                initialState: AppAuthenticationDomain.State(
                    didCompleteAuthentication: false,
                    subdomain: .biometrics(AppAuthenticationBiometricsDomain.State(
                        biometryType: .touchID,
                        startImmediateAuthenticationChallenge: false
                    )),
                    failedAuthenticationsCount: 1
                )
            ) {
                EmptyReducer()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testAppAuthenticationBiometricPasswordView() {
        let sut = AppAuthenticationView(
            store: StoreOf<AppAuthenticationDomain>(
                initialState: AppAuthenticationDomain.State(
                    didCompleteAuthentication: false,
                    subdomain: .biometricAndPassword(.init(
                        biometryType: .faceID,
                        startImmediateAuthenticationChallenge: false,
                        authenticationResult: .success(true)
                    )),
                    failedAuthenticationsCount: 0
                )
            ) {
                EmptyReducer()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testAppAuthenticationBiometricPasswordFaceIDFailed() {
        let sut = AppAuthenticationView(
            store: StoreOf<AppAuthenticationDomain>(
                initialState: AppAuthenticationDomain.State(
                    didCompleteAuthentication: false,
                    subdomain: .biometricAndPassword(.init(
                        biometryType: .faceID,
                        startImmediateAuthenticationChallenge: false
                    )),
                    failedAuthenticationsCount: 1
                )
            ) {
                EmptyReducer()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testAppAuthenticationBiometricPasswordPasswordView() {
        let sut = AppAuthenticationView(
            store: StoreOf<AppAuthenticationDomain>(
                initialState: AppAuthenticationDomain.State(
                    didCompleteAuthentication: false,
                    subdomain: .biometricAndPassword(.init(
                        biometryType: .faceID,
                        startImmediateAuthenticationChallenge: false,
                        showPassword: true
                    )),
                    failedAuthenticationsCount: 0
                )
            ) {
                EmptyReducer()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
