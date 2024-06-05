// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation






extension AccidentInfoDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension AppAuthenticationBiometricPasswordDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension AppAuthenticationBiometricPasswordDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension AppAuthenticationBiometricsDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension AppAuthenticationBiometricsDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension AppAuthenticationDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension AppAuthenticationDomain.Subdomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .biometrics(action):
                action.analytics(tracker: tracker)
            case let .password(action):
                action.analytics(tracker: tracker)
            case let .biometricAndPassword(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension AppAuthenticationPasswordDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension AppDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .main(action: action):
                action.analytics(tracker: tracker)
            case let .pharmacySearch(action: action):
                action.analytics(tracker: tracker)
            case let .orders(action: action):
                action.analytics(tracker: tracker)
            case let .settings(action: action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension AppDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension AppMigrationDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension AppMigrationDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension AppSecurityDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension AppSecurityDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .appPassword(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension AppStartDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension AppStartDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .onboarding(action):
                action.analytics(tracker: tracker)
            case let .app(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension AuditEventsDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension AuditEventsDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .cardWall(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension CardWallCANDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension CardWallCANDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .pin(action):
                action.analytics(tracker: tracker)
            case let .egk(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension CardWallExtAuthConfirmationDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension CardWallExtAuthHelpDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension CardWallExtAuthSelectionDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension CardWallExtAuthSelectionDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .confirmation(action):
                action.analytics(tracker: tracker)
            case let .help(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension CardWallIntroductionDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension CardWallIntroductionDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .can(action):
                action.analytics(tracker: tracker)
            case let .extAuth(action):
                action.analytics(tracker: tracker)
            case let .egk(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension CardWallLoginOptionDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension CardWallLoginOptionDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .readCard(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension CardWallPINDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension CardWallPINDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .login(action):
                action.analytics(tracker: tracker)
            case let .egk(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension CardWallReadCardDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension CardWallReadCardDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .help(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension ChargeItemDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension ChargeItemDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .shareSheet(action):
                action.analytics(tracker: tracker)
            case let .idpCardWall(action):
                action.analytics(tracker: tracker)
            case let .alterChargeItem(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension ChargeItemListDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension ChargeItemListDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .idpCardWall(action):
                action.analytics(tracker: tracker)
            case let .chargeItem(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension CoPaymentDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension CreatePasswordDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension CreateProfileDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension CreateProfileDomain.DelegateAction {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension DeviceSecurityDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension DosageInstructionsDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension EditProfileDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension EditProfileDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .token(action):
                action.analytics(tracker: tracker)
            case let .auditEvents(action):
                action.analytics(tracker: tracker)
            case let .registeredDevices(action):
                action.analytics(tracker: tracker)
            case let .chargeItemList(action):
                action.analytics(tracker: tracker)
            case let .editProfilePicture(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension EditProfileNameDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension EditProfileNameDomain.DelegateAction {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension EditProfilePictureDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension EditProfilePictureDomain.DelegateAction {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension EditProfilePictureDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension EmptyDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension ExtAuthPendingDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension ExtAuthPendingDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension HealthCardPasswordCanDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension HealthCardPasswordCanDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .puk(action):
                action.analytics(tracker: tracker)
            case let .oldPin(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension HealthCardPasswordIntroductionDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension HealthCardPasswordIntroductionDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .can(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension HealthCardPasswordOldPinDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension HealthCardPasswordOldPinDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .pin(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension HealthCardPasswordPinDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension HealthCardPasswordPinDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .readCard(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension HealthCardPasswordPukDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension HealthCardPasswordPukDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .pin(action):
                action.analytics(tracker: tracker)
            case let .readCard(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension HealthCardPasswordReadCardDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension HealthCardPasswordReadCardDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension HorizontalProfileSelectionDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension IDPCardWallDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension IDPCardWallDomain.Subdomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .can(action):
                action.analytics(tracker: tracker)
            case let .pin(action):
                action.analytics(tracker: tracker)
            case let .readCard(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension IDPTokenDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension IngredientDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension MainDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case let .extAuthPending(action: action):
                action.analytics(tracker: tracker)
            case let .prescriptionList(action: action):
                action.analytics(tracker: tracker)
            case let .horizontalProfileSelection(action: action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension MainDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .createProfile(action):
                action.analytics(tracker: tracker)
            case let .editProfilePicture(action):
                action.analytics(tracker: tracker)
            case let .editProfileName(action):
                action.analytics(tracker: tracker)
            case let .scanner(action):
                action.analytics(tracker: tracker)
            case let .deviceSecurity(action):
                action.analytics(tracker: tracker)
            case let .cardWall(action):
                action.analytics(tracker: tracker)
            case let .prescriptionArchive(action):
                action.analytics(tracker: tracker)
            case let .prescriptionDetail(action):
                action.analytics(tracker: tracker)
            case let .redeemMethods(action):
                action.analytics(tracker: tracker)
            case let .medicationReminder(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension MatrixCodeDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension MedicationDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension MedicationDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .ingredient(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension MedicationOverviewDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension MedicationOverviewDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .medication(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension MedicationReminderListDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension MedicationReminderListDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .medicationReminder(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension MedicationReminderOneDaySummaryDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension MedicationReminderSetupDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension MedicationReminderSetupDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .repetitionDetails(action):
                action.analytics(tracker: tracker)
            case let .dosageInstructionsInfo(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension NewProfileDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension NewProfileDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .editProfilePicture(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension OnboardingDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .registerAuthentication(action: action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension OrderDetailDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension OrderDetailDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .pickupCode(action):
                action.analytics(tracker: tracker)
            case let .prescriptionDetail(action):
                action.analytics(tracker: tracker)
            case let .chargeItem(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension OrderHealthCardContactDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension OrderHealthCardDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension OrderHealthCardDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .serviceInquiry(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension OrderHealthCardInquiryDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension OrderHealthCardInquiryDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .contact(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension OrdersDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension OrdersDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .orderDetail(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension OrganizationDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension PatientDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension PharmacyContactDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension PharmacyDetailDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension PharmacyDetailDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .redeemViaAVS(action):
                action.analytics(tracker: tracker)
            case let .redeemViaErxTaskRepository(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension PharmacyPrescriptionSelectionDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension PharmacyRedeemDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension PharmacyRedeemDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .redeemSuccess(action):
                action.analytics(tracker: tracker)
            case let .contact(action):
                action.analytics(tracker: tracker)
            case let .cardWall(action):
                action.analytics(tracker: tracker)
            case let .prescriptionSelection(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension PharmacySearchClusterDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension PharmacySearchDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension PharmacySearchDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .pharmacyDetail(action):
                action.analytics(tracker: tracker)
            case let .pharmacyFilter(action):
                action.analytics(tracker: tracker)
            case let .pharmacyMapSearch(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension PharmacySearchFilterDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension PharmacySearchMapDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension PharmacySearchMapDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .pharmacy(action):
                action.analytics(tracker: tracker)
            case let .filter(action):
                action.analytics(tracker: tracker)
            case let .clusterSheet(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension PickupCodeDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension PractitionerDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension PrescriptionArchiveDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension PrescriptionArchiveDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .prescriptionDetail(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension PrescriptionDetailDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension PrescriptionDetailDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .chargeItem(action):
                action.analytics(tracker: tracker)
            case let .medicationOverview(action):
                action.analytics(tracker: tracker)
            case let .medication(action):
                action.analytics(tracker: tracker)
            case let .patient(action):
                action.analytics(tracker: tracker)
            case let .practitioner(action):
                action.analytics(tracker: tracker)
            case let .organization(action):
                action.analytics(tracker: tracker)
            case let .accidentInfo(action):
                action.analytics(tracker: tracker)
            case let .technicalInformations(action):
                action.analytics(tracker: tracker)
            case let .sharePrescription(action):
                action.analytics(tracker: tracker)
            case let .directAssignmentInfo(action):
                action.analytics(tracker: tracker)
            case let .substitutionInfo(action):
                action.analytics(tracker: tracker)
            case let .prescriptionValidityInfo(action):
                action.analytics(tracker: tracker)
            case let .scannedPrescriptionInfo(action):
                action.analytics(tracker: tracker)
            case let .errorInfo(action):
                action.analytics(tracker: tracker)
            case let .coPaymentInfo(action):
                action.analytics(tracker: tracker)
            case let .emergencyServiceFeeInfo(action):
                action.analytics(tracker: tracker)
            case let .medicationReminder(action):
                action.analytics(tracker: tracker)
            case let .dosageInstructionsInfo(action):
                action.analytics(tracker: tracker)
            case let .matrixCode(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension PrescriptionDosageInstructionsDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension PrescriptionListDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension PrescriptionValidityDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension ProfilesDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension ReadCardHelpDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension ReadCardHelpDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension RedeemMethodsDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension RedeemMethodsDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .matrixCode(action):
                action.analytics(tracker: tracker)
            case let .pharmacySearch(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension RedeemSuccessDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension RegisterAuthenticationDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension RegisteredDevicesDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension RegisteredDevicesDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .cardWallCAN(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension ScannerDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension ScannerDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension SettingsDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .profiles(action: action):
                action.analytics(tracker: tracker)
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension SettingsDomain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .healthCardPasswordForgotPin(action):
                action.analytics(tracker: tracker)
            case let .healthCardPasswordSetCustomPin(action):
                action.analytics(tracker: tracker)
            case let .healthCardPasswordUnlockCard(action):
                action.analytics(tracker: tracker)
            case let .appSecurity(action):
                action.analytics(tracker: tracker)
            case let .complyTracking(action):
                action.analytics(tracker: tracker)
            case let .legalNotice(action):
                action.analytics(tracker: tracker)
            case let .dataProtection(action):
                action.analytics(tracker: tracker)
            case let .openSourceLicence(action):
                action.analytics(tracker: tracker)
            case let .termsOfUse(action):
                action.analytics(tracker: tracker)
            case let .egk(action):
                action.analytics(tracker: tracker)
            case let .editProfile(action):
                action.analytics(tracker: tracker)
            case let .newProfile(action):
                action.analytics(tracker: tracker)
            case let .medicationReminderList(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension ShareSheetDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension SubstitutionInfoDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension TCAToast_PreviewProvider.Domain.Destination.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension TechnicalInformationsDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
