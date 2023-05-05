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

import Combine
@testable import eRpApp
import eRpKit
import IDP
import Nimble
import XCTest

final class ChargeItemsDomainServiceTests: XCTestCase {
    let testScheduler = DispatchQueue.test
    var schedulers: Schedulers!
    var mockUserSessionProvider: MockUserSessionProvider!
    var mockUserSession: MockUserSession!
    var mockLoginHandler: MockLoginHandler!
    var mockErxTaskRepository: MockErxTaskRepository!

    let testProfileId = UUID()

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

    func testFetchChargeItems_happyPath() {
        // given
        let sut = DefaultChargeItemsDomainService(userSessionProvider: mockUserSessionProvider)
        var runSuccess: Bool

        // when
        runSuccess = false
        mockUserSession.profileReturnValue = Just(.Fixtures.profileForChargeItemsService)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        mockLoginHandler.isAuthenticatedReturnValue = Just(LoginResult.success(true)).eraseToAnyPublisher()
        mockErxTaskRepository.fetchConsentsReturnValue = Just([.Fixtures.validChargeItemsServiceConsent])
            .setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
        mockErxTaskRepository.loadRemoteChargeItemsPublisher = Just([])
            .setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()

        // then
        sut.fetchChargeItems(for: testProfileId)
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemDomainServiceFetchResult.success([])
                }
            )
        expect(runSuccess) == true
    }

    func testFetchChargeItems_notAuthenticated() {
        // given
        let sut = DefaultChargeItemsDomainService(userSessionProvider: mockUserSessionProvider)
        var runSuccess: Bool

        // when
        runSuccess = false
        mockLoginHandler.isAuthenticatedReturnValue = Just(LoginResult.success(false)).eraseToAnyPublisher()

        // then
        sut.fetchChargeItems(for: testProfileId)
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemDomainServiceFetchResult.notAuthenticated
                }
            )
        expect(runSuccess) == true
    }

    func testFetchChargeItems_noValidConsentGiven() {
        // given
        let sut = DefaultChargeItemsDomainService(userSessionProvider: mockUserSessionProvider)
        var runSuccess: Bool

        // when no consent was returned from server
        runSuccess = false
        mockUserSession.profileReturnValue = Just(.Fixtures.profileForChargeItemsService)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        mockLoginHandler.isAuthenticatedReturnValue = Just(.success(true)).eraseToAnyPublisher()
        mockErxTaskRepository.fetchConsentsReturnValue = Just([]).setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()

        // then
        sut.fetchChargeItems(for: testProfileId)
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemDomainServiceFetchResult.consentNotGranted
                }
            )
        expect(runSuccess) == true
    }

    func testAuthenticate() {
        // given
        let sut = DefaultChargeItemsDomainService(userSessionProvider: mockUserSessionProvider)
        var runSuccess: Bool

        // when authentication is possible via LoginHandler (e.g. using biometrics)
        runSuccess = false
        mockLoginHandler.isAuthenticatedOrAuthenticateReturnValue = Just(.success(true)).eraseToAnyPublisher()

        // then
        sut.authenticate(for: testProfileId)
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemDomainServiceAuthenticateResult.success
                }
            )
        expect(runSuccess) == true

        // when authentication is not possible via LoginHandler (e.g. cardWall, or other service necessary)
        runSuccess = false
        mockLoginHandler.isAuthenticatedOrAuthenticateReturnValue = Just(.success(false)).eraseToAnyPublisher()

        // then
        sut.authenticate(for: testProfileId)
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemDomainServiceAuthenticateResult.furtherAuthenticationRequired
                }
            )
        expect(runSuccess) == true

        // when already authenticated
        runSuccess = false
        mockLoginHandler.isAuthenticatedOrAuthenticateReturnValue = Just(.success(true)).eraseToAnyPublisher()

        // then
        sut.authenticate(for: testProfileId)
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemDomainServiceAuthenticateResult.success
                }
            )
        expect(runSuccess) == true
    }

    func testGrantConsent() {
        // given
        let sut = DefaultChargeItemsDomainService(userSessionProvider: mockUserSessionProvider)
        var runSuccess: Bool

        // when no consent was returned from server
        runSuccess = false
        mockUserSession.profileReturnValue = Just(.Fixtures.profileForChargeItemsService)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        mockLoginHandler.isAuthenticatedReturnValue = Just(.success(true)).eraseToAnyPublisher()
        mockErxTaskRepository.grantConsentReturnValue = Just(nil)
            .setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()

        // then
        sut.grantChargeItemsConsent(for: testProfileId)
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemsDomainServiceGrantResult.error(.unexpectedGrantConsentResponse)
                }
            )
        expect(runSuccess) == true

        // when a valid consent was returned from server
        runSuccess = false
        mockErxTaskRepository.grantConsentReturnValue = Just(.Fixtures.validChargeItemsServiceConsent)
            .setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()

        // then
        sut.grantChargeItemsConsent(for: testProfileId)
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemsDomainServiceGrantResult.success
                }
            )
        expect(runSuccess) == true
    }

    func testFetchChargeItemsAssumingConsentGranted() {
        // given
        let sut = DefaultChargeItemsDomainService(userSessionProvider: mockUserSessionProvider)
        var runSuccess: Bool

        // when not authenticated
        runSuccess = false
        mockLoginHandler.isAuthenticatedReturnValue = Just(LoginResult.success(false)).eraseToAnyPublisher()
        mockErxTaskRepository.loadRemoteChargeItemsPublisher = Just([])
            .setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()

        // then
        sut.fetchChargeItems(for: testProfileId)
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemDomainServiceFetchResult.notAuthenticated
                }
            )
        expect(runSuccess) == true

        // when
        runSuccess = false
        mockLoginHandler.isAuthenticatedReturnValue = Just(LoginResult.success(true)).eraseToAnyPublisher()

        // then
        sut.fetchChargeItemsAssumingConsentGranted(for: testProfileId)
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemDomainServiceFetchResult.success([])
                }
            )
        expect(runSuccess) == true
    }

    func testRevokeConsent() {
        // given
        let sut = DefaultChargeItemsDomainService(userSessionProvider: mockUserSessionProvider)
        var runSuccess: Bool

        // when the service returns an error
        runSuccess = false
        mockUserSession.profileReturnValue = Just(.Fixtures.profileForChargeItemsService)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        mockLoginHandler.isAuthenticatedReturnValue = Just(.success(true)).eraseToAnyPublisher()
        let erxTaskRepositoryError: ErxRepositoryError = .remote(.notImplemented)
        mockErxTaskRepository.revokeConsentReturnValue = Fail(outputType: Bool.self, failure: erxTaskRepositoryError)
            .eraseToAnyPublisher()

        // then
        sut.revokeChargeItemsConsent(for: testProfileId)
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemsDomainServiceRevokeResult.error(.erxRepository(erxTaskRepositoryError))
                }
            )
        expect(runSuccess) == true

        // when the server returns with success
        runSuccess = false
        mockErxTaskRepository.revokeConsentReturnValue = Just(true).setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()

        // then
        sut.revokeChargeItemsConsent(for: testProfileId)
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemsDomainServiceRevokeResult.success(.success)
                }
            )
        expect(runSuccess) == true
    }
}

extension ErxConsent {
    enum Fixtures {}
}

extension Profile {
    enum Fixtures {}
}

extension Profile.Fixtures {
    static let profileForChargeItemsService: Profile = .init(
        name: "Gerrry with three \"r\"",
        identifier: UUID(),
        created: Date(),
        insuranceId: "X114428530",
        color: .green,
        image: .doctor2,
        lastAuthenticated: nil,
        erxTasks: []
    )
}

extension ErxConsent.Fixtures {
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
