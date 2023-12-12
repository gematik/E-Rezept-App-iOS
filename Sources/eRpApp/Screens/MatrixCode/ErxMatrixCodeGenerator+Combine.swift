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
import eRpKit
import UIKit

extension ErxMatrixCodeGenerator {
    func publishedMatrixCode(for tasks: [ErxTask],
                             with size: CGSize)
        -> AnyPublisher<UIImage, Error> {
        matrixCodePublisher(for: tasks, with: size, scale: UIScreen.main.scale, orientation: .up)
    }

    func publishedMatrixCode(for chargeItem: ErxChargeItem,
                             with size: CGSize)
        -> AnyPublisher<UIImage, Error> {
        matrixCodePublisher(for: chargeItem, with: size, scale: UIScreen.main.scale, orientation: .up)
    }

    func matrixCodePublisher(for tasks: [ErxTask],
                             with size: CGSize,
                             scale: CGFloat,
                             orientation: UIImage.Orientation)
        -> AnyPublisher<UIImage, Error> {
        Deferred { () -> AnyPublisher<UIImage, Error> in
            do {
                let size = CGSize(width: size.width * scale, height: size.height * scale)
                let code = try matrixCode(for: tasks, with: size)
                let image = UIImage(cgImage: code, scale: scale, orientation: orientation)

                return Just(image)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } catch {
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }

    func matrixCodePublisher(
        for chargeItem: ErxChargeItem,
        with size: CGSize,
        scale: CGFloat,
        orientation: UIImage.Orientation
    ) -> AnyPublisher<UIImage, Error> {
        Deferred { () -> AnyPublisher<UIImage, Error> in
            do {
                let size = CGSize(width: size.width * scale, height: size.height * scale)
                let code = try matrixCode(for: chargeItem, with: size)
                let image = UIImage(cgImage: code, scale: scale, orientation: orientation)

                return Just(image)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } catch {
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
}
