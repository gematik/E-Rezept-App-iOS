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

import ComposableArchitecture
import eRpKit
import eRpStyleKit
import Foundation
import Perception
import SwiftUI
import UIKit

struct OrderMessageView: View {
    let store: StoreOf<OrderDetailDomain>
    let timelineEntry: TimelineEntry
    var style: Indicator.Style = .middle
    @State var calculatedHeight = CGFloat(1)
    @Dependency(\.uiDateFormatter) var uiDateFormatter: UIDateFormatter

    var body: some View {
        HStack {
            Indicator(style: style)
                .frame(maxHeight: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                let timestamp = uiDateFormatter.relativeDateAndTime(timelineEntry.lastUpdated) ?? timelineEntry
                    .lastUpdated
                Text(timestamp)
                    .font(Font.subheadline)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Colors.systemLabel)
                    .padding(.horizontal)

                if !timelineEntry.chipTexts.isEmpty {
                    RowStack {
                        ForEach(timelineEntry.chipTexts, id: \.self) { chipText in
                            Text(chipText)
                                .font(Font.caption)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(Colors.systemLabel)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Colors.primary100)
                                .cornerRadius(16)
                        }
                    }.accessibility(identifier: A11y.orderDetail.message.msgTxtChips)
                        .padding(.horizontal)
                }

                UIKitTextView(attributedString: timelineEntry.formattedText,
                              calculatedHeight: $calculatedHeight) { url in
                    switch timelineEntry {
                    case .dispReq:
                        if let action = timelineEntry.actions.first?.action {
                            store.send(action)
                        }
                    case .reply:
                        store.send(.openPhoneAppWith(url: url))
                    case .chargeItem,
                         .internalCommunication:
                        // cases have no custom URLs
                        store.send(.openUrl(url: url))
                    }
                }
                .frame(height: calculatedHeight)
                .contextMenu(ContextMenu {
                    Button(L10n.orderTxtCopyToClipboard) {
                        UIPasteboard.general.string = timelineEntry.text
                    }
                })
                .accessibilityElement(children: .contain)
                .accessibility(identifier: A11y.orderDetail.message.msgTxtTitle)
                .padding(.horizontal)

                if case .dispReq = timelineEntry {
                    // ignore action here since it's used as inline text link
                } else {
                    ForEach(timelineEntry.actions) { timelineEntry in
                        Button {
                            store.send(timelineEntry.action)
                        } label: {
                            HStack(spacing: 4) {
                                Text(timelineEntry.name)
                                    .font(Font.subheadline)
                                Image(systemName: SFSymbolName.chevronRight)
                                    .font(Font.subheadline.weight(.semibold))
                            }
                            .padding(.top)
                            .padding(.horizontal)
                            .foregroundColor(Colors.primary700)
                        }
                        .accessibilityIdentifier(timelineEntry.accessibilityIdentifier)
                    }
                }

                if ![.last, .single].contains(style) {
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 0)
                        .padding(.top, 40)
                        .padding(.leading)
                        .padding(.bottom)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal)
    }

    struct Indicator: View {
        let offsetY = -15.0
        let style: Indicator.Style

        var body: some View {
            ZStack(alignment: .top) {
                switch style {
                case .single:
                    VLine(style: .topSmall)
                        .stroke(style: StrokeStyle(lineWidth: 2))
                        .foregroundColor(Colors.systemGray5)
                        .frame(width: 1)
                        .offset(x: 0.5, y: offsetY)
                case .first:
                    VLine(style: .full)
                        .stroke(style: StrokeStyle(lineWidth: 2))
                        .foregroundColor(Colors.systemGray5)
                        .frame(width: 1)
                        .offset(x: 0.5, y: offsetY)
                case .middle:
                    VLine(style: .full)
                        .stroke(style: StrokeStyle(lineWidth: 2))
                        .foregroundColor(Colors.systemGray5)
                        .frame(width: 1)
                        .offset(x: 0.5, y: offsetY)
                case .last:
                    VLine(style: .topSmall)
                        .stroke(style: StrokeStyle(lineWidth: 2))
                        .foregroundColor(Colors.systemGray5)
                        .frame(width: 1)
                        .offset(x: 0.5, y: offsetY)
                }

                Circle()
                    .strokeBorder(Colors.systemGray5, lineWidth: 5)
                    .background(Colors.systemBackground)
                    .frame(width: 16, height: 16)
            }
        }

        enum Style {
            case single
            case first
            case middle
            case last
        }

        struct VLine: Shape {
            let style: VLine.Style

            func path(in rect: CGRect) -> Path {
                var path = Path()
                let startY = rect.minY
                var endY = rect.maxY
                switch style {
                case .full:
                    break
                case .topSmall:
                    endY = rect.minY + 15
                }
                path.move(to: CGPoint(x: rect.minX, y: startY))
                path.addLine(to: CGPoint(x: rect.minX, y: endY))
                return path
            }

            enum Style {
                case full
                case topSmall
            }
        }
    }

    /// A custom layout that arranges subview in a row-like pattern
    /// wrapping to a new row when the elements exceed the available width.
    struct RowStack: Layout {
        let horizontalPadding: CGFloat = 4
        let verticalPadding: CGFloat = 4

        // Calculate the total size needed
        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout Void) -> CGSize {
            var currentRowWidth: CGFloat = 0
            var currentRowHeight: CGFloat = 0
            var totalHeight: CGFloat = 0
            let maxWidth = proposal.width ?? .infinity

            for subview in subviews {
                // get the size of current subview
                let size = subview.sizeThatFits(.unspecified)
                let elementWidth = size.width + horizontalPadding
                let elementHeight = size.height

                // Check if new elements is exceeding maxWidth
                if currentRowWidth + elementWidth > maxWidth {
                    // "create" a new row
                    currentRowWidth = 0
                    totalHeight += currentRowHeight + verticalPadding
                    currentRowHeight = 0
                }

                currentRowWidth += elementWidth
                // store height of the tallest element
                currentRowHeight = max(currentRowHeight, elementHeight)
            }
            totalHeight += currentRowHeight
            return CGSize(width: currentRowWidth, height: totalHeight)
        }

        // Places the subviews
        func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout Void) {
            // values based on the boundary
            var currentRowWidth: CGFloat = bounds.minX
            var currentRowHeight: CGFloat = bounds.minY
            var totalHeight: CGFloat = 0
            let maxWidth = bounds.maxX

            for subview in subviews {
                // get the size of current subview
                let size = subview.sizeThatFits(.unspecified)
                let elementWidth = size.width + horizontalPadding
                let elementHeight = size.height

                // Check if new elements is exceeding maxWidth
                if currentRowWidth + elementWidth > maxWidth {
                    // "create" a new row
                    currentRowWidth = bounds.minX
                    currentRowHeight += totalHeight + verticalPadding
                    totalHeight = 0
                }

                subview.place(at: CGPoint(x: currentRowWidth, y: currentRowHeight), proposal: ProposedViewSize(size))
                // modify x-value for new insert position
                currentRowWidth += elementWidth
                // store height of the tallest element
                totalHeight = max(totalHeight, elementHeight)
            }
        }
    }
}

