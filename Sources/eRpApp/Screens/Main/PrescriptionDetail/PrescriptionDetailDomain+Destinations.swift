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

import ComposableArchitecture
import eRpKit
import Foundation
import UIKit

extension PrescriptionDetailDomain {
    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = chargeItemDetails
            case chargeItem(ChargeItemDomain.State)
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
            // sourcery: AnalyticsScreen = alert
            case alert(ErpAlertState<Action.Alert>)
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
            // sourcery: AnalyticsScreen = prescriptionDetail_toast
            case toast(ToastState<Action.Toast>)
            // sourcery: AnalyticsScreen = prescriptionDetail_setupMedicationSchedule
            case medicationReminder(MedicationReminderSetupDomain.State)
            // sourcery: AnalyticsScreen = prescriptionDetail_dosageInstructionsInfo
            case dosageInstructionsInfo(DosageInstructionsState)
        }

        enum Action: Equatable {
            case chargeItem(action: ChargeItemDomain.Action)
            case medication(action: MedicationDomain.Action)
            case medicationOverview(action: MedicationOverviewDomain.Action)
            case medicationReminder(action: MedicationReminderSetupDomain.Action)

            case patient(None)
            case practitioner(None)
            case organization(None)
            case accidentInfo(None)
            case technicalInformations(None)
            case sharePrescription(None)
            case directAssignmentInfo(None)
            case substitutionInfo(None)
            case prescriptionValidityInfo(None)
            case scannedPrescriptionInfo(None)
            case errorInfo(None)
            case coPaymentInfo(None)
            case emergencyServiceFeeInfo(None)
            case dosageInstructionsInfo(None)

            case alert(Alert)
            case toast(Toast)

            enum None: Equatable {}

            enum Alert: Equatable {
                case dismiss
                /// User has confirmed to delete task
                case confirmedDelete
                case openEmailClient(body: String)
                case grantConsent
                case grantConsentDeny
                case consentServiceErrorOkay
                case consentServiceErrorAuthenticate
                case consentServiceErrorRetry
            }

            enum Toast: Equatable {}
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.chargeItem,
                action: /Action.chargeItem
            ) {
                ChargeItemDomain()
            }
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

            Scope(
                state: /State.medicationReminder,
                action: /Action.medicationReminder
            ) {
                MedicationReminderSetupDomain()
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

        struct DosageInstructionsState: Equatable {
            let title: String
            let description: String

            init(dosageInstructions: String?) {
                title = L10n.prscDtlTxtDosageInstructions.text

                guard let dosageInstructions = dosageInstructions, !dosageInstructions.isEmpty else {
                    description = L10n.prscDtlTxtMissingDosageInstructions.text
                    return
                }
                let instructions = MedicationReminderParser.parseFromDosageInstructions(dosageInstructions)

                if !instructions.isEmpty {
                    var description = L10n.prscDtlTxtDosageInstructionsFormatted.text + "\n\n"
                    description += instructions.map(\.description).joined(separator: "\n")
                    self.description = description
                } else if dosageInstructions
                    .localizedCaseInsensitiveContains(ErpPrescription.Key.MedicationRequest.dosageInstructionDj) {
                    description = L10n.prscDtlTxtDosageInstructionsDf.text
                } else {
                    description = L10n.prscDtlTxtDosageInstructionsNote.text
                }
            }
        }

        struct PrescriptionValidityState: Equatable {
            let acceptBeginDisplayDate: String?
            let acceptEndDisplayDate: String?
            let expiresBeginDisplayDate: String?
            let expiresEndDisplayDate: String?
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
