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
import HTTPClient
import OpenSSL

@testable import AVS
























class AVSClientMock: AVSClient {




    //MARK: - send

    var sendDataDataToEndpointAVSEndpoint_DataHTTPURLResponseHTTPStatusCodeThrowableError: (any Error)?
    var sendDataDataToEndpointAVSEndpoint_DataHTTPURLResponseHTTPStatusCodeCallsCount = 0
    var sendDataDataToEndpointAVSEndpoint_DataHTTPURLResponseHTTPStatusCodeCalled: Bool {
        return sendDataDataToEndpointAVSEndpoint_DataHTTPURLResponseHTTPStatusCodeCallsCount > 0
    }
    var sendDataDataToEndpointAVSEndpoint_DataHTTPURLResponseHTTPStatusCodeReceivedArguments: (data: Data, endpoint: AVSEndpoint)?
    var sendDataDataToEndpointAVSEndpoint_DataHTTPURLResponseHTTPStatusCodeReceivedInvocations: [(data: Data, endpoint: AVSEndpoint)] = []
    var sendDataDataToEndpointAVSEndpoint_DataHTTPURLResponseHTTPStatusCodeReturnValue: HTTPResponse!
    var sendDataDataToEndpointAVSEndpoint_DataHTTPURLResponseHTTPStatusCodeClosure: ((Data, AVSEndpoint) async throws -> HTTPResponse)?

    func send(data: Data, to endpoint: AVSEndpoint) async throws -> HTTPResponse {
        sendDataDataToEndpointAVSEndpoint_DataHTTPURLResponseHTTPStatusCodeCallsCount += 1
        sendDataDataToEndpointAVSEndpoint_DataHTTPURLResponseHTTPStatusCodeReceivedArguments = (data: data, endpoint: endpoint)
        sendDataDataToEndpointAVSEndpoint_DataHTTPURLResponseHTTPStatusCodeReceivedInvocations.append((data: data, endpoint: endpoint))
        if let error = sendDataDataToEndpointAVSEndpoint_DataHTTPURLResponseHTTPStatusCodeThrowableError {
            throw error
        }
        if let sendDataDataToEndpointAVSEndpoint_DataHTTPURLResponseHTTPStatusCodeClosure = sendDataDataToEndpointAVSEndpoint_DataHTTPURLResponseHTTPStatusCodeClosure {
            return try await sendDataDataToEndpointAVSEndpoint_DataHTTPURLResponseHTTPStatusCodeClosure(data, endpoint)
        } else {
            return sendDataDataToEndpointAVSEndpoint_DataHTTPURLResponseHTTPStatusCodeReturnValue
        }
    }


}
class AVSCmsEncrypterMock: AVSCmsEncrypter {




    //MARK: - cmsEncrypt

    var cmsEncryptDataDataRecipientsX509DataThrowableError: (any Error)?
    var cmsEncryptDataDataRecipientsX509DataCallsCount = 0
    var cmsEncryptDataDataRecipientsX509DataCalled: Bool {
        return cmsEncryptDataDataRecipientsX509DataCallsCount > 0
    }
    var cmsEncryptDataDataRecipientsX509DataReceivedArguments: (data: Data, recipients: [X509])?
    var cmsEncryptDataDataRecipientsX509DataReceivedInvocations: [(data: Data, recipients: [X509])] = []
    var cmsEncryptDataDataRecipientsX509DataReturnValue: Data!
    var cmsEncryptDataDataRecipientsX509DataClosure: ((Data, [X509]) throws -> Data)?

    func cmsEncrypt(_ data: Data, recipients: [X509]) throws -> Data {
        cmsEncryptDataDataRecipientsX509DataCallsCount += 1
        cmsEncryptDataDataRecipientsX509DataReceivedArguments = (data: data, recipients: recipients)
        cmsEncryptDataDataRecipientsX509DataReceivedInvocations.append((data: data, recipients: recipients))
        if let error = cmsEncryptDataDataRecipientsX509DataThrowableError {
            throw error
        }
        if let cmsEncryptDataDataRecipientsX509DataClosure = cmsEncryptDataDataRecipientsX509DataClosure {
            return try cmsEncryptDataDataRecipientsX509DataClosure(data, recipients)
        } else {
            return cmsEncryptDataDataRecipientsX509DataReturnValue
        }
    }


}
class AVSMessageConverterMock: AVSMessageConverter {




    //MARK: - convert

    var convertMessageAVSMessageRecipientsX509DataThrowableError: (any Error)?
    var convertMessageAVSMessageRecipientsX509DataCallsCount = 0
    var convertMessageAVSMessageRecipientsX509DataCalled: Bool {
        return convertMessageAVSMessageRecipientsX509DataCallsCount > 0
    }
    var convertMessageAVSMessageRecipientsX509DataReceivedArguments: (message: AVSMessage, recipients: [X509])?
    var convertMessageAVSMessageRecipientsX509DataReceivedInvocations: [(message: AVSMessage, recipients: [X509])] = []
    var convertMessageAVSMessageRecipientsX509DataReturnValue: Data!
    var convertMessageAVSMessageRecipientsX509DataClosure: ((AVSMessage, [X509]) throws -> Data)?

    func convert(_ message: AVSMessage, recipients: [X509]) throws -> Data {
        convertMessageAVSMessageRecipientsX509DataCallsCount += 1
        convertMessageAVSMessageRecipientsX509DataReceivedArguments = (message: message, recipients: recipients)
        convertMessageAVSMessageRecipientsX509DataReceivedInvocations.append((message: message, recipients: recipients))
        if let error = convertMessageAVSMessageRecipientsX509DataThrowableError {
            throw error
        }
        if let convertMessageAVSMessageRecipientsX509DataClosure = convertMessageAVSMessageRecipientsX509DataClosure {
            return try convertMessageAVSMessageRecipientsX509DataClosure(message, recipients)
        } else {
            return convertMessageAVSMessageRecipientsX509DataReturnValue
        }
    }


}
