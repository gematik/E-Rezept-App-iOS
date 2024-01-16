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

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    let prompt: LocalizedStringKey
    let onSubmit: () -> Void

    @State private var isEditing = false

    var body: some View {
        HStack {
            TextField(
                prompt,
                text: $searchText,
                onEditingChanged: { _ in },
                onCommit: onSubmit
            )
            .introspectTextField { textField in
                textField.returnKeyType = .go
            }
            .padding(7)
            .padding(.horizontal, 25)
            .background(Colors.systemFillTertiary)
            .cornerRadius(8)
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
                            action: { self.searchText = "" },
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
            .onTapGesture {
                withAnimation {
                    self.isEditing = true
                }
            }
            .transition(.move(edge: .trailing))

            // Cancel button
            if isEditing {
                Button(
                    action: {
                        withAnimation {
                            self.isEditing = false
                            self.searchText = ""
                        }
                        UIApplication.shared.dismissKeyboard()
                    },
                    label: { Text(L10n.ctlBtnSearchBarCancel) }
                )
                .transition(.move(edge: .trailing))
                .accessibility(identifier: A11y.controls.searchBar.ctlBtnSearchBarCancel)
            }
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(
            searchText: .constant(""),
            prompt: "Search..."
        ) {}
        SearchBar(
            searchText: .constant("Search Term"),
            prompt: "Search..."
        ) {}
    }
}
