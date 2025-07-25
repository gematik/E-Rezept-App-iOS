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

import SwiftUI

/// sourcery: StringAssetInitialized
public struct KeyValuePair: View {
    let configuration: KeyValuePairConfiguration

    @Environment(\.keyValuePairStyle) var keyValuePairStyle: AnyKeyValuePairStyle

    public init(
        key: LocalizedStringKey,
        value: LocalizedStringKey,
        bundle: Bundle? = nil
    ) {
        configuration = KeyValuePairConfiguration(
            key: Text(key, bundle: bundle),
            value: Text(value, bundle: bundle)
        )
    }

    public init(
        key: LocalizedStringKey,
        value: String,
        bundle: Bundle? = nil
    ) {
        configuration = KeyValuePairConfiguration(
            key: Text(key, bundle: bundle),
            value: Text(value)
        )
    }

    public init(key: String, value: String) {
        configuration = KeyValuePairConfiguration(
            key: Text(key),
            value: Text(value)
        )
    }

    public var body: some View {
        keyValuePairStyle.makeBody(configuration: configuration)
    }
}

struct KeyValuePair_Preview: PreviewProvider {
    static var previews: some View {
        ScrollView {
            KeyValuePair(key: "Key 1", value: "Value 21")
                .keyValuePairStyle(DefaultKeyValuePairStyle())

            SectionContainer {
                KeyValuePair(key: "Key 1", value: "Value 1")

                KeyValuePair(key: "Key 1", value: "Value 1")
                    .keyValuePairStyle(PlainKeyValuePairStyle())

                KeyValuePair(key: "Key 1", value: "Value 1")
                    .keyValuePairStyle(DefaultKeyValuePairStyle())
            }
        }
        .background(Color(.secondarySystemBackground))
    }
}

/// The properties of a key-value pair
public struct KeyValuePairConfiguration {
    /// A description of the labeled item.
    public var key: Text

    /// A symbolic representation of the labeled description.
    public var value: Text
}

/// A type that applies a custom appearance to all ``KeyValuePair``s within a view hierarchy.
public protocol KeyValuePairStyle {
    /// A view that represents the body of a ``KeyValuePair``.
    associatedtype Body: View

    /// Creates a view that represents the ``SubTitle`` of a button.
    @ViewBuilder func makeBody(configuration: KeyValuePairConfiguration) -> Self.Body
}

public struct DefaultKeyValuePairStyle: KeyValuePairStyle {
    public func makeBody(configuration: KeyValuePairConfiguration) -> some View {
        HStack {
            configuration.key
                .font(.body)
                .labelStyle(DefaultLabelStyle())
            Spacer()
            configuration.value
                .font(.body.weight(.bold))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(configuration.key)
        .accessibilityValue(configuration.value)
    }
}

struct PaddedKeyValuePairStyle: KeyValuePairStyle {
    func makeBody(configuration: KeyValuePairConfiguration) -> some View {
        HStack {
            configuration.key
                .font(.body)
                .labelStyle(DefaultLabelStyle())
            Spacer()
            configuration.value
                .font(.body.weight(.bold))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(configuration.key)
        .accessibilityValue(configuration.value)
        .padding()
    }
}

public struct SeparatedKeyValuePairStyle: KeyValuePairStyle {
    let showSeparator: Bool

    init(showSeparator: Bool) {
        self.showSeparator = showSeparator
    }

    public func makeBody(configuration: KeyValuePairConfiguration) -> some View {
        HStack {
            configuration.key
                .font(.body)
                .foregroundColor(Color(.label))
            Spacer()
            configuration.value
                .font(.body)
                .foregroundColor(Color(.secondaryLabel))
        }
        .bottomDivider(showSeparator: showSeparator)
        .padding(.leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(configuration.key)
        .accessibilityValue(configuration.value)
    }
}

public struct PlainKeyValuePairStyle: KeyValuePairStyle {
    public func makeBody(configuration: KeyValuePairConfiguration) -> some View {
        HStack {
            configuration.key
                .font(.body)
                .foregroundColor(Color(.label))
            Spacer()
            configuration.value
                .font(.body)
                .foregroundColor(Color(.secondaryLabel))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(configuration.key)
        .accessibilityValue(configuration.value)
    }
}

extension View {
    /// Sets a `KeyValuePairStyle` for this and the children views.
    public func keyValuePairStyle<Style: KeyValuePairStyle>(_ style: Style) -> some View {
        environment(\.keyValuePairStyle, AnyKeyValuePairStyle(style: style))
    }
}

private protocol TypeErasedBox {
    var base: Any { get }
    func makeBody(configuration: KeyValuePairConfiguration) -> AnyView
}

private struct ConcreteTypeErased<Base: KeyValuePairStyle>: TypeErasedBox {
    let baseProto: Base

    var base: Any {
        baseProto
    }

    func makeBody(configuration: KeyValuePairConfiguration) -> AnyView {
        AnyView(baseProto.makeBody(configuration: configuration))
    }
}

struct AnyKeyValuePairStyle: KeyValuePairStyle {
    typealias Body = AnyView
    private let box: TypeErasedBox
    init<T: KeyValuePairStyle>(style value: T) {
        box = ConcreteTypeErased(baseProto: value)
    }

    var base: Any {
        box.base
    }

    func makeBody(configuration: KeyValuePairConfiguration) -> AnyView {
        box.makeBody(configuration: configuration)
    }
}

private struct AnyKeyValuePairStyleElementKey: EnvironmentKey {
    static let defaultValue = AnyKeyValuePairStyle(style: DefaultKeyValuePairStyle())
}

extension EnvironmentValues {
    var keyValuePairStyle: AnyKeyValuePairStyle {
        get { self[AnyKeyValuePairStyleElementKey.self] }
        set { self[AnyKeyValuePairStyleElementKey.self] = newValue }
    }
}

extension View {
    func keyValuePairStyle(_ keyValuePairStyle: AnyKeyValuePairStyle) -> some View {
        environment(\.keyValuePairStyle, keyValuePairStyle)
    }
}

extension KeyValuePairStyle where Self == SeparatedNoPaddingKeyValuePairStyle {
    /// A button style that applies a navigation chevron and wraps the button with a divider.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View/buttonStyle(_:)`` modifier.
    public static var noPadding: SeparatedNoPaddingKeyValuePairStyle { SeparatedNoPaddingKeyValuePairStyle() }
}

public struct SeparatedNoPaddingKeyValuePairStyle: KeyValuePairStyle {
    public func makeBody(configuration: KeyValuePairConfiguration) -> some View {
        HStack {
            configuration.key
                .font(.body)
                .labelStyle(DefaultLabelStyle())
            Spacer()
            configuration.value
                .font(.body)
                .foregroundColor(Color(.secondaryLabel))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(configuration.key)
        .accessibilityValue(configuration.value)
    }
}
