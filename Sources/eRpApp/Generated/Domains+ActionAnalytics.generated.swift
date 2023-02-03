// Generated using Sourcery 1.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation





extension AddProfileDomain.Action {
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
            case let .profile(action: action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension AppMigrationDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension AppSecurityDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension AppStartDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .app(action: action):
                action.analytics(tracker: tracker)
            case let .onboarding(action: action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension AuditEventsDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension CardWallCANDomain.Action {
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
            case let .canAction(action: action):
                action.analytics(tracker: tracker)
            case let .fasttrack(action: action):
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
            case let .readcardAction(action: action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension CardWallPINDomain.Action {
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
            case let .auditEvents(action: action):
                action.analytics(tracker: tracker)
            case let .registeredDevices(action: action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension ExtAuthPendingDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension HealthCardPasswordDomain.Action {
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
extension MainDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .extAuthPending(action: action):
                action.analytics(tracker: tracker)
            case let .prescriptionList(action: action):
                action.analytics(tracker: tracker)
            case let .scanner(action: action):
                action.analytics(tracker: tracker)
            case let .deviceSecurity(action: action):
                action.analytics(tracker: tracker)
            case let .prescriptionArchiveAction(action: action):
                action.analytics(tracker: tracker)
            case let .prescriptionDetailAction(action: action):
                action.analytics(tracker: tracker)
            case let .redeemMethods(action: action):
                action.analytics(tracker: tracker)
            case let .cardWall(action: action):
                action.analytics(tracker: tracker)
            case let .addProfileAction(action: action):
                action.analytics(tracker: tracker)
            case let .horizontalProfileSelection(action: action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension MainViewHintsDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension NewProfileDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
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
extension OnboardingNewProfileDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension OrderDetailDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .prescriptionDetail(action: action):
                action.analytics(tracker: tracker)
            case let .pickupCode(action: action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension OrderHealthCardDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension OrdersDomain.Action {
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
            case let .pharmacyRedeemViaErxTaskRepository(action: action):
                action.analytics(tracker: tracker)
            case let .pharmacyRedeemViaAVS(action: action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension PharmacyRedeemDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .redeemSuccessView(action: action):
                action.analytics(tracker: tracker)
            case let .pharmacyContact(action: action):
                action.analytics(tracker: tracker)
            case let .cardWall(action: action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension PharmacySearchDomain.Action {
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
extension PharmacySearchFilterDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
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
            case let .prescriptionDetailAction(action: action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension PrescriptionDetailDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension PrescriptionListDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .hint(action: action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension ProfileSelectionDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension ProfileSelectionToolbarItemDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .profileSelection(action: action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension ProfilesDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .profile(action: action):
                action.analytics(tracker: tracker)
            case let .newProfile(action: action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension RedeemMatrixCodeDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension RedeemMethodsDomain.Action {
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
            case let .idpCardWall(action: action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
extension ScannerDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension SettingsDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            case let .appSecurity(action: action):
                action.analytics(tracker: tracker)
            case let .profiles(action: action):
                action.analytics(tracker: tracker)
            case let .healthCardPasswordUnlockCard(action: action):
                action.analytics(tracker: tracker)
            case let .healthCardPasswordForgotPin(action: action):
                action.analytics(tracker: tracker)
            case let .healthCardPasswordSetCustomPin(action: action):
                action.analytics(tracker: tracker)
            case let .createPassword(action: action):
                action.analytics(tracker: tracker)
            case let .egkAction(action: action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
