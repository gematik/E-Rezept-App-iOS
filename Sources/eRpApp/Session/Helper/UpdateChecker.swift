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

import AsyncHelpers
import Dependencies
import DependenciesMacros
import Foundation
import HTTPClient
import HTTPClientLive
import Settings

@DependencyClient
struct UpdateChecker {
    var isUpdateAvailable: @Sendable () async -> Bool = {
        false
    }
}

extension DependencyValues {
    var updateChecker: UpdateChecker {
        get { self[UpdateChecker.self] }
        set { self[UpdateChecker.self] = newValue }
    }
}

extension UpdateChecker: DependencyKey {
    static var liveValue = Self {
        @Shared(.isDemoMode) var isDemoMode

        if isDemoMode {
            return await Self.demoValue.isUpdateAvailable()
        }
        return await Self.defaultImplementation.isUpdateAvailable()
    }
}

extension UpdateChecker: TestDependencyKey {
    static var testValue: UpdateChecker = Self()
}

extension UpdateChecker {
    /// Demo mode implemetation
    static var demoValue: UpdateChecker = Self {
        false
    }

    static var defaultImplementation: UpdateChecker {
        Self {
            @Dependency(\.updateCheckerFactory) var updateCheckerFactory
            @Dependency(\.userDataStore.appConfiguration) var appConfiguration

            let interceptors: [Interceptor] = [
                AdditionalHeaderInterceptor(additionalHeader: appConfiguration.erpAdditionalHeader),
                LoggingInterceptor(log: .body),
                DebugLiveLogger.LogInterceptor(),
            ]
            let client = DefaultHTTPClient(urlSessionConfiguration: .ephemeral, interceptors: interceptors)

            return await updateCheckerFactory.updateChecker(client, appConfiguration).isUpdateAvailable()
        }
    }
}

struct UpdateCheckerFactory {
    var updateChecker: (HTTPClient, AppConfiguration) -> UpdateChecker
}

extension DependencyValues {
    var updateCheckerFactory: UpdateCheckerFactory {
        get { self[UpdateCheckerFactory.self] }
        set { self[UpdateCheckerFactory.self] = newValue }
    }
}

extension UpdateCheckerFactory: DependencyKey {
    static var liveValue = UpdateCheckerFactory { httpClient, appConfiguration in
        UpdateChecker {
            var vauCertificateEndpoint: URL {
                appConfiguration.erp.appendingPathComponent("VAUCertificate")
            }

            let request = URLRequest(url: vauCertificateEndpoint)
            guard let (_, _, status) = try? await httpClient.send(request: request) else {
                return false
            }

            return status == .unauthorized
        }
    }

    static func test() -> UpdateCheckerFactory {
        UpdateCheckerFactory { _, _ in
            .init {
                false
            }
        }
    }
}
