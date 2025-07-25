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
import Dependencies
import eRpKit
import UIKit
import ZXingCpp

/// This protocol abstracts the generates of visual (matrix) codes for
/// a given set of `ErxTask`s or a `ErxChargeItem`.
protocol ErxMatrixCodeGenerator {
    /// Generates a matrix code for a given set of Tasks. Encodes all Tasks within one matrix code.
    /// - Parameters:
    ///   - tasks: Array of `ErxTask`s that should be encoded.
    ///   - size: The size of the requested image
    func matrixCode(for tasks: [ErxTask], with size: CGSize) throws -> CGImage

    func matrixCodePublisher(
        for tasks: [ErxTask],
        with size: CGSize,
        scale: CGFloat,
        orientation: UIImage.Orientation
    ) -> AnyPublisher<UIImage, Error>

    /// Generates a matrix code for a given ChargeItem and encodes it into matrix code.
    /// - Parameters:
    ///   - chargeItem: `ErxChargeItem`s that should be encoded.
    ///   - size: The size of the requested image
    func matrixCode(for chargeItem: ErxChargeItem, with size: CGSize) throws -> CGImage

    func matrixCodePublisher(
        for chargeItem: ErxChargeItem,
        with size: CGSize,
        scale: CGFloat,
        orientation: UIImage.Orientation
    ) -> AnyPublisher<UIImage, Error>
}

// MARK: TCA Dependency

struct ErxMatrixCodeGeneratorDependency: DependencyKey {
    static let liveValue: ErxMatrixCodeGenerator =
        DefaultErxMatrixCodeGenerator(matrixCodeGenerator: ZXingMatrixCodeGenerator())

    static var previewValue: ErxMatrixCodeGenerator = liveValue

    static let testValue: ErxMatrixCodeGenerator = UnimplementedErxMatrixCodeGenerator()
}

extension DependencyValues {
    var erxMatrixCodeGenerator: ErxMatrixCodeGenerator {
        get { self[ErxMatrixCodeGeneratorDependency.self] }
        set { self[ErxMatrixCodeGeneratorDependency.self] = newValue }
    }
}
