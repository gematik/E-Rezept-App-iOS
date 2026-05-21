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

struct EnterProfileNameSubView: View {
    let displayName: Binding<String>
    let didTapButtonAction: () -> Void
    let closeAction: (() -> Void)?
    var validating: ((String) -> Bool)?

    @FocusState private var focused: Bool

    init(
        displayName: Binding<String>,
        didTapButtonAction: @escaping () -> Void,
        closeAction: (() -> Void)? = nil,
        validating: ((String) -> Bool)? = nil
    ) {
        self.displayName = displayName
        self.didTapButtonAction = didTapButtonAction
        self.closeAction = closeAction
        self.validating = validating
    }

    var isValidEntry: Bool {
        guard let validating else { return true }
        return validating(displayName.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 8) {
            if let closeAction {
                HStack(spacing: 0) {
                    Spacer()

                    CloseButton {
                        closeAction()
                    }
                }
            }

            Section(header:
                Text(L10n.addTxtTitle)
                    .font(.system(size: 16, weight: .bold))) {
                TextField(
                    "",
                    text: displayName
                )
                .introspect(.textField, on: .iOS(.v15, .v16, .v17, .v18, .v26)) { textField in
                    textField.clearButtonMode = .whileEditing
                }
                .accessibilityIdentifier(A11y.settings.newProfile.stgInpNewProfileName)
                .foregroundColor(Colors.systemLabel)
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
                        Text(L10n.addBtnSave)
                    }
                )
                .accessibilityIdentifier(A11y.settings.newProfile.stgBtnNewProfileSave)
                .buttonStyle(.primary(isEnabled: isValidEntry, isDestructive: false, width: .wideHugging))
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
