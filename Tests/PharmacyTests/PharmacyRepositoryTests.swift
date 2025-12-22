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
import eRpKit
import Nimble
@testable import Pharmacy
import TestUtils
import XCTest

final class PharmacyRepositoryTests: XCTestCase {
    func testLoadRemoteWithLocalPharmacy() async throws {
        let mockLocalDataStore = MockPharmacyLocalDataStore()
        let sut = PharmacyRepository.createWithMocks(disk: mockLocalDataStore)

        mockLocalDataStore.fetchPharmacyByClosure = { telematikId in
            if telematikId == Fixtures.pharmacy1.telematikID,
               mockLocalDataStore.fetchPharmacyByCallsCount == 1 {
                return Just(Fixtures.pharmacy1)
                    .setFailureType(to: LocalStoreError.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: LocalStoreError.notImplemented).eraseToAnyPublisher()
            }
        }

        let result = try await sut.loadCached(Fixtures.pharmacy1.telematikID)
        expect(result).to(equal(Fixtures.pharmacy1))

        expect(mockLocalDataStore.savePharmaciesCallsCount).to(equal(0))
    }

    func testLoadRemoteWithoutLocalPharmacy() async throws {
        try await withDependencies {
            $0.pharmacyRemoteDataStore.fetchPharmacy = { _ in Fixtures.pharmacy1 }
        } operation: {
            let mockLocalDataStore = MockPharmacyLocalDataStore()
            let sut = PharmacyRepository.createWithMocks(disk: mockLocalDataStore)

            mockLocalDataStore.fetchPharmacyByClosure = { telematikId in
                if telematikId == Fixtures.pharmacy1.telematikID,
                   mockLocalDataStore.fetchPharmacyByCallsCount == 1 {
                    return Just(nil)
                        .setFailureType(to: LocalStoreError.self)
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: LocalStoreError.notImplemented).eraseToAnyPublisher()
                }
            }

            mockLocalDataStore.savePharmaciesReturnValue = Just(true)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()

            let result = try await sut.loadCached(Fixtures.pharmacy1.telematikID)
            expect(result).to(equal(Fixtures.pharmacy1))

            expect(mockLocalDataStore.savePharmaciesCallsCount).to(equal(1))
            expect(mockLocalDataStore.savePharmaciesReceivedInvocations).to(equal([
                [Fixtures.pharmacy1],
            ]))
        }
    }

    func testLoadRemoteUnknownPharmacy() async throws {
        try await withDependencies {
            $0.pharmacyRemoteDataStore.fetchPharmacy = { _ in nil }
        } operation: {
            let mockLocalDataStore = MockPharmacyLocalDataStore()
            let telematikId = "123"
            let sut = PharmacyRepository.createWithMocks(disk: mockLocalDataStore)

            mockLocalDataStore.fetchPharmacyByClosure = { id in
                if id == telematikId,
                   mockLocalDataStore.fetchPharmacyByCallsCount == 1 {
                    return Just(nil)
                        .setFailureType(to: LocalStoreError.self)
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: LocalStoreError.notImplemented).eraseToAnyPublisher()
                }
            }

            let result = try await sut.loadCached(telematikId)
            expect(result).to(beNil())
            expect(mockLocalDataStore.savePharmaciesCallsCount).to(equal(0))
        }
    }

    func testSearchRemoteWithDeliveryOption() async throws {
        try await withDependencies {
            $0.pharmacyRemoteDataStore.searchPharmacies = { _, _, _ in
                [Fixtures.pharmacy1, Fixtures.pharmacy2]
            }
        } operation: {
            let mockLocalDataStore = MockPharmacyLocalDataStore()
            mockLocalDataStore.listPharmaciesCountReturnValue = Just([])
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
            mockLocalDataStore.savePharmaciesReturnValue = Just(true)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()

            let sut = PharmacyRepository.createWithMocks(disk: mockLocalDataStore)

            let pharmacies = try await sut.searchRemote("", nil, [.delivery])
            expect(pharmacies).to(equal([Fixtures.pharmacy2]))
        }
    }

    func testSearchRemoteWithPharmacyInLocalStore() async throws {
        let mockLocalDataStore = MockPharmacyLocalDataStore()
        let createDate = Date()
        var storedPharmacy = Fixtures.storedPharmacy2
        storedPharmacy.created = createDate
        mockLocalDataStore.listPharmaciesCountReturnValue = Just([storedPharmacy])
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        try await withDependencies {
            $0.pharmacyRemoteDataStore.searchPharmacies = { _, _, filter in
                var remotePharmacy = Fixtures.pharmacy2
                remotePharmacy.created = createDate

                if filter.isEmpty {
                    return [Fixtures.pharmacy1, remotePharmacy]
                } else {
                    throw PharmacyRemoteStoreError.fhirClient(.internalError("notImplemented"))
                }
            }
        } operation: {
            let sut = PharmacyRepository.createWithMocks(disk: mockLocalDataStore)

            let pharmacies = try await sut.searchRemote(searchTerm: "", position: nil, filter: [])
            expect(pharmacies).to(equal([Fixtures.pharmacy1, storedPharmacy]))
        }
    }
}

extension PharmacyRepositoryTests {
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

        // equal telematic id
        static let storedPharmacy2 = PharmacyLocation(
            id: "345",
            status: .active,
            telematikID: "S.-3456",
            created: Date(),
            name: "Pharmacy 2",
            types: [.delivery],
            address: nil,
            telecom: nil,
            lastUsed: Date(),
            isFavorite: true,
            hoursOfOperation: []
        )
    }
}
