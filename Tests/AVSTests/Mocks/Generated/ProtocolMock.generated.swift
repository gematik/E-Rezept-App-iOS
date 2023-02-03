// Generated using Sourcery 1.9.0 — https://github.com/krzysztofzablocki/Sourcery
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




















final class MockAVSClient: AVSClient {


    //MARK: - send

    var sendDataToCallsCount = 0
    var sendDataToCalled: Bool {
        return sendDataToCallsCount > 0
    }
    var sendDataToReceivedArguments: (data: Data, endpoint: AVSEndpoint)?
    var sendDataToReceivedInvocations: [(data: Data, endpoint: AVSEndpoint)] = []
    var sendDataToReturnValue: AnyPublisher<HTTPResponse, AVSError>!
    var sendDataToClosure: ((Data, AVSEndpoint) -> AnyPublisher<HTTPResponse, AVSError>)?

    func send(data: Data, to endpoint: AVSEndpoint) -> AnyPublisher<HTTPResponse, AVSError> {
        sendDataToCallsCount += 1
        sendDataToReceivedArguments = (data: data, endpoint: endpoint)
        sendDataToReceivedInvocations.append((data: data, endpoint: endpoint))
        if let sendDataToClosure = sendDataToClosure {
            return sendDataToClosure(data, endpoint)
        } else {
            return sendDataToReturnValue
        }
    }

}
final class MockAVSCmsEncrypter: AVSCmsEncrypter {


    //MARK: - cmsEncrypt

    var cmsEncryptRecipientsThrowableError: Error?
    var cmsEncryptRecipientsCallsCount = 0
    var cmsEncryptRecipientsCalled: Bool {
        return cmsEncryptRecipientsCallsCount > 0
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
        if let cmsEncryptRecipientsClosure = cmsEncryptRecipientsClosure {
            return try cmsEncryptRecipientsClosure(data, recipients)
        } else {
            return cmsEncryptRecipientsReturnValue
        }
    }

}
final class MockAVSMessageConverter: AVSMessageConverter {


    //MARK: - convert

    var convertRecipientsThrowableError: Error?
    var convertRecipientsCallsCount = 0
    var convertRecipientsCalled: Bool {
        return convertRecipientsCallsCount > 0
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
        if let convertRecipientsClosure = convertRecipientsClosure {
            return try convertRecipientsClosure(message, recipients)
        } else {
            return convertRecipientsReturnValue
        }
    }

}
