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
import ComposableCoreLocation
@testable import eRpFeatures
import eRpKit
import MapKit
import Nimble
import Pharmacy
import XCTest

@MainActor
class PharmacySearchMapDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = TestStoreOf<PharmacySearchMapDomain>

    var resourceHandlerMock: MockResourceHandler!
    var searchHistoryMock: SearchHistoryMock!
    var mockUserSession: MockUserSession!
    var mockRedeemService: MockRedeemService!
    var mockPrescriptionRepository: MockPrescriptionRepository!

    override func setUp() {
        super.setUp()

        resourceHandlerMock = MockResourceHandler()
        searchHistoryMock = SearchHistoryMock()
        mockUserSession = MockUserSession()
        mockRedeemService = MockRedeemService()
        mockPrescriptionRepository = MockPrescriptionRepository()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testStore(
        for state: PharmacySearchMapDomain.State,
        pharmacyRepository: PharmacyRepository = MockPharmacyRepository()
    ) -> TestStore {
        TestStore(initialState: state) {
            PharmacySearchMapDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
            dependencies.pharmacyRepository = pharmacyRepository
            dependencies.locationManager = .failing
            dependencies.resourceHandler = resourceHandlerMock
            dependencies.dateProvider = { TestData.openHoursTestReferenceDate! }
            dependencies.userSession = mockUserSession
            dependencies.feedbackReceiver = MockFeedbackReceiver()
            dependencies.prescriptionRepository = mockPrescriptionRepository
            dependencies.redeemOrderService.redeemViaAVS = { @Sendable [mockRedeemService] orders in
                try await mockRedeemService?.redeem(orders).async() ?? []
            }
            dependencies.redeemOrderService.redeemViaErxTaskRepository = { @Sendable [mockRedeemService] orders in
                try await mockRedeemService?.redeem(orders).async() ?? []
            }
            dependencies.date = DateGenerator.constant(Date.now)
            dependencies.calendar = Calendar.autoupdatingCurrent
        }
    }

    func testSearchForPharmacies() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo
            .searchRemoteSearchTermPositionFilterReturnValue = Just(TestData.pharmaciesWithLocations)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let sut = testStore(for: TestData.stateWithNoLocation, pharmacyRepository: mockPharmacyRepo)
        let expectedLocation =
            Location(rawValue: CLLocation(latitude: MKCoordinateRegion.gematikHQRegion.center.latitude,
                                          longitude: MKCoordinateRegion.gematikHQRegion.center.longitude))

        let expected: Result<[PharmacyLocation], PharmacyRepositoryError> = .success(TestData.pharmaciesWithLocations)

        await sut.send(.performSearch)
        await testScheduler.advance()
        await sut.receive(.response(.pharmaciesReceived(expected, expectedLocation.coordinate))) { state in
            state.mapLocation = .manual(MKCoordinateRegion(center: expectedLocation.coordinate,
                                                           span: MKCoordinateSpan(
                                                               latitudeDelta: 5.991751000000008,
                                                               longitudeDelta: 9.841382800000005
                                                           )))
        }

        expect(mockPharmacyRepo.searchRemoteSearchTermPositionFilterReceivedArguments?.searchTerm)
            .to(equal("Adler"))
    }

    func test_FirstOpenAndAllowingLocation() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo
            .searchRemoteSearchTermPositionFilterReturnValue = Just(TestData.pharmaciesWithLocations)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let sut = testStore(for: TestData.stateWithLocation, pharmacyRepository: mockPharmacyRepo)
        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
        sut.dependencies.locationManager.authorizationStatus = { .notDetermined }
        sut.dependencies.locationManager.delegate = {
            AsyncStream { continuation in
                let cancellable = locationManagerSubject.sink { continuation.yield($0) }
                continuation.onTermination = { _ in
                    cancellable.cancel()
                }
            }
        }
        sut.dependencies.locationManager.locationServicesEnabled = { true }

        sut.dependencies.locationManager.requestWhenInUseAuthorization = {}
        sut.dependencies.locationManager.startUpdatingLocation = {}
        sut.dependencies.locationManager.stopUpdatingLocation = {}
        sut.dependencies.locationManager.requestLocation = {}
        let expected: Result<[PharmacyLocation], PharmacyRepositoryError> = .success(TestData.pharmaciesWithLocations)
        let expectedLocation = TestData.testLocation

        let onAppear = await sut.send(.onAppear)
        await sut.receive(.quickSearch(filters: []))
        await sut.receive(.searchWithMap)
        await sut.receive(.requestLocation) { state in
            state.currentUserLocation = nil
        }

        locationManagerSubject.send(.didChangeAuthorization(.authorizedWhenInUse))
        await sut.receive(.locationManager(.didChangeAuthorization(.authorizedWhenInUse))) { state in
            state.searchAfterAuthorized = true
        }
        sut.dependencies.locationManager.authorizationStatus = { .authorizedAlways }
        locationManagerSubject.send(completion: .finished)

        await testScheduler.advance()
        await sut.receive(.response(.pharmaciesReceived(expected, expectedLocation.coordinate)))

        locationManagerSubject.send(.didUpdateLocations([expectedLocation]))
        await sut.send(.locationManager(.didUpdateLocations([expectedLocation]))) { state in
            state.currentUserLocation = expectedLocation
        }
        locationManagerSubject.send(completion: .finished)

        await sut.receive(.setMapAfterLocationUpdate) { state in
            state.searchAfterAuthorized = false
        }

        await testScheduler.advance()

        await sut.receive(.response(.pharmaciesReceived(expected, expectedLocation.coordinate)))

        await sut.send(.goToUser) { state in
            state.$pharmacyFilterOptions.withLock { $0 = [.currentLocation] }
        }

        await sut.receive(.quickSearch(filters: [.currentLocation]))

        await testScheduler.advance()

        await sut.receive(.response(.pharmaciesReceived(expected, expectedLocation.coordinate)))

        await onAppear.cancel()
    }

    func test_AlreadyAllowingLocation() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo
            .searchRemoteSearchTermPositionFilterReturnValue = Just(TestData.pharmaciesWithLocations)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let sut = testStore(for: TestData.stateWithLocation, pharmacyRepository: mockPharmacyRepo)
        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
        sut.dependencies.locationManager.authorizationStatus = { .authorizedAlways }
        sut.dependencies.locationManager.delegate = {
            AsyncStream { continuation in
                let cancellable = locationManagerSubject.sink { continuation.yield($0) }
                continuation.onTermination = { _ in
                    cancellable.cancel()
                }
            }
        }
        sut.dependencies.locationManager.requestWhenInUseAuthorization = {}
        let expected: Result<[PharmacyLocation], PharmacyRepositoryError> = .success(TestData.pharmaciesWithLocations)
        let expectedLocation = TestData.testLocation
        sut.dependencies.locationManager.location = { expectedLocation }

        let onAppear = await sut.send(.onAppear)
        locationManagerSubject.send(completion: .finished)
        await sut.receive(.quickSearch(filters: []))
        await sut.receive(.searchWithMap)

        await testScheduler.advance()

        await sut.receive(.response(.pharmaciesReceived(expected, expectedLocation.coordinate)))

        await testScheduler.advance()

        await sut.send(.performSearch)

        await sut.send(.goToUser) { state in
            state.$pharmacyFilterOptions.withLock { $0 = [.currentLocation] }
        }

        await sut.receive(.quickSearch(filters: [.currentLocation]))

        await testScheduler.advance()

        await sut.receive(.response(.pharmaciesReceived(expected, expectedLocation.coordinate)))
        await sut.receive(.response(.pharmaciesReceived(expected, expectedLocation.coordinate)))

        await onAppear.cancel()
    }

    func test_FirstOpenAndDeniedLocation() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo
            .searchRemoteSearchTermPositionFilterReturnValue = Just(TestData.pharmaciesWithLocations)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let sut = testStore(for: TestData.stateWithNoLocation, pharmacyRepository: mockPharmacyRepo)
        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
        sut.dependencies.locationManager.authorizationStatus = { .notDetermined }
        sut.dependencies.locationManager.requestWhenInUseAuthorization = {}
        sut.dependencies.locationManager.locationServicesEnabled = { true }
        sut.dependencies.locationManager.delegate = {
            AsyncStream { continuation in
                let cancellable = locationManagerSubject.sink { continuation.yield($0) }
                continuation.onTermination = { _ in
                    cancellable.cancel()
                }
            }
        }
        let expected: Result<[PharmacyLocation], PharmacyRepositoryError> = .success(TestData.pharmaciesWithLocations)
        let expectedLocation = Location(rawValue:
            CLLocation(latitude: MKCoordinateRegion.gematikHQRegion.center.latitude,
                       longitude: MKCoordinateRegion.gematikHQRegion.center.longitude))

        let onAppear = await sut.send(.onAppear)
        await sut.receive(.quickSearch(filters: []))
        await sut.receive(.searchWithMap)
        await sut.receive(.requestLocation)

        locationManagerSubject.send(.didChangeAuthorization(.denied))
        await sut.receive(.locationManager(.didChangeAuthorization(.denied))) { state in
            state.destination = .alert(PharmacySearchMapDomain.locationPermissionAlertState)
        }
        sut.dependencies.locationManager.authorizationStatus = { .denied }
        locationManagerSubject.send(completion: .finished)

        await sut.send(.destination(.presented(.alert(.close)))) { state in
            state.destination = nil
        }

        await sut.send(.goToUser)

        await sut.receive(.requestLocation)

        await sut.receive(.setAlert(PharmacySearchMapDomain.locationPermissionAlertState)) { state in
            state.destination = .alert(PharmacySearchMapDomain.locationPermissionAlertState)
        }

        await sut.send(.performSearch)

        await testScheduler.advance()

        await sut.receive(.response(.pharmaciesReceived(expected, expectedLocation.coordinate))) { state in
            state.mapLocation = .manual(MKCoordinateRegion(center: state.mapLocation.region.center,
                                                           span: MKCoordinateSpan(
                                                               latitudeDelta: 5.991751000000008,
                                                               longitudeDelta: 9.841382800000005
                                                           )))
        }

        await sut.receive(.response(.pharmaciesReceived(expected, expectedLocation.coordinate)))

        await onAppear.cancel()
    }

    func test_AlreadyDeniedLocation() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo
            .searchRemoteSearchTermPositionFilterReturnValue = Just(TestData.pharmaciesWithLocations)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let sut = testStore(for: TestData.stateWithNoLocation, pharmacyRepository: mockPharmacyRepo)
        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
        sut.dependencies.locationManager.authorizationStatus = { .denied }
        sut.dependencies.locationManager.locationServicesEnabled = { true }
        sut.dependencies.locationManager.delegate = {
            AsyncStream { continuation in
                let cancellable = locationManagerSubject.sink { continuation.yield($0) }
                continuation.onTermination = { _ in
                    cancellable.cancel()
                }
            }
        }
        let expected: Result<[PharmacyLocation], PharmacyRepositoryError> = .success(TestData.pharmaciesWithLocations)
        let expectedLocation = Location(rawValue:
            CLLocation(latitude: MKCoordinateRegion.gematikHQRegion.center.latitude,
                       longitude: MKCoordinateRegion.gematikHQRegion.center.longitude))

        let onAppear = await sut.send(.onAppear)
        locationManagerSubject.send(completion: .finished)
        await sut.receive(.quickSearch(filters: []))
        await sut.receive(.searchWithMap)

        await testScheduler.advance()

        await sut.receive(.response(.pharmaciesReceived(expected, expectedLocation.coordinate))) { state in
            state.mapLocation = .manual(MKCoordinateRegion(center: state.mapLocation.region.center,
                                                           span: MKCoordinateSpan(
                                                               latitudeDelta: 5.991751000000008,
                                                               longitudeDelta: 9.841382800000005
                                                           )))
        }

        await sut.send(.goToUser)

        await sut.receive(.requestLocation)

        await sut.receive(.setAlert(PharmacySearchMapDomain.locationPermissionAlertState)) { state in
            state.destination = .alert(PharmacySearchMapDomain.locationPermissionAlertState)
        }

        await onAppear.cancel()
    }

    func test_FilterTapedSearch() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo
            .searchRemoteSearchTermPositionFilterReturnValue = Just(TestData.pharmaciesWithLocations)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let sut = testStore(for: TestData.stateWithLocation, pharmacyRepository: mockPharmacyRepo)
        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
        sut.dependencies.locationManager.authorizationStatus = { .authorizedAlways }
        sut.dependencies.locationManager.delegate = {
            AsyncStream { continuation in
                let cancellable = locationManagerSubject.sink { continuation.yield($0) }
                continuation.onTermination = { _ in
                    cancellable.cancel()
                }
            }
        }
        let expected: Result<[PharmacyLocation], PharmacyRepositoryError> = .success(TestData.pharmaciesWithLocations)

        let onAppear = await sut.send(.onAppear)
        await sut.receive(.quickSearch(filters: []))
        await sut.receive(.searchWithMap)

        await testScheduler.run()

        await sut.receive(.response(.pharmaciesReceived(expected, TestData.testLocation.coordinate)))

        await sut.send(.showPharmacyFilter) { state in
            state.destination = .filter(.init(
                pharmacyFilterOptions: state.$pharmacyFilterOptions,
                pharmacyFilterShow: [.open, .delivery, .shipment, .currentLocation]
            ))
        }

        await sut.send(.destination(.presented(.filter(.toggleFilter(.delivery))))) { state in
            state.$pharmacyFilterOptions.withLock { $0 = [.delivery] }
        }

        await testScheduler.run()

        await sut.receive(\.quickSearch, [.delivery])

        await sut.receive(\.response.pharmaciesReceived)

        await onAppear.cancel()
    }

    func testRedeemPharmacyChangePharmacyMap() async {
        let inputTask = [Prescription.Dummies.prescriptionReady]

        let oldPharmacy = PharmacyLocationViewModel(
            pharmacy: TestData.pharmacy1,
            referenceDate: TestData.openHoursTestReferenceDate
        )
        let newPharmacy = PharmacyLocationViewModel(
            pharmacy: TestData.pharmacy2,
            referenceDate: TestData.openHoursTestReferenceDate
        )
        let mockPharmacyRepo = MockPharmacyRepository()

        mockPharmacyRepo.updateFromRemoteByReturnValue = Just(newPharmacy.pharmacyLocation)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let profile = Profile(name: "Test", insuranceId: nil, erxTasks: [ErxTask.Fixtures.erxTaskReady])
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        mockPrescriptionRepository.loadLocalReturnValue = Just(inputTask)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(inputTask)

        let sut = testStore(for: TestData.stateWithLocation, pharmacyRepository: mockPharmacyRepo)

        await sut.send(.showDetails(oldPharmacy)) {
            $0.destination = .pharmacy(PharmacyDetailDomain.State(
                prescriptions: Shared(value: []),
                selectedPrescriptions: Shared(value: []),
                inRedeemProcess: false,
                pharmacyViewModel: oldPharmacy,
                onMapView: true
            ))
        }

        await sut.send(.destination(.presented(.pharmacy(.task))))

        await testScheduler.run()

        await sut.receive(.destination(.presented(.pharmacy(.response(.redeemOptionProviderReceived(
            RedeemOptionProvider(wasAuthenticatedBefore: false, pharmacy: oldPharmacy.pharmacyLocation)
        )))))) {
            $0.destination = .pharmacy(.init(
                prescriptions: Shared(value: []),
                selectedPrescriptions: Shared(value: []),
                inRedeemProcess: false,
                pharmacyViewModel: oldPharmacy,
                hasRedeemableTasks: false,
                availableServiceOptions: [.onPremise, .shipment],
                onMapView: true,
                serviceOptionState: ServiceOptionDomain.State(
                    prescriptions: Shared(value: []),
                    selectedOption: .none,
                    availableOptions: [.onPremise, .shipment],
                    redeemOptionProvider: RedeemOptionProvider(
                        wasAuthenticatedBefore: false,
                        pharmacy: oldPharmacy.pharmacyLocation
                    )
                )
            ))
        }

        await sut
            .receive(.destination(.presented(.pharmacy(.response(.loadLocalPrescriptionsReceived(expected)))))) {
                $0.destination = .pharmacy(.init(
                    prescriptions: Shared(value: inputTask.filter(\.isRedeemable)),
                    selectedPrescriptions: Shared(value: []),
                    inRedeemProcess: false,
                    pharmacyViewModel: oldPharmacy,
                    hasRedeemableTasks: true,
                    availableServiceOptions: [.onPremise, .shipment],
                    onMapView: true,
                    serviceOptionState: ServiceOptionDomain.State(
                        prescriptions: Shared(value: inputTask.filter(\.isRedeemable)),
                        selectedOption: .none,
                        availableOptions: [.onPremise, .shipment],
                        redeemOptionProvider: RedeemOptionProvider(
                            wasAuthenticatedBefore: false,
                            pharmacy: oldPharmacy.pharmacyLocation
                        )
                    )
                ))
            }

        await sut.send(.destination(.presented(.pharmacy(.serviceOption(.redeemOptionTapped(.onPremise))))))

        await sut.receive(.destination(.presented(.pharmacy(.delegate(.redeem(
            prescriptions: inputTask.filter(\.isRedeemable),
            selectedPrescriptions: [],
            pharmacy: oldPharmacy.pharmacyLocation,
            option: .onPremise
        ))))))

        await sut.send(.showDetails(newPharmacy)) {
            $0.destination = .pharmacy(PharmacyDetailDomain.State(
                prescriptions: Shared(value: []),
                selectedPrescriptions: Shared(value: []),
                inRedeemProcess: false,
                pharmacyViewModel: newPharmacy,
                onMapView: true
            ))
        }

        await sut.send(.destination(.presented(.pharmacy(.task))))

        await testScheduler.run()

        await sut.receive(.destination(.presented(.pharmacy(.response(.redeemOptionProviderReceived(
            RedeemOptionProvider(wasAuthenticatedBefore: false, pharmacy: newPharmacy.pharmacyLocation)
        )))))) {
            $0.destination = .pharmacy(.init(
                prescriptions: Shared(value: []),
                selectedPrescriptions: Shared(value: []),
                inRedeemProcess: false,
                pharmacyViewModel: newPharmacy,
                hasRedeemableTasks: false,
                availableServiceOptions: [.onPremise],
                onMapView: true,
                serviceOptionState: ServiceOptionDomain.State(
                    prescriptions: Shared(value: []),
                    selectedOption: .none,
                    availableOptions: [.onPremise],
                    redeemOptionProvider: RedeemOptionProvider(
                        wasAuthenticatedBefore: false,
                        pharmacy: newPharmacy.pharmacyLocation
                    )
                )
            ))
        }

        await sut
            .receive(.destination(.presented(.pharmacy(.response(.loadLocalPrescriptionsReceived(expected)))))) {
                $0.destination = .pharmacy(.init(
                    prescriptions: Shared(value: inputTask.filter(\.isRedeemable)),
                    selectedPrescriptions: Shared(value: []),
                    inRedeemProcess: false,
                    pharmacyViewModel: newPharmacy,
                    hasRedeemableTasks: true,
                    availableServiceOptions: [.onPremise],
                    onMapView: true,
                    serviceOptionState: ServiceOptionDomain.State(
                        prescriptions: Shared(value: inputTask.filter(\.isRedeemable)),
                        selectedOption: .none,
                        availableOptions: [.onPremise],
                        redeemOptionProvider: RedeemOptionProvider(
                            wasAuthenticatedBefore: false,
                            pharmacy: newPharmacy.pharmacyLocation
                        )
                    )
                ))
            }

        await sut.send(.destination(.presented(.pharmacy(.serviceOption(.redeemOptionTapped(.onPremise))))))

        await sut.receive(.destination(.presented(.pharmacy(.delegate(.redeem(
            prescriptions: inputTask.filter(\.isRedeemable),
            selectedPrescriptions: [],
            pharmacy: newPharmacy.pharmacyLocation,
            option: .onPremise
        ))))))
    }

    func testUpdatePharmacyFavoriteInSearch() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo.savePharmaciesReturnValue = Just(true).setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()
        let testPharmacy = PharmacyLocationViewModel(
            pharmacy: TestData.pharmacy3,
            referenceDate: TestData.openHoursTestReferenceDate
        )
        let expectedPharmacy = PharmacyLocationViewModel(
            pharmacy: PharmacyLocation(
                id: TestData.pharmacy3.id,
                status: TestData.pharmacy3.status,
                telematikID: TestData.pharmacy3.telematikID,
                created: TestData.pharmacy3.created,
                name: TestData.pharmacy3.name,
                types: TestData.pharmacy3.types,
                address: TestData.pharmacy3.address,
                telecom: TestData.pharmacy3.telecom,
                isFavorite: true,
                hoursOfOperation: []
            ),
            referenceDate: TestData.openHoursTestReferenceDate
        )
        let expectedPharmacies = [TestData.pharmacy1, TestData.pharmacy2, expectedPharmacy.pharmacyLocation]
        let testPharmacies = [TestData.pharmacy1, TestData.pharmacy2, TestData.pharmacy3]

        let sut = testStore(for: .init(selectedPrescriptions: Shared(value: []),
                                       inRedeemProcess: false,
                                       mapLocation: .manual(MKCoordinateRegion.gematikHQRegion),
                                       pharmacies: testPharmacies.map { pharmacies in
                                           PharmacyLocationViewModel(
                                               pharmacy: pharmacies,
                                               referenceLocation: TestData.testLocation,
                                               referenceDate: TestData.openHoursTestReferenceDate
                                           )
                                       }),
                            pharmacyRepository: mockPharmacyRepo)

        await sut.send(.showDetails(testPharmacy)) { state in
            state.destination = .pharmacy(.init(
                prescriptions: Shared(value: []),
                selectedPrescriptions: Shared(value: []),
                inRedeemProcess: false,
                pharmacyViewModel: testPharmacy,
                onMapView: true
            ))
        }

        await sut.send(.destination(.presented(.pharmacy(.toggleIsFavorite))))

        await testScheduler.run()

        await sut.receive(.destination(.presented(
            .pharmacy(.response(.toggleIsFavoriteReceived(.success(expectedPharmacy))))
        ))) { state in
            state.pharmacies = expectedPharmacies.map { pharmacies in
                PharmacyLocationViewModel(
                    pharmacy: pharmacies,
                    referenceLocation: TestData.testLocation,
                    referenceDate: TestData.openHoursTestReferenceDate
                )
            }
            state.destination = .pharmacy(.init(
                prescriptions: Shared(value: []),
                selectedPrescriptions: Shared(value: []),
                inRedeemProcess: false,
                pharmacyViewModel: expectedPharmacy,
                onMapView: true
            ))
        }

        await sut.send(.destination(.dismiss)) { state in
            state.destination = nil
        }

        await testScheduler.run()

        await sut.send(.showDetails(expectedPharmacy)) { state in
            state.destination = .pharmacy(.init(
                prescriptions: Shared(value: []),
                selectedPrescriptions: Shared(value: []),
                inRedeemProcess: false,
                pharmacyViewModel: expectedPharmacy,
                onMapView: true
            ))
        }
    }

    func testSearchInRedeemProcessToDetails() async {
        let prescriptions = Prescription.Fixtures.prescriptions

        let pharmacy = PharmacyLocationViewModel(
            pharmacy: TestData.pharmacy1,
            referenceDate: TestData.openHoursTestReferenceDate
        )

        let mockPharmacyRepo = MockPharmacyRepository()

        let sut = testStore(for: PharmacySearchMapDomain.State(
            selectedPrescriptions: Shared(value: prescriptions),
            inRedeemProcess: true,
            currentUserLocation: TestData.testLocation,
            mapLocation: .manual(.init(center: TestData.testLocation.coordinate,
                                       span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))),
            pharmacies: TestData.pharmaciesWithLocations.map { pharmacies in
                PharmacyLocationViewModel(
                    pharmacy: pharmacies,
                    referenceLocation: TestData.testLocation,
                    referenceDate: TestData.openHoursTestReferenceDate
                )
            }
        ), pharmacyRepository: mockPharmacyRepo)

        await sut.send(.showDetails(pharmacy)) {
            $0.destination = .pharmacy(PharmacyDetailDomain.State(
                prescriptions: Shared(value: []),
                selectedPrescriptions: $0.$selectedPrescriptions,
                inRedeemProcess: true,
                pharmacyViewModel: pharmacy,
                hasRedeemableTasks: true,
                onMapView: true
            ))
        }
    }
}

