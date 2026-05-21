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

import eRpResources
import SwiftUI

/// A search bar with a cancel button and a clear text button.
public struct SearchBar: View {
    @Binding public var searchText: String
    public let prompt: String
    public let onSubmit: () -> Void

    @FocusState private var isEditing: Bool

    public init(
        searchText: Binding<String>,
        prompt: String,
        onSubmit: @escaping () -> Void,
        isEditing: Bool = false
    ) {
        _searchText = searchText
        self.prompt = prompt
        self.onSubmit = onSubmit
        self.isEditing = isEditing
    }

    public var body: some View {
        HStack {
            TextField(text: $searchText) {
                Text(prompt)
                    .foregroundColor(Colors.systemLabelSecondary)
            }
            .foregroundColor(Colors.systemLabel)
            .onSubmit(onSubmit)
            .submitLabel(.go)
            .padding(7)
            .padding(.horizontal, 25)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Colors.systemLabelSecondary, lineWidth: 0.5)
            )
            .padding(1)
            .accessibility(identifier: A11y.controls.searchBar.ctlTxtSearchBarField)
            .accessibility(label: Text(L10n.ctlTxtSearchBarFieldLabel))
            .overlay(
                HStack {
                    Image(systemName: SFSymbolName.magnifyingGlas)
                        .foregroundColor(Colors.systemGray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 8)
                        .accessibility(hidden: true)

                    // X button
                    if isEditing, !searchText.isEmpty {
                        Button(
                            action: { searchText = "" },
                            label: {
                                Image(systemName: SFSymbolName.xmarkCircleFill)
                                    .foregroundColor(Colors.systemGray)
                                    .padding(.trailing, 6)
                            }
                        )
                        .accessibility(identifier: A11y.controls.searchBar.ctlBtnSearchBarDeleteText)
                        .accessibility(label: Text(L10n.ctlBtnSearchBarDeleteTextLabel))
                    }
                }
            )
            .focused($isEditing)
            .transition(.move(edge: .trailing))

            // Cancel button
            if isEditing {
                Button(
                    action: {
                        withAnimation {
                            isEditing = false
                            searchText = ""
                        }
                        isEditing = false
                    },
                    label: { Text(L10n.ctlBtnSearchBarCancel) }
                )
                .transition(.move(edge: .trailing))
                .accessibility(identifier: A11y.controls.searchBar.ctlBtnSearchBarCancel)
            }
        }
    }
}

#Preview {
    SearchBar(
        searchText: .constant(""),
        prompt: "Search..."
    ) {}
}

#Preview {
    SearchBar(
        searchText: .constant("Search Term"),
        prompt: "Search..."
    ) {}
}
