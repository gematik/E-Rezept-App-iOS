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

import SwiftUI

/// sourcery: StringAssetInitialized
public struct SubTitle: View {
    let configuration: SubTitleConfiguration

    @Environment(\.subTitleStyle)
    var subTitleStyle: AnySubTitleStyle

    public init(title: LocalizedStringKey, description: LocalizedStringKey? = nil, details: LocalizedStringKey? = nil) {
        configuration = SubTitleConfiguration(
            title: Text(title),
            description: description.map { Text($0) },
            details: details.map { Text($0) }
        )
    }

    public init(title: String, description: LocalizedStringKey) {
        configuration = SubTitleConfiguration(
            title: Text(title),
            description: Text(description),
            details: nil
        )
    }

    public init(title: LocalizedStringKey, description: String) {
        configuration = SubTitleConfiguration(
            title: Text(title),
            description: Text(description),
            details: nil
        )
    }

    public init(title: String, description: String) {
        configuration = SubTitleConfiguration(
            title: Text(title),
            description: Text(description),
            details: nil
        )
    }

    public var body: some View {
        subTitleStyle.makeBody(configuration: configuration)
    }
}

struct SubTitle_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            SubTitle(title: "abc", description: "def", details: "ghi")
                .subTitleStyle(SectionContainerSubTitleStyle(showSeparator: true))

            SubTitle(title: "abc", description: "def", details: "ghi")
                .subTitleStyle(SectionContainerSubTitleStyle(showSeparator: true))

            SubTitle(title: "abc", description: "def", details: "ghi")

            SubTitle(title: "abc", description: "def", details: "ghi")
        }
    }
}

/// The properties of a ``SubTitle`` pair
public struct SubTitleConfiguration {
    /// A description of the labeled item.
    public var title: Text

    /// A symbolic representation of the labeled description.
    public var description: Text?

    /// A symbolic representation of the labeled details.
    public var details: Text?
}

public struct DefaultSubTitleStyle: SubTitleStyle {
    public func makeBody(configuration: SubTitleConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            configuration.title
                .font(.body.weight(.semibold))

            if let description = configuration.description {
                description
                    .font(.subheadline)
            }

            if let details = configuration.details {
                details
                    .font(.subheadline)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
        .padding()
    }
}

public struct SectionContainerSubTitleStyle: SubTitleStyle {
    let showSeparator: Bool

    public init(showSeparator: Bool = false) {
        self.showSeparator = showSeparator
    }

    public func makeBody(configuration: SubTitleConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            configuration.title
                .font(.body)
                .foregroundColor(Color(.label))

            if let description = configuration.description {
                description
                    .font(.subheadline)
                    .foregroundColor(Color(.secondaryLabel))
            }

            if let details = configuration.details {
                details
                    .font(.subheadline)
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
        .bottomDivider(showSeparator: showSeparator)
        .padding(.leading)
    }
}

public struct PlainSectionContainerSubTitleStyle: SubTitleStyle {
    public init() {}

    public func makeBody(configuration: SubTitleConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            configuration.title
                .font(.body)
                .foregroundColor(Color(.label))

            if let description = configuration.description {
                description
                    .font(.subheadline)
                    .foregroundColor(Color(.secondaryLabel))
            }

            if let details = configuration.details {
                details
                    .font(.subheadline)
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
    }
}

public struct SubTitleViewModifier<Style: SubTitleStyle>: ViewModifier {
    let style: Style

    public func body(content: Content) -> some View {
        content
            .environment(\.subTitleStyle, AnySubTitleStyle(style: style))
    }
}

extension View {
    /// Sets the style of SubTitle within this view to a SubTitlyStyle with a custom appearance.
    public func subTitleStyle<Style: SubTitleStyle>(_ style: Style) -> some View {
        modifier(SubTitleViewModifier(style: style))
    }
}

/// A type that applies a custom appearance to all ``SubTitle``s within a view hierarchy.
public protocol SubTitleStyle {
    /// A view that represents the body of a ``SubTitle``.
    associatedtype Body: View

    /// Creates a view that represents the ``SubTitle`` of a button.
    @ViewBuilder func makeBody(configuration: SubTitleConfiguration) -> Self.Body
}

private protocol TypeErasedBox {
    var base: Any { get }
    func makeBody(configuration: SubTitleConfiguration) -> AnyView
}

private struct ConcreteTypeErased<Base: SubTitleStyle>: TypeErasedBox {
    let baseProto: Base

    var base: Any {
        baseProto
    }

    func makeBody(configuration: SubTitleConfiguration) -> AnyView {
        AnyView(baseProto.makeBody(configuration: configuration))
    }
}

struct AnySubTitleStyle: SubTitleStyle {
    typealias Body = AnyView
    private let box: TypeErasedBox
    init<T: SubTitleStyle>(style value: T) {
        box = ConcreteTypeErased(baseProto: value)
    }

    var base: Any {
        box.base
    }

    func makeBody(configuration: SubTitleConfiguration) -> AnyView {
        box.makeBody(configuration: configuration)
    }
}

private struct SubTitleStyleElementKey: EnvironmentKey {
    static let defaultValue = AnySubTitleStyle(style: DefaultSubTitleStyle())
}

extension EnvironmentValues {
    var subTitleStyle: AnySubTitleStyle {
        get { self[SubTitleStyleElementKey.self] }
        set { self[SubTitleStyleElementKey.self] = newValue }
    }
}

extension View {
    func subTitleStyle(_ subTitleStyle: AnySubTitleStyle) -> some View {
        environment(\.subTitleStyle, subTitleStyle)
    }
}
