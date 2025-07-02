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
import CoreImage
import eRpKit
import UIKit

/// Instances of conforming type can be used to generate a matrix code
extension MatrixCodeGenerator {
    /// Publisher that emits when creating an image of the passed string in the passes size, scale and orientation
    /// - Parameters:
    ///   - string: The content that should be generated as matrix code image
    ///   - size:final size for the generated image
    ///   - scale: scaling factor for the image
    ///   - orientation: orientation of the image
    func matrixCodePublisher(for string: String,
                             with size: CGSize,
                             scale: CGFloat = UIScreen.main.scale,
                             orientation: UIImage.Orientation = .up) -> AnyPublisher<UIImage, Swift.Error> {
        Deferred { () -> AnyPublisher<UIImage, Swift.Error> in
            do {
                let size = CGSize(width: size.width * scale, height: size.height * scale)
                let code = try self.generateImage(for: string, width: Int(size.width), height: Int(size.height))
                let image = UIImage(cgImage: code, scale: scale, orientation: orientation)

                return Just(image)
                    .setFailureType(to: Swift.Error.self)
                    .eraseToAnyPublisher()
            } catch {
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
}
