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
@testable import TrustStore

// swiftlint:disable all
class TrustStoreClientMock: TrustStoreClient {
    var loadCertListFromServer_CallsCount = 0
    var loadCertListFromServer_Called: Bool {
        loadCertListFromServer_CallsCount > 0
    }

    var certList: CertList?
    func loadCertListFromServer() -> AnyPublisher<CertList, TrustStoreError> {
        Deferred { () -> AnyPublisher<CertList, TrustStoreError> in
            self.loadCertListFromServer_CallsCount += 1
            guard let certList = self.certList else {
                return Fail(error: TrustStoreError.internalError("No cert list available from TrustStoreClientMock"))
                    .eraseToAnyPublisher()
            }
            return Just(certList)
                .setFailureType(to: TrustStoreError.self)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    var loadOCSPListFromServer_CallsCount = 0
    var loadOCSPListFromServer_Called: Bool {
        loadOCSPListFromServer_CallsCount > 0
    }

    var ocspList: OCSPList?
    func loadOCSPListFromServer() -> AnyPublisher<OCSPList, TrustStoreError> {
        Deferred { () -> AnyPublisher<OCSPList, TrustStoreError> in
            self.loadOCSPListFromServer_CallsCount += 1
            guard let ocspList = self.ocspList else {
                return Fail(error: TrustStoreError.internalError("No OCSP list available from TrustStoreClientMock"))
                    .eraseToAnyPublisher()
            }
            return Just(ocspList)
                .setFailureType(to: TrustStoreError.self)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
