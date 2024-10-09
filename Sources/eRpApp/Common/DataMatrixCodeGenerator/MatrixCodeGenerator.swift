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

import Combine
import CoreImage
import Dependencies
import ZXingCpp

/// Instances of conforming type can be used to generate a matrix code
public protocol MatrixCodeGenerator {
    /// Generates a `CGImage` from the given string
    /// - Parameters:
    ///   - contents: the string used to generate a matrix code
    ///   - width: witdth of the generated image
    ///   - height: height of the generated image
    func generateImage(for contents: String,
                       width: Int,
                       height: Int) throws -> CGImage
}

struct MatrixCodeGeneratorDependency: DependencyKey {
    static let liveValue: MatrixCodeGenerator = ZXingMatrixCodeGenerator()

    static var previewValue: MatrixCodeGenerator = liveValue

    static let testValue: MatrixCodeGenerator = UnimplementedMatrixCodeGenerator()
}

extension DependencyValues {
    var matrixCodeGenerator: MatrixCodeGenerator {
        get { self[MatrixCodeGeneratorDependency.self] }
        set { self[MatrixCodeGeneratorDependency.self] = newValue }
    }
}
