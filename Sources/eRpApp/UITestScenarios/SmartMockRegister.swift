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

import Dependencies
import Foundation
import UIKit

class SmartMockRegister {
    private(set) var register: [SmartMock] = []

    func register(_ smartMock: SmartMock) {
        register.append(smartMock)
    }

    func save() throws {
        let fileManager = FileManager.default

        guard let baseUrl = try? fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("mocks") else {
            fatalError("failed to write mock")
        }

        // delete if already existing, if it does not exist we don't care
        _ = try? fileManager.removeItem(at: baseUrl)
        // (re-)create the directory
        try fileManager.createDirectory(at: baseUrl, withIntermediateDirectories: true)

        for smartMock in register {
            let recordedData = try smartMock.recordedData()
            let json = recordedData.jsonData
            let name = recordedData.name

            let fileName = baseUrl.appendingPathComponent("\(name).json")

            _ = try? json.write(to: fileName)
        }

        UIPasteboard.general.string = baseUrl.absoluteString
        print(baseUrl.absoluteString)
    }
}

extension SmartMockRegister: DependencyKey {
    static var liveValue = SmartMockRegister()
}

extension DependencyValues {
    var smartMockRegister: SmartMockRegister {
        get { self[SmartMockRegister.self] }
        set { self[SmartMockRegister.self] = newValue }
    }
}
