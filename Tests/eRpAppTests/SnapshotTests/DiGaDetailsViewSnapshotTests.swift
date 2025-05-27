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

import CombineSchedulers
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

final class DiGaDetailsViewSnapshotTests: ERPSnapshotTestCase {
    func store(
        with erxTask: ErxTask,
        diGaInfo: DiGaInfo
    ) -> StoreOf<DiGaDetailDomain> {
        Store(
            initialState: .init(
                diGaTask: .init(prescription: Prescription(erxTask: erxTask, dateFormatter: UIDateFormatter.testValue)),
                diGaInfo: diGaInfo,
                bfarmDiGaDetails: Fixtures.bfArmLong
            )
        ) {
            EmptyReducer()
        }
    }

    func testDiGaDetail_OverViewView_request() {
        let store = store(with: ErxTask.Fixtures.erxTaskDeviceRequest, diGaInfo: .init(diGaState: .request))
        let sut = NavigationStack {
            DiGaDetailView(store: store)
        }
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testDiGaDetail_OverViewView_request_expired() {
        let store = store(with: Self.Fixtures.expiredErxTask(with: .ready), diGaInfo: .init(diGaState: .request))
        let sut = NavigationStack {
            DiGaDetailView(store: store)
        }
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testDiGaDetail_OverViewView_insurance() {
        let store = store(with: ErxTask.Fixtures.erxTaskDeviceRequest, diGaInfo: .init(diGaState: .insurance))
        let sut = NavigationStack {
            DiGaDetailView(store: store)
        }
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testDiGaDetail_OverViewView_download_Rejected() {
        let store = store(with: ErxTask.Fixtures.erxTaskDeviceRequestDispenseRejected,
                          diGaInfo: .init(diGaState: .download))
        let sut = NavigationStack {
            DiGaDetailView(store: store)
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testDiGaDetail_OverViewView_download() {
        let store = store(with: ErxTask.Fixtures.erxTaskDeviceRequestDispense, diGaInfo: .init(diGaState: .download))
        let sut = NavigationStack {
            DiGaDetailView(store: store)
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testDiGaDetail_OverViewView_activate() {
        let store = store(with: ErxTask.Fixtures.erxTaskDeviceRequestDispense, diGaInfo: .init(diGaState: .activate))
        let sut = NavigationStack {
            DiGaDetailView(store: store)
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testDiGaDetail_OverViewView_archive() {
        let store = store(
            with: ErxTask.Fixtures.erxTaskDeviceRequestDispense,
            diGaInfo: .init(diGaState: .archive(.completed))
        )
        let sut = NavigationStack {
            DiGaDetailView(store: store)
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testDiGaDetail_DetailsView() {
        let sut = NavigationStack {
            DiGaDetailView(store: .init(initialState:
                .init(
                    diGaTask: .init(prescription: Prescription(erxTask: ErxTask.Fixtures.erxTaskDeviceRequest,
                                                               dateFormatter: UIDateFormatter.testValue)),
                    diGaInfo: .init(diGaState: .request),
                    bfarmDiGaDetails: .init(description: "pretty long text",
                                            languages: "Deutsch, Englisch",
                                            platform: "iOS, Android",
                                            contractMedicalService: "Nein",
                                            additionalDevice: "keine Zusatzgeräte benötigt",
                                            patientCost: "0 €",
                                            producerCost: "500 €",
                                            supportUrl: "https://www.gematik.de"),
                    profile: UserProfile.Dummies.profileA,
                    selectedView: .details
                )) {
                EmptyReducer()
            })
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testDiGaDetail_DiGaValidView() {
        let store = store(with: ErxTask.Fixtures.erxTaskDeviceRequest, diGaInfo: .init(diGaState: .request))
        let sut = NavigationStack {
            DiGaValidView(store: store)
        }
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testDiGaDetail_DiGaSupportView() {
        let store = store(with: ErxTask.Fixtures.erxTaskDeviceRequest, diGaInfo: .init(diGaState: .request))
        let sut = NavigationStack {
            DiGaSupportView(store: store)
        }
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testDiGaDetail_DiGaDescriptionView() {
        let store = store(with: ErxTask.Fixtures.erxTaskDeviceRequest, diGaInfo: .init(diGaState: .request))
        let sut = NavigationStack {
            DiGaDescriptionView(store: store)
        }
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }
}

extension DiGaDetailsViewSnapshotTests {
    enum Fixtures {
        static let bfArmLong = DiGaDetailDomain.BfArMDiGaDetails(
            description: """
            Kaia Rückenschmerzen ist eine digitale Anwendung für erwachsene Patientinnen und Patienten mit
            nicht-spezifischen Rückenschmerzen. Sie vermittelt leitlinienbasierte, an das Krankheitsstadium der
            Patientin bzw. des Patienten angepasste Kerninhalte der multimodalen Therapie. Kaia Rückenschmerzen setzt
            sich aus den Therapie-Elementen Bewegung,Wissen und Entspannung zusammen. Die Inhalte basieren auf den
            Vorgaben der Nationalen VersorgungsLeitlinie (NVL) „Nicht-spezifischerKreuzschmerz". Durch die multimodale
            Therapie reduziert Kaia Rückenschmerzen wirksam die Intensität nicht-spezifischer Rückenschmerzen und
            verbessert die körperliche Aktivität sowie das Krankheitsverständnis der Patientin bzw. des Patienten.
            Kaia Rückenschmerzen berücksichtigt die individuellen Voraussetzungen der Patientin bzw. des Patienten wie
            die körperliche Leistungsfähigkeit, die Schmerzintensität und die Schmerzlokalisation und ermöglicht so
            eine auf die Patientin bzw. den Patienten individuell angepasste Therapie. In der randomisierten
            kontrollierten Studie Rise-uP mit 1237 Patientinnen und Patienten mit nicht-spezifischen Rückenschmerzen mit
            111 Ärztinnen und Ärzten in 56 Praxen in Deutschland wurde der medizinische Nutzen von Kaia Rückenschmerzen
            nachgewiesen. Die Patientinnen und Patienten der Interventionsgruppe zeigten eine signifikante und klinisch
            relevante Reduktion der Schmerzintensität. Des Weiteren zeigten sich signifikante Verbesserungen in der
            schmerzbedingten Beeinträchtigung, von Angst, Depression und Stress, der Funktionskapazität und der
            gesundheitsbezogenen Lebensqualität. Kaia Rückenschmerzen kann im Rahmen der Nachsorge, zur Überbrückung von
            Wartezeiten oder als Teil der Therapie (Therapiebegleitung) eingesetzt werden.
            """,
            supportUrl: "https://gematik.de"
        )

        static let medication8: ErxMedication = .init(
            name: "Vita-Tee",
            pzn: "06876518",
            isVaccine: true,
            amount: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "8", unit: "Beutel")
            ),
            dosageForm: "INS",
            normSizeCode: "NB",
            packaging: "Box",
            manufacturingInstructions: "Anleitung beiliegend",
            ingredients: []
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

        static func expiredErxTask(with status: ErxTask.Status) -> ErxTask {
            let referenceDate = Date(timeIntervalSinceReferenceDate: 0)
            let ninetyTwoDaysBefore = FHIRDateFormatter.liveValue
                .stringWithLongUTCTimeZone(
                    from: referenceDate.addingTimeInterval(-60 * 60 * 24 * 92)
                )
            let weekBefore = FHIRDateFormatter.liveValue
                .stringWithLongUTCTimeZone(
                    from: referenceDate.addingTimeInterval(-60 * 60 * 24 * 7)
                )
            let thirtyDaysBefore = FHIRDateFormatter.liveValue
                .stringWithLongUTCTimeZone(
                    from: referenceDate.addingTimeInterval(-60 * 60 * 24 * 30)
                )
            return .init(
                identifier: "34235f983-1e67-22c5-8955-63bf44e44fb8",
                status: status,
                flowType: .pharmacyOnly,
                accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: ninetyTwoDaysBefore,
                expiresOn: weekBefore,
                acceptedUntil: thirtyDaysBefore,
                redeemedOn: nil,
                author: "Dr. Dr. med. Carsten van Storchhausen",
                medication: medication8,
                medicationRequest: .init(
                    accidentInfo: demoAccidentInfo,
                    quantity: .init(value: "2", unit: "Packungen")
                ),
                patient: demoPatient,
                practitioner: demoPractitioner,
                organization: demoOrganization
            )
        }
    }
}
