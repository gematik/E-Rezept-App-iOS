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
import ComposableCoreLocation
import Dependencies
@testable import eRpFeatures
import eRpKit
import MapKit
import Nimble
import Pharmacy
import XCTest

@MainActor
class PharmacySearchDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = TestStoreOf<PharmacySearchDomain>

    // For tests we can lower the delay for search start
    var delaySearchStart: DispatchQueue.SchedulerTimeType.Stride = 0.1
    var resourceHandlerMock: MockResourceHandler!
    var searchHistoryMock: MockSearchHistory!
    var mockUserSession: MockUserSession!
    var mockPrescriptionRepository: MockPrescriptionRepository!

    override func setUp() {
        super.setUp()

        mockUserSession = MockUserSession()
        resourceHandlerMock = MockResourceHandler()
        searchHistoryMock = MockSearchHistory()
        mockPrescriptionRepository = MockPrescriptionRepository()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testStore(
        for state: PharmacySearchDomain.State,
        pharmacyRepository: PharmacyRepository = MockPharmacyRepository()
    ) -> TestStore {
        TestStore(initialState: state) {
            PharmacySearchDomain(referenceDateForOpenHours: TestData.openHoursTestReferenceDate)
        } withDependencies: { dependencies in
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
            dependencies.pharmacyRepository = pharmacyRepository
            dependencies.locationManager = .failing
            dependencies.searchHistory = searchHistoryMock
            dependencies.resourceHandler = resourceHandlerMock
            dependencies.feedbackReceiver = MockFeedbackReceiver()
            dependencies.dateProvider = { TestData.openHoursTestReferenceDate! }
            dependencies.userSession = mockUserSession
            dependencies.prescriptionRepository = mockPrescriptionRepository
            dependencies.date = DateGenerator.constant(Date.now)
            dependencies.calendar = Calendar.autoupdatingCurrent
        }
    }

    func testSearchForPharmacies() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo.searchRemoteSearchTermPositionFilterReturnValue = Just(TestData.pharmacies)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let sut = testStore(for: TestData.stateWithStartView, pharmacyRepository: mockPharmacyRepo)
        let testSearchText = "Apo"
        let expected: Result<[PharmacyLocationViewModel], PharmacyRepositoryError> = .success(TestData.pharmacies.map {
            PharmacyLocationViewModel(
                pharmacy: $0,
                referenceDate: TestData.openHoursTestReferenceDate
            )
        })

        searchHistoryMock.historyItemsReturnValue = []

        // when search text changes to valid search term...
        await sut.send(.binding(.set(\.searchText, testSearchText))) { state in
            // ...expect it to be stored
            state.searchText = testSearchText
        }
        // when user hits Enter on keyboard start search...
        await sut.send(.performSearch) { state in
            // ...expect a search request to run
            state.searchState = .searchRunning
            state.lastSearchCriteria = .init(searchTerm: testSearchText, filter: [])
        }
        await testScheduler.advance()
        // when search request is done...
        await sut.receive(.response(.pharmaciesReceived(expected))) { state in
            // expect it to deliver successful & results...
            state.searchState = .searchResultOk
        }
    }

    func testSearchForPharmaciesEmptyResult() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo.searchRemoteSearchTermPositionFilterReturnValue = Just([])
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let sut = testStore(for: TestData.stateEmpty, pharmacyRepository: mockPharmacyRepo)
        let testSearchText = "Apodfdfd"
        let expected: Result<[PharmacyLocationViewModel], PharmacyRepositoryError> = .success([])

        searchHistoryMock.historyItemsReturnValue = []

        // when search text changes to valid search term...
        await sut.send(.binding(.set(\.searchText, testSearchText))) { state in
            // ...expect it to be stored
            state.searchText = testSearchText
        }
        // when user hits Enter on keyboard start search...
        await sut.send(.performSearch) { state in
            // ...expect a search request to run
            state.searchState = .searchRunning
            state.lastSearchCriteria = .init(searchTerm: testSearchText, filter: [])
        }
        await testScheduler.advance()
        expect(self.searchHistoryMock.addHistoryItemReceivedItem).to(equal(testSearchText))
        // when search request is done...
        await sut.receive(.response(.pharmaciesReceived(expected))) { state in
            // expect it to be empty...
            state.searchState = .searchResultEmpty
        }
    }

    func testSearchForPharmaciesWithLocation() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo.searchRemoteSearchTermPositionFilterReturnValue = Just(TestData.pharmaciesWithLocations)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let sut = testStore(for: TestData.stateWithLocation, pharmacyRepository: mockPharmacyRepo)
        let expectedPharmacy = TestData.pharmaciesWithLocations.map {
            PharmacyLocationViewModel(
                pharmacy: $0,
                referenceLocation: nil,
                referenceDate: TestData.openHoursTestReferenceDate
            )
        }
        let expectedResult: Result<[PharmacyLocationViewModel], PharmacyRepositoryError> = .success(expectedPharmacy)

        searchHistoryMock.historyItemsReturnValue = []

        // when user hits Location button start search...
        await sut.send(.performSearch) { state in
            // ...expect a search request to run
            state.searchState = .searchRunning
            state.lastSearchCriteria = .init(searchTerm: "", location: nil, filter: [])
        }
        await testScheduler.advance()
        // when search request is done...
        await sut.receive(.response(.pharmaciesReceived(expectedResult))) { state in
            // expect it to deliver successful & results...
            state.pharmacies = expectedPharmacy
            state.searchState = .searchResultOk
        }
    }

    func testStartView_loadLocalPharmacies_task_Success() async {
        let state = TestData.stateWithStartView
        let storedPharmacies = TestData.pharmacies
        let storedPharmaciesAsVM = storedPharmacies.map {
            PharmacyLocationViewModel(
                pharmacy: $0,
                referenceDate: TestData.openHoursTestReferenceDate
            )
        }
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo.loadLocalCountReturnValue = Just(storedPharmacies)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()
        let sut = testStore(for: state, pharmacyRepository: mockPharmacyRepo)
        searchHistoryMock.historyItemsReturnValue = []
        let locationManagerSubject = AsyncStream<LocationManager.Action> { _ in
        }
        sut.dependencies.locationManager.authorizationStatus = { .denied }
        sut.dependencies.locationManager.delegate = { locationManagerSubject }
        sut.dependencies.locationManager.requestWhenInUseAuthorization = {}
        sut.dependencies.locationManager.location = { nil }

        let task = await sut.send(.task)
        await testScheduler.advance()
        await sut.receive(.mapSetUp)

        await sut.receive(.mapSetUpReceived(nil))
        await sut.receive(.response(.loadLocalPharmaciesReceived(.success(storedPharmaciesAsVM)))) {
            $0.localPharmacies = storedPharmaciesAsVM
        }

        await task.cancel()
    }

    func testStartView_selectingLocalPharmacies_toLoadAndNavigateToPharmacy_Success() async {
        let state = TestData.stateWithStartView
        let selectedPharmacy = PharmacyLocation.Fixtures.pharmacyA
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo.updateFromRemoteByReturnValue = Just(selectedPharmacy)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()
        let sut = testStore(for: state, pharmacyRepository: mockPharmacyRepo)
        searchHistoryMock.historyItemsReturnValue = []

        await sut.send(.loadAndNavigateToPharmacy(selectedPharmacy)) {
            $0.searchState = .startView(loading: true)
            $0.selectedPharmacy = selectedPharmacy
        }
        await testScheduler.advance()
        await sut.receive(.response(.loadAndNavigateToPharmacyReceived(.success(selectedPharmacy)))) {
            $0.detailsPharmacy = PharmacyLocationViewModel(
                pharmacy: selectedPharmacy,
                referenceDate: TestData.openHoursTestReferenceDate
            )
            $0.searchState = .startView(loading: false)
            $0.selectedPharmacy = nil
            $0.destination = .pharmacyDetail(PharmacyDetailDomain.State(
                prescriptions: Shared([]),
                selectedPrescriptions: Shared([]),
                inRedeemProcess: false,
                pharmacyViewModel: PharmacyLocationViewModel(
                    pharmacy: selectedPharmacy,
                    referenceDate: TestData.openHoursTestReferenceDate
                ),
                pharmacyRedeemState: Shared(nil)
            ))
        }
    }

    func testStartView_selectingLocalPharmacies_toLoadAndNavigateToPharmacy_Failure() async {
        let state = TestData.stateWithStartView
        let selectedPharmacy = PharmacyLocation.Fixtures.pharmacyA
        let expectedError = PharmacyRepositoryError.remote(.fhirClient(.inconsistentResponse))
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo.updateFromRemoteByReturnValue = Fail(error: expectedError).eraseToAnyPublisher()
        let sut = testStore(for: state, pharmacyRepository: mockPharmacyRepo)
        searchHistoryMock.historyItemsReturnValue = []

        await sut.send(.loadAndNavigateToPharmacy(selectedPharmacy)) {
            $0.searchState = .startView(loading: true)
            $0.selectedPharmacy = selectedPharmacy
        }
        await testScheduler.advance()
        await sut.receive(.response(.loadAndNavigateToPharmacyReceived(.failure(expectedError)))) {
            $0.searchState = .startView(loading: false)
            $0.selectedPharmacy = nil
            $0.destination = .alert(.init(for: expectedError))
        }
    }

    func testStartView_selectingLocalPharmacies_toLoadAndNavigateToPharmacy_NotFound() async {
        let pharmacyViewModels = TestData.pharmacies.map { pharmacies in
            PharmacyLocationViewModel(
                pharmacy: pharmacies,
                referenceLocation: nil,
                referenceDate: TestData.openHoursTestReferenceDate
            )
        }
        let state = PharmacySearchDomain.State(
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            searchText: "",
            pharmacies: pharmacyViewModels,
            localPharmacies: pharmacyViewModels,
            pharmacyRedeemState: Shared(nil),
            pharmacyFilterOptions: Shared([]),
            searchState: .startView(loading: false)
        )
        let selectedPharmacy = pharmacyViewModels.last!
        let expectedError = PharmacyRepositoryError.remote(.notFound)
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo.updateFromRemoteByReturnValue = Fail(error: expectedError).eraseToAnyPublisher()
        mockPharmacyRepo.deletePharmaciesReturnValue = Just(true).setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let sut = testStore(for: state, pharmacyRepository: mockPharmacyRepo)
        searchHistoryMock.historyItemsReturnValue = []

        await sut.send(.loadAndNavigateToPharmacy(selectedPharmacy.pharmacyLocation)) {
            $0.searchState = .startView(loading: true)
            $0.selectedPharmacy = selectedPharmacy.pharmacyLocation
        }
        await testScheduler.advance()
        await sut.receive(.response(.loadAndNavigateToPharmacyReceived(.failure(expectedError)))) {
            $0.searchState = .startView(loading: false)
            $0.selectedPharmacy = nil
            $0.localPharmacies = pharmacyViewModels.dropLast()
            $0.destination = .alert(.init(for: expectedError))
        }
        expect(mockPharmacyRepo.deletePharmaciesCallsCount) == 1
    }

    func test_requestAuthorization_WhenInUse() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo.searchRemoteSearchTermPositionFilterReturnValue = Just(TestData.pharmacies)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let sut = testStore(for: TestData.stateWithStartView, pharmacyRepository: mockPharmacyRepo)
        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
        sut.dependencies.locationManager.authorizationStatus = { .notDetermined }
        sut.dependencies.locationManager.locationServicesEnabled = { true }
        sut.dependencies.locationManager.delegate = {
            AsyncStream { continuation in
                let cancellable = locationManagerSubject.sink { continuation.yield($0) }
                continuation.onTermination = { _ in
                    cancellable.cancel()
                }
            }
        }
        sut.dependencies.locationManager.requestWhenInUseAuthorization = {}
        sut.dependencies.locationManager.location = { TestData.testLocation }
        // when
        let onAppear = await sut.send(.onAppear)
        await sut.send(.requestLocation)
        locationManagerSubject.send(.didChangeAuthorization(.authorizedWhenInUse))
        // then
        await sut.receive(.locationManager(.didChangeAuthorization(.authorizedWhenInUse)))
        locationManagerSubject.send(completion: .finished)
        await sut.receive(.mapSetUp)

        await sut.receive(.mapSetUpReceived(TestData.testLocation)) { state in
            state.currentLocation = TestData.testLocation
            state.mapLocation = MKCoordinateRegion(center: TestData.testLocation.coordinate,
                                                   span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        }

        await onAppear.cancel()
    }

    func test_requestAuthorization_Denied() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo.searchRemoteSearchTermPositionFilterReturnValue = Just(TestData.pharmacies)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let sut = testStore(for: TestData.stateWithStartView, pharmacyRepository: mockPharmacyRepo)
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
        sut.dependencies.locationManager.requestWhenInUseAuthorization = {}
        // when
        let onAppear = await sut.send(.onAppear)
        await sut.send(.requestLocation)

        await sut.receive(.setAlert(PharmacySearchDomain.locationPermissionAlertState)) { state in
            state.destination = .alert(PharmacySearchDomain.locationPermissionAlertState)
        }
        locationManagerSubject.send(.didChangeAuthorization(.denied))
        // then
        await sut.receive(.locationManager(.didChangeAuthorization(.denied)))
        locationManagerSubject.send(completion: .finished)

        await onAppear.cancel()
    }

    func testUniversalLink() async {
        let mockPharmacyRepo = MockPharmacyRepository()
        let pharmacy = PharmacyLocation(id: "123.456.789", telematikID: "123.456.789", types: [])
        mockPharmacyRepo.loadCachedByReturnValue = Just(pharmacy)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()
        mockPharmacyRepo.savePharmaciesReturnValue = Just(false)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()
        let sut = testStore(for: PharmacySearchDomain.State(
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            searchText: "",
            pharmacies: [],
            pharmacyRedeemState: Shared(nil),
            pharmacyFilterOptions: Shared([])
        ), pharmacyRepository: mockPharmacyRepo)

        let url = URL(string: "https://erezept.gematik.de/pharmacies/#tiid=123.456.789")!
        await sut.send(.universalLink(url)) { state in
            state.searchState = .startView(loading: true)
        }
        var locationViewModel = PharmacyLocationViewModel(pharmacy: pharmacy)
        await sut.receive(.response(.loadAndNavigateToPharmacyReceived(.success(pharmacy)))) { state in
            state.searchState = .startView(loading: false)
            state.detailsPharmacy = locationViewModel
            state
                .destination = .pharmacyDetail(PharmacyDetailDomain
                    .State(
                        prescriptions: Shared([]),
                        selectedPrescriptions: Shared([]),
                        inRedeemProcess: false,
                        pharmacyViewModel: locationViewModel,
                        pharmacyRedeemState: Shared(nil)
                    ))
        }

        await testScheduler.run()

        await sut.receive(.destination(.presented(.pharmacyDetail(.setIsFavorite(true)))))

        await testScheduler.run()
        locationViewModel.pharmacyLocation.isFavorite = true
        await sut
            .receive(
                .destination(
                    .presented(
                        .pharmacyDetail(.response(.toggleIsFavoriteReceived(.success(locationViewModel))))
                    )
                )
            ) { state in
                state
                    .destination = .pharmacyDetail(PharmacyDetailDomain
                        .State(
                            prescriptions: Shared([]),
                            selectedPrescriptions: Shared([]),
                            inRedeemProcess: false,
                            pharmacyViewModel: locationViewModel,
                            pharmacyRedeemState: Shared(nil)
                        ))
            }
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

        let sut = testStore(for: .init(selectedPrescriptions: Shared([]),
                                       inRedeemProcess: false,
                                       searchText: "",
                                       currentLocation: TestData.testLocation,
                                       pharmacies: testPharmacies.map { pharmacies in
                                           PharmacyLocationViewModel(
                                               pharmacy: pharmacies,
                                               referenceLocation: TestData.testLocation,
                                               referenceDate: TestData.openHoursTestReferenceDate
                                           )
                                       },
                                       pharmacyRedeemState: Shared(nil),
                                       pharmacyFilterOptions: Shared([])),
                            pharmacyRepository: mockPharmacyRepo)

        await sut.send(.showDetails(testPharmacy)) { state in
            state.detailsPharmacy = testPharmacy

            state.destination =
                .pharmacyDetail(.init(
                    prescriptions: Shared([]),
                    selectedPrescriptions: Shared([]),
                    inRedeemProcess: false,
                    pharmacyViewModel: testPharmacy,
                    pharmacyRedeemState: Shared(nil)
                ))
        }

        await sut.send(.destination(.presented(.pharmacyDetail(.toggleIsFavorite))))

        await testScheduler.run()

        await sut.receive(.destination(.presented(
            .pharmacyDetail(.response(.toggleIsFavoriteReceived(.success(expectedPharmacy))))
        ))) { state in
            state.pharmacies = expectedPharmacies.map { pharmacies in
                PharmacyLocationViewModel(
                    pharmacy: pharmacies,
                    referenceLocation: TestData.testLocation,
                    referenceDate: TestData.openHoursTestReferenceDate
                )
            }
            state
                .destination =
                .pharmacyDetail(.init(
                    prescriptions: Shared([]),
                    selectedPrescriptions: Shared([]),
                    inRedeemProcess: false,
                    pharmacyViewModel: expectedPharmacy,
                    pharmacyRedeemState: Shared(nil)
                ))
        }

        await sut.send(.destination(.dismiss)) { state in
            state.destination = nil
        }

        await testScheduler.run()

        await sut.send(.showDetails(expectedPharmacy)) { state in
            state.detailsPharmacy = expectedPharmacy

            state.destination =
                .pharmacyDetail(.init(
                    prescriptions: Shared([]),
                    selectedPrescriptions: Shared([]),
                    inRedeemProcess: false,
                    pharmacyViewModel: expectedPharmacy,
                    pharmacyRedeemState: Shared(nil)
                ))
        }
    }

    func testRedeemPharmacyChangePharmacy() async {
        let prescriptions = Prescription.Fixtures.prescriptions

        let oldPharmacy = PharmacyLocationViewModel(
            pharmacy: TestData.pharmacy1,
            referenceDate: TestData.openHoursTestReferenceDate
        )
        let newPharmacy = PharmacyLocationViewModel(
            pharmacy: TestData.pharmacy2,
            referenceDate: TestData.openHoursTestReferenceDate
        )
        let oldPharmacyRedeemState = PharmacyRedeemDomain.State(
            redeemOption: .onPremise,
            prescriptions: Shared(prescriptions.filter(\.isRedeemable)),
            pharmacy: oldPharmacy.pharmacyLocation,
            selectedPrescriptions: Shared([])
        )
        let newPharmacyRedeemState = PharmacyRedeemDomain.State(
            redeemOption: .onPremise,
            prescriptions: oldPharmacyRedeemState.$prescriptions,
            pharmacy: newPharmacy.pharmacyLocation,
            selectedPrescriptions: oldPharmacyRedeemState.$selectedPrescriptions
        )
        let mockPharmacyRepo = MockPharmacyRepository()

        mockPharmacyRepo.updateFromRemoteByReturnValue = Just(newPharmacy.pharmacyLocation)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let profile = Profile(name: "Test", insuranceId: nil, erxTasks: [ErxTask.Fixtures.erxTaskReady])
        mockUserSession.profileReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        mockPrescriptionRepository.loadLocalReturnValue = Just(prescriptions)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let expected: Result<[Prescription], PrescriptionRepositoryError> = .success(prescriptions)

        let sut = testStore(for: PharmacySearchDomain.State(
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            searchText: "",
            pharmacies: TestData.pharmacies.map { pharmacies in
                PharmacyLocationViewModel(
                    pharmacy: pharmacies,
                    referenceLocation: nil,
                    referenceDate: TestData.openHoursTestReferenceDate
                )
            },
            pharmacyRedeemState: Shared(nil),
            pharmacyFilterOptions: Shared([]),
            searchState: .startView(loading: false)
        ), pharmacyRepository: mockPharmacyRepo)

        await sut.send(.showDetails(oldPharmacy)) {
            $0.detailsPharmacy = oldPharmacy
            $0.destination = .pharmacyDetail(PharmacyDetailDomain.State(
                prescriptions: Shared([]),
                selectedPrescriptions: Shared([]),
                inRedeemProcess: false,
                pharmacyViewModel: oldPharmacy,
                pharmacyRedeemState: Shared(nil)
            ))
        }

        await sut.send(.destination(.presented(.pharmacyDetail(.task))))

        await testScheduler.run()

        await sut.receive(.destination(.presented(.pharmacyDetail(.response(.currentProfileReceived(profile)))))) {
            $0.destination = .pharmacyDetail(.init(
                prescriptions: Shared([]),
                selectedPrescriptions: Shared([]),
                inRedeemProcess: false,
                pharmacyViewModel: oldPharmacy,
                pharmacyRedeemState: Shared(nil),
                reservationService: .erxTaskRepositoryAvailable,
                shipmentService: .erxTaskRepositoryAvailable
            ))
        }

        await sut
            .receive(.destination(.presented(.pharmacyDetail(.response(.loadLocalPrescriptionsReceived(expected)))))) {
                $0.destination = .pharmacyDetail(.init(prescriptions: Shared(prescriptions.filter(\.isRedeemable)),
                                                       selectedPrescriptions: Shared([]),
                                                       inRedeemProcess: false,
                                                       pharmacyViewModel: oldPharmacy,
                                                       hasRedeemableTasks: true,
                                                       pharmacyRedeemState: Shared(nil),
                                                       reservationService: .erxTaskRepositoryAvailable,
                                                       shipmentService: .erxTaskRepositoryAvailable))
            }

        await sut.send(.destination(.presented(.pharmacyDetail(.tappedRedeemOption(.onPremise))))) {
            $0.destination = .pharmacyDetail(.init(prescriptions: Shared(prescriptions.filter(\.isRedeemable)),
                                                   selectedPrescriptions: Shared([]),
                                                   inRedeemProcess: false,
                                                   pharmacyViewModel: oldPharmacy,
                                                   hasRedeemableTasks: true,
                                                   pharmacyRedeemState: Shared(nil),
                                                   reservationService: .erxTaskRepositoryAvailable,
                                                   shipmentService: .erxTaskRepositoryAvailable,
                                                   destination: .redeemViaErxTaskRepository(oldPharmacyRedeemState)))
        }

        await sut.send(.destination(.presented(.pharmacyDetail(.destination(.presented(
            .redeemViaErxTaskRepository(.delegate(.changePharmacy(oldPharmacyRedeemState)))
        )))))) {
            $0.pharmacyRedeemState = oldPharmacyRedeemState
            $0.destination = .pharmacyDetail(.init(prescriptions: Shared(prescriptions.filter(\.isRedeemable)),
                                                   selectedPrescriptions: Shared([]),
                                                   inRedeemProcess: false,
                                                   pharmacyViewModel: oldPharmacy,
                                                   hasRedeemableTasks: true,
                                                   pharmacyRedeemState: Shared(nil),
                                                   reservationService: .erxTaskRepositoryAvailable,
                                                   shipmentService: .erxTaskRepositoryAvailable,
                                                   destination: nil))
        }

        await sut
            .receive(.destination(.presented(.pharmacyDetail(.delegate(.changePharmacy(oldPharmacyRedeemState)))))) {
                $0.destination = nil
                $0.pharmacyRedeemState = oldPharmacyRedeemState
            }

        await sut.send(.showDetails(newPharmacy)) {
            $0.detailsPharmacy = newPharmacy

            $0.destination = .pharmacyDetail(PharmacyDetailDomain.State(
                prescriptions: Shared([]),
                selectedPrescriptions: Shared([]),
                inRedeemProcess: false,
                pharmacyViewModel: newPharmacy,
                pharmacyRedeemState: Shared(oldPharmacyRedeemState)
            ))
        }

        await sut.send(.destination(.presented(.pharmacyDetail(.task))))

        await testScheduler.run()

        await sut.receive(.destination(.presented(.pharmacyDetail(.response(.currentProfileReceived(profile)))))) {
            $0.destination = .pharmacyDetail(.init(
                prescriptions: Shared([]),
                selectedPrescriptions: Shared([]),
                inRedeemProcess: false,
                pharmacyViewModel: newPharmacy,
                pharmacyRedeemState: Shared(oldPharmacyRedeemState),
                reservationService: .erxTaskRepositoryAvailable,
                shipmentService: .noService
            ))
        }

        await sut
            .receive(.destination(.presented(.pharmacyDetail(.response(.loadLocalPrescriptionsReceived(expected)))))) {
                $0.destination = .pharmacyDetail(.init(
                    prescriptions: Shared(prescriptions.filter(\.isRedeemable)),
                    selectedPrescriptions: Shared([]),
                    inRedeemProcess: false,
                    pharmacyViewModel: newPharmacy,
                    hasRedeemableTasks: true,
                    pharmacyRedeemState: Shared(oldPharmacyRedeemState),
                    reservationService: .erxTaskRepositoryAvailable,
                    shipmentService: .noService
                ))
            }

        await sut.send(.destination(.presented(.pharmacyDetail(.tappedRedeemOption(.onPremise))))) {
            $0.destination = .pharmacyDetail(.init(
                prescriptions: Shared(prescriptions.filter(\.isRedeemable)),
                selectedPrescriptions: Shared([]),
                inRedeemProcess: false,
                pharmacyViewModel: newPharmacy,
                hasRedeemableTasks: true,
                pharmacyRedeemState: Shared(oldPharmacyRedeemState),
                reservationService: .erxTaskRepositoryAvailable,
                shipmentService: .noService,
                destination: .redeemViaErxTaskRepository(newPharmacyRedeemState)
            ))
        }
    }

    func test_MiniMapSetup() async {
        // given
        let state = TestData.stateWithStartView
        let mockPharmacyRepo = MockPharmacyRepository()
        let sut = testStore(for: state, pharmacyRepository: mockPharmacyRepo)
        searchHistoryMock.historyItemsReturnValue = []
        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
        sut.dependencies.locationManager.authorizationStatus = { .authorizedWhenInUse }
        sut.dependencies.locationManager.delegate = {
            AsyncStream { continuation in
                let cancellable = locationManagerSubject.sink { continuation.yield($0) }
                continuation.onTermination = { _ in
                    cancellable.cancel()
                }
            }
        }
        sut.dependencies.locationManager.requestWhenInUseAuthorization = {}
        sut.dependencies.locationManager.location = { TestData.testLocation }

        // then
        let onAppear = await sut.send(.onAppear)
        locationManagerSubject.send(completion: .finished)
        await sut.send(.mapSetUp)
        await sut.receive(.mapSetUpReceived(TestData.testLocation)) { state in
            state.currentLocation = TestData.testLocation
            state.mapLocation = MKCoordinateRegion(
                center: TestData.testLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }

        await onAppear.cancel()
    }

    // Includes the change of location permission while inside child domain and detecting the change in parent domain
    func testSwitchResultToMap() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo.searchRemoteSearchTermPositionFilterReturnValue = Just(TestData.pharmaciesWithLocations)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()
        let sut = testStore(for: TestData.stateWithNoLocation, pharmacyRepository: mockPharmacyRepo)
        let testSearchText = "Apo"
        let testSearchTextBahn = "Wäldchen"
        let expected: Result<[PharmacyLocationViewModel], PharmacyRepositoryError> = .success(
            TestData.pharmaciesWithLocations.map { pharmacies in
                PharmacyLocationViewModel(
                    pharmacy: pharmacies,
                    referenceLocation: nil,
                    referenceDate: TestData.openHoursTestReferenceDate
                )
            }
        )
        searchHistoryMock.historyItemsReturnValue = []
        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
        sut.dependencies.locationManager.authorizationStatus = { .denied }
        sut.dependencies.locationManager.requestWhenInUseAuthorization = {}
        sut.dependencies.locationManager.stopUpdatingLocation = {}
        sut.dependencies.locationManager.requestLocation = {}
        sut.dependencies.locationManager.delegate = {
            AsyncStream { continuation in
                let cancellable = locationManagerSubject.sink { continuation.yield($0) }
                continuation.onTermination = { _ in
                    cancellable.cancel()
                }
            }
        }
        sut.dependencies.locationManager.location = { nil }
        let expectedMapRegion = MKCoordinateRegion(center: .init(latitude: 49.24703449999999,
                                                                 longitude: 8.866878599999998),
                                                   span: .init(latitudeDelta: 0.01,
                                                               longitudeDelta: 0.01))

        let locationMapRegion = MKCoordinateRegion(center: .init(latitude: 52.5260422, longitude: 13.403368),
                                                   span: .init(latitudeDelta: 6.558015400000016,
                                                               longitudeDelta: 9.072978800000005))
        let newLocation = TestData.testLocation2
        // Pharmacies with referenceLocation of nil
        let expectedPharmacyNil = TestData.pharmaciesWithLocations.map { pharmacies in
            PharmacyLocationViewModel(
                pharmacy: pharmacies,
                referenceLocation: nil,
                referenceDate: TestData.openHoursTestReferenceDate
            )
        }
        // Result of pharmacySearch with expectedPharmacyNil
        let expectedResultNil: Result<[PharmacyLocationViewModel], PharmacyRepositoryError> =
            .success(expectedPharmacyNil)
        let emptyLocation: Location? = nil
        let calculatedLocation = TestData.testLocation
        // Pharmacies after Location tracking is allowed and got referenceLocation
        let pharmaciesAfterAllow = TestData.pharmaciesWithLocations.map { pharmacies in
            PharmacyLocationViewModel(
                pharmacy: pharmacies,
                referenceLocation: newLocation,
                referenceDate: TestData.openHoursTestReferenceDate
            )
        }
        // Pharmacies after Location is nil and is calculated based on pharmacies
        let pharmaciesAfterCalculatedLocation = TestData.pharmaciesWithLocations.map { pharmacies in
            PharmacyLocationViewModel(
                pharmacy: pharmacies,
                referenceLocation: calculatedLocation,
                referenceDate: TestData.openHoursTestReferenceDate
            )
        }
        // Pharmacies after Location tracking is denied
        let pharmaciesAfterDenied = TestData.pharmaciesWithLocations.map { pharmacies in
            PharmacyLocationViewModel(
                pharmacy: pharmacies,
                referenceLocation: nil,
                referenceDate: TestData.openHoursTestReferenceDate
            )
        }

        // then
        let onAppear = await sut.send(.onAppear)
        locationManagerSubject.send(completion: .finished)
        await sut.send(.mapSetUp)
        await sut.receive(.mapSetUpReceived(nil))

        await onAppear.cancel()

        await sut.send(.binding(.set(\.searchText, testSearchText))) { state in
            state.searchText = testSearchText
        }
        await sut.send(.performSearch) { state in
            state.searchState = .searchRunning
            state.lastSearchCriteria = .init(searchTerm: testSearchText, filter: [])
        }
        await testScheduler.advance()

        await sut.receive(.response(.pharmaciesReceived(expected))) { state in
            state.searchState = .searchResultOk
        }

        await sut.send(.switchToMapView) { state in
            state.destination = .pharmacyMapSearch(.init(selectedPrescriptions: Shared([]),
                                                         inRedeemProcess: false,
                                                         currentUserLocation: state.currentLocation,
                                                         mapLocation: .manual(expectedMapRegion),
                                                         pharmacies: pharmaciesAfterCalculatedLocation,
                                                         pharmacyFilterOptions: Shared([]),
                                                         showOnlyTextSearchResult: true,
                                                         searchText: testSearchText))
        }

        await sut
            .send(
                .destination(
                    .presented(.pharmacyMapSearch(.locationManager(.didChangeAuthorization(.authorizedAlways))))
                )
            ) { state in
                state.destination = .pharmacyMapSearch(.init(selectedPrescriptions: Shared([]),
                                                             inRedeemProcess: false,
                                                             currentUserLocation: state.currentLocation,
                                                             mapLocation: .manual(expectedMapRegion),
                                                             pharmacies: pharmaciesAfterCalculatedLocation,
                                                             pharmacyFilterOptions: Shared([]),
                                                             searchAfterAuthorized: true,
                                                             showOnlyTextSearchResult: true,
                                                             searchText: testSearchText))
            }

        await sut
            .send(
                .destination(
                    .presented(.pharmacyMapSearch(.locationManager(.didUpdateLocations([newLocation]))))
                )
            ) { state in
                state.destination = .pharmacyMapSearch(.init(selectedPrescriptions: Shared([]),
                                                             inRedeemProcess: false,
                                                             currentUserLocation: newLocation,
                                                             mapLocation: .manual(expectedMapRegion),
                                                             pharmacies: pharmaciesAfterCalculatedLocation,
                                                             pharmacyFilterOptions: Shared([]),
                                                             searchAfterAuthorized: true,
                                                             showOnlyTextSearchResult: true,
                                                             searchText: testSearchText))
            }

        await sut.receive(.destination(.presented(.pharmacyMapSearch(.setMapAfterLocationUpdate)))) { state in
            state.destination = .pharmacyMapSearch(.init(selectedPrescriptions: Shared([]),
                                                         inRedeemProcess: false,
                                                         currentUserLocation: newLocation,
                                                         mapLocation: .manual(locationMapRegion),
                                                         pharmacies: pharmaciesAfterAllow,
                                                         pharmacyFilterOptions: Shared([]),
                                                         searchAfterAuthorized: true,
                                                         showOnlyTextSearchResult: true,
                                                         searchText: testSearchText))
        }

        await sut
            .send(.destination(.presented(.pharmacyMapSearch(.delegate(.closeMap(location: newLocation)))))) { state in
                state.destination = nil
                state.currentLocation = newLocation
                state.pharmacyFilterOptions = []
            }

        await sut.send(.binding(.set(\.searchText, testSearchTextBahn))) { state in
            state.searchText = testSearchTextBahn
        }

        await sut.send(.performSearch) { state in
            state.searchState = .searchRunning
            state.lastSearchCriteria = .init(searchTerm: state.searchText,
                                             location: nil,
                                             filter: state.pharmacyFilterOptions)
        }

        await testScheduler.advance()

        await sut.receive(.response(.pharmaciesReceived(expectedResultNil))) { state in
            state.searchState = .searchResultOk
            state.pharmacies = expectedPharmacyNil
        }

        await sut.send(.switchToMapView) { state in
            state.destination = .pharmacyMapSearch(.init(selectedPrescriptions: Shared([]),
                                                         inRedeemProcess: false,
                                                         currentUserLocation: state.currentLocation,
                                                         mapLocation: .manual(locationMapRegion),
                                                         pharmacies: pharmaciesAfterAllow,
                                                         pharmacyFilterOptions: Shared([]),
                                                         showOnlyTextSearchResult: true,
                                                         searchText: testSearchTextBahn))
        }

        await sut
            .send(
                .destination(
                    .presented(.pharmacyMapSearch(.locationManager(.didChangeAuthorization(.denied))))
                )
            ) { state in
                state.destination = .pharmacyMapSearch(.init(selectedPrescriptions: Shared([]),
                                                             inRedeemProcess: false,
                                                             currentUserLocation: nil,
                                                             mapLocation: .manual(locationMapRegion),
                                                             pharmacies: pharmaciesAfterAllow,
                                                             pharmacyFilterOptions: Shared([]),
                                                             destination: .alert(PharmacySearchMapDomain
                                                                 .locationPermissionAlertState),
                                                             searchAfterAuthorized: false,
                                                             showOnlyTextSearchResult: true,
                                                             searchText: testSearchTextBahn))
            }

        await sut
            .send(
                .destination(.presented(.pharmacyMapSearch(.delegate(.closeMap(location: emptyLocation)))))
            ) { state in
                state.destination = nil
                state.currentLocation = emptyLocation
                state.pharmacyFilterOptions = []
            }

        await sut.send(.binding(.set(\.searchText, testSearchText))) { state in
            state.searchText = testSearchText
        }

        await sut.send(.performSearch) { state in
            state.searchState = .searchRunning
            state.lastSearchCriteria = .init(searchTerm: state.searchText,
                                             location: nil,
                                             filter: state.pharmacyFilterOptions)
        }

        await testScheduler.advance()

        await sut.receive(.response(.pharmaciesReceived(expected))) { state in
            state.searchState = .searchResultOk
            state.pharmacies = pharmaciesAfterDenied
        }

        await sut.send(.switchToMapView) { state in
            state.destination = .pharmacyMapSearch(.init(selectedPrescriptions: Shared([]),
                                                         inRedeemProcess: false,
                                                         currentUserLocation: emptyLocation,
                                                         mapLocation: .manual(expectedMapRegion),
                                                         pharmacies: pharmaciesAfterCalculatedLocation,
                                                         pharmacyFilterOptions: Shared([]),
                                                         showOnlyTextSearchResult: true,
                                                         searchText: testSearchText))
        }
    }

    func testSearchRequestNearMeFilter() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo.loadLocalCountReturnValue = Just([])
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()
        mockPharmacyRepo.searchRemoteSearchTermPositionFilterReturnValue = Just(TestData.pharmaciesWithLocations)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let sut = testStore(for: TestData.stateWithLocation, pharmacyRepository: mockPharmacyRepo)
        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
        sut.dependencies.locationManager.authorizationStatus = { .authorizedWhenInUse }
        sut.dependencies.locationManager.delegate = {
            AsyncStream { continuation in
                let cancellable = locationManagerSubject.sink { continuation.yield($0) }
                continuation.onTermination = { _ in
                    cancellable.cancel()
                }
            }
        }
        sut.dependencies.locationManager.requestWhenInUseAuthorization = {}
        sut.dependencies.locationManager.locationServicesEnabled = { true }
        sut.dependencies.locationManager.requestLocation = {}
        sut.dependencies.locationManager.stopUpdatingLocation = {}
        sut.dependencies.locationManager.location = { TestData.testLocation }
        searchHistoryMock.historyItemsReturnValue = []

        let expectedPharmacyLocation = TestData.pharmaciesWithLocations.map { pharmacies in
            PharmacyLocationViewModel(
                pharmacy: pharmacies,
                referenceLocation: TestData.testLocation,
                referenceDate: TestData.openHoursTestReferenceDate
            )
        }
        let expectedResultLocation: Result<[PharmacyLocationViewModel], PharmacyRepositoryError> =
            .success(expectedPharmacyLocation)

        let expectedPharmacyNil = TestData.pharmaciesWithLocations.map { pharmacies in
            PharmacyLocationViewModel(
                pharmacy: pharmacies,
                referenceLocation: nil,
                referenceDate: TestData.openHoursTestReferenceDate
            )
        }
        let expectedResultNil: Result<[PharmacyLocationViewModel], PharmacyRepositoryError> =
            .success(expectedPharmacyNil)

        let onAppear = await sut.send(.onAppear)
        locationManagerSubject.send(completion: .finished)
        let task = await sut.send(.task)
        await sut.receive(.mapSetUp)

        await sut.receive(.mapSetUpReceived(TestData.testLocation)) { state in
            state.currentLocation = TestData.testLocation
            state.mapLocation = MKCoordinateRegion(center: TestData.testLocation.coordinate,
                                                   span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        }

        await testScheduler.run()

        await sut.receive(.response(.loadLocalPharmaciesReceived(.success([]))))

        await sut.send(.showPharmacyFilter) { state in
            state.destination = .pharmacyFilter(.init())
        }
        await sut.send(.destination(.presented(.pharmacyFilter(.toggleFilter(.currentLocation))))) { state in
            state.pharmacyFilterOptions = [.currentLocation]
        }

        await testScheduler.run()

        await sut.receive(\.quickSearch, [.currentLocation]) { state in
            state.searchState = .searchAfterLocalizationWasAuthorized
        }
        await sut.receive(.requestLocation)

        await testScheduler.run()

        await sut.send(.locationManager(.didUpdateLocations([TestData.testLocation])))

        await sut.receive(.performSearch) { state in
            state.searchState = .searchRunning
            state.lastSearchCriteria = .init(
                searchTerm: "",
                location: TestData.testLocation,
                filter: [.currentLocation]
            )
        }

        await testScheduler.run()

        await sut.receive(.response(.pharmaciesReceived(expectedResultLocation))) { state in
            state.pharmacies = expectedPharmacyLocation
            state.searchState = .searchResultOk
        }

        await sut.send(.destination(.presented(.pharmacyFilter(.toggleFilter(.currentLocation))))) { state in
            state.pharmacyFilterOptions = []
        }

        await sut.receive(\.quickSearch, [])
        await sut.receive(.performSearch) { state in
            state.searchState = .searchRunning
            state.lastSearchCriteria = .init(searchTerm: "", location: nil, filter: [])
        }

        await testScheduler.run()

        await sut.receive(.response(.pharmaciesReceived(expectedResultNil))) { state in
            state.pharmacies = expectedPharmacyNil
            state.searchState = .searchResultOk
        }

        await task.cancel()
        await onAppear.cancel()
    }

    func testSearchInRedeemProcessToDetails() async {
        let prescriptions = Prescription.Fixtures.prescriptions

        let pharmacy = PharmacyLocationViewModel(
            pharmacy: TestData.pharmacy1,
            referenceDate: TestData.openHoursTestReferenceDate
        )

        let mockPharmacyRepo = MockPharmacyRepository()

        let sut = testStore(for: PharmacySearchDomain.State(
            selectedPrescriptions: Shared(prescriptions),
            inRedeemProcess: true,
            searchText: "",
            pharmacies: TestData.pharmacies.map { pharmacies in
                PharmacyLocationViewModel(
                    pharmacy: pharmacies,
                    referenceLocation: nil,
                    referenceDate: TestData.openHoursTestReferenceDate
                )
            },
            pharmacyRedeemState: Shared(nil),
            pharmacyFilterOptions: Shared([]),
            searchState: .startView(loading: false)
        ), pharmacyRepository: mockPharmacyRepo)

        await sut.send(.showDetails(pharmacy)) {
            $0.detailsPharmacy = pharmacy
            $0.destination = .pharmacyDetail(PharmacyDetailDomain.State(
                prescriptions: Shared([]),
                selectedPrescriptions: $0.$selectedPrescriptions,
                inRedeemProcess: true,
                pharmacyViewModel: pharmacy,
                hasRedeemableTasks: true,
                pharmacyRedeemState: Shared(nil)
            ))
        }
    }
}

