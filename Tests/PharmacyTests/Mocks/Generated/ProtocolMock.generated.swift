// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import eRpKit
import OpenSSL

@testable import Pharmacy

/// AUTO GENERATED – DO NOT EDIT
///
/// Use sourcery to update this file.
/// NOTE: If imports are missing/superfluous then add/remove them in the .sourcery.yml in the project's root.
















// MARK: - MockPharmacyLocalDataStore -

final class MockPharmacyLocalDataStore: PharmacyLocalDataStore {
    
   // MARK: - fetchPharmacy

    var fetchPharmacyByCallsCount = 0
    var fetchPharmacyByCalled: Bool {
        fetchPharmacyByCallsCount > 0
    }
    var fetchPharmacyByReceivedTelematikId: String?
    var fetchPharmacyByReceivedInvocations: [String] = []
    var fetchPharmacyByReturnValue: AnyPublisher<PharmacyLocation?, LocalStoreError>!
    var fetchPharmacyByClosure: ((String) -> AnyPublisher<PharmacyLocation?, LocalStoreError>)?

    func fetchPharmacy(by telematikId: String) -> AnyPublisher<PharmacyLocation?, LocalStoreError> {
        fetchPharmacyByCallsCount += 1
        fetchPharmacyByReceivedTelematikId = telematikId
        fetchPharmacyByReceivedInvocations.append(telematikId)
        return fetchPharmacyByClosure.map({ $0(telematikId) }) ?? fetchPharmacyByReturnValue
    }
    
   // MARK: - listPharmacies

    var listPharmaciesCountCallsCount = 0
    var listPharmaciesCountCalled: Bool {
        listPharmaciesCountCallsCount > 0
    }
    var listPharmaciesCountReceivedCount: Int?
    var listPharmaciesCountReceivedInvocations: [Int?] = []
    var listPharmaciesCountReturnValue: AnyPublisher<[PharmacyLocation], LocalStoreError>!
    var listPharmaciesCountClosure: ((Int?) -> AnyPublisher<[PharmacyLocation], LocalStoreError>)?

    func listPharmacies(count: Int?) -> AnyPublisher<[PharmacyLocation], LocalStoreError> {
        listPharmaciesCountCallsCount += 1
        listPharmaciesCountReceivedCount = count
        listPharmaciesCountReceivedInvocations.append(count)
        return listPharmaciesCountClosure.map({ $0(count) }) ?? listPharmaciesCountReturnValue
    }
    
   // MARK: - save

