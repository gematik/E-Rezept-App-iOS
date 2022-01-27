//
//  Copyright (c) 2022 gematik GmbH
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

@testable import eRpLocalStorage
import Foundation

class MockCoreDataControllerFactory: CoreDataControllerFactory {
    var databaseUrl = URL(fileURLWithPath: "/dev/null/ErxTask.db")

    var loadCoreDataControllerError: Error?
    var loadCoreDataControllerCallsCount = 0
    var loadCoreDataControllerCalled: Bool {
        loadCoreDataControllerCallsCount > 0
    }

    var loadCoreDataControllerValue: CoreDataController!

    func loadCoreDataController() throws -> CoreDataController {
        loadCoreDataControllerCallsCount += 1
        if let error = loadCoreDataControllerError {
            throw error
        }
        return loadCoreDataControllerValue
    }
}
