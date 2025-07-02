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

import Combine
import eRpStyleKit
import SwiftUI
import UIKit

struct CardWallCANInputView: View {
    internal init(can: Binding<String>, completion: @escaping () -> Void) {
        self.completion = completion

        _can = can
    }

    @Binding var can: String
    let completion: () -> Void

    var body: some View {
        ZStack {
            HStack(alignment: .center, spacing: 8) {
                ForEach(Array(self.can).prefix(6), id: \.self) { digit in
                    Text(String(digit))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .frame(minWidth: 32, maxWidth: 48, minHeight: 56, maxHeight: 64)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
                ForEach(min(self.can.count, 6) ..< 6, id: \.self) { index in
                    Rectangle()
                        .fill(Colors.systemGray5)
                        .frame(minWidth: 32, maxWidth: 48, minHeight: 56, maxHeight: 64)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Colors.primary700,
                                        lineWidth: index == self.can.count ? 0.5 : 0)
                        )
                }
            }.accessibility(hidden: true)

            TextField("", text: $can.trimCAN())
                .textContentType(.oneTimeCode)
                .keyboardType(.numberPad)
                .foregroundColor(.clear)
                .tint(.clear)
                .accessibilityHint(Text(L10n.cdwTxtCanTitleHint))
                .accessibility(identifier: A11y.cardWall.canInput.cdwTxtCanInput)
        }
        .onChange(of: can) { newValue in
            can = String(newValue.prefix(6))
        }
    }

    private var title: String {
        L10n.cdwBtnCanDone.text
    }

    private var localizedAccessibility: String {
        if can.count != 6 {
            return L10n.cdwBtnCanDoneLabelError("\(can.count)").text
        }
        return L10n.cdwBtnCanDoneLabel.text
    }
}

extension Binding where Value == String {
    func trimCAN() -> Self {
        filterCharacters()
    }
}

struct CardWallCANInputView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardWallCANInputView(can: .constant("321")) {}
                .frame(width: 360, height: 200).fixedSize(horizontal: true, vertical: false)
        }
    }
}
