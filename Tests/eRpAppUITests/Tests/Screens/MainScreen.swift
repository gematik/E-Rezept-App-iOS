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
struct MainScreen: Screen {
    let app: XCUIApplication

    func prescriptionCellByName(_ name: String, fileID _: String = #fileID, file: String = #filePath,
                                line: UInt = #line) -> XCUIElement {
        let cell = app.buttons.containing(.staticText, identifier: name).element
        expect(file: file, line: line, cell).to(exist(name))
        return cell
    }

    func tapDetailsForPrescriptionNamed(_ name: String, fileID: String = #fileID, file: String = #filePath,
                                        line: UInt = #line) -> PrescriptionDetailsScreen<MainScreen> {
        staticText(by: name, fileID: fileID, file: file, line: line).tap()

        // assert label exists that contains the prescription name as a label
        let title = staticText(by: A11y.prescriptionDetails.prscDtlTxtTitle, fileID: fileID, file: file, line: line)
        expect(file: file, line: line, title.label).to(equal(name))

        return PrescriptionDetailsScreen(app: app, previous: self)
    }

    func tapDetailsForDiGaNamed(_ name: String, fileID: String = #fileID, file: String = #filePath,
                                line: UInt = #line) -> DiGaDetailsScreen<MainScreen> {
        staticText(by: name, fileID: fileID, file: file, line: line).tap()

        // assert label exists that contains the prescription name as a label
        let title = staticText(by: A11y.digaDetail.digaDtlTxtNameHeader, fileID: fileID, file: file, line: line)
        expect(file: file, line: line, title.label).to(equal(name))

        return DiGaDetailsScreen(app: app, previous: self)
    }

    func tapDetailsForDiGaNamed(
        _ name: String,
        _ screen: (DiGaDetailsScreen<MainScreen>) async -> Void,
        fileID: String = #fileID,
        file: String = #filePath,
        line: UInt = #line
    ) async {
        staticText(by: name, fileID: fileID, file: file, line: line).tap()

        // assert label exists that contains the prescription name as a label
        let title = staticText(by: A11y.digaDetail.digaDtlTxtNameHeader, fileID: fileID, file: file, line: line)
        expect(file: file, line: line, title.label).to(equal(name))

        let diGaDetailsScreen = DiGaDetailsScreen(app: app, previous: self)
        await screen(diGaDetailsScreen)

        diGaDetailsScreen.tapBackButton(fileID: fileID, file: file, line: line)
    }

    func tapDetailsForScannedPrescription(_ name: String, fileID: String = #fileID, file: String = #filePath,
                                          line: UInt = #line) -> PrescriptionDetailsScreen<MainScreen> {
        staticText(by: name, fileID: fileID, file: file, line: line).tap()

        // assert label exists that contains the prescription name as a label
        let title = textField(by: A11y.prescriptionDetails.prscDtlTxtTitleInput, fileID: fileID, file: file, line: line)
        if let titleValue = title.value as? String {
            expect(file: file, line: line, titleValue).to(equal(name))
        } else {
            Nimble.fail("expect to have a title in prescription detail view")
        }

        return PrescriptionDetailsScreen(app: app, previous: self)
    }

