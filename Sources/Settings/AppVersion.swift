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
import eRpResources
import Foundation

/// Represents the current version of the app as defined in the Info.plist
public struct AppVersion: Equatable {
    /// The product version, e.g. "1.0.0"
    public let productVersion: String
    /// The build number, e.g. "42"
    public let buildNumber: String
    /// The build hash, e.g. "abc"
    public let buildHash: String

    /// The current app version as defined in the Info.plist
    public static let current = AppVersion(
        productVersion: Bundle.main.cfBundleShortVersionString,
        buildNumber: Bundle.main.cfBundleVersion,
        buildHash: Bundle.main.gematikSourceVersion
    )

    public var description: String {
        L10n.stgTxtVersionAndBuild(productVersion, "\(buildNumber) (\(buildHash))").text
    }

    /// Creates a new `AppVersion` instance
    public init(
        productVersion: String,
        buildNumber: String,
        buildHash: String
    ) {
        self.productVersion = productVersion
        self.buildNumber = buildNumber
        self.buildHash = buildHash
    }
}

private extension Bundle { // swiftlint:disable:this no_extension_access_modifier
    var cfBundleShortVersionString: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "NO CFBundleShortVersionString in Info.plist"
    }

    var cfBundleVersion: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "NO CFBundleVersion in Info.plist"
    }

    var gematikSourceVersion: String {
        infoDictionary?["GEMATIKSourceVersion"] as? String ?? "NO GEMATIKSourceVersion in Info.plist"
    }
}

// MARK: TCA Dependency

extension AppVersion: DependencyKey {
    public static let liveValue = AppVersion.current

    public static let previewValue = AppVersion(productVersion: "preview", buildNumber: "42", buildHash: "abc")
}

extension DependencyValues {
    /// The current app version as defined in the Info.plist
    public var currentAppVersion: AppVersion {
        get { self[AppVersion.self] }
        set { self[AppVersion.self] = newValue }
    }
}
