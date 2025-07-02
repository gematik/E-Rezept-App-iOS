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

struct AppVersion: Equatable {
    let productVersion: String
    let buildNumber: String
    let buildHash: String

    static let current = AppVersion(
        productVersion: Bundle.main.cfBundleShortVersionString,
        buildNumber: Bundle.main.cfBundleVersion,
        buildHash: Bundle.main.gematikSourceVersion
    )

    var description: String {
        L10n.stgTxtVersionAndBuild(productVersion, "\(buildNumber) (\(buildHash))").text
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
    static let liveValue = AppVersion.current

    static let previewValue = AppVersion(productVersion: "preview", buildNumber: "42", buildHash: "abc")
}

extension DependencyValues {
    var currentAppVersion: AppVersion {
        get { self[AppVersion.self] }
        set { self[AppVersion.self] = newValue }
    }
}
