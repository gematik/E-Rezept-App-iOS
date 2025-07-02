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

import SwiftUI

/// sourcery: StringAssetInitialized
public struct SubTitleTop: View {
    public init(subject: LocalizedStringKey, title: LocalizedStringKey? = nil, bundle: Bundle) {
        self.subject = subject
        self.title = title
        self.bundle = bundle
    }

    var subject: LocalizedStringKey
    var title: LocalizedStringKey?
    var bundle: Bundle

    public var body: some View {
        VStack {
            Text(subject, bundle: bundle)

            if let title = title {
                Text(title, bundle: bundle)
            }
        }
    }
}
