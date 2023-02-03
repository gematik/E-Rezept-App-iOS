// Generated using Sourcery 1.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation
import OpenSSL

@testable import TrustStore

/// AUTO GENERATED – DO NOT EDIT
///
/// Use sourcery to update this file.
/// NOTE: If imports are missing/superfluous then add/remove them in the .sourcery.yml in the project's root.




















final class MockTrustStoreClient: TrustStoreClient {


    //MARK: - loadCertListFromServer

    var loadCertListFromServerCallsCount = 0
    var loadCertListFromServerCalled: Bool {
        return loadCertListFromServerCallsCount > 0
    }
    var loadCertListFromServerReturnValue: AnyPublisher<CertList, TrustStoreError>!
    var loadCertListFromServerClosure: (() -> AnyPublisher<CertList, TrustStoreError>)?

    func loadCertListFromServer() -> AnyPublisher<CertList, TrustStoreError> {
        loadCertListFromServerCallsCount += 1
        if let loadCertListFromServerClosure = loadCertListFromServerClosure {
            return loadCertListFromServerClosure()
        } else {
            return loadCertListFromServerReturnValue
        }
    }

    //MARK: - loadOCSPListFromServer

    var loadOCSPListFromServerCallsCount = 0
    var loadOCSPListFromServerCalled: Bool {
        return loadOCSPListFromServerCallsCount > 0
    }
    var loadOCSPListFromServerReturnValue: AnyPublisher<OCSPList, TrustStoreError>!
    var loadOCSPListFromServerClosure: (() -> AnyPublisher<OCSPList, TrustStoreError>)?

    func loadOCSPListFromServer() -> AnyPublisher<OCSPList, TrustStoreError> {
        loadOCSPListFromServerCallsCount += 1
        if let loadOCSPListFromServerClosure = loadOCSPListFromServerClosure {
            return loadOCSPListFromServerClosure()
        } else {
            return loadOCSPListFromServerReturnValue
        }
    }

}
