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
import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import Nimble
import XCTest

final class MessageDomainTests: XCTestCase {
    let mockApplication = MockUIApplication()

    typealias TestStore = ComposableArchitecture.TestStore<
        MessageDomain.State,
        MessageDomain.State,
        MessageDomain.Action,
        MessageDomain.Action,
        MessageDomain.Environment
    >

    private func testStore(
        for communication: ErxTask.Communication,
        date: Date = Date(),
        deviceInfo: MessageDomain.DeviceInformations = MessageDomain.DeviceInformations(),
        version: String = "TestAppVersion"
    ) -> TestStore {
        let schedulers = Schedulers(uiScheduler: DispatchQueue.immediate.eraseToAnyScheduler())

        return TestStore(
            initialState: MessageDomain.State(communication: communication),
            reducer: MessageDomain.reducer,
            environment: MessageDomain.Environment(
                schedulers: schedulers,
                application: mockApplication,
                date: date,
                deviceInfo: deviceInfo,
                version: version
            )
        )
    }

    func testSelectingOnPremiseCommunicationMessage() {
        let store = testStore(for: communicationOnPremise)

        store.send(.didSelect) {
            $0.communication = self.communicationOnPremise
            $0.alertState = nil
            $0.pickupCodeViewState = nil
        }
        store.receive(.showPickupCode(dmcCode: "DMC-4711-and-more", hrCode: "4711")) {
            $0.communication = self.communicationOnPremise
            $0.alertState = nil
            $0.pickupCodeViewState = PickupCodeDomain.State(
                pickupCodeHR: "4711",
                pickupCodeDMC: "DMC-4711-and-more",
                dmcImage: nil
            )
        }
        store.send(.dismissPickupCodeView) {
            $0.communication = self.communicationOnPremise
            $0.pickupCodeViewState = nil
            $0.alertState = nil
        }
    }

    func testSelectingMessageWithShipmentCommunication() {
        let store = testStore(for: communicationShipment)

        store.send(.didSelect) {
            $0.communication = self.communicationShipment
            $0.alertState = nil
            $0.pickupCodeViewState = nil
        }
        let expectedUrl = URL(string: "https://www.das-e-rezept-fuer-deutschland.de")!
        store.receive(.openUrl(url: expectedUrl)) {
            $0.communication = self.communicationShipment
            $0.alertState = nil
            $0.pickupCodeViewState = nil
        }
        expect(self.mockApplication.canOpenURLCallsCount) == 1
        expect(self.mockApplication.openCallsCount) == 1
        expect(self.mockApplication.openUrlParameter) == expectedUrl
    }

    func testSelectingShipmentCommunicationWithWrongUrl() {
        let expectedUrl = URL(string: "www.invalid-url.de")!
        let store = testStore(for: communicationShipmentInvalidUrl)
        mockApplication.canOpenURLReturnValue = false

        store.send(.didSelect) {
            $0.communication = self.communicationShipmentInvalidUrl
            $0.pickupCodeViewState = nil
            $0.alertState = nil
        }
        store.receive(.openUrl(url: expectedUrl)) {
            $0.communication = self.communicationShipmentInvalidUrl
            $0.pickupCodeViewState = nil
            $0.alertState = MessageDomain.openUrlAlertState(for: expectedUrl)
        }
        expect(self.mockApplication.canOpenURLCallsCount) == 1
        expect(self.mockApplication.openCallsCount) == 0
        expect(self.mockApplication.openUrlParameter).to(beNil())
    }

    func testSelectingMessagesWithDeliveryCommunication() {
        let store = testStore(for: communicationDelivery)

        store.send(.didSelect) {
            $0.communication = self.communicationDelivery
            $0.pickupCodeViewState = nil
            $0.alertState = nil
        }
    }

