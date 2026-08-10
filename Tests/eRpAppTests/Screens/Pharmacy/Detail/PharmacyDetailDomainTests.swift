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
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import eRpLocalStorage
import FeatureHelpers
import Nimble
import OpenSSL
import Pharmacy
import XCTest

@MainActor
class PharmacyDetailDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.immediate
    var mockUserSession: MockUserSession!
    var mockRedeemService: RedeemServiceMock!
    var mockPrescriptionRepository: PrescriptionRepositoryMock!

    typealias TestStore = TestStoreOf<PharmacyDetailDomain>

    override func invokeTest() {
        withDependencies { dependencies in
            dependencies.date.now = TestDate.defaultReferenceDate
        } operation: {
            super.invokeTest()
        }
    }

    override func setUp() {
        super.setUp()
        mockUserSession = MockUserSession()
        mockRedeemService = RedeemServiceMock()
        mockPrescriptionRepository = PrescriptionRepositoryMock()
    }

    func testStore(
        for state: PharmacyDetailDomain.State,
        withDependencies prepareDependencies: (inout DependencyValues) -> Void = { _ in }
    ) -> TestStore {
        TestStore(initialState: state) {
            PharmacyDetailDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
            dependencies.userSession = mockUserSession
            dependencies.hapticFeedbackGenerator.success = {}
            dependencies.prescriptionRepository = mockPrescriptionRepository
            dependencies.redeemOrderService.redeemViaErxTaskRepository = { @Sendable [mockRedeemService] orders, _ in
                try await mockRedeemService?.redeem(orders, profileId: UUID()).async() ?? []
            }
            dependencies.date = DateGenerator.constant(Date.now)
            dependencies.calendar = Calendar.autoupdatingCurrent

            prepareDependencies(&dependencies)
        }
    }

    let derCert = try! X509(
        der: Data(
            base64Encoded: "MIIE4TCCA8mgAwIBAgIDD0vlMA0GCSqGSIb3DQEBCwUAMIGuMQswCQYDVQQGEwJERTEzMDEGA1UECgwqQXRvcyBJbmZvcm1hdGlvbiBUZWNobm9sb2d5IEdtYkggTk9ULVZBTElEMUgwRgYDVQQLDD9JbnN0aXR1dGlvbiBkZXMgR2VzdW5kaGVpdHN3ZXNlbnMtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxIDAeBgNVBAMMF0FUT1MuU01DQi1DQTMgVEVTVC1PTkxZMB4XDTE5MDkxNzEyMzYxNloXDTI0MDkxNzEyMzYxNlowXDELMAkGA1UEBhMCREUxIDAeBgNVBAoMFzEtMjExMjM0NTY3ODkgTk9ULVZBTElEMSswKQYDVQQDDCJBcnp0cHJheGlzIERyLiBBxJ9hb8SfbHUgVEVTVC1PTkxZMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmdmUeBLB6UDh4u8FAvi7B3hpAhJYXBlx+IJXLiSrhgCu/T/L5vVlCQb+1gYybWhHT5YlxafTJpOcXSfcixJbFWGxn+iQLqo+LCp/ljLBz5JoU+IXIxRKZCi5SZ9APeglGs4R0/xpPBtsJzihFXVu+B8qGm2oqmvVV91u+MoJ5asC6C+rVOecLxqy/OdmeKfaNSgH2NxVzNc19VmFUkFDGUFJjG4ZgatW4V6AuAhiPnDkEg8gfXr5L7ycQRZUNlEGMmDhh+noHU/doxSU2cgBaiTZNmu17FJLXlBLRISpWcQitcjOkjrJDt4Z0Yta64yZe13+a5dANh32Zeeg5jDQRQIDAQABo4IBVzCCAVMwHQYDVR0OBBYEFF/uDhGziRKzsUC9Nkat5xQojOUZMA4GA1UdDwEB/wQEAwIEMDAMBgNVHRMBAf8EAjAAMCAGA1UdIAQZMBcwCQYHKoIUAEwETDAKBggqghQATASBIzBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLXNtY2IuZWdrLXRlc3QtdHNwLmRlL0FUT1MuU01DQi1DQTNfVEVTVC1PTkxZLmNybDA8BggrBgEFBQcBAQQwMC4wLAYIKwYBBQUHMAGGIGh0dHA6Ly9vY3NwLXNtY2IuZWdrLXRlc3QtdHNwLmRlMB8GA1UdIwQYMBaAFD+eHl4mKtYMlaF4nqrz1drzQaf8MEUGBSskCAMDBDwwOjA4MDYwNDAyMBYMFEJldHJpZWJzc3TDpHR0ZSBBcnp0MAkGByqCFABMBDITDTEtMjExMjM0NTY3ODkwDQYJKoZIhvcNAQELBQADggEBACUnL3MxjyoEyUBRxcBAjl7FdePW0O1/UCeDAbH2b4ob9GjMGjL5OoBmhj9GsUORg/K4cIiqTot2TcPtdooKCI5a5Jupp0nYoAuzdrNlvGYEm0S/cvlyYJXjfhrEIHmlDY0/hpJX3S/hYgkniJ1Wg70MfLLcib05+31OijZmEzpChioIm4KmumEKU4ODsLWr/4OEw9KCYfuNpjiSyyAEd2pMgnGU8MKCJhrR/ZKSteAxAPKTXVtNTKndbptvcsaEZPp//vNdbBh+k8P642P2DHYfeDoUgivEYXdE5ABixtG9sk1Q2DPfTXoS+CKv45ae0vejBnRjuA28lmkmuIp+f+s=" // swiftlint:disable:this line_length
        )!
    )

    lazy var allServicesPharmacy: PharmacyLocationViewModel = .init(
        pharmacy: PharmacyLocation(
            id: "id",
            telematikID: "telematikID",
            types: [.delivery, .mobl, .outpharm]
        )
    )

    lazy var mixedServicesPharmacy: PharmacyLocationViewModel = .init(
        pharmacy: PharmacyLocation(
            id: "id",
            telematikID: "telematikID",
            types: [.delivery, .mobl, .outpharm]
        )
    )

    lazy var noAVSServicesPharmacy: PharmacyLocationViewModel = .init(
        pharmacy: PharmacyLocation(
            id: "id",
            telematikID: "telematikID",
            types: [.delivery, .mobl, .outpharm]
        )
    )

    lazy var noServicePharmacy: PharmacyLocationViewModel = .init(pharmacy: PharmacyLocation(
        id: "id",
        telematikID: "telematikID",
        types: []
    ))

    func testRedeemFlowWithAProfileThatHasInsuranceId() async {
        // Given a pharmacy with all avs and ErxTaskRepository services
        let pharmacyModel = allServicesPharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared(value: []),
            selectedPrescriptions: Shared(value: []),
            inRedeemProcess: false,
            pharmacyViewModel: pharmacyModel,
            availableServiceOptions: [.delivery]
        ))

        // and a profile that has been logged in before (== insuranceID non nil)
        let profile = Profile(
            name: "Test",
            insuranceId: "was logged in before",
            erxTasks: ErxTask.Fixtures.erxTasks
        )
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        let prescriptions = Prescription.Fixtures.prescriptions.filter(\.isRedeemable)
        mockPrescriptionRepository
            .loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorReturnValue =
            Just(prescriptions)
                .setFailureType(to: PrescriptionRepositoryError.self)
                .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(prescriptions)
        let selectedOption = RedeemOption.delivery

        // When loading the profile
        await sut.send(.task) {
            // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`
            // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
            $0.$prescriptions.withLock { $0 = prescriptions }
            $0.serviceOptionState.$prescriptions.withLock { $0 = prescriptions }
        }

        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected))) {
            $0.$prescriptions.withLock { $0 = prescriptions }
            $0.hasRedeemableTasks = true
        }

        await sut
            .receive(.response(.redeemOptionProviderReceived(RedeemOptionProvider(
                wasAuthenticatedBefore: true,
                pharmacy: pharmacyModel.pharmacyLocation
            )))) {
                $0.serviceOptionState.availableOptions = [.delivery, .onPremise, .shipment]
                $0.serviceOptionState.validOptions = [.delivery, .onPremise, .shipment]
                $0.serviceOptionState.redeemOptionProvider = RedeemOptionProvider(
                    wasAuthenticatedBefore: true,
                    pharmacy: pharmacyModel.pharmacyLocation
                )
            }

        await sut.send(.serviceOption(.redeemOptionTapped(selectedOption)))

        await sut.receive(.delegate(.redeem(
            prescriptions: prescriptions,
            selectedPrescriptions: [],
            pharmacy: pharmacyModel.pharmacyLocation,
            option: selectedOption
        )))
    }

    func testRedeemFlowWithAProfileThatHasNotBeenLoggedInBeforeAndAPharmacyWithAVSService() async {
        // Given a pharmacy with all avs and ErxTaskRepository services
        let pharmacyModel = allServicesPharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared(value: []),
            selectedPrescriptions: Shared(value: []),
            inRedeemProcess: false,
            pharmacyViewModel: pharmacyModel,
            availableServiceOptions: [.shipment]
        ))
        // and a profile that has never been logged in before (== insuranceID is nil)
        let profile = Profile(name: "Test", insuranceId: nil, erxTasks: ErxTask.Fixtures.erxTasks)
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        let prescriptions = Prescription.Fixtures.prescriptions.filter(\.isRedeemable)
        mockPrescriptionRepository
            .loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorReturnValue =
            Just(prescriptions)
                .setFailureType(to: PrescriptionRepositoryError.self)
                .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(prescriptions)

        let selectedOption = RedeemOption.shipment

        // When loading the profile
        await sut.send(.task) {
            // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`
            // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
            $0.$prescriptions.withLock { $0 = prescriptions }
            $0.serviceOptionState.$prescriptions.withLock { $0 = prescriptions }
        }

        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected))) {
            $0.$prescriptions.withLock { $0 = prescriptions }
            $0.hasRedeemableTasks = true
        }

        await sut.receive(.response(.redeemOptionProviderReceived(
            RedeemOptionProvider(wasAuthenticatedBefore: false, pharmacy: pharmacyModel.pharmacyLocation)
        ))) {
            $0.serviceOptionState.availableOptions = [.delivery, .onPremise, .shipment]
            $0.serviceOptionState.validOptions = [.delivery, .onPremise, .shipment]
            $0.serviceOptionState.redeemOptionProvider = RedeemOptionProvider(
                wasAuthenticatedBefore: false,
                pharmacy: pharmacyModel.pharmacyLocation
            )
        }

        await sut.send(.serviceOption(.redeemOptionTapped(selectedOption)))

        await sut.receive(.delegate(.redeem(
            prescriptions: prescriptions,
            selectedPrescriptions: [],
            pharmacy: allServicesPharmacy.pharmacyLocation,
            option: selectedOption
        )))
    }

    func testRedeemFlowWithAProfileThatHasNotBeenLoggedInBeforeAndAPharmacyWithAVSServiceAndMissingCerts() async {
        // Given a pharmacy with all avs and ErxTaskRepository services
        let pharmacyModel = allServicesPharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared(value: []),
            selectedPrescriptions: Shared(value: []),
            inRedeemProcess: false,
            pharmacyViewModel: pharmacyModel
        ))
        // and a profile that has never been logged in before (== insuranceID is nil)
        let profile = Profile(name: "Test", insuranceId: nil, erxTasks: ErxTask.Fixtures.erxTasks)
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        let prescriptions = Prescription.Fixtures.prescriptions.filter(\.isRedeemable)
        mockPrescriptionRepository
            .loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorReturnValue =
            Just(prescriptions)
                .setFailureType(to: PrescriptionRepositoryError.self)
                .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(prescriptions)
        let selectedOption = RedeemOption.onPremise

        // When loading the profile
        await sut.send(.task) {
            // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`
            // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
            $0.$prescriptions.withLock { $0 = prescriptions }
            $0.serviceOptionState.$prescriptions.withLock { $0 = prescriptions }
        }
        // Then only redeem services for `avs` should be available
        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected))) {
            $0.$prescriptions.withLock { $0 = prescriptions }
            $0.hasRedeemableTasks = true
        }

        await sut.receive(.response(.redeemOptionProviderReceived(
            RedeemOptionProvider(wasAuthenticatedBefore: false, pharmacy: pharmacyModel.pharmacyLocation)
        ))) {
            $0.serviceOptionState.availableOptions = [.onPremise, .delivery, .shipment]
            $0.serviceOptionState.validOptions = [.delivery, .onPremise, .shipment]
            $0.serviceOptionState.redeemOptionProvider = RedeemOptionProvider(
                wasAuthenticatedBefore: false,
                pharmacy: pharmacyModel.pharmacyLocation
            )
        }

        await sut.send(.serviceOption(.redeemOptionTapped(selectedOption)))

        await sut.receive(.delegate(.redeem(
            prescriptions: prescriptions,
            selectedPrescriptions: [],
            pharmacy: allServicesPharmacy.pharmacyLocation,
            option: selectedOption
        )))
    }

    func testRedeemFlowWithAProfileThatHasNotBeenLoggedInAndAPharmacyWithoutAVS() async {
        // Given a pharmacy with only ErxTaskRepository services
        let pharmacyModel = PharmacyLocationViewModel.Dummies.pharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared(value: []),
            selectedPrescriptions: Shared(value: []),
            inRedeemProcess: false,
            pharmacyViewModel: pharmacyModel
        ))
        // and a profile that has never been logged in before (== insuranceID is nil)
        let profile = Profile(name: "Test", insuranceId: nil, erxTasks: ErxTask.Fixtures.erxTasks)
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        let prescriptions = Prescription.Fixtures.prescriptions.filter(\.isRedeemable)
        mockPrescriptionRepository
            .loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorReturnValue =
            Just(prescriptions)
                .setFailureType(to: PrescriptionRepositoryError.self)
                .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(prescriptions)
        let selectedOption = RedeemOption.onPremise
        // When loading the profile
        await sut.send(.task) {
            // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`,
            // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
            $0.$prescriptions.withLock { $0 = prescriptions }
            $0.serviceOptionState.$prescriptions.withLock { $0 = prescriptions }
        }
        // Then only redeem services for ErxTaskRepository should be available (after login)
        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected))) {
            $0.$prescriptions.withLock { $0 = prescriptions }
            $0.hasRedeemableTasks = true
        }

        await sut.receive(.response(.redeemOptionProviderReceived(
            RedeemOptionProvider(wasAuthenticatedBefore: false, pharmacy: pharmacyModel.pharmacyLocation)
        ))) {
            $0.serviceOptionState.availableOptions = [.onPremise, .delivery, .shipment]
            $0.serviceOptionState.validOptions = [.delivery, .onPremise, .shipment]
            $0.serviceOptionState.redeemOptionProvider = RedeemOptionProvider(
                wasAuthenticatedBefore: false,
                pharmacy: pharmacyModel.pharmacyLocation
            )
        }

        await sut.send(.serviceOption(.redeemOptionTapped(selectedOption)))

        await sut.receive(.delegate(.redeem(
            prescriptions: prescriptions,
            selectedPrescriptions: [],
            pharmacy: pharmacyModel.pharmacyLocation,
            option: selectedOption
        )))
    }

    func testRedeemOptionWithPharmacyWithoutServicesAndNotLoggedInBefore() async {
        // Given a pharmacy without any services
        let pharmacyModel = noServicePharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared(value: []),
            selectedPrescriptions: Shared(value: []),
            inRedeemProcess: false,
            pharmacyViewModel: pharmacyModel
        ))
        // and a profile that has never been logged in before (== insuranceID is nil)
        let profile = Profile(name: "Test", insuranceId: nil, erxTasks: ErxTask.Fixtures.erxTasks)
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        let prescriptions = Prescription.Fixtures.prescriptions.filter(\.isRedeemable)
        mockPrescriptionRepository
            .loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorReturnValue =
            Just(prescriptions)
                .setFailureType(to: PrescriptionRepositoryError.self)
                .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(prescriptions)
        await sut.send(.task) {
            // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`,
            // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
            $0.$prescriptions.withLock { $0 = prescriptions }
            $0.serviceOptionState.$prescriptions.withLock { $0 = prescriptions }
        }
        // then no state change occurs (default is no service)
        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected))) {
            $0.$prescriptions.withLock { $0 = prescriptions }
            $0.hasRedeemableTasks = true
        }

        await sut.receive(.response(.redeemOptionProviderReceived(
            RedeemOptionProvider(wasAuthenticatedBefore: false, pharmacy: pharmacyModel.pharmacyLocation)
        ))) {
            $0.serviceOptionState.redeemOptionProvider = RedeemOptionProvider(
                wasAuthenticatedBefore: false,
                pharmacy: pharmacyModel.pharmacyLocation
            )
        }

        // then redeem does not present something
        await sut.send(.serviceOption(.redeemOptionTapped(.onPremise)))
        await sut.receive(.delegate(.redeem(
            prescriptions: prescriptions,
            selectedPrescriptions: [],
            pharmacy: pharmacyModel.pharmacyLocation,
            option: .onPremise
        )))
        await sut.send(.serviceOption(.redeemOptionTapped(.shipment)))
        await sut.receive(.delegate(.redeem(
            prescriptions: prescriptions,
            selectedPrescriptions: [],
            pharmacy: pharmacyModel.pharmacyLocation,
            option: .shipment
        )))
        await sut.send(.serviceOption(.redeemOptionTapped(.delivery)))
        await sut.receive(.delegate(.redeem(
            prescriptions: prescriptions,
            selectedPrescriptions: [],
            pharmacy: pharmacyModel.pharmacyLocation,
            option: .delivery
        )))
    }

    func testRedeemOptionWithPharmacyWithoutServicesAndLoggedInBefore() async {
        // Given a pharmacy without any services
        let pharmacyModel = noServicePharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared(value: []),
            selectedPrescriptions: Shared(value: []),
            inRedeemProcess: false,
            pharmacyViewModel: pharmacyModel
        ))
        // and a profile that has been logged in before (== insuranceID not nil)
        let profile = Profile(name: "Test", insuranceId: "loggedIn", erxTasks: ErxTask.Fixtures.erxTasks)
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        let prescriptions = Prescription.Fixtures.prescriptions.filter(\.isRedeemable)
        mockPrescriptionRepository
            .loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorReturnValue =
            Just(prescriptions)
                .setFailureType(to: PrescriptionRepositoryError.self)
                .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(prescriptions)
        await sut.send(.task) {
            // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`,
            // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
            $0.$prescriptions.withLock { $0 = prescriptions }
            $0.serviceOptionState.$prescriptions.withLock { $0 = prescriptions }
        }
        // then no state change occurs (default is no service)
        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected))) {
            $0.$prescriptions.withLock { $0 = prescriptions }
            $0.hasRedeemableTasks = true
        }

        await sut.receive(.response(.redeemOptionProviderReceived(
            RedeemOptionProvider(wasAuthenticatedBefore: true, pharmacy: pharmacyModel.pharmacyLocation)
        ))) {
            $0.serviceOptionState.redeemOptionProvider = RedeemOptionProvider(
                wasAuthenticatedBefore: true,
                pharmacy: pharmacyModel.pharmacyLocation
            )
        }

        // then redeem does not present something
        await sut.send(.serviceOption(.redeemOptionTapped(.onPremise)))
        await sut.receive(.delegate(.redeem(
            prescriptions: prescriptions,
            selectedPrescriptions: [],
            pharmacy: pharmacyModel.pharmacyLocation,
            option: .onPremise
        )))
        await sut.send(.serviceOption(.redeemOptionTapped(.shipment)))
        await sut.receive(.delegate(.redeem(
            prescriptions: prescriptions,
            selectedPrescriptions: [],
            pharmacy: pharmacyModel.pharmacyLocation,
            option: .shipment
        )))
        await sut.send(.serviceOption(.redeemOptionTapped(.delivery)))
        await sut.receive(.delegate(.redeem(
            prescriptions: prescriptions,
            selectedPrescriptions: [],
            pharmacy: pharmacyModel.pharmacyLocation,
            option: .delivery
        )))
    }

    func testTogglingFavoriteState_Success() async {
        var calledCount = 0
        await withDependencies {
            $0.pharmacyRepository.saveMultiple = { _ in true }
        } operation: {
            let sut = testStore(for: PharmacyDetailDomain.State(
                prescriptions: Shared(value: []),
                selectedPrescriptions: Shared(value: []),
                inRedeemProcess: false,
                pharmacyViewModel: PharmacyLocationViewModel.Fixtures.pharmacyA
            )) { dependencies in
                dependencies.hapticFeedbackGenerator.success = {
                    calledCount += 1
                }
            }

            var expectedResult = PharmacyLocationViewModel.Fixtures.pharmacyA
            expectedResult.pharmacyLocation.isFavorite.toggle()

            await sut.send(.toggleIsFavorite)
            await sut.receive(.response(.toggleIsFavoriteReceived(.success(expectedResult)))) {
                $0.pharmacyViewModel = expectedResult
            }

            expect(calledCount).to(equal(1))

            await sut.send(.toggleIsFavorite)
            await sut
                .receive(.response(.toggleIsFavoriteReceived(.success(PharmacyLocationViewModel.Fixtures.pharmacyA)))) {
                    $0.pharmacyViewModel = PharmacyLocationViewModel.Fixtures.pharmacyA
                }

            expect(calledCount).to(equal(2))
        }
    }

    func testSetFavoriteStateTrue() async {
        var calledCount = 0
        await withDependencies {
            $0.pharmacyRepository.saveMultiple = { _ in true }
        } operation: {
            let sut = testStore(for: PharmacyDetailDomain.State(
                prescriptions: Shared(value: []),
                selectedPrescriptions: Shared(value: []),
                inRedeemProcess: false,
                pharmacyViewModel: PharmacyLocationViewModel.Fixtures.pharmacyA
            )) { dependencies in
                dependencies.hapticFeedbackGenerator.success = {
                    calledCount += 1
                }
            }

            var expectedResult = PharmacyLocationViewModel.Fixtures.pharmacyA
            expectedResult.pharmacyLocation.isFavorite.toggle()

            await sut.send(.setIsFavorite(true))
            await sut.receive(.response(.toggleIsFavoriteReceived(.success(expectedResult)))) {
                $0.pharmacyViewModel = expectedResult
            }

            expect(calledCount).to(equal(1))

            await sut.send(.setIsFavorite(true))
            expect(calledCount).to(equal(2))

            await sut.send(.setIsFavorite(false))
            await sut
                .receive(.response(.toggleIsFavoriteReceived(.success(PharmacyLocationViewModel.Fixtures.pharmacyA)))) {
                    $0.pharmacyViewModel = PharmacyLocationViewModel.Fixtures.pharmacyA
                }
            expect(calledCount).to(equal(3))
        }
    }

    func testTogglingFavoriteState_Failure() async {
        let error = PharmacyRepositoryError.local(.write(error: PharmacyCoreDataStore.Error.noMatchingEntity))
        await withDependencies {
            $0.pharmacyRepository.saveMultiple = { _ in throw error }
        } operation: {
            let sut = testStore(for: PharmacyDetailDomain.State(
                prescriptions: Shared(value: []),
                selectedPrescriptions: Shared(value: []),
                inRedeemProcess: false,
                pharmacyViewModel: PharmacyLocationViewModel.Fixtures.pharmacyA
            ))

            let expectedError = PharmacyRepositoryError
                .local(.write(error: PharmacyCoreDataStore.Error.noMatchingEntity))

            var expectedResult = PharmacyLocationViewModel.Fixtures.pharmacyA
            expectedResult.pharmacyLocation.isFavorite.toggle()

            await sut.send(.toggleIsFavorite)
            await sut.receive(.response(.toggleIsFavoriteReceived(.failure(expectedError)))) {
                $0.destination = .alert(.init(for: expectedError))
            }
        }
    }

    func testNoErxTask() async {
        // Given a pharmacy without any services
        let pharmacyModel = noServicePharmacy
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared(value: []),
            selectedPrescriptions: Shared(value: []),
            inRedeemProcess: false,
            pharmacyViewModel: pharmacyModel
        ))
        // and a profile that has been logged in before (== insuranceID not nil)
        let profile = Profile(name: "Test", insuranceId: nil)
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
        mockPrescriptionRepository
            .loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorReturnValue = Just([])
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success([])
        await sut.send(.task)
        // then no state change occurs (default is no service)
        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))
        // then redeem does not present something
        await sut.receive(.response(.redeemOptionProviderReceived(
            RedeemOptionProvider(wasAuthenticatedBefore: false, pharmacy: pharmacyModel.pharmacyLocation)
        ))) {
            $0.serviceOptionState.redeemOptionProvider = RedeemOptionProvider(
                wasAuthenticatedBefore: false,
                pharmacy: pharmacyModel.pharmacyLocation
            )
        }
        await sut.send(.serviceOption(.redeemOptionTapped(.onPremise))) {
            $0.serviceOptionState.selectedOption = .onPremise
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
                prescriptions: Shared(value: []),
                selectedPrescriptions: Shared(value: []),
                inRedeemProcess: false,
                pharmacyViewModel: pharmacyModel
            ))

            // and a profile that has been logged in before (== insuranceID non nil)
            let profile = Profile(name: "Test")
            mockUserSession.profileReturnValue = Just(profile)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()

            let expectedPrescription = Prescription(
                erxTask: ErxTask.Fixtures.erxTask1,
                date: TestDate.defaultReferenceDate
            )
            let nonReadyPrescriptions = [
                Prescription(
                    erxTask: ErxTask.Fixtures.erxTask9,
                    date: TestDate.defaultReferenceDate
                ),
                Prescription(
                    erxTask: ErxTask.Fixtures.erxTask10,
                    date: TestDate.defaultReferenceDate
                ),
                Prescription(
                    erxTask: ErxTask.Fixtures.erxTask11,
                    date: TestDate.defaultReferenceDate
                ),
            ]

            let prescriptions = nonReadyPrescriptions + [expectedPrescription]

            mockPrescriptionRepository
                .loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorReturnValue =
                Just(prescriptions)
                    .setFailureType(to: PrescriptionRepositoryError.self)
                    .eraseToAnyPublisher()
            await sut.send(.task) {
                // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`
                // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
                $0.$prescriptions.withLock { $0 = [expectedPrescription] }
                $0.serviceOptionState.$prescriptions.withLock { $0 = [expectedPrescription] }
            }

            await sut.receive(.response(.loadLocalPrescriptionsReceived(.success(prescriptions)))) {
                $0.$prescriptions.withLock { $0 = [expectedPrescription] }
                $0.hasRedeemableTasks = true
            }

            await sut.receive(.response(.redeemOptionProviderReceived(
                RedeemOptionProvider(wasAuthenticatedBefore: false, pharmacy: pharmacyModel.pharmacyLocation)
            ))) {
                $0.serviceOptionState.availableOptions = [.onPremise, .delivery, .shipment]
                $0.serviceOptionState.validOptions = [.delivery, .onPremise, .shipment]
                $0.serviceOptionState.redeemOptionProvider = RedeemOptionProvider(
                    wasAuthenticatedBefore: false,
                    pharmacy: pharmacyModel.pharmacyLocation
                )
            }
        }
    }

    func testInRedeemProcessWithSelectedPrescription() async {
        // Given a pharmacy with all avs and ErxTaskRepository services
        let pharmacyModel = allServicesPharmacy
        let selectedPrescriptions = [Prescription.Dummies.prescriptionMVO]
        let sut = testStore(for: PharmacyDetailDomain.State(
            prescriptions: Shared<[Prescription]>(value: []),
            selectedPrescriptions: Shared(value: selectedPrescriptions),
            inRedeemProcess: true,
            pharmacyViewModel: pharmacyModel
        ))

        let profile = Profile(name: "Test")
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        let prescriptions = [Prescription.Dummies.prescriptionReady, Prescription.Dummies.scanned]

        mockPrescriptionRepository
            .loadLocalForProfileIdUUIDAnyPublisherPrescriptionPrescriptionRepositoryErrorReturnValue =
            Just(prescriptions)
                .setFailureType(to: PrescriptionRepositoryError.self)
                .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(prescriptions)
        await sut.send(.task) {
            // technically this should happen on `sut.receive(.response(.loadLocalPrescriptionsReceived(expected)))`
            // due to shared state the test snapshot is wrong here, this might get fixed within TCA in the future?
            $0.$prescriptions.withLock { $0 = prescriptions }
            $0.serviceOptionState.$prescriptions.withLock { $0 = prescriptions }
        }

        await sut.receive(.response(.loadLocalPrescriptionsReceived(expected))) {
            $0.$prescriptions.withLock { $0 = prescriptions }
            $0.hasRedeemableTasks = true
        }

        await sut.receive(.response(.redeemOptionProviderReceived(
            RedeemOptionProvider(wasAuthenticatedBefore: false, pharmacy: pharmacyModel.pharmacyLocation)
        ))) {
            $0.serviceOptionState.availableOptions = [.delivery, .onPremise, .shipment]
            $0.serviceOptionState.validOptions = [.delivery, .onPremise, .shipment]
            $0.serviceOptionState.redeemOptionProvider = RedeemOptionProvider(
                wasAuthenticatedBefore: false,
                pharmacy: pharmacyModel.pharmacyLocation
            )
        }

        await sut.send(.serviceOption(.redeemOptionTapped(.delivery)))

        await sut.receive(.delegate(.redeem(
            prescriptions: prescriptions,
            selectedPrescriptions: selectedPrescriptions,
            pharmacy: pharmacyModel.pharmacyLocation,
            option: .delivery
        )))
    }
}
