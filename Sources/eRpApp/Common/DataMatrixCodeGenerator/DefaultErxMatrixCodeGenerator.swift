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
import eRpKit
import UIKit

/// Encodes `ErxTasks` or `ErxChargeItem` with a given `MatrixCodeGenerator`.
public class DefaultErxMatrixCodeGenerator: ErxMatrixCodeGenerator {
    init(matrixCodeGenerator: MatrixCodeGenerator,
         matrixStringEncoder: DataMatrixStringEncoder = DefaultDataMatrixStringEncoder()) {
        self.matrixCodeGenerator = matrixCodeGenerator
        self.matrixStringEncoder = matrixStringEncoder
    }

    let matrixCodeGenerator: MatrixCodeGenerator
    let matrixStringEncoder: DataMatrixStringEncoder

    func matrixCode(for tasks: [ErxTask], with size: CGSize) throws -> CGImage {
        let dataMatrixTasks = tasks.compactMap { task -> Task? in
            guard let accessCode = task.accessCode else { return nil }

            return Task(id: task.identifier, accessCode: accessCode)
        }

        let jsonString = try matrixStringEncoder.stringEncode(tasks: dataMatrixTasks)
        return try matrixCodeGenerator.generateImage(for: jsonString,
                                                     width: Int(size.width),
                                                     height: Int(size.height))
    }

    private struct Task: ErxTaskMatrixCode {
        var id: String
        var accessCode: String
    }

    func matrixCode(for chargeItem: ErxChargeItem, with size: CGSize) throws -> CGImage {
        let dataMatrixChargeItem = ChargeItem(id: chargeItem.id, accessCode: chargeItem.accessCode)

        let jsonString = try matrixStringEncoder.stringEncode(chargeItem: dataMatrixChargeItem)
        return try matrixCodeGenerator.generateImage(for: jsonString,
                                                     width: Int(size.width),
                                                     height: Int(size.height))
    }

    private struct ChargeItem: ErxChargeItemMatrixCode {
        var id: String
        var accessCode: String?
    }
}
