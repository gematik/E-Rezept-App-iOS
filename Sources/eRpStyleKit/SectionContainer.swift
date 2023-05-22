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

public struct SectionContainer<Header: View, Content: View, Footer: View>: View {
    @Environment(\.sectionContainerStyle) var style
    var content: Content
    var header: () -> Header?
    var footer: () -> Footer?

    internal init(@ViewBuilder header: @escaping () -> Header? = { nil },
                  @ViewBuilder footer: @escaping () -> Footer? = { nil },
                  @ViewBuilder modifiedContent: @escaping () -> Content) {
        self.header = header
        content = modifiedContent()
        self.footer = footer
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let header = header() {
                Group {
                    header
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.headline)
                .padding(style.content.headerEdgeInsets)
            }

            VStack(spacing: 0) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .background(style.content.backgroundColor)
            .cornerRadius(style.content.cornerRadius)
            .border(
                style.content.borderColor,
                width: style.content.borderWidth,
                cornerRadius: style.content.cornerRadius
            )
            .topAndBottomDivider(showSeparator: style.content.topAndBottomDivider)
            .padding(style.content.edgeInsets)

            if let footer = footer() {
                Group {
                    footer
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.footnote)
                .foregroundColor(Color(.secondaryLabel))
                .buttonStyle(FooterButtonStyle())
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
}

// swiftlint:disable operator_usage_whitespace large_tuple missing_docs trailing_closure no_extension_access_modifier
// swiftlint:disable file_length
public extension SectionContainer {
    init<
        Content0: View,
        Content1: View
    >(@ViewBuilder header: @escaping () -> Header? = { nil },
      @ViewBuilder footer: @escaping () -> Footer? = { nil },
      @ViewBuilder content: @escaping () -> TupleView<(
          Content0,
          Content1
      )>)
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>
        )> {
        let content = content()

        self.init(header: header, footer: footer, modifiedContent: {
            content.value.0
                .modifier(SectionContainerCellModifier())

            content.value.1
                .modifier(SectionContainerCellModifier(last: true))
        })
    }

    init<
        Content0: View,
        Content1: View,
        Content2: View
    >(@ViewBuilder header: @escaping () -> Header? = { nil },
      @ViewBuilder footer: @escaping () -> Footer? = { nil },
      @ViewBuilder content: @escaping ()
          -> TupleView<(
              Content0,
              Content1,
              Content2
          )>)
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>

        )> {
        let content = content()

        self.init(header: header, footer: footer, modifiedContent: {
            content.value.0
                .modifier(SectionContainerCellModifier())
            content.value.1
                .modifier(SectionContainerCellModifier())
            content.value.2
                .modifier(SectionContainerCellModifier(last: true))
        })
    }

