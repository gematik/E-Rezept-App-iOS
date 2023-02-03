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
@testable import eRpApp
import eRpKit
import Foundation
import Pharmacy
import XCTest

class MockPharmacyRepository: PharmacyRepository {
    var loadCachedPublisher: AnyPublisher<PharmacyLocation?, PharmacyRepositoryError>
    var loadCachedCallsCount = 0
    var loadCachedCalled: Bool {
        loadCachedCallsCount > 0
    }

    var searchRemotePublisher: AnyPublisher<[PharmacyLocation], PharmacyRepositoryError>
    var searchRemoteCallsCount = 0
    var searchRemoteCalled: Bool {
        searchRemoteCallsCount > 0
    }

    var savePublisher: AnyPublisher<Bool, PharmacyRepositoryError>
    var saveCallsCount = 0
    var saveCalled: Bool {
        saveCallsCount > 0
    }

    var loadLocalByIdPublisher: AnyPublisher<PharmacyLocation?, PharmacyRepositoryError>
    var loadLocalByIdCallsCount = 0
    var loadLocalByIdCalled: Bool {
        loadLocalByIdCallsCount > 0
    }

    var loadLocalAllPublisher: AnyPublisher<[PharmacyLocation], PharmacyRepositoryError>
    var loadLocalAllCallsCount = 0
    var loadLocalAllCalled: Bool {
        loadLocalAllCallsCount > 0
    }

    var deletePublisher: AnyPublisher<Bool, PharmacyRepositoryError>
    var deleteCallsCount = 0
    var deleteCalled: Bool {
        deleteCallsCount > 0
    }

    var loadRemoteAndSavePublisher: AnyPublisher<PharmacyLocation, PharmacyRepositoryError>
    var loadRemoteAndSaveCallsCount = 0
    var loadRemoteAndSaveCalled: Bool {
        loadRemoteAndSaveCallsCount > 0
    }

    init(stored pharmacies: [PharmacyLocation] = [],
         loadRemoteAndSave: AnyPublisher<PharmacyLocation, PharmacyRepositoryError> = failing(),
         loadCachedById: AnyPublisher<PharmacyLocation?, PharmacyRepositoryError> = failing(),
         searchRemote: AnyPublisher<[PharmacyLocation], PharmacyRepositoryError> = failing(),
         savePharmacies: AnyPublisher<Bool, PharmacyRepositoryError> = failing(),
         loadLocalById: AnyPublisher<PharmacyLocation?, PharmacyRepositoryError> = failing(),
         deletePharmacies: AnyPublisher<Bool, PharmacyRepositoryError> = failing()) {
        loadLocalAllPublisher = Just(pharmacies)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()
        loadCachedPublisher = loadCachedById
        searchRemotePublisher = searchRemote
        savePublisher = savePharmacies
        loadLocalByIdPublisher = loadLocalById
        deletePublisher = deletePharmacies
        loadRemoteAndSavePublisher = loadRemoteAndSave
    }

    func updateFromRemote(by _: String) -> AnyPublisher<PharmacyLocation, PharmacyRepositoryError> {
        loadRemoteAndSaveCallsCount += 1
        return loadRemoteAndSavePublisher
    }

    func loadCached(by _: String) -> AnyPublisher<PharmacyLocation?, PharmacyRepositoryError> {
        loadCachedCallsCount += 1
        return loadCachedPublisher
    }

    func searchRemote(searchTerm _: String, position _: Position?,
                      filter _: [PharmacyRepositoryFilter])
        -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError> {
        searchRemoteCallsCount += 1
        return searchRemotePublisher
    }

    func loadLocal(by _: String) -> AnyPublisher<PharmacyLocation?, PharmacyRepositoryError> {
        loadLocalByIdCallsCount += 1
        return loadLocalByIdPublisher
    }

    func loadLocal(count _: Int?) -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError> {
        loadLocalAllCallsCount += 1
        return loadLocalAllPublisher
    }

    func save(pharmacies _: [PharmacyLocation]) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        saveCallsCount += 1
        return savePublisher
    }

    func delete(pharmacies _: [PharmacyLocation]) -> AnyPublisher<Bool, PharmacyRepositoryError> {
        deleteCallsCount += 1
        return deletePublisher
    }

    static func failing() -> AnyPublisher<PharmacyLocation?, PharmacyRepositoryError> {
        Deferred { () -> AnyPublisher<PharmacyLocation?, PharmacyRepositoryError> in
            XCTFail("This publisher should not have run")
            return Just(nil).setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    static func failing() -> AnyPublisher<Bool, PharmacyRepositoryError> {
        Deferred { () -> AnyPublisher<Bool, PharmacyRepositoryError> in
            XCTFail("This publisher should not have run")
            return Just(false).setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    static func failing() -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError> {
        Deferred { () -> AnyPublisher<[PharmacyLocation], PharmacyRepositoryError> in
            XCTFail("This publisher should not have run")
            return Just([]).setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    static func failing() -> AnyPublisher<PharmacyLocation, PharmacyRepositoryError> {
        Deferred { () -> AnyPublisher<PharmacyLocation, PharmacyRepositoryError> in
            XCTFail("This publisher should not have run")
            return Fail(error: PharmacyRepositoryError.remote(.notFound)).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}
