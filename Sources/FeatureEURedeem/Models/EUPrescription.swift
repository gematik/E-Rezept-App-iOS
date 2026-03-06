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

import eRpKit
import eRpStyleKit
import Foundation

/// `EUPrescription` acts as a view model for an `ErxTask` to better fit the presentation logic
@dynamicMemberLookup
public struct EUPrescription: Equatable, Identifiable {
    public var erxTask: ErxTask

    public var id: String {
        erxTask.id
    }

    public subscript<A>(dynamicMember keyPath: KeyPath<ErxTask, A>) -> A {
        erxTask[keyPath: keyPath]
    }

    public init(
        erxTask: ErxTask
    ) {
        self.erxTask = erxTask
    }

    public var name: String {
        guard let name = erxTask.medication?.displayName
        else { return L10n.prscFdTxtNa.text }
        return name
    }

    public var irredeemableReason: String? {
        guard erxTask.source != .scanner else {
            return L10n.euredeemPrscIrredeemableReasonScanned.text
        }
        guard erxTask.flowType != .narcotic, erxTask.flowType != .narcoticForPKV else {
            return L10n.euredeemPrscIrredeemableReasonNarcotic.text
        }
        guard erxTask.medication?.profile != .freeText else {
            return L10n.euredeemPrscIrredeemableReasonFreeText.text
        }
        guard erxTask.medication?.profile != .ingredient else {
            return L10n.euredeemPrscIrredeemableReasonIngredient.text
        }
        guard erxTask.isEURedeemable != false else {
            return L10n.euredeemPrscIrredeemableReasonFlag.text
        }
        return nil
    }
}
