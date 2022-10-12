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
import Nimble
@testable import Pharmacy
import TestUtils
import XCTest

final class DefaultPharmacyRepositoryTests: XCTestCase {
    func testLoadRemoteWithLocalPharmacy() {
        let mockLocalDataStore = MockPharmacyLocalDataStore()
        let mockRemoteDataStore = MockPharmacyRemoteDataStore()

        let sut = DefaultPharmacyRepository(disk: mockLocalDataStore, cloud: mockRemoteDataStore)

        mockLocalDataStore.fetchByTelematikIdClosure = { telematikId in
            if telematikId == Fixtures.pharmacy1.telematikID,
               mockLocalDataStore.fetchByTelematikIdCallsCount == 1 {
                return Just(Fixtures.pharmacy1)
                    .setFailureType(to: LocalStoreError.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: LocalStoreError.notImplemented).eraseToAnyPublisher()
            }
        }

        sut.loadCached(by: Fixtures.pharmacy1.telematikID)
            .first()
            .test(failure: { _ in
            }, expectations: { result in
                expect(result).to(equal(Fixtures.pharmacy1))
            })

        expect(mockRemoteDataStore.fetchByTelematikIdCallsCount).to(equal(0))
        expect(mockLocalDataStore.savePharmaciesCallsCount).to(equal(0))
    }

    func testLoadRemoteWithoutLocalPharmacy() {
        let mockLocalDataStore = MockPharmacyLocalDataStore()
        let mockRemoteDataStore = MockPharmacyRemoteDataStore()

        let sut = DefaultPharmacyRepository(disk: mockLocalDataStore, cloud: mockRemoteDataStore)

        mockLocalDataStore.fetchByTelematikIdClosure = { telematikId in
            if telematikId == Fixtures.pharmacy1.telematikID,
               mockLocalDataStore.fetchByTelematikIdCallsCount == 1 {
                return Just(nil)
                    .setFailureType(to: LocalStoreError.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: LocalStoreError.notImplemented).eraseToAnyPublisher()
            }
        }

        mockRemoteDataStore.fetchByTelematikIdClosure = { _ in
            if mockRemoteDataStore.fetchByTelematikIdCallsCount == 1 {
                return Just(Fixtures.pharmacy1)
                    .setFailureType(to: PharmacyFHIRDataSource.Error.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: PharmacyFHIRDataSource.Error.fhirClient(.internalError("notImplemented")))
                    .eraseToAnyPublisher()
            }
        }

        mockLocalDataStore.savePharmaciesReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        sut.loadCached(by: Fixtures.pharmacy1.telematikID)
            .first()
            .test(failure: { _ in
            }, expectations: { result in
                expect(result).to(equal(Fixtures.pharmacy1))
            })

        expect(mockLocalDataStore.savePharmaciesCallsCount).to(equal(1))
        expect(mockLocalDataStore.savePharmaciesReceivedInvocations).to(equal([
            [Fixtures.pharmacy1],
        ]))
    }

    func testLoadRemoteUnknownPharmacy() {
        let mockLocalDataStore = MockPharmacyLocalDataStore()
        let mockRemoteDataStore = MockPharmacyRemoteDataStore()

        let telematikId = "123"
        let sut = DefaultPharmacyRepository(disk: mockLocalDataStore, cloud: mockRemoteDataStore)

        mockLocalDataStore.fetchByTelematikIdClosure = { id in
            if id == telematikId,
               mockLocalDataStore.fetchByTelematikIdCallsCount == 1 {
                return Just(nil)
                    .setFailureType(to: LocalStoreError.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: LocalStoreError.notImplemented).eraseToAnyPublisher()
            }
        }

        mockRemoteDataStore.fetchByTelematikIdClosure = { _ in
            if mockRemoteDataStore.fetchByTelematikIdCallsCount == 1 {
                return Just(nil)
                    .setFailureType(to: PharmacyFHIRDataSource.Error.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: PharmacyFHIRDataSource.Error.fhirClient(.internalError("notImplemented")))
                    .eraseToAnyPublisher()
            }
        }

        sut.loadCached(by: telematikId)
            .first()
            .test(failure: { _ in
            }, expectations: { result in
                expect(result).to(beNil())
            })

        expect(mockLocalDataStore.savePharmaciesCallsCount).to(equal(0))
    }

    func testSearchRemoteWithDeliveryOption() {
        let mockLocalDataStore = MockPharmacyLocalDataStore()
        let mockRemoteDataStore = MockPharmacyRemoteDataStore()

        let sut = DefaultPharmacyRepository(disk: mockLocalDataStore, cloud: mockRemoteDataStore)

        mockRemoteDataStore.searchByTermPositionFilterClosure = { _, _, filter in
            if filter.isEmpty,
               mockRemoteDataStore.searchByTermPositionFilterCallsCount == 1 {
                return Just([Fixtures.pharmacy1, Fixtures.pharmacy2])
                    .setFailureType(to: PharmacyFHIRDataSource.Error.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: PharmacyFHIRDataSource.Error.fhirClient(.internalError("notImplemented")))
                    .eraseToAnyPublisher()
            }
        }

        sut.searchRemote(searchTerm: "", position: nil, filter: [.delivery])
            .first()
            .test(failure: { _ in
            }, expectations: { pharmacies in
                expect(pharmacies).to(equal([Fixtures.pharmacy2]))
            })
    }
}

extension DefaultPharmacyRepositoryTests {
    enum Fixtures {
        static let pharmacy1 = PharmacyLocation(
            id: "123",
            status: .active,
            telematikID: "S.-1234",
            name: "Pharmacy 1",
            types: [],
            hoursOfOperation: []
        )

        static let pharmacy2 = PharmacyLocation(
            id: "345",
            status: .active,
            telematikID: "S.-3456",
            name: "Pharmacy 2",
            types: [.delivery],
            hoursOfOperation: []
        )
    }
}
