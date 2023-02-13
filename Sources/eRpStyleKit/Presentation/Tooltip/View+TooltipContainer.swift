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

extension View {
    /// Adds a tooltip container to the view hierarchy so that child views may use the `tooltip` modifier.
    public func tooltipContainer(enabled: Bool) -> some View {
        modifier(TooltipContainerModifier(enabled: enabled))
    }
}

struct TooltipContainerModifier: ViewModifier {
    let enabled: Bool

    init(enabled: Bool) {
        self.enabled = enabled &&
            !UIAccessibility.isVoiceOverRunning // TODO: migrate to iOS 15 API asap  swiftlint:disable:this todo
    }

    func body(content: Content) -> some View {
        content
            .overlayPreferenceValue(TooltipAnchorKey.self, alignment: .top) { tooltipElement in

                if let tooltipElement = tooltipElement, enabled {
                    GeometryReader { proxy in
                        ZStack {
                            Cutout(inset: 8)
                                .fill(Color.black.opacity(0.25))
                                .frame(
                                    width: proxy[tooltipElement.bounds].width,
                                    height: proxy[tooltipElement.bounds].height
                                )
                                .overlay(
                                    TooltipView(
                                        tooltipId: tooltipElement.tooltipId,
                                        trianglePosition: proxy[tooltipElement.bounds]
                                            .alignment(relativeTo: UIScreen.main.bounds),
                                        content: tooltipElement.view
                                    )
                                )
                                .offset(x: proxy[tooltipElement.bounds].minX, y: proxy[tooltipElement.bounds].minY)
                        }
                    }
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            tooltipElement.dismiss()
                        }
                    }
                    .transition(
                        .asymmetric(
                            insertion: .scale.animation(.default),
                            removal: .scale(scale: 0.1).combined(with: .opacity).animation(.default)
                        )
                    )
                }
            }
    }
}

struct Cutout: Shape {
    private var inset: CGFloat

    init(inset: CGFloat) {
        self.inset = inset
    }

    var animatableData: CGFloat {
        get { inset }
        set { inset = newValue }
    }

    func path(in rect: CGRect) -> Path {
        Path { mutablePath in
            let overscan = CGRect(x: -10000, y: -10000, width: 20000, height: 20000)
            mutablePath.addRect(overscan)

            let bounds = rect.insetBy(dx: -inset, dy: -inset)
            let radius = inset

            mutablePath.move(to: .init(x: bounds.midX, y: bounds.minY))
            mutablePath.addRelativeArc(
                center: .init(x: bounds.minX + radius, y: bounds.minY + radius),
                radius: radius,
                startAngle: .radians(-1 / 2 * CGFloat.pi),
                delta: .radians(-1 / 2 * CGFloat.pi)
            )
            mutablePath.addRelativeArc(
                center: .init(x: bounds.minX + radius, y: bounds.maxY - radius),
                radius: radius,
                startAngle: .radians(-CGFloat.pi),
                delta: .radians(-1 / 2 * CGFloat.pi)
            )
            mutablePath.addRelativeArc(
                center: .init(x: bounds.maxX - radius, y: bounds.maxY - radius),
                radius: radius,
                startAngle: .radians(-3 / 2 * CGFloat.pi),
                delta: .radians(-1 / 2 * CGFloat.pi)
            )
            mutablePath.addRelativeArc(
                center: .init(x: bounds.maxX - radius, y: bounds.minY + radius),
                radius: radius,
                startAngle: .radians(0),
                delta: .radians(-1 / 2 * CGFloat.pi)
            )
            mutablePath.closeSubpath()
        }
    }
}
