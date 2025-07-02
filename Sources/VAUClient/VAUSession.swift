//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import Foundation
import HTTPClient
import TrustStore

/// VAU Session that handles initial communication setup (e.g. requesting VAU certificate)
/// and provides HTTP Interceptor for further use
public class VAUSession {
    let vauServer: URL
    let vauAccessTokenProvider: VAUAccessTokenProvider
    let vauCryptoProvider: VAUCryptoProvider
    let vauStorage: VAUStorage
    let trustStoreSession: TrustStoreSession

    /// Initialize the VAU Session
    ///
    /// - Parameters:
    ///   - vauServer: the VAU server URL
    ///   - vauAccessTokenProvider: provides and keeps track of a token for VAU access
    ///   - vauCryptoProvider: provides necessary function for HTTP request/response encryption/decryption
    ///   - vauStorage: the VAU storage
    ///   - trustStoreSession: session that obtains the VAU encryption certificate
    public convenience init(
        vauServer: URL,
        vauAccessTokenProvider: VAUAccessTokenProvider,
        vauStorage: VAUStorage,
        trustStoreSession: TrustStoreSession
    ) {
        self.init(
            vauServer: vauServer,
            vauAccessTokenProvider: vauAccessTokenProvider,
            vauCryptoProvider: EciesVAUCryptoProvider(),
            vauStorage: vauStorage,
            trustStoreSession: trustStoreSession
        )
    }

    init(
        vauServer: URL,
        vauAccessTokenProvider: VAUAccessTokenProvider,
        vauCryptoProvider: VAUCryptoProvider,
        vauStorage: VAUStorage,
        trustStoreSession: TrustStoreSession
    ) {
        self.vauServer = vauServer
        self.vauAccessTokenProvider = vauAccessTokenProvider
        self.vauCryptoProvider = vauCryptoProvider
        self.vauStorage = vauStorage
        self.trustStoreSession = trustStoreSession
    }

    /// Provides the actual HTTP request interceptor that re-routes the original request to the VAU server.
    public func provideInterceptor() -> Interceptor {
        VAUInterceptor(
            vauAccessTokenProvider: vauAccessTokenProvider,
            vauCertificateProvider: self,
            vauCryptoProvider: vauCryptoProvider,
            vauEndpointHandler: self
        )
    }
}
