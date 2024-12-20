// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation
import OpenSSL

@testable import TrustStore

/// AUTO GENERATED – DO NOT EDIT
///
/// Use sourcery to update this file.
/// NOTE: If imports are missing/superfluous then add/remove them in the .sourcery.yml in the project's root.
















// MARK: - MockTrustStoreClient -

final class MockTrustStoreClient: TrustStoreClient {
    
   // MARK: - loadCertListFromServer

    var loadCertListFromServerCallsCount = 0
    var loadCertListFromServerCalled: Bool {
        loadCertListFromServerCallsCount > 0
    }
    var loadCertListFromServerReturnValue: AnyPublisher<CertList, TrustStoreError>!
    var loadCertListFromServerClosure: (() -> AnyPublisher<CertList, TrustStoreError>)?

    func loadCertListFromServer() -> AnyPublisher<CertList, TrustStoreError> {
        loadCertListFromServerCallsCount += 1
        return loadCertListFromServerClosure.map({ $0() }) ?? loadCertListFromServerReturnValue
    }
    
   // MARK: - loadOCSPListFromServer

    var loadOCSPListFromServerCallsCount = 0
    var loadOCSPListFromServerCalled: Bool {
        loadOCSPListFromServerCallsCount > 0
    }
    var loadOCSPListFromServerReturnValue: AnyPublisher<OCSPList, TrustStoreError>!
    var loadOCSPListFromServerClosure: (() -> AnyPublisher<OCSPList, TrustStoreError>)?

    func loadOCSPListFromServer() -> AnyPublisher<OCSPList, TrustStoreError> {
        loadOCSPListFromServerCallsCount += 1
        return loadOCSPListFromServerClosure.map({ $0() }) ?? loadOCSPListFromServerReturnValue
    }
    
   // MARK: - loadPKICertificatesFromServer

    var loadPKICertificatesFromServerRootSubjectCnThrowableError: Error?
    var loadPKICertificatesFromServerRootSubjectCnCallsCount = 0
    var loadPKICertificatesFromServerRootSubjectCnCalled: Bool {
        loadPKICertificatesFromServerRootSubjectCnCallsCount > 0
    }
    var loadPKICertificatesFromServerRootSubjectCnReceivedRootSubjectCn: String?
    var loadPKICertificatesFromServerRootSubjectCnReceivedInvocations: [String] = []
    var loadPKICertificatesFromServerRootSubjectCnReturnValue: PKICertificates!
    var loadPKICertificatesFromServerRootSubjectCnClosure: ((String) throws -> PKICertificates)?

    func loadPKICertificatesFromServer(rootSubjectCn: String) throws -> PKICertificates {
        if let error = loadPKICertificatesFromServerRootSubjectCnThrowableError {
            throw error
        }
        loadPKICertificatesFromServerRootSubjectCnCallsCount += 1
        loadPKICertificatesFromServerRootSubjectCnReceivedRootSubjectCn = rootSubjectCn
        loadPKICertificatesFromServerRootSubjectCnReceivedInvocations.append(rootSubjectCn)
        return try loadPKICertificatesFromServerRootSubjectCnClosure.map({ try $0(rootSubjectCn) }) ?? loadPKICertificatesFromServerRootSubjectCnReturnValue
    }
    
   // MARK: - loadVauCertificateFromServer

    var loadVauCertificateFromServerThrowableError: Error?
    var loadVauCertificateFromServerCallsCount = 0
    var loadVauCertificateFromServerCalled: Bool {
        loadVauCertificateFromServerCallsCount > 0
    }
    var loadVauCertificateFromServerReturnValue: Data!
    var loadVauCertificateFromServerClosure: (() throws -> Data)?

    func loadVauCertificateFromServer() throws -> Data {
        if let error = loadVauCertificateFromServerThrowableError {
            throw error
        }
        loadVauCertificateFromServerCallsCount += 1
        return try loadVauCertificateFromServerClosure.map({ try $0() }) ?? loadVauCertificateFromServerReturnValue
    }
    
   // MARK: - loadOcspResponseFromServer

    var loadOcspResponseFromServerIssuerCnSerialNrThrowableError: Error?
    var loadOcspResponseFromServerIssuerCnSerialNrCallsCount = 0
    var loadOcspResponseFromServerIssuerCnSerialNrCalled: Bool {
        loadOcspResponseFromServerIssuerCnSerialNrCallsCount > 0
    }
    var loadOcspResponseFromServerIssuerCnSerialNrReceivedArguments: (issuerCn: String, serialNr: String)?
    var loadOcspResponseFromServerIssuerCnSerialNrReceivedInvocations: [(issuerCn: String, serialNr: String)] = []
    var loadOcspResponseFromServerIssuerCnSerialNrReturnValue: Data!
    var loadOcspResponseFromServerIssuerCnSerialNrClosure: ((String, String) throws -> Data)?

    func loadOcspResponseFromServer(issuerCn: String, serialNr: String) throws -> Data {
        if let error = loadOcspResponseFromServerIssuerCnSerialNrThrowableError {
            throw error
        }
        loadOcspResponseFromServerIssuerCnSerialNrCallsCount += 1
        loadOcspResponseFromServerIssuerCnSerialNrReceivedArguments = (issuerCn: issuerCn, serialNr: serialNr)
        loadOcspResponseFromServerIssuerCnSerialNrReceivedInvocations.append((issuerCn: issuerCn, serialNr: serialNr))
        return try loadOcspResponseFromServerIssuerCnSerialNrClosure.map({ try $0(issuerCn, serialNr) }) ?? loadOcspResponseFromServerIssuerCnSerialNrReturnValue
    }
}
