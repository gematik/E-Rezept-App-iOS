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
            guard let (_, _, status) = try? await httpClient.send(request: request).async() else {
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
