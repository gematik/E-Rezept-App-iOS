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

/// `ButtonStyle` for navigation buttons with a chevron. This style must be applied manually to `Button`s that should be
/// presented as navigational buttons. This style is not meant to be used with `NavigationLink`and will probably not
/// work with these.
public struct DetailNavigationButtonStyle: ButtonStyle {
    let showSeparator: Bool
    let minChevronSpacing: CGFloat

    init(showSeparator: Bool, minChevronSpacing: CGFloat? = nil) {
        self.showSeparator = showSeparator
        self.minChevronSpacing = minChevronSpacing ?? 16
    }

    @Environment(\.sectionContainerStyle) var style
    @Environment(\.isEnabled) var isEnabled: Bool

    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .opacity(isEnabled ? 1.0 : 0.5)
                .keyValuePairStyle(SeparatedKeyValuePairStyle(showSeparator: showSeparator))
                .subTitleStyle(.navigation(showSeparator: showSeparator, minChevronSpacing: minChevronSpacing))
                .labelStyle(DetailNavigationLabelStyle(
                    showSeparator: showSeparator,
                    minChevronSpacing: minChevronSpacing
                ))
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .foregroundColor(Color(.label))
        .background(
            configuration.isPressed ? style.content.selectedColor : style.content.backgroundColor
        )
    }
}

public struct DetailNavigationLabelStyle: LabelStyle {
    let showSeparator: Bool
    let minChevronSpacing: CGFloat

    init(showSeparator: Bool, minChevronSpacing: CGFloat) {
        self.showSeparator = showSeparator
        self.minChevronSpacing = minChevronSpacing
    }

    public func makeBody(configuration: Configuration) -> some View {
        Label(title: {
            HStack(spacing: 0) {
                configuration.title

                Spacer(minLength: minChevronSpacing)

                Image(systemName: SFSymbolName.chevronForward)
                    .foregroundColor(Color(.tertiaryLabel))
                    .font(.body.weight(.semibold))
            }
        }, icon: {
            configuration.icon
        })
            .labelStyle(SectionContainerLabelStyle(showSeparator: showSeparator))
            .subTitleStyle(.navigation(showSeparator: showSeparator, minChevronSpacing: minChevronSpacing))
            .keyValuePairStyle(PlainKeyValuePairStyle())
    }
}

public struct BottomDividerStyle: ViewModifier {
    @Environment(\.sectionContainerIsLastElement) var isLastElement: Bool
    let showSeparator: Bool

    public init(showSeparator: Bool) {
        self.showSeparator = showSeparator
    }

    public func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content
                .padding([.bottom, .trailing, .top])

            if showSeparator, !isLastElement {
                Divider()
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
    }
}

extension View {
    func bottomDivider(showSeparator: Bool = true) -> some View {
        modifier(BottomDividerStyle(showSeparator: showSeparator))
    }
}

public struct TopDividerStyle: ViewModifier {
    let showSeparator: Bool

    public init(showSeparator: Bool) {
        self.showSeparator = showSeparator
    }

    public func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if showSeparator {
                Divider()
            }

            content
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
    }
}

extension View {
    func topDivider(showSeparator: Bool = true) -> some View {
        modifier(TopDividerStyle(showSeparator: showSeparator))
    }
}

extension ButtonStyle where Self == DetailNavigationButtonStyle {
    /// A button style that applies a navigation chevron and wraps the button with a divider.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View/buttonStyle(_:)`` modifier.
    public static var navigation: DetailNavigationButtonStyle { DetailNavigationButtonStyle(showSeparator: true) }

    /// A button style that applies a navigation chevron and optionally skips the divider.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View/buttonStyle(.navigation(showSeparator:))`` modifier.
    public static func navigation(showSeparator: Bool = true,
                                  minChevronSpacing: CGFloat? = nil) -> DetailNavigationButtonStyle {
        DetailNavigationButtonStyle(showSeparator: showSeparator, minChevronSpacing: minChevronSpacing)
    }
}

struct DetailNavigationButtonStyle_Preview: PreviewProvider {
    struct ExampleView: View {
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    SectionContainer(header: {
                        Text("Navigational Button")
                    }, content: {
                        Button(action: {}, label: {
                            Text("Simple Text without icon needs manual padding and frame!")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .bottomDivider()
                                .padding(.leading)
                        })
                            .buttonStyle(.navigation)

                        Button(action: {}, label: {
                            Label(title: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("You may use manual components")

                                    Text("as the `title` part of a `Label`.")
                                        .font(.subheadline)
                                }
                            }, icon: {})
                        })
                            .buttonStyle(.navigation)

                        Button(action: {}, label: {
                            Label(title: { Text("Simple Label without icon") }, icon: {})
                        })
                            .buttonStyle(.navigation)

                        Button(action: {}, label: {
                            Label("Simple Label", systemImage: "qrcode")
                        })
                            .buttonStyle(.navigation)

                        Button(action: {}, label: {
                            Label(title: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("And pair them with an")

                                    Text("Icon to create beautiful buttons")
                                        .font(.subheadline)
                                }
                            }, icon: {
                                Image(systemName: "qrcode")
                            })
                        })
                            .buttonStyle(.navigation)

                        Toggle(isOn: .constant(true)) {
                            Label {
                                Text(
                                    "Toggles may be navigational Items too!, just apply `DetailNavigationButtonStyle`"
                                )
                                .font(.footnote)
                            } icon: {
                                Image(systemName: "qrcode")
                            }
                        }
                        .buttonStyle(.plain)

                        Toggle(isOn: .constant(true)) {
                            Label {
                                Text(
                                    "Toggles may be navigational Items too!, just apply `DetailNavigationButtonStyle`"
                                )
                                .font(.footnote)
                            } icon: {
                                Image(systemName: "qrcode")
                            }
                        }
                        .toggleStyle(.radio)
                        .buttonStyle(.plain)

                        Button(action: {}, label: {
                            SubTitle(title: "Here", description: "everything is optional", details: "some details")
                        })
                            .buttonStyle(.navigation)

                        Button(action: {}, label: {
                            SubTitle(title: "Here", description: "everything is optional", details: "some details")
                                .subTitleStyle(.info)
                        })
                            .buttonStyle(.navigation)
                    })
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }

    static var previews: some View {
        Group {
            ExampleView()
                .sectionContainerStyle(.bordered)
                .background(Color(.secondarySystemBackground))
        }

        Group {
            ExampleView()
                .sectionContainerStyle(.bordered)
        }.preferredColorScheme(.dark)

        Group {
            ExampleView()
                .sectionContainerStyle(.inline)
        }

        Group {
            ExampleView()
                .sectionContainerStyle(.inline)
        }.preferredColorScheme(.dark)
    }
}
