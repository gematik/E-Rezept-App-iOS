//
//  Copyright (c) 2022 gematik GmbH
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
import eRpKit
@testable import Pharmacy

final class MockPharmacyLocalDataStore: PharmacyLocalDataStore {
    // MARK: - fetchPharmacy

    var fetchByTelematikIdCallsCount = 0
    var fetchByTelematikIdCalled: Bool {
        fetchByTelematikIdCallsCount > 0
    }

    var fetchByTelematikIdReceivedArgument: String?
    var fetchByTelematikIdReceivedInvocations: [String] = []
    var fetchByTelematikIdReturnValue: AnyPublisher<PharmacyLocation?, LocalStoreError>!
    var fetchByTelematikIdClosure: ((String) -> AnyPublisher<PharmacyLocation?, LocalStoreError>)?

    func fetchPharmacy(by telematikId: String) -> AnyPublisher<PharmacyLocation?, LocalStoreError> {
        fetchByTelematikIdCallsCount += 1
        fetchByTelematikIdReceivedArgument = telematikId
        fetchByTelematikIdReceivedInvocations.append(telematikId)
        return fetchByTelematikIdClosure.map { $0(telematikId) } ?? fetchByTelematikIdReturnValue
    }

    // MARK: - listAllPharmacies

    var listPharmaciesReceivedArgument: Int?
    var listPharmaciesCallsCount = 0
    var listPharmaciesCalled: Bool {
        listPharmaciesCallsCount > 0
    }

    var listPharmaciesReturnValue: AnyPublisher<[PharmacyLocation], LocalStoreError>!
    var listPharmaciesClosure: (() -> AnyPublisher<[PharmacyLocation], LocalStoreError>)?

    func listPharmacies(count: Int?) -> AnyPublisher<[PharmacyLocation], LocalStoreError> {
        listPharmaciesReceivedArgument = count
        listPharmaciesCallsCount += 1
        return listPharmaciesClosure.map { $0() } ?? listPharmaciesReturnValue
    }

    // MARK: - save

    var savePharmaciesCallsCount = 0
    var savePharmaciesCalled: Bool {
        savePharmaciesCallsCount > 0
    }

    var savePharmaciesReceivedArgument: [PharmacyLocation]?
    var savePharmaciesReceivedInvocations: [[PharmacyLocation]] = []
    var savePharmaciesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var savePharmaciesClosure: (([PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError> {
        savePharmaciesCallsCount += 1
        savePharmaciesReceivedArgument = pharmacies
        savePharmaciesReceivedInvocations.append(pharmacies)
        return savePharmaciesClosure.map { $0(pharmacies) } ?? savePharmaciesReturnValue
    }

    // MARK: - delete

    var deletePharmaciesCallsCount = 0
    var deletePharmaciesCalled: Bool {
        deletePharmaciesCallsCount > 0
    }

    var deletePharmaciesReceivedArgument: [PharmacyLocation]?
    var deletePharmaciesReceivedInvocations: [[PharmacyLocation]] = []
    var deletePharmaciesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var deletePharmaciesClosure: (([PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError>)?

    func delete(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError> {
        deletePharmaciesCallsCount += 1
        deletePharmaciesReceivedArgument = pharmacies
        deletePharmaciesReceivedInvocations.append(pharmacies)
        return deletePharmaciesClosure.map { $0(pharmacies) } ?? deletePharmaciesReturnValue
    }

    // MARK: - update

    var updatePharmacyIdMutatingCallsCount = 0
    var updatePharmacyIdMutatingCalled: Bool {
        updatePharmacyIdMutatingCallsCount > 0
    }

    var updatePharmacyIdMutatingReceivedArguments: (pharmacyId: String, mutating: (inout PharmacyLocation) -> Void)?
    var updatePharmacyIdMutatingReceivedInvocations: [
        (pharmacyId: String, mutating: (inout PharmacyLocation) -> Void)
    ] =
        []
    var updatePharmacyIdMutatingReturnValue: AnyPublisher<PharmacyLocation, LocalStoreError>!
    var updatePharmacyIdMutatingClosure: ((String, @escaping (inout PharmacyLocation) -> Void)
        -> AnyPublisher<PharmacyLocation, LocalStoreError>)?

    func update(telematikId: String,
                mutating: @escaping (inout PharmacyLocation) -> Void)
        -> AnyPublisher<PharmacyLocation, LocalStoreError> {
        updatePharmacyIdMutatingCallsCount += 1
        updatePharmacyIdMutatingReceivedArguments = (telematikId, mutating)
        updatePharmacyIdMutatingReceivedInvocations.append((telematikId, mutating))
        return updatePharmacyIdMutatingClosure.map { $0(telematikId, mutating) } ?? updatePharmacyIdMutatingReturnValue
    }
}