extension PharmacySearchMapDomainTests {
    /// Test-Data values for `PharmacyLocation`
    public enum TestData {
        /// Test-Date for opening/closing state
        public static var openHoursTestReferenceDate: Date? {
            // Current dummy-time is set to 10:00am on 16th (WED) June 2021...
            var dateComponents = DateComponents()
            dateComponents.year = 2021
            dateComponents.month = 6
            dateComponents.day = 16
            dateComponents.timeZone = TimeZone.current
            dateComponents.hour = 10
            dateComponents.minute = 00
            let cal = Calendar(identifier: .gregorian)
            return cal.date(from: dateComponents)
        }

        /// Test-Data PharmacyDomain.State
        public static let stateWithNoLocation =
            PharmacySearchMapDomain.State(
                selectedPrescriptions: Shared(value: []),
                inRedeemProcess: false,
                currentUserLocation: nil,
                mapLocation: .manual(MKCoordinateRegion.gematikHQRegion),
                pharmacies: pharmaciesWithLocations.map { pharmacies in
                    PharmacyLocationViewModel(
                        pharmacy: pharmacies,
                        referenceLocation: Location(rawValue: CLLocation(latitude: MKCoordinateRegion.gematikHQRegion
                                .center.latitude,
                            longitude: MKCoordinateRegion.gematikHQRegion
                                .center.longitude)),
                        referenceDate: TestData.openHoursTestReferenceDate
                    )
                },
                pharmacyFilterOptions: Shared(value: []),
                searchText: "Adler"
            )
        /// Test-Data PharmacyDomain.State
        static var stateWithLocation: PharmacySearchMapDomain.State {
            PharmacySearchMapDomain.State(
                selectedPrescriptions: Shared(value: []),
                inRedeemProcess: false,
                currentUserLocation: TestData.testLocation,
                mapLocation: .manual(.init(center: TestData.testLocation.coordinate,
                                           span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))),
                pharmacies: PharmacySearchMapDomainTests.TestData.pharmaciesWithLocations.map { pharmacies in
                    PharmacyLocationViewModel(
                        pharmacy: pharmacies,
                        referenceLocation: TestData.testLocation,
                        referenceDate: TestData.openHoursTestReferenceDate
                    )
                },
                pharmacyFilterOptions: Shared(value: [])
            )
        }

