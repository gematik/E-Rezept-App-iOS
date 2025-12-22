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

    @State private var effectStrength: CGFloat = 0

    init(applyBackgroundBlur: Bool = true, @ViewBuilder header: () -> Header, @ViewBuilder content: () -> Content) {
        self.applyBackgroundBlur = applyBackgroundBlur
        self.header = header()
        self.content = content()
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                Section {
                    content
                } header: {
                    header
                        .overlay(
                            Divider().foregroundColor(Colors.separator).opacity(effectStrength),
                            alignment: .bottom
                        )
                        .background(.bar)
                }
            }
        }
        // Mitigate unwanted behaviour of the navigation bar On devices/simulators starting with iOS 18.2:
        // the ScrollView's content would be visible below the navigation bar when scrolling down.
        .introspect(.viewController, on: .iOS(.v17, .v18, .v26)) { (viewController: UIViewController) in
            guard let scrollView = viewController.view?.recursiveSubviews.compactMap({ $0 as? UIScrollView }).first
            else { return }
            viewController.setContentScrollView(scrollView, for: .top)

            observer.action = { strength in
                DispatchQueue.main.async { effectStrength = strength }
            }
            // only replace the delegate when this is a new scroll view we haven't seen
            if observer.scrollView != scrollView {
                observer.wrapped = scrollView.delegate
                scrollView.delegate = observer
                observer.scrollView = scrollView
            }
        }
    }

    @StateObject var observer = ScrollViewObserver()
}

class ScrollViewObserver: NSObject, ObservableObject, UIScrollViewDelegate {
    var wrapped: (any UIScrollViewDelegate)?
    var action: ((CGFloat) -> Void)?
    weak var scrollView: UIScrollView?

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        wrapped?.scrollViewDidScroll?(scrollView)

        let effectStrength = min(
            max((scrollView.safeAreaInsets.top + scrollView.contentOffset.y - 1.0) / 4.0, 0.0),
            1.0
        )
        action?(effectStrength)
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        wrapped?.scrollViewDidZoom?(scrollView)
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        wrapped?.scrollViewDidScrollToTop?(scrollView)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        wrapped?.scrollViewWillBeginDragging?(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        wrapped?.scrollViewDidEndDecelerating?(scrollView)
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        wrapped?.scrollViewShouldScrollToTop?(scrollView) ?? true
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        wrapped?.scrollViewWillBeginDecelerating?(scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        wrapped?.scrollViewDidEndScrollingAnimation?(scrollView)
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        wrapped?.scrollViewWillBeginZooming?(scrollView, with: view)
    }

    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        wrapped?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        wrapped?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        wrapped?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        wrapped?.scrollViewWillEndDragging?(
            scrollView,
            withVelocity: velocity,
            targetContentOffset: targetContentOffset
        )
    }
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
