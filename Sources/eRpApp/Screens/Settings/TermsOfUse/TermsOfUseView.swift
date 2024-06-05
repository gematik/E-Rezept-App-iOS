//
//  Copyright (c) 2024 gematik GmbH
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

import ComposableArchitecture
import SwiftUI
import WebKit

// [REQ:BSI-eRp-ePA:O.Purp_3#2] Actual view for the Terms of Use display
// [REQ:BSI-eRp-ePA:O.Arch_8#1] Webview containing local html without javascript
struct TermsOfUseView: View {
    var body: some View {
        WebView()
    }
}

extension TermsOfUseView {
    struct WebView: UIViewRepresentable {
        // swiftlint:disable:next weak_delegate
        // [REQ:BSI-eRp-ePA:O.Plat_10#5] Usage of the delegate
        let navigationDelegate = DataPrivacyTermsOfUseNavigationDelegate()

        func makeUIView(context _: Context) -> WKWebView {
            let wkWebView = WKWebView()
            // [REQ:BSI-eRp-ePA:O.Plat_11#3] disabled javascript
            wkWebView.configuration.defaultWebpagePreferences.allowsContentJavaScript = false
            if let url = Bundle.module.url(forResource: "TermsOfUse",
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

struct TermsOfUseView_Previews: PreviewProvider {
    static var previews: some View {
        TermsOfUseView()
            .accessibilityIdentifier(A11y.settings.termsOfUse.stgWwTermsOfUse)
    }
}
