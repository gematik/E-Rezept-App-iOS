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
import eRpLocalStorage
import Nimble
import OpenSSL
import Pharmacy
import XCTest

@MainActor
class PharmacyDetailDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.immediate
    var mockUserSession: MockUserSession!
    var mockPharmacyRepository: MockPharmacyRepository!
    var mockFeedbackReceiver: MockFeedbackReceiver!
    var mockPrescriptionRepository: MockPrescriptionRepository!

    typealias TestStore = TestStoreOf<PharmacyDetailDomain>

    override func setUp() {
        super.setUp()
        mockUserSession = MockUserSession()
        mockPharmacyRepository = MockPharmacyRepository()
        mockFeedbackReceiver = MockFeedbackReceiver()
        mockPrescriptionRepository = MockPrescriptionRepository()
    }

    func testStore(for state: PharmacyDetailDomain.State) -> TestStore {
        TestStore(initialState: state) {
            PharmacyDetailDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
            dependencies.userSession = mockUserSession
            dependencies.pharmacyRepository = mockPharmacyRepository
            dependencies.feedbackReceiver = mockFeedbackReceiver
            dependencies.prescriptionRepository = mockPrescriptionRepository
            dependencies.date = DateGenerator.constant(Date.now)
            dependencies.calendar = Calendar.autoupdatingCurrent
        }
    }

    let derCert = try! X509(
        der: Data(
            base64Encoded: "MIIE4TCCA8mgAwIBAgIDD0vlMA0GCSqGSIb3DQEBCwUAMIGuMQswCQYDVQQGEwJERTEzMDEGA1UECgwqQXRvcyBJbmZvcm1hdGlvbiBUZWNobm9sb2d5IEdtYkggTk9ULVZBTElEMUgwRgYDVQQLDD9JbnN0aXR1dGlvbiBkZXMgR2VzdW5kaGVpdHN3ZXNlbnMtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxIDAeBgNVBAMMF0FUT1MuU01DQi1DQTMgVEVTVC1PTkxZMB4XDTE5MDkxNzEyMzYxNloXDTI0MDkxNzEyMzYxNlowXDELMAkGA1UEBhMCREUxIDAeBgNVBAoMFzEtMjExMjM0NTY3ODkgTk9ULVZBTElEMSswKQYDVQQDDCJBcnp0cHJheGlzIERyLiBBxJ9hb8SfbHUgVEVTVC1PTkxZMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmdmUeBLB6UDh4u8FAvi7B3hpAhJYXBlx+IJXLiSrhgCu/T/L5vVlCQb+1gYybWhHT5YlxafTJpOcXSfcixJbFWGxn+iQLqo+LCp/ljLBz5JoU+IXIxRKZCi5SZ9APeglGs4R0/xpPBtsJzihFXVu+B8qGm2oqmvVV91u+MoJ5asC6C+rVOecLxqy/OdmeKfaNSgH2NxVzNc19VmFUkFDGUFJjG4ZgatW4V6AuAhiPnDkEg8gfXr5L7ycQRZUNlEGMmDhh+noHU/doxSU2cgBaiTZNmu17FJLXlBLRISpWcQitcjOkjrJDt4Z0Yta64yZe13+a5dANh32Zeeg5jDQRQIDAQABo4IBVzCCAVMwHQYDVR0OBBYEFF/uDhGziRKzsUC9Nkat5xQojOUZMA4GA1UdDwEB/wQEAwIEMDAMBgNVHRMBAf8EAjAAMCAGA1UdIAQZMBcwCQYHKoIUAEwETDAKBggqghQATASBIzBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLXNtY2IuZWdrLXRlc3QtdHNwLmRlL0FUT1MuU01DQi1DQTNfVEVTVC1PTkxZLmNybDA8BggrBgEFBQcBAQQwMC4wLAYIKwYBBQUHMAGGIGh0dHA6Ly9vY3NwLXNtY2IuZWdrLXRlc3QtdHNwLmRlMB8GA1UdIwQYMBaAFD+eHl4mKtYMlaF4nqrz1drzQaf8MEUGBSskCAMDBDwwOjA4MDYwNDAyMBYMFEJldHJpZWJzc3TDpHR0ZSBBcnp0MAkGByqCFABMBDITDTEtMjExMjM0NTY3ODkwDQYJKoZIhvcNAQELBQADggEBACUnL3MxjyoEyUBRxcBAjl7FdePW0O1/UCeDAbH2b4ob9GjMGjL5OoBmhj9GsUORg/K4cIiqTot2TcPtdooKCI5a5Jupp0nYoAuzdrNlvGYEm0S/cvlyYJXjfhrEIHmlDY0/hpJX3S/hYgkniJ1Wg70MfLLcib05+31OijZmEzpChioIm4KmumEKU4ODsLWr/4OEw9KCYfuNpjiSyyAEd2pMgnGU8MKCJhrR/ZKSteAxAPKTXVtNTKndbptvcsaEZPp//vNdbBh+k8P642P2DHYfeDoUgivEYXdE5ABixtG9sk1Q2DPfTXoS+CKv45ae0vejBnRjuA28lmkmuIp+f+s=" // swiftlint:disable:this line_length
        )!
    )

    lazy var allServicesPharmacy: PharmacyLocationViewModel = {
        PharmacyLocationViewModel(
            pharmacy: PharmacyLocation(
                id: "id",
                telematikID: "telematikID",
                types: [.delivery, .mobl, .outpharm],
                avsEndpoints: .init(
                    onPremiseUrl: "some",
                    shipmentUrl: "some",
                    deliveryUrl: "some"
                ),
                avsCertificates: []
            )
        )
    }()

    lazy var mixedServicesPharmacy: PharmacyLocationViewModel = {
        PharmacyLocationViewModel(
            pharmacy: PharmacyLocation(
                id: "id",
                telematikID: "telematikID",
                types: [.delivery, .mobl, .outpharm],
                avsEndpoints: .init(
                    shipmentUrl: "some"
                ),
                avsCertificates: []
            )
        )
    }()

    lazy var noAVSServicesPharmacy: PharmacyLocationViewModel = {
        PharmacyLocationViewModel(
            pharmacy: PharmacyLocation(
                id: "id",
                telematikID: "telematikID",
                types: [.delivery, .mobl, .outpharm],
                avsEndpoints: nil,
                avsCertificates: []
            )
        )
    }()

    lazy var noServicePharmacy: PharmacyLocationViewModel = {
        .init(pharmacy: PharmacyLocation(id: "id", telematikID: "telematikID", types: []))
    }()

    func testRedeemFlowWithAProfileThatHasInsuranceId() async {
        // Given a pharmacy with all avs and ErxTaskRepository services
        let pharmacyModel = allServicesPharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared([]),
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            pharmacyViewModel: pharmacyModel,
            pharmacyRedeemState: Shared(nil)
        ))

        // and a profile that has been logged in before (== insuranceID non nil)
        let profile = Profile(name: "Test", insuranceId: "was logged in before", erxTasks: ErxTask.Fixtures.erxTasks)
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        mockPharmacyRepository.loadAvsCertificatesForReturnValue = Just([])
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()
        let prescriptions = Prescription.Fixtures.prescriptions.filter(\.isRedeemable)
        mockPrescriptionRepository.loadLocalReturnValue = Just(prescriptions)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(prescriptions)
        let selectedOption = RedeemOption.delivery
        let serviceOption = RedeemServiceOption.erxTaskRepository
        // When loading the profile
        await sut.send(.task) {
            // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`,
            // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
            $0.prescriptions = prescriptions
        }

        // Then redeem services for ErxTaskRepository can be used
        await sut.receive(.response(.currentProfileReceived(profile))) {
            $0.wasProfileAuthenticatedBefore = true
        }

        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected))) {
            $0.prescriptions = prescriptions
            $0.hasRedeemableTasks = true
        }

        await sut.receive(.response(.avsCertificatesReceived(.success([])))) {
            $0.reservationService = serviceOption
            $0.deliveryService = serviceOption
            $0.shipmentService = serviceOption
        }

        await sut.send(.tappedRedeemOption(selectedOption)) {
            $0.destination = .redeemViaErxTaskRepository(
                .init(
                    redeemOption: selectedOption,
                    prescriptions: $0.$prescriptions,
                    pharmacy: $0.pharmacyViewModel.pharmacyLocation,
                    selectedPrescriptions: Shared([])
                )
            )
        }
    }

    func testRedeemFlowWithAProfileThatHasNotBeenLoggedInBeforeAndAPharmacyWithAVSService() async {
        // Given a pharmacy with all avs and ErxTaskRepository services
        var pharmacyModel = allServicesPharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared([]),
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            pharmacyViewModel: pharmacyModel,
            pharmacyRedeemState: Shared(nil)
        ))
        // and a profile that has never been logged in before (== insuranceID is nil)
        let profile = Profile(name: "Test", insuranceId: nil, erxTasks: ErxTask.Fixtures.erxTasks)
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        let expectedCertResponse = [derCert]
        mockPharmacyRepository.loadAvsCertificatesForReturnValue = Just(expectedCertResponse)
            .setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
        let prescriptions = Prescription.Fixtures.prescriptions.filter(\.isRedeemable)
        mockPrescriptionRepository.loadLocalReturnValue = Just(prescriptions)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(prescriptions)

        let selectedOption = RedeemOption.shipment
        let serviceOption = RedeemServiceOption.avs
        // When loading the profile
        await sut.send(.task) {
            // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`,
            // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
            $0.prescriptions = prescriptions
        }
        // Then only redeem services for `avs` should be available
        await sut.receive(.response(.currentProfileReceived(profile)))

        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected))) {
            $0.prescriptions = prescriptions
            $0.hasRedeemableTasks = true
        }

        await sut.receive(.response(.avsCertificatesReceived(.success(expectedCertResponse)))) {
            $0.reservationService = serviceOption
            $0.deliveryService = serviceOption
            $0.shipmentService = serviceOption
            $0.pharmacyViewModel.pharmacyLocation.avsCertificates = expectedCertResponse
        }
        pharmacyModel.pharmacyLocation.avsCertificates = [derCert]

        await sut.send(.tappedRedeemOption(selectedOption)) {
            $0.destination = .redeemViaAVS(
                .init(
                    redeemOption: selectedOption,
                    prescriptions: $0.$prescriptions,
                    pharmacy: $0.pharmacyViewModel.pharmacyLocation,
                    selectedPrescriptions: Shared([])
                )
            )
        }
    }

    func testRedeemFlowWithAProfileThatHasNotBeenLoggedInBeforeAndAPharmacyWithAVSServiceAndMissingCerts() async {
        // Given a pharmacy with all avs and ErxTaskRepository services
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared([]),
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            pharmacyViewModel: allServicesPharmacy,
            pharmacyRedeemState: Shared(nil)
        ))
        // and a profile that has never been logged in before (== insuranceID is nil)
        let profile = Profile(name: "Test", insuranceId: nil, erxTasks: ErxTask.Fixtures.erxTasks)
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        mockPharmacyRepository.loadAvsCertificatesForReturnValue = Just([])
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()
        let prescriptions = Prescription.Fixtures.prescriptions.filter(\.isRedeemable)
        mockPrescriptionRepository.loadLocalReturnValue = Just(prescriptions)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(prescriptions)
        let selectedOption = RedeemOption.onPremise
        let serviceOption = RedeemServiceOption.erxTaskRepositoryAvailable

        // When loading the profile
        await sut.send(.task) {
            // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`,
            // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
            $0.prescriptions = prescriptions
        }
        // Then only redeem services for `avs` should be available
        await sut.receive(.response(.currentProfileReceived(profile)))
        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected))) {
            $0.prescriptions = prescriptions
            $0.hasRedeemableTasks = true
        }

        await sut.receive(.response(.avsCertificatesReceived(.success([])))) {
            $0.reservationService = serviceOption
            $0.deliveryService = serviceOption
            $0.shipmentService = serviceOption
        }

        await sut.send(.tappedRedeemOption(selectedOption)) {
            $0.destination = .redeemViaErxTaskRepository(
                .init(
                    redeemOption: selectedOption,
                    prescriptions: $0.$prescriptions,
                    pharmacy: $0.pharmacyViewModel.pharmacyLocation,
                    selectedPrescriptions: Shared([])
                )
            )
        }
    }

    func testRedeemFlowWithAProfileThatHasNotBeenLoggedInAndAPharmacyWithoutAVS() async {
        // Given a pharmacy with only ErxTaskRepository services
        let pharmacyModel = PharmacyLocationViewModel.Dummies.pharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared([]),
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            pharmacyViewModel: pharmacyModel,
            pharmacyRedeemState: Shared(nil)
        ))
        // and a profile that has never been logged in before (== insuranceID is nil)
        let profile = Profile(name: "Test", insuranceId: nil, erxTasks: ErxTask.Fixtures.erxTasks)
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        let prescriptions = Prescription.Fixtures.prescriptions.filter(\.isRedeemable)
        mockPrescriptionRepository.loadLocalReturnValue = Just(prescriptions)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(prescriptions)
        let selectedOption = RedeemOption.onPremise
        let serviceOption = RedeemServiceOption.erxTaskRepositoryAvailable
        // When loading the profile
        await sut.send(.task) {
            // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`,
            // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
            $0.prescriptions = prescriptions
        }
        // Then only redeem services for ErxTaskRepository should be available (after login)
        await sut.receive(.response(.currentProfileReceived(profile))) {
            $0.reservationService = serviceOption
            $0.deliveryService = serviceOption
            $0.shipmentService = serviceOption
        }

        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected))) {
            $0.prescriptions = prescriptions
            $0.hasRedeemableTasks = true
        }

        await sut.send(.tappedRedeemOption(selectedOption)) {
            $0.destination = .redeemViaErxTaskRepository(
                .init(
                    redeemOption: selectedOption,
                    prescriptions: $0.$prescriptions,
                    pharmacy: $0.pharmacyViewModel.pharmacyLocation,
                    selectedPrescriptions: Shared([])
                )
            )
        }
    }

    func testRedeemOptionWithPharmacyWithoutServicesAndNotLoggedInBefore() async {
        // Given a pharmacy without any services
        let pharmacyModel = noServicePharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared([]),
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            pharmacyViewModel: pharmacyModel,
            pharmacyRedeemState: Shared(nil)
        ))
        // and a profile that has never been logged in before (== insuranceID is nil)
        let profile = Profile(name: "Test", insuranceId: nil, erxTasks: ErxTask.Fixtures.erxTasks)
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        let prescriptions = Prescription.Fixtures.prescriptions.filter(\.isRedeemable)
        mockPrescriptionRepository.loadLocalReturnValue = Just(prescriptions)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(prescriptions)
        await sut.send(.task) {
            // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`,
            // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
            $0.prescriptions = prescriptions
        }
        // then no state change occurs (default is no service)
        await sut.receive(.response(.currentProfileReceived(profile)))

        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected))) {
            $0.prescriptions = prescriptions
            $0.hasRedeemableTasks = true
        }

        // then redeem does not present something
        await sut.send(.tappedRedeemOption(.onPremise))
        await sut.send(.tappedRedeemOption(.shipment))
        await sut.send(.tappedRedeemOption(.delivery))
    }

    func testRedeemOptionWithPharmacyWithoutServicesAndLoggedInBefore() async {
        // Given a pharmacy without any services
        let pharmacyModel = noServicePharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared([]),
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            pharmacyViewModel: pharmacyModel,
            pharmacyRedeemState: Shared(nil)
        ))
        // and a profile that has been logged in before (== insuranceID not nil)
        let profile = Profile(name: "Test", insuranceId: "loggedIn", erxTasks: ErxTask.Fixtures.erxTasks)
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        let prescriptions = Prescription.Fixtures.prescriptions.filter(\.isRedeemable)
        mockPrescriptionRepository.loadLocalReturnValue = Just(prescriptions)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(prescriptions)
        await sut.send(.task) {
            // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`,
            // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
            $0.prescriptions = prescriptions
        }
        // then no state change occurs (default is no service)
        await sut.receive(.response(.currentProfileReceived(profile))) {
            $0.wasProfileAuthenticatedBefore = true
        }
        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected))) {
            $0.prescriptions = prescriptions
            $0.hasRedeemableTasks = true
        }

        // then redeem does not present something
        await sut.send(.tappedRedeemOption(.onPremise))
        await sut.send(.tappedRedeemOption(.shipment))
        await sut.send(.tappedRedeemOption(.delivery))
    }

    func testRedeemOptionWithAPharmacyOfSomeAVSServicesAndLoggedInBefore() async {
        // Given a pharmacy with all avs and ErxTaskRepository services
        let pharmacyModel = mixedServicesPharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared([]),
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            pharmacyViewModel: pharmacyModel,
            pharmacyRedeemState: Shared(nil)
        ))
        // and a profile that has been logged in before (== insuranceID is not nil)
        let profile = Profile(name: "Test", insuranceId: "loggedIn")
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        let expectedCertResponse = [derCert]
        mockPharmacyRepository.loadAvsCertificatesForReturnValue = Just(expectedCertResponse)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()
        let prescriptions = Prescription.Fixtures.prescriptions.filter(\.isRedeemable)
        mockPrescriptionRepository.loadLocalReturnValue = Just(prescriptions)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(prescriptions)
        // When loading the profile
        await sut.send(.task) {
            // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`,
            // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
            $0.prescriptions = prescriptions
        }
        // Then the redeem services for `avs` should overwrite ti services
        await sut.receive(.response(.currentProfileReceived(profile))) {
            $0.wasProfileAuthenticatedBefore = true
        }

        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected))) {
            $0.prescriptions = prescriptions
            $0.hasRedeemableTasks = true
        }

        await sut.receive(.response(.avsCertificatesReceived(.success(expectedCertResponse)))) {
            $0.reservationService = .noService
            $0.deliveryService = .noService
            $0.shipmentService = .erxTaskRepository
            $0.pharmacyViewModel.pharmacyLocation.avsCertificates = expectedCertResponse
        }
    }

    func testRedeemOptionWithAPharmacyOfSomeAVSServicesAndNotLoggedInBefore() async {
        // Given a pharmacy with all avs and ErxTaskRepository services
        let pharmacyModel = mixedServicesPharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared([]),
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            pharmacyViewModel: pharmacyModel,
            pharmacyRedeemState: Shared(nil)
        ))
        // and a profile that has not been logged in before (== insuranceID is nil)
        let profile = Profile(name: "Test", insuranceId: nil)
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        let expectedCertResponse = [derCert]
        mockPharmacyRepository.loadAvsCertificatesForReturnValue = Just(expectedCertResponse)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()
        let prescriptions = Prescription.Fixtures.prescriptions.filter(\.isRedeemable)
        mockPrescriptionRepository.loadLocalReturnValue = Just(prescriptions)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(prescriptions)
        // When loading the profile
        await sut.send(.task) {
            // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`,
            // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
            $0.prescriptions = prescriptions
        }
        // Then the redeem services for `avs` should overwrite ti services
        await sut.receive(.response(.currentProfileReceived(profile)))

        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected))) {
            $0.prescriptions = prescriptions
            $0.hasRedeemableTasks = true
        }

        await sut.receive(.response(.avsCertificatesReceived(.success(expectedCertResponse)))) {
            $0.reservationService = .noService
            $0.deliveryService = .noService
            $0.shipmentService = .avs
            $0.pharmacyViewModel.pharmacyLocation.avsCertificates = expectedCertResponse
        }
    }

    func testRedeemOptionWithoutAVSServicesAndLoggedInBefore() async {
        // Given a pharmacy with all ErxTaskRepository and no avs services
        let pharmacyModel = noAVSServicesPharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared([]),
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            pharmacyViewModel: pharmacyModel,
            pharmacyRedeemState: Shared(nil)
        ))
        // and a profile that has been logged in before (== insuranceID is not nil)
        let profile = Profile(name: "Test", insuranceId: "loggedIn")
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        mockPharmacyRepository.loadAvsCertificatesForReturnValue = Just([])
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()
        let prescriptions = Prescription.Fixtures.prescriptions.filter(\.isRedeemable)
        mockPrescriptionRepository.loadLocalReturnValue = Just(prescriptions)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(prescriptions)
        // When loading the profile
        await sut.send(.task) {
            // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`,
            // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
            $0.prescriptions = prescriptions
        }
        // Then the redeem services should be the one from the repository
        await sut.receive(.response(.currentProfileReceived(profile))) {
            $0.wasProfileAuthenticatedBefore = true
            $0.reservationService = .erxTaskRepository
            $0.deliveryService = .erxTaskRepository
            $0.shipmentService = .erxTaskRepository
        }
        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected))) {
            $0.prescriptions = prescriptions
            $0.hasRedeemableTasks = true
        }
    }

    func testRedeemOptionWithoutAVSServicesAndNotLoggedInBefore() async {
        // Given a pharmacy with all ErxTaskRepository and no avs services
        let pharmacyModel = noAVSServicesPharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared([]),
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            pharmacyViewModel: pharmacyModel,
            pharmacyRedeemState: Shared(nil)
        ))
        // and a profile that has not been logged in before (== insuranceID is nil)
        let profile = Profile(name: "Test", insuranceId: nil)
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        mockPharmacyRepository.loadAvsCertificatesForReturnValue = Just([])
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()
        let prescriptions = Prescription.Fixtures.prescriptions.filter(\.isRedeemable)
        mockPrescriptionRepository.loadLocalReturnValue = Just(prescriptions)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(prescriptions)
        // When loading the profile
        await sut.send(.task) {
            // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`,
            // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
            $0.prescriptions = prescriptions
        }
        // Then the redeem services should be the one from the repository
        await sut.receive(.response(.currentProfileReceived(profile))) {
            $0.reservationService = .erxTaskRepositoryAvailable
            $0.deliveryService = .erxTaskRepositoryAvailable
            $0.shipmentService = .erxTaskRepositoryAvailable
        }
        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected))) {
            $0.prescriptions = prescriptions
            $0.hasRedeemableTasks = true
        }
    }

    func testTogglingFavoriteState_Success() async {
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared([]),
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            pharmacyViewModel: PharmacyLocationViewModel.Fixtures.pharmacyA,
            pharmacyRedeemState: Shared(nil)
        ))

        mockPharmacyRepository.savePharmaciesReturnValue = Just(true).setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        var expectedResult = PharmacyLocationViewModel.Fixtures.pharmacyA
        expectedResult.pharmacyLocation.isFavorite.toggle()

        await sut.send(.toggleIsFavorite)
        await sut.receive(.response(.toggleIsFavoriteReceived(.success(expectedResult)))) {
            $0.pharmacyViewModel = expectedResult
        }

        expect(self.mockFeedbackReceiver.hapticFeedbackSuccessCalled).to(beTrue())
        expect(self.mockFeedbackReceiver.hapticFeedbackSuccessCallsCount) == 1

        await sut.send(.toggleIsFavorite)
        await sut
            .receive(.response(.toggleIsFavoriteReceived(.success(PharmacyLocationViewModel.Fixtures.pharmacyA)))) {
                $0.pharmacyViewModel = PharmacyLocationViewModel.Fixtures.pharmacyA
            }

        expect(self.mockFeedbackReceiver.hapticFeedbackSuccessCallsCount) == 2
    }

    func testSetFavoriteStateTrue() async {
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared([]),
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            pharmacyViewModel: PharmacyLocationViewModel.Fixtures.pharmacyA,
            pharmacyRedeemState: Shared(nil)
        ))

        mockPharmacyRepository.savePharmaciesReturnValue = Just(true).setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        var expectedResult = PharmacyLocationViewModel.Fixtures.pharmacyA
        expectedResult.pharmacyLocation.isFavorite.toggle()

        await sut.send(.setIsFavorite(true))
        await sut.receive(.response(.toggleIsFavoriteReceived(.success(expectedResult)))) {
            $0.pharmacyViewModel = expectedResult
        }

        expect(self.mockFeedbackReceiver.hapticFeedbackSuccessCalled).to(beTrue())
        expect(self.mockFeedbackReceiver.hapticFeedbackSuccessCallsCount) == 1

        await sut.send(.setIsFavorite(true))
        expect(self.mockFeedbackReceiver.hapticFeedbackSuccessCallsCount) == 2

        await sut.send(.setIsFavorite(false))
        await sut
            .receive(.response(.toggleIsFavoriteReceived(.success(PharmacyLocationViewModel.Fixtures.pharmacyA)))) {
                $0.pharmacyViewModel = PharmacyLocationViewModel.Fixtures.pharmacyA
            }
        expect(self.mockFeedbackReceiver.hapticFeedbackSuccessCallsCount) == 3
    }

    func testTogglingFavoriteState_Failure() async {
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared([]),
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            pharmacyViewModel: PharmacyLocationViewModel.Fixtures.pharmacyA,
            pharmacyRedeemState: Shared(nil)
        ))

        let expectedError = PharmacyRepositoryError
            .local(.write(error: PharmacyCoreDataStore.Error.noMatchingEntity))
        mockPharmacyRepository
            .savePharmaciesReturnValue = Fail(error: PharmacyRepositoryError
                .local(.write(error: PharmacyCoreDataStore.Error.noMatchingEntity))).eraseToAnyPublisher()

        var expectedResult = PharmacyLocationViewModel.Fixtures.pharmacyA
        expectedResult.pharmacyLocation.isFavorite.toggle()

        await sut.send(.toggleIsFavorite)
        await sut.receive(.response(.toggleIsFavoriteReceived(.failure(expectedError)))) {
            $0.destination = .alert(.init(for: expectedError))
        }
    }

    func testNoErxTask() async {
        // Given a pharmacy without any services
        let pharmacyModel = noServicePharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared([]),
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            pharmacyViewModel: pharmacyModel,
            pharmacyRedeemState: Shared(nil)
        ))
        // and a profile that has been logged in before (== insuranceID not nil)
        let profile = Profile(name: "Test", insuranceId: nil)
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        mockPrescriptionRepository.loadLocalReturnValue = Just([])
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success([])
        await sut.send(.task)
        // then no state change occurs (default is no service)
        await sut.receive(.response(.currentProfileReceived(profile)))
        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))
        // then redeem does not present soemthing
        await sut.send(.tappedRedeemOption(.onPremise)) {
            $0.destination = .toast(PharmacyDetailDomain.ToastStates.noErxTask)
        }
    }

    func testOnlyRedeemablePrescriptionStored() async {
        await withDependencies {
            $0.date = DateGenerator { Date() }
        } operation: {
            // Given a pharmacy with all avs and ErxTaskRepository services
            let pharmacyModel = allServicesPharmacy
            let sut = testStore(for: PharmacyDetailDomain.State(
                prescriptions: Shared([]),
                selectedPrescriptions: Shared([]),
                inRedeemProcess: false,
                pharmacyViewModel: pharmacyModel,
                pharmacyRedeemState: Shared(nil)
            ))

            // and a profile that has been logged in before (== insuranceID non nil)
            let profile = Profile(name: "Test")
            mockUserSession.profileReturnValue = Just(profile)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
            mockPharmacyRepository.loadAvsCertificatesForReturnValue = Just([])
                .setFailureType(to: PharmacyRepositoryError.self)
                .eraseToAnyPublisher()

            let expectedPrescription = Prescription(erxTask: ErxTask.Fixtures.erxTask1,
                                                    dateFormatter: UIDateFormatter.testValue)
            let nonReadyPrescriptions = [
                Prescription(erxTask: ErxTask.Fixtures.erxTask9, dateFormatter: UIDateFormatter.testValue),
                Prescription(erxTask: ErxTask.Fixtures.erxTask10, dateFormatter: UIDateFormatter.testValue),
                Prescription(erxTask: ErxTask.Fixtures.erxTask11, dateFormatter: UIDateFormatter.testValue),
            ]

            let prescriptions = nonReadyPrescriptions + [expectedPrescription]

            mockPrescriptionRepository.loadLocalReturnValue = Just(prescriptions)
                .setFailureType(to: PrescriptionRepositoryError.self)
                .eraseToAnyPublisher()
            await sut.send(.task) {
                // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`
                // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
                $0.prescriptions = [expectedPrescription]
            }

            await sut.receive(.response(.currentProfileReceived(profile)))

            await sut.receive(.response(.loadLocalPrescriptionsReceived(.success(prescriptions)))) {
                $0.prescriptions = [expectedPrescription]
                $0.hasRedeemableTasks = true
            }

            await sut.receive(.response(.avsCertificatesReceived(.success([])))) {
                $0.reservationService = .erxTaskRepositoryAvailable
                $0.deliveryService = .erxTaskRepositoryAvailable
                $0.shipmentService = .erxTaskRepositoryAvailable
            }
        }
    }

    func testInRedeemProcessWithSelectedPrescription() async {
        // Given a pharmacy with all avs and ErxTaskRepository services
        let pharmacyModel = allServicesPharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared<[Prescription]>([]),
            selectedPrescriptions: Shared([Prescription.Dummies.prescriptionMVO]),
            inRedeemProcess: true,
            pharmacyViewModel: pharmacyModel,
            pharmacyRedeemState: Shared(nil)
        ))

        let profile = Profile(name: "Test")
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        mockPharmacyRepository.loadAvsCertificatesForReturnValue = Just([])
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let prescriptions = [Prescription.Dummies.prescriptionReady, Prescription.Dummies.scanned]

        mockPrescriptionRepository.loadLocalReturnValue = Just(prescriptions)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(prescriptions)
        await sut.send(.task) {
            // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`,
            // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
            $0.prescriptions = prescriptions
        }

        await sut.receive(.response(.currentProfileReceived(profile)))

        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected))) {
            $0.prescriptions = prescriptions
            $0.hasRedeemableTasks = true
        }

        await sut.receive(.response(.avsCertificatesReceived(.success([])))) {
            $0.reservationService = .erxTaskRepositoryAvailable
            $0.deliveryService = .erxTaskRepositoryAvailable
            $0.shipmentService = .erxTaskRepositoryAvailable
        }

        await sut.send(.tappedRedeemOption(.delivery)) {
            $0.destination = .redeemViaErxTaskRepository(.init(redeemOption: .delivery,
                                                               prescriptions: $0.$prescriptions,
                                                               pharmacy: pharmacyModel.pharmacyLocation,
                                                               selectedPrescriptions: Shared($0.selectedPrescriptions)))
        }
    }
}
