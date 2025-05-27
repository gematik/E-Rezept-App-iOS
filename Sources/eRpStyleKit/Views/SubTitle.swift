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

/// sourcery: StringAssetInitialized
public struct SubTitle: View {
    let configuration: SubTitleConfiguration

    @Environment(\.subTitleStyle) var subTitleStyle: AnySubTitleStyle

    public init(
        title: LocalizedStringKey,
        description: LocalizedStringKey? = nil,
        details: LocalizedStringKey? = nil,
        bundle: Bundle? = nil
    ) {
        configuration = SubTitleConfiguration(
            title: Text(title, bundle: bundle),
            description: description.map { Text($0, bundle: bundle) },
            details: details.map { Text($0, bundle: bundle) }
        )
    }

    public init(title: String, details: LocalizedStringKey, bundle: Bundle? = nil) {
        configuration = SubTitleConfiguration(
            title: Text(title),
            description: nil,
            details: Text(details, bundle: bundle)
        )
    }

    public init(title: String, description: LocalizedStringKey, bundle: Bundle? = nil) {
        configuration = SubTitleConfiguration(
            title: Text(title),
            description: Text(description, bundle: bundle),
            details: nil
        )
    }

    public init(title: LocalizedStringKey, description: String, bundle: Bundle? = nil) {
        configuration = SubTitleConfiguration(
            title: Text(title, bundle: bundle),
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

    public init(title: String) {
        configuration = SubTitleConfiguration(
            title: Text(title),
            description: nil,
            details: nil
        )
    }

    public var body: some View {
        subTitleStyle.makeBody(configuration: configuration)
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

public struct DetailNavigationSubTitleStyle: SubTitleStyle {
    let showSeparator: Bool
    let minChevronSpacing: CGFloat
    let stateText: String?

    init(showSeparator: Bool, minChevronSpacing: CGFloat? = nil, stateText: String? = nil) {
        self.showSeparator = showSeparator
        self.minChevronSpacing = minChevronSpacing ?? 16
        self.stateText = stateText
    }

    public func makeBody(configuration: SubTitleConfiguration) -> some View {
        HStack(spacing: 0) {
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
                        .foregroundColor(Color(.secondaryLabel))
                }
            }

            Spacer(minLength: minChevronSpacing)

            if let text = stateText {
                Text(text)
                    .foregroundColor(Color(.secondaryLabel))
                    .padding(.horizontal)
            }

            Image(systemName: SFSymbolName.chevronForward)
                .foregroundColor(Color(.tertiaryLabel))
                .font(.body.weight(.semibold))
        }
        .bottomDivider(showSeparator: showSeparator)
        .padding(.leading)
    }
}

public struct InfoNavigationSubTitleStyle: SubTitleStyle {
    let showSeparator: Bool
    let minChevronSpacing: CGFloat

    init(showSeparator: Bool, minChevronSpacing: CGFloat? = nil) {
        self.showSeparator = showSeparator
        self.minChevronSpacing = minChevronSpacing ?? 16
    }

    public func makeBody(configuration: SubTitleConfiguration) -> some View {
        HStack(spacing: 0) {
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
                        .foregroundColor(Color(.secondaryLabel))
                }
            }

            Spacer(minLength: minChevronSpacing)

            Image(systemName: SFSymbolName.info)
                .foregroundColor(Colors.primary700)
                .font(.subheadline.weight(.semibold))
        }
        .bottomDivider(showSeparator: showSeparator)
        .padding(.leading)
    }
}

public struct PlainSectionContainerSubTitleStyle: SubTitleStyle {
    public init() {}