    init<
        Content0: View,
        Content1: View,
        Content2: View,
        Content3: View
    >(@ViewBuilder header: @escaping () -> Header? = { nil },
      @ViewBuilder footer: @escaping () -> Footer? = { nil },
      @ViewBuilder content: @escaping ()
          -> TupleView<(
              Content0,
              Content1,
              Content2,
              Content3
          )>)
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>
        )> {
        let content = content()

        self.init(header: header, footer: footer, modifiedContent: {
            content.value.0
                .modifier(SectionContainerCellModifier())
            content.value.1
                .modifier(SectionContainerCellModifier())
            content.value.2
                .modifier(SectionContainerCellModifier())
            content.value.3
                .modifier(SectionContainerCellModifier(last: true))
        })
    }

    init<
        Content0: View,
        Content1: View,
        Content2: View,
        Content3: View,
        Content4: View
    >(@ViewBuilder header: @escaping () -> Header? = { nil },
      @ViewBuilder footer: @escaping () -> Footer? = { nil },
      @ViewBuilder content: @escaping ()
          -> TupleView<(
              Content0,
              Content1,
              Content2,
              Content3,
              Content4
          )>)
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>
        )> {
        let content = content()

        self.init(header: header, footer: footer, modifiedContent: {
            content.value.0
                .modifier(SectionContainerCellModifier())
            content.value.1
                .modifier(SectionContainerCellModifier())
            content.value.2
                .modifier(SectionContainerCellModifier())
            content.value.3
                .modifier(SectionContainerCellModifier())
            content.value.4
                .modifier(SectionContainerCellModifier(last: true))
        })
    }

    init<Content0: View, Content1: View, Content2: View, Content3: View, Content4: View, Content5: View>(
        @ViewBuilder header: @escaping () -> Header? = { nil },
        @ViewBuilder footer: @escaping () -> Footer? = { nil },
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>
        )> {
        let content = content()

        self.init(header: header, footer: footer, modifiedContent: {
            content.value.0
                .modifier(SectionContainerCellModifier())
            content.value.1
                .modifier(SectionContainerCellModifier())
            content.value.2
                .modifier(SectionContainerCellModifier())
            content.value.3
                .modifier(SectionContainerCellModifier())
            content.value.4
                .modifier(SectionContainerCellModifier())
            content.value.5
                .modifier(SectionContainerCellModifier(last: true))
        })
    }

    init<Content0: View, Content1: View, Content2: View, Content3: View, Content4: View, Content5: View,
        Content6: View>(
        @ViewBuilder header: @escaping () -> Header? = { nil },
        @ViewBuilder footer: @escaping () -> Footer? = { nil },
        @ViewBuilder content: @escaping ()
            -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5, Content6)>
    )
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>,
            ModifiedContent<Content6, SectionContainerCellModifier>
        )> {
        let content = content()

        self.init(header: header, footer: footer, modifiedContent: {
            content.value.0
                .modifier(SectionContainerCellModifier())
            content.value.1
                .modifier(SectionContainerCellModifier())
            content.value.2
                .modifier(SectionContainerCellModifier())
            content.value.3
                .modifier(SectionContainerCellModifier())
            content.value.4
                .modifier(SectionContainerCellModifier())
            content.value.5
                .modifier(SectionContainerCellModifier())
            content.value.6
                .modifier(SectionContainerCellModifier(last: true))
        })
    }

    init<
        Content0: View,
        Content1: View,
        Content2: View,
        Content3: View,
        Content4: View,
        Content5: View,
        Content6: View,
        Content7: View
    >(@ViewBuilder header: @escaping () -> Header? = { nil },
      @ViewBuilder footer: @escaping () -> Footer? = { nil },
      @ViewBuilder content: @escaping ()
          -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7)>)
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>,
            ModifiedContent<Content6, SectionContainerCellModifier>,
            ModifiedContent<Content7, SectionContainerCellModifier>
        )> {
        let content = content()

        self.init(header: header, footer: footer, modifiedContent: {
            content.value.0
                .modifier(SectionContainerCellModifier())
            content.value.1
                .modifier(SectionContainerCellModifier())
            content.value.2
                .modifier(SectionContainerCellModifier())
            content.value.3
                .modifier(SectionContainerCellModifier())
            content.value.4
                .modifier(SectionContainerCellModifier())
            content.value.5
                .modifier(SectionContainerCellModifier())
            content.value.6
                .modifier(SectionContainerCellModifier())
            content.value.7
                .modifier(SectionContainerCellModifier(last: true))
        })
    }

    init<
        Content0: View,
        Content1: View,
        Content2: View,
        Content3: View,
        Content4: View,
        Content5: View,
        Content6: View,
        Content7: View,
        Content8: View
    >(@ViewBuilder header: @escaping () -> Header? = { nil },
      @ViewBuilder footer: @escaping () -> Footer? = { nil },
      @ViewBuilder content: @escaping ()
          -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7, Content8)>)
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>,
            ModifiedContent<Content6, SectionContainerCellModifier>,
            ModifiedContent<Content7, SectionContainerCellModifier>,
            ModifiedContent<Content8, SectionContainerCellModifier>
        )> {
        let content = content()

        self.init(header: header, footer: footer, modifiedContent: {
            content.value.0
                .modifier(SectionContainerCellModifier())
            content.value.1
                .modifier(SectionContainerCellModifier())
            content.value.2
                .modifier(SectionContainerCellModifier())
            content.value.3
                .modifier(SectionContainerCellModifier())
            content.value.4
                .modifier(SectionContainerCellModifier())
            content.value.5
                .modifier(SectionContainerCellModifier())
            content.value.6
                .modifier(SectionContainerCellModifier())
            content.value.7
                .modifier(SectionContainerCellModifier())
            content.value.8
                .modifier(SectionContainerCellModifier(last: true))
        })
    }

    init<
        Content0: View,
        Content1: View,
        Content2: View,
        Content3: View,
        Content4: View,
        Content5: View,
        Content6: View,
        Content7: View,
        Content8: View,
        Content9: View
    >(@ViewBuilder header: @escaping () -> Header? = { nil },
      @ViewBuilder footer: @escaping () -> Footer? = { nil },
      @ViewBuilder content: @escaping ()
          -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7, Content8,
                        Content9)>)
        where Content == TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>,
            ModifiedContent<Content6, SectionContainerCellModifier>,
            ModifiedContent<Content7, SectionContainerCellModifier>,
            ModifiedContent<Content8, SectionContainerCellModifier>,
            ModifiedContent<Content9, SectionContainerCellModifier>
        )> {
        let content = content()

        self.init(header: header, footer: footer, modifiedContent: {
            content.value.0
                .modifier(SectionContainerCellModifier())
            content.value.1
                .modifier(SectionContainerCellModifier())
            content.value.2
                .modifier(SectionContainerCellModifier())
            content.value.3
                .modifier(SectionContainerCellModifier())
            content.value.4
                .modifier(SectionContainerCellModifier())
            content.value.5
                .modifier(SectionContainerCellModifier())
            content.value.6
                .modifier(SectionContainerCellModifier())
            content.value.7
                .modifier(SectionContainerCellModifier())
            content.value.8
                .modifier(SectionContainerCellModifier())
            content.value.9
                .modifier(SectionContainerCellModifier(last: true))
        })
    }

    @_disfavoredOverload
    init<
        Content0: View,
        Content1: View,
        Content2: View,
        Content3: View,
        Content4: View,
        Content5: View,
        Content6: View,
        Content7: View,
        Content8: View,
        Content9: View,
        Content10: View
    >(@ViewBuilder header: @escaping () -> Header? = { nil },
      @ViewBuilder footer: @escaping () -> Footer? = { nil },
      @ViewBuilder content: @escaping ()
          -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7, Content8,
                        Content9)>,
      @ViewBuilder moreContent: @escaping () -> Content10)
        where Content == TupleView<(
            Group<TupleView<(
                ModifiedContent<Content0, SectionContainerCellModifier>,
                ModifiedContent<Content1, SectionContainerCellModifier>,
                ModifiedContent<Content2, SectionContainerCellModifier>,
                ModifiedContent<Content3, SectionContainerCellModifier>,
                ModifiedContent<Content4, SectionContainerCellModifier>,
                ModifiedContent<Content5, SectionContainerCellModifier>,
                ModifiedContent<Content6, SectionContainerCellModifier>,
                ModifiedContent<Content7, SectionContainerCellModifier>,
                ModifiedContent<Content8, SectionContainerCellModifier>,
                ModifiedContent<Content9, SectionContainerCellModifier>
            )>>,
            Group<ModifiedContent<Content10, SectionContainerCellModifier>>
        )> {
        let content = content()
        let moreContent = moreContent()

        self.init(header: header, footer: footer, modifiedContent: {
            Group {
                content.value.0
                    .modifier(SectionContainerCellModifier())
                content.value.1
                    .modifier(SectionContainerCellModifier())
                content.value.2
                    .modifier(SectionContainerCellModifier())
                content.value.3
                    .modifier(SectionContainerCellModifier())
                content.value.4
                    .modifier(SectionContainerCellModifier())
                content.value.5
                    .modifier(SectionContainerCellModifier())
                content.value.6
                    .modifier(SectionContainerCellModifier())
                content.value.7
                    .modifier(SectionContainerCellModifier())
                content.value.8
                    .modifier(SectionContainerCellModifier())
                content.value.9
                    .modifier(SectionContainerCellModifier())
            }
            Group {
                moreContent
                    .modifier(SectionContainerCellModifier(last: true))
            }
        })
    }

    init<
        Content0: View,
        Content1: View,
        Content2: View,
        Content3: View,
        Content4: View,
        Content5: View,
        Content6: View,
        Content7: View,
        Content8: View,
        Content9: View,
        Content10: View,
        Content11: View
    >(@ViewBuilder header: @escaping () -> Header? = { nil },
      @ViewBuilder footer: @escaping () -> Footer? = { nil },
      @ViewBuilder content: @escaping ()
          -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7, Content8,
                        Content9)>,
      @ViewBuilder moreContent: @escaping () -> TupleView<(Content10, Content11)>)
        where Content == TupleView<(Group<TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>,
            ModifiedContent<Content6, SectionContainerCellModifier>,
            ModifiedContent<Content7, SectionContainerCellModifier>,
            ModifiedContent<Content8, SectionContainerCellModifier>,
            ModifiedContent<Content9, SectionContainerCellModifier>
        )>>, Group<TupleView<(ModifiedContent<Content10, SectionContainerCellModifier>,
                              ModifiedContent<Content11, SectionContainerCellModifier>)>>)> {
        let content = content()
        let moreContent = moreContent()

        self.init(header: header, footer: footer, modifiedContent: {
            Group {
                content.value.0
                    .modifier(SectionContainerCellModifier())
                content.value.1
                    .modifier(SectionContainerCellModifier())
                content.value.2
                    .modifier(SectionContainerCellModifier())
                content.value.3
                    .modifier(SectionContainerCellModifier())
                content.value.4
                    .modifier(SectionContainerCellModifier())
                content.value.5
                    .modifier(SectionContainerCellModifier())
                content.value.6
                    .modifier(SectionContainerCellModifier())
                content.value.7
                    .modifier(SectionContainerCellModifier())
                content.value.8
                    .modifier(SectionContainerCellModifier())
                content.value.9
                    .modifier(SectionContainerCellModifier())
            }
            Group {
                moreContent.value.0
                    .modifier(SectionContainerCellModifier())
                moreContent.value.1
                    .modifier(SectionContainerCellModifier(last: true))
            }
        })
    }

    init<
        Content0: View,
        Content1: View,
        Content2: View,
        Content3: View,
        Content4: View,
        Content5: View,
        Content6: View,
        Content7: View,
        Content8: View,
        Content9: View,
        Content10: View,
        Content11: View,
        Content12: View
    >(@ViewBuilder header: @escaping () -> Header? = { nil },
      @ViewBuilder footer: @escaping () -> Footer? = { nil },
      @ViewBuilder content: @escaping ()
          -> TupleView<(Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7, Content8,
                        Content9)>,
      @ViewBuilder moreContent: @escaping () -> TupleView<(Content10, Content11, Content12)>)
        where Content == TupleView<(Group<TupleView<(
            ModifiedContent<Content0, SectionContainerCellModifier>,
            ModifiedContent<Content1, SectionContainerCellModifier>,
            ModifiedContent<Content2, SectionContainerCellModifier>,
            ModifiedContent<Content3, SectionContainerCellModifier>,
            ModifiedContent<Content4, SectionContainerCellModifier>,
            ModifiedContent<Content5, SectionContainerCellModifier>,
            ModifiedContent<Content6, SectionContainerCellModifier>,
            ModifiedContent<Content7, SectionContainerCellModifier>,
            ModifiedContent<Content8, SectionContainerCellModifier>,
            ModifiedContent<Content9, SectionContainerCellModifier>
        )>>, Group<TupleView<(
            ModifiedContent<Content10, SectionContainerCellModifier>,
            ModifiedContent<Content11, SectionContainerCellModifier>,
            ModifiedContent<Content12, SectionContainerCellModifier>
        )>>)> {
        let content = content()
        let moreContent = moreContent()

        self.init(header: header, footer: footer, modifiedContent: {
            Group {
                content.value.0
                    .modifier(SectionContainerCellModifier())
                content.value.1
                    .modifier(SectionContainerCellModifier())
                content.value.2
                    .modifier(SectionContainerCellModifier())
                content.value.3
                    .modifier(SectionContainerCellModifier())
                content.value.4
                    .modifier(SectionContainerCellModifier())
                content.value.5
                    .modifier(SectionContainerCellModifier())
                content.value.6
                    .modifier(SectionContainerCellModifier())
                content.value.7
                    .modifier(SectionContainerCellModifier())
                content.value.8
                    .modifier(SectionContainerCellModifier())
                content.value.9
                    .modifier(SectionContainerCellModifier())
            }
            Group {
                moreContent.value.0
                    .modifier(SectionContainerCellModifier())
                moreContent.value.1
                    .modifier(SectionContainerCellModifier())
                moreContent.value.2
                    .modifier(SectionContainerCellModifier(last: true))
            }
        })
    }
}

