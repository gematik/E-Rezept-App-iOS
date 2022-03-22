//
//  Copyright (c) 2022 gematik GmbH
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

import SwiftUI

/// sourcery: StringAssetInitialized
public struct SubTitleTop: View {
    public init(subject: LocalizedStringKey, title: LocalizedStringKey? = nil) {
        self.subject = subject
        self.title = title
    }

    var subject: LocalizedStringKey
    var title: LocalizedStringKey?

    public var body: some View {
        VStack {
            Text(subject)

            if let title = title {
                Text(title)
            }
        }
    }
}
