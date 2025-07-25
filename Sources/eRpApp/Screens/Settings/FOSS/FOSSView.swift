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

import ComposableArchitecture
import SwiftUI
import WebKit

// [REQ:BSI-eRp-ePA:O.Arch_8#2] Webview containing local html without javascript
struct FOSSView: View {
    var body: some View {
        WebView()
    }
}

extension FOSSView {
    struct WebView: UIViewRepresentable {
        // swiftlint:disable:next weak_delegate
        // [REQ:BSI-eRp-ePA:O.Plat_10#4] Usage of the delegate
        let navigationDelegate = DataPrivacyTermsOfUseNavigationDelegate()

        func makeUIView(context _: Context) -> WKWebView {
            let wkWebView = WKWebView()
            // [REQ:BSI-eRp-ePA:O.Plat_11#4] disabled javascript
            wkWebView.configuration.defaultWebpagePreferences.allowsContentJavaScript = false
            if let url = Bundle.module.url(forResource: "FOSS",
                                           withExtension: "html") {
                wkWebView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            }
            wkWebView.navigationDelegate = navigationDelegate
            return wkWebView
        }

        func updateUIView(_: WKWebView, context _: UIViewRepresentableContext<WebView>) {
            // this is a static html page - nothing needs to be updated
        }
    }
}

struct FOSSView_Previews: PreviewProvider {
    static var previews: some View {
        FOSSView()
    }
}
