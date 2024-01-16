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
@testable import eRpApp
import eRpKit
import UIKit
import ZXingObjC

// Encodes a string with a given `MatrixCodeGenerator` into an DMC image.
class MockErxMatrixCodeGenerator: ErxMatrixCodeGenerator {
    static let testBundleName = "qrcode"

    init() {
        uiImage = UIImage(testBundleNamed: MockErxMatrixCodeGenerator.testBundleName)!
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
