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
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = chargeItemDetails
        case chargeItem(ChargeItemDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_medicationOverview
        case medicationOverview(MedicationOverviewDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_medication
        case medication(MedicationDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_patient
        case patient(PatientDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_practitioner
        case practitioner(PractitionerDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_organization
        case organization(OrganizationDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_accidentInfo
        case accidentInfo(AccidentInfoDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_technicalInfo
        case technicalInformations(TechnicalInformationsDomain)
        // sourcery: AnalyticsScreen = alert
        @ReducerCaseEphemeral
        case alert(ErpAlertState<Alert>)
        // sourcery: AnalyticsScreen = prescriptionDetail_sharePrescription
        case sharePrescription(ShareSheetDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_directAssignmentInfo
        case directAssignmentInfo(EmptyDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_substitutionInfo
        case substitutionInfo(SubstitutionInfoDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_prescriptionValidityInfo
        case prescriptionValidityInfo(PrescriptionValidityDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_scannedPrescriptionInfo
        case scannedPrescriptionInfo(EmptyDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_errorInfo
        case errorInfo(EmptyDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_coPaymentInfo
        case coPaymentInfo(CoPaymentDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_emergencyServiceFeeInfo
        case emergencyServiceFeeInfo(EmptyDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_selfPayerPrescriptionBottomSheet
        case selfPayerInfo(EmptyDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_toast
        @ReducerCaseEphemeral
        case toast(ToastState<Toast>)
        // sourcery: AnalyticsScreen = prescriptionDetail_setupMedicationSchedule
        case medicationReminder(MedicationReminderSetupDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_dosageInstructionsInfo
        case dosageInstructionsInfo(PrescriptionDosageInstructionsDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_matrixCode
        case matrixCode(MatrixCodeDomain)

        enum Alert: Equatable {
            case dismiss
            /// User has confirmed to delete task
            case confirmedDelete
            /// User has confirmed to delete task with chargeItem
            case confirmedDeleteWithChargeItem
            case openEmailClient(body: String)
            case grantConsent
            case grantConsentDeny
            case consentServiceErrorOkay
            case consentServiceErrorAuthenticate
            case consentServiceErrorRetry
        }

        enum Toast: Equatable {}

        enum Tag: Int {
            case chargeItem
            case medicationOverview
            case medication
            case patient
            case practitioner
            case organization
            case accidentInfo
            case technicalInformations
            case alert
            case sharePrescription
            case directAssignmentInfo
            case substitutionInfo
            case prescriptionValidityInfo
            case scannedPrescriptionInfo
            case errorInfo
            case coPaymentInfo
            case emergencyServiceFeeInfo
            case selfPayerInfo
            case toast
            case medicationReminder
            case dosageInstructionsInfo
            case matrixCode
        }
    }
}

@Reducer
struct CoPaymentDomain {
    @ObservableState
    struct State: Equatable {
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

    enum Action: Equatable {}

    var body: some ReducerOf<Self> { EmptyReducer() }
}

@Reducer
struct SubstitutionInfoDomain {
    @ObservableState
    struct State: Equatable {
        let title: String
        let description: String

        init(substitutionAllowed: Bool) {
            if substitutionAllowed {
                title = L10n.prscDtlDrSubstitutionInfoTitle.text
                description = L10n.prscDtlDrSubstitutionInfoDescription.text
            } else {
                title = L10n.prscDtlDrNoSubstitutionInfoTitle.text
                description = L10n.prscDtlDrNoSubstitutionInfoDescribtion.text
            }
        }
    }

    enum Action: Equatable {}

    var body: some ReducerOf<Self> { EmptyReducer() }
}

@Reducer
struct PrescriptionDosageInstructionsDomain {
    @ObservableState
    struct State: Equatable {
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

    enum Action: Equatable {}

    var body: some ReducerOf<Self> { EmptyReducer() }
}

@Reducer
struct PrescriptionValidityDomain {
    @ObservableState
    struct State: Equatable {
        let acceptBeginDisplayDate: String?
        let acceptEndDisplayDate: String?
        let expiresBeginDisplayDate: String?
        let expiresEndDisplayDate: String?
        let isMVO: Bool
    }

    enum Action: Equatable {}

    var body: some ReducerOf<Self> { EmptyReducer() }
}

@Reducer
struct TechnicalInformationsDomain {
    @ObservableState
    struct State: Equatable {
        let taskId: String
        let accessCode: String?
    }

    enum Action: Equatable {}

    var body: some ReducerOf<Self> { EmptyReducer() }
}

@Reducer
struct PatientDomain {
    @ObservableState
    struct State: Equatable {
        let patient: ErxPatient
    }

    enum Action: Equatable {}

    var body: some ReducerOf<Self> { EmptyReducer() }
}

@Reducer
struct PractitionerDomain {
    @ObservableState
    struct State: Equatable {
        let practitioner: ErxPractitioner
    }

    enum Action: Equatable {}

    var body: some ReducerOf<Self> { EmptyReducer() }
}

@Reducer
struct OrganizationDomain {
    @ObservableState
    struct State: Equatable {
        let organization: ErxOrganization
    }

    enum Action: Equatable {}

    var body: some ReducerOf<Self> { EmptyReducer() }
}

@Reducer
struct AccidentInfoDomain {
    @ObservableState
    struct State: Equatable {
        let accidentInfo: AccidentInfo
    }

    enum Action: Equatable {}

    var body: some ReducerOf<Self> { EmptyReducer() }
}
