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

    //MARK: - getOcspResponse

    public var getOcspResponseIssuerCnStringSerialNrStringDataCallsCount = 0
    public var getOcspResponseIssuerCnStringSerialNrStringDataCalled: Bool {
        return getOcspResponseIssuerCnStringSerialNrStringDataCallsCount > 0
    }
    public var getOcspResponseIssuerCnStringSerialNrStringDataReceivedArguments: (issuerCn: String, serialNr: String)?
    public var getOcspResponseIssuerCnStringSerialNrStringDataReceivedInvocations: [(issuerCn: String, serialNr: String)] = []
    public var getOcspResponseIssuerCnStringSerialNrStringDataReturnValue: Data?
    public var getOcspResponseIssuerCnStringSerialNrStringDataClosure: ((String, String) -> Data?)?

    public func getOcspResponse(issuerCn: String, serialNr: String) -> Data? {
        getOcspResponseIssuerCnStringSerialNrStringDataCallsCount += 1
        getOcspResponseIssuerCnStringSerialNrStringDataReceivedArguments = (issuerCn: issuerCn, serialNr: serialNr)
        getOcspResponseIssuerCnStringSerialNrStringDataReceivedInvocations.append((issuerCn: issuerCn, serialNr: serialNr))
        if let getOcspResponseIssuerCnStringSerialNrStringDataClosure = getOcspResponseIssuerCnStringSerialNrStringDataClosure {
            return getOcspResponseIssuerCnStringSerialNrStringDataClosure(issuerCn, serialNr)
        } else {
            return getOcspResponseIssuerCnStringSerialNrStringDataReturnValue
        }
    }

    //MARK: - setOcspResponse

    public var setOcspResponseIssuerCnStringSerialNrStringOcspResponseDataVoidCallsCount = 0
    public var setOcspResponseIssuerCnStringSerialNrStringOcspResponseDataVoidCalled: Bool {
        return setOcspResponseIssuerCnStringSerialNrStringOcspResponseDataVoidCallsCount > 0
    }
    public var setOcspResponseIssuerCnStringSerialNrStringOcspResponseDataVoidReceivedArguments: (issuerCn: String, serialNr: String, ocspResponse: Data?)?
    public var setOcspResponseIssuerCnStringSerialNrStringOcspResponseDataVoidReceivedInvocations: [(issuerCn: String, serialNr: String, ocspResponse: Data?)] = []
    public var setOcspResponseIssuerCnStringSerialNrStringOcspResponseDataVoidClosure: ((String, String, Data?) -> Void)?

    public func setOcspResponse(issuerCn: String, serialNr: String, ocspResponse: Data?) {
        setOcspResponseIssuerCnStringSerialNrStringOcspResponseDataVoidCallsCount += 1
        setOcspResponseIssuerCnStringSerialNrStringOcspResponseDataVoidReceivedArguments = (issuerCn: issuerCn, serialNr: serialNr, ocspResponse: ocspResponse)
        setOcspResponseIssuerCnStringSerialNrStringOcspResponseDataVoidReceivedInvocations.append((issuerCn: issuerCn, serialNr: serialNr, ocspResponse: ocspResponse))
        setOcspResponseIssuerCnStringSerialNrStringOcspResponseDataVoidClosure?(issuerCn, serialNr, ocspResponse)
    }

    //MARK: - resetOcspResponses

    public var resetOcspResponsesVoidCallsCount = 0
    public var resetOcspResponsesVoidCalled: Bool {
        return resetOcspResponsesVoidCallsCount > 0
    }
    public var resetOcspResponsesVoidClosure: (() -> Void)?

    public func resetOcspResponses() {
        resetOcspResponsesVoidCallsCount += 1
        resetOcspResponsesVoidClosure?()
    }


}
