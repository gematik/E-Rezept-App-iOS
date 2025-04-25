// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation




extension AccidentInfoDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension AppAuthenticationBiometricPasswordDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case .alert:
                return destination.analyticsName
        }
    }
}

extension AppAuthenticationBiometricsDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case .alert:
                return destination.analyticsName
        }
    }
}

extension AppAuthenticationDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension AppAuthenticationPasswordDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension AppDomain.State {
    func routeName() -> String? {
        switch destination {
            case .main:
                return main.routeName() ?? destination.tag.analyticsName
            case .pharmacy:
                return pharmacy.routeName() ?? destination.tag.analyticsName
            case .orders:
                return orders.routeName() ?? destination.tag.analyticsName
            case .settings:
                return settings.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension AppMigrationDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case .alert:
                return destination.analyticsName
        }
    }
}

extension AppSecurityDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .appPassword(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension AppStartDomain.State {
    func routeName() -> String? {
        switch destination {
            case .loading:
                return destination.analyticsName
            case let .onboarding(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .app(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension AuditEventsDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .cardWall(state: state):
                return state.routeName() ?? destination.analyticsName
            case .alert:
                return destination.analyticsName
        }
    }
}

extension CardWallCANDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .pin(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .egk(state: state):
                return state.routeName() ?? destination.analyticsName
            case .scanner:
                return destination.analyticsName
        }
    }
}

extension CardWallExtAuthConfirmationDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension CardWallExtAuthHelpDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension CardWallExtAuthSelectionDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .confirmation(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .help(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension CardWallIntroductionDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .can(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .extAuth(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .egk(state: state):
                return state.routeName() ?? destination.analyticsName
            case .alert:
                return destination.analyticsName
            case .contactSheet:
                return destination.analyticsName
        }
    }
}

extension CardWallLoginOptionDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case .alert:
                return destination.analyticsName
            case let .readCard(state: state):
                return state.routeName() ?? destination.analyticsName
            case .warning:
                return destination.analyticsName
        }
    }
}

extension CardWallPINDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .login(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .egk(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension CardWallReadCardDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case .alert:
                return destination.analyticsName
            case let .help(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension ChargeItemDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .shareSheet(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .idpCardWall(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .alterChargeItem(state: state):
                return state.routeName() ?? destination.analyticsName
            case .alert:
                return destination.analyticsName
        }
    }
}

extension ChargeItemListDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .idpCardWall(state: state):
                return state.routeName() ?? destination.analyticsName
            case .alert:
                return destination.analyticsName
            case let .chargeItem(state: state):
                return state.routeName() ?? destination.analyticsName
            case .toast:
                return destination.analyticsName
        }
    }
}

extension CoPaymentDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension CreatePasswordDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension CreateProfileDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension DeviceSecurityDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension DosageInstructionsDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension EditProfileDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case .alert:
                return destination.analyticsName
            case let .auditEvents(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .registeredDevices(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .chargeItemList(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .editProfilePicture(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension EditProfileNameDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension EditProfilePictureDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case .alert:
                return destination.analyticsName
            case .cameraPicker:
                return destination.analyticsName
            case .memojiPicker:
                return destination.analyticsName
            case .photoPicker:
                return destination.analyticsName
        }
    }
}

extension EmptyDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension EpaMedicationCodableIngredientDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension EpaMedicationDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .codableIngredient(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .medicationIngredient(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension ExtAuthPendingDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case .extAuthAlert:
                return destination.analyticsName
        }
    }
}

extension HealthCardPasswordCanDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .puk(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .oldPin(state: state):
                return state.routeName() ?? destination.analyticsName
            case .scanner:
                return destination.analyticsName
        }
    }
}

extension HealthCardPasswordIntroductionDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .can(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension HealthCardPasswordOldPinDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .pin(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension HealthCardPasswordPinDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .readCard(state: state):
                return state.routeName() ?? destination.analyticsName
            case .pinAlert:
                return destination.analyticsName
        }
    }
}

extension HealthCardPasswordPukDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .pin(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .readCard(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension HealthCardPasswordReadCardDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case .alert:
                return destination.analyticsName
        }
    }
}

extension HorizontalProfileSelectionDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension IDPCardWallDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension IngredientDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension MainDomain.State {
    func routeName() -> String? {
        if let pathId = path.ids.last,
            let path = path[id: pathId] {
            switch path {
            case let .redeemMethods(state: state):
                return state.routeName() ?? path.analyticsName
            case let .redeem(state: state):
                return state.routeName() ?? path.analyticsName
            case let .pharmacy(state: state):
                return state.routeName() ?? path.analyticsName
            }
        }
        guard let destination else { return nil }
        switch destination {
            case let .createProfile(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .editProfilePicture(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .editProfileName(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .scanner(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .deviceSecurity(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .cardWall(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .prescriptionArchive(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .prescriptionDetail(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .medicationReminder(state: state):
                return state.routeName() ?? destination.analyticsName
            case .welcomeDrawer:
                return destination.analyticsName
            case .grantChargeItemConsentDrawer:
                return destination.analyticsName
            case .alert:
                return destination.analyticsName
            case .toast:
                return destination.analyticsName
        }
    }
}

extension MatrixCodeDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .sharePrescription(state: state):
                return state.routeName() ?? destination.analyticsName
            case .alert:
                return destination.analyticsName
        }
    }
}

extension MedicationDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .ingredient(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension MedicationOverviewDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .medication(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .epaMedication(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension MedicationReminderListDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .medicationReminder(state: state):
                return state.routeName() ?? destination.analyticsName
            case .alert:
                return destination.analyticsName
        }
    }
}

extension MedicationReminderOneDaySummaryDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension MedicationReminderSetupDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case .alert:
                return destination.analyticsName
            case let .repetitionDetails(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .dosageInstructionsInfo(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension NewProfileDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .editProfilePicture(state: state):
                return state.routeName() ?? destination.analyticsName
            case .alert:
                return destination.analyticsName
        }
    }
}

extension OnboardingDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension OrderDetailDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .pickupCode(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .prescriptionDetail(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .chargeItem(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .pharmacyDetail(state: state):
                return state.routeName() ?? destination.analyticsName
            case .alert:
                return destination.analyticsName
        }
    }
}

extension OrderHealthCardContactDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension OrderHealthCardDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .serviceInquiry(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension OrderHealthCardInquiryDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .contact(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension OrdersDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .orderDetail(state: state):
                return state.routeName() ?? destination.analyticsName
            case .alert:
                return destination.analyticsName
        }
    }
}

extension OrganizationDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension PatientDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension PharmacyContactDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension PharmacyContainerDomain.State {
    func routeName() -> String? {
        if let pathId = path.ids.last,
            let path = path[id: pathId] {
            switch path {
            case let .redeem(state: state):
                return state.routeName() ?? path.analyticsName
            }
        }
        return nil
    }
}

extension PharmacyDetailDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case .alert:
                return destination.analyticsName
            case .toast:
                return destination.analyticsName
        }
    }
}

extension PharmacyPrescriptionSelectionDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension PharmacyRedeemDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .redeemSuccess(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .contact(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .cardWall(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .prescriptionSelection(state: state):
                return state.routeName() ?? destination.analyticsName
            case .alert:
                return destination.analyticsName
        }
    }
}

extension PharmacySearchClusterDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension PharmacySearchDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .pharmacyDetail(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .pharmacyFilter(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .pharmacyMapSearch(state: state):
                return state.routeName() ?? destination.analyticsName
            case .alert:
                return destination.analyticsName
        }
    }
}