    var savePharmaciesCallsCount = 0
    var savePharmaciesCalled: Bool {
        savePharmaciesCallsCount > 0
    }
    var savePharmaciesReceivedPharmacies: [PharmacyLocation]?
    var savePharmaciesReceivedInvocations: [[PharmacyLocation]] = []
    var savePharmaciesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var savePharmaciesClosure: (([PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError> {
        savePharmaciesCallsCount += 1
        savePharmaciesReceivedPharmacies = pharmacies
        savePharmaciesReceivedInvocations.append(pharmacies)
        return savePharmaciesClosure.map({ $0(pharmacies) }) ?? savePharmaciesReturnValue
    }
    
   // MARK: - delete

    var deletePharmaciesCallsCount = 0
    var deletePharmaciesCalled: Bool {
        deletePharmaciesCallsCount > 0
    }
    var deletePharmaciesReceivedPharmacies: [PharmacyLocation]?
    var deletePharmaciesReceivedInvocations: [[PharmacyLocation]] = []
    var deletePharmaciesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var deletePharmaciesClosure: (([PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError>)?

    func delete(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError> {
        deletePharmaciesCallsCount += 1
        deletePharmaciesReceivedPharmacies = pharmacies
        deletePharmaciesReceivedInvocations.append(pharmacies)
        return deletePharmaciesClosure.map({ $0(pharmacies) }) ?? deletePharmaciesReturnValue
    }
    
   // MARK: - update

    var updateTelematikIdMutatingCallsCount = 0
    var updateTelematikIdMutatingCalled: Bool {
        updateTelematikIdMutatingCallsCount > 0
    }
    var updateTelematikIdMutatingReceivedArguments: (telematikId: String, mutating: (inout PharmacyLocation) -> Void)?
    var updateTelematikIdMutatingReceivedInvocations: [(telematikId: String, mutating: (inout PharmacyLocation) -> Void)] = []
    var updateTelematikIdMutatingReturnValue: AnyPublisher<PharmacyLocation, LocalStoreError>!
    var updateTelematikIdMutatingClosure: ((String, @escaping (inout PharmacyLocation) -> Void) -> AnyPublisher<PharmacyLocation, LocalStoreError>)?

    func update(telematikId: String, mutating: @escaping (inout PharmacyLocation) -> Void) -> AnyPublisher<PharmacyLocation, LocalStoreError> {
        updateTelematikIdMutatingCallsCount += 1
        updateTelematikIdMutatingReceivedArguments = (telematikId: telematikId, mutating: mutating)
        updateTelematikIdMutatingReceivedInvocations.append((telematikId: telematikId, mutating: mutating))
        return updateTelematikIdMutatingClosure.map({ $0(telematikId, mutating) }) ?? updateTelematikIdMutatingReturnValue
    }
}


// MARK: - MockPharmacyRemoteDataStore -

final class MockPharmacyRemoteDataStore: PharmacyRemoteDataStore {
    
   // MARK: - searchPharmacies

    var searchPharmaciesByPositionFilterCallsCount = 0
    var searchPharmaciesByPositionFilterCalled: Bool {
        searchPharmaciesByPositionFilterCallsCount > 0
    }
    var searchPharmaciesByPositionFilterReceivedArguments: (searchTerm: String, position: Position?, filter: [PharmacyRemoteDataStoreFilter])?
    var searchPharmaciesByPositionFilterReceivedInvocations: [(searchTerm: String, position: Position?, filter: [PharmacyRemoteDataStoreFilter])] = []
    var searchPharmaciesByPositionFilterReturnValue: AnyPublisher<[PharmacyLocation], PharmacyFHIRDataSource.Error>!
    var searchPharmaciesByPositionFilterClosure: ((String, Position?, [PharmacyRemoteDataStoreFilter]) -> AnyPublisher<[PharmacyLocation], PharmacyFHIRDataSource.Error>)?

    func searchPharmacies(by searchTerm: String, position: Position?, filter: [PharmacyRemoteDataStoreFilter]) -> AnyPublisher<[PharmacyLocation], PharmacyFHIRDataSource.Error> {
        searchPharmaciesByPositionFilterCallsCount += 1
        searchPharmaciesByPositionFilterReceivedArguments = (searchTerm: searchTerm, position: position, filter: filter)
        searchPharmaciesByPositionFilterReceivedInvocations.append((searchTerm: searchTerm, position: position, filter: filter))
        return searchPharmaciesByPositionFilterClosure.map({ $0(searchTerm, position, filter) }) ?? searchPharmaciesByPositionFilterReturnValue
    }
    
   // MARK: - fetchPharmacy

    var fetchPharmacyByCallsCount = 0
    var fetchPharmacyByCalled: Bool {
        fetchPharmacyByCallsCount > 0
    }
    var fetchPharmacyByReceivedTelematikId: String?
    var fetchPharmacyByReceivedInvocations: [String] = []
    var fetchPharmacyByReturnValue: AnyPublisher<PharmacyLocation?, PharmacyFHIRDataSource.Error>!
    var fetchPharmacyByClosure: ((String) -> AnyPublisher<PharmacyLocation?, PharmacyFHIRDataSource.Error>)?

    func fetchPharmacy(by telematikId: String) -> AnyPublisher<PharmacyLocation?, PharmacyFHIRDataSource.Error> {
        fetchPharmacyByCallsCount += 1
        fetchPharmacyByReceivedTelematikId = telematikId
        fetchPharmacyByReceivedInvocations.append(telematikId)
        return fetchPharmacyByClosure.map({ $0(telematikId) }) ?? fetchPharmacyByReturnValue
    }
    
   // MARK: - loadAvsCertificates

    var loadAvsCertificatesForCallsCount = 0
    var loadAvsCertificatesForCalled: Bool {
        loadAvsCertificatesForCallsCount > 0
    }
    var loadAvsCertificatesForReceivedLocationId: String?
    var loadAvsCertificatesForReceivedInvocations: [String] = []
    var loadAvsCertificatesForReturnValue: AnyPublisher<[X509], PharmacyFHIRDataSource.Error>!
    var loadAvsCertificatesForClosure: ((String) -> AnyPublisher<[X509], PharmacyFHIRDataSource.Error>)?

    func loadAvsCertificates(for locationId: String) -> AnyPublisher<[X509], PharmacyFHIRDataSource.Error> {
        loadAvsCertificatesForCallsCount += 1
        loadAvsCertificatesForReceivedLocationId = locationId
        loadAvsCertificatesForReceivedInvocations.append(locationId)
        return loadAvsCertificatesForClosure.map({ $0(locationId) }) ?? loadAvsCertificatesForReturnValue
    }
    
   // MARK: - apiFilters

    var apiFiltersForCallsCount = 0
    var apiFiltersForCalled: Bool {
        apiFiltersForCallsCount > 0
    }
    var apiFiltersForReceivedFilter: [PharmacyRepositoryFilter]?
    var apiFiltersForReceivedInvocations: [[PharmacyRepositoryFilter]] = []
    var apiFiltersForReturnValue: [PharmacyRemoteDataStoreFilter]!
    var apiFiltersForClosure: (([PharmacyRepositoryFilter]) -> [PharmacyRemoteDataStoreFilter])?

    func apiFilters(for filter: [PharmacyRepositoryFilter]) -> [PharmacyRemoteDataStoreFilter] {
        apiFiltersForCallsCount += 1
        apiFiltersForReceivedFilter = filter
        apiFiltersForReceivedInvocations.append(filter)
        return apiFiltersForClosure.map({ $0(filter) }) ?? apiFiltersForReturnValue
    }
    
   // MARK: - fetchInsurance

    var fetchInsuranceByCallsCount = 0
    var fetchInsuranceByCalled: Bool {
        fetchInsuranceByCallsCount > 0
    }
    var fetchInsuranceByReceivedIkNumber: String?
    var fetchInsuranceByReceivedInvocations: [String] = []
    var fetchInsuranceByReturnValue: AnyPublisher<Insurance?, PharmacyFHIRDataSource.Error>!
    var fetchInsuranceByClosure: ((String) -> AnyPublisher<Insurance?, PharmacyFHIRDataSource.Error>)?

    func fetchInsurance(by ikNumber: String) -> AnyPublisher<Insurance?, PharmacyFHIRDataSource.Error> {
        fetchInsuranceByCallsCount += 1
        fetchInsuranceByReceivedIkNumber = ikNumber
        fetchInsuranceByReceivedInvocations.append(ikNumber)
        return fetchInsuranceByClosure.map({ $0(ikNumber) }) ?? fetchInsuranceByReturnValue
    }
    
   // MARK: - fetchAllInsurances

    var fetchAllInsurancesCallsCount = 0
    var fetchAllInsurancesCalled: Bool {
        fetchAllInsurancesCallsCount > 0
    }
    var fetchAllInsurancesReturnValue: AnyPublisher<[Insurance], PharmacyFHIRDataSource.Error>!
    var fetchAllInsurancesClosure: (() -> AnyPublisher<[Insurance], PharmacyFHIRDataSource.Error>)?

    func fetchAllInsurances() -> AnyPublisher<[Insurance], PharmacyFHIRDataSource.Error> {
        fetchAllInsurancesCallsCount += 1
        return fetchAllInsurancesClosure.map({ $0() }) ?? fetchAllInsurancesReturnValue
    }
}
