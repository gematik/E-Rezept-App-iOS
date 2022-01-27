//
//  Copyright (c) 2022 gematik GmbH
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
import ZXingObjC

/// Encodes `ErxTasks` with a given `MatrixCodeGenerator`.
public class DefaultErxTaskMatrixCodeGenerator: ErxTaskMatrixCodeGenerator {
    public init(matrixCodeGenerator: MatrixCodeGenerator = ZXDataMatrixWriter(),
                erxTaskStringEncoder: DataMatrixStringEncoder = DefaultDataMatrixStringEncoder()) {
        self.matrixCodeGenerator = matrixCodeGenerator
        self.erxTaskStringEncoder = erxTaskStringEncoder
    }

    let matrixCodeGenerator: MatrixCodeGenerator
    let erxTaskStringEncoder: DataMatrixStringEncoder

    public func matrixCode(for tasks: [ErxTask], with size: CGSize) throws -> CGImage {
        let dataMatrixTasks = tasks.compactMap { task -> Task? in
            guard let accessCode = task.accessCode else { return nil }

            return Task(id: task.identifier, accessCode: accessCode)
        }

        let jsonString = try erxTaskStringEncoder.stringEncodeTasks(dataMatrixTasks)
        return try matrixCodeGenerator.generateImage(for: jsonString,
                                                     width: Int(size.width),
                                                     height: Int(size.height))
    }

    private struct Task: ErxTaskMatrixCode {
        var id: String // swiftlint:disable:this identifier_name
        var accessCode: String
    }
}
