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
        let mockLocalDataStore = PharmacyLocalDataStoreMock()
        let sut = PharmacyRepository.createWithMocks(disk: mockLocalDataStore)

        mockLocalDataStore
            .fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorClosure = { telematikId in
                if telematikId == Fixtures.pharmacy1.telematikID,
                   mockLocalDataStore
                   .fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorCallsCount == 1 {
                    return Just(Fixtures.pharmacy1)
                        .setFailureType(to: LocalStoreError.self)
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: LocalStoreError.notImplemented).eraseToAnyPublisher()
                }
            }

        let result = try await sut.loadCached(Fixtures.pharmacy1.telematikID)
        expect(result).to(equal(Fixtures.pharmacy1))

        expect(mockLocalDataStore.savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorCallsCount).to(equal(0))
    }

    func testLoadRemoteWithoutLocalPharmacy() async throws {
        try await withDependencies {
            $0.pharmacyRemoteDataStore.fetchPharmacy = { _ in Fixtures.pharmacy1 }
        } operation: {
            let mockLocalDataStore = PharmacyLocalDataStoreMock()
            let sut = PharmacyRepository.createWithMocks(disk: mockLocalDataStore)

            mockLocalDataStore
                .fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorClosure = { telematikId in
                    if telematikId == Fixtures.pharmacy1.telematikID,
                       mockLocalDataStore
                       .fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorCallsCount == 1 {
                        return Just(nil)
                            .setFailureType(to: LocalStoreError.self)
                            .eraseToAnyPublisher()
                    } else {
                        return Fail(error: LocalStoreError.notImplemented).eraseToAnyPublisher()
                    }
                }

            mockLocalDataStore.savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReturnValue = Just(true)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()

            let result = try await sut.loadCached(Fixtures.pharmacy1.telematikID)
            expect(result).to(equal(Fixtures.pharmacy1))

            expect(mockLocalDataStore.savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorCallsCount)
                .to(equal(1))
            expect(mockLocalDataStore.savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReceivedInvocations)
                .to(equal([
                    [Fixtures.pharmacy1],
                ]))
        }
    }

    func testLoadRemoteUnknownPharmacy() async throws {
        try await withDependencies {
            $0.pharmacyRemoteDataStore.fetchPharmacy = { _ in nil }
        } operation: {
            let mockLocalDataStore = PharmacyLocalDataStoreMock()
            let telematikId = "123"
            let sut = PharmacyRepository.createWithMocks(disk: mockLocalDataStore)

            mockLocalDataStore
                .fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorClosure = { id in
                    if id == telematikId,
                       mockLocalDataStore
                       .fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorCallsCount == 1 {
                        return Just(nil)
                            .setFailureType(to: LocalStoreError.self)
                            .eraseToAnyPublisher()
                    } else {
                        return Fail(error: LocalStoreError.notImplemented).eraseToAnyPublisher()
                    }
                }

            let result = try await sut.loadCached(telematikId)
            expect(result).to(beNil())
            expect(mockLocalDataStore.savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorCallsCount)
                .to(equal(0))
        }
    }

    func testSearchRemoteWithDeliveryOption() async throws {
        try await withDependencies {
            $0.pharmacyRemoteDataStore.searchPharmacies = { _, _, _ in
                [Fixtures.pharmacy1, Fixtures.pharmacy2]
            }
        } operation: {
            let mockLocalDataStore = PharmacyLocalDataStoreMock()
            mockLocalDataStore.listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorReturnValue = Just([])
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
            mockLocalDataStore.savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReturnValue = Just(true)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()

            let sut = PharmacyRepository.createWithMocks(disk: mockLocalDataStore)

            let pharmacies = try await sut.searchRemote("", nil, [.delivery])
            expect(pharmacies).to(equal([Fixtures.pharmacy2]))
        }
    }

    func testSearchRemoteWithPharmacyInLocalStore() async throws {
        let mockLocalDataStore = PharmacyLocalDataStoreMock()
        let createDate = Date()
        var storedPharmacy = Fixtures.storedPharmacy2
        storedPharmacy.created = createDate
        mockLocalDataStore
            .listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorReturnValue = Just([storedPharmacy])
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

    /// Tests that loadLocalCount only returns pharmacies that are favorites OR have been recently used.
    /// Pharmacies that are neither should be filtered out.
    func testLoadLocalCount_filtersFavoritesAndRecentlyUsed() async throws {
        let mockLocalDataStore = PharmacyLocalDataStoreMock()

        // Given: The disk store contains pharmacies with different favorite/lastUsed states
        let allPharmacies = [
            Fixtures.pharmacyFavorite, // isFavorite = true -> should be included
            Fixtures.pharmacyRecentlyUsed, // lastUsed != nil -> should be included
            Fixtures.pharmacyNeitherFavoriteNorUsed, // neither -> should be excluded
        ]

        mockLocalDataStore
            .listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorReturnValue = Just(allPharmacies)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        let sut = PharmacyRepository.createWithMocks(disk: mockLocalDataStore)

        // When: Loading local pharmacies
        let result = try await sut.loadLocalCount(nil)

        // Then: Only favorite and recently used pharmacies should be returned
        expect(result).to(haveCount(2))
        expect(result.map(\.id)).to(contain("fav-1", "used-1"))
        expect(result.map(\.id)).notTo(contain("neither-1"))
    }

    /// Tests that a pharmacy with both isFavorite=true AND lastUsed set is included
    func testLoadLocalCount_includesPharmacyWithBothFavoriteAndUsed() async throws {
        let mockLocalDataStore = PharmacyLocalDataStoreMock()

        let pharmacyBoth = PharmacyLocation(
            id: "both-1",
            status: .active,
            telematikID: "S.-BOTH",
            name: "Both Favorite and Used",
            types: [],
            lastUsed: Date(),
            isFavorite: true,
            hoursOfOperation: []
        )

        let allPharmacies = [pharmacyBoth, Fixtures.pharmacyNeitherFavoriteNorUsed]

        mockLocalDataStore
            .listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorReturnValue = Just(allPharmacies)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        let sut = PharmacyRepository.createWithMocks(disk: mockLocalDataStore)

        // When: Loading local pharmacies
        let result = try await sut.loadLocalCount(nil)

        // Then: Only the pharmacy with favorite/used should be returned
        expect(result).to(haveCount(1))
        expect(result.first?.id).to(equal("both-1"))
    }

    /// Tests that when all pharmacies are neither favorites nor recently used,
    /// the result is empty
    func testLoadLocalCount_returnsEmptyWhenNoFavoritesOrRecentlyUsed() async throws {
        let mockLocalDataStore = PharmacyLocalDataStoreMock()

        let allPharmacies = [
            Fixtures.pharmacy1, // no favorite, no lastUsed
            Fixtures.pharmacyNeitherFavoriteNorUsed,
        ]

        mockLocalDataStore
            .listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorReturnValue = Just(allPharmacies)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        let sut = PharmacyRepository.createWithMocks(disk: mockLocalDataStore)

        // When: Loading local pharmacies
        let result = try await sut.loadLocalCount(nil)

        // Then: No pharmacies should be returned
        expect(result).to(beEmpty())
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

        /// equal telematic id
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

        /// Pharmacy that is a favorite (should be included in filtered results)
        static let pharmacyFavorite = PharmacyLocation(
            id: "fav-1",
            status: .active,
            telematikID: "S.-FAV",
            name: "Favorite Pharmacy",
            types: [],
            isFavorite: true,
            hoursOfOperation: []
        )

        /// Pharmacy that was recently used (should be included in filtered results)
        static let pharmacyRecentlyUsed = PharmacyLocation(
            id: "used-1",
            status: .active,
            telematikID: "S.-USED",
            name: "Recently Used Pharmacy",
            types: [],
            lastUsed: Date(),
            isFavorite: false,
            hoursOfOperation: []
        )

        /// Pharmacy that is neither favorite nor recently used (should be filtered out)
        static let pharmacyNeitherFavoriteNorUsed = PharmacyLocation(
            id: "neither-1",
            status: .active,
            telematikID: "S.-NEITHER",
            name: "Neither Favorite Nor Used",
            types: [],
            isFavorite: false,
            hoursOfOperation: []
        )
    }
}
