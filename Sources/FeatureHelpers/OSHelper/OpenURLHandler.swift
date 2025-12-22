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
import DependenciesMacros
import SwiftUI

/// Handler for opening URLs with various options
@DependencyClient
public struct OpenURLHandler {
    /// Checks if a URL can be opened
    public var canOpenURL: @Sendable (URL) async -> Bool = { _ in false }
    /// Opens a URL asynchronously
    public var open: @Sendable (URL) async -> Void
    /// Opens a URL with specific options asynchronously
    public var openWithOptions: @Sendable (
        _ url: URL,
        _ options: [UIApplication.OpenExternalURLOptionsKey: Any]
    ) async -> Void
}

// MARK: - TCA Dependency

extension OpenURLHandler: DependencyKey {
    /// Live implementation using UIApplication
    public static let liveValue = OpenURLHandler(
        canOpenURL: { @MainActor url in
            UIApplication.shared.canOpenURL(url)
        },
        open: { @MainActor url in
            await UIApplication.shared.open(url, options: [:])
        },
        openWithOptions: { @MainActor url, options in
            await UIApplication.shared.open(url, options: options)
        }
    )

    public static let testValue = OpenURLHandler()
}

extension DependencyValues {
    /// Access point for the OpenURLHandler dependency
    public var openURLHandler: OpenURLHandler {
        get { self[OpenURLHandler.self] }
        set { self[OpenURLHandler.self] = newValue }
    }
}
