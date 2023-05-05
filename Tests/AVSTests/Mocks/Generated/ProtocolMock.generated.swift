// Generated using Sourcery 2.0.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation
import HTTPClient
import OpenSSL

@testable import AVS

/// AUTO GENERATED – DO NOT EDIT
///
/// Use sourcery to update this file.
/// NOTE: If imports are missing/superfluous then add/remove them in the .sourcery.yml in the project's root.
















// MARK: - MockAVSClient -

final class MockAVSClient: AVSClient {
    
   // MARK: - send

    var sendDataToCallsCount = 0
    var sendDataToCalled: Bool {
        sendDataToCallsCount > 0
    }
    var sendDataToReceivedArguments: (data: Data, endpoint: AVSEndpoint)?
    var sendDataToReceivedInvocations: [(data: Data, endpoint: AVSEndpoint)] = []
    var sendDataToReturnValue: AnyPublisher<HTTPResponse, AVSError>!
    var sendDataToClosure: ((Data, AVSEndpoint) -> AnyPublisher<HTTPResponse, AVSError>)?

    func send(data: Data, to endpoint: AVSEndpoint) -> AnyPublisher<HTTPResponse, AVSError> {
        sendDataToCallsCount += 1
        sendDataToReceivedArguments = (data: data, endpoint: endpoint)
        sendDataToReceivedInvocations.append((data: data, endpoint: endpoint))
        return sendDataToClosure.map({ $0(data, endpoint) }) ?? sendDataToReturnValue
    }
}


// MARK: - MockAVSCmsEncrypter -

final class MockAVSCmsEncrypter: AVSCmsEncrypter {
    
   // MARK: - cmsEncrypt

    var cmsEncryptRecipientsThrowableError: Error?
    var cmsEncryptRecipientsCallsCount = 0
    var cmsEncryptRecipientsCalled: Bool {
        cmsEncryptRecipientsCallsCount > 0
    }
    var cmsEncryptRecipientsReceivedArguments: (data: Data, recipients: [X509])?
    var cmsEncryptRecipientsReceivedInvocations: [(data: Data, recipients: [X509])] = []
    var cmsEncryptRecipientsReturnValue: Data!
    var cmsEncryptRecipientsClosure: ((Data, [X509]) throws -> Data)?

    func cmsEncrypt(_ data: Data, recipients: [X509]) throws -> Data {
        if let error = cmsEncryptRecipientsThrowableError {
            throw error
        }
        cmsEncryptRecipientsCallsCount += 1
        cmsEncryptRecipientsReceivedArguments = (data: data, recipients: recipients)
        cmsEncryptRecipientsReceivedInvocations.append((data: data, recipients: recipients))
        return try cmsEncryptRecipientsClosure.map({ try $0(data, recipients) }) ?? cmsEncryptRecipientsReturnValue
    }
}


// MARK: - MockAVSMessageConverter -

final class MockAVSMessageConverter: AVSMessageConverter {
    
   // MARK: - convert

    var convertRecipientsThrowableError: Error?
    var convertRecipientsCallsCount = 0
    var convertRecipientsCalled: Bool {
        convertRecipientsCallsCount > 0
    }
    var convertRecipientsReceivedArguments: (message: AVSMessage, recipients: [X509])?
    var convertRecipientsReceivedInvocations: [(message: AVSMessage, recipients: [X509])] = []
    var convertRecipientsReturnValue: Data!
    var convertRecipientsClosure: ((AVSMessage, [X509]) throws -> Data)?

    func convert(_ message: AVSMessage, recipients: [X509]) throws -> Data {
        if let error = convertRecipientsThrowableError {
            throw error
        }
        convertRecipientsCallsCount += 1
        convertRecipientsReceivedArguments = (message: message, recipients: recipients)
        convertRecipientsReceivedInvocations.append((message: message, recipients: recipients))
        return try convertRecipientsClosure.map({ try $0(message, recipients) }) ?? convertRecipientsReturnValue
    }
}
