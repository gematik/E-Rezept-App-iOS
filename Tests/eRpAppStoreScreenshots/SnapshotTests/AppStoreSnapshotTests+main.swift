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

import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

extension AppStoreSnapshotTests {
    func main() -> some View {
        let state = PrescriptionListDomain.State(
            prescriptions: Prescription.Fixtures.prescriptions,
            profile: UserProfile.Dummies.profileA
        )

        return MainView(
            store: StoreOf<MainDomain>(
                initialState: MainDomain.State(
                    prescriptionListState: state,
                    horizontalProfileSelectionState: HorizontalProfileSelectionDomain
                        .State(profiles: [UserProfile.Fixtures.theo], selectedProfileId: UserProfile.Fixtures.theo.id)
                )
            ) {
                EmptyReducer()
            }
        )
    }
}

extension UserProfile {
    enum Fixtures {
        static let theo = UserProfile(
            profile: Profile(
                name: "Theo Testprofil",
                identifier: UUID(),
                created: Date(),
                insuranceId: nil,
                color: .green,
                image: .oldDoctor,
                lastAuthenticated: nil,
                erxTasks: []
            ),
            connectionStatus: .connected,
            activityIndicating: false
        )
    }
}

extension ErxTask {
    // swiftlint:disable:next type_body_length
    enum Fixtures {
        static let medication1: ErxMedication = .init(
            name: "Saflorblüten-Extrakt Pulver Peroral",
            pzn: "06876512",
            amount: .init(numerator: .init(value: "10")),
            dosageForm: "PUL",
            normSizeCode: "N1"
        )

        static let medication2: ErxMedication = .init(
            name: "Yucca filamentosa",
            pzn: "06876511",
            amount: .init(numerator: .init(value: "12")),
            dosageForm: "FDA",
            normSizeCode: "N2"
        )

        static let medication3: ErxMedication = .init(
            name: "Lebenselixir 9000",
            pzn: "06876513",
            amount: .init(numerator: .init(value: "1")),
            dosageForm: "ELI",
            normSizeCode: "KTP"
        )

        static let medication4: ErxMedication = .init(
            name: "Zimtöl",
            pzn: "06876514",
            amount: .init(numerator: .init(value: "1")),
            dosageForm: "AEO",
            normSizeCode: "KA"
        )

        static let medication5: ErxMedication = .init(
            name: "Gelitan Wundgel Zur äußerlichen Anwendung",
            pzn: "06876515",
            amount: .init(numerator: .init(value: "2")),
            dosageForm: "GEL",
            normSizeCode: "sonstiges"
        )

        static let medication6: ErxMedication = .init(
            name: "Asthmazopol Inhalator Flasche",
            pzn: "06876516",
            amount: .init(numerator: .init(value: "5")),
            dosageForm: "INH",
            normSizeCode: "N2"
        )

        static let medication7: ErxMedication = .init(
            name: "Iboprogenal 100+",
            pzn: "06876517",
            amount: .init(numerator: .init(value: "20")),
            dosageForm: "TAB",
            normSizeCode: "N3"
        )

        static let medication8: ErxMedication = .init(
            name: "Vita-Tee",
            pzn: "06876518",
            amount: .init(numerator: .init(value: "8")),
            dosageForm: "INS",
            normSizeCode: "NB"
        )

        static let erxTaskReady = erxTask1

        static let erxTaskRedeemed = erxTask10

        static let erxTaskError: ErxTask = .init(
            identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .error(.decoding(message: "error: decoding")),
            flowType: .pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            authoredOn: TestDate.createFormattedDate(.yesterday)
        )

        static let demoPatient = ErxPatient(
            name: "Ludger Königsstein",
            address: "Musterstr. 1 \n10623 Berlin",
            birthDate: "22.6.1935",
            phone: "555 1234567",
            status: "Mitglied",
            insurance: "AOK Rheinland/Hamburg",
            insuranceId: "A123456789",
            coverageType: .GKV
        )

        static let demoPractitioner = ErxPractitioner(
            lanr: "123456789",
            name: "Dr. Dr. med. Carsten van Storchhausen",
            qualification: "Allgemeinarzt/Hausarzt",
            email: "noreply@google.de",
            address: "Hinter der Bahn 2\n12345 Berlin"
        )

        static let demoOrganization = ErxOrganization(
            identifier: "987654321",
            name: "Praxis van Storchhausen",
            phone: "555 76543321",
            email: "noreply@praxisvonstorchhausen.de",
            address: "Vor der Bahn 6\n54321 Berlin"
        )

        static let demoAccidentInfo = AccidentInfo(
            type: .workAccident,
            workPlaceIdentifier: "1234567890",
            date: "9.4.2021"
        )

