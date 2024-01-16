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

import Combine
import SwiftUI

public protocol TooltipId: Equatable, CustomStringConvertible {
    var priority: UInt { get }
}

extension View {
    /// Adds a tooltip to the view. Must only be used within a View structure that contains a parent node with the
    /// `tooltipContainer` Modifier.
    /// - Parameters:
    ///   - id: Id of the tooltip to show, best practice is to use an `enum` that conforms to `TooltipId`, where each
    ///   case represents a single tooltip.
    ///   - content: A view builder that represents the tooltip. Must somehow define a width to work properly.
    public func tooltip(id: any TooltipId, @ViewBuilder content: () -> some View) -> some View {
        modifier(TooltipModifier(id: id, tooltipContent: content()))
    }
}

struct TooltipModifier<TooltipContent: View>: ViewModifier {
    let tooltipContent: TooltipContent
    let tooltipId: any TooltipId

    // This value will be loaded onAppear and updated on tooltip dismiss
    @State var tooltipHidden = true

    init(id: any TooltipId, tooltipContent: TooltipContent) {
        self.tooltipContent = tooltipContent
        tooltipId = id
    }

    @Environment(\.tooltipDisplayStorage) var tooltipDisplayStorage: TooltipDisplayStorage
    @Environment(\.isEnabled) var isEnabled: Bool

    func body(content: Content) -> some View {
        if tooltipHidden || !isEnabled {
            content
                .onAppear {
                    self.tooltipHidden = tooltipDisplayStorage.tooltipHidden(tooltipId.description)
                }
        } else {
            content
                .overlay(
                    TooltipProxy(
                        tooltipId: tooltipId,
                        content: { tooltipContent },
                        dismiss: {
                            tooltipDisplayStorage.setTooltipHidden(tooltipId.description, true)
                            tooltipHidden = true
                        }
                    )
                )
        }
    }

    struct TooltipProxy: View {
        let content: TooltipContent
        let tooltipId: any TooltipId
        let dismiss: () -> Void

        init(tooltipId: any TooltipId, @ViewBuilder content: () -> TooltipContent, dismiss: @escaping () -> Void) {
            self.tooltipId = tooltipId
            self.content = content()
            self.dismiss = dismiss
        }

        var body: some View {
            EmptyView()
                .anchorPreference(key: TooltipAnchorKey.self, value: .bounds) { anchor in
                    TooltipElement(view: AnyView(content), tooltipId: tooltipId, bounds: anchor) {
                        dismiss()
                    }
                }
        }
    }
}

struct TooltipElement {
    let view: AnyView
    let bounds: Anchor<CGRect>
    let dismiss: () -> Void
    let tooltipId: any TooltipId

    init(view: AnyView, tooltipId: any TooltipId, bounds: Anchor<CGRect>, dismiss: @escaping () -> Void) {
        self.view = view
        self.tooltipId = tooltipId
        self.bounds = bounds
        self.dismiss = dismiss
    }
}

struct TooltipAnchorKey: PreferenceKey {
    static func reduce(value: inout TooltipElement?, nextValue: () -> TooltipElement?) {
        guard let nextValue = nextValue() else {
            return
        }
        guard let unwrappedValue = value else {
            value = nextValue
            return
        }
        if nextValue.tooltipId.priority > unwrappedValue.tooltipId.priority {
            value = nextValue
        }
    }

    typealias Value = TooltipElement?
}

enum PlaygroundTooltipId: UInt, TooltipId {
    static func <(lhs: PlaygroundTooltipId, rhs: PlaygroundTooltipId) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var description: String { "PlaygroundTooltipId_\(rawValue)" }

    case tooltipA = 100
    case tooltipB = 200
    case tooltipC = 300
    case tooltipD = 400
    case tooltipE = 500
    case tooltipF = 600
    case tooltipG = 700
    case tooltipH = 800
    case tooltipI = 900
    case tooltipJ = 850
    case tooltipK = 750

    var priority: UInt { rawValue }
}

struct TooltipPlayground: View {
    struct Btn: View {
        var body: some View {
            Button {} label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .padding()
                    .background(Circle().fill(Color.primary))
            }
        }
    }

    var body: some View {
        TabView {
            NavigationView {
                ScrollView {
                    VStack(spacing: 50) {
                        Text("Lorem ipsum dolor sit amet...")

                        HStack {
                            Btn()
                                .frame(width: 120, height: 10, alignment: .center)
                                .background(Color.blue)
                                .clipped()
                                .tooltip(id: PlaygroundTooltipId.tooltipA) {
                                    Text("Tooltip A")
                                        .frame(width: 180, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                            Spacer()

                            Btn()
                                .tooltip(id: PlaygroundTooltipId.tooltipB) {
                                    Text("Tooltip B")
                                        .frame(width: 80, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                            Spacer()

                            Btn()
                                .tooltip(id: PlaygroundTooltipId.tooltipC) {
                                    Text("Tooltip C")
                                        .frame(width: 80, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                        }

                        Text("Lorem ipsum dolor sit amet...")
                            .background(Color.green)
                        Text("Lorem ipsum dolor sit amet...")
                            .background(Color.green)

                        HStack {
                            Btn()
                                .tooltip(id: PlaygroundTooltipId.tooltipD) {
                                    Text("Tooltip D")
                                        .frame(width: 180, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                            Spacer()

                            Btn()
                                .tooltip(id: PlaygroundTooltipId.tooltipE) {
                                    Text("Tooltip E")
                                        .frame(width: 80, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                            Spacer()

                            Btn()
                                .frame(width: 120, height: 10, alignment: .center)
                                .clipped()
                                .background(Color.blue)
                                .tooltip(id: PlaygroundTooltipId.tooltipF) {
                                    Text("Tooltip")
                                        .frame(width: 80, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                        }
                        Text("Lorem ipsum dolor sit amet...")
                            .background(Color.green)

                        Text("Lorem ipsum dolor sit amet...")
                        Text("Lorem ipsum dolor sit amet...")
                        Text("Lorem ipsum dolor sit amet...")
                            .background(Color.green)

                        HStack {
                            Btn()
                                .tooltip(id: PlaygroundTooltipId.tooltipG) {
                                    Text("Tooltip")
                                        .frame(width: 180, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                            Spacer()

                            Btn()
                                .tooltip(id: PlaygroundTooltipId.tooltipH) {
                                    Text("Tooltip")
                                        .frame(width: 80, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                            Spacer()

                            Btn()
                                .font(.title.bold())
                                .frame(width: 120, height: 10, alignment: .center)
                                .clipped()
                                .background(Color.blue)
                                .tooltip(id: PlaygroundTooltipId.tooltipI) {
                                    Text("Tooltip")
                                        .frame(width: 80, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                        }
                    }
                    .padding()
                }
                .font(.subheadline.bold())
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Text("abc")
                            .tooltip(id: PlaygroundTooltipId.tooltipJ) {
                                Text("Tooltip")
                                    .frame(width: 80, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                    }

                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("abc")
                            .tooltip(id: PlaygroundTooltipId.tooltipK) {
                                Text("Tooltip")
                                    .frame(width: 80, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                    }
                }
                .navigationTitle("ABC")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .tooltipContainer(enabled: true)
    }
}

struct TooltipPlayground_Previews: PreviewProvider {
    static var previews: some View {
        TooltipPlayground()
    }
}
