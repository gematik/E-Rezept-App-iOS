// swiftlint:disable:this file_name
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

import Dependencies
import eRpKit
import FHIRClient
import Foundation
import HTTPClient
import HTTPClientLive
import IDP
import IDPLive
import Sharing
import TrustStore
import VAUClient

extension FHIRClientServiceFactory: DependencyKey {
    public static var liveValue: FHIRClientServiceFactory = {
        let erpClient: LockIsolated<[String: FHIRClient]> = LockIsolated([:])

        return .init {
            @Dependency(\.userDataStore.appConfiguration) var appConfiguration

            let interceptors: [Interceptor] = [
                AdditionalHeaderInterceptor(additionalHeader: appConfiguration.fhirVzdAdditionalHeader),
                LoggingInterceptor(log: .body), // Logging interceptor (DEBUG ONLY)
                DebugLiveLogger.LogInterceptor(),
            ]

            // Remote FHIR data source configuration
            let fhirVZDHttpClient: HTTPClient = DefaultHTTPClient(
                urlSessionConfiguration: .ephemeral,
                interceptors: interceptors
            )

            return FHIRClient(
                server: appConfiguration.fhirVzd,
                httpClient: fhirVZDHttpClient
            )
        } erpClient: {
            @Dependency(\.userDataStore.appConfiguration) var appConfiguration
            @Shared(.selectedProfileId) var selectedProfileId: UUID

            // Unique config name per profile configuration combination, workaround until IDPSession is using ne storage
            // dependency
            let configName = appConfiguration.name + "-\(selectedProfileId)"

            let client = erpClient.withValue { $0[configName] }
            if let client {
                return client
            }

            let trustStoreHttpClient: HTTPClient = {
                let interceptors: [Interceptor] = [
                    AdditionalHeaderInterceptor(additionalHeader: appConfiguration.erpAdditionalHeader),
                    LoggingInterceptor(log: .body), // Logging interceptor (DEBUG ONLY)
                    DebugLiveLogger.LogInterceptor(),
                ]

                // Remote FHIR data source configuration
                return DefaultHTTPClient(
                    urlSessionConfiguration: .ephemeral,
                    interceptors: interceptors
                )
            }()

            let vauStorage: VAUStorage = {
                guard let vauStorageFilePath = try? FileManager.default.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false
                )
                .appendingPathComponent("VauStorage") else {
                    preconditionFailure("Could not create a filePath for the vau storage.")
                }
                return FileVAUStorage(vauStorageBaseFilePath: vauStorageFilePath)
            }()

            let secureUserStore: SecureUserDataStore = {
                @Dependency(\.schedulers) var schedulers

                return KeychainStorage(profileId: selectedProfileId, schedulers: schedulers)
            }()

            let idpHttpClient: HTTPClient = {
                let interceptors: [Interceptor] = [
                    AdditionalHeaderInterceptor(additionalHeader: appConfiguration.idpAdditionalHeader),
                    LoggingInterceptor(log: .body), // Logging interceptor (DEBUG ONLY)
                    DebugLiveLogger.LogInterceptor(),
                ]

                // Remote FHIR data source configuration
                return DefaultHTTPClient(
                    urlSessionConfiguration: .ephemeral,
                    interceptors: interceptors
                )
            }()

            @Dependency(\.extAuthRequestStorage) var extAuthRequestStorage

            let trustStoreSession: TrustStoreSession = {
                guard let trustStoreStorageFilePath = try? FileManager.default.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false
                )
                .appendingPathComponent("TrustStoreStorage") else {
                    preconditionFailure("Could not create a filePath for the truststore storage.")
                }
                let trustStoreStorage = TrustStoreFileStorage(trustStoreStorageBaseFilePath: trustStoreStorageFilePath)
                return DefaultTrustStoreSession(
                    serverURL: appConfiguration.erp,
                    trustAnchor: appConfiguration.trustAnchor,
                    trustStoreStorage: trustStoreStorage,
                    httpClient: trustStoreHttpClient
                )
            }()
            let idpSession: IDPSession = {
                @Dependency(\.schedulers) var schedulers
                let idpSessionConfig = DefaultIDPSession.Configuration(
                    clientId: appConfiguration.clientId,
                    redirectURI: appConfiguration.redirectUri,
                    extAuthRedirectURI: appConfiguration.extAuthRedirectUri,
                    discoveryURL: appConfiguration.idp,
                    scopes: appConfiguration.idpDefaultScopes
                )

                return DefaultIDPSession(
                    config: idpSessionConfig,
                    // [REQ:gemSpec_IDP_Frontend:A_21328#2] Keychain storage encrypts session tokens
                    // [REQ:gemSpec_eRp_FdV:A_20184] Keychain storage encrypts session/ssl tokens
                    storage: secureUserStore,
                    schedulers: schedulers,
                    httpClient: idpHttpClient,
                    trustStoreSession: trustStoreSession,
                    extAuthRequestStorage: extAuthRequestStorage
                )
            }()

            let session = VAUSession(
                vauServer: appConfiguration.erp,
                vauAccessTokenProvider: idpSession.asVAUAccessTokenProvider(),
                vauStorage: vauStorage,
                trustStoreSession: trustStoreSession
            )

            // [REQ:gemSpec_IDP_Frontend:A_21325#2] Interceptor order defines what is encrypted via VAU
            let interceptors: [Interceptor] = [
                AdditionalHeaderInterceptor(additionalHeader: appConfiguration.erpAdditionalHeader),
                IDPInterceptor(session: idpSession),
                LoggingInterceptor(log: .body), // Logging interceptor (DEBUG ONLY)
                DebugLiveLogger.LogInterceptor(),
                VAUInterceptor(vauSession: session),
                AdditionalHeaderInterceptor(additionalHeader: appConfiguration.erpAdditionalHeader),
            ]

            // Remote FHIR data source configuration
            let httpClient = DefaultHTTPClient(
                urlSessionConfiguration: .ephemeral,
                interceptors: interceptors
            )

            let fhirClient = FHIRClient(
                server: appConfiguration.base,
                httpClient: httpClient
            )
            erpClient.withValue { $0[configName] = fhirClient }

            return fhirClient
        }
    }()
}
