// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
/// Use sourcery to update this file.

import BfArM
import eRpKit
import Foundation

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

    struct Mocks: Codable {
        var fetchBfArMInfoRecordings: MockAnswer<BfArMDiGaDetails?>? = .delegate
        var fetchCachedImageRecordings: MockAnswer<Data?>? = .delegate
    }
    func recordedData() throws -> CodableMock {
        return try CodableMock(
            "BfArMSession",
            Self.mocks
        )
    }
}


#endif
