//
//  Copyright (c) 2021 gematik GmbH
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
import UIKit

struct CardWallCANInputView: View {
    internal init(can: Binding<String>, pauseFirstResponder: Bool, completion: @escaping () -> Void) {
        self.completion = completion
        self.pauseFirstResponder = pauseFirstResponder

        _can = can
    }

    @Binding var can: String
    let completion: () -> Void
    let pauseFirstResponder: Bool

    var body: some View {
        ZStack {
            HStack(alignment: .center, spacing: 8) {
                ForEach(Array(self.can), id: \.self) { digit in
                    Text(String(digit))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .frame(minWidth: 32, maxWidth: 48, minHeight: 56, maxHeight: 64)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
                ForEach(self.can.count ..< 6, id: \.self) { index in
                    Rectangle()
                        .fill(Colors.systemGray5)
                        .frame(minWidth: 32, maxWidth: 48, minHeight: 56, maxHeight: 64)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Colors.primary600,
                                        lineWidth: index == self.can.count ? 0.5 : 0)
                        )
                }
            }.accessibility(hidden: true)

            TextField("", text: $can.trimCAN(), onEditingChanged: { _ in }, onCommit: {})
                .textFieldKeepFirstResponder(pause: pauseFirstResponder)
                .textContentType(.oneTimeCode)
                .keyboardType(.numberPad)
                .foregroundColor(.clear)
                .accentColor(.clear)
                .accessibility(label: Text("cdw_txt_can_input_label"))
                .accessibility(hint: Text("cdw_txt_can_title_hint"))
                .accessibility(identifier: A11y.cardWall.canInput.cdwTxtCanInput)
        }
    }

    private var title: String {
        NSLocalizedString("cdw_btn_can_done", comment: "Cardwall - CAN input done button")
    }

    private var localizedAccessibility: String {
        if can.count != 6 {
            let format = NSLocalizedString(
                "cdw_btn_can_done_label_error_%@",
                comment: "Cardwall - CAN input done on error accessibility label."
            )
            return String.localizedStringWithFormat(format, "\(can.count)")
        }
        return NSLocalizedString("cdw_btn_can_done_label", comment: "Cardwall - CAN input done accessibility label.")
    }
}

extension Binding where Value == String {
    func trimCAN() -> Self {
        filterCharacters().prefix(6)
    }
}

struct CardWallCANInputView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardWallCANInputView(can: .constant("321"), pauseFirstResponder: false) {}
                .frame(width: 360, height: 200).fixedSize(horizontal: true, vertical: false)
        }
    }
}
