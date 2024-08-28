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

@testable import eRpFeatures
import Foundation
import SnapshotTesting
import TestUtils
import XCTest

final class ImageGeneratorTests: XCTestCase {
    func testGeneratingDataMatrixCodeWithCaption() {
        let matrixCodeImage = UIImage(asset: Asset.qrcode)!
        let sut = ImageGenerator.liveValue.addCaption(matrixCodeImage, "single code", "Medication Name")

        assertSnapshots(matching: sut, as: [.image])
    }
}
