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
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import eRpLocalStorage
import Nimble
import OpenSSL
import Pharmacy
import XCTest

class PharmacyDetailDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.immediate
    var mockUserSession: MockUserSession!
    var mockPharmacyRepository: MockPharmacyRepository!
    var mockFeedbackReceiver: MockFeedbackReceiver!

    typealias TestStore = ComposableArchitecture.TestStore<
        PharmacyDetailDomain.State,
        PharmacyDetailDomain.Action,
        PharmacyDetailDomain.State,
        PharmacyDetailDomain.Action,
        Void
    >

    override func setUp() {
        super.setUp()
        mockUserSession = MockUserSession()
        mockPharmacyRepository = MockPharmacyRepository()
        mockFeedbackReceiver = MockFeedbackReceiver()
    }

    func testStore(for state: PharmacyDetailDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: PharmacyDetailDomain()
        ) { dependencies in
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
            dependencies.userSession = mockUserSession
            dependencies.pharmacyRepository = mockPharmacyRepository
            dependencies.feedbackReceiver = mockFeedbackReceiver
        }
    }

    lazy var allServicesPharmacy: PharmacyLocationViewModel = {
        let derCert =
            Data(
                base64Encoded: "MIIE4TCCA8mgAwIBAgIDD0vlMA0GCSqGSIb3DQEBCwUAMIGuMQswCQYDVQQGEwJERTEzMDEGA1UECgwqQXRvcyBJbmZvcm1hdGlvbiBUZWNobm9sb2d5IEdtYkggTk9ULVZBTElEMUgwRgYDVQQLDD9JbnN0aXR1dGlvbiBkZXMgR2VzdW5kaGVpdHN3ZXNlbnMtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxIDAeBgNVBAMMF0FUT1MuU01DQi1DQTMgVEVTVC1PTkxZMB4XDTE5MDkxNzEyMzYxNloXDTI0MDkxNzEyMzYxNlowXDELMAkGA1UEBhMCREUxIDAeBgNVBAoMFzEtMjExMjM0NTY3ODkgTk9ULVZBTElEMSswKQYDVQQDDCJBcnp0cHJheGlzIERyLiBBxJ9hb8SfbHUgVEVTVC1PTkxZMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmdmUeBLB6UDh4u8FAvi7B3hpAhJYXBlx+IJXLiSrhgCu/T/L5vVlCQb+1gYybWhHT5YlxafTJpOcXSfcixJbFWGxn+iQLqo+LCp/ljLBz5JoU+IXIxRKZCi5SZ9APeglGs4R0/xpPBtsJzihFXVu+B8qGm2oqmvVV91u+MoJ5asC6C+rVOecLxqy/OdmeKfaNSgH2NxVzNc19VmFUkFDGUFJjG4ZgatW4V6AuAhiPnDkEg8gfXr5L7ycQRZUNlEGMmDhh+noHU/doxSU2cgBaiTZNmu17FJLXlBLRISpWcQitcjOkjrJDt4Z0Yta64yZe13+a5dANh32Zeeg5jDQRQIDAQABo4IBVzCCAVMwHQYDVR0OBBYEFF/uDhGziRKzsUC9Nkat5xQojOUZMA4GA1UdDwEB/wQEAwIEMDAMBgNVHRMBAf8EAjAAMCAGA1UdIAQZMBcwCQYHKoIUAEwETDAKBggqghQATASBIzBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLXNtY2IuZWdrLXRlc3QtdHNwLmRlL0FUT1MuU01DQi1DQTNfVEVTVC1PTkxZLmNybDA8BggrBgEFBQcBAQQwMC4wLAYIKwYBBQUHMAGGIGh0dHA6Ly9vY3NwLXNtY2IuZWdrLXRlc3QtdHNwLmRlMB8GA1UdIwQYMBaAFD+eHl4mKtYMlaF4nqrz1drzQaf8MEUGBSskCAMDBDwwOjA4MDYwNDAyMBYMFEJldHJpZWJzc3TDpHR0ZSBBcnp0MAkGByqCFABMBDITDTEtMjExMjM0NTY3ODkwDQYJKoZIhvcNAQELBQADggEBACUnL3MxjyoEyUBRxcBAjl7FdePW0O1/UCeDAbH2b4ob9GjMGjL5OoBmhj9GsUORg/K4cIiqTot2TcPtdooKCI5a5Jupp0nYoAuzdrNlvGYEm0S/cvlyYJXjfhrEIHmlDY0/hpJX3S/hYgkniJ1Wg70MfLLcib05+31OijZmEzpChioIm4KmumEKU4ODsLWr/4OEw9KCYfuNpjiSyyAEd2pMgnGU8MKCJhrR/ZKSteAxAPKTXVtNTKndbptvcsaEZPp//vNdbBh+k8P642P2DHYfeDoUgivEYXdE5ABixtG9sk1Q2DPfTXoS+CKv45ae0vejBnRjuA28lmkmuIp+f+s=" // swiftlint:disable:this line_length
            )

        return PharmacyLocationViewModel(
            pharmacy: PharmacyLocation(
                id: "id",
                telematikID: "telematikID",
                types: [.delivery, .mobl, .outpharm],
                avsEndpoints: .init(
                    onPremiseUrl: "some",
                    shipmentUrl: "some",
                    deliveryUrl: "some",
                    certificatesURL: URL(string: "https://das-rezept.de")
                ),
                avsCertificates: [try! X509(der: derCert!)]
            )
        )
    }()

    lazy var noServicePharmacy: PharmacyLocationViewModel = {
        .init(pharmacy: PharmacyLocation(id: "id", telematikID: "telematikID", types: []))
    }()

    func testRedeemFlowWithAProfileThatHasInsuranceId() {
        // Given a pharmacy with all avs and ErxTaskRepository services
        let pharmacyModel = allServicesPharmacy
        let erxTasks = ErxTask.Fixtures.erxTasks
        let sut = testStore(for: PharmacyDetailDomain.State(
            erxTasks: erxTasks,
            pharmacyViewModel: allServicesPharmacy
        ))

        // and a profile that has been logged in before (== insuranceID non nil)
        let profile = Profile(name: "Test", insuranceId: "was logged in before")
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        // When loading the profile
        sut.send(.loadCurrentProfile)
        // Then redeem services for ErxTaskRepository can be used
        sut.receive(.response(.currentProfileReceived(profile))) {
            $0.reservationService = .erxTaskRepository
            $0.deliveryService = .erxTaskRepository
            $0.shipmentService = .erxTaskRepository
        }

        let selectedOption = RedeemOption.delivery
        let redeemState = PharmacyRedeemDomain.State(
            redeemOption: selectedOption,
            erxTasks: erxTasks,
            pharmacy: pharmacyModel.pharmacyLocation,
            selectedErxTasks: Set(erxTasks)
        )
        sut.send(.showPharmacyRedeemOption(selectedOption)) {
            $0.destination = .redeemViaErxTaskRepository(redeemState)
        }
    }

    func testRedeemFlowWithAProfileThatHasNotBeenLoggegInBefore() {
        // Given a pharmacy with all avs and ErxTaskRepository services
        let pharmacyModel = allServicesPharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            erxTasks: ErxTask.Fixtures.erxTasks,
            pharmacyViewModel: pharmacyModel
        ))
        // and a profile that has never been logged in before (== insuranceID is nil)
        let profile = Profile(name: "Test", insuranceId: nil)
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        // When loading the profile
        sut.send(.loadCurrentProfile)
        // Then only redeem services for `avs` should be available
        sut.receive(.response(.currentProfileReceived(profile))) {
            $0.reservationService = .avs
            $0.deliveryService = .avs
            $0.shipmentService = .avs
        }

        let selectedOption = RedeemOption.shipment
        sut.send(.showPharmacyRedeemOption(selectedOption)) {
            $0.destination = .redeemViaAVS(
                .init(
                    redeemOption: selectedOption,
                    erxTasks: $0.erxTasks,
                    pharmacy: pharmacyModel.pharmacyLocation,
                    selectedErxTasks: Set($0.erxTasks)
                )
            )
        }
    }

    func testRedeemFlowWithAProfileThatHasNotBeenLoggegInAndAPharmacyWithoutAVS() {
        // Given a pharmacy with only ErxTaskRepository services
        let pharmacyModel = PharmacyLocationViewModel.Dummies.pharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            erxTasks: ErxTask.Fixtures.erxTasks,
            pharmacyViewModel: pharmacyModel
        ))
        // and a profile that has never been logged in before (== insuranceID is nil)
        let profile = Profile(name: "Test", insuranceId: nil)
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        // When loading the profile
        sut.send(.loadCurrentProfile)
        // Then only redeem services for ErxTaskRepository should be available (after login)
        sut.receive(.response(.currentProfileReceived(profile))) {
            $0.reservationService = .erxTaskRepositoryAvailable
            $0.deliveryService = .erxTaskRepositoryAvailable
            $0.shipmentService = .erxTaskRepositoryAvailable
        }

        let selectedOption = RedeemOption.onPremise
        sut.send(.showPharmacyRedeemOption(selectedOption)) {
            $0.destination = .redeemViaErxTaskRepository(
                .init(
                    redeemOption: selectedOption,
                    erxTasks: $0.erxTasks,
                    pharmacy: pharmacyModel.pharmacyLocation,
                    selectedErxTasks: Set($0.erxTasks)
                )
            )
        }
    }

    func testRedeemFlowWithPharmacyWithoutServicesAndNotLoggedInBefore() {
        // Given a pharmacy without any services
        let pharmacyModel = noServicePharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            erxTasks: ErxTask.Fixtures.erxTasks,
            pharmacyViewModel: pharmacyModel
        ))
        // and a profile that has never been logged in before (== insuranceID is nil)
        let profile = Profile(name: "Test", insuranceId: nil)
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        sut.send(.loadCurrentProfile)
        // then no state change occurs (default is no service)
        sut.receive(.response(.currentProfileReceived(profile)))

        // then redeem does not present something
        sut.send(.showPharmacyRedeemOption(.onPremise))
        sut.send(.showPharmacyRedeemOption(.shipment))
        sut.send(.showPharmacyRedeemOption(.delivery))
    }

    func testRedeemFlowWithPharmacyWithoutServicesAndLoggedInBefore() {
        // Given a pharmacy without any services
        let pharmacyModel = noServicePharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            erxTasks: ErxTask.Fixtures.erxTasks,
            pharmacyViewModel: pharmacyModel
        ))
        // and a profile that has been logged in before (== insuranceID not nil)
        let profile = Profile(name: "Test", insuranceId: "loggedIn")
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        sut.send(.loadCurrentProfile)
        // then no state change occurs (default is no service)
        sut.receive(.response(.currentProfileReceived(profile)))

        // then redeem does not present soemthing
        sut.send(.showPharmacyRedeemOption(.onPremise))
        sut.send(.showPharmacyRedeemOption(.shipment))
        sut.send(.showPharmacyRedeemOption(.delivery))
    }

    func testTogglingFavoriteState_Success() {
        let sut = testStore(for: PharmacyDetailDomain.State(
            erxTasks: ErxTask.Fixtures.erxTasks,
            pharmacyViewModel: PharmacyLocationViewModel.Fixtures.pharmacyA
        ))

        mockPharmacyRepository.savePublisher = Just(true).setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        var expectedResult = PharmacyLocationViewModel.Fixtures.pharmacyA
        expectedResult.pharmacyLocation.isFavorite.toggle()

        sut.send(.toggleIsFavorite)
        sut.receive(.response(.toggleIsFavoriteReceived(.success(expectedResult)))) {
            $0.pharmacyViewModel = expectedResult
        }

        expect(self.mockFeedbackReceiver.hapticFeedbackSuccessCalled).to(beTrue())
        expect(self.mockFeedbackReceiver.hapticFeedbackSuccessCallsCount) == 1

        sut.send(.toggleIsFavorite)
        sut.receive(.response(.toggleIsFavoriteReceived(.success(PharmacyLocationViewModel.Fixtures.pharmacyA)))) {
            $0.pharmacyViewModel = PharmacyLocationViewModel.Fixtures.pharmacyA
        }

        expect(self.mockFeedbackReceiver.hapticFeedbackSuccessCallsCount) == 2
    }

    func testTogglingFavoriteState_Failure() {
        let sut = testStore(for: PharmacyDetailDomain.State(
            erxTasks: ErxTask.Fixtures.erxTasks,
            pharmacyViewModel: PharmacyLocationViewModel.Fixtures.pharmacyA
        ))

        let expectedError = PharmacyRepositoryError
            .local(.write(error: PharmacyCoreDataStore.Error.noMatchingEntity))
        mockPharmacyRepository
            .savePublisher = Fail(error: PharmacyRepositoryError
                .local(.write(error: PharmacyCoreDataStore.Error.noMatchingEntity))).eraseToAnyPublisher()

        var expectedResult = PharmacyLocationViewModel.Fixtures.pharmacyA
        expectedResult.pharmacyLocation.isFavorite.toggle()

        sut.send(.toggleIsFavorite)
        sut.receive(.response(.toggleIsFavoriteReceived(.failure(expectedError)))) {
            $0.destination = .alert(.init(for: expectedError))
        }
    }
}
