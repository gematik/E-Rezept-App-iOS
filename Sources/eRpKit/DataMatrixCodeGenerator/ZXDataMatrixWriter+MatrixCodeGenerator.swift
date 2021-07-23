//
//  Copyright (c) 2021 gematik GmbH
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

extension ZXDataMatrixWriter: MatrixCodeGenerator {
    enum Error: Swift.Error {
        case cgImgageConvertion(String)
    }

    public func generateImage(for contents: String,
                              width: Int,
                              height: Int) throws -> CGImage {
        let matrix = try encode(contents,
                                format: ZXBarcodeFormat(rawValue: kBarcodeFormatDataMatrix.rawValue),
                                width: Int32(width),
                                height: Int32(height),
                                hints: nil)

        if let cgImage = ZXImage(matrix: matrix).cgimage {
            return cgImage
        } else {
            throw Error.cgImgageConvertion("Could not create a cgImage from the encoded matrix code")
        }
    }
}