        static let erxTask1: ErxTask = .init(
            identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            flowType: .pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: TestDate.createFormattedDate(.today),
            expiresOn: TestDate.createFormattedDate(.tomorrow),
            acceptedUntil: TestDate.createFormattedDate(.ninetyTwoDaysAhead),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication1,
            medicationRequest: .init(
                substitutionAllowed: true,
                hasEmergencyServiceFee: true,
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask2: ErxTask = .init(
            identifier: "5390f983-1e67-11b2-8555-63bf44e44fb9",
            status: .ready,
            flowType: .pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: TestDate.createFormattedDate(.today),
            expiresOn: TestDate.createFormattedDate(.twentyEightDaysAhead),
            acceptedUntil: TestDate.createFormattedDate(.ninetyTwoDaysAhead),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication2,
            medicationRequest: .init(
                substitutionAllowed: true,
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask3: ErxTask = .init(
            identifier: "0390f983-1e67-11b2-8555-63bf44e44fb7",
            status: .ready,
            flowType: .pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: TestDate.createFormattedDate(.yesterday),
            expiresOn: TestDate.createFormattedDate(.twelveDaysAhead),
            acceptedUntil: TestDate.createFormattedDate(.ninetyTwoDaysAhead),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication3,
            medicationRequest: .init(
                hasEmergencyServiceFee: true,
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask4: ErxTask = .init(
            identifier: "1390f983-1e67-11b2-8555-63bf44e44fb6",
            status: .ready,
            flowType: .pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: TestDate.createFormattedDate(.dayBeforeYesterday),
            expiresOn: TestDate.createFormattedDate(.twentyEightDaysAhead),
            acceptedUntil: TestDate.createFormattedDate(.ninetyTwoDaysAhead),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication4,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask5: ErxTask = .init(
            identifier: "3390f983-1e67-11b2-8555-63bf44e44fb5",
            status: .ready,
            flowType: .pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: TestDate.createFormattedDate(.sixteenDaysBefore),
            expiresOn: TestDate.createFormattedDate(.yesterday),
            acceptedUntil: TestDate.createFormattedDate(.ninetyTwoDaysAhead),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication5,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask6: ErxTask = .init(
            identifier: "490f983-1e67-11b2-8555-63bf44e44fb4",
            status: .ready,
            flowType: .pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: TestDate.createFormattedDate(.thirtyDaysBefore),
            expiresOn: TestDate.createFormattedDate(.dayBeforeYesterday),
            acceptedUntil: TestDate.createFormattedDate(.ninetyTwoDaysAhead),
            author: "Praxis Dr. med. Karin Hasenbein",
            medication: medication6,
            medicationRequest: .init(
                hasEmergencyServiceFee: true,
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask7: ErxTask = .init(
            identifier: "6390f983-1e67-11b2-8555-63bf44e44fb3",
            status: .ready,
            flowType: .pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: TestDate.createFormattedDate(.sixteenDaysBefore),
            expiresOn: TestDate.createFormattedDate(.twentyEightDaysAhead),
            acceptedUntil: TestDate.createFormattedDate(.ninetyTwoDaysAhead),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication7,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask8: ErxTask = .init(
            identifier: "6390f983-1e67-11b2-8555-63bf44e44fb2",
            status: .ready,
            flowType: .pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: TestDate.createFormattedDate(.sixteenDaysBefore),
            expiresOn: TestDate.createFormattedDate(.yesterday),
            acceptedUntil: TestDate.createFormattedDate(.yesterday),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication8,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask9: ErxTask = .init(
            identifier: "6390f983-1e67-11b2-8555-63bf44e44fb1",
            status: .inProgress,
            flowType: .pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: TestDate.createFormattedDate(.sixteenDaysBefore),
            expiresOn: TestDate.createFormattedDate(.twelveDaysAhead),
            acceptedUntil: TestDate.createFormattedDate(.twelveDaysAhead),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication7,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask10: ErxTask = .init(
            identifier: "7390f983-1e67-11b2-8555-63bf44e44fc8",
            status: .completed,
            flowType: .pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: TestDate.createFormattedDate(.thirtyDaysBefore),
            expiresOn: TestDate.createFormattedDate(.yesterday),
            acceptedUntil: TestDate.createFormattedDate(.yesterday),
            redeemedOn: TestDate.createFormattedDate(.yesterday),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication1,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask11: ErxTask = .init(
            identifier: "7390f983-1e67-11b2-8955-63bf44e44fa8",
            status: .cancelled,
            flowType: .pharmacyOnly,
            accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: TestDate.createFormattedDate(.thirtyDaysBefore),
            expiresOn: TestDate.createFormattedDate(.weekBefore),
            acceptedUntil: TestDate.createFormattedDate(.weekBefore),
            redeemedOn: nil,
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication2,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask12: ErxTask = .init(
            identifier: "7390f983-1e67-11b2-8955-63bf44e44fd8",
            status: .draft,
            flowType: .pharmacyOnly,
            accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: nil,
            expiresOn: nil,
            acceptedUntil: nil,
            redeemedOn: nil,
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication3,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask13: ErxTask = .init(
            identifier: "7390f983-1e67-11b2-8955-63bf44e44fg8",
            status: .undefined(status: "on-hold"),
            flowType: .pharmacyOnly,
            accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: TestDate.createFormattedDate(.thirtyDaysBefore),
            expiresOn: TestDate.createFormattedDate(.weekBefore),
            acceptedUntil: TestDate.createFormattedDate(.weekBefore),
            redeemedOn: nil,
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication4,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTasks: [ErxTask] =
            [
                erxTask1,
                erxTask2,
                erxTask3,
                erxTask4,
                erxTask5,
                erxTask6,
                erxTask7,
                erxTask8,
                erxTask9,
                erxTask10,
                erxTask11,
                erxTask12,
                erxTask13,
            ]
    }
}

extension Prescription {
    enum Fixtures {
        static let prescriptions = ErxTask.Fixtures.erxTasks.map {
            Prescription(
                erxTask: $0,
                date: TestDate.defaultReferenceDate,
                dateFormatter: UIDateFormatter.testValue
            )
        }
    }
}