struct SectionContainer_Preview: PreviewProvider {
    struct ExampleView: View {
        var body: some View {
            ScrollView {
                SectionContainer(
                    header: { Text("Header") },
                    footer: { Text("Footer") },
                    content: {
                        Button(action: {}, label: {
                            Label("Within a button", systemImage: "qrcode")
                        }).buttonStyle(.plain)

                        Button(action: {}, label: {
                            Label("Used for navigation", systemImage: "qrcode")
                        })
                            .buttonStyle(DetailNavigationButtonStyle(showSeparator: true))

                        Toggle(isOn: .constant(true)) {
                            Label("Simple Toggle", systemImage: "qrcode")
                        }
                        .toggleStyle(.plain)

                        Toggle(isOn: .constant(true)) {
                            Label("Radio toggle", systemImage: "qrcode")
                        }
                        .toggleStyle(.radio)
                        .buttonStyle(.navigation)

                        Toggle(isOn: .constant(true)) {
                            Label("Used for navigation", systemImage: "qrcode")
                        }
                        .toggleStyle(.radioWithNavigation)
                        .buttonStyle(.navigation)
                    }
                )
            }
        }
    }

    static var previews: some View {
        ExampleView()
            .background(Color(.secondarySystemBackground))

        ExampleView()
            .background(Color(.secondarySystemBackground))
            .preferredColorScheme(.dark)

        ExampleView()
            .sectionContainerStyle(.inline)

        ExampleView()
            .sectionContainerStyle(.inline)
            .preferredColorScheme(.dark)
    }
}
