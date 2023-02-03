//
//  Copyright (c) 2023 gematik GmbH
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
