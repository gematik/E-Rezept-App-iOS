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

extension MainDomain {
    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = main_createProfile
            case createProfile(CreateProfileDomain.State)
            // sourcery: AnalyticsScreen = main_editProfilePicture
            case editProfilePicture(EditProfilePictureDomain.State)
            // sourcery: AnalyticsScreen = main_editName
            case editName(EditProfileNameDomain.State)
            // sourcery: AnalyticsScreen = main_scanner
            case scanner(ScannerDomain.State)
            // sourcery: AnalyticsScreen = main_deviceSecurity
            case deviceSecurity(DeviceSecurityDomain.State)
            // sourcery: AnalyticsScreen = cardWall
            case cardWall(CardWallIntroductionDomain.State)
            // sourcery: AnalyticsScreen = main_prescriptionArchive
            case prescriptionArchive(PrescriptionArchiveDomain.State)
            // sourcery: AnalyticsScreen = prescriptionDetail
            case prescriptionDetail(PrescriptionDetailDomain.State)
            // sourcery: AnalyticsScreen = redeem_methodSelection
            case redeem(RedeemMethodsDomain.State)
            // sourcery: AnalyticsScreen = main_medicationReminder
            case medicationReminder(MedicationReminderOneDaySummaryDomain.State)
            // sourcery: AnalyticsScreen = main_welcomeDrawer
            case welcomeDrawer
            // sourcery: AnalyticsScreen = main_consentDrawer
            case grantChargeItemConsentDrawer
            // sourcery: AnalyticsScreen = alert
            case alert(ErpAlertState<Action.Alert>)
            // sourcery: AnalyticsScreen = alert
            case toast(ToastState<Action.Toast>)
        }

        enum Action: Equatable {
            case createProfileAction(action: CreateProfileDomain.Action)
            case editProfilePictureAction(action: EditProfilePictureDomain.Action)
            case editProfileNameAction(action: EditProfileNameDomain.Action)
            case scanner(action: ScannerDomain.Action)
            case deviceSecurity(action: DeviceSecurityDomain.Action)
            case cardWall(action: CardWallIntroductionDomain.Action)
            case prescriptionArchiveAction(action: PrescriptionArchiveDomain.Action)
            case prescriptionDetailAction(action: PrescriptionDetailDomain.Action)
            case redeemMethods(action: RedeemMethodsDomain.Action)
            case medicationReminder(action: MedicationReminderOneDaySummaryDomain.Action)
            case alert(Alert)
            case toast(Toast)

            enum Alert: Equatable {
                case dismiss
                case cardWall
                case retryGrantChargeItemConsent
                case dismissGrantChargeItemConsent
                case consentServiceErrorOkay
                case consentServiceErrorAuthenticate
                case consentServiceErrorRetry
            }

            enum Toast: Equatable {
                case routeToChargeItemsList
            }
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.createProfile,
                action: /Action.createProfileAction
            ) {
                CreateProfileDomain()
            }
            Scope(
                state: /State.editProfilePicture,
                action: /Action.editProfilePictureAction
            ) {
                EditProfilePictureDomain()
            }
            Scope(
                state: /State.editName,
                action: /Action.editProfileNameAction
            ) {
                EditProfileNameDomain()
            }
            Scope(
                state: /State.scanner,
                action: /Action.scanner
            ) {
                ScannerDomain()
            }
            Scope(
                state: /State.deviceSecurity,
                action: /Action.deviceSecurity
            ) {
                DeviceSecurityDomain()
            }
            Scope(
                state: /State.cardWall,
                action: /Action.cardWall
            ) {
                CardWallIntroductionDomain()
            }
            Scope(
                state: /State.prescriptionArchive,
                action: /Action.prescriptionArchiveAction
            ) {
                PrescriptionArchiveDomain()
            }
            Scope(
                state: /State.prescriptionDetail,
                action: /Action.prescriptionDetailAction
            ) {
                PrescriptionDetailDomain()
            }
            Scope(
                state: /State.redeem,
                action: /Action.redeemMethods
            ) {
                RedeemMethodsDomain()
            }
            Scope(
                state: /State.medicationReminder,
                action: /Action.medicationReminder
            ) {
                MedicationReminderOneDaySummaryDomain()
            }
        }
    }
}
