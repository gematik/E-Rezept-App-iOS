// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation



extension AppAuthenticationBiometricPasswordDomain.State {
    func routeName() -> String? {
            return nil
    }
}

extension AppAuthenticationBiometricsDomain.State {
    func routeName() -> String? {
            return nil
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
                return subdomains.main.routeName() ?? destination.tag.analyticsName
            case .pharmacySearch:
                return subdomains.pharmacySearch.routeName() ?? destination.tag.analyticsName
            case .orders:
                return subdomains.orders.routeName() ?? destination.tag.analyticsName
            case .settings:
                return subdomains.settingsState.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension AppMigrationDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension AppSecurityDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .appPassword(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension AuditEventsDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case .alert:
                return destination.tag.analyticsName
            case let .cardWall(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension CardWallCANDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .pin(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .egk(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .scanner:
                return destination.tag.analyticsName
        }
    }
}

extension CardWallExtAuthConfirmationDomain.State {
    func routeName() -> String? {
            return nil
    }
}

extension CardWallExtAuthSelectionDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .confirmation(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .egk(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension CardWallIntroductionDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .can(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .fasttrack(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .egk(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension CardWallLoginOptionDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case .alert:
                return destination.tag.analyticsName
            case let .readcard(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .warning:
                return destination.tag.analyticsName
        }
    }
}

extension CardWallPINDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .login(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .egk(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension CardWallReadCardDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case .alert:
                return destination.tag.analyticsName
            case let .help(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension ChargeItemDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case .shareSheet:
                return destination.tag.analyticsName
            case let .idpCardWall(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .alterChargeItem(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension ChargeItemListDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .idpCardWall(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
            case let .chargeItem(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
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

extension EditProfileDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case .alert:
                return destination.tag.analyticsName
            case .token:
                return destination.tag.analyticsName
            case let .auditEvents(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .registeredDevices(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .chargeItemList(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .editProfilePicture(state: state):
                return state.routeName() ?? destination.tag.analyticsName
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
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case .alert:
                return destination.tag.analyticsName
            case .cameraPicker:
                return destination.tag.analyticsName
            case .photoPicker:
                return destination.tag.analyticsName
        }
    }
}

extension ExtAuthPendingDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case .extAuthAlert:
                return destination.tag.analyticsName
        }
    }
}

extension HealthCardPasswordDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case .introduction:
                return destination.tag.analyticsName
            case .can:
                return destination.tag.analyticsName
            case .puk:
                return destination.tag.analyticsName
            case .oldPin:
                return destination.tag.analyticsName
            case .pin:
                return destination.tag.analyticsName
            case let .readCard(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .scanner:
                return destination.tag.analyticsName
            case .pinAlert:
                return destination.tag.analyticsName
        }
    }
}

extension HealthCardPasswordReadCardDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case .alert:
                return destination.tag.analyticsName
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
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .createProfile(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .editProfilePicture(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .editName(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .scanner(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .deviceSecurity(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .cardWall(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .prescriptionArchive(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .prescriptionDetail(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .redeem(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .welcomeDrawer:
                return destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension MatrixCodeDomain.State {
    func routeName() -> String? {
            return nil
    }
}

extension MedicationDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .ingredient(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension MedicationOverviewDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .medication(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension NewProfileDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .editProfilePicture(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
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
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .pickupCode(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .prescriptionDetail(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension OrderHealthCardDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case .searchPicker:
                return destination.tag.analyticsName
            case .serviceInquiry:
                return destination.tag.analyticsName
            case .contactOptions:
                return destination.tag.analyticsName
        }
    }
}

extension OrdersDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .orderDetail(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension PharmacyContactDomain.State {
    func routeName() -> String? {
            return nil
    }
}

extension PharmacyDetailDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .redeemViaAVS(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .redeemViaErxTaskRepository(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension PharmacyRedeemDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .redeemSuccess(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .contact(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .cardWall(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension PharmacySearchDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .pharmacy(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .filter(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension PharmacySearchFilterDomain.State {
    func routeName() -> String? {
            return nil
    }
}

extension PickupCodeDomain.State {
    func routeName() -> String? {
            return nil
    }
}

extension PrescriptionArchiveDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .prescriptionDetail(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension PrescriptionDetailDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .medicationOverview(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .medication(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .patient:
                return destination.tag.analyticsName
            case .practitioner:
                return destination.tag.analyticsName
            case .organization:
                return destination.tag.analyticsName
            case .accidentInfo:
                return destination.tag.analyticsName
            case .technicalInformations:
                return destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
            case .sharePrescription:
                return destination.tag.analyticsName
            case .directAssignmentInfo:
                return destination.tag.analyticsName
            case .substitutionInfo:
                return destination.tag.analyticsName
            case .prescriptionValidityInfo:
                return destination.tag.analyticsName
            case .scannedPrescriptionInfo:
                return destination.tag.analyticsName
            case .errorInfo:
                return destination.tag.analyticsName
            case .coPaymentInfo:
                return destination.tag.analyticsName
            case .emergencyServiceFeeInfo:
                return destination.tag.analyticsName
        }
    }
}

extension PrescriptionListDomain.State {
    func routeName() -> String? {
            return nil
    }
}

extension ProfileSelectionDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension ProfilesDomain.State {
    func routeName() -> String? {
            return nil
    }
}

extension RedeemMethodsDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .matrixCode(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .pharmacySearch(state: state):
                return state.routeName() ?? destination.tag.analyticsName
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
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .cardWallCAN(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension ScannerDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case .imageGallery:
                return destination.tag.analyticsName
            case .documentImporter:
                return destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
            case .sheet:
                return destination.tag.analyticsName
        }
    }
}

extension SettingsDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case .debug:
                return nil
            case .alert:
                return destination.tag.analyticsName
            case let .healthCardPasswordForgotPin(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .healthCardPasswordSetCustomPin(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .healthCardPasswordUnlockCard(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .appSecurity(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .complyTracking:
                return destination.tag.analyticsName
            case .legalNotice:
                return destination.tag.analyticsName
            case .dataProtection:
                return destination.tag.analyticsName
            case .openSourceLicence:
                return destination.tag.analyticsName
            case .termsOfUse:
                return destination.tag.analyticsName
            case let .egk(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .editProfile(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .newProfile(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}


extension AppStartDomain.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case .loading:
                return destination.tag.analyticsName
            case let .onboarding(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .app(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension ReadCardHelpDomain.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case .first:
                return destination.tag.analyticsName
            case .second:
                return destination.tag.analyticsName
            case .third:
                return destination.tag.analyticsName
            case .fourth:
                return destination.tag.analyticsName
        }
    }
}



extension AppMigrationDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension AppSecurityDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .appPassword(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension AuditEventsDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case .alert:
                return destination.tag.analyticsName
            case let .cardWall(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension CardWallCANDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .pin(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .egk(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .scanner:
                return destination.tag.analyticsName
        }
    }
}

extension CardWallExtAuthSelectionDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .confirmation(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .egk(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension CardWallIntroductionDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .can(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .fasttrack(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .egk(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension CardWallLoginOptionDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case .alert:
                return destination.tag.analyticsName
            case let .readcard(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .warning:
                return destination.tag.analyticsName
        }
    }
}

extension CardWallPINDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .login(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .egk(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension CardWallReadCardDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case .alert:
                return destination.tag.analyticsName
            case let .help(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension ChargeItemDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case .shareSheet:
                return destination.tag.analyticsName
            case let .idpCardWall(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .alterChargeItem(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension ChargeItemListDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .idpCardWall(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
            case let .chargeItem(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension EditProfileDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case .alert:
                return destination.tag.analyticsName
            case .token:
                return destination.tag.analyticsName
            case let .auditEvents(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .registeredDevices(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .chargeItemList(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .editProfilePicture(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension EditProfilePictureDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case .alert:
                return destination.tag.analyticsName
            case .cameraPicker:
                return destination.tag.analyticsName
            case .photoPicker:
                return destination.tag.analyticsName
        }
    }
}

extension ExtAuthPendingDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case .extAuthAlert:
                return destination.tag.analyticsName
        }
    }
}

extension HealthCardPasswordDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case .introduction:
                return destination.tag.analyticsName
            case .can:
                return destination.tag.analyticsName
            case .puk:
                return destination.tag.analyticsName
            case .oldPin:
                return destination.tag.analyticsName
            case .pin:
                return destination.tag.analyticsName
            case let .readCard(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .scanner:
                return destination.tag.analyticsName
            case .pinAlert:
                return destination.tag.analyticsName
        }
    }
}

extension HealthCardPasswordReadCardDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension MainDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .createProfile(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .editProfilePicture(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .editName(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .scanner(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .deviceSecurity(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .cardWall(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .prescriptionArchive(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .prescriptionDetail(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .redeem(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .welcomeDrawer:
                return destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension MedicationDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .ingredient(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension MedicationOverviewDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .medication(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension NewProfileDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .editProfilePicture(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension OrderDetailDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .pickupCode(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .prescriptionDetail(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension OrderHealthCardDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case .searchPicker:
                return destination.tag.analyticsName
            case .serviceInquiry:
                return destination.tag.analyticsName
            case .contactOptions:
                return destination.tag.analyticsName
        }
    }
}

extension OrdersDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .orderDetail(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension PharmacyDetailDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .redeemViaAVS(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .redeemViaErxTaskRepository(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension PharmacyRedeemDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .redeemSuccess(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .contact(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .cardWall(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension PharmacySearchDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .pharmacy(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .filter(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension PrescriptionArchiveDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .prescriptionDetail(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension PrescriptionDetailDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .medicationOverview(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .medication(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .patient:
                return destination.tag.analyticsName
            case .practitioner:
                return destination.tag.analyticsName
            case .organization:
                return destination.tag.analyticsName
            case .accidentInfo:
                return destination.tag.analyticsName
            case .technicalInformations:
                return destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
            case .sharePrescription:
                return destination.tag.analyticsName
            case .directAssignmentInfo:
                return destination.tag.analyticsName
            case .substitutionInfo:
                return destination.tag.analyticsName
            case .prescriptionValidityInfo:
                return destination.tag.analyticsName
            case .scannedPrescriptionInfo:
                return destination.tag.analyticsName
            case .errorInfo:
                return destination.tag.analyticsName
            case .coPaymentInfo:
                return destination.tag.analyticsName
            case .emergencyServiceFeeInfo:
                return destination.tag.analyticsName
        }
    }
}

extension ProfileSelectionDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension RedeemMethodsDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .matrixCode(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .pharmacySearch(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}

extension RegisteredDevicesDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .cardWallCAN(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension ScannerDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case .imageGallery:
                return destination.tag.analyticsName
            case .documentImporter:
                return destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
            case .sheet:
                return destination.tag.analyticsName
        }
    }
}

extension SettingsDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case .debug:
                return nil
            case .alert:
                return destination.tag.analyticsName
            case let .healthCardPasswordForgotPin(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .healthCardPasswordSetCustomPin(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .healthCardPasswordUnlockCard(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .appSecurity(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .complyTracking:
                return destination.tag.analyticsName
            case .legalNotice:
                return destination.tag.analyticsName
            case .dataProtection:
                return destination.tag.analyticsName
            case .openSourceLicence:
                return destination.tag.analyticsName
            case .termsOfUse:
                return destination.tag.analyticsName
            case let .egk(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .editProfile(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .newProfile(state: state):
                return state.routeName() ?? destination.tag.analyticsName
        }
    }
}



extension AppDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .main: 
                return Analytics.Screens.main.name
            case .pharmacySearch: 
                return Analytics.Screens.pharmacySearch.name
            case .orders: 
                return Analytics.Screens.orders.name
            case .settings: 
                return Analytics.Screens.settings.name
        }
    }
}
extension AppMigrationDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .alert: 
                return "alert"
        }
    }
}
extension AppSecurityDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .appPassword: 
                return "appPassword"
        }
    }
}
extension AuditEventsDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .alert: 
                return Analytics.Screens.errorAlert.name
            case .cardWall: 
                return Analytics.Screens.cardWall.name
        }
    }
}
extension CardWallCANDomain.Destinations.State.Tag {
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
extension CardWallExtAuthSelectionDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .confirmation: 
                return Analytics.Screens.cardWall_extAuthConfirm.name
            case .egk: 
                return Analytics.Screens.contactInsuranceCompany.name
        }
    }
}
extension CardWallIntroductionDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .can: 
                return Analytics.Screens.cardWall_CAN.name
            case .fasttrack: 
                return Analytics.Screens.cardWall_extAuth.name
            case .egk: 
                return Analytics.Screens.contactInsuranceCompany.name
        }
    }
}
extension CardWallLoginOptionDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .alert: 
                return Analytics.Screens.alert.name
            case .readcard: 
                return Analytics.Screens.cardWall_readCard.name
            case .warning: 
                return Analytics.Screens.cardWall_saveLoginSecurityInfo.name
        }
    }
}
extension CardWallPINDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .login: 
                return Analytics.Screens.cardWall_saveLogin.name
            case .egk: 
                return Analytics.Screens.contactInsuranceCompany.name
        }
    }
}
extension CardWallReadCardDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .alert: 
                return Analytics.Screens.alert.name
            case .help: 
                return "help"
        }
    }
}
extension ChargeItemDomain.Destinations.State.Tag {
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
extension ChargeItemListDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .idpCardWall: 
                return Analytics.Screens.cardWall.name
            case .alert: 
                return Analytics.Screens.alert.name
            case .chargeItem: 
                return Analytics.Screens.chargeItemDetails.name
        }
    }
}
extension EditProfileDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .alert: 
                return Analytics.Screens.alert.name
            case .token: 
                return Analytics.Screens.profile_token.name
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
extension EditProfilePictureDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .alert: 
                return "alert"
            case .cameraPicker: 
                return "cameraPicker"
            case .photoPicker: 
                return "photoPicker"
        }
    }
}
extension ExtAuthPendingDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .extAuthAlert: 
                return "extAuthAlert"
        }
    }
}
extension HealthCardPasswordDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .introduction: 
                return Analytics.Screens.healthCardPassword_introduction.name
            case .can: 
                return Analytics.Screens.healthCardPassword_can.name
            case .puk: 
                return Analytics.Screens.healthCardPassword_puk.name
            case .oldPin: 
                return Analytics.Screens.healthCardPassword_oldPin.name
            case .pin: 
                return Analytics.Screens.healthCardPassword_pin.name
            case .readCard: 
                return Analytics.Screens.healthCardPassword_readCard.name
            case .scanner: 
                return Analytics.Screens.healthCardPassword_scanner.name
            case .pinAlert: 
                return Analytics.Screens.healthCardPassword_pin_alert.name
        }
    }
}
extension HealthCardPasswordReadCardDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .alert: 
                return Analytics.Screens.errorAlert.name
        }
    }
}
extension MainDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .createProfile: 
                return Analytics.Screens.main_createProfile.name
            case .editProfilePicture: 
                return Analytics.Screens.main_editProfilePicture.name
            case .editName: 
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
            case .redeem: 
                return Analytics.Screens.redeem_methodSelection.name
            case .welcomeDrawer: 
                return Analytics.Screens.main_welcomeDrawer.name
            case .alert: 
                return Analytics.Screens.alert.name
        }
    }
}
extension MedicationDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .ingredient: 
                return Analytics.Screens.prescriptionDetail_medication_ingredients.name
        }
    }
}
extension MedicationOverviewDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .medication: 
                return Analytics.Screens.prescriptionDetail_medication.name
        }
    }
}
extension NewProfileDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .editProfilePicture: 
                return "editProfilePicture"
            case .alert: 
                return "alert"
        }
    }
}
extension OrderDetailDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .pickupCode: 
                return Analytics.Screens.orders_pickupCode.name
            case .prescriptionDetail: 
                return Analytics.Screens.prescriptionDetail.name
            case .alert: 
                return Analytics.Screens.alert.name
        }
    }
}
extension OrderHealthCardDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .searchPicker: 
                return Analytics.Screens.contactInsuranceCompany_selectKK.name
            case .serviceInquiry: 
                return Analytics.Screens.contactInsuranceCompany_selectReason.name
            case .contactOptions: 
                return Analytics.Screens.contactInsuranceCompany_selectMethod.name
        }
    }
}
extension OrdersDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .orderDetail: 
                return Analytics.Screens.orders_detail.name
        }
    }
}
extension PharmacyDetailDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .redeemViaAVS: 
                return Analytics.Screens.redeem_viaAVS.name
            case .redeemViaErxTaskRepository: 
                return Analytics.Screens.redeem_viaTI.name
            case .alert: 
                return Analytics.Screens.alert.name
        }
    }
}
extension PharmacyRedeemDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .redeemSuccess: 
                return Analytics.Screens.redeem_success.name
            case .contact: 
                return Analytics.Screens.redeem_editContactInformation.name
            case .cardWall: 
                return Analytics.Screens.cardWall.name
            case .alert: 
                return Analytics.Screens.alert.name
        }
    }
}
extension PharmacySearchDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .pharmacy: 
                return Analytics.Screens.pharmacySearch_detail.name
            case .filter: 
                return Analytics.Screens.pharmacySearch_filter.name
            case .alert: 
                return Analytics.Screens.alert.name
        }
    }
}
extension PrescriptionArchiveDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .prescriptionDetail: 
                return Analytics.Screens.prescriptionDetail.name
        }
    }
}
extension PrescriptionDetailDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
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
                return Analytics.Screens.errorAlert.name
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
        }
    }
}
extension ProfileSelectionDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .alert: 
                return "alert"
        }
    }
}
extension RedeemMethodsDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .matrixCode: 
                return Analytics.Screens.redeem_matrixCode.name
            case .pharmacySearch: 
                return Analytics.Screens.pharmacySearch.name
        }
    }
}
extension RegisteredDevicesDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .cardWallCAN: 
                return Analytics.Screens.cardWall.name
            case .alert: 
                return Analytics.Screens.alert.name
        }
    }
}
extension ScannerDomain.Destinations.State.Tag {
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
extension SettingsDomain.Destinations.State.Tag {
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
        }
    }
}


extension AppStartDomain.State.Tag {
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
extension ReadCardHelpDomain.State.Tag {
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
