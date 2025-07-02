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

import ComposableArchitecture
import eRpKit
import eRpStyleKit
import Foundation
import SwiftUI

struct SelfPayerWarningView: View {
    let erxTasks: [ErxTask]

    var body: some View {
        if !erxTasks.filter({ $0.patient?.coverageType == .SEL }).isEmpty {
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: SFSymbolName.exclamationMark)
                    .foregroundColor(Colors.yellow900)
                    .font(.title3)
                    .padding(.trailing)

                VStack(alignment: .leading, spacing: 4) {
                    Text(selfPayerWarningText(erxTasks: erxTasks))
                        .font(Font.subheadline)
                        .foregroundColor(Colors.yellow900)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 12).fill(Colors.yellow100))
            .accessibilityElement(children: .combine)
            .accessibility(identifier: A18n.selfPayerWarning.selfPayerWarningTxtMessage)
            .border(Colors.yellow300, width: 0.5, cornerRadius: 12)
        }
    }

    func selfPayerWarningText(erxTasks: [ErxTask]) -> String {
        let selTasks = erxTasks.filter { $0.patient?.coverageType == .SEL }
            .map { $0.medication?.displayName ?? L10n.prscFdTxtNa.text }

        if erxTasks.count == 1, selTasks.count == 1 {
            // if we only have one selfPayer prescription, we wont display the name of the prescription
            // because we only have one prescription in total.
            return L10n.selfPayerWarningTxtMessageSingle.text
        } else {
            // if we only have one selfPayer prescription, we wont display the name of the prescription
            // because we only have one prescription in total.
            let displayText = selTasks.map { "'\($0)'" }.joined(separator: " & ")
            return L10n.selfPayerWarningTxtMessage(selTasks.count, displayText).text
        }
    }
}