        /// Test location
        public static let testLocation = Location(
            rawValue: CLLocation(latitude: 49.5270345, longitude: 8.4668786)
        )
        /// Test Maplocation
        public static let testMapLocation = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 49.2470345, longitude: 8.8668786),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        /// Test-Data address
        public static let address1 = PharmacyLocation.Address(
            street: "Hinter der Bahn",
            houseNumber: "6",
            zip: "12345",
            city: "Buxtehude"
        )
        /// Test-Data address
        public static let address2 = PharmacyLocation.Address(
            street: "Meisenweg",
            houseNumber: "23",
            zip: "54321",
            city: "Linsengericht"
        )
        /// Test-Data telecom
        public static let telecom = PharmacyLocation.Telecom(
            phone: "555-Schuh",
            fax: "555-123456",
            email: "info@gematik.de",
            web: "http://www.gematik.de"
        )
        /// Test-Data Pharmacy 1
        public static let pharmacy1 = PharmacyLocation(
            id: "1",
            status: .active,
            telematikID: "3-06.2.ycl.123",
            name: "Apotheke am Wäldchen",
            types: [.pharm, .emergency, .mobl, .outpharm],
            position: PharmacyLocation.Position(
                latitude: Decimal(testLocation.coordinate.latitude),
                longitude: Decimal(testLocation.coordinate.longitude)
            ),
            address: address1,
            telecom: telecom,
            isFavorite: true,
            hoursOfOperation: [
                PharmacyLocation.HoursOfOperation(
                    daysOfWeek: ["mon", "tue"],
                    openingTime: "08:00:00",
                    closingTime: "12:00:00"
                ),
            ]
        )
        /// Test-Data Pharmacy 2
        public static let pharmacy2 = PharmacyLocation(
            id: "2",
            status: .inactive,
            telematikID: "3-09.2.S.10.124",
            name: "Apotheke hinter der Bahn",
            types: [PharmacyLocation.PharmacyType.pharm,
                    PharmacyLocation.PharmacyType.outpharm],
            address: address2,
            telecom: telecom,
            hoursOfOperation: [
                PharmacyLocation.HoursOfOperation(
                    daysOfWeek: ["wed"],
                    openingTime: "08:00:00",
                    closingTime: "12:00:00"
                ),
            ]
        )
        /// Test-Data Pharmacy 3
        public static let pharmacy3 = PharmacyLocation(
            id: "3",
            status: .active,
            telematikID: "3-09.2.sdf.125",
            name: "Apotheke Elise mit langem Vor- und Zunamen am Rathaus",
            types: [PharmacyLocation.PharmacyType.pharm,
                    PharmacyLocation.PharmacyType.mobl],
            address: address1,
            telecom: telecom,
            hoursOfOperation: []
        )
        /// Test-Data Pharmacy 4
        public static let pharmacy4 = PharmacyLocation(
            id: "4",
            status: .inactive,
            telematikID: "3-09.2.dfs.126",
            name: "Eulenapotheke",
            types: [PharmacyLocation.PharmacyType.outpharm],
            address: address2,
            telecom: telecom,
            isFavorite: false,
            hoursOfOperation: [
                PharmacyLocation.HoursOfOperation(
                    daysOfWeek: ["fri"],
                    openingTime: "07:00:00",
                    closingTime: "13:00:00"
                ),
            ]
        )

        /// Test-Data arry of pharmacies
        public static let pharmacies = [
            pharmacy1,
            pharmacy2,
            pharmacy3,
            pharmacy4,
        ]
        /// Test-Data array of pharmacies with a location
        public static let pharmaciesWithLocations = [
            pharmacy1,
        ]
    }
}
