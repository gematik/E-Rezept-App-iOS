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

struct Backport<Content> {
    let content: Content
}

extension View {
    var backport: Backport<Self> { Backport(content: self) }
}

extension Backport where Content: View {
    @ViewBuilder
    func badge(_ count: Int) -> some View {
        if #available(iOS 15, *) {
//            content.badge(count)
            content.modifier(BagdeModifier(count: count))
        } else {
            content
        }
    }

    @ViewBuilder
    func listRowSeparatorHiddenAllEdges() -> some View {
        if #available(iOS 15, *) {
            // content.listRowSeparator(.hidden, edges: .all)
            content.modifier(ListRowSeparatorHiddenAllEdgesModifier())
        } else {
            content
        }
    }

    @ViewBuilder
    func searchable(
        text: Binding<String>,
        prompt: LocalizedStringKey,
        onSubmitOfSearch: @escaping () -> Void
    ) -> some View {
        if #available(iOS 15, *) {
            // content
            //  .searchable(text: text, placement: .navigationBarDrawer(displayMode: .always), prompt: prompt)
            //  .onSubmit(of: .search, onSubmitOfSearch)
            content.modifier(
                SearchableModifier(
                    text: text,
                    prompt: prompt,
                    onSubmitOfSearch: onSubmitOfSearch
                )
            )
        } else {
            content
        }
    }

    @ViewBuilder
    func searchable<Suggestions: View>(
        text: Binding<String>,
        prompt: LocalizedStringKey,
        displayModeAlways: Bool = true,
        @ViewBuilder suggestions: () -> Suggestions,
        onSubmitOfSearch: @escaping () -> Void
    ) -> some View {
        if #available(iOS 15, *) {
            // content
            //  .searchable(text: text, placement: .navigationBarDrawer(displayMode: .always), prompt: prompt)
            //  .onSubmit(of: .search, onSubmitOfSearch)
            content.modifier(
                SearchableModifier(
                    text: text,
                    prompt: prompt,
                    displayMode: displayModeAlways ? .always : .automatic,
                    onSubmitOfSearch: onSubmitOfSearch,
                    suggestions: suggestions
                )
            )
        } else {
            content
        }
    }

    @ViewBuilder
    func searchCompletion(_ completion: String) -> some View {
        if #available(iOS 15.0, *) {
            content.searchCompletion(completion)
        } else {
            content
        }
    }
}

// Workaround for Xcode 13.2.1 Bug https://developer.apple.com/forums/thread/697070
@available(iOS 15.0, *)
struct BagdeModifier: ViewModifier {
    let count: Int

    func body(content: Content) -> some View {
        content.badge(count)
    }
}

// Workaround for Xcode 13.2.1 Bug https://developer.apple.com/forums/thread/697070
@available(iOS 15.0, *)
struct ListRowSeparatorHiddenAllEdgesModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.listRowSeparator(.hidden, edges: .all)
    }
}

// Workaround for Xcode 13.2.1 Bug https://developer.apple.com/forums/thread/697070
@available(iOS 15.0, *)
struct SearchableModifier<Suggestions: View>: ViewModifier {
    internal init(
        text: Binding<String>,
        prompt: LocalizedStringKey,
        displayMode: SearchFieldPlacement.NavigationBarDrawerDisplayMode = .always,
        onSubmitOfSearch: @escaping () -> Void,
        @ViewBuilder suggestions: () -> Suggestions
    ) {
        self.text = text
        self.prompt = prompt
        self.onSubmitOfSearch = onSubmitOfSearch
        self.suggestions = suggestions()
        self.displayMode = displayMode
    }

    internal init(
        text: Binding<String>,
        prompt: LocalizedStringKey,
        displayMode: SearchFieldPlacement.NavigationBarDrawerDisplayMode = .always,
        onSubmitOfSearch: @escaping () -> Void
    )
        where Suggestions == EmptyView {
        self.text = text
        self.prompt = prompt
        self.onSubmitOfSearch = onSubmitOfSearch
        suggestions = EmptyView()
        self.displayMode = displayMode
    }

    let text: Binding<String>
    let prompt: LocalizedStringKey
    let onSubmitOfSearch: () -> Void
    let suggestions: Suggestions
    let displayMode: SearchFieldPlacement.NavigationBarDrawerDisplayMode

    func body(content: Content) -> some View {
        content
            .searchable(text: text,
                        placement: .navigationBarDrawer(displayMode: displayMode),
                        prompt: prompt) {
                suggestions
            }
            .onSubmit(of: .search, onSubmitOfSearch)
    }
}
