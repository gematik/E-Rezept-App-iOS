//
//  Copyright (c) 2025 gematik GmbH
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

// sourcery:StringAssetInitialized
public struct AnnotationBadge: View {
    let text: LocalizedStringKey
    let bundle: Bundle?

    public init(text: LocalizedStringKey, bundle: Bundle? = nil) {
        self.text = text
        self.bundle = bundle
    }

    public var body: some View {
        Text(text, bundle: bundle)
            .font(.footnote.bold())
            .padding(8)
            .foregroundColor(.white)
            .background(Color.red, in: RoundedRectangle(cornerRadius: 16))
    }
}

// sourcery:StringAssetInitialized
public struct AnnotationBadgeModifier: ViewModifier {
    let text: LocalizedStringKey
    let bundle: Bundle?

    public init(text: LocalizedStringKey, bundle: Bundle? = nil) {
        self.text = text
        self.bundle = bundle
    }

    public func body(content: Content) -> some View {
        content
            .overlay(alignment: .trailing) {
                AnnotationBadge(text: text, bundle: bundle)
                    .padding(.trailing)
            }
    }
}

#Preview {
    NavigationStack {
        List {
            Text("Test")
                .frame(maxWidth: .infinity, alignment: .leading)
                .modifier(AnnotationBadgeModifier(text: "Neu"))
        }
    }
}
