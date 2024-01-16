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

@testable import eRpKit
import Nimble
import XCTest

final class CommunicationUniqueTests: XCTestCase {
    func testFilterForUniqueProperties() {
        // given
        let communications = [
            Fixtures.communicationDuplicate,
            Fixtures.communication,
            Fixtures.communicationProfile,
            Fixtures.communicationPayload,
            Fixtures.communicationUser,
            Fixtures.communicationTelematik,
            Fixtures.communicationOrderId,
            Fixtures.communicationEmptyOrderId,
        ]

        // when
        let result = communications.filterUnique()

        // then
        expect(result.count).to(equal(7))
        expect(result).to(contain(
            Fixtures.communication,
            Fixtures.communicationProfile,
            Fixtures.communicationPayload,
            Fixtures.communicationUser,
            Fixtures.communicationTelematik,
            Fixtures.communicationOrderId
        ))
    }

    func testFilterMultipleCommunicationsWithoutOrderId() {
        // given
        let communications = [
            Fixtures.communicationEmptyOrderId,
            Fixtures.communicationEmptyOrderId,
            Fixtures.communicationEmptyOrderId,
        ]

        let result = communications.filterUnique()

        expect(result.count).to(equal(3))
    }
}

enum Fixtures {
    static let communication = ErxTask.Communication(
        identifier: UUID().uuidString,
        profile: .dispReq,
        taskId: "123",
        userId: "ABC",
        telematikId: "T.XXX",
        orderId: "O.XXX",
        timestamp: "20.04.2022",
        payloadJSON: "some",
        isRead: false
    )

    static let communicationProfile = ErxTask.Communication(
        identifier: UUID().uuidString,
        profile: .reply,
        taskId: "123",
        userId: "ABC",
        telematikId: "T.XXX",
        orderId: "O.XXX",
        timestamp: "21.04.2022",
        payloadJSON: "some",
        isRead: true
    )

    static let communicationUser = ErxTask.Communication(
        identifier: UUID().uuidString,
        profile: .dispReq,
        taskId: "123",
        userId: "ABCD",
        telematikId: "T.XXX",
        orderId: "O.XXX",
        timestamp: "22.05.2022",
        payloadJSON: "some",
        isRead: false
    )

    static let communicationTelematik = ErxTask.Communication(
        identifier: UUID().uuidString,
        profile: .dispReq,
        taskId: "123",
        userId: "ABC",
        telematikId: "T.YYY",
        orderId: "O.XXX",
        timestamp: "20.06.2022",
        payloadJSON: "some",
        isRead: true
    )

    static let communicationPayload = ErxTask.Communication(
        identifier: UUID().uuidString,
        profile: .dispReq,
        taskId: "123",
        userId: "ABC",
        telematikId: "T.YYY",
        orderId: "O.XXX",
        timestamp: "20.07.2022",
        payloadJSON: "",
        isRead: false
    )

    static let communicationOrderId = ErxTask.Communication(
        identifier: UUID().uuidString,
        profile: .dispReq,
        taskId: "123",
        userId: "ABC",
        telematikId: "T.YYY",
        orderId: "O.ZZZ",
        timestamp: "20.07.2022",
        payloadJSON: "some",
        isRead: false
    )

    static let communicationEmptyOrderId = ErxTask.Communication(
        identifier: UUID().uuidString,
        profile: .dispReq,
        taskId: "123",
        userId: "ABC",
        telematikId: "T.YYY",
        orderId: nil,
        timestamp: "20.07.2022",
        payloadJSON: "",
        isRead: false
    )

    static let communicationDuplicate = ErxTask.Communication(
        identifier: UUID().uuidString,
        profile: .dispReq,
        taskId: "123",
        userId: "ABC",
        telematikId: "T.XXX",
        orderId: "O.XXX",
        timestamp: "20.09.2022",
        payloadJSON: "some",
        isRead: true
    )
}