extension PharmacySearchFilterDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension PharmacySearchMapDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .pharmacy(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .filter(state: state):
                return state.routeName() ?? destination.analyticsName
            case .alert:
                return destination.analyticsName
            case let .clusterSheet(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension PickupCodeDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension PractitionerDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension PrescriptionArchiveDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .prescriptionDetail(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension PrescriptionDetailDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .chargeItem(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .medicationOverview(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .medication(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .patient(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .practitioner(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .organization(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .accidentInfo(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .technicalInformations(state: state):
                return state.routeName() ?? destination.analyticsName
            case .alert:
                return destination.analyticsName
            case let .sharePrescription(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .directAssignmentInfo(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .substitutionInfo(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .prescriptionValidityInfo(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .scannedPrescriptionInfo(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .errorInfo(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .coPaymentInfo(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .emergencyServiceFeeInfo(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .selfPayerInfo(state: state):
                return state.routeName() ?? destination.analyticsName
            case .toast:
                return destination.analyticsName
            case let .medicationReminder(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .dosageInstructionsInfo(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .matrixCode(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension PrescriptionDosageInstructionsDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension PrescriptionListDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension PrescriptionValidityDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension ProfilesDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension ReadCardHelpDomain.State {
    func routeName() -> String? {
        switch destination {
            case .first:
                return destination.analyticsName
            case .second:
                return destination.analyticsName
            case .third:
                return destination.analyticsName
            case .fourth:
                return destination.analyticsName
        }
    }
}

extension RedeemMethodsDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .matrixCode(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension RedeemSuccessDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension RegisterAuthenticationDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension RegisteredDevicesDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case let .cardWallCAN(state: state):
                return state.routeName() ?? destination.analyticsName
            case .alert:
                return destination.analyticsName
        }
    }
}

extension ScannerDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case .imageGallery:
                return destination.analyticsName
            case .documentImporter:
                return destination.analyticsName
            case .alert:
                return destination.analyticsName
            case .sheet:
                return destination.analyticsName
        }
    }
}

extension ServiceOptionDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension SettingsDomain.State {
    func routeName() -> String? {
        guard let destination else { return nil }
        switch destination {
            case .debug:
                return nil
            case .alert:
                return destination.analyticsName
            case let .healthCardPasswordForgotPin(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .healthCardPasswordSetCustomPin(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .healthCardPasswordUnlockCard(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .appSecurity(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .complyTracking(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .legalNotice(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .dataProtection(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .openSourceLicence(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .termsOfUse(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .egk(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .editProfile(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .newProfile(state: state):
                return state.routeName() ?? destination.analyticsName
            case let .medicationReminderList(state: state):
                return state.routeName() ?? destination.analyticsName
        }
    }
}

extension ShareSheetDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension SubstitutionInfoDomain.State {
    func routeName() -> String? {
        return nil
    }
}

extension TechnicalInformationsDomain.State {
    func routeName() -> String? {
        return nil
    }
}






extension AppDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .main:
                return Analytics.Screens.main.name
            case .pharmacy:
                return Analytics.Screens.pharmacySearch.name
            case .orders:
                return Analytics.Screens.orders.name
            case .settings:
                return Analytics.Screens.settings.name
        }
    }
}

extension AppAuthenticationBiometricPasswordDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .alert:
                return "alert"
        }
    }
}
extension AppAuthenticationBiometricsDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .alert:
                return "alert"
        }
    }
}
extension AppMigrationDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .alert:
                return "alert"
        }
    }
}
extension AppSecurityDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .appPassword:
                return "appPassword"
        }
    }
}
extension AppStartDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .loading:
                return "loading"
            case .onboarding:
                return "onboarding"
            case .app:
                return "app"
        }
    }
}
extension AuditEventsDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .cardWall:
                return Analytics.Screens.cardWall.name
            case .alert:
                return Analytics.Screens.errorAlert.name
        }
    }
}
extension CardWallCANDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .pin:
                return Analytics.Screens.cardWall_PIN.name
            case .egk:
                return Analytics.Screens.contactInsuranceCompany.name
            case .scanner:
                return Analytics.Screens.cardWall_scanCAN.name
        }
    }
}
extension CardWallExtAuthSelectionDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .confirmation:
                return Analytics.Screens.cardWall_extAuthConfirm.name
            case .help:
                return Analytics.Screens.cardWall_extAuthSelectionHelp.name
        }
    }
}
extension CardWallIntroductionDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .can:
                return Analytics.Screens.cardWall_CAN.name
            case .extAuth:
                return Analytics.Screens.cardWall_extAuth.name
            case .egk:
                return Analytics.Screens.contactInsuranceCompany.name
            case .alert:
                return Analytics.Screens.alert.name
            case .contactSheet:
                return "contactSheet"
        }
    }
}
extension CardWallLoginOptionDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .alert:
                return Analytics.Screens.alert.name
            case .readCard:
                return Analytics.Screens.cardWall_readCard.name
            case .warning:
                return Analytics.Screens.cardWall_saveLoginSecurityInfo.name
        }
    }
}
extension CardWallPINDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .login:
                return Analytics.Screens.cardWall_saveLogin.name
            case .egk:
                return Analytics.Screens.contactInsuranceCompany.name
        }
    }
}
extension CardWallReadCardDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .alert:
                return Analytics.Screens.alert.name
            case .help:
                return "help"
        }
    }
}
extension ChargeItemDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .shareSheet:
                return "shareSheet"
            case .idpCardWall:
                return "idpCardWall"
            case .alterChargeItem:
                return "alterChargeItem"
            case .alert:
                return "alert"
        }
    }
}
extension ChargeItemListDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .idpCardWall:
                return Analytics.Screens.cardWall.name
            case .alert:
                return Analytics.Screens.alert.name
            case .chargeItem:
                return Analytics.Screens.chargeItemDetails.name
            case .toast:
                return Analytics.Screens.chargeItemList_toast.name
        }
    }
}
extension EditProfileDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .alert:
                return Analytics.Screens.alert.name
            case .auditEvents:
                return Analytics.Screens.profile_auditEvents.name
            case .registeredDevices:
                return Analytics.Screens.profile_registeredDevices.name
            case .chargeItemList:
                return Analytics.Screens.chargeItemList.name
            case .editProfilePicture:
                return "editProfilePicture"
        }
    }
}
extension EditProfilePictureDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .alert:
                return "alert"
            case .cameraPicker:
                return "cameraPicker"
            case .memojiPicker:
                return "memojiPicker"
            case .photoPicker:
                return "photoPicker"
        }
    }
}
extension EpaMedicationDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .codableIngredient:
                return Analytics.Screens.prescriptionDetail_epa_medication_codable_ingredient.name
            case .medicationIngredient:
                return Analytics.Screens.prescriptionDetail_epa_medication_ingredient.name
        }
    }
}
extension ExtAuthPendingDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .extAuthAlert:
                return "extAuthAlert"
        }
    }
}
extension HealthCardPasswordCanDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .puk:
                return Analytics.Screens.healthCardPassword_puk.name
            case .oldPin:
                return Analytics.Screens.healthCardPassword_oldPin.name
            case .scanner:
                return Analytics.Screens.healthCardPassword_scanner.name
        }
    }
}
extension HealthCardPasswordIntroductionDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .can:
                return Analytics.Screens.healthCardPassword_can.name
        }
    }
}
extension HealthCardPasswordOldPinDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .pin:
                return Analytics.Screens.healthCardPassword_pin.name
        }
    }
}
extension HealthCardPasswordPinDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .readCard:
                return Analytics.Screens.healthCardPassword_readCard.name
            case .pinAlert:
                return Analytics.Screens.healthCardPassword_pin_alert.name
        }
    }
}
extension HealthCardPasswordPukDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .pin:
                return Analytics.Screens.healthCardPassword_pin.name
            case .readCard:
                return Analytics.Screens.healthCardPassword_readCard.name
        }
    }
}
extension HealthCardPasswordReadCardDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .alert:
                return Analytics.Screens.errorAlert.name
        }
    }
}
extension MainDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .createProfile:
                return Analytics.Screens.main_createProfile.name
            case .editProfilePicture:
                return Analytics.Screens.main_editProfilePicture.name
            case .editProfileName:
                return Analytics.Screens.main_editName.name
            case .scanner:
                return Analytics.Screens.main_scanner.name
            case .deviceSecurity:
                return Analytics.Screens.main_deviceSecurity.name
            case .cardWall:
                return Analytics.Screens.cardWall.name
            case .prescriptionArchive:
                return Analytics.Screens.main_prescriptionArchive.name
            case .prescriptionDetail:
                return Analytics.Screens.prescriptionDetail.name
            case .medicationReminder:
                return Analytics.Screens.main_medicationReminder.name
            case .welcomeDrawer:
                return Analytics.Screens.main_welcomeDrawer.name
            case .grantChargeItemConsentDrawer:
                return Analytics.Screens.main_consentDrawer.name
            case .alert:
                return Analytics.Screens.alert.name
            case .toast:
                return Analytics.Screens.alert.name
        }
    }
}
extension MatrixCodeDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .sharePrescription:
                return Analytics.Screens.matrixCode_sharePrescription.name
            case .alert:
                return Analytics.Screens.alert.name
        }
    }
}
extension MedicationDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .ingredient:
                return Analytics.Screens.prescriptionDetail_medication_ingredients.name
        }
    }
}
extension MedicationOverviewDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .medication:
                return Analytics.Screens.prescriptionDetail_medication.name
            case .epaMedication:
                return Analytics.Screens.prescriptionDetail_epaMedication.name
        }
    }
}
extension MedicationReminderListDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .medicationReminder:
                return "medicationReminder"
            case .alert:
                return Analytics.Screens.alert.name
        }
    }
}
extension MedicationReminderSetupDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .alert:
                return Analytics.Screens.alert.name
            case .repetitionDetails:
                return Analytics.Screens.medicationReminder_repetitionDetails.name
            case .dosageInstructionsInfo:
                return Analytics.Screens.medicationReminder_dosageInstruction.name
        }
    }
}
extension NewProfileDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .editProfilePicture:
                return "editProfilePicture"
            case .alert:
                return "alert"
        }
    }
}
extension OrderDetailDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .pickupCode:
                return Analytics.Screens.orders_pickupCode.name
            case .prescriptionDetail:
                return Analytics.Screens.prescriptionDetail.name
            case .chargeItem:
                return Analytics.Screens.chargeItemDetails.name
            case .pharmacyDetail:
                return Analytics.Screens.orders_pharmacyDetail.name
            case .alert:
                return Analytics.Screens.alert.name
        }
    }
}
extension OrderHealthCardDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .serviceInquiry:
                return Analytics.Screens.contactInsuranceCompany_selectReason.name
        }
    }
}
extension OrderHealthCardInquiryDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .contact:
                return Analytics.Screens.contactInsuranceCompany_selectMethod.name
        }
    }
}
extension OrdersDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .orderDetail:
                return Analytics.Screens.orders_detail.name
            case .alert:
                return Analytics.Screens.alert.name
        }
    }
}
extension PharmacyDetailDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .alert:
                return Analytics.Screens.alert.name
            case .toast:
                return Analytics.Screens.alert.name
        }
    }
}
extension PharmacyRedeemDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .redeemSuccess:
                return Analytics.Screens.redeem_success.name
            case .contact:
                return Analytics.Screens.redeem_editContactInformation.name
            case .cardWall:
                return Analytics.Screens.cardWall.name
            case .prescriptionSelection:
                return Analytics.Screens.redeem_prescriptionSelection.name
            case .alert:
                return Analytics.Screens.alert.name
        }
    }
}
extension PharmacySearchDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .pharmacyDetail:
                return Analytics.Screens.pharmacySearch_detail.name
            case .pharmacyFilter:
                return Analytics.Screens.pharmacySearch_filter.name
            case .pharmacyMapSearch:
                return Analytics.Screens.pharmacySearch_map.name
            case .alert:
                return Analytics.Screens.alert.name
        }
    }
}
extension PharmacySearchMapDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .pharmacy:
                return Analytics.Screens.pharmacySearch_detail.name
            case .filter:
                return Analytics.Screens.pharmacySearch_filter.name
            case .alert:
                return Analytics.Screens.alert.name
            case .clusterSheet:
                return "clusterSheet"
        }
    }
}
extension PrescriptionArchiveDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .prescriptionDetail:
                return Analytics.Screens.prescriptionDetail.name
        }
    }
}
extension PrescriptionDetailDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .chargeItem:
                return Analytics.Screens.chargeItemDetails.name
            case .medicationOverview:
                return Analytics.Screens.prescriptionDetail_medicationOverview.name
            case .medication:
                return Analytics.Screens.prescriptionDetail_medication.name
            case .patient:
                return Analytics.Screens.prescriptionDetail_patient.name
            case .practitioner:
                return Analytics.Screens.prescriptionDetail_practitioner.name
            case .organization:
                return Analytics.Screens.prescriptionDetail_organization.name
            case .accidentInfo:
                return Analytics.Screens.prescriptionDetail_accidentInfo.name
            case .technicalInformations:
                return Analytics.Screens.prescriptionDetail_technicalInfo.name
            case .alert:
                return Analytics.Screens.alert.name
            case .sharePrescription:
                return Analytics.Screens.prescriptionDetail_sharePrescription.name
            case .directAssignmentInfo:
                return Analytics.Screens.prescriptionDetail_directAssignmentInfo.name
            case .substitutionInfo:
                return Analytics.Screens.prescriptionDetail_substitutionInfo.name
            case .prescriptionValidityInfo:
                return Analytics.Screens.prescriptionDetail_prescriptionValidityInfo.name
            case .scannedPrescriptionInfo:
                return Analytics.Screens.prescriptionDetail_scannedPrescriptionInfo.name
            case .errorInfo:
                return Analytics.Screens.prescriptionDetail_errorInfo.name
            case .coPaymentInfo:
                return Analytics.Screens.prescriptionDetail_coPaymentInfo.name
            case .emergencyServiceFeeInfo:
                return Analytics.Screens.prescriptionDetail_emergencyServiceFeeInfo.name
            case .selfPayerInfo:
                return Analytics.Screens.prescriptionDetail_selfPayerPrescriptionBottomSheet.name
            case .toast:
                return Analytics.Screens.prescriptionDetail_toast.name
            case .medicationReminder:
                return Analytics.Screens.prescriptionDetail_setupMedicationSchedule.name
            case .dosageInstructionsInfo:
                return Analytics.Screens.prescriptionDetail_dosageInstructionsInfo.name
            case .matrixCode:
                return Analytics.Screens.prescriptionDetail_matrixCode.name
        }
    }
}
extension ReadCardHelpDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .first:
                return Analytics.Screens.troubleShooting_readCardHelp1.name
            case .second:
                return Analytics.Screens.troubleShooting_readCardHelp2.name
            case .third:
                return Analytics.Screens.troubleShooting_readCardHelp3.name
            case .fourth:
                return Analytics.Screens.troubleShooting_readCardHelp4.name
        }
    }
}
extension RedeemMethodsDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .matrixCode:
                return Analytics.Screens.redeem_matrixCode.name
        }
    }
}
extension RegisteredDevicesDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .cardWallCAN:
                return Analytics.Screens.cardWall.name
            case .alert:
                return Analytics.Screens.alert.name
        }
    }
}
extension ScannerDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .imageGallery:
                return Analytics.Screens.scanner_imageGallery.name
            case .documentImporter:
                return Analytics.Screens.scanner_documentImporter.name
            case .alert:
                return "alert"
            case .sheet:
                return "sheet"
        }
    }
}
extension SettingsDomain.Destination.State {
    var analyticsName: String {
        switch self {
            case .debug:
                return "debug"
            case .alert:
                return Analytics.Screens.alert.name
            case .healthCardPasswordForgotPin:
                return Analytics.Screens.healthCardPassword_forgotPin.name
            case .healthCardPasswordSetCustomPin:
                return Analytics.Screens.healthCardPassword_setCustomPin.name
            case .healthCardPasswordUnlockCard:
                return Analytics.Screens.healthCardPassword_unlockCard.name
            case .appSecurity:
                return "appSecurity"
            case .complyTracking:
                return Analytics.Screens.settings_productImprovements_complyTracking.name
            case .legalNotice:
                return Analytics.Screens.settings_legalNotice.name
            case .dataProtection:
                return Analytics.Screens.settings_dataProtection.name
            case .openSourceLicence:
                return Analytics.Screens.settings_openSourceLicence.name
            case .termsOfUse:
                return Analytics.Screens.settings_termsOfUse.name
            case .egk:
                return Analytics.Screens.contactInsuranceCompany.name
            case .editProfile:
                return Analytics.Screens.profile.name
            case .newProfile:
                return Analytics.Screens.settings_newProfile.name
            case .medicationReminderList:
                return Analytics.Screens.settings_medicationReminderList.name
        }
    }
}

extension MainDomain.Path.State {
    var analyticsName: String {
        switch self {
            case .redeemMethods:
                return Analytics.Screens.redeem_methodSelection.name
            case .redeem:
                return Analytics.Screens.redeem_overview.name
            case .pharmacy:
                return Analytics.Screens.pharmacySearch.name
        }
    }
}
extension PharmacyContainerDomain.Path.State {
    var analyticsName: String {
        switch self {
            case .redeem:
                return Analytics.Screens.pharmacySearch.name
        }
    }
}
