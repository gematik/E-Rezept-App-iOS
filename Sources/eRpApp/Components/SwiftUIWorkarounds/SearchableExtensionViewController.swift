//
//  Copyright (c) 2023 gematik GmbH
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

import Foundation
import Introspect
import SwiftUI

extension View {
    /// Finds a `UINavigationController` from any view embedded in a `SwiftUI.NavigationView`.
    func searchableForceCancelButtonVisible(_ overwriteVisibity: Binding<Bool>) -> some View {
        inject(SearchableExtensionViewController(overwriteIsCancelButtonVisible: overwriteVisibity))
    }
}

/// Work around SwiftUI having no modifier for force showing a `searchable` cancel button.
///
/// If `overwriteIsCancelButtonVisible` is true, the cancel is force shown, otherwise the SearchController will decide
/// wether the button is shown or not.
///
/// The implementation works by intercepting the UISearchBar's delegate methods. As the search bar already contains a
/// delegate, the new implementation will forward all existing calls.
struct SearchableExtensionViewController: UIViewControllerRepresentable {
    @Binding var overwriteIsCancelButtonVisible: Bool

    func makeUIViewController(context _: Context) -> IntrospectionUIViewController {
        IntrospectionUIViewController()
    }

    func updateUIViewController(
        _ uiViewController: IntrospectionUIViewController,
        context: UIViewControllerRepresentableContext<SearchableExtensionViewController>
    ) {
        DispatchQueue.main.async {
            guard let navigationController = uiViewController.navigationController ??
                Introspect.previousSibling(containing: UINavigationController.self, from: uiViewController) else {
                return
            }

            if let items = navigationController.navigationBar.items {
                for item in items {
                    if let searchController = item.searchController {
                        if !context.coordinator.initialized {
                            context.coordinator.initialized = true
                            context.coordinator.searchBar = searchController.searchBar
                            context.coordinator.wrappedDelegate = searchController.searchBar.delegate
                            searchController.searchBar.delegate = context.coordinator
                            context.coordinator.overwriteShowsCancelButton = overwriteIsCancelButtonVisible
                        }
                        context.coordinator.updateCancelButtonStatus()
                    }
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(initialized: false, overwriteShowsCancelButton: $overwriteIsCancelButtonVisible, searchBar: nil)
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        internal init(initialized: Bool = false, overwriteShowsCancelButton: Binding<Bool>, searchBar: UISearchBar?) {
            self.initialized = initialized
            _overwriteShowsCancelButton = overwriteShowsCancelButton
            self.searchBar = searchBar
        }

        var initialized: Bool
        @Binding var overwriteShowsCancelButton: Bool {
            didSet {
                updateCancelButtonStatus()
            }
        }

        weak var searchBar: UISearchBar?

        func updateCancelButtonStatus() {
            guard let searchBar = searchBar else { return }

            let showCancelButton = overwriteShowsCancelButton || searchBar.searchTextField.isFirstResponder
            searchBar.setShowsCancelButton(showCancelButton, animated: true)
        }

        var wrappedDelegate: UISearchBarDelegate?

        func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
            guard let wrappedDelegate = wrappedDelegate else { return true }

            return wrappedDelegate.searchBarShouldBeginEditing?(searchBar) ?? true
        }

        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            guard let wrappedDelegate = wrappedDelegate else { return }
            wrappedDelegate.searchBarTextDidBeginEditing?(searchBar)

            updateCancelButtonStatus()
        }

        func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
            guard let wrappedDelegate = wrappedDelegate else { return true }
            return wrappedDelegate.searchBarShouldEndEditing?(searchBar) ?? true
        }

        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            guard let wrappedDelegate = wrappedDelegate else { return }
            wrappedDelegate.searchBarTextDidEndEditing?(searchBar)

            updateCancelButtonStatus()
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            guard let wrappedDelegate = wrappedDelegate else { return }
            wrappedDelegate.searchBar?(searchBar, textDidChange: searchText)
        }

        func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange,
                       replacementText text: String) -> Bool {
            guard let wrappedDelegate = wrappedDelegate else { return true }
            return wrappedDelegate.searchBar?(searchBar, shouldChangeTextIn: range, replacementText: text) ?? true
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            guard let wrappedDelegate = wrappedDelegate else { return }
            wrappedDelegate.searchBarSearchButtonClicked?(searchBar)
        }

        func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
            guard let wrappedDelegate = wrappedDelegate else { return }
            wrappedDelegate.searchBarBookmarkButtonClicked?(searchBar)
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            guard let wrappedDelegate = wrappedDelegate else { return }
            wrappedDelegate.searchBarCancelButtonClicked?(searchBar)

            overwriteShowsCancelButton = false
        }

        func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
            wrappedDelegate?.searchBarResultsListButtonClicked?(searchBar)
        }
    }
}

/// The following class is copied from Package Introspect to avoid using @testable import Instrospect
/// Introspection UIViewController that is inserted alongside the target view controller.
class IntrospectionUIViewController: UIViewController {
    required init() {
        super.init(nibName: nil, bundle: nil)
        view = IntrospectionUIView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class IntrospectionUIView: UIView {
        required init() {
            super.init(frame: .zero)
            isHidden = true
            isUserInteractionEnabled = false
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

@available(iOS 15.0, *)
struct SearchableExtensionVC_Preview: PreviewProvider {
    struct SearchableCancelButtonTest: View {
        @State var overwriteVisibity = false {
            didSet {
                print("overwriteVisibity: \(overwriteVisibity)")
            }
        }

        @State var text: String = "" {
            didSet {
                print("text: \(text)")
            }
        }

        var body: some View {
            NavigationView {
                ScrollView {
                    Toggle(isOn: $overwriteVisibity) {
                        Label("ABC", image: "")
                    }
                    .padding()
                    VStack {
                        Text("Dummy Content")
                            .frame(height: 1200)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .searchable(
                    text: $text,
                    placement: .navigationBarDrawer(displayMode: .always)
                )
                .onSubmit(of: .search) {
                    //
                }
                .background(Color.gray.ignoresSafeArea())
                .navigationTitle("NavigationTitle")
                .searchableForceCancelButtonVisible($overwriteVisibity)
            }
        }
    }

    static var previews: some View {
        SearchableCancelButtonTest()
    }
}
