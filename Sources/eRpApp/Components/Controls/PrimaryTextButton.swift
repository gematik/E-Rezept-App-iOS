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

/// sourcery: StringAssetInitialized
struct PrimaryTextButton: View {
    var text: LocalizedStringKey
    var a11y: String
    var image: Image?
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                if let image = image {
                    image.foregroundColor(.white)
                }
                Text(text, bundle: .module)
                    .fontWeight(.semibold)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isEnabled ? Color(.white) : Color(.systemGray))
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
        }
        .buttonStyle(PrimaryButtonStyle(enabled: isEnabled))
        .accessibility(identifier: a11y)
        .if(!isEnabled) { $0.accessibility(value: Text(L10n.buttonTxtIsInactiveValue)) }
        .disabled(!isEnabled)
    }
}

/// sourcery: StringAssetInitialized
struct PrimaryTextButtonBorder: View {
    var text: LocalizedStringKey
    var note: LocalizedStringKey?
    var image: Image?
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                HStack(spacing: 8) {
                    Spacer()
                    if let image = image {
                        image
                            .foregroundColor(isEnabled ? Colors.primary : Colors.disabled)
                            .font(.body.weight(.semibold))
                    }
                    Text(text, bundle: .module)
                        .fontWeight(.semibold)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(isEnabled ? Colors.primary : Colors.disabled)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                if let note = note {
                    Text(note, bundle: .module)
                        .font(.footnote)
                        .foregroundColor(isEnabled ? Colors.primary : Colors.disabled)
                }
            }.padding()
        }
        .buttonStyle(PrimaryBorderButtonStyle(enabled: isEnabled))
        .if(!isEnabled) { $0.accessibility(value: Text(L10n.buttonTxtIsInactiveValue)) }
        .disabled(!isEnabled)
    }
}

/// sourcery: StringAssetInitialized
struct LoadingPrimaryButton: View {
    var text: LocalizedStringKey
    var isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if isLoading {
                HStack {
                    Text(" ")
                        .fontWeight(.semibold)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(isLoading ? Color(.white) : Color(.systemGray))
                        .padding()
                    ProgressView()
                        .hidden(!isLoading)
                    Text(" ")
                        .fontWeight(.semibold)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(isLoading ? Color(.white) : Color(.systemGray))
                        .padding()
                }
            } else {
                Text(text, bundle: .module)
                    .fontWeight(.semibold)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(.white))
                    .padding()
            }
        }
        .buttonStyle(PrimaryButtonStyle(enabled: !isLoading))
        .disabled(isLoading)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    private var isEnabled: Bool

    init(enabled: Bool = true) {
        isEnabled = enabled
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .opacity(configuration.isPressed ? 0.25 : 1)
            .background(isEnabled ? Colors.primary : Color(.systemGray4))
            .cornerRadius(16)
    }
}

struct DestructiveButtonStyle: ButtonStyle {
    private var isEnabled: Bool

    init(enabled: Bool = true) {
        isEnabled = enabled
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .opacity(configuration.isPressed ? 0.25 : 1)
            .background(isEnabled ? Colors.red600 : Color(.systemGray4))
            .cornerRadius(16)
    }
}

struct DestructiveSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .multilineTextAlignment(.center)
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity, alignment: .center)
            .foregroundColor(Colors.red600)
            .fixedSize(horizontal: false, vertical: true)
            .padding()
            .opacity(configuration.isPressed ? 0.25 : 1)
            .background(Color(.systemGray5))
            .cornerRadius(16)
    }
}

struct PrimaryBorderButtonStyle: ButtonStyle {
    private var isEnabled: Bool

    init(enabled: Bool = true) {
        isEnabled = enabled
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .opacity(configuration.isPressed ? 0.25 : 1)
            .background(isEnabled ? Color(.systemBackground) : Color(.systemGray5))
            .border(Colors.primary, width: isEnabled ? 1.0 : 0.0, cornerRadius: 16)
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PrimaryTextButton(text: "Peter picked a peck of pickled peppers", a11y: "") {}
                .previewLayout(.fixed(width: 350.0, height: 150.0))
            PrimaryTextButton(text: "Peter picked a peck of pickled peppers", a11y: "", isEnabled: false) {}
                .previewLayout(.fixed(width: 350.0, height: 150.0))
            PrimaryTextButton(text: "Peter picked a peck of pickled peppers", a11y: "") {}
                .previewLayout(.fixed(width: 400.0, height: 150.0))
                .preferredColorScheme(.dark)
                .environment(\.sizeCategory, .extraExtraLarge)
            PrimaryTextButtonBorder(text: "Peter picked a peck of pickled peppers",
                                    note: "You must be logged in",
                                    image: Image(systemName: SFSymbolName.safari)) {}
                .previewLayout(.fixed(width: 350.0, height: 150.0))
            PrimaryTextButtonBorder(text: "Peter picked a peck of pickled peppers",
                                    note: "You must be logged in to use this feature",
                                    image: Image(systemName: SFSymbolName.safari),
                                    isEnabled: false) {}
                .previewLayout(.fixed(width: 350.0, height: 150.0))
        }
    }
}
