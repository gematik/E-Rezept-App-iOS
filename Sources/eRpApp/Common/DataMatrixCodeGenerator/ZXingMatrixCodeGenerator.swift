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
import eRpKit
import ZXingCpp

class ZXingMatrixCodeGenerator: MatrixCodeGenerator {
    // sourcery: CodedError = "009"
    enum Error: Swift.Error {
        // sourcery: errorCode = "01"
        case cgImageConversion(String)
    }

    func generateImage(for contents: String,
                       width: Int,
                       height: Int) throws -> CGImage {
        let options = ZXIWriterOptions(
            format: .DATA_MATRIX,
            width: Int32(width),
            height: Int32(height),
            ecLevel: 0,
            margin: -1
        )
        guard let image = try? ZXIBarcodeWriter(options: options).write(contents)
        else {
            throw Error.cgImageConversion("Could not create a cgImage from the encoded matrix code")
        }

        return image.takeRetainedValue()
    }
}
