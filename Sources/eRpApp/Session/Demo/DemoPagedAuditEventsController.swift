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
import Foundation

class DemoPagedAuditEventsController: PagedAuditEventsController {
    func getPageContainer() -> PageContainer? {
        PageContainer(forNumberOfElements: 121, pageSize: 25)
    }

    func getPage(_ page: Page) -> AnyPublisher<[ErxAuditEvent], LocalStoreError> {
        let range = 0 ... 24
        let events = range.map { dummyAuditEvent(number: page.offset + $0) }

        return Just(events)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
    }

    func dummyAuditEvent(number: Int) -> ErxAuditEvent {
        ErxAuditEvent(
            identifier: UUID().uuidString,
            locale: nil,
            text: "Demo Audit Event \(number)",
            timestamp: FHIRDateFormatter.shared.string(from: Date().addingTimeInterval(Double(-1 * number * 60 * 60))),
            taskId: nil,
            title: number % 2 == 0 ? "Ibuprofen" : nil
        )
    }
}
