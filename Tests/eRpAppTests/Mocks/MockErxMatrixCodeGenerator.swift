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
@testable import eRpFeatures
import eRpKit
import UIKit

// Encodes a string with a given `MatrixCodeGenerator` into an DMC image.
class MockErxMatrixCodeGenerator: ErxMatrixCodeGenerator {
    init() {
        uiImage = Asset.qrcode.image
        cgImage = uiImage.cgImage!
    }

    let uiImage: UIImage
    let cgImage: CGImage

    func matrixCode(for _: [ErxTask], with _: CGSize) throws -> CGImage {
        cgImage
    }

    func matrixCode(for _: ErxChargeItem, with _: CGSize) throws -> CGImage {
        cgImage
    }

    func matrixCodePublisher(for _: [ErxTask],
                             with _: CGSize,
                             scale _: CGFloat = UIScreen.main.scale,
                             orientation _: UIImage.Orientation = .up) -> AnyPublisher<UIImage, Error> {
        Just(uiImage).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func matrixCodePublisher(for _: ErxChargeItem,
                             with _: CGSize,
                             scale _: CGFloat = UIScreen.main.scale,
                             orientation _: UIImage.Orientation = .up) -> AnyPublisher<UIImage, Error> {
        Just(uiImage).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
