// Generated using Sourcery 1.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import eRpKit

@testable import Pharmacy

/// AUTO GENERATED – DO NOT EDIT
///
/// Use sourcery to update this file.
/// NOTE: If imports are missing/superfluous then add/remove them in the .sourcery.yml in the project's root.




















final class MockPharmacyLocalDataStore: PharmacyLocalDataStore {


    //MARK: - fetchPharmacy

    var fetchPharmacyByCallsCount = 0
    var fetchPharmacyByCalled: Bool {
        return fetchPharmacyByCallsCount > 0
    }
    var fetchPharmacyByReceivedTelematikId: String?
    var fetchPharmacyByReceivedInvocations: [String] = []
    var fetchPharmacyByReturnValue: AnyPublisher<PharmacyLocation?, LocalStoreError>!
    var fetchPharmacyByClosure: ((String) -> AnyPublisher<PharmacyLocation?, LocalStoreError>)?

    func fetchPharmacy(by telematikId: String) -> AnyPublisher<PharmacyLocation?, LocalStoreError> {
        fetchPharmacyByCallsCount += 1
        fetchPharmacyByReceivedTelematikId = telematikId
        fetchPharmacyByReceivedInvocations.append(telematikId)
        if let fetchPharmacyByClosure = fetchPharmacyByClosure {
            return fetchPharmacyByClosure(telematikId)
        } else {
            return fetchPharmacyByReturnValue
        }
    }

    //MARK: - listPharmacies

    var listPharmaciesCountCallsCount = 0
    var listPharmaciesCountCalled: Bool {
        return listPharmaciesCountCallsCount > 0
    }
    var listPharmaciesCountReceivedCount: Int?
    var listPharmaciesCountReceivedInvocations: [Int?] = []
    var listPharmaciesCountReturnValue: AnyPublisher<[PharmacyLocation], LocalStoreError>!
    var listPharmaciesCountClosure: ((Int?) -> AnyPublisher<[PharmacyLocation], LocalStoreError>)?

    func listPharmacies(count: Int?) -> AnyPublisher<[PharmacyLocation], LocalStoreError> {
        listPharmaciesCountCallsCount += 1
        listPharmaciesCountReceivedCount = count
        listPharmaciesCountReceivedInvocations.append(count)
        if let listPharmaciesCountClosure = listPharmaciesCountClosure {
            return listPharmaciesCountClosure(count)
        } else {
            return listPharmaciesCountReturnValue
        }
    }

    //MARK: - save

