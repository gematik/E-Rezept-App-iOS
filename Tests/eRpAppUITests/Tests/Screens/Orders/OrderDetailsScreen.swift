//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import eRpResources
import Nimble
import XCTest

@MainActor
struct OrderDetailsScreen: Screen {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    func tapOpenPharmacyDetails(fileID: String = #fileID, file: String = #filePath,
                                line: UInt = #line) -> PharmacyDetailsScreen {
        container(by: A11y.orderDetail.message.msgTxtTitle, fileID: fileID, file: file, line: line)
            .links
            .firstMatch
            .tap()
        return .init(app: app)
    }

    func tapBackButton(fileID: String = #fileID, file: String = #filePath,
                       line: UInt = #line) {
        button(within: app.navigationBars, by: "Nachrichten", fileID: fileID, file: file, line: line).tap()
    }

    func message(at index: Int, fileID _: String = #fileID, file _: String = #file,
                 line _: UInt = #line) -> MessageContainer {
        let container = app.otherElements.matching(.any, identifier: A11y.orderDetail.list.ordDetailTxtMsgList)
            .allElementsBoundByIndex[index]
        return MessageContainer(app: app, container: container)
    }

    @MainActor
    struct MessageContainer: Screen {
        let app: XCUIApplication
        let container: XCUIElement

        func title(fileID: String = #fileID, file: String = #file, line: UInt = #line) -> XCUIElement {
            elements(
                query: container.otherElements,
                identifier: A11y.orderDetail.message.msgTxtTitle,
                fileID: fileID,
                file: file,
                line: line,
                checkExistence: true
            ).textViews.firstMatch
        }

        func linkButton(fileID: String = #fileID, file: String = #file, line: UInt = #line) -> XCUIElement {
            elements(
                query: container.buttons,
                identifier: A11y.orderDetail.list.ordDetailBtnLink,
                fileID: fileID,
                file: file,
                line: line,
                checkExistence: false
            )
        }

        func dmcButton(fileID: String = #fileID, file: String = #file, line: UInt = #line) -> XCUIElement {
            elements(
                query: container.buttons,
                identifier: A11y.orderDetail.list.ordDetailBtnDmc,
                fileID: fileID,
                file: file,
                line: line,
                checkExistence: false
            )
        }

        func chipTexts(fileID _: String = #fileID, file _: String = #file, line _: UInt = #line) -> [XCUIElement] {
            container.staticTexts.matching(.any, identifier: A11y.orderDetail.message.msgTxtChips)
                .allElementsBoundByIndex
        }

        func tapDmcButton(fileID: String = #fileID, file: String = #file, line: UInt = #line) -> DMCScreen {
            elements(
                query: container.buttons,
                identifier: A11y.orderDetail.list.ordDetailBtnDmc,
                fileID: fileID,
                file: file,
                line: line,
                checkExistence: true
            ).tap()

            return DMCScreen(app: app)
        }
    }

    @MainActor
    struct DMCScreen: Screen {
        let app: XCUIApplication

        func humanReadableCode(fileID: String = #fileID, file: String = #file, line: UInt = #line) -> XCUIElement {
            staticText(by: A11y.orderDetail.pickupCode.pucTxtHrCode, fileID: fileID, file: file, line: line)
        }

        func tapClose(fileID: String = #fileID, file: String = #file, line: UInt = #line) {
            button(by: A11y.orderDetail.pickupCode.pucBtnClose, fileID: fileID, file: file, line: line).tap()
        }
    }
}
