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
import Dependencies
@testable import eRpFeatures
import eRpKit
import Nimble
import XCTest

@MainActor
final class ChargeItemConsentServiceTests: XCTestCase {
    let testScheduler = DispatchQueue.test
    var schedulers: Schedulers!
    var mockUserSessionProvider: MockUserSessionProvider!
    var mockUserSession: MockUserSession!
    var mockLoginHandler: MockLoginHandler!
    var mockErxTaskRepository: MockErxTaskRepository!

    override func setUp() {
        super.setUp()

        schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        mockUserSessionProvider = MockUserSessionProvider()
        mockUserSession = MockUserSession()
        mockLoginHandler = MockLoginHandler()
        mockErxTaskRepository = MockErxTaskRepository()

        mockUserSession.idpSessionLoginHandler = mockLoginHandler
        mockUserSession.erxTaskRepository = mockErxTaskRepository
        mockUserSessionProvider.userSessionForReturnValue = mockUserSession
    }

    func testGrantConsent_happyPath() async throws {
        // given
        let sut = ChargeItemConsentService(userSessionProvider: mockUserSessionProvider)

        mockLoginHandler.isAuthenticatedReturnValue = Just(.success(true)).eraseToAnyPublisher()
        mockUserSession.profileReturnValue = Just(Self.Fixtures.profileForChargeItemsConsentService)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        mockErxTaskRepository.grantConsentReturnValue = Just(Self.Fixtures.validChargeItemsServiceConsent)
            .setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()

        // when
        let result = try await sut.grantConsent(Self.testProfileId)

        // then
        expect(result) == ChargeItemConsentService.GrantResult.success
        expect(self.mockLoginHandler.isAuthenticatedCalled) == true
        expect(self.mockLoginHandler.isAuthenticatedCallsCount) == 1
        expect(self.mockErxTaskRepository.grantConsentCalled) == true
        expect(self.mockErxTaskRepository.grantConsentCallsCount) == 1
    }

    func testGrantConsent_unexpectedResponse() async {
        // given
        let sut = ChargeItemConsentService(userSessionProvider: mockUserSessionProvider)

        mockLoginHandler.isAuthenticatedReturnValue = Just(.success(true)).eraseToAnyPublisher()
        mockUserSession.profileReturnValue = Just(Self.Fixtures.profileForChargeItemsConsentService)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        mockErxTaskRepository.grantConsentReturnValue = Just(nil)
            .setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()

        // when
        var runSuccess = false
        do {
            _ = try await sut.grantConsent(Self.testProfileId)
        } catch {
            guard let error = error as? ChargeItemConsentService.Error
            else {
                Nimble.fail("Unexpected error")
                return
            }
            expect(error) == .unexpectedGrantConsentResponse
            runSuccess = true
        }

        // then
        expect(runSuccess) == true
        expect(self.mockLoginHandler.isAuthenticatedCalled) == true
        expect(self.mockLoginHandler.isAuthenticatedCallsCount) == 1
        expect(self.mockErxTaskRepository.grantConsentCalled) == true
        expect(self.mockErxTaskRepository.grantConsentCallsCount) == 1
    }

    func testRevokeConsent_happyPath() async throws {
        // given
        let sut = ChargeItemConsentService(userSessionProvider: mockUserSessionProvider)

        mockLoginHandler.isAuthenticatedReturnValue = Just(.success(true)).eraseToAnyPublisher()
        mockUserSession.profileReturnValue = Just(Self.Fixtures.profileForChargeItemsConsentService)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        mockErxTaskRepository.revokeConsentReturnValue = Just(true)
            .setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()

        // when
        let result = try await sut.revokeConsent(Self.testProfileId)

        // then
        expect(result) == ChargeItemConsentService.RevokeResult.success
        expect(self.mockLoginHandler.isAuthenticatedCalled) == true
        expect(self.mockLoginHandler.isAuthenticatedCallsCount) == 1
        expect(self.mockErxTaskRepository.revokeConsentCalled) == true
        expect(self.mockErxTaskRepository.revokeConsentCallsCount) == 1
    }

    func testRevokeConsent_unexpectedResponse() async {
        // given
        let sut = ChargeItemConsentService(userSessionProvider: mockUserSessionProvider)

        mockLoginHandler.isAuthenticatedReturnValue = Just(.success(true)).eraseToAnyPublisher()
        mockUserSession.profileReturnValue = Just(Self.Fixtures.profileForChargeItemsConsentService)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        mockErxTaskRepository.revokeConsentReturnValue = Just(false)
            .setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()

        // when
        var runSuccess = false
        do {
            _ = try await sut.revokeConsent(Self.testProfileId)
        } catch {
            expect { throw error }.to(throwError(ChargeItemConsentService.Error.unexpectedRevokeConsentResponse))
            runSuccess = true
        }

        // then
        expect(runSuccess) == true
        expect(self.mockLoginHandler.isAuthenticatedCalled) == true
        expect(self.mockLoginHandler.isAuthenticatedCallsCount) == 1
        expect(self.mockErxTaskRepository.revokeConsentCalled) == true
        expect(self.mockErxTaskRepository.revokeConsentCallsCount) == 1
    }
}

extension ChargeItemConsentServiceTests {
    static let testProfileId = UUID()
    enum Fixtures {
        static let profileForChargeItemsConsentService: Profile = .init(
            name: "Gerrry with three \"r\"",
            identifier: ChargeItemConsentServiceTests.testProfileId,
            created: Date(),
            insuranceId: "X114428530",
            color: .green,
            image: .pharmacist,
            lastAuthenticated: nil,
            erxTasks: []
        )

        static let validChargeItemsServiceConsent: ErxConsent = {
            let kvnr = "X114428530"
            let chargeItemsConsent = ErxConsent(
                identifier: "\(ErxConsent.Category.chargcons.rawValue)-\(kvnr)",
                insuranceId: kvnr,
                timestamp: FHIRDateFormatter.shared.string(from: Date(), format: .yearMonthDay),
                scope: .patientPrivacy,
                category: .chargcons,
                policyRule: .optIn
            )
            return chargeItemsConsent
        }()
    }
}
