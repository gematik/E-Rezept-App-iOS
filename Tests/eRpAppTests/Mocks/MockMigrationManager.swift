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

import Combine
import eRpKit
import eRpLocalStorage

class MockMigrationManager: ModelMigrating {
    init() {}

    var startModelMigrationCallsCount = 0
    var startModelMigrationCalled: Bool {
        startModelMigrationCallsCount > 0
    }

    var startModelMigrationReceivedCurrentVersion: ModelVersion?
    var startModelMigrationReceivedInvocations: [ModelVersion] = []
    var startModelMigrationReturnValue: AnyPublisher<ModelVersion, MigrationError>!
    var startModelMigrationClosure: ((ModelVersion) -> AnyPublisher<ModelVersion, MigrationError>)?

    func startModelMigration(from currentVersion: ModelVersion) -> AnyPublisher<ModelVersion, MigrationError> {
        startModelMigrationCallsCount += 1
        startModelMigrationReceivedCurrentVersion = currentVersion
        startModelMigrationReceivedInvocations.append(currentVersion)
        return startModelMigrationClosure.map { $0(currentVersion) } ?? startModelMigrationReturnValue
    }
}
