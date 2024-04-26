// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation






extension AppAuthenticationBiometricPasswordDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension AppAuthenticationBiometricsDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension AppAuthenticationDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .biometrics(action: action):
                action.analytics(tracker: tracker)
            case let .password(action: action):
                action.analytics(tracker: tracker)
            case let .biometricAndPassword(action: action):
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
extension AppMigrationDomain.Destinations.Action {
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
extension AppSecurityDomain.Destinations.Action {
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
            case let .app(action):
                action.analytics(tracker: tracker)
            case let .onboarding(action):
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
extension AuditEventsDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .cardWall(action: action):
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
extension CardWallCANDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .pinAction(action: action):
                action.analytics(tracker: tracker)
            case let .egkAction(action: action):
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
extension CardWallExtAuthSelectionDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension CardWallExtAuthSelectionDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .egkAction(action: action):
                action.analytics(tracker: tracker)
            case let .confirmation(action: action):
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
extension CardWallIntroductionDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .canAction(action: action):
                action.analytics(tracker: tracker)
            case let .extauth(action: action):
                action.analytics(tracker: tracker)
            case let .egkAction(action: action):
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
extension CardWallLoginOptionDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .readcardAction(action: action):
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
extension CardWallPINDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .login(action: action):
                action.analytics(tracker: tracker)
            case let .egkAction(action: action):
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
extension CardWallReadCardDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .egkAction(action: action):
                action.analytics(tracker: tracker)
            case let .confirmation(action: action):
                action.analytics(tracker: tracker)
            case let .help(action: action):
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
extension ChargeItemDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .idpCardWallAction(action):
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
extension ChargeItemListDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .idpCardWallAction(action):
                action.analytics(tracker: tracker)
            case let .chargeItem(action: action):
                action.analytics(tracker: tracker)
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
extension EditProfileDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension EditProfileDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .auditEventsAction(action):
                action.analytics(tracker: tracker)
            case let .registeredDevicesAction(action):
                action.analytics(tracker: tracker)
            case let .chargeItemListAction(action):
                action.analytics(tracker: tracker)
            case let .editProfilePictureAction(action: action):
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
extension EditProfilePictureDomain.Destinations.Action {
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
extension HealthCardPasswordDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension HealthCardPasswordDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .readCard(action: action):
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
extension HealthCardPasswordReadCardDomain.Destinations.Action {
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
            case let .canAction(action: action):
                action.analytics(tracker: tracker)
            case let .pinAction(action: action):
                action.analytics(tracker: tracker)
            case let .readCard(action: action):
                action.analytics(tracker: tracker)
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
            case let .createProfileAction(action: action):
                action.analytics(tracker: tracker)
            case let .editProfilePictureAction(action: action):
                action.analytics(tracker: tracker)
            case let .editProfileNameAction(action: action):
                action.analytics(tracker: tracker)
            case let .scanner(action: action):
                action.analytics(tracker: tracker)
            case let .deviceSecurity(action: action):
                action.analytics(tracker: tracker)
            case let .cardWall(action: action):
                action.analytics(tracker: tracker)
            case let .prescriptionArchiveAction(action: action):
                action.analytics(tracker: tracker)
            case let .prescriptionDetailAction(action: action):
                action.analytics(tracker: tracker)
            case let .redeemMethods(action: action):
                action.analytics(tracker: tracker)
            case let .medicationReminder(action: action):
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
extension MedicationDomain.Destinations.Action {
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
extension MedicationOverviewDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .medication(action: action):
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
extension MedicationReminderListDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .medicationReminderAction(action: action):
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
extension MedicationReminderSetupDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
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
extension NewProfileDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .editProfilePictureAction(action: action):
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
extension OrderDetailDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .prescriptionDetail(action: action):
                action.analytics(tracker: tracker)
            case let .pickupCode(action: action):
                action.analytics(tracker: tracker)
            case let .chargeItem(action: action):
                action.analytics(tracker: tracker)
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
extension OrderHealthCardDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
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
extension OrdersDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .orderDetail(action: action):
                action.analytics(tracker: tracker)
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
extension PharmacyDetailDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .pharmacyRedeemViaErxTaskRepository(action: action):
                action.analytics(tracker: tracker)
            case let .pharmacyRedeemViaAVS(action: action):
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
extension PharmacyRedeemDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .redeemSuccessView(action: action):
                action.analytics(tracker: tracker)
            case let .pharmacyContact(action: action):
                action.analytics(tracker: tracker)
            case let .cardWall(action: action):
                action.analytics(tracker: tracker)
            case let .prescriptionSelection(action: action):
                action.analytics(tracker: tracker)
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
extension PharmacySearchDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .pharmacyDetailView(action: action):
                action.analytics(tracker: tracker)
            case let .pharmacyFilterView(action: action):
                action.analytics(tracker: tracker)
            case let .pharmacyMapSearch(action: action):
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
extension PharmacySearchMapDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .pharmacyDetailView(action: action):
                action.analytics(tracker: tracker)
            case let .pharmacyFilterView(action: action):
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
extension PrescriptionArchiveDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension PrescriptionArchiveDomain.Destinations.Action {
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
extension PrescriptionDetailDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .chargeItem(action: action):
                action.analytics(tracker: tracker)
            case let .medication(action: action):
                action.analytics(tracker: tracker)
            case let .medicationOverview(action: action):
                action.analytics(tracker: tracker)
            case let .medicationReminder(action: action):
                action.analytics(tracker: tracker)
            case let .matrixCode(action: action):
                action.analytics(tracker: tracker)
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
extension ProfileSelectionDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension ProfileSelectionDomain.Destinations.Action {
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
extension RedeemMethodsDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension RedeemMethodsDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .redeemMatrixCodeAction(action: action):
                action.analytics(tracker: tracker)
            case let .pharmacySearchAction(action: action):
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
extension RegisteredDevicesDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .cardWallCAN(action: action):
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
extension ScannerDomain.Destinations.Action {
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
extension SettingsDomain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .healthCardPasswordForgotPinAction(action):
                action.analytics(tracker: tracker)
            case let .healthCardPasswordSetCustomPinAction(action):
                action.analytics(tracker: tracker)
            case let .healthCardPasswordUnlockCardAction(action):
                action.analytics(tracker: tracker)
            case let .appSecurityStateAction(action):
                action.analytics(tracker: tracker)
            case let .egkAction(action):
                action.analytics(tracker: tracker)
            case let .editProfileAction(action):
                action.analytics(tracker: tracker)
            case let .newProfileAction(action):
                action.analytics(tracker: tracker)
            case let .medicationReminderListAction(action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension TCAToast_PreviewProvider.Domain.Destinations.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
