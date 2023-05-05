//
//  Copyright (c) 2023 gematik GmbH
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
import ComposableArchitecture
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

    let debugStore = DebugDomain.Store(
        initialState: DebugDomain.State(trackingOptIn: true),
        reducer: DebugDomain()
    )

    let appVersion = AppVersion(productVersion: "1.0", buildNumber: "LOCAL BUILD", buildHash: "LOCAL BUILD")

    func testSettingsFigmaVariant1() {
        let profiles = [
            UserProfile(
                from: Profile(
                    name: "Dennis Weihnachtsgans",
                    color: Profile.Color.blue,
                    image: .doctor
                ),
                isAuthenticated: true
            ),
            UserProfile(
                from: Profile(
                    name: "Merry Martin",
                    color: Profile.Color.green,
                    image: .baby
                ),
                isAuthenticated: false
            ),
            UserProfile(
                from: Profile(
                    name: "Schneebartz van Eltz",
                    color: Profile.Color.red,
                    image: .boyWithCard,
                    lastAuthenticated: Date().addingTimeInterval(-60 * 60 * 24 * 32)
                ),
                isAuthenticated: false
            ),
        ]

        let sut = SettingsView(store: SettingsDomain.Store(
            initialState: configuredSettingsDomainState(
                profiles: profiles,
                withAvailableSecurityOptions: [.biometry(.faceID), .password],
                andSelectedSecurityOption: .biometry(.faceID),
                appVersion: AppVersion(productVersion: "1.0.1", buildNumber: "12", buildHash: "3130b2e"),
                trackerOptIn: true
            ),
            reducer: EmptyReducer()
        ))
            .frame(width: 375, height: 2589, alignment: .center)

        assertSnapshots(matching: sut, as: figmaReference())
    }

    func testSettingsFigmaVariant2() {
        let profiles = [
            UserProfile(
                from: Profile(
                    name: "Schneebartz van Eltz",
                    color: Profile.Color.blue
                ),
                isAuthenticated: false
            ),
        ]

        let sut = SettingsView(store: SettingsDomain.Store(
            initialState: configuredSettingsDomainState(
                profiles: profiles,
                isDemoMode: true,
                withAvailableSecurityOptions: [.biometry(.faceID), .password],
                andSelectedSecurityOption: .biometry(.faceID),
                appVersion: AppVersion(productVersion: "1.0.1", buildNumber: "12", buildHash: "3130b2e"),
                trackerOptIn: true
            ),
            reducer: EmptyReducer()
        ))
            .frame(width: 375, height: 2589, alignment: .center)

        assertSnapshots(matching: sut, as: figmaReference())
    }

    func testSettingsView_App_Security_Biometry_Available_No_Selection() {
        let sut = SettingsView(store: SettingsDomain.Store(
            initialState: configuredSettingsDomainState(
                withAvailableSecurityOptions: [.biometry(.faceID)],
                andSelectedSecurityOption: nil
            ),
            reducer: EmptyReducer()
        ))
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
            reducer: EmptyReducer()
        ))
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
            reducer: EmptyReducer()
        ))
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
            reducer: EmptyReducer()
        ))
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
            reducer: EmptyReducer()
        ))
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testSettingsView_DemoMode_Disabled() {
        let sut = SettingsView(store: SettingsDomain.Store(
            initialState: configuredSettingsDomainState(
                withAvailableSecurityOptions: [.biometry(.faceID), .password],
                andSelectedSecurityOption: nil
            ),
            reducer: EmptyReducer()
        ))
            .frame(width: 320, height: 2000)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testSettingsView_DemoMode_Enabled() {
        let sut = SettingsView(store: SettingsDomain.Store(
            initialState: SettingsDomain.State(isDemoMode: true,
                                               appSecurityState: AppSecurityDomain
                                                   .State(
                                                       availableSecurityOptions: [
                                                           .biometry(.faceID),
                                                           .password,
                                                       ],
                                                       selectedSecurityOption: nil
                                                   ),
                                               appVersion: appVersion),
            reducer: EmptyReducer()
        ))
            .frame(width: 320, height: 2000)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testSettingsView_ComplyTrackingView() {
        let sut = SettingsView.TrackingComplyView(store: SettingsDomain.Store(
            initialState: SettingsDomain.State(
                isDemoMode: false,
                appSecurityState: AppSecurityDomain.State(availableSecurityOptions: [.password]),
                destination: .complyTracking
            ),
            reducer: EmptyReducer()
        ))
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
    }

    private func configuredSettingsDomainState(
        // swiftlint:disable:next discouraged_optional_collection
        profiles: [UserProfile]? = nil,
        isDemoMode: Bool = false,
        withAvailableSecurityOptions availableSecurityOptions: [AppSecurityOption],
        andSelectedSecurityOption selectedSecurityOption: AppSecurityOption?,
        appVersion: AppVersion? = nil,
        trackerOptIn: Bool = false
    ) -> SettingsDomain.State {
        let profiles = profiles ?? [
            UserProfile(
                from: Profile(name: "Super duper long name so that I get nervous", color: Profile.Color.blue),
                isAuthenticated: true
            ),
            UserProfile(from: Profile(name: "Anna Vetter", color: Profile.Color.yellow), isAuthenticated: false),
        ]

        return SettingsDomain.State(isDemoMode: isDemoMode,
                                    appSecurityState: AppSecurityDomain
                                        .State(
                                            availableSecurityOptions: availableSecurityOptions,
                                            selectedSecurityOption: selectedSecurityOption
                                        ),
                                    profiles: ProfilesDomain.State(
                                        profiles: profiles,
                                        selectedProfileId: profiles.first!.id
                                    ),
                                    appVersion: appVersion ?? self.appVersion,
                                    trackerOptIn: trackerOptIn)
    }
}
