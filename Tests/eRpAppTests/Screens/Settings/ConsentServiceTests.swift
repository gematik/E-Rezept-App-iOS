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

import Combine
import ConsentService
import Dependencies
@testable import eRpFeatures
import eRpKit
import ErxTaskRepository
import FeatureHelpers
import Nimble
import XCTest

@MainActor
final class ConsentServiceTests: XCTestCase {
    let testScheduler = DispatchQueue.test
    var schedulers: Schedulers!
    var mockUserSessionProvider: UserSessionProviderMock!
    var mockUserSession: MockUserSession!
    var mockLoginHandler: LoginHandlerMock!

    override func invokeTest() {
        mockUserSessionProvider = UserSessionProviderMock()

        withDependencies { dependencies in
            dependencies.userSessionProvider = mockUserSessionProvider
        } operation: {
            super.invokeTest()
        }
    }

    override func setUp() {
        super.setUp()

        schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        mockUserSession = MockUserSession()
        mockLoginHandler = LoginHandlerMock()

        mockUserSession.idpSessionLoginHandler = mockLoginHandler
        mockUserSessionProvider.userSessionForUuidUUIDUserSessionReturnValue = mockUserSession
    }

    func testGrantConsent_happyPath() async throws {
        // given
        let sut = ConsentService.defaultValue

        mockLoginHandler.isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverReturnValue = Just(.success(true))
            .eraseToAnyPublisher()
        mockUserSession.profileReturnValue = Just(Self.Fixtures.profileForChargeItemsConsentService)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()

        try await withDependencies { dependencies in
            dependencies.erxTaskRepository.grantConsent = { _, _ in
                Self.Fixtures.validChargeItemsServiceConsent
            }
        } operation: {
            // when
            let result = try await sut.grantConsent(.chargcons, Self.testProfileId)

            // then
            expect(result) == ConsentService.GrantResult.success
            expect(self.mockLoginHandler.isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverCalled) == true
            expect(self.mockLoginHandler.isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverCallsCount) == 1
        }
    }

    func testGrantConsent_unexpectedResponse() async {
        // given
        let sut = ConsentService.defaultValue

        mockLoginHandler.isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverReturnValue = Just(.success(true))
            .eraseToAnyPublisher()
        mockUserSession.profileReturnValue = Just(Self.Fixtures.profileForChargeItemsConsentService)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()

        await withDependencies { dependencies in
            dependencies.erxTaskRepository.grantConsent = { _, _ in nil }
        } operation: {
            // when
            var runSuccess = false
            do {
                _ = try await sut.grantConsent(.chargcons, Self.testProfileId)
            } catch {
                guard let error = error as? ConsentService.Error
                else {
                    Nimble.fail("Unexpected error")
                    return
                }
                expect(error) == .unexpectedGrantConsentResponse
                runSuccess = true
            }

            // then
            expect(runSuccess) == true
            expect(self.mockLoginHandler.isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverCalled) == true
            expect(self.mockLoginHandler.isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverCallsCount) == 1
        }
    }

    func testRevokeConsent_happyPath() async throws {
        // given
        let sut = ConsentService.defaultValue

        mockLoginHandler.isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverReturnValue = Just(.success(true))
            .eraseToAnyPublisher()
        mockUserSession.profileReturnValue = Just(Self.Fixtures.profileForChargeItemsConsentService)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()

        try await withDependencies { dependencies in
            dependencies.erxTaskRepository.revokeConsent = { _, _ in }
        } operation: {
            // when
            let result = try await sut.revokeConsent(.chargcons, Self.testProfileId)

            // then
            expect(result) == ConsentService.RevokeResult.success
            expect(self.mockLoginHandler.isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverCalled) == true
            expect(self.mockLoginHandler.isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverCallsCount) == 1
        }
    }

    func testRevokeConsent_unexpectedResponse() async {
        // given
        let sut = ConsentService.defaultValue

        mockLoginHandler.isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverReturnValue = Just(.success(true))
            .eraseToAnyPublisher()
        mockUserSession.profileReturnValue = Just(Self.Fixtures.profileForChargeItemsConsentService)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()

        await withDependencies { dependencies in
            dependencies.erxTaskRepository.revokeConsent = { _, _ in
                throw ConsentService.Error.unexpectedRevokeConsentResponse
            }
        } operation: {
            // when
            var runSuccess = false
            do {
                _ = try await sut.revokeConsent(.chargcons, Self.testProfileId)
            } catch {
                expect { throw error }.to(throwError(ConsentService.Error.unexpectedRevokeConsentResponse))
                runSuccess = true
            }

            // then
            expect(runSuccess) == true
            expect(self.mockLoginHandler.isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverCalled) == true
            expect(self.mockLoginHandler.isAuthenticatedAnyPublisherResultBoolLoginHandlerErrorNeverCallsCount) == 1
        }
    }
}

extension ConsentServiceTests {
    static let testProfileId = UUID()
    enum Fixtures {
        @MainActor
        static let profileForChargeItemsConsentService: Profile = .init(
            name: "Gerrry with three \"r\"",
            identifier: ConsentServiceTests.testProfileId,
            created: Date(),
            insuranceId: "X114428530",
            color: .green,
            image: .pharmacist,
            lastAuthenticated: nil,
            erxTasks: []
        )

        static let validChargeItemsServiceConsent: ErxConsent = {
            let kvnr = "X114428530"
            return ErxConsent(
                identifier: "\(ErxConsent.Category.chargcons.rawValue)-\(kvnr)",
                insuranceId: kvnr,
                timestamp: FHIRDateFormatter.shared.string(from: Date(), format: .yearMonthDay),
                scope: .patientPrivacy,
                category: .chargcons,
                policyRule: .optIn
            )
        }()
    }
}
