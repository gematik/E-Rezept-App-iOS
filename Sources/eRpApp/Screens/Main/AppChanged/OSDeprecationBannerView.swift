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
import eRpStyleKit
import SwiftUI
import SwiftUIIntrospect

struct OSDeprecationBannerView: View {
    let osVersion: String
    var visible = true
    var onTapCallback: (() -> Void)?

    var body: some View {
        if visible {
            Button {
                if let callback = onTapCallback {
                    callback()
                }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: SFSymbolName.info)
                        .accessibility(hidden: true)

                    Text(L10n.appChangedOsDeprecationBannerTitle(osVersion))
                        .accessibility(identifier: A11y.controls.osDeprecationBanner.bnrTxtOsDeprecation)

                    Spacer()

                    Image(systemName: SFSymbolName.arrowRight)
                        .accessibility(hidden: true)
                }
                .layoutPriority(1)
                .padding(.horizontal)
                .padding([.bottom, .top], 8)
                .font(Font.subheadline.weight(.semibold))
                .background(Colors.yellow500)
                .foregroundColor(Colors.yellow900)
            }
        }
    }
}

struct OSDeprecationBannerViewModifier: ViewModifier {
    let osVersion: String
    var visible = true
    var onTapCallback: (() -> Void)?

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            OSDeprecationBannerView(
                osVersion: osVersion,
                visible: visible,
                onTapCallback: onTapCallback
            )
            content
                .introspect(.navigationView(style: .stack), on: .iOS(.v15, .v16, .v17, .v18)) { navigationController in
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    if visible {
                        appearance.backgroundColor = UIColor(Colors.red100)
                    }
                    navigationController.navigationBar.standardAppearance = appearance
                    navigationController.navigationBar.compactAppearance = appearance
                }
        }
    }
}

extension View {
    func osDeprecationBanner(
        osVersion: String,
        isPresented: Bool,
        onTapCallback: (() -> Void)? = nil
    ) -> some View {
        modifier(
            OSDeprecationBannerViewModifier(
                osVersion: osVersion,
                visible: isPresented,
                onTapCallback: onTapCallback
            )
        )
    }
}

#Preview("Navigation with Banner") {
    NavigationStack {
        List {
            Text("Sample content")
                .frame(height: 1000, alignment: .top)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
        .listStyle(.insetGrouped)
        .frame(maxWidth: .infinity, alignment: .leading)
        .osDeprecationBanner(
            osVersion: "16",
            isPresented: true
        )
        .navigationTitle("Main")
    }
    .navigationBarTitleDisplayMode(.automatic)
    .frame(maxWidth: .infinity, alignment: .leading)
}

#Preview("Banner Only - iOS 16") {
    OSDeprecationBannerView(
        osVersion: "16",
        visible: true
    )
    .previewLayout(.fixed(width: 250.0, height: 100.0))
}

#Preview("Banner with Message - iOS 17") {
    OSDeprecationBannerView(
        osVersion: "17",
        visible: true
    )
    .previewLayout(.fixed(width: 250.0, height: 200.0))
}

#Preview("Banner Dark Mode - Large Text") {
    OSDeprecationBannerView(
        osVersion: "16",
        visible: true
    )
    .preferredColorScheme(.dark)
    .environment(\.sizeCategory, .extraExtraExtraLarge)
    .previewLayout(.fixed(width: 250.0, height: 100.0))
}
