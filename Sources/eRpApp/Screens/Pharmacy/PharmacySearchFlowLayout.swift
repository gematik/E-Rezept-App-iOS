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

/// A wrapping flow layout that arranges subviews horizontally and wraps to the next row
/// when the available width is exceeded. Items wider than the container are constrained
/// to fit within the available width.
struct PharmacySearchFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        let sizes = measureSubviews(subviews, containerWidth: containerWidth)
        return layoutItems(sizes: sizes, containerWidth: containerWidth).size
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        let containerWidth = bounds.width
        let sizes = measureSubviews(subviews, containerWidth: containerWidth)
        let layout = layoutItems(sizes: sizes, containerWidth: containerWidth)

        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(x: bounds.minX + layout.positions[index].x,
                            y: bounds.minY + layout.positions[index].y),
                proposal: ProposedViewSize(sizes[index])
            )
        }
    }

    // MARK: - Private helpers

    private func measureSubviews(_ subviews: Subviews, containerWidth: CGFloat) -> [CGSize] {
        subviews.map { subview -> CGSize in
            let ideal = subview.sizeThatFits(.unspecified)
            if ideal.width > containerWidth {
                return subview.sizeThatFits(ProposedViewSize(width: containerWidth, height: nil))
            }
            return ideal
        }
    }

    private func layoutItems(sizes: [CGSize], containerWidth: CGFloat)
        -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        for size in sizes {
            if currentX + size.width > containerWidth, currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
            maxWidth = max(maxWidth, currentX - spacing)
        }

        return (CGSize(width: maxWidth, height: currentY + rowHeight), positions)
    }
}
