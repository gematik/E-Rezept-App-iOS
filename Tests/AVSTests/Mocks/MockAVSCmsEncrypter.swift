//
//  Copyright (c) 2022 gematik GmbH
//  
//  Licensed under the EUPL, Version 1.2 or – as soon they will be approved by
//  the European Commission - subsequent versions of the EUPL (the Licence);
//  You may not use this work except in compliance with the Licence.
//  You may obtain a copy of the Licence at:
//  
//      https://joinup.ec.europa.eu/software/page/eupl
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the Licence for the specific language governing permissions and
//  limitations under the Licence.
//  
//

@testable import AVS
import Foundation
import OpenSSL

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
        return try cmsEncryptRecipientsClosure.map { try $0(data, recipients) } ?? cmsEncryptRecipientsReturnValue
    }
}
