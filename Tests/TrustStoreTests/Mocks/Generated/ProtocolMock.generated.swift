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


// MARK: - MockTrustStoreStorage -

final class MockTrustStoreStorage: TrustStoreStorage {
    
   // MARK: - certList

    var certList: AnyPublisher<CertList?, Never> {
        get { underlyingCertList }
        set(value) { underlyingCertList = value }
    }
    var underlyingCertList: AnyPublisher<CertList?, Never>!
    
   // MARK: - ocspList

    var ocspList: AnyPublisher<OCSPList?, Never> {
        get { underlyingOcspList }
        set(value) { underlyingOcspList = value }
    }
    var underlyingOcspList: AnyPublisher<OCSPList?, Never>!
    
   // MARK: - set

    var setCertListCallsCount = 0
    var setCertListCalled: Bool {
        setCertListCallsCount > 0
    }
    var setCertListReceivedCertList: CertList?
    var setCertListReceivedInvocations: [CertList?] = []
    var setCertListClosure: ((CertList?) -> Void)?

    func set(certList: CertList?) {
        setCertListCallsCount += 1
        setCertListReceivedCertList = certList
        setCertListReceivedInvocations.append(certList)
        setCertListClosure?(certList)
    }
    
   // MARK: - set

    var setOcspListCallsCount = 0
    var setOcspListCalled: Bool {
        setOcspListCallsCount > 0
    }
    var setOcspListReceivedOcspList: OCSPList?
    var setOcspListReceivedInvocations: [OCSPList?] = []
    var setOcspListClosure: ((OCSPList?) -> Void)?

    func set(ocspList: OCSPList?) {
        setOcspListCallsCount += 1
        setOcspListReceivedOcspList = ocspList
        setOcspListReceivedInvocations.append(ocspList)
        setOcspListClosure?(ocspList)
    }
    
   // MARK: - getPKICertificates

    var getPKICertificatesCallsCount = 0
    var getPKICertificatesCalled: Bool {
        getPKICertificatesCallsCount > 0
    }
    var getPKICertificatesReturnValue: PKICertificates?
    var getPKICertificatesClosure: (() -> PKICertificates?)?

    func getPKICertificates() -> PKICertificates? {
        getPKICertificatesCallsCount += 1
        return getPKICertificatesClosure.map({ $0() }) ?? getPKICertificatesReturnValue
    }
    
   // MARK: - set

    var setPkiCertificatesCallsCount = 0
    var setPkiCertificatesCalled: Bool {
        setPkiCertificatesCallsCount > 0
    }
    var setPkiCertificatesReceivedPkiCertificates: PKICertificates?
    var setPkiCertificatesReceivedInvocations: [PKICertificates?] = []
    var setPkiCertificatesClosure: ((PKICertificates?) -> Void)?

    func set(pkiCertificates: PKICertificates?) {
        setPkiCertificatesCallsCount += 1
        setPkiCertificatesReceivedPkiCertificates = pkiCertificates
        setPkiCertificatesReceivedInvocations.append(pkiCertificates)
        setPkiCertificatesClosure?(pkiCertificates)
    }
    
   // MARK: - getVauCertificate

    var getVauCertificateCallsCount = 0
    var getVauCertificateCalled: Bool {
        getVauCertificateCallsCount > 0
    }
    var getVauCertificateReturnValue: Data?
    var getVauCertificateClosure: (() -> Data?)?

    func getVauCertificate() -> Data? {
        getVauCertificateCallsCount += 1
        return getVauCertificateClosure.map({ $0() }) ?? getVauCertificateReturnValue
    }
    
   // MARK: - set

    var setVauCertificateCallsCount = 0
    var setVauCertificateCalled: Bool {
        setVauCertificateCallsCount > 0
    }
    var setVauCertificateReceivedVauCertificate: Data?
    var setVauCertificateReceivedInvocations: [Data?] = []
    var setVauCertificateClosure: ((Data?) -> Void)?

    func set(vauCertificate: Data?) {
        setVauCertificateCallsCount += 1
        setVauCertificateReceivedVauCertificate = vauCertificate
        setVauCertificateReceivedInvocations.append(vauCertificate)
        setVauCertificateClosure?(vauCertificate)
    }
    
   // MARK: - getVauCertificateOcspResponse

    var getVauCertificateOcspResponseCallsCount = 0
    var getVauCertificateOcspResponseCalled: Bool {
        getVauCertificateOcspResponseCallsCount > 0
    }
    var getVauCertificateOcspResponseReturnValue: Data?
    var getVauCertificateOcspResponseClosure: (() -> Data?)?

    func getVauCertificateOcspResponse() -> Data? {
        getVauCertificateOcspResponseCallsCount += 1
        return getVauCertificateOcspResponseClosure.map({ $0() }) ?? getVauCertificateOcspResponseReturnValue
    }
    
   // MARK: - set

    var setVauCertificateOcspResponseCallsCount = 0
    var setVauCertificateOcspResponseCalled: Bool {
        setVauCertificateOcspResponseCallsCount > 0
    }
    var setVauCertificateOcspResponseReceivedVauCertificateOcspResponse: Data?
    var setVauCertificateOcspResponseReceivedInvocations: [Data?] = []
    var setVauCertificateOcspResponseClosure: ((Data?) -> Void)?

    func set(vauCertificateOcspResponse: Data?) {
        setVauCertificateOcspResponseCallsCount += 1
        setVauCertificateOcspResponseReceivedVauCertificateOcspResponse = vauCertificateOcspResponse
        setVauCertificateOcspResponseReceivedInvocations.append(vauCertificateOcspResponse)
        setVauCertificateOcspResponseClosure?(vauCertificateOcspResponse)
    }
}
