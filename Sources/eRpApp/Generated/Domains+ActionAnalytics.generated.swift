// Generated using Sourcery 2.1.2 — https://github.com/krzysztofzablocki/Sourcery
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
            default: break
        }
    }
}
extension CardWallIntroductionDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension CardWallLoginOptionDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension CardWallPINDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
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
extension ChargeItemDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension ChargeItemListDomain.Action {
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
extension EditProfileDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
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
            default: break
        }
    }
}
extension MedicationOverviewDomain.Action {
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
extension OrderDetailDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
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
            default: break
        }
    }
}
extension PharmacyRedeemDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
            default: break
        }
    }
}
extension PharmacySearchDomain.Action {
    func analytics(tracker: Tracker) {
        switch self {
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
            case let .profiles(action: action):
                action.analytics(tracker: tracker)
            default: break
        }
    }
}
