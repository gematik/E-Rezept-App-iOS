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
@testable import eRpApp
import eRpKit
import IDP
import Nimble
import XCTest

final class ChargeItemListDomainServiceTests: XCTestCase {
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

    func testFetchLocalChargeItems_withSuccess() {
        // given
        var chargeItemConsentService = ChargeItemConsentService.testValue
        chargeItemConsentService.checkForConsent = { _ in .granted }
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            chargeItemConsentService: chargeItemConsentService
        )

        var runSuccess: Bool

        runSuccess = false
        mockErxTaskRepository.loadLocalAllChargeItemsPublisher = Just([])
            .setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()

        // when
        sut.fetchLocalChargeItems(for: testProfileId)
            // then
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemDomainServiceFetchResult.success([])
                }
            )
        expect(runSuccess) == true
    }

    func testFetchRemoteChargeItems_happyPath() {
        // given
        var chargeItemConsentService = ChargeItemConsentService.testValue
        chargeItemConsentService.checkForConsent = { _ in .granted }
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            chargeItemConsentService: chargeItemConsentService
        )

        var runSuccess = false
        let returnValue: [ErxSparseChargeItem] = []
        mockErxTaskRepository.loadRemoteAndSaveChargeItemsPublisher = Just(returnValue)
            .setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()

        // when
        sut.fetchRemoteChargeItemsAndSave(for: testProfileId)
            // then
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemDomainServiceFetchResult.success(returnValue)
                }
            )
        expect(runSuccess) == true
    }

    func testFetchRemoteChargeItems_notAuthenticated() {
        // given
        var chargeItemConsentService = ChargeItemConsentService.testValue
        chargeItemConsentService.checkForConsent = { _ in .notAuthenticated }
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            chargeItemConsentService: chargeItemConsentService
        )

        var runSuccess = false

        // when
        sut.fetchRemoteChargeItemsAndSave(for: testProfileId)
            // then
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemDomainServiceFetchResult.notAuthenticated
                }
            )
        expect(runSuccess) == true
    }

    func testFetchRemoteChargeItems_noValidConsentGiven() {
        // given
        var chargeItemConsentService = ChargeItemConsentService.testValue
        chargeItemConsentService.checkForConsent = { _ in .notGranted }
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            chargeItemConsentService: chargeItemConsentService
        )

        var runSuccess = false

        // then
        sut.fetchRemoteChargeItemsAndSave(for: testProfileId)
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemDomainServiceFetchResult.consentNotGranted
                }
            )
        expect(runSuccess) == true
    }

    func testDeleteChargeItem() {
        // given
        let chargeItemConsentService = ChargeItemConsentService.testValue
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            chargeItemConsentService: chargeItemConsentService
        )
        var runSuccess: Bool

        // when
        runSuccess = false
        mockUserSession.profileReturnValue = Just(Self.Fixtures.profileForChargeItemsService)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        mockLoginHandler.isAuthenticatedReturnValue = Just(LoginResult.success(true)).eraseToAnyPublisher()
        mockErxTaskRepository.deleteChargeItemsPublisher = Just(true)
            .setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()

        // then
        sut.delete(
            chargeItem: ErxChargeItem.Fixtures.chargeItem,
            for: testProfileId
        )
        .test(
            expectations: { result in
                runSuccess = true
                expect(result) == ChargeItemDomainServiceDeleteResult.success
            }
        )
        expect(runSuccess) == true
    }

    func testDeleteChargeItem_notAuthenticated() {
        // given
        let chargeItemConsentService = ChargeItemConsentService.testValue
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            chargeItemConsentService: chargeItemConsentService
        )
        var runSuccess: Bool

        // when
        runSuccess = false
        mockLoginHandler.isAuthenticatedReturnValue = Just(LoginResult.success(false)).eraseToAnyPublisher()

        // then
        sut.delete(
            chargeItem: ErxChargeItem.Fixtures.chargeItem,
            for: testProfileId
        )
        .test(
            expectations: { result in
                runSuccess = true
                expect(result) == ChargeItemDomainServiceDeleteResult.notAuthenticated
            }
        )
        expect(runSuccess) == true
    }

    func testAuthenticate() {
        // given
        let chargeItemConsentService = ChargeItemConsentService.testValue
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            chargeItemConsentService: chargeItemConsentService
        )
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

    func testGrantConsent_unexpectedResponse() {
        // given
        var chargeItemConsentService = ChargeItemConsentService.testValue
        chargeItemConsentService
            .grantConsent = { _ in throw ChargeItemConsentService.Error.unexpectedGrantConsentResponse }
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            chargeItemConsentService: chargeItemConsentService
        )

        var runSuccess: Bool

        // when no consent was returned from server
        runSuccess = false

        // then
        sut.grantChargeItemsConsent(for: testProfileId)
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemListDomainServiceGrantResult
                        .error(.chargeItemConsentService(.unexpectedGrantConsentResponse))
                }
            )
        expect(runSuccess) == true
    }

    func testGrantConsent_happyPath() {
        // given
        var chargeItemConsentService = ChargeItemConsentService.testValue
        chargeItemConsentService.grantConsent = { _ in .success }
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            chargeItemConsentService: chargeItemConsentService
        )

        var runSuccess = false

        // when
        sut.grantChargeItemsConsent(for: testProfileId)
            // then
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemListDomainServiceGrantResult.success
                }
            )
        expect(runSuccess) == true
    }

    func testGrantConsent_conflictConsentAlreadyGranted() {
        // given
        var chargeItemConsentService = ChargeItemConsentService.testValue
        chargeItemConsentService.grantConsent = { _ in .conflict }
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            chargeItemConsentService: chargeItemConsentService
        )

        var runSuccess = false

        // when
        sut.grantChargeItemsConsent(for: testProfileId)
            // then
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemListDomainServiceGrantResult.conflict
                }
            )
        expect(runSuccess) == true
    }

    func testFetchRemoteChargeItemsAssumingConsentGranted() {
        // given
        var chargeItemConsentService = ChargeItemConsentService.testValue
        chargeItemConsentService.checkForConsent = { _ in .notAuthenticated }
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            chargeItemConsentService: chargeItemConsentService
        )
        var runSuccess: Bool

        // when not authenticated
        runSuccess = false

        // then
        sut.fetchRemoteChargeItemsAndSave(for: testProfileId)
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemDomainServiceFetchResult.notAuthenticated
                }
            )
        expect(runSuccess) == true

        // when authenticated
        runSuccess = false
        mockLoginHandler.isAuthenticatedReturnValue = Just(LoginResult.success(true)).eraseToAnyPublisher()
        mockErxTaskRepository.loadLocalAllChargeItemsPublisher = Just([])
            .setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()

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
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            chargeItemConsentService: ChargeItemConsentService.testValue
        )
        var runSuccess: Bool

        // when the service returns an error
        runSuccess = false
        mockUserSession.profileReturnValue = Just(Self.Fixtures.profileForChargeItemsService)
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
                    expect(result) == ChargeItemListDomainServiceRevokeResult
                        .error(.erxRepository(erxTaskRepositoryError))
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
                    expect(result) == ChargeItemListDomainServiceRevokeResult.success(.success)
                }
            )
        expect(runSuccess) == true
    }
}

extension ChargeItemListDomainServiceTests {
    enum Fixtures {
        static let profileForChargeItemsService: Profile = .init(
            name: "Gerrry with three \"r\"",
            identifier: UUID(),
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

        static let chargeItem = ErxSparseChargeItem(
            identifier: UUID().uuidString,
            taskId: "task id",
            fhirData: "testdata".data(using: .utf8)!,
            enteredDate: "2022-09-14"
        )
    }
}
