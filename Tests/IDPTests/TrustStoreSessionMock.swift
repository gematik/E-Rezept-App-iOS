//
//  Copyright (c) 2021 gematik GmbH
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

import Combine
import Foundation
import OpenSSL
import TrustStore

// MARK: - TrustStoreSessionMock -

final class TrustStoreSessionMock: TrustStoreSession {
    // MARK: - loadVauCertificate

    var loadVauCertificateCallsCount = 0
    var loadVauCertificateCalled: Bool {
        loadVauCertificateCallsCount > 0
    }

    var loadVauCertificateReturnValue: AnyPublisher<X509, TrustStoreError>!
    var loadVauCertificateClosure: (() -> AnyPublisher<X509, TrustStoreError>)?

    func loadVauCertificate() -> AnyPublisher<X509, TrustStoreError> {
        loadVauCertificateCallsCount += 1
        return loadVauCertificateClosure.map { $0() } ?? loadVauCertificateReturnValue
    }

    // MARK: - validate

    var validateCertificateCallsCount = 0
    var validateCertificateCalled: Bool {
        validateCertificateCallsCount > 0
    }

    var validateCertificateReceivedCertificate: X509?
    var validateCertificateReceivedInvocations: [X509] = []
    var validateCertificateReturnValue: AnyPublisher<Bool, TrustStoreError>!
    var validateCertificateClosure: ((X509) -> AnyPublisher<Bool, TrustStoreError>)?

    func validate(certificate: X509) -> AnyPublisher<Bool, TrustStoreError> {
        validateCertificateCallsCount += 1
        validateCertificateReceivedCertificate = certificate
        validateCertificateReceivedInvocations.append(certificate)
        return validateCertificateClosure.map { $0(certificate) } ?? validateCertificateReturnValue
    }

    func reset() {}
}
