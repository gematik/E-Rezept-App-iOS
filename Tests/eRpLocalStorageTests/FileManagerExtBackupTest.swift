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

import BundleKit
@testable import eRpLocalStorage
import Foundation
import Nimble
import XCTest

final class FileManagerExtBackupTest: XCTestCase {
    func testExcludeFromBackup() {
        let fileManager = FileManager.default
        let file = fileManager.temporaryDirectory.appendingPathComponent("testExcludeFromBackup.file")
        if fileManager.fileExists(atPath: file.path) {
            do {
                try fileManager.removeItem(at: file)
            } catch {
                fail("Could not delete existing file")
            }
        }
        fileManager.createFile(atPath: file.path, contents: nil, attributes: nil)

        expect(
            try file.resourceValues(forKeys: [URLResourceKey.isExcludedFromBackupKey]).isExcludedFromBackup
        ).to(beFalse())
        expect(try FileManager().excludeFileFromBackup(filePath: file).get()).to(beTrue())

        expect(
            try file.resourceValues(forKeys: [URLResourceKey.isExcludedFromBackupKey]).isExcludedFromBackup
        ).to(beTrue())
    }

    func testExcludeFromBackupNonExisting() {
        let file = URL(fileURLWithPath: "/non-existing/path.txt")
        expect(try FileManager().excludeFileFromBackup(filePath: file).get())
            .to(throwError(FileManager.ExcludeFileError.fileDoesNotExist))
    }
}
