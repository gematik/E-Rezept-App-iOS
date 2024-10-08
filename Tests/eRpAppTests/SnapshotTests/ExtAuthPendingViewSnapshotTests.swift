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

import Combine
import CombineSchedulers
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import IDP
import SnapshotTesting
import SwiftUI
import XCTest

final class ExtAuthPendingViewSnapshotTests: ERPSnapshotTestCase {
    let networkScheduler = DispatchQueue.immediate
    let uiScheduler = DispatchQueue.immediate

    lazy var schedulers: Schedulers = {
        Schedulers(
            uiScheduler: uiScheduler.eraseToAnyScheduler(),
            networkScheduler: networkScheduler.eraseToAnyScheduler(),
            ioScheduler: DispatchQueue.test.eraseToAnyScheduler(),
            computeScheduler: DispatchQueue.test.eraseToAnyScheduler()
        )
    }()

    func testExtAuthPendingView_WithSuccess() {
        let mockUserSession = MockUserSession()
        mockUserSession.profileReturnValue = Just(Profile(name: ""))
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        mockUserSession.mockUserDataStore.underlyingSelectedProfileId = Just(UUID()).eraseToAnyPublisher()
        mockUserSession.mockProfileDataStore.listAllProfilesReturnValue =
            Just([])
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        let store = ExtAuthPendingDomain.Store(
            initialState: .init(
                extAuthState: .extAuthSuccessful(KKAppDirectory
                    .Entry(name: "Gematik KK", identifier: "abc"))
            )

        ) {
            EmptyReducer()
        }

        let sut = ExtAuthPendingView(store: store)

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testExtAuthPendingView_WithPending() {
        let mockUserSession = MockUserSession()
        mockUserSession.profileReturnValue = Just(Profile(name: ""))
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        mockUserSession.mockUserDataStore.underlyingSelectedProfileId = Just(UUID()).eraseToAnyPublisher()
        mockUserSession.mockProfileDataStore.listAllProfilesReturnValue =
            Just([])
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        let store = ExtAuthPendingDomain.Store(
            initialState: .init(
                extAuthState: .pendingExtAuth(KKAppDirectory
                    .Entry(name: "Gematik KK", identifier: "abc"))
            )

        ) {
            EmptyReducer()
        }

        let sut = ExtAuthPendingView(store: store)

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
