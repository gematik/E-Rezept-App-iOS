// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

import Combine
import Foundation
import OpenSSL

@testable import TrustStore
























public class TrustStoreClientMock: TrustStoreClient {

    public init() {}



    //MARK: - loadCertListFromServer

    public var loadCertListFromServerAnyPublisherCertListTrustStoreErrorCallsCount = 0
    public var loadCertListFromServerAnyPublisherCertListTrustStoreErrorCalled: Bool {
        return loadCertListFromServerAnyPublisherCertListTrustStoreErrorCallsCount > 0
    }
    public var loadCertListFromServerAnyPublisherCertListTrustStoreErrorReturnValue: AnyPublisher<CertList, TrustStoreError>!
    public var loadCertListFromServerAnyPublisherCertListTrustStoreErrorClosure: (() -> AnyPublisher<CertList, TrustStoreError>)?

    public func loadCertListFromServer() -> AnyPublisher<CertList, TrustStoreError> {
        loadCertListFromServerAnyPublisherCertListTrustStoreErrorCallsCount += 1
        if let loadCertListFromServerAnyPublisherCertListTrustStoreErrorClosure = loadCertListFromServerAnyPublisherCertListTrustStoreErrorClosure {
            return loadCertListFromServerAnyPublisherCertListTrustStoreErrorClosure()
        } else {
            return loadCertListFromServerAnyPublisherCertListTrustStoreErrorReturnValue
        }
    }

    //MARK: - loadOCSPListFromServer

    public var loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorCallsCount = 0
    public var loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorCalled: Bool {
        return loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorCallsCount > 0
    }
    public var loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorReturnValue: AnyPublisher<OCSPList, TrustStoreError>!
    public var loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorClosure: (() -> AnyPublisher<OCSPList, TrustStoreError>)?

    public func loadOCSPListFromServer() -> AnyPublisher<OCSPList, TrustStoreError> {
        loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorCallsCount += 1
        if let loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorClosure = loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorClosure {
            return loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorClosure()
        } else {
            return loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorReturnValue
        }
    }

    //MARK: - loadPKICertificatesFromServer

    public var loadPKICertificatesFromServerRootSubjectCnStringPKICertificatesThrowableError: (any Error)?
    public var loadPKICertificatesFromServerRootSubjectCnStringPKICertificatesCallsCount = 0
    public var loadPKICertificatesFromServerRootSubjectCnStringPKICertificatesCalled: Bool {
        return loadPKICertificatesFromServerRootSubjectCnStringPKICertificatesCallsCount > 0
    }
    public var loadPKICertificatesFromServerRootSubjectCnStringPKICertificatesReceivedRootSubjectCn: (String)?
    public var loadPKICertificatesFromServerRootSubjectCnStringPKICertificatesReceivedInvocations: [(String)] = []
    public var loadPKICertificatesFromServerRootSubjectCnStringPKICertificatesReturnValue: PKICertificates!
    public var loadPKICertificatesFromServerRootSubjectCnStringPKICertificatesClosure: ((String) async throws -> PKICertificates)?

    public func loadPKICertificatesFromServer(rootSubjectCn: String) async throws -> PKICertificates {
        loadPKICertificatesFromServerRootSubjectCnStringPKICertificatesCallsCount += 1
        loadPKICertificatesFromServerRootSubjectCnStringPKICertificatesReceivedRootSubjectCn = rootSubjectCn
        loadPKICertificatesFromServerRootSubjectCnStringPKICertificatesReceivedInvocations.append(rootSubjectCn)
        if let error = loadPKICertificatesFromServerRootSubjectCnStringPKICertificatesThrowableError {
            throw error
        }
        if let loadPKICertificatesFromServerRootSubjectCnStringPKICertificatesClosure = loadPKICertificatesFromServerRootSubjectCnStringPKICertificatesClosure {
            return try await loadPKICertificatesFromServerRootSubjectCnStringPKICertificatesClosure(rootSubjectCn)
        } else {
            return loadPKICertificatesFromServerRootSubjectCnStringPKICertificatesReturnValue
        }
    }

    //MARK: - loadVauCertificateFromServer

    public var loadVauCertificateFromServerDataThrowableError: (any Error)?
    public var loadVauCertificateFromServerDataCallsCount = 0
    public var loadVauCertificateFromServerDataCalled: Bool {
        return loadVauCertificateFromServerDataCallsCount > 0
    }
    public var loadVauCertificateFromServerDataReturnValue: Data!
    public var loadVauCertificateFromServerDataClosure: (() async throws -> Data)?

