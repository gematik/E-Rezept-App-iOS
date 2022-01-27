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

import ComposableArchitecture
import SwiftUI

struct DemoBannerView<Content: View>: View {
    var visible = true
    var innerContent: Content?
    var turnDemoModeOffCallback: (() -> Void)?

    var body: some View {
        if visible {
            HStack(alignment: .firstTextBaseline) {
                VStack {
                    Image(systemName: SFSymbolName.wandAndStars)
                        .accessibility(hidden: true)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("bnr_txt_demo_mode")
                        .accessibility(identifier: "bnr_txt_demo_mode")

                    if let innerContent = innerContent {
                        innerContent
                            .font(Font.subheadline.weight(.regular))
                    }
                }
                .layoutPriority(1)

                Spacer()
            }
            .layoutPriority(1)
            .padding(.leading)
            .padding([.trailing, .bottom, .top], 8)
            .font(Font.subheadline.weight(.semibold))
            .background(Colors.yellow500)
            .foregroundColor(Colors.yellow900)
            .onTapGesture {
                if let callback = turnDemoModeOffCallback {
                    callback()
                }
            }
        }
    }
}

struct DemoBannerViewModifier<InnerContent: View>: ViewModifier {
    var visible = true
    var innerContent: InnerContent?
    var turnDemoModeOffCallback: (() -> Void)?

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            DemoBannerView(
                visible: visible,
                innerContent: innerContent,
                turnDemoModeOffCallback: turnDemoModeOffCallback
            )
            content
        }
    }
}

extension View {
    func demoBanner(isPresented: Bool, turnDemoModeOffCallback: (() -> Void)? = nil) -> some View {
        modifier(
            DemoBannerViewModifier(
                visible: isPresented,
                innerContent: EmptyView(),
                turnDemoModeOffCallback: turnDemoModeOffCallback
            )
        )
    }

    func demoBanner<Content: View>(isPresented: Bool, @ViewBuilder content: () -> Content) -> some View {
        modifier(DemoBannerViewModifier(visible: isPresented, innerContent: content()))
    }
}

struct DemoBannerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DemoBannerView(visible: true, innerContent: EmptyView())
                .previewLayout(.fixed(width: 250.0, height: 100.0))

            DemoBannerView(
                visible: true,
                innerContent: Text("Der Demomodus ist aktiviert. Geben Sie eine beliebige PIN ein um fortzufahren")
            )
            .previewLayout(.fixed(width: 250.0, height: 200.0))

            DemoBannerView(visible: true, innerContent: EmptyView())
                .preferredColorScheme(.dark)
                .environment(\.sizeCategory, .extraExtraExtraLarge)
                .previewLayout(.fixed(width: 250.0, height: 100.0))
        }
    }
}
