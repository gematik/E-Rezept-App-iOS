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

import Combine
import Dependencies
import eRpKit
import UIKit
import ZXingObjC

/// This protocol abstracts the generates of visual (matrix) codes for a given set of Tasks.
public protocol ErxTaskMatrixCodeGenerator {
    /// Generates a matrix code for a given set of Tasks. Encodes all Tasks within one matrix code.
    /// - Parameters:
    ///   - tasks: Array of `ErxTask`s that should be encoded.
    ///   - size: The size of the requested image
    func matrixCode(for tasks: [ErxTask], with size: CGSize) throws -> CGImage
}

// MARK: TCA Dependency

struct ErxTaskMatrixCodeGeneratorDependency: DependencyKey {
    static let liveValue: ErxTaskMatrixCodeGenerator =
        DefaultErxTaskMatrixCodeGenerator(matrixCodeGenerator: ZXDataMatrixWriter())

    static var previewValue: ErxTaskMatrixCodeGenerator = liveValue

    static let testValue: ErxTaskMatrixCodeGenerator = UnimplementedErxTaskMatrixCodeGenerator()
}

extension DependencyValues {
    var erxTaskMatrixCodeGenerator: ErxTaskMatrixCodeGenerator {
        get { self[ErxTaskMatrixCodeGeneratorDependency.self] }
        set { self[ErxTaskMatrixCodeGeneratorDependency.self] = newValue }
    }
}
