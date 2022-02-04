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
@testable import eRpKit
import Nimble
import TestUtils
import XCTest

final class DefaultErxTaskRepositoryTests: XCTestCase {
    func testGetPagedAuditEvents() {
        let mockLocalDataStore = MockErxLocalDataStore()
        let mockRemoteDataStore = MockErxRemoteDataStore()

        let sut = DefaultErxTaskRepository(disk: mockLocalDataStore, cloud: mockRemoteDataStore)

        mockLocalDataStore.fetchLatestTimestampForAuditEventsClosure = {
            if mockLocalDataStore.fetchLatestTimestampForAuditEventsCallsCount == 1 {
                return Just(nil)
                    .setFailureType(to: LocalStoreError.self)
                    .eraseToAnyPublisher()
            } else if mockLocalDataStore.fetchLatestTimestampForAuditEventsCallsCount == 2 {
                return Just(Fixtures.auditEventPageA.last?.timestamp)
                    .setFailureType(to: LocalStoreError.self)
                    .eraseToAnyPublisher()
            } else if mockLocalDataStore.fetchLatestTimestampForAuditEventsCallsCount == 3 {
                return Just(Fixtures.auditEventPageB.last?.timestamp)
                    .setFailureType(to: LocalStoreError.self)
                    .eraseToAnyPublisher()
            } else if mockLocalDataStore.fetchLatestTimestampForAuditEventsCallsCount == 4 {
                return Just(Fixtures.auditEventPageC.last?.timestamp)
                    .setFailureType(to: LocalStoreError.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: LocalStoreError.notImplemented).eraseToAnyPublisher()
            }
        }

        mockRemoteDataStore.listAllAuditEventsAfterForClosure = { timestamp, _ in
            if timestamp == nil {
                return Just(Fixtures.auditEventPageA).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
            } else if timestamp == Fixtures.auditEventPageA.last?.timestamp {
                return Just(Fixtures.auditEventPageB).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
            } else if timestamp == Fixtures.auditEventPageB.last?.timestamp {
                return Just(Fixtures.auditEventPageC).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
            } else {
                return Fail(error: RemoteStoreError.notImplemented).eraseToAnyPublisher()
            }
        }

        mockLocalDataStore.saveAuditEventsReturnValue = Just(true).setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        sut.loadRemoteLatestAuditEvents(for: nil)
            .first()
            .test(failure: { _ in
            }, expectations: { result in
                expect(result).to(beTrue())
            })

        expect(mockLocalDataStore.saveAuditEventsCallsCount).to(equal(3))
        expect(mockLocalDataStore.saveAuditEventsReceivedInvocations).to(equal([Fixtures.auditEventPageA,
                                                                                Fixtures.auditEventPageB,
                                                                                Fixtures.auditEventPageC]))
    }
}

extension DefaultErxTaskRepositoryTests {
    enum Fixtures {
        static let auditEventPageA: [ErxAuditEvent] = {
            let range = 0 ... 49
            return range.map { index in
                ErxAuditEvent(
                    identifier: "auditEvent\(1 + index)",
                    timestamp: String(format: "2021-01-21T00:%02d:00Z", index)
                )
            }
        }()

        static let auditEventPageB: [ErxAuditEvent] = {
            let range = 0 ... 49
            return range.map { index in
                ErxAuditEvent(
                    identifier: "auditEvent\(51 + index)",
                    timestamp: String(format: "2021-01-22T00:%02d:00Z", index)
                )
            }
        }()

        static let auditEventPageC: [ErxAuditEvent] = {
            let range = 0 ... 4
            return range.map { index in
                ErxAuditEvent(
                    identifier: "auditEvent\(101 + index)",
                    timestamp: String(format: "2021-01-23T00:%02d:00Z", index)
                )
            }
        }()
    }
}
