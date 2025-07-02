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

import eRpStyleKit
import SwiftUI
import SwiftUIIntrospect
import UIKit

struct ScrollViewWithStickyHeader<Content: View, Header: View>: View {
    private var header: Header
    private var content: Content

    private let coordinateSpace = "StickyHeaderCoordinateSpace"
    private var applyBackgroundBlur: Bool

    init(applyBackgroundBlur: Bool = true, @ViewBuilder header: () -> Header, @ViewBuilder content: () -> Content) {
        self.applyBackgroundBlur = applyBackgroundBlur
        self.header = header()
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                    .anchorPreference(key: StickyHeaderAnchorKey.self, value: .bounds) { anchor in
                        StickyHeader(view: AnyView(header), bounds: anchor)
                    }
                    .disabled(true)
                    .hidden()
                    .accessibilityHidden(true)

                content
            }
        }
        // Mitigate unwanted behaviour of the navigation bar On devices/simulators starting with iOS 18.2:
        // the ScrollView's content would be visible below the navigation bar when scrolling down.
        .introspect(.viewController, on: .iOS(.v18)) { (viewController: UIViewController) in
            guard let scrollView = viewController.view?.recursiveSubviews.compactMap({ $0 as? UIScrollView }).first
            else { return }
            viewController.setContentScrollView(scrollView, for: .top)
        }
        .overlayPreferenceValue(StickyHeaderAnchorKey.self, alignment: .top) { stickyHeader in
            if let stickyHeader = stickyHeader {
                GeometryReader { proxy in
                    let yPosition = max(-proxy.frame(in: .named(coordinateSpace)).minY, proxy[stickyHeader.bounds].minY)
                    let yPositionMinStrength = max(
                        -proxy.frame(in: .named(coordinateSpace)).minY - 2,
                        proxy[stickyHeader.bounds].minY
                    )
                    let effectStrength = (yPosition - yPositionMinStrength) / 2.0

                    stickyHeader.view
                        .overlay(
                            Divider().foregroundColor(Colors.separator).opacity(effectStrength),
                            alignment: SwiftUI.Alignment.bottom
                        )
                        .background(BlurEffectView(
                            style: .systemChromeMaterial,
                            strength: applyBackgroundBlur ? effectStrength : 0.0
                        ))
                        .offset(x: proxy[stickyHeader.bounds].minX, y: yPosition)
                }
                .ignoresSafeArea()
            }
        }
        .coordinateSpace(name: coordinateSpace)
    }
}

struct StickyHeader {
    var view: AnyView
    var bounds: Anchor<CGRect>

    init(view: AnyView, bounds: Anchor<CGRect>) {
        self.view = view
        self.bounds = bounds
    }
}

struct StickyHeaderAnchorKey: PreferenceKey {
    static func reduce(value: inout StickyHeader?, nextValue: () -> StickyHeader?) {
        value = nextValue() ?? value
    }

    typealias Value = StickyHeader?
}

struct ScrollViewWithStickyHeader_Preview: PreviewProvider {
    static var previews: some View {
        ScrollViewHeaderTest()
    }

    struct ScrollViewHeaderTest: View {
        @State var trigger = false
        @State var text = ""

        @State var headerToggle = false

        var body: some View {
            ScrollViewWithStickyHeader(
                header: {
                    Header(toggle: $headerToggle)
                },
                content: {
                    Toggle(isOn: $trigger) {
                        Label("ABC", image: "qrcode")
                    }
                    VStack {
                        Text("Content")
                            .frame(height: 1200)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .background(Color.green)
                    Toggle(isOn: $trigger) {
                        Label("DEF", image: "qrcode")
                    }
                }
            )
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $text,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Prompt"
            )
            .background(Color(.secondarySystemBackground).ignoresSafeArea())
            .navigationTitle("ABC")
        }
    }

    struct Header: View {
        @Binding var toggle: Bool

        var body: some View {
            VStack {
                Toggle(isOn: $toggle) {
                    Text("Toggle")
                }
                .padding()
                if toggle {
                    Text("jojo")
                }
            }
        }
    }
}

extension UIView {
    var recursiveSubviews: [UIView] {
        var allSubviews = subviews
        allSubviews.forEach { allSubviews.append(contentsOf: $0.recursiveSubviews) }
        return allSubviews
    }
}