struct OrderMessageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            OrderMessageView(
                store: OrderDetailDomain.Dummies.store,
                timelineEntry: TimelineEntry.internalCommunication(
                    InternalCommunication.Message(
                        id: "12431234",
                        timestamp: Date(),
                        text: "Some change log text and explanations 1.27.0",
                        version: "1.27.0"
                    )
                ),
                style: .first
            )

            OrderMessageView(
                store: OrderDetailDomain.Dummies.store,
                timelineEntry: .reply(
                    ErxTask.Communication.Unique(
                        identifier: "4",
                        profile: .reply,
                        taskIds: ["taskID"],
                        insuranceId: "userID",
                        telematikId: "telematikID",
                        timestamp: "2021-05-29T10:59:37.098245933+00:00",
                        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"delivery\",\"info_text\": \"Your prescription is on the way. Make sure you are at home. We will not come back and bring you more drugs! Just kidding ;)\", \"url\":\"https://www.tree.fm/forest/33\"}" // swiftlint:disable:this line_length
                    ),
                    chipTexts: []
                )
            )

            OrderMessageView(
                store: OrderDetailDomain.Dummies.store,
                timelineEntry: .reply(
                    ErxTask.Communication.Unique(
                        identifier: "3",
                        profile: .reply,
                        taskIds: ["taskID"],
                        insuranceId: "userID",
                        telematikId: "telematikID",
                        timestamp: "2021-05-29T10:59:37.098245933+00:00",
                        payloadJSON: "{\"version\":\"1\" , \"supplyOptionsType\":\"onPremise\" , \"info_text\":\"01 Info/Para + HRcode/Para + DMC/Para + URL/Para\" , \"pickUpCodeHR\":\"T01__R01\" , \"pickUpCodeDMC\":\"Test_01___Rezept_01___abcdefg12345\" }" // swiftlint:disable:this line_length
                    ), chipTexts: []
                )
            )

            OrderMessageView(
                store: OrderDetailDomain.Dummies.store,
                timelineEntry: .reply(
                    ErxTask.Communication.Unique(
                        identifier: "2",
                        profile: .reply,
                        taskIds: ["taskID"],
                        insuranceId: "userID",
                        telematikId: "telematikID",
                        timestamp: "2021-05-29T10:59:37.098245933+00:00",
                        payloadJSON: "{\"version\":\"1\" , \"supplyOptionsType\":\"shipment\" , \"info_text\":\"10 Info/Para + HRcode/Para + DMC/Para + URL/Para\" , \"pickUpCodeHR\":\"T10__R03\" , \"pickUpCodeDMC\":\"Test_10___Rezept_03___abcdefg12345\" , \"url\":\"https://www.tree.fm/forest/33\"}" // swiftlint:disable:this line_length
                    ), chipTexts: []
                )
            )

            OrderMessageView(
                store: OrderDetailDomain.Dummies.store,
                timelineEntry: .reply(
                    ErxTask.Communication.Unique(
                        identifier: "2",
                        profile: .reply,
                        taskIds: ["taskID"],
                        insuranceId: "userID",
                        telematikId: "telematikID",
                        timestamp: "2021-05-29T10:59:37.098245933+00:00",
                        payloadJSON: "not a json"
                    ), chipTexts: []
                )
            )

            OrderMessageView(
                store: OrderDetailDomain.Dummies.store,
                timelineEntry: .dispReq(
                    ErxTask.Communication.Unique(
                        identifier: "1",
                        profile: .dispReq,
                        taskIds: ["taskID"],
                        insuranceId: "userID",
                        telematikId: "telematikID",
                        timestamp: "2021-05-29T09:59:37.098245933+00:00",
                        payloadJSON: ""
                    ),
                    pharmacy: nil,
                    chipTexts: []
                ),
                style: .single
            )

            OrderMessageView(
                store: OrderDetailDomain.Dummies.store,
                timelineEntry: .chargeItem(ErxChargeItem(identifier: "charge_item_id",
                                                         fhirData: Data()))
            )
        }
    }
}

