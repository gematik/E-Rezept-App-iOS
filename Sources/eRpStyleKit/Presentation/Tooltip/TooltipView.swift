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

/// Contains a single Tooltip and wraps it inside a background with a little triangle pointing to the source of the
/// tooltip.
struct TooltipView<Content: View>: View {
    @State private var width = 10.0 // initial values will be overwritten on appearance
    @State private var height = 10.0

    private var position = Alignment.top
    @State private var frame = CGRect.zero

    var content: Content
    let tooltipId: any TooltipId

    init(tooltipId: any TooltipId, trianglePosition: Alignment, content: Content) {
        self.tooltipId = tooltipId
        position = trianglePosition
        self.content = content
    }

    var body: some View {
        GeometryReader { overlayedContentProxy in
            VStack { // user defined content
                content
                    .id("Tooltip-\(tooltipId.description)")
                    .transition(tooltipAppearanceAnimation)
            }
            .padding()
            .foregroundColor(Color.white)
            .background( // dark backdrop shape
                TooltipBackgroundShape(
                    targetSize: overlayedContentProxy.size,
                    tooltipContentSize: .init(width: width, height: height),
                    triangleAlignment: triangleAlignment
                )
                .fill(Color(.systemGray4.resolvedColor(with: .init(userInterfaceStyle: .dark))))
                .transition(tooltipAppearanceAnimation)
                .id("TooltipBackground-\(tooltipId.description)") // Custom ID to enable fade out/in animation
            )
            .offset(offset(for: overlayedContentProxy.size))
            // Retrieve/Update content and origin shape related data
            .overlay(
                GeometryReader { ownSizeProxy in
                    Rectangle()
                        .fill(.clear)
                        .onChange(of: tooltipId.description) { _ in
                            self.width = ownSizeProxy.size.width
                            self.height = ownSizeProxy.size.height
                        }
                        .onAppear {
                            self.width = ownSizeProxy.size.width
                            self.height = ownSizeProxy.size.height
                        }
                }
            )
        }
    }
}

extension TooltipView {
    func xOffset(for size: CGSize) -> CGFloat {
        switch position.horizontal {
        case .leading:
            return 0
        case .trailing:
            return -width + size.width
        default:
            return -width * 0.5 + size.width * 0.5
        }
    }

    func yOffset(for size: CGSize) -> CGFloat {
        switch position.vertical {
        case .bottom:
            return -height - 15
        default:
            return size.height + 15
        }
    }

    func offset(for size: CGSize) -> CGSize {
        CGSize(
            width: xOffset(for: size),
            height: yOffset(for: size)
        )
    }

    var triangleAlignment: Alignment {
        switch position {
        case .topLeading,
             .leading:
            return .topLeading
        case .top,
             .center:
            return .top
        case .topTrailing,
             .trailing:
            return .topTrailing
        default:
            return position
        }
    }

    private var tooltipAppearanceAnimation: AnyTransition {
        .scale(scale: 0.1, anchor: triangleAlignment.unitPoint).combined(with: .opacity)
    }
}

extension Alignment {
    var unitPoint: UnitPoint {
        switch vertical {
        case .top:
            return .top
        case .bottom:
            return .bottom
        default:
            return .center
        }
    }
}

struct TooltipBackgroundShape: Shape {
    var targetSize: CGSize
    var triangleAlignment: Alignment
    var tooltipContentSize: CGSize

    static let triangleSize = CGSize(width: 24, height: 12)
    static let triangleTipRadius = 4.0
    static let backgroundCornerRadius = 8.0

    var animatableData: AnimatablePair<CGSize.AnimatableData, CGSize.AnimatableData> {
        get { AnimatablePair(targetSize.animatableData, tooltipContentSize.animatableData) }
        set { (targetSize.animatableData, tooltipContentSize.animatableData) = (newValue.first, newValue.second) }
    }

    init(targetSize: CGSize, tooltipContentSize: CGSize, triangleAlignment: Alignment) {
        self.targetSize = targetSize
        self.tooltipContentSize = tooltipContentSize
        self.triangleAlignment = triangleAlignment

        triangleBounds = {
            var offset = CGPoint(x: -Self.triangleSize.width * 0.5, y: 0)
            switch triangleAlignment.vertical {
            case .bottom:
                offset.y += 0
            default:
                offset.y -= 12
            }

            switch triangleAlignment.horizontal {
            case .leading:
                offset.x += targetSize.width * 0.5
            case .trailing:
                offset.x += tooltipContentSize.width - targetSize.width * 0.5
            default:
                offset.x += 0.5 * tooltipContentSize.width
            }

            return CGRect(origin: offset, size: Self.triangleSize)
                .offsetBy(
                    dx: 0,
                    dy: triangleAlignment.vertical == .bottom ? tooltipContentSize.height : 0
                )
        }()
    }

    var triangleBounds: CGRect

