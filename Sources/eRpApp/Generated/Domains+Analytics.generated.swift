// Generated using Sourcery 2.0.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation



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

extension AppSecurityDomain.State {
    func routeName() -> String? {
            return nil
    }
}

extension AuditEventsDomain.State {
    func routeName() -> String? {
            return nil
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
            case .notCapable:
                return destination.tag.analyticsName
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
            return nil
    }
}

extension ChargeItemsDomain.State {
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
            case .linkedDevices:
                return destination.tag.analyticsName
            case let .auditEvents(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .registeredDevices(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .chargeItems(state: state):
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
            return nil
    }
}

extension HealthCardPasswordDomain.State {
    func routeName() -> String? {
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

extension NewProfileDomain.State {
    func routeName() -> String? {
            return nil
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
            case .selectProfile:
                return destination.tag.analyticsName
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
            case .selectProfile:
                return destination.tag.analyticsName
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
            case .medication:
                return destination.tag.analyticsName
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

extension ProfileSelectionToolbarItemDomain.State {
    func routeName() -> String? {
            return nil
    }
}

extension ProfilesDomain.State {
    func routeName() -> String? {
        guard let destination = destination else {
            return nil
        }
        switch destination {
            case let .editProfile(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .newProfile(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension RedeemMatrixCodeDomain.State {
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
            case let .idpCardWall(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .alert:
                return destination.tag.analyticsName
        }
    }
}

extension ScannerDomain.State {
    func routeName() -> String? {
            return nil
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
            case let .setAppPassword(state: state):
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
        }
    }
}


extension AppMigrationDomain.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case .none:
                return destination.tag.analyticsName
            case .inProgress:
                return destination.tag.analyticsName
            case .finished:
                return destination.tag.analyticsName
            case .failed:
                return destination.tag.analyticsName
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

extension CardWallReadCardHelpDomain.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case .first:
                return destination.tag.analyticsName
            case .second:
                return destination.tag.analyticsName
            case .third:
                return destination.tag.analyticsName
        }
    }
}

extension ExtAuthPendingDomain.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case .empty:
                return destination.tag.analyticsName
            case .pendingExtAuth:
                return destination.tag.analyticsName
            case .extAuthReceived:
                return destination.tag.analyticsName
            case .extAuthSuccessful:
                return destination.tag.analyticsName
            case let .extAuthFailed(.error(error, _)): 
                return error.analyticsName
            case .extAuthFailed:
                return destination.tag.analyticsName
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
            case .notCapable:
                return destination.tag.analyticsName
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

extension ChargeItemsDomain.Destinations.State {
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
            case .linkedDevices:
                return destination.tag.analyticsName
            case let .auditEvents(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .registeredDevices(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .chargeItems(state: state):
                return state.routeName() ?? destination.tag.analyticsName
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
        }
    }
}

extension OrdersDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .orderDetail(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .selectProfile:
                return destination.tag.analyticsName
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
            case .selectProfile:
                return destination.tag.analyticsName
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
            case .medication:
                return destination.tag.analyticsName
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

extension ProfilesDomain.Destinations.State {
    func routeName() -> String? {
        let destination = self
        switch destination {
            case let .editProfile(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case let .newProfile(state: state):
                return state.routeName() ?? destination.tag.analyticsName
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
            case let .idpCardWall(state: state):
                return state.routeName() ?? destination.tag.analyticsName
            case .alert:
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
            case let .setAppPassword(state: state):
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
        }
    }
}



extension AppDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .main: 
                return "main"
            case .pharmacySearch: 
                return "pharmacySearch"
            case .orders: 
                return "orders"
            case .settings: 
                return "settings"
        }
    }
}
extension CardWallCANDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .pin: 
                return Analytics.Screens.cardwallPIN.name
            case .egk: 
                return Analytics.Screens.cardwallContactInsuranceCompany.name
            case .scanner: 
                return Analytics.Screens.cardwallScanCAN.name
        }
    }
}
extension CardWallExtAuthSelectionDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .confirmation: 
                return Analytics.Screens.cardWallExtAuthConfirm.name
            case .egk: 
                return "egk"
        }
    }
}
extension CardWallIntroductionDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .can: 
                return Analytics.Screens.cardwallCAN.name
            case .fasttrack: 
                return Analytics.Screens.cardWallExtAuth.name
            case .egk: 
                return Analytics.Screens.cardwallContactInsuranceCompany.name
            case .notCapable: 
                return Analytics.Screens.cardwallNotCapable.name
        }
    }
}
extension CardWallLoginOptionDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .alert: 
                return "alert"
            case .readcard: 
                return Analytics.Screens.cardWallReadCard.name
            case .warning: 
                return Analytics.Screens.cardwallSaveLoginSecurityInfo.name
        }
    }
}
extension CardWallPINDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .login: 
                return Analytics.Screens.cardwallSaveLogin.name
            case .egk: 
                return Analytics.Screens.cardwallContactInsuranceCompany.name
        }
    }
}
extension CardWallReadCardDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .alert: 
                return "alert"
            case .help: 
                return "help"
        }
    }
}
extension ChargeItemsDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .idpCardWall: 
                return "idpCardWall"
            case .alert: 
                return "alert"
            case .chargeItem: 
                return "chargeItem"
        }
    }
}
extension EditProfileDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .alert: 
                return "alert"
            case .token: 
                return "token"
            case .linkedDevices: 
                return "linkedDevices"
            case .auditEvents: 
                return "auditEvents"
            case .registeredDevices: 
                return "registeredDevices"
            case .chargeItems: 
                return "chargeItems"
        }
    }
}
extension HealthCardPasswordDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .introduction: 
                return "introduction"
            case .can: 
                return "can"
            case .puk: 
                return "puk"
            case .oldPin: 
                return "oldPin"
            case .pin: 
                return "pin"
            case .readCard: 
                return "readCard"
            case .scanner: 
                return "scanner"
        }
    }
}
extension HealthCardPasswordReadCardDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .alert: 
                return "alert"
        }
    }
}
extension MainDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .createProfile: 
                return "createProfile"
            case .editProfilePicture: 
                return "editProfilePicture"
            case .editName: 
                return "editName"
            case .scanner: 
                return "scanner"
            case .deviceSecurity: 
                return "deviceSecurity"
            case .cardWall: 
                return "cardWall"
            case .prescriptionArchive: 
                return "prescriptionArchive"
            case .prescriptionDetail: 
                return "prescriptionDetail"
            case .redeem: 
                return "redeem"
            case .welcomeDrawer: 
                return "welcomeDrawer"
            case .alert: 
                return "alert"
        }
    }
}
extension OrderDetailDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .pickupCode: 
                return "pickupCode"
            case .prescriptionDetail: 
                return "prescriptionDetail"
            case .alert: 
                return "alert"
        }
    }
}
extension OrderHealthCardDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .searchPicker: 
                return "searchPicker"
            case .serviceInquiry: 
                return "serviceInquiry"
        }
    }
}
extension OrdersDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .orderDetail: 
                return "orderDetail"
            case .selectProfile: 
                return "selectProfile"
        }
    }
}
extension PharmacyDetailDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .redeemViaAVS: 
                return "redeemViaAVS"
            case .redeemViaErxTaskRepository: 
                return "redeemViaErxTaskRepository"
            case .alert: 
                return "alert"
        }
    }
}
extension PharmacyRedeemDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .redeemSuccess: 
                return "redeemSuccess"
            case .contact: 
                return "contact"
            case .cardWall: 
                return "cardWall"
            case .alert: 
                return "alert"
        }
    }
}
extension PharmacySearchDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .selectProfile: 
                return "selectProfile"
            case .pharmacy: 
                return "pharmacy"
            case .filter: 
                return "filter"
            case .alert: 
                return "alert"
        }
    }
}
extension PrescriptionArchiveDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .prescriptionDetail: 
                return "prescriptionDetail"
        }
    }
}
extension PrescriptionDetailDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .medication: 
                return "medication"
            case .patient: 
                return "patient"
            case .practitioner: 
                return "practitioner"
            case .organization: 
                return "organization"
            case .accidentInfo: 
                return "accidentInfo"
            case .technicalInformations: 
                return "technicalInformations"
            case .alert: 
                return "alert"
            case .sharePrescription: 
                return "sharePrescription"
            case .directAssignmentInfo: 
                return "directAssignmentInfo"
            case .substitutionInfo: 
                return "substitutionInfo"
            case .prescriptionValidityInfo: 
                return "prescriptionValidityInfo"
            case .scannedPrescriptionInfo: 
                return "scannedPrescriptionInfo"
            case .errorInfo: 
                return "errorInfo"
            case .coPaymentInfo: 
                return "coPaymentInfo"
            case .emergencyServiceFeeInfo: 
                return "emergencyServiceFeeInfo"
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
extension ProfilesDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .editProfile: 
                return "editProfile"
            case .newProfile: 
                return "newProfile"
            case .alert: 
                return "alert"
        }
    }
}
extension RedeemMethodsDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .matrixCode: 
                return "matrixCode"
            case .pharmacySearch: 
                return "pharmacySearch"
        }
    }
}
extension RegisteredDevicesDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .idpCardWall: 
                return "idpCardWall"
            case .alert: 
                return "alert"
        }
    }
}
extension SettingsDomain.Destinations.State.Tag {
    var analyticsName: String {
        switch self {
            case .debug: 
                return "debug"
            case .alert: 
                return "alert"
            case .healthCardPasswordForgotPin: 
                return "healthCardPasswordForgotPin"
            case .healthCardPasswordSetCustomPin: 
                return "healthCardPasswordSetCustomPin"
            case .healthCardPasswordUnlockCard: 
                return "healthCardPasswordUnlockCard"
            case .setAppPassword: 
                return "setAppPassword"
            case .complyTracking: 
                return "complyTracking"
            case .legalNotice: 
                return "legalNotice"
            case .dataProtection: 
                return "dataProtection"
            case .openSourceLicence: 
                return "openSourceLicence"
            case .termsOfUse: 
                return "termsOfUse"
            case .egk: 
                return "egk"
        }
    }
}


extension AppMigrationDomain.State.Tag {
    var analyticsName: String {
        switch self {
            case .none: 
                return "none"
            case .inProgress: 
                return "inProgress"
            case .finished: 
                return "finished"
            case .failed: 
                return "failed"
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
extension CardWallReadCardHelpDomain.State.Tag {
    var analyticsName: String {
        switch self {
            case .first: 
                return Analytics.Screens.cardWallReadCardHelp1.name
            case .second: 
                return Analytics.Screens.cardWallReadCardHelp2.name
            case .third: 
                return Analytics.Screens.cardWallReadCardHelp3.name
        }
    }
}
extension ExtAuthPendingDomain.State.Tag {
    var analyticsName: String {
        switch self {
            case .empty: 
                return "empty"
            case .pendingExtAuth: 
                return "pendingExtAuth"
            case .extAuthReceived: 
                return "extAuthReceived"
            case .extAuthSuccessful: 
                return "extAuthSuccessful"
            case .extAuthFailed: 
                return "extAuthFailed"
        }
    }
}
