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
import SwiftUI

protocol ResourceHandler {
    func canOpenURL(_ url: URL) -> Bool

    func open(_ url: URL)

    #if compiler(>=6.0)
    func open(_ url: URL,
              options: [UIApplication.OpenExternalURLOptionsKey: Any],
              completionHandler completion: (@MainActor @Sendable (Bool) -> Void)?)
    #else
    func open(_ url: URL,
              options: [UIApplication.OpenExternalURLOptionsKey: Any],
              completionHandler completion: ((Bool) -> Void)?)
    #endif
}

extension UIApplication: ResourceHandler {
    func open(_ url: URL) {
        open(url, options: [:], completionHandler: nil)
    }
}

// MARK: TCA Dependency

struct ResourceHandlerDependency: DependencyKey {
    static let liveValue: ResourceHandler = UIApplication.shared

    static let previewValue: ResourceHandler = UIApplication.shared

    static let testValue: ResourceHandler = UnimplementedResourceHandler()
}

extension DependencyValues {
    var resourceHandler: ResourceHandler {
        get { self[ResourceHandlerDependency.self] }
        set { self[ResourceHandlerDependency.self] = newValue }
    }
}