    func testMessageWithWrongPayloadFormat() {
        let date = Date()
        let timestamp = date.fhirFormattedString(with: .yearMonthDayTime)
        let deviceInfo = MessageDomain.DeviceInformations(
            model: "TestModel",
            systemName: "TestSystem",
            version: "TestOSVersion"
        )
        let expectedUrl =
            URL(
                string: "mailto:app-fehlermeldung@ti-support.de?subject=Error%20message%20from%20the%20e-prescription%20app&body=Dear%20Service%20Team,%20I%20received%20a%20message%20from%20a%20pharmacy.%20Unfortunately,%20however,%20I%20could%20not%20pass%20the%20message%20on%20to%20my%20user%20because%20I%20did%20not%20understand%20it.%20Please%20check%20what%20happened%20here%20and%20help%20us.%20Thank%20you%20very%20much!%20The%20e-prescription%20app%0A%0AYou%20are%20sending%20us%20this%20information%20for%20purposes%20of%20troubleshooting.%20Please%20note%20that%20your%20email%20address%20and%20any%20name%20you%20include%20will%20also%20be%20transferred.%20If%20you%20do%20not%20wish%20to%20transfer%20this%20information%20either%20in%20full%20or%20in%20part,%20please%20remove%20it%20from%20this%20email.%20%0A%0AAll%20data%20will%20only%20be%20stored%20or%20processed%20by%20gematik%20GmbH%20or%20its%20appointed%20companies%20in%20order%20to%20deal%20with%20this%20error%20message.%20Deletion%20takes%20place%20automatically%20a%20maximum%20of%20180%20days%20after%20the%20ticket%20has%20been%20processed.%20We%20will%20use%20your%20email%20address%20exclusively%20to%20contact%20you%20regarding%20this%20error%20message.%20If%20you%20have%20any%20questions,%20or%20require%20an%20earlier%20deletion,%20you%20can%20contact%20the%20data%20protection%20representative%20responsible%20for%20the%20e-prescription%20system.%20You%20can%20find%20further%20information%20in%20the%20menu%20below%20the%20entry%20for%20data%20protection%20in%20the%20e-prescription%20app.%0A%0Awrong%20payload%20format%0A%0AFehler%2040%2042%2067336%0ATestAppVersion%0A\(timestamp)%0AModel:%20\(deviceInfo.model),%0AOS:\(deviceInfo.systemName)%20\(deviceInfo.version)" // swiftlint:disable:this line_length
            )

        let store = testStore(for: communicationWithWrongPayload, date: date, deviceInfo: deviceInfo)

        store.send(.didSelect) {
            $0.communication = self.communicationWithWrongPayload
            $0.pickupCodeViewState = nil
            $0.alertState = nil
        }
        store.receive(.openMail(message: "wrong payload format")) {
            $0.communication = self.communicationWithWrongPayload
            $0.pickupCodeViewState = nil
            $0.alertState = nil
        }
        expect(self.mockApplication.canOpenURLCallsCount) == 1
        expect(self.mockApplication.openCallsCount) == 1
        expect(self.mockApplication.openUrlParameter) == expectedUrl
    }

    let communicationOnPremise = ErxTask.Communication(
        identifier: "1",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-26T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"You can come by and pick up your drugs.\",\"pickUpCodeHR\":\"4711\",\"pickUpCodeDMC\":\"DMC-4711-and-more\" }" // swiftlint:disable:this line_length
    )

    let communicationShipment = ErxTask.Communication(
        identifier: "2",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-28T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Checkout your shimpment in the shopping cart.\",\"url\": \"https://www.das-e-rezept-fuer-deutschland.de\"}",
        // swiftlint:disable:previous line_length
        isRead: true
    )

    let communicationDelivery = ErxTask.Communication(
        identifier: "3",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-29T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"delivery\",\"info_text\": \"Your prescription is on the way. Make sure you are at home. We will not come back and bring you more drugs! Just kidding ;)\"}" // swiftlint:disable:this line_length
    )

    let communicationWithWrongPayload = ErxTask.Communication(
        identifier: "4",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-30T10:59:37.098245933+00:00",
        payloadJSON: "wrong payload format"
    )

    let communicationShipmentInvalidUrl = ErxTask.Communication(
        identifier: "2",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-28T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Checkout your shimpment in the shopping cart.\",\"url\": \"www.invalid-url.de\"}",
        // swiftlint:disable:previous line_length
        isRead: true
    )
}
