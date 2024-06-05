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
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import IDP
import Nimble
import XCTest

@MainActor
final class AuditEventsDomainTests: XCTestCase {
    let mockAuditEventsService = MockAuditEventsService()
    let fhirDateFormatter = FHIRDateFormatter.shared
    let uiDateFormatter = UIDateFormatter(fhirDateFormatter: FHIRDateFormatter.shared)

    typealias TestStore = TestStoreOf<AuditEventsDomain>

    func testStore() -> TestStore {
        testStore(for: AuditEventsDomain.Dummies.state)
    }

    func testStore(for state: AuditEventsDomain.State) -> TestStore {
        TestStore(initialState: state) {
            AuditEventsDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = Schedulers(uiScheduler: DispatchQueue.immediate.eraseToAnyScheduler())
            dependencies.fhirDateFormatter = fhirDateFormatter
            dependencies.uiDateFormatter = uiDateFormatter
            dependencies.auditEventsService = mockAuditEventsService
            dependencies.serviceLocator = ServiceLocator()
        }
    }

    func testLoadingEmptyAuditEventList() async {
        let sut = testStore()
        let expectedResponse = PagedContent(content: [ErxAuditEvent](), next: nil)
        mockAuditEventsService.loadAuditEventsForLocaleReturnValue = Just(expectedResponse)
            .setFailureType(to: AuditEventsServiceError.self).eraseToAnyPublisher()

        await sut.send(.task)
        await sut.receive(.response(.taskReceived(.success(expectedResponse)))) {
            $0.entries = []
        }
    }

    func testLoadingAuditEventWhenNotLoggedIn() async {
        let sut = testStore()
        let expectedResponse = AuditEventsServiceError.missingAuthentication
        mockAuditEventsService.loadAuditEventsForLocaleReturnValue = Fail(error: expectedResponse).eraseToAnyPublisher()

        await sut.send(.task)
        await sut.receive(.response(.taskReceived(.failure(expectedResponse)))) {
            $0.entries = []
            $0.needsAuthentication = true
        }
    }

    func testLoadingAuditEventsAfterCardWallCloses() async {
        let profileUUID = UUID()
        let sut = testStore(for: AuditEventsDomain.State(
            profileUUID: profileUUID,
            destination: .cardWall(.init(isNFCReady: true, profileId: profileUUID))
        ))

        // emulate login and close card wall
        let expectedResponse = PagedContent(content: ErxAuditEvent.Fixtures.auditEvents, next: nil)
        mockAuditEventsService.loadAuditEventsForLocaleReturnValue = Just(expectedResponse)
            .setFailureType(to: AuditEventsServiceError.self).eraseToAnyPublisher()
        await sut.send(.destination(.presented(.cardWall(.delegate(.close))))) {
            $0.destination = nil
        }
        await sut.receive(.task)
        await sut.receive(.response(.taskReceived(.success(expectedResponse)))) { state in
            state.entries = IdentifiedArrayOf(
                uniqueElements: expectedResponse.content.asAuditEventStates(
                    dateFormatter: self.uiDateFormatter.compactDateAndTimeFormatter,
                    fhirDateFormatter: self.fhirDateFormatter
                )
            )
        }
    }

    func testLoadingFirstAuditEventsAndNextPage() async {
        let sut = testStore()

        // emulate login and close card wall
        let firstResponse = PagedContent(
            content: ErxAuditEvent.Fixtures.auditEvents,
            next: URL(string: "https://next.link")
        )
        mockAuditEventsService.loadAuditEventsForLocaleReturnValue = Just(firstResponse)
            .setFailureType(to: AuditEventsServiceError.self).eraseToAnyPublisher()
        let secondPageResponse = PagedContent(
            content: [ErxAuditEvent(identifier: "105",
                                    locale: "de",
                                    text: "einer geht noch",
                                    timestamp: "2021-04-11T12:45:34.123473321+00:00",
                                    taskId: "7390f983-1e67-11b2-8555-63bf44e43fb8")], next: nil
        )
        mockAuditEventsService.loadNextAuditEventsForUrlLocaleReturnValue = Just(secondPageResponse)
            .setFailureType(to: AuditEventsServiceError.self).eraseToAnyPublisher()

        await sut.send(.task)
        await sut.receive(.response(.taskReceived(.success(firstResponse)))) { state in
            state.entries = IdentifiedArrayOf(
                uniqueElements: firstResponse.content.asAuditEventStates(
                    dateFormatter: self.uiDateFormatter.compactDateAndTimeFormatter,
                    fhirDateFormatter: self.fhirDateFormatter
                )
            )
            state.nextPageUrl = URL(string: "https://next.link")
        }

        await sut.send(.loadNextPage)
        await sut.receive(.response(.loadNextPageReceived(.success(secondPageResponse)))) {
            let nextAuditEvents = IdentifiedArrayOf(
                uniqueElements: secondPageResponse.content.asAuditEventStates(
                    dateFormatter: self.uiDateFormatter.compactDateAndTimeFormatter,
                    fhirDateFormatter: self.fhirDateFormatter
                )
            )
            $0.entries = $0.entries! + nextAuditEvents
            $0.nextPageUrl = nil
        }
    }
}
