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
import Foundation
import HTTPClient

struct UpdateChecker {
    var isUpdateAvailable: @Sendable () async -> Bool
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
    static var liveValue = UpdateCheckerFactory { httpClient, configuration in
        UpdateChecker {
            var certListEndpoint: URL {
                configuration.erp.appendingPathComponent("CertList")
            }

            let request = URLRequest(url: certListEndpoint)
            guard let (_, _, status) = try? await httpClient.sendPublisher(request: request).async() else {
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
