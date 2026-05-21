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

import CodedError
import Combine
import Dependencies
import DependenciesMacros
import SwiftUI
import ZXingCpp

/// Handler for generating eu accessCodes
@DependencyClient
public struct EuAccessCodeGenerator {
    /// generat accessCode for eu redeem
    public var generatAccessCode: @Sendable () async throws -> String
    /// Opens a URL asynchronously
    public var generateQRCodeImage: @Sendable (String, CGSize) async throws -> UIImage
}

// MARK: - TCA Dependency

extension EuAccessCodeGenerator: DependencyKey {
    /// Live implementation using UIApplication
    public static let liveValue = EuAccessCodeGenerator(
        generatAccessCode: {
            let accessCodeCharacters: [Character] = {
                let digits = "123456789" // exclude '0'
                let lowercase = "abcdefghjkmnpqrstuvwxyz" // exclude 'i', 'l', 'o'
                let uppercase = "ABCDEFGHJKLMNPQRSTUVWXYZ" // exclude 'I', 'O'
                return Array(digits + lowercase + uppercase)
            }()

            return String((0 ..< 6).compactMap { _ in accessCodeCharacters.randomElement() })
        },
        generateQRCodeImage: { string, size in
            let padding: CGFloat = 16
            let minScreenDimension = min(size.width, size.height)
            let pixelDimension = Int(minScreenDimension - 2 * padding)
            let screenSize = CGSize(width: pixelDimension, height: pixelDimension)

            let options = ZXIWriterOptions(
                format: .QR_CODE,
                width: Int32(screenSize.width),
                height: Int32(screenSize.height),
                ecLevel: 0,
                margin: -1
            )
            guard let image = try? ZXIBarcodeWriter(options: options).write(string)
            else {
                throw EuCodeGenerationError.euCGImageConversion("Could not create a cgImage")
            }

            return await UIImage(cgImage: image.takeRetainedValue(),
                                 scale: UIScreen.main.scale,
                                 orientation: .up)
        }
    )

    public static let testValue = Self()
}

@CodedError("046")
public enum EuCodeGenerationError: Error, Equatable, LocalizedError {
    @ErrorCode("01")
    case euCGImageConversion(String)
}

extension DependencyValues {
    /// Access point for the EuAccessCodeGenerator dependency
    public var euAccessCodeGenerator: EuAccessCodeGenerator {
        get { self[EuAccessCodeGenerator.self] }
        set { self[EuAccessCodeGenerator.self] = newValue }
    }
}