    public func loadVauCertificateFromServer() async throws -> Data {
        loadVauCertificateFromServerDataCallsCount += 1
        if let error = loadVauCertificateFromServerDataThrowableError {
            throw error
        }
        if let loadVauCertificateFromServerDataClosure = loadVauCertificateFromServerDataClosure {
            return try await loadVauCertificateFromServerDataClosure()
        } else {
            return loadVauCertificateFromServerDataReturnValue
        }
    }

    //MARK: - loadOcspResponseFromServer

    public var loadOcspResponseFromServerIssuerCnStringSerialNrStringDataThrowableError: (any Error)?
    public var loadOcspResponseFromServerIssuerCnStringSerialNrStringDataCallsCount = 0
    public var loadOcspResponseFromServerIssuerCnStringSerialNrStringDataCalled: Bool {
        return loadOcspResponseFromServerIssuerCnStringSerialNrStringDataCallsCount > 0
    }
    public var loadOcspResponseFromServerIssuerCnStringSerialNrStringDataReceivedArguments: (issuerCn: String, serialNr: String)?
    public var loadOcspResponseFromServerIssuerCnStringSerialNrStringDataReceivedInvocations: [(issuerCn: String, serialNr: String)] = []
    public var loadOcspResponseFromServerIssuerCnStringSerialNrStringDataReturnValue: Data!
    public var loadOcspResponseFromServerIssuerCnStringSerialNrStringDataClosure: ((String, String) async throws -> Data)?

    public func loadOcspResponseFromServer(issuerCn: String, serialNr: String) async throws -> Data {
        loadOcspResponseFromServerIssuerCnStringSerialNrStringDataCallsCount += 1
        loadOcspResponseFromServerIssuerCnStringSerialNrStringDataReceivedArguments = (issuerCn: issuerCn, serialNr: serialNr)
        loadOcspResponseFromServerIssuerCnStringSerialNrStringDataReceivedInvocations.append((issuerCn: issuerCn, serialNr: serialNr))
        if let error = loadOcspResponseFromServerIssuerCnStringSerialNrStringDataThrowableError {
            throw error
        }
        if let loadOcspResponseFromServerIssuerCnStringSerialNrStringDataClosure = loadOcspResponseFromServerIssuerCnStringSerialNrStringDataClosure {
            return try await loadOcspResponseFromServerIssuerCnStringSerialNrStringDataClosure(issuerCn, serialNr)
        } else {
            return loadOcspResponseFromServerIssuerCnStringSerialNrStringDataReturnValue
        }
    }


}
public class TrustStoreStorageMock: TrustStoreStorage {

    public init() {}

    public var certList: AnyPublisher<CertList?, Never> {
        get { return underlyingCertList }
        set(value) { underlyingCertList = value }
    }
    public var underlyingCertList: (AnyPublisher<CertList?, Never>)!
    public var ocspList: AnyPublisher<OCSPList?, Never> {
        get { return underlyingOcspList }
        set(value) { underlyingOcspList = value }
    }
    public var underlyingOcspList: (AnyPublisher<OCSPList?, Never>)!


    //MARK: - set

    public var setCertListCertListVoidCallsCount = 0
    public var setCertListCertListVoidCalled: Bool {
        return setCertListCertListVoidCallsCount > 0
    }
    public var setCertListCertListVoidReceivedCertList: (CertList)?
    public var setCertListCertListVoidReceivedInvocations: [(CertList)?] = []
    public var setCertListCertListVoidClosure: ((CertList?) -> Void)?

    public func set(certList: CertList?) {
        setCertListCertListVoidCallsCount += 1
        setCertListCertListVoidReceivedCertList = certList
        setCertListCertListVoidReceivedInvocations.append(certList)
        setCertListCertListVoidClosure?(certList)
    }

    //MARK: - set

    public var setOcspListOCSPListVoidCallsCount = 0
    public var setOcspListOCSPListVoidCalled: Bool {
        return setOcspListOCSPListVoidCallsCount > 0
    }
    public var setOcspListOCSPListVoidReceivedOcspList: (OCSPList)?
    public var setOcspListOCSPListVoidReceivedInvocations: [(OCSPList)?] = []
    public var setOcspListOCSPListVoidClosure: ((OCSPList?) -> Void)?

    public func set(ocspList: OCSPList?) {
        setOcspListOCSPListVoidCallsCount += 1
        setOcspListOCSPListVoidReceivedOcspList = ocspList
        setOcspListOCSPListVoidReceivedInvocations.append(ocspList)
        setOcspListOCSPListVoidClosure?(ocspList)
    }

    //MARK: - getPKICertificates

    public var getPKICertificatesPKICertificatesCallsCount = 0
    public var getPKICertificatesPKICertificatesCalled: Bool {
        return getPKICertificatesPKICertificatesCallsCount > 0
    }
    public var getPKICertificatesPKICertificatesReturnValue: PKICertificates?
    public var getPKICertificatesPKICertificatesClosure: (() -> PKICertificates?)?

