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

import CombineSchedulers
@testable import eRpApp
import eRpKit
@testable import eRpLocalStorage
import SnapshotTesting
import SwiftUI
import XCTest

final class SettingsViewSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        diffTool = "open"
    }

    let debugStore = DebugDomain.Store(initialState: DebugDomain.State(trackingOptOut: true),
                                       reducer: .empty,
                                       environment: DebugDomain.Environment(
                                           schedulers: Schedulers(),
                                           userSession: DemoSessionContainer(),
                                           localUserStore: MockUserDataStore(),
                                           tracker: DummyTracker(),
                                           serverEnvironmentConfiguration: nil,
                                           signatureProvider: DummySecureEnclaveSignatureProvider(),
                                           serviceLocatorDebugAccess: ServiceLocatorDebugAccess(
                                               serviceLocator: ServiceLocator()
                                           )
                                       ))

    func testSettingsView_App_Security_Biometry_Available_No_Selection() {
        let sut = SettingsView(store: SettingsDomain.Store(
            initialState: configuredSettingsDomainState(
                withAvailableSecurityOptions: [.biometry(.faceID)],
                andSelectedSecurityOption: nil
            ),
            reducer: SettingsDomain.Reducer.empty,
            environment: SettingsDomain.Dummies.environment
        ),
        debugStore: debugStore)
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testSettingsView_App_Security_Biometry_Available_And_Selected() {
        let sut = SettingsView(store: SettingsDomain.Store(
            initialState: configuredSettingsDomainState(
                withAvailableSecurityOptions: [.biometry(.faceID)],
                andSelectedSecurityOption: .biometry(.faceID)
            ),
            reducer: SettingsDomain.Reducer.empty,
            environment: SettingsDomain.Dummies.environment
        ),
        debugStore: debugStore)
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testSettingsView_App_Security_Biometry_Available_Unsecured_Selected() {
        let sut = SettingsView(store: SettingsDomain.Store(
            initialState: configuredSettingsDomainState(
                withAvailableSecurityOptions: [.biometry(.faceID)],
                andSelectedSecurityOption: .unsecured
            ),
            reducer: SettingsDomain.Reducer.empty,
            environment: SettingsDomain.Dummies.environment
        ),
        debugStore: debugStore)
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testSettingsView_App_Security_Biometry_Unavailable_No_Selection() {
        let sut = SettingsView(store: SettingsDomain.Store(
            initialState: configuredSettingsDomainState(
                withAvailableSecurityOptions: [],
                andSelectedSecurityOption: nil
            ),
            reducer: SettingsDomain.Reducer.empty,
            environment: SettingsDomain.Dummies.environment
        ),
        debugStore: debugStore)
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testSettingsView_App_Security_Biometry_Unvailable_Unsecured_Selected() {
        let sut = SettingsView(store: SettingsDomain.Store(
            initialState: configuredSettingsDomainState(
                withAvailableSecurityOptions: [],
                andSelectedSecurityOption: .unsecured
            ),
            reducer: SettingsDomain.Reducer.empty,
            environment: SettingsDomain.Dummies.environment
        ),
        debugStore: debugStore)
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testSettingsView_DemoMode_Disabled() {
        let sut = SettingsView(store: SettingsDomain.Store(
            initialState: configuredSettingsDomainState(
                withAvailableSecurityOptions: [.password, .biometry(.faceID)],
                andSelectedSecurityOption: nil
            ),
            reducer: SettingsDomain.Reducer.empty,
            environment: SettingsDomain.Dummies.environment
        ),
        debugStore: debugStore)
            .frame(width: 320, height: 2000)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    let appVersion = AppVersion(productVersion: "1.0", buildNumber: "LOCAL BUILD", buildHash: "LOCAL BUILD")

    func testSettingsView_DemoMode_Enabled() {
        let sut = SettingsView(store: SettingsDomain.Store(
            initialState: SettingsDomain.State(isDemoMode: true,
                                               showLegalNoticeView: false,
                                               showDataProtectionView: false,
                                               showTermsOfUseView: false,
                                               appSecurityState: AppSecurityDomain
                                                   .State(
                                                       availableSecurityOptions: [
                                                           .password,
                                                           .biometry(.faceID),
                                                       ],
                                                       selectedSecurityOption: nil
                                                   ),
                                               appVersion: appVersion),
            reducer: SettingsDomain.Reducer.empty,
            environment: SettingsDomain.Dummies.environment
        ),
        debugStore: debugStore)
            .frame(width: 320, height: 2000)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testSettingsView_ComplyTrackingView() {
        let sut = SettingsView.TrackingComplyView(store: SettingsDomain.Store(
            initialState: SettingsDomain.State(
                isDemoMode: false,
                appSecurityState: AppSecurityDomain.State(availableSecurityOptions: [.password]),
                showTrackerComplyView: true
            ),
            reducer: SettingsDomain.Reducer.empty,
            environment: SettingsDomain.Dummies.environment
        ))
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
    }

    private func configuredSettingsDomainState(
        withAvailableSecurityOptions availableSecurityOptions: [AppSecurityOption],
        andSelectedSecurityOption selectedSecurityOption: AppSecurityOption?
    ) -> SettingsDomain.State {
        let profiles = [
            UserProfile(
                from: Profile(name: "Super duper long name so that I get nervous", color: Profile.Color.blue),
                isAuthenticated: true
            ),
            UserProfile(from: Profile(name: "Anna Vetter", color: Profile.Color.yellow), isAuthenticated: false),
        ]
        return SettingsDomain.State(isDemoMode: false,
                                    showLegalNoticeView: false,
                                    showDataProtectionView: false,
                                    showTermsOfUseView: false,
                                    appSecurityState: AppSecurityDomain
                                        .State(
                                            availableSecurityOptions: availableSecurityOptions,
                                            selectedSecurityOption: selectedSecurityOption
                                        ),
                                    profiles: ProfilesDomain.State(
                                        profiles: profiles,
                                        selectedProfileId: profiles.first!.id
                                    ),
                                    appVersion: appVersion)
    }
}
