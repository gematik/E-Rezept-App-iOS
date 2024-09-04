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

import CombineSchedulers
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
@testable import eRpLocalStorage
import SnapshotTesting
import SwiftUI
import XCTest

final class SettingsViewSnapshotTests: ERPSnapshotTestCase {
    let debugStore = StoreOf<DebugDomain>(
        initialState: DebugDomain.State(trackingOptIn: true)
    ) {
        DebugDomain()
    }

    let appVersion = AppVersion(productVersion: "1.0", buildNumber: "LOCAL BUILD", buildHash: "LOCAL BUILD")

    func testSettingsFigmaVariant1() {
        let profiles = [
            UserProfile(
                from: Profile(
                    name: "Dennis Weihnachtsgans",
                    color: Profile.Color.blue,
                    image: .doctorFemale
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

        let sut = SettingsView(store: StoreOf<SettingsDomain>(
            initialState: configuredSettingsDomainState(
                profiles: profiles,
                withAvailableSecurityOptions: [.biometry(.faceID), .password],
                andSelectedSecurityOption: .biometry(.faceID),
                appVersion: AppVersion(productVersion: "1.0.1", buildNumber: "12", buildHash: "3130b2e"),
                trackerOptIn: true
            )

        ) {
            EmptyReducer()
        })
            .frame(width: 375, height: 2589, alignment: .top)

        assertSnapshots(of: sut, as: figmaReference())
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

        let sut = SettingsView(store: StoreOf<SettingsDomain>(
            initialState: configuredSettingsDomainState(
                profiles: profiles,
                isDemoMode: true,
                withAvailableSecurityOptions: [.biometry(.faceID), .password],
                andSelectedSecurityOption: .biometry(.faceID),
                appVersion: AppVersion(productVersion: "1.0.1", buildNumber: "12", buildHash: "3130b2e"),
                trackerOptIn: true
            )

        ) {
            EmptyReducer()
        })
            .frame(width: 375, height: 2589, alignment: .top)

        assertSnapshots(of: sut, as: figmaReference())
    }

    func testSettingsView_DemoMode_Disabled() {
        let sut = SettingsView(store: StoreOf<SettingsDomain>(
            initialState: configuredSettingsDomainState(
                withAvailableSecurityOptions: [.biometry(.faceID), .password],
                andSelectedSecurityOption: nil
            )

        ) {
            EmptyReducer()
        })
            .frame(width: 320, height: 2000)

        assertSnapshots(of: sut, as: snapshotModi())
    }

    func testSettingsView_DemoMode_Enabled() {
        let sut = SettingsView(store: StoreOf<SettingsDomain>(
            initialState: SettingsDomain.State(isDemoMode: true,
                                               appVersion: appVersion)

        ) {
            EmptyReducer()
        })
            .frame(width: 320, height: 2000)

        assertSnapshots(of: sut, as: snapshotModi())
    }

    func testSettingsView_ComplyTrackingView() {
        let sut = SettingsView.TrackingComplyView(store: StoreOf<SettingsDomain>(
            initialState: SettingsDomain.State(
                isDemoMode: false,
                destination: .complyTracking(.init())
            )

        ) {
            EmptyReducer()
        })
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
    }

    private func configuredSettingsDomainState(
        // swiftlint:disable:next discouraged_optional_collection
        profiles: [UserProfile]? = nil,
        isDemoMode: Bool = false,
        withAvailableSecurityOptions _: [AppSecurityOption],
        andSelectedSecurityOption _: AppSecurityOption?,
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
                                    profiles: ProfilesDomain.State(
                                        profiles: profiles,
                                        selectedProfileId: profiles.first!.id
                                    ),
                                    appVersion: appVersion ?? self.appVersion,
                                    trackerOptIn: trackerOptIn)
    }
}
