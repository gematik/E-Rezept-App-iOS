//
//  Copyright (c) 2021 gematik GmbH
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
                string: "mailto:app-fehlermeldung@ti-support.de?subject=Fehlermeldung%20aus%20der%20E-Rezept%20App&body=Liebes%20Service-Team,%20ich%20habe%20eine%20Nachricht%20von%20einer%20Apotheke%20erhalten.%20Leider%20konnte%20ich%20meinem%20Nutzer%20die%20Nachricht%20aber%20nicht%20mitteilen,%20da%20ich%20sie%20nicht%20verstanden%20habe.%20Bitte%20pr%C3%BCft,%20was%20hier%20passiert%20ist,%20und%20helft%20uns.%20Vielen%20Dank!%20Die%20E-Rezept%20App%0A%0ADie%20folgenden%20Informationen%20w%C3%BCrde%20ich%20gerne%20dem%20Service-Team%20mitteilen,%20damit%20die%20Fehlersuche%20durchgef%C3%BChrt%20werden%20kann.%20Bitte%20beachten%20Sie,%20dass%20wir%20auch%20Ihre%20eMail-Adresse%20sowie%20ggf.%20Ihren%20Namen%20erfahren,%20wenn%20Sie%20ihn%20als%20Absender%20der%20eMail%20konfiguriert%20haben.%20Wenn%20Sie%20diese%20Informationen%20ganz%20oder%20teilweise%20nicht%20%C3%BCbermitteln%20m%C3%B6chten,%20l%C3%B6schen%20Sie%20diese%20bitte%20aus%20der%20eMail.%20Alle%20Daten%20werden%20von%20der%20gematik%20GmbH%20oder%20deren%20beauftragten%20Unternehmen%20nur%20zur%20Bearbeitung%20dieser%20Fehlermeldung%20gespeichert%20und%20verarbeitet.%20Die%20L%C3%B6schung%20erfolgt%20automatisiert,%20sp%C3%A4testens%20180%20Tage%20nach%20Erledigung%20des%20Tickets.%20Ihre%20eMail-Adresse%20nutzen%20wir%20ausschlie%C3%9Flich,%20um%20mit%20Ihnen%20Kontakt%20in%20Bezug%20auf%20diese%20Fehlermeldung%20aufzunehmen.%20F%C3%BCr%20Fragen%20oder%20eine%20vorzeitige%20L%C3%B6schung%20k%C3%B6nnen%20Sie%20sich%20jederzeit%20an%20den%20Datenschutzverantwortlichen%20des%20E-Rezept%20Systems%20wenden.%20Sie%20finden%20weitere%20Informationen%20in%20der%20E-Rezept%20App%20im%20Men%C3%BC%20unter%20dem%20Datenschutz-Eintrag.%0A%0Awrong%20payload%20format%0A%0AError%2040%2042%2067336%0ATestAppVersion%0A\(timestamp)%0AModel:%20\(deviceInfo.model),%0AOS:\(deviceInfo.systemName)%20\(deviceInfo.version)" // swiftlint:disable:this line_length
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