    public func makeBody(configuration: SubTitleConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            configuration
                .title
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

extension SubTitleStyle where Self == DefaultSubTitleStyle {
    /// A SubTitleStyle style that applies a default SubTitle
    ///
    /// To apply this style to a SubTitle, or to a view that contains SubTitle, use
    /// the ``View/subTitleStyle(_:)`` modifier.
    public static var simple: DefaultSubTitleStyle {
        DefaultSubTitleStyle()
    }
}

extension SubTitleStyle where Self == PlainSectionContainerSubTitleStyle {
    /// A SubTitleStyle style that applies a plain SubTitle
    ///
    /// To apply this style to a SubTitle, or to a view that contains SubTitle, use
    /// the ``View/subTitleStyle(_:)`` modifier.
    public static var plain: PlainSectionContainerSubTitleStyle {
        PlainSectionContainerSubTitleStyle()
    }
}

extension SubTitleStyle where Self == SectionContainerSubTitleStyle {
    /// A SubTitleStyle style that wraps the SubTitle with a divider at the bottom
    ///
    /// To apply this style to a SubTitle, or to a view that contains SubTitle, use
    /// the ``View/subTitleStyle(_:)`` modifier.
    public static var sectionContainer: SectionContainerSubTitleStyle {
        SectionContainerSubTitleStyle()
    }

    /// A SubTitleStyle that applies an optional divider at the bottom.
    ///
    /// To apply this style to a SubTitle, or to a view that contains SubTitles, use
    /// the ``View/subTitleStyle(.sectionContainer(showSeparator:))`` modifier.
    public static func sectionContainer(showSeparator: Bool = true) -> SectionContainerSubTitleStyle {
        SectionContainerSubTitleStyle(showSeparator: showSeparator)
    }
}

extension SubTitleStyle where Self == DetailNavigationSubTitleStyle {
    /// A SubTitleStyle style that applies a navigation chevron and wraps the SubTitle with a divider.
    ///
    /// To apply this style to a SubTitle, or to a view that contains SubTitle, use
    /// the ``View/subTitleStyle(_:)`` modifier.
    public static var navigation: DetailNavigationSubTitleStyle {
        DetailNavigationSubTitleStyle(showSeparator: true)
    }

    /// A SubTitleStyle that applies a navigation chevron and optionally skips the divider.
    ///
    /// To apply this style to a SubTitle, or to a view that contains SubTitles, use
    /// the ``View/subTitleStyle(.navigation(showSeparator:))`` modifier.
    public static func navigation(
        showSeparator: Bool = true,
        minChevronSpacing: CGFloat? = nil,
        stateText: String? = nil
    ) -> DetailNavigationSubTitleStyle {
        DetailNavigationSubTitleStyle(
            showSeparator: showSeparator,
            minChevronSpacing: minChevronSpacing,
            stateText: stateText
        )
    }
}

extension SubTitleStyle where Self == InfoNavigationSubTitleStyle {
    /// A SubTitleStyle style that applies an info icon and wraps the SubTitle with a divider.
    ///
    /// To apply this style to a SubTitle, or to a view that contains SubTitle, use
    /// the ``View/subTitleStyle(_:)`` modifier.
    public static var info: InfoNavigationSubTitleStyle {
        InfoNavigationSubTitleStyle(showSeparator: true)
    }

    /// A SubTitleStyle that applies an info icon and optionally skips the divider.
    ///
    /// To apply this style to a SubTitle, or to a view that contains SubTitles, use
    /// the ``View/subTitleStyle(.info(showSeparator:))`` modifier.
    public static func info(
        showSeparator: Bool = true,
        minChevronSpacing: CGFloat? = nil
    ) -> InfoNavigationSubTitleStyle {
        InfoNavigationSubTitleStyle(showSeparator: showSeparator, minChevronSpacing: minChevronSpacing)
    }
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

struct SubTitle_Preview: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            SubTitle(title: "abc", description: "def")
                .subTitleStyle(SectionContainerSubTitleStyle(showSeparator: true))

            SubTitle(title: "abc", details: "def", bundle: .module)
                .subTitleStyle(SectionContainerSubTitleStyle(showSeparator: true))

            SubTitle(title: "abc", description: "def", details: "ghi", bundle: .module)
                .subTitleStyle(SectionContainerSubTitleStyle(showSeparator: true))

            SubTitle(title: "abc", description: "def", details: "ghi", bundle: .module)
                .subTitleStyle(.navigation)

            SubTitle(title: "abc", description: "def", details: "ghi", bundle: .module)
                .subTitleStyle(.info)

            SubTitle(title: "abc", description: "def", details: "ghi", bundle: .module)

            SubTitle(title: "abc", description: "def", details: "ghi", bundle: .module)
                .subTitleStyle(.navigation(stateText: "Ein"))
        }
    }
}