struct UIKitTextView: UIViewRepresentable {
    private var attributedString: NSMutableAttributedString
    @Binding private var calculatedHeight: CGFloat
    var onLinkTap: (URL) -> Void

    init(attributedString: AttributedString, calculatedHeight: Binding<CGFloat>, onLinkTap: @escaping (URL) -> Void) {
        _calculatedHeight = calculatedHeight
        let result = NSMutableAttributedString(attributedString)
        result.addAttribute(.font,
                            value: UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .regular),
                            range: NSRange(location: 0, length: result.length))
        result.addAttribute(.foregroundColor,
                            value: UIColor.label,
                            range: NSRange(location: 0, length: result.length))
        self.attributedString = result
        self.onLinkTap = onLinkTap
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.isScrollEnabled = false
        textView.delegate = context.coordinator
        textView.attributedText = attributedString
        textView.isEditable = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.anchorPoint = .zero
        return textView
    }

    func updateUIView(_ uiView: UITextView, context _: Context) {
        let newSize = uiView.sizeThatFits(CGSize(width: uiView.frame.width,
                                                 height: .greatestFiniteMagnitude))

        guard calculatedHeight != newSize.height else { return }

        DispatchQueue.main.async { $calculatedHeight.wrappedValue = newSize.height }
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: UIKitTextView

        init(parent: UIKitTextView) {
            self.parent = parent
        }

        func textView(_: UITextView, shouldInteractWith URL: URL, in _: NSRange,
                      interaction _: UITextItemInteraction) -> Bool {
            if URL.absoluteString.hasPrefix("https://") {
                // return true when normal https link
                return true
            } else {
                // handle custom link
                parent.onLinkTap(URL)
                return false
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}
