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
import FeatureCardWall
import FeatureHelpers
import IDP
import Nimble
import XCTest

final class ChargeItemListDomainServiceTests: XCTestCase {
    let testScheduler = DispatchQueue.test
    var schedulers: Schedulers!
    var mockUserSessionProvider: MockUserSessionProvider!
    var mockUserSession: MockUserSession!
    var mockLoginHandler: MockLoginHandler!

    let testProfileId = UUID()

    override func setUp() {
        super.setUp()

        schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        mockUserSessionProvider = MockUserSessionProvider()
        mockUserSession = MockUserSession()
        mockLoginHandler = MockLoginHandler()

        mockUserSession.idpSessionLoginHandler = mockLoginHandler
        mockUserSessionProvider.userSessionForReturnValue = mockUserSession
    }

    func testFetchLocalChargeItems_withSuccess() {
        // given
        var consentService = ConsentService.testValue
        consentService.checkForConsent = { _, _ in .granted }
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            consentService: consentService
        )

        var runSuccess: Bool

        runSuccess = false

        withDependencies {
            $0.erxTaskRepository.loadLocalAllChargeItems = { _ in [] }
        } operation: {
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
    }

    func testFetchRemoteChargeItems_happyPath() {
        // given
        var consentService = ConsentService.testValue
        consentService.checkForConsent = { _, _ in .granted }
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            consentService: consentService
        )

        var runSuccess = false
        let returnValue: [ErxSparseChargeItem] = []

        withDependencies {
            $0.erxTaskRepository.loadRemoteChargeItems = { _ in returnValue }
        } operation: {
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
    }

    func testFetchRemoteChargeItems_notAuthenticated() {
        // given
        var consentService = ConsentService.testValue
        consentService.checkForConsent = { _, _ in .notAuthenticated }
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            consentService: consentService
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
        var consentService = ConsentService.testValue
        consentService.checkForConsent = { _, _ in .notGranted }
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            consentService: consentService
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
        let consentService = ConsentService.testValue
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            consentService: consentService
        )
        var runSuccess: Bool

        // when
        runSuccess = false
        mockUserSession.profileReturnValue = Just(Self.Fixtures.profileForChargeItemsService)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        mockLoginHandler.isAuthenticatedReturnValue = Just(LoginResult.success(true)).eraseToAnyPublisher()

        withDependencies {
            $0.erxTaskRepository.deleteChargeItems = { _, _ in }
        } operation: {
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
    }

    func testDeleteChargeItem_notAuthenticated() {
        // given
        let consentService = ConsentService.testValue
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            consentService: consentService
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
        let consentService = ConsentService.testValue
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            consentService: consentService
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
        var consentService = ConsentService.testValue
        consentService
            .grantConsent = { _, _ in throw ConsentService.Error.unexpectedGrantConsentResponse }
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            consentService: consentService
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
                        .error(.consentService(.unexpectedGrantConsentResponse))
                }
            )
        expect(runSuccess) == true
    }

    func testGrantConsent_happyPath() {
        // given
        var consentService = ConsentService.testValue
        consentService.grantConsent = { _, _ in .success }
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            consentService: consentService
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
        var consentService = ConsentService.testValue
        consentService.grantConsent = { _, _ in .conflict }
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            consentService: consentService
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
        var consentService = ConsentService.testValue
        consentService.checkForConsent = { _, _ in .notAuthenticated }
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            consentService: consentService
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

        withDependencies {
            $0.erxTaskRepository.loadRemoteChargeItems = { _ in [] }
        } operation: {
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
    }

    func testRevokeConsent_happyPath() {
        // given
        var consentService = ConsentService.testValue
        consentService.revokeConsent = { _, _ in .success }
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            consentService: consentService
        )

        var runSuccess: Bool

        // when the server returns with success
        runSuccess = false
        withDependencies { dependencies in
            dependencies.erxTaskRepository.loadLocalAllChargeItems = { _ in [] }
            dependencies.erxTaskRepository.deleteLocalChargeItems = { _, _ in }
        } operation: {
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

    func testRevokeConsent_Error() {
        // given
        var consentService = ConsentService.testValue
        consentService.revokeConsent = { _, _ in throw ConsentService.Error.unexpected }
        let sut = DefaultChargeItemListDomainService(
            userSessionProvider: mockUserSessionProvider,
            consentService: consentService
        )

        var runSuccess: Bool

        // when the service returns an error
        runSuccess = false

        // then
        sut.revokeChargeItemsConsent(for: testProfileId)
            .test(
                expectations: { result in
                    runSuccess = true
                    expect(result) == ChargeItemListDomainServiceRevokeResult
                        .error(.consentService(.unexpected))
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
