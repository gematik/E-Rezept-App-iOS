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

import eRpStyleKit
import SwiftUI
import SwiftUIIntrospect

struct EnterProfileNameSubView: View {
    let displayName: Binding<String>
    let didTapButtonAction: () -> Void
    var validating: ((String) -> Bool)?

    @FocusState private var focused: Bool

    var isValidEntry: Bool {
        guard let validating = validating else { return true }
        return validating(displayName.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 8) {
            Section(header:
                Text(L10n.addTxtTitle)
                    .font(.system(size: 16, weight: .bold))) {
                    TextField(
                        L10n.addTxtProfile1,
                        text: displayName
                    )
                    .introspect(.textField, on: .iOS(.v15, .v16, .v17, .v18)) { textField in
                        textField.clearButtonMode = .whileEditing
                    }
                    .foregroundColor(Colors.text)
                    .padding()
                    .border(Colors.primary700, width: 2, cornerRadius: 8)
                    .padding(.vertical)
                    .padding(.horizontal)
                    .focused($focused)

                    Button(
                        action: {
                            didTapButtonAction()
                        },
                        label: {
                            HStack {
                                Text(L10n.addBtnSave)
                                    .foregroundColor(isValidEntry ? Color(.white) : Color(.systemGray))
                                    .font(.system(size: 16, weight: .bold))
                                    .padding()
                                    .padding(.horizontal)
                            }
                        }
                    )
                    .disabled(!isValidEntry)
                    .background(isValidEntry ? Colors.primary : Color(.systemGray4))
                    .cornerRadius(16)
            }
        }
        .padding()
        .background(Colors.systemBackground.ignoresSafeArea())
        .onAppear {
            focused = true
        }
    }
}

struct EnterProfileNameSubView_Previews: PreviewProvider {
    static var previews: some View {
        EnterProfileNameSubView(
            displayName: .constant(""),
            didTapButtonAction: {},
            validating: { _ in true }
        )
    }
}