extension PharmacySearchDomainTests {
    // Test-Data values for `PharmacyLocation`
    enum TestData {
        // Test-Date for opening/closing state
        static var openHoursTestReferenceDate: Date? {
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

        // Test-Data PharmacyDomain.State
        static let stateWithStartView =
            PharmacySearchDomain.State(
                selectedPrescriptions: Shared([]),
                inRedeemProcess: false,
                searchText: "",
                pharmacies: pharmacies.map { pharmacies in
                    PharmacyLocationViewModel(
                        pharmacy: pharmacies,
                        referenceLocation: nil,
                        referenceDate: TestData.openHoursTestReferenceDate
                    )
                },
                pharmacyRedeemState: Shared(nil),
                pharmacyFilterOptions: Shared([]),
                searchState: .startView(loading: false)
            )
        // Test-Data PharmacyDomain.State
        static let stateEmpty =
            PharmacySearchDomain.State(
                selectedPrescriptions: Shared([]),
                inRedeemProcess: false,
                searchText: "",
                pharmacies: [],
                pharmacyRedeemState: Shared(nil),
                pharmacyFilterOptions: Shared([])
            )
        // Test-Data PharmacyDomain.State with a location
        static let stateWithLocation =
            PharmacySearchDomain.State(
                selectedPrescriptions: Shared([]),
                inRedeemProcess: false,
                searchText: "",
                currentLocation: testLocation,
                pharmacies: pharmaciesWithLocations.map { pharmacies in
                    PharmacyLocationViewModel(
                        pharmacy: pharmacies,
                        referenceLocation: testLocation,
                        referenceDate: openHoursTestReferenceDate
                    )
                },
                pharmacyRedeemState: Shared(nil),
                pharmacyFilterOptions: Shared([])
            )

        // Test-Data PharmacyDomain.State
        static let stateWithNoLocation =
            PharmacySearchDomain.State(
                selectedPrescriptions: Shared([]),
                inRedeemProcess: false,
                searchText: "",
                currentLocation: nil,
                pharmacies: pharmaciesWithLocations.map { pharmacies in
                    PharmacyLocationViewModel(
                        pharmacy: pharmacies,
                        referenceLocation: nil,
                        referenceDate: TestData.openHoursTestReferenceDate
                    )
                },
                pharmacyRedeemState: Shared(nil),
                pharmacyFilterOptions: Shared([])
            )

        // Test location
        static let testLocation = Location(
            rawValue: CLLocation(latitude: 49.2470345, longitude: 8.8668786)
        )
        // Test location - 2
        static let testLocation2 = Location(
            rawValue: CLLocation(latitude: 52.5260422, longitude: 13.4033680)
        )
        // Test-Data address
        static let address1 = PharmacyLocation.Address(
            street: "Hinter der Bahn",
            houseNumber: "6",
            zip: "12345",
            city: "Buxtehude"
        )
        // Test-Data address
        static let address2 = PharmacyLocation.Address(
            street: "Meisenweg",
            houseNumber: "23",
            zip: "54321",
            city: "Linsengericht"
        )
        // Test-Data telecom
        static let telecom = PharmacyLocation.Telecom(
            phone: "555-Schuh",
            fax: "555-123456",
            email: "info@gematik.de",
            web: "http://www.gematik.de"
        )
        // Test-Data Pharmacy 1
        static let pharmacy1 = PharmacyLocation(
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
        // Test-Data Pharmacy 2
        static let pharmacy2 = PharmacyLocation(
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
        // Test-Data Pharmacy 3
        static let pharmacy3 = PharmacyLocation(
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
        // Test-Data Pharmacy 4
        static let pharmacy4 = PharmacyLocation(
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

        // Test-Data arry of pharmacies
        static let pharmacies = [
            pharmacy1,
            pharmacy2,
            pharmacy3,
            pharmacy4,
        ]
        // Test-Data array of pharmacies sorted alphabetical
        static let pharmaciesSortedAlphabetical = [
            pharmacy1,
            pharmacy3,
            pharmacy2,
            pharmacy4,
        ]
        // Test-Data array of pharmacies with a location
        static let pharmaciesWithLocations = [
            pharmacy1,
        ]
    }
}
