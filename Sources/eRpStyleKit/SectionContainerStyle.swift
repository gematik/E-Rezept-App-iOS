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

/// A type that applies a custom appearance to all `SectionContainer`s within a view hierarchy.
public protocol SectionContainerStyle {
    /// Used to change the styling of the `content` for a `SectionContainer`
    var content: SectionContainerContentStyle { get }
}

/// A style that is defines all possible styles that can be applied to the `content` of a `SectionContainer`
public enum SectionContainerContentStyle {
    /// default content style
    case plain
    /// bordered content style
    case border(color: Color, width: CGFloat)
    /// integrated list content style without leading/trailing padding
    case inline

    var borderWidth: CGFloat {
        switch self {
        case .plain, .inline:
            return 0.0
        case let .border(color: _, width: width):
            return width
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .inline:
            return 0.0
        default:
            return 16.0
        }
    }

    var backgroundColor: Color {
        switch self {
        case .inline:
            return Color(.systemBackground)
        default:
            return Color(.tertiarySystemBackground)
        }
    }

    var selectedColor: Color {
        switch self {
        case .inline:
            return Color(.systemGray5)
        default:
            return Color(.systemGray4)
        }
    }

    var edgeInsets: EdgeInsets {
        switch self {
        case .inline:
            return EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
        default:
            return EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        }
    }

    var headerEdgeInsets: EdgeInsets {
        switch self {
        case .inline:
            return EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
        default:
            return EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
        }
    }

    var borderColor: Color {
        switch self {
        case .plain, .inline:
            return Colors.systemColorClear
        case let .border(color: color, width: _):
            return color
        }
    }

    var topAndBottomDivider: Bool {
        switch self {
        case .inline:
            return true
        case .plain, .border:
            return false
        }
    }
}

struct DefaultSectionContainerStyle: SectionContainerStyle {
    var content = SectionContainerContentStyle.plain
}

public struct InlineSectionContainerStyle: SectionContainerStyle {
    public var content = SectionContainerContentStyle.inline
}

/// The border style of the `content` of a `SectionContainer`
public struct BorderSectionContainerStyle: SectionContainerStyle {
    private let color: Color
    private let width: CGFloat

    public init(color: Color = Colors.opaqueSeparator, width: CGFloat = 0.5) {
        self.color = color
        self.width = width
    }

    public var content: SectionContainerContentStyle {
        SectionContainerContentStyle.border(color: color, width: width)
    }
}

/// Define an `EnvironmentKey` default that than is used by SwiftUI as default
struct SectionContainerStyleKey: EnvironmentKey {
    static var defaultValue: SectionContainerStyle = DefaultSectionContainerStyle()
}

/// Register our new style to the `EnvironmentValues` so that it can be used within a SwiftUI body
extension EnvironmentValues {
    var sectionContainerStyle: SectionContainerStyle {
        get { self[SectionContainerStyleKey.self] }
        set { self[SectionContainerStyleKey.self] = newValue }
    }
}

extension View {
    /// Sets the style of `SectionContainer` within this view to a `SectionContainerStyle` with a custom appearance.
    public func sectionContainerStyle(_ style: SectionContainerStyle) -> some View {
        modifier(SectionContainerViewModifier(style: style))
    }
}

/// Provides easy use of the `BorderSectionContainerStyle`
extension SectionContainerStyle where Self == BorderSectionContainerStyle {
    /// A `SectionContainerStyle` that applies standard border around the entire content of a section
    ///
    /// To apply this style to a `SectionContainer` use the ``View/sectionContainerStyle(_:)`` modifier.
    public static var bordered: BorderSectionContainerStyle {
        BorderSectionContainerStyle()
    }
}

extension SectionContainerStyle where Self == InlineSectionContainerStyle {
    /// A integrated `SectionContainerStyle` without leading/trailing padding and without borders.
    ///
    /// To apply this style to a `SectionContainer` use the ``View/sectionContainerStyle(_:)`` modifier.
    public static var inline: SectionContainerStyle {
        InlineSectionContainerStyle()
    }
}

public struct SectionContainerViewModifier: ViewModifier {
    let style: SectionContainerStyle

    public func body(content: Content) -> some View {
        content
            .environment(\.sectionContainerStyle, style)
    }
}

extension View {
    /// This modifier helps to draw a border with rounded corners
    ///
    /// `clipShape` guarantees that it also works if the passed content has a colored background
    /// - Parameters:
    ///   - content: A view for which you plan to draw the border
    ///   - width: line width of the drawn border, defaults to 1
    ///   - cornerRadius: radius of the corners
    /// - Returns: Returns a new view with a  rounded border
    func border<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S: ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
            .overlay(roundedRect.strokeBorder(content, lineWidth: width))
    }
}

struct TopAndBottomDividerStyle: ViewModifier {
    let showSeparator: Bool

    init(showSeparator: Bool) {
        self.showSeparator = showSeparator
    }

    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if showSeparator {
                Divider()
            }

            content

            if showSeparator {
                Divider()
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
    }
}

extension View {
    func topAndBottomDivider(showSeparator: Bool = false) -> some View {
        modifier(TopAndBottomDividerStyle(showSeparator: showSeparator))
    }
}
