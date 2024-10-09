//
//  Copyright (c) 2024 gematik GmbH
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

protocol VAUCertificateProvider {
    func loadAndVerifyVauCertificate() -> AnyPublisher<VAUCertificate, VAUError>
}

protocol VAUCertificate {
    var brainpoolP256r1KeyExchangePublicKey: BrainpoolP256r1.KeyExchange.PublicKey? { get }
}

extension VAUSession: VAUCertificateProvider {
    // [REQ:gemSpec_Krypt:A_21222#4|7] Vau Certificate provider
    func loadAndVerifyVauCertificate() -> AnyPublisher<VAUCertificate, VAUError> {
        trustStoreSession.loadVauCertificate()
            .first()
            .mapError { $0.asVAUError() }
            .map { X509VAUCertificate(x509: $0) }
            .eraseToAnyPublisher()
    }
}

struct X509VAUCertificate: VAUCertificate {
    let x509: X509

    init(x509: X509) {
        self.x509 = x509
    }

    init(der: Data) throws {
        self.init(x509: try X509(der: der))
    }

    init(pem: Data) throws {
        self.init(x509: try X509(pem: pem))
    }

    var brainpoolP256r1KeyExchangePublicKey: BrainpoolP256r1.KeyExchange.PublicKey? {
        x509.brainpoolP256r1KeyExchangePublicKey()
    }
}
