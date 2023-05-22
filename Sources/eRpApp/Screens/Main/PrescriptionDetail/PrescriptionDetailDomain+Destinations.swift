//
//  Copyright (c) 2023 gematik GmbH
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

import ComposableArchitecture
import eRpKit
import Foundation
import UIKit

extension PrescriptionDetailDomain {
    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = prescriptionDetail_medicationOverview
            case medicationOverview(MedicationOverviewDomain.State)
            // sourcery: AnalyticsScreen = prescriptionDetail_medication
            case medication(MedicationDomain.State)
            // sourcery: AnalyticsScreen = prescriptionDetail_patient
            case patient(PatientState)
            // sourcery: AnalyticsScreen = prescriptionDetail_practitioner
            case practitioner(PractitionerState)
            // sourcery: AnalyticsScreen = prescriptionDetail_organization
            case organization(OrganizationState)
            // sourcery: AnalyticsScreen = prescriptionDetail_accidentInfo
            case accidentInfo(AccidentInfoState)
            // sourcery: AnalyticsScreen = prescriptionDetail_technicalInfo
            case technicalInformations(TechnicalInformationsState)
            // sourcery: AnalyticsScreen = errorAlert
            case alert(ErpAlertState<PrescriptionDetailDomain.Action>)
            // sourcery: AnalyticsScreen = prescriptionDetail_sharePrescription
            case sharePrescription(ShareState)
            // sourcery: AnalyticsScreen = prescriptionDetail_directAssignmentInfo
            case directAssignmentInfo
            // sourcery: AnalyticsScreen = prescriptionDetail_substitutionInfo
            case substitutionInfo
            // sourcery: AnalyticsScreen = prescriptionDetail_prescriptionValidityInfo
            case prescriptionValidityInfo(PrescriptionValidityState)
            // sourcery: AnalyticsScreen = prescriptionDetail_scannedPrescriptionInfo
            case scannedPrescriptionInfo
            // sourcery: AnalyticsScreen = prescriptionDetail_errorInfo
            case errorInfo
            // sourcery: AnalyticsScreen = prescriptionDetail_coPaymentInfo
            case coPaymentInfo(CoPaymentState)
            // sourcery: AnalyticsScreen = prescriptionDetail_emergencyServiceFeeInfo
            case emergencyServiceFeeInfo
        }

        enum Action: Equatable {
            case medication(action: MedicationDomain.Action)
            case medicationOverview(action: MedicationOverviewDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.medication,
                action: /Action.medication
            ) {
                MedicationDomain()
            }
            Scope(
                state: /State.medicationOverview,
                action: /Action.medicationOverview
            ) {
                MedicationOverviewDomain()
            }
        }

        struct CoPaymentState: Equatable {
            let title: String
            let description: String

            init(status: ErxTask.CoPaymentStatus) {
                switch status {
                case .subjectToCharge:
                    title = L10n.prscDtlDrCoPaymentYesTitle.text
                    description = L10n.prscDtlDrCoPaymentYesDescription.text
                case .noSubjectToCharge:
                    title = L10n.prscDtlDrCoPaymentNoTitle.text
                    description = L10n.prscDtlDrCoPaymentNoDescription.text
                case .artificialInsemination:
                    title = L10n.prscDtlDrCoPaymentPartialTitle.text
                    description = L10n.prscDtlDrCoPaymentPartialDescription.text
                }
            }
        }

        struct PrescriptionValidityState: Equatable {
            let authoredOnDate: String?
            let acceptUntilDate: String?
            let expiresOnDate: String?
        }

        struct TechnicalInformationsState: Equatable {
            let taskId: String
            let accessCode: String?
        }

        struct PatientState: Equatable {
            let patient: ErxPatient
        }

        struct PractitionerState: Equatable {
            let practitioner: ErxPractitioner
        }

        struct OrganizationState: Equatable {
            let organization: ErxOrganization
        }

        struct AccidentInfoState: Equatable {
            let accidentInfo: AccidentInfo
        }

        struct ShareState: Equatable {
            let url: URL
            let dataMatrixCodeImage: UIImage?
        }
    }
}
