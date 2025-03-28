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
