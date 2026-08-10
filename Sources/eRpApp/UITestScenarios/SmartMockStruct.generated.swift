// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
/// Use sourcery to update this file.

import BfArM
import eRpKit
import eRpLocalStorage
import Foundation
import Pharmacy
import FHIRVZD
#if DEBUG


// MARK: - SmartMockBfArMSession -

extension BfArMSession: SmartMock {
    static func smartMock(wrapped: BfArMSession, mocks: Mocks?, isRecording: Bool = false) -> BfArMSession {
        Self.mocks = mocks ?? Self.mocks
        return BfArMSession(
            fetchBfArMInfo: {
                guard !isRecording else {
                    let result = try await wrapped.fetchBfArMInfo($0)
                    Self.mocks.fetchBfArMInfoRecordings?.record(result)
                    return result ?? nil 
                }
                if let first = Self.mocks.fetchBfArMInfoRecordings?.next() {
                    return first
                }
                return try await wrapped.fetchBfArMInfo($0) ?? nil 
            },
            fetchCachedImage: {
                guard !isRecording else {
                    let result = try await wrapped.fetchCachedImage($0)
                    Self.mocks.fetchCachedImageRecordings?.record(result)
                    return result ?? nil 
                }
                if let first = Self.mocks.fetchCachedImageRecordings?.next() {
                    return first
                }
                return try await wrapped.fetchCachedImage($0) ?? nil 
            }
        )
    }

    static var mocks: Mocks = Mocks()

    struct Mocks: VerifiableMock {
        var fetchBfArMInfoRecordings: MockAnswer<BfArMDiGaDetails?>? = .delegate
        var fetchCachedImageRecordings: MockAnswer<Data?>? = .delegate

        static var expectedKeys: Set<String> {
            [
                "fetchBfArMInfoRecordings",
                "fetchCachedImageRecordings",
            ]
        }
    }
    func recordedData() throws -> CodableMock {
        return try CodableMock(
            "BfArMSession",
            Self.mocks
        )
    }
}


// MARK: - SmartMockPharmacyRemoteDataStore -

extension PharmacyRemoteDataStore: SmartMock {
    static func smartMock(wrapped: PharmacyRemoteDataStore, mocks: Mocks?, isRecording: Bool = false) -> PharmacyRemoteDataStore {
        Self.mocks = mocks ?? Self.mocks
        return PharmacyRemoteDataStore(
            searchPharmacies: {
                guard !isRecording else {
                    let result = try await wrapped.searchPharmacies($0,$1,$2)
                    Self.mocks.searchPharmaciesRecordings?.record(result)
                    return result
                }
                if let first = Self.mocks.searchPharmaciesRecordings?.next() {
                    return first
                }
                return try await wrapped.searchPharmacies($0,$1,$2)
            },
            fetchPharmacy: {
                guard !isRecording else {
                    let result = try await wrapped.fetchPharmacy($0)
                    Self.mocks.fetchPharmacyRecordings?.record(result)
                    return result ?? nil 
                }
                if let first = Self.mocks.fetchPharmacyRecordings?.next() {
                    return first
                }
                return try await wrapped.fetchPharmacy($0) ?? nil 
            },
            fetchInsurance: {
                guard !isRecording else {
                    let result = try await wrapped.fetchInsurance($0)
                    Self.mocks.fetchInsuranceRecordings?.record(result)
                    return result ?? nil 
                }
                if let first = Self.mocks.fetchInsuranceRecordings?.next() {
                    return first
                }
                return try await wrapped.fetchInsurance($0) ?? nil 
            },
            fetchAllInsurances: {
                guard !isRecording else {
                    let result = try await wrapped.fetchAllInsurances()
                    Self.mocks.fetchAllInsurancesRecordings?.record(result)
                    return result
                }
                if let first = Self.mocks.fetchAllInsurancesRecordings?.next() {
                    return first
                }
                return try await wrapped.fetchAllInsurances()
            },
            fetchEuCountries: {
                guard !isRecording else {
                    let result = try await wrapped.fetchEuCountries()
                    Self.mocks.fetchEuCountriesRecordings?.record(result)
                    return result
                }
                if let first = Self.mocks.fetchEuCountriesRecordings?.next() {
                    return first
                }
                return try await wrapped.fetchEuCountries()
            }
        )
    }

    static var mocks: Mocks = Mocks()

    struct Mocks: VerifiableMock {
        var searchPharmaciesRecordings: MockAnswer<[PharmacyLocation]>? = .delegate
        var fetchPharmacyRecordings: MockAnswer<PharmacyLocation?>? = .delegate
        var fetchInsuranceRecordings: MockAnswer<Insurance?>? = .delegate
        var fetchAllInsurancesRecordings: MockAnswer<[Insurance]>? = .delegate
        var fetchEuCountriesRecordings: MockAnswer<[Country]>? = .delegate

        static var expectedKeys: Set<String> {
            [
                "searchPharmaciesRecordings",
                "fetchPharmacyRecordings",
                "fetchInsuranceRecordings",
                "fetchAllInsurancesRecordings",
                "fetchEuCountriesRecordings",
            ]
        }
    }
    func recordedData() throws -> CodableMock {
        return try CodableMock(
            "PharmacyRemoteDataStore",
            Self.mocks
        )
    }
}


#endif
