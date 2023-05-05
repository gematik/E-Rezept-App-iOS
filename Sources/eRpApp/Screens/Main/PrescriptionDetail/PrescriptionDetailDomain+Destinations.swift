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

extension PrescriptionDetailDomain {
    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            case medication
            case patient(PatientState)
            case practitioner(PractitionerState)
            case organization(OrganizationState)
            case accidentInfo(AccidentInfoState)
            case technicalInformations(TechnicalInformationsState)
            case alert(ErpAlertState<PrescriptionDetailDomain.Action>)
            case sharePrescription(URL)
            case directAssignmentInfo
            case substitutionInfo
            case prescriptionValidityInfo(PrescriptionValidity)
            case scannedPrescriptionInfo
            case errorInfo
            case coPaymentInfo(CoPaymentState)
            case emergencyServiceFeeInfo
        }

        enum Action: Equatable {}

        var body: some ReducerProtocol<State, Action> {
            EmptyReducer()
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
    }
}