    public func getPKICertificates() -> PKICertificates? {
        getPKICertificatesPKICertificatesCallsCount += 1
        if let getPKICertificatesPKICertificatesClosure = getPKICertificatesPKICertificatesClosure {
            return getPKICertificatesPKICertificatesClosure()
        } else {
            return getPKICertificatesPKICertificatesReturnValue
        }
    }

    //MARK: - set

    public var setPkiCertificatesPKICertificatesVoidCallsCount = 0
    public var setPkiCertificatesPKICertificatesVoidCalled: Bool {
        return setPkiCertificatesPKICertificatesVoidCallsCount > 0
    }
    public var setPkiCertificatesPKICertificatesVoidReceivedPkiCertificates: (PKICertificates)?
    public var setPkiCertificatesPKICertificatesVoidReceivedInvocations: [(PKICertificates)?] = []
    public var setPkiCertificatesPKICertificatesVoidClosure: ((PKICertificates?) -> Void)?

    public func set(pkiCertificates: PKICertificates?) {
        setPkiCertificatesPKICertificatesVoidCallsCount += 1
        setPkiCertificatesPKICertificatesVoidReceivedPkiCertificates = pkiCertificates
        setPkiCertificatesPKICertificatesVoidReceivedInvocations.append(pkiCertificates)
        setPkiCertificatesPKICertificatesVoidClosure?(pkiCertificates)
    }

    //MARK: - getVauCertificate

    public var getVauCertificateDataCallsCount = 0
    public var getVauCertificateDataCalled: Bool {
        return getVauCertificateDataCallsCount > 0
    }
    public var getVauCertificateDataReturnValue: Data?
    public var getVauCertificateDataClosure: (() -> Data?)?

    public func getVauCertificate() -> Data? {
        getVauCertificateDataCallsCount += 1
        if let getVauCertificateDataClosure = getVauCertificateDataClosure {
            return getVauCertificateDataClosure()
        } else {
            return getVauCertificateDataReturnValue
        }
    }

    //MARK: - set

    public var setVauCertificateDataVoidCallsCount = 0
    public var setVauCertificateDataVoidCalled: Bool {
        return setVauCertificateDataVoidCallsCount > 0
    }
    public var setVauCertificateDataVoidReceivedVauCertificate: (Data)?
    public var setVauCertificateDataVoidReceivedInvocations: [(Data)?] = []
    public var setVauCertificateDataVoidClosure: ((Data?) -> Void)?

    public func set(vauCertificate: Data?) {
        setVauCertificateDataVoidCallsCount += 1
        setVauCertificateDataVoidReceivedVauCertificate = vauCertificate
        setVauCertificateDataVoidReceivedInvocations.append(vauCertificate)
        setVauCertificateDataVoidClosure?(vauCertificate)
    }

    //MARK: - getVauCertificateOcspResponse

    public var getVauCertificateOcspResponseDataCallsCount = 0
    public var getVauCertificateOcspResponseDataCalled: Bool {
        return getVauCertificateOcspResponseDataCallsCount > 0
    }
    public var getVauCertificateOcspResponseDataReturnValue: Data?
    public var getVauCertificateOcspResponseDataClosure: (() -> Data?)?

    public func getVauCertificateOcspResponse() -> Data? {
        getVauCertificateOcspResponseDataCallsCount += 1
        if let getVauCertificateOcspResponseDataClosure = getVauCertificateOcspResponseDataClosure {
            return getVauCertificateOcspResponseDataClosure()
        } else {
            return getVauCertificateOcspResponseDataReturnValue
        }
    }

    //MARK: - set

    public var setVauCertificateOcspResponseDataVoidCallsCount = 0
    public var setVauCertificateOcspResponseDataVoidCalled: Bool {
        return setVauCertificateOcspResponseDataVoidCallsCount > 0
    }
    public var setVauCertificateOcspResponseDataVoidReceivedVauCertificateOcspResponse: (Data)?
    public var setVauCertificateOcspResponseDataVoidReceivedInvocations: [(Data)?] = []
    public var setVauCertificateOcspResponseDataVoidClosure: ((Data?) -> Void)?

    public func set(vauCertificateOcspResponse: Data?) {
        setVauCertificateOcspResponseDataVoidCallsCount += 1
        setVauCertificateOcspResponseDataVoidReceivedVauCertificateOcspResponse = vauCertificateOcspResponse
        setVauCertificateOcspResponseDataVoidReceivedInvocations.append(vauCertificateOcspResponse)
        setVauCertificateOcspResponseDataVoidClosure?(vauCertificateOcspResponse)
    }


}