    // swiftlint:disable:next function_body_length
    func path(in _: CGRect) -> Path {
        Path { path in
            let radius = Self.triangleTipRadius
            let cornerRadius = Self.backgroundCornerRadius

            // half angle of the tip
            let angle = (0.5 * CGFloat.pi) - atan(triangleBounds.width / 2 / triangleBounds.height)

            let backgroundFrameOrigin: CGPoint
            if triangleAlignment.horizontal == .leading {
                backgroundFrameOrigin = .init(
                    x: -max(
                        Self.triangleSize.width * 0.5 + Self.backgroundCornerRadius,
                        targetSize.width * 0.5
                    ) + targetSize.width * 0.5,
                    y: 0
                )
            } else {
                backgroundFrameOrigin = .init(
                    x: max(
                        Self.triangleSize.width * 0.5 + Self.backgroundCornerRadius,
                        targetSize.width * 0.5
                    ) - targetSize.width * 0.5,
                    y: 0
                )
            }

            let backgroundFrame = CGRect(origin: backgroundFrameOrigin, size: tooltipContentSize)
                .insetBy(dx: cornerRadius, dy: cornerRadius)

            if triangleAlignment.vertical == .bottom {
                // Triangle
                path.move(to: triangleBounds.topRight)
                path.addRelativeArc(
                    center: .init(
                        x: triangleBounds.midX,
                        y: triangleBounds.maxY - Self.triangleTipRadius
                    ),
                    radius: Self.triangleTipRadius,
                    startAngle: .radians(angle),
                    delta: .radians(2 * angle)
                )
                path.addLine(to: triangleBounds.topLeft)

                // Rounded Corner Frame
                path.addRelativeArc( // bottom left corner
                    center: backgroundFrame.bottomLeft,
                    radius: cornerRadius,
                    startAngle: .radians(1 / 2 * CGFloat.pi),
                    delta: .radians(1 / 2 * CGFloat.pi)
                )
                path.addRelativeArc( // top left corner
                    center: backgroundFrame.topLeft,
                    radius: cornerRadius,
                    startAngle: .radians(CGFloat.pi),
                    delta: .radians(1 / 2 * CGFloat.pi)
                )
                path.addRelativeArc( // top right corner
                    center: backgroundFrame.topRight,
                    radius: cornerRadius,
                    startAngle: .radians(-1 / 2 * CGFloat.pi),
                    delta: .radians(1 / 2 * CGFloat.pi)
                )
                path.addRelativeArc( // bottom right corner
                    center: backgroundFrame.bottomRight,
                    radius: cornerRadius,
                    startAngle: .radians(0),
                    delta: .radians(1 / 2 * CGFloat.pi)
                )

                path.closeSubpath()
            } else {
                // Triangle
                path.move(to: triangleBounds.bottomLeft)
                path.addRelativeArc(
                    center: .init(x: triangleBounds.midX, y: triangleBounds.minY + radius),
                    radius: radius,
                    startAngle: .radians(-angle - 0.5 * CGFloat.pi),
                    delta: .radians(2 * angle)
                )
                path.addLine(to: triangleBounds.bottomRight)

                // Rounded Corner Frame
                path.addRelativeArc( // top right
                    center: backgroundFrame.topRight,
                    radius: cornerRadius,
                    startAngle: .radians(-1 / 2 * CGFloat.pi),
                    delta: .radians(1 / 2 * CGFloat.pi)
                )
                path.addRelativeArc( // bottom right
                    center: backgroundFrame.bottomRight,
                    radius: cornerRadius,
                    startAngle: .radians(0),
                    delta: .radians(1 / 2 * CGFloat.pi)
                )
                path.addRelativeArc( // bottom left
                    center: backgroundFrame.bottomLeft,
                    radius: cornerRadius,
                    startAngle: .radians(1 / 2 * CGFloat.pi),
                    delta: .radians(1 / 2 * CGFloat.pi)
                )
                path.addRelativeArc( // top left
                    center: backgroundFrame.topLeft,
                    radius: cornerRadius,
                    startAngle: .radians(CGFloat.pi),
                    delta: .radians(1 / 2 * CGFloat.pi)
                )

                path.closeSubpath()
            }
        }
    }
}

extension CGRect {
    /// Calculate an `Alignment` by comparing with a reference rect. The `reference` `CGRect` should include this rect.
    func alignment(relativeTo reference: CGRect) -> Alignment {
        var center = CGPoint(
            x: origin.x + size.width * 0.5,
            y: origin.y + size.height * 0.5
        )

        center.x /= reference.size.width
        center.y /= reference.size.height

        if center.y < 0.3 { // top
            if center.x < 0.3 { // leading
                return .topLeading
            } else if center.x > 0.7 { // trailing
                return .topTrailing
            } else { // center
                return .top
            }
        } else if center.y > 0.7 { // bottom
            if center.x < 0.3 { // leading
                return .bottomLeading
            } else if center.x > 0.7 { // trailing
                return .bottomTrailing
            } else { // center
                return .bottom
            }
        } else { // center
            if center.x < 0.3 { // leading
                return .leading
            } else if center.x > 0.7 { // trailing
                return .trailing
            } else { // center
                return .center
            }
        }
    }

    var topLeft: CGPoint {
        .init(x: minX, y: minY)
    }

    var topRight: CGPoint {
        .init(x: maxX, y: minY)
    }

    var bottomRight: CGPoint {
        .init(x: maxX, y: maxY)
    }

    var bottomLeft: CGPoint {
        .init(x: minX, y: maxY)
    }
}
