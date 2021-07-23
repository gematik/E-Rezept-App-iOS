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

import CombineSchedulers
@testable import eRpApp
@testable import eRpLocalStorage
import SnapshotTesting
import SwiftUI
import XCTest

final class SettingsViewSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()

        diffTool = "open"
    }

    func testSettingsView_App_Security_Biometry_Available_No_Selection() {
        let sut = SettingsView(store: SettingsDomain.Store(
            initialState: configuredSettingsDomainState(
                withAvailableSecurityOptions: [.biometry(.faceID), .unsecured],
                andSelectedSecurityOption: nil
            ),
            reducer: SettingsDomain.Reducer.empty,
            environment: SettingsDomain.Dummies.environment
        ))
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testSettingsView_App_Security_Biometry_Available_And_Selected() {
        let sut = SettingsView(store: SettingsDomain.Store(
            initialState: configuredSettingsDomainState(
                withAvailableSecurityOptions: [.biometry(.faceID), .unsecured],
                andSelectedSecurityOption: .biometry(.faceID)
            ),
            reducer: SettingsDomain.Reducer.empty,
            environment: SettingsDomain.Dummies.environment
        ))
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testSettingsView_App_Security_Biometry_Available_Unsecured_Selected() {
        let sut = SettingsView(store: SettingsDomain.Store(
            initialState: configuredSettingsDomainState(
                withAvailableSecurityOptions: [.biometry(.faceID), .unsecured],
                andSelectedSecurityOption: .unsecured
            ),
            reducer: SettingsDomain.Reducer.empty,
            environment: SettingsDomain.Dummies.environment
        ))
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testSettingsView_App_Security_Biometry_Unavailable_No_Selection() {
        let sut = SettingsView(store: SettingsDomain.Store(
            initialState: configuredSettingsDomainState(
                withAvailableSecurityOptions: [.unsecured],
                andSelectedSecurityOption: nil
            ),
            reducer: SettingsDomain.Reducer.empty,
            environment: SettingsDomain.Dummies.environment
        ))
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testSettingsView_App_Security_Biometry_Unvailable_Unsecured_Selected() {
        let sut = SettingsView(store: SettingsDomain.Store(
            initialState: configuredSettingsDomainState(
                withAvailableSecurityOptions: [.unsecured],
                andSelectedSecurityOption: .unsecured
            ),
            reducer: SettingsDomain.Reducer.empty,
            environment: SettingsDomain.Dummies.environment
        ))
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testSettingsView_DemoMode_Disabled() {
        let sut = SettingsView(store: SettingsDomain.Store(
            initialState: configuredSettingsDomainState(
                withAvailableSecurityOptions: [.unsecured],
                andSelectedSecurityOption: nil
            ),
            reducer: SettingsDomain.Reducer.empty,
            environment: SettingsDomain.Dummies.environment
        ))
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
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
                                                       availableSecurityOptions: [.unsecured],
                                                       selectedSecurityOption: nil
                                                   ),
                                               appVersion: appVersion,
                                               debug: DebugDomain.State(trackingOptOut: true)),
            reducer: SettingsDomain.Reducer.empty,
            environment: SettingsDomain.Dummies.environment
        ))
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testSettingsView_ComplyTrackingView() {
        let sut = SettingsView.TrackingComplyView(store: SettingsDomain.Store(
            initialState: SettingsDomain.State(
                isDemoMode: false,
                showTrackerComplyView: true,
                debug: DebugDomain.State(trackingOptOut: true)
            ),
            reducer: SettingsDomain.Reducer.empty,
            environment: SettingsDomain.Dummies.environment
        ))
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
    }

    private func configuredSettingsDomainState(withAvailableSecurityOptions availableSecurityOptions: [AppSecurityDomain
                                                   .AppSecurityOption],
                                               andSelectedSecurityOption selectedSecurityOption: AppSecurityDomain
        .AppSecurityOption?) -> SettingsDomain.State {
        SettingsDomain.State(isDemoMode: false,
                             showLegalNoticeView: false,
                             showDataProtectionView: false,
                             showTermsOfUseView: false,
                             appSecurityState: AppSecurityDomain
                                 .State(
                                     availableSecurityOptions: availableSecurityOptions,
                                     selectedSecurityOption: selectedSecurityOption
                                 ),
                             appVersion: appVersion,
                             debug: DebugDomain.State(trackingOptOut: true))
    }
}
