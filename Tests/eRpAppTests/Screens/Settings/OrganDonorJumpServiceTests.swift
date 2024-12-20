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
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import Nimble
import XCTest

@MainActor
final class OrganDonorJumpServiceTests: XCTestCase {
    @MainActor
    func testLoggedInJump() async throws {
        let sut = OrganDonorJumpService.liveValue

        let userDataStore = MockUserDataStore()
        userDataStore.serverEnvironmentName = "RU"
        let userSession = MockUserSession()
        let profile = Profile(name: "Bob", gIdEntry: .init(name: "Alice", identifier: "ABC123"))
        userSession.profileReturnValue = Just(profile).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()

        let resourceHandler = MockResourceHandler()
        resourceHandler.canOpenURLReturnValue = true

        let expected = "iss=ABC123"

        try await withDependencies { dependencies in
            dependencies.userDataStore = userDataStore
            dependencies.userSession = userSession
            dependencies.resourceHandler = resourceHandler
        } operation: {
            try await sut.jump()

            expect(resourceHandler.canOpenURLCallsCount).to(equal(1))
            expect(resourceHandler.canOpenURLReceivedUrl?.absoluteString).to(contain(expected))
        }
    }

    @MainActor
    func testLoggedOutJump() async throws {
        let sut = OrganDonorJumpService.liveValue

        let userDataStore = MockUserDataStore()
        userDataStore.serverEnvironmentName = "RU"
        let userSession = MockUserSession()
        let profile = Profile(name: "Bob", gIdEntry: nil)
        userSession.profileReturnValue = Just(profile).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()

        let resourceHandler = MockResourceHandler()
        resourceHandler.canOpenURLReturnValue = true

        let expected = URL(string: "https://www.organspende-info.de/")!

        try await withDependencies { dependencies in
            dependencies.userDataStore = userDataStore
            dependencies.userSession = userSession
            dependencies.resourceHandler = resourceHandler
        } operation: {
            try await sut.jump()

            expect(resourceHandler.canOpenURLCallsCount).to(equal(1))
            expect(resourceHandler.canOpenURLReceivedUrl).to(equal(expected))
        }
    }
}