    var savePharmaciesCallsCount = 0
    var savePharmaciesCalled: Bool {
        return savePharmaciesCallsCount > 0
    }
    var savePharmaciesReceivedPharmacies: [PharmacyLocation]?
    var savePharmaciesReceivedInvocations: [[PharmacyLocation]] = []
    var savePharmaciesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var savePharmaciesClosure: (([PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError> {
        savePharmaciesCallsCount += 1
        savePharmaciesReceivedPharmacies = pharmacies
        savePharmaciesReceivedInvocations.append(pharmacies)
        if let savePharmaciesClosure = savePharmaciesClosure {
            return savePharmaciesClosure(pharmacies)
        } else {
            return savePharmaciesReturnValue
        }
    }

    //MARK: - delete

    var deletePharmaciesCallsCount = 0
    var deletePharmaciesCalled: Bool {
        return deletePharmaciesCallsCount > 0
    }
    var deletePharmaciesReceivedPharmacies: [PharmacyLocation]?
    var deletePharmaciesReceivedInvocations: [[PharmacyLocation]] = []
    var deletePharmaciesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var deletePharmaciesClosure: (([PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError>)?

    func delete(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError> {
        deletePharmaciesCallsCount += 1
        deletePharmaciesReceivedPharmacies = pharmacies
        deletePharmaciesReceivedInvocations.append(pharmacies)
        if let deletePharmaciesClosure = deletePharmaciesClosure {
            return deletePharmaciesClosure(pharmacies)
        } else {
            return deletePharmaciesReturnValue
        }
    }

    //MARK: - update

    var updateTelematikIdMutatingCallsCount = 0
    var updateTelematikIdMutatingCalled: Bool {
        return updateTelematikIdMutatingCallsCount > 0
    }
    var updateTelematikIdMutatingReceivedArguments: (telematikId: String, mutating: (inout PharmacyLocation) -> Void)?
    var updateTelematikIdMutatingReceivedInvocations: [(telematikId: String, mutating: (inout PharmacyLocation) -> Void)] = []
    var updateTelematikIdMutatingReturnValue: AnyPublisher<PharmacyLocation, LocalStoreError>!
    var updateTelematikIdMutatingClosure: ((String, @escaping (inout PharmacyLocation) -> Void) -> AnyPublisher<PharmacyLocation, LocalStoreError>)?

    func update(telematikId: String, mutating: @escaping (inout PharmacyLocation) -> Void) -> AnyPublisher<PharmacyLocation, LocalStoreError> {
        updateTelematikIdMutatingCallsCount += 1
        updateTelematikIdMutatingReceivedArguments = (telematikId: telematikId, mutating: mutating)
        updateTelematikIdMutatingReceivedInvocations.append((telematikId: telematikId, mutating: mutating))
        if let updateTelematikIdMutatingClosure = updateTelematikIdMutatingClosure {
            return updateTelematikIdMutatingClosure(telematikId, mutating)
        } else {
            return updateTelematikIdMutatingReturnValue
        }
    }

}
final class MockPharmacyRemoteDataStore: PharmacyRemoteDataStore {


    //MARK: - searchPharmacies

    var searchPharmaciesByPositionFilterCallsCount = 0
    var searchPharmaciesByPositionFilterCalled: Bool {
        return searchPharmaciesByPositionFilterCallsCount > 0
    }
    var searchPharmaciesByPositionFilterReceivedArguments: (searchTerm: String, position: Position?, filter: [String: String])?
    var searchPharmaciesByPositionFilterReceivedInvocations: [(searchTerm: String, position: Position?, filter: [String: String])] = []
    var searchPharmaciesByPositionFilterReturnValue: AnyPublisher<[PharmacyLocation], PharmacyFHIRDataSource.Error>!
    var searchPharmaciesByPositionFilterClosure: ((String, Position?, [String: String]) -> AnyPublisher<[PharmacyLocation], PharmacyFHIRDataSource.Error>)?

    func searchPharmacies(by searchTerm: String, position: Position?, filter: [String: String]) -> AnyPublisher<[PharmacyLocation], PharmacyFHIRDataSource.Error> {
        searchPharmaciesByPositionFilterCallsCount += 1
        searchPharmaciesByPositionFilterReceivedArguments = (searchTerm: searchTerm, position: position, filter: filter)
        searchPharmaciesByPositionFilterReceivedInvocations.append((searchTerm: searchTerm, position: position, filter: filter))
        if let searchPharmaciesByPositionFilterClosure = searchPharmaciesByPositionFilterClosure {
            return searchPharmaciesByPositionFilterClosure(searchTerm, position, filter)
        } else {
            return searchPharmaciesByPositionFilterReturnValue
        }
    }

    //MARK: - fetchPharmacy

    var fetchPharmacyByCallsCount = 0
    var fetchPharmacyByCalled: Bool {
        return fetchPharmacyByCallsCount > 0
    }
    var fetchPharmacyByReceivedTelematikId: String?
    var fetchPharmacyByReceivedInvocations: [String] = []
    var fetchPharmacyByReturnValue: AnyPublisher<PharmacyLocation?, PharmacyFHIRDataSource.Error>!
    var fetchPharmacyByClosure: ((String) -> AnyPublisher<PharmacyLocation?, PharmacyFHIRDataSource.Error>)?

    func fetchPharmacy(by telematikId: String) -> AnyPublisher<PharmacyLocation?, PharmacyFHIRDataSource.Error> {
        fetchPharmacyByCallsCount += 1
        fetchPharmacyByReceivedTelematikId = telematikId
        fetchPharmacyByReceivedInvocations.append(telematikId)
        if let fetchPharmacyByClosure = fetchPharmacyByClosure {
            return fetchPharmacyByClosure(telematikId)
        } else {
            return fetchPharmacyByReturnValue
        }
    }

}
