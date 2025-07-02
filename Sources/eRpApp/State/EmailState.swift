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

import UIKit

struct EmailState {
    enum Mailto {
        case developer
        case supportCenter

        var address: String {
            switch self {
            case .developer:
                return "mailto:app-feedback@gematik.de"
            case .supportCenter:
                return "mailto:app-fehlermeldung@ti-support.de"
            }
        }
    }

    var mailto: Mailto = .developer
    var subject: String = L10n.emailSubjectFallback.text
    var body: String

    func createEmailUrl() -> URL? {
        var urlString = URLComponents(string: mailto.address)
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "subject", value: subject))
        let message = Self.addDeviceInfo(to: body)
        queryItems.append(URLQueryItem(name: "body", value: message))

        urlString?.queryItems = queryItems

        return urlString?.url
    }

    static func addDeviceInfo(to message: String) -> String {
        """
        \(message)

        ---

        E-Rezept Version: \(AppVersion.current.description)
        iOS: \(UIDevice.current.systemVersion), \(UIDevice.current.systemName)
        Model: \(UIDevice.current.model) | \(UIDevice.current.machineName())
        """
    }
}

extension UIDevice {
    func machineName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
}
