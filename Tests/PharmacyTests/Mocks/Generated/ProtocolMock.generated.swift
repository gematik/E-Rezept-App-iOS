// Generated using Sourcery 2.0.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import eRpKit

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
    var searchPharmaciesByPositionFilterReceivedArguments: (searchTerm: String, position: Position?, filter: [String: String])?
    var searchPharmaciesByPositionFilterReceivedInvocations: [(searchTerm: String, position: Position?, filter: [String: String])] = []
    var searchPharmaciesByPositionFilterReturnValue: AnyPublisher<[PharmacyLocation], PharmacyFHIRDataSource.Error>!
    var searchPharmaciesByPositionFilterClosure: ((String, Position?, [String: String]) -> AnyPublisher<[PharmacyLocation], PharmacyFHIRDataSource.Error>)?

    func searchPharmacies(by searchTerm: String, position: Position?, filter: [String: String]) -> AnyPublisher<[PharmacyLocation], PharmacyFHIRDataSource.Error> {
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
}