    func tapRedeem(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> RedeemSelectionScreen {
        button(by: A11y.mainScreen.erxBtnRedeemPrescriptions, fileID: fileID, file: file, line: line).tap()

        return RedeemSelectionScreen(app: app)
    }

    func swipeToRefresh(fileID _: String = #fileID, file _: String = #filePath,
                        line _: UInt = #line) {
        let from = app.scrollViews.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
        let to = app.scrollViews.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
        from.press(forDuration: 0.0, thenDragTo: to)
    }

    func tapOpenCardwall(fileID: String = #fileID, file: String = #filePath,
                         line: UInt = #line) -> CardWallIntroductionScreen {
        button(by: A11y.mainScreen.erxBtnLogin, fileID: fileID, file: file, line: line).tap()

        return .init(app: app)
    }

    func tapArchive(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) -> ArchiveScreen {
        app.scrollViews.firstMatch.swipeUp(velocity: 2000.0)

        button(by: A11y.mainScreen.erxBtnArcPrescription, fileID: fileID, file: file, line: line).tap()

        return ArchiveScreen(app: app)
    }

    func tapArchive(
        _ screen: (ArchiveScreen) async -> Void,
        fileID: String = #fileID,
        file: String = #filePath,
        line: UInt = #line
    ) async {
        app.scrollViews.firstMatch.swipeUp(velocity: 2000.0)

        button(by: A11y.mainScreen.erxBtnArcPrescription, fileID: fileID, file: file, line: line).tap()

        let archiveScreen = ArchiveScreen(app: app)
        await screen(archiveScreen)
        archiveScreen.backToMainScreen()
    }

    @MainActor
    struct ArchiveScreen: Screen {
        var app: XCUIApplication

        func prescriptionCellByName(
            _ name: String,
            fileID: String = #fileID,
            file: String = #filePath,
            line: UInt = #line
        ) -> XCUIElement {
            let cell = app.buttons.containing(.staticText, identifier: name).element
            expect(fileID: fileID, file: file, line: line, cell).to(exist(name))
            return cell
        }

        func detailsForPrescriptionNamed(_ name: String, fileID: String = #fileID, file: String = #filePath,
                                         line: UInt = #line) -> PrescriptionDetailsScreen<ArchiveScreen> {
            let segementedControlButton = button(
                by: A11y.prescriptionArchive.arcBtnSegmentedControlPrescriptions,
                fileID: fileID,
                file: file,
                line: line,
                checkExistence: false
            )
            if segementedControlButton.exists, !segementedControlButton.isSelected {
                segementedControlButton.tap()
            }

            staticText(by: name, fileID: fileID, file: file, line: line).tap()

            // assert label exists that contains the prescription name as a label
            let title = staticText(by: A11y.prescriptionDetails.prscDtlTxtTitle, fileID: fileID, file: file, line: line)
            expect(fileID: fileID, file: file, line: line, title.label).to(equal(name))

            return PrescriptionDetailsScreen(app: app, previous: self)
        }

        func detailsForDiGaNamed(_ name: String, fileID: String = #fileID, file: String = #filePath,
                                 line: UInt = #line) -> DiGaDetailsScreen<ArchiveScreen> {
            let segementedControlButton = button(
                by: A11y.prescriptionArchive.arcBtnSegmentedControlDigas,
                fileID: fileID,
                file: file,
                line: line,
                checkExistence: false
            )
            if segementedControlButton.exists, !segementedControlButton.isSelected {
                segementedControlButton.tap()
            }

            staticText(by: name, fileID: fileID, file: file, line: line).tap()

            // assert label exists that contains the prescription name as a label
            let title = staticText(by: A11y.digaDetail.digaDtlTxtNameHeader, fileID: fileID, file: file, line: line)
            expect(fileID: fileID, file: file, line: line, title.label).to(equal(name))

            return DiGaDetailsScreen(app: app, previous: self)
        }

        func detailsForDiGaNamed(
            _ name: String,
            _ screen: (DiGaDetailsScreen<ArchiveScreen>) async -> Void,
            fileID: String = #fileID,
            file: String = #filePath,
            line: UInt = #line
        ) async {
            let segementedControlButton = button(
                by: A11y.prescriptionArchive.arcBtnSegmentedControlDigas,
                fileID: fileID,
                file: file,
                line: line,
                checkExistence: false
            )
            if segementedControlButton.exists, !segementedControlButton.isSelected {
                segementedControlButton.tap()
            }

            staticText(by: name, fileID: fileID, file: file, line: line).tap()

            // assert label exists that contains the prescription name as a label
            let title = staticText(by: A11y.digaDetail.digaDtlTxtNameHeader, fileID: fileID, file: file, line: line)
            expect(fileID: fileID, file: file, line: line, title.label).to(equal(name))

            let diGaDetailsScreen = DiGaDetailsScreen(app: app, previous: self)
            await screen(diGaDetailsScreen)
            diGaDetailsScreen.tapBackButton()
        }

        func backToMainScreen(fileID: String = #fileID, file: String = #filePath, line: UInt = #line) {
            button(within: app.navigationBars, by: "Rezepte", fileID: fileID, file: file, line: line).tap()
        }
    }
}
