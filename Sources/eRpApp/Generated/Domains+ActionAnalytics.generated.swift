// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import FeatureEURedeem
import FeatureCardWall
import FeatureCommunication
import eRpResources






extension AccidentInfoDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension AppAuthenticationBiometricPasswordDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension AppAuthenticationBiometricPasswordDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension AppAuthenticationBiometricsDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension AppAuthenticationBiometricsDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension AppAuthenticationDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension AppAuthenticationDomain.Subdomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .biometrics(action):
                action.analytics(tracker: tracker)
            case let .password(action):
                action.analytics(tracker: tracker)
            case let .biometricAndPassword(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension AppAuthenticationPasswordDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension AppDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .main(action: action):
                action.analytics(tracker: tracker)
            case let .pharmacy(action: action):
                action.analytics(tracker: tracker)
            case let .orders(action: action):
                action.analytics(tracker: tracker)
            case let .messages(action: action):
                action.analytics(tracker: tracker)
            case let .settings(action: action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension AppDomain.Destinations.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension AppMigrationDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension AppMigrationDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension AppSecurityDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension AppSecurityDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .appPassword(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension AppStartDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension AppStartDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .onboarding(action):
                action.analytics(tracker: tracker)
            case let .app(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension AuditEventsDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension AuditEventsDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .cardWall(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension CardWallCANDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension CardWallCANDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .pin(action):
                action.analytics(tracker: tracker)
            case let .egk(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension CardWallExtAuthHelpDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension CardWallExtAuthSelectionDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension CardWallExtAuthSelectionDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .help(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension CardWallIntroductionDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension CardWallIntroductionDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .can(action):
                action.analytics(tracker: tracker)
            case let .extAuth(action):
                action.analytics(tracker: tracker)
            case let .egk(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension CardWallLoginOptionDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension CardWallLoginOptionDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .readCard(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension CardWallPINDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension CardWallPINDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .login(action):
                action.analytics(tracker: tracker)
            case let .egk(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension CardWallReadCardDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension CardWallReadCardDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .help(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension ChargeItemDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension ChargeItemDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .shareSheet(action):
                action.analytics(tracker: tracker)
            case let .idpCardWall(action):
                action.analytics(tracker: tracker)
            case let .alterChargeItem(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension ChargeItemListDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension ChargeItemListDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .idpCardWall(action):
                action.analytics(tracker: tracker)
            case let .chargeItem(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension CoPaymentDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension CoPaymentDomain.DelegateAction {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension CodeDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension CodeDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension ConsentDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension ConsentDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension CountrySelectionDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension CountrySelectionDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension CreatePasswordDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension CreateProfileDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension CreateProfileDomain.DelegateAction {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension DeviceSecurityDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension DiGaDetailDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension DiGaDetailDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .descriptionDiGA(action):
                action.analytics(tracker: tracker)
            case let .validDiGa(action):
                action.analytics(tracker: tracker)
            case let .supportDiGa(action):
                action.analytics(tracker: tracker)
            case let .cardWall(action):
                action.analytics(tracker: tracker)
            case let .patient(action):
                action.analytics(tracker: tracker)
            case let .practitioner(action):
                action.analytics(tracker: tracker)
            case let .organization(action):
                action.analytics(tracker: tracker)
            case let .technicalInformations(action):
                action.analytics(tracker: tracker)
            case let .insuranceList(action):
                action.analytics(tracker: tracker)
            case let .duesInfo(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension DiGaInsuranceListDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension DiGaInsuranceListDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension DosageInstructionsDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension EURedeemDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .selection(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension EURedeemDomain.Path.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .countrySelection(action):
                action.analytics(tracker: tracker)
            case let .prescriptionSelection(action):
                action.analytics(tracker: tracker)
            case let .instructions(action):
                action.analytics(tracker: tracker)
            case let .code(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension EURedeemSelectionDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension EURedeemSelectionDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .consent(action):
                action.analytics(tracker: tracker)
            case let .cardWall(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension EditProfileDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension EditProfileDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .auditEvents(action):
                action.analytics(tracker: tracker)
            case let .notificationChannels(action):
                action.analytics(tracker: tracker)
            case let .registeredDevices(action):
                action.analytics(tracker: tracker)
            case let .chargeItemList(action):
                action.analytics(tracker: tracker)
            case let .cardWall(action):
                action.analytics(tracker: tracker)
            case let .euRedeemConsent(action):
                action.analytics(tracker: tracker)
            case let .editProfilePicture(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension EditProfileNameDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension EditProfileNameDomain.DelegateAction {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension EditProfilePictureDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension EditProfilePictureDomain.DelegateAction {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension EditProfilePictureDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension EmptyDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension EpaMedicationCodableIngredientDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension EpaMedicationDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension EpaMedicationDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .codableIngredient(action):
                action.analytics(tracker: tracker)
            case let .medicationIngredient(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension ExtAuthPendingDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension ExtAuthPendingDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension HealthCardPasswordCanDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension HealthCardPasswordCanDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .puk(action):
                action.analytics(tracker: tracker)
            case let .oldPin(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension HealthCardPasswordIntroductionDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension HealthCardPasswordIntroductionDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .can(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension HealthCardPasswordOldPinDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension HealthCardPasswordOldPinDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .pin(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension HealthCardPasswordPinDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension HealthCardPasswordPinDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .readCard(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension HealthCardPasswordPukDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension HealthCardPasswordPukDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .pin(action):
                action.analytics(tracker: tracker)
            case let .readCard(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension HealthCardPasswordReadCardDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension HealthCardPasswordReadCardDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .help(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension HorizontalProfileSelectionDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension IDPCardWallDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension IDPCardWallDomain.Subdomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .can(action):
                action.analytics(tracker: tracker)
            case let .pin(action):
                action.analytics(tracker: tracker)
            case let .readCard(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension IngredientDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension InstructionsDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension MainDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
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
            case _: break
        }
    }
}
extension MainDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
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
            case let .medicationReminder(action):
                action.analytics(tracker: tracker)
            case let .diGaDetail(action):
                action.analytics(tracker: tracker)
            case let .osDeprecation(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension MainDomain.Path.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .redeemMethods(action):
                action.analytics(tracker: tracker)
            case let .redeem(action):
                action.analytics(tracker: tracker)
            case let .pharmacy(action):
                action.analytics(tracker: tracker)
            case let .euRedeemSelection(action):
                action.analytics(tracker: tracker)
            case let .countrySelection(action):
                action.analytics(tracker: tracker)
            case let .prescriptionSelection(action):
                action.analytics(tracker: tracker)
            case let .instructions(action):
                action.analytics(tracker: tracker)
            case let .code(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension MatrixCodeDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension MatrixCodeDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .sharePrescription(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension MedicationDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension MedicationDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .ingredient(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension MedicationOverviewDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension MedicationOverviewDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .medication(action):
                action.analytics(tracker: tracker)
            case let .epaMedication(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension MedicationReminderListDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension MedicationReminderListDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .medicationReminder(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension MedicationReminderOneDaySummaryDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension MedicationReminderSetupDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension MedicationReminderSetupDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .repetitionDetails(action):
                action.analytics(tracker: tracker)
            case let .dosageInstructionsInfo(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension MessageThreadDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension MessageThreadListDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension MessageThreadListDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .orderDetail(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension NotificationChannelsDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension OSDeprecationDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension OnboardingDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension OnboardingDomain.Path.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .registerAuth(action):
                action.analytics(tracker: tracker)
            case let .registerPassword(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension OrderDetailDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension OrderDetailDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .pickupCode(action):
                action.analytics(tracker: tracker)
            case let .prescriptionDetail(action):
                action.analytics(tracker: tracker)
            case let .chargeItem(action):
                action.analytics(tracker: tracker)
            case let .pharmacyDetail(action):
                action.analytics(tracker: tracker)
            case let .euAccessCode(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension OrderHealthCardContactDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension OrderHealthCardDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension OrderHealthCardDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .serviceInquiry(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension OrderHealthCardInquiryDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension OrderHealthCardInquiryDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .contact(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension OrdersDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension OrdersDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .orderDetail(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension OrganizationDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension PatientDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension PharmacyContactDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension PharmacyContainerDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .pharmacySearch(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension PharmacyContainerDomain.Path.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .redeem(action):
                action.analytics(tracker: tracker)
            case let .euRedeemSelection(action):
                action.analytics(tracker: tracker)
            case let .countrySelection(action):
                action.analytics(tracker: tracker)
            case let .prescriptionSelection(action):
                action.analytics(tracker: tracker)
            case let .instructions(action):
                action.analytics(tracker: tracker)
            case let .code(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension PharmacyDetailDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case let .serviceOption(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension PharmacyDetailDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension PharmacyPrescriptionSelectionDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension PharmacyRedeemDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case let .serviceOption(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension PharmacyRedeemDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
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
            case _: break
        }
    }
}
extension PharmacySearchClusterDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension PharmacySearchDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension PharmacySearchDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .pharmacyDetail(action):
                action.analytics(tracker: tracker)
            case let .pharmacyFilter(action):
                action.analytics(tracker: tracker)
            case let .pharmacyMapSearch(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension PharmacySearchFilterDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension PharmacySearchMapDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension PharmacySearchMapDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .pharmacy(action):
                action.analytics(tracker: tracker)
            case let .filter(action):
                action.analytics(tracker: tracker)
            case let .clusterSheet(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension PickupCodeDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension PractitionerDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension PrescriptionArchiveDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension PrescriptionArchiveDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .prescriptionDetail(action):
                action.analytics(tracker: tracker)
            case let .diGaDetail(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension PrescriptionDetailDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension PrescriptionDetailDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
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
            case let .teratogenicInfo(action):
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
            case let .selfPayerInfo(action):
                action.analytics(tracker: tracker)
            case let .tPrescriptionInfo(action):
                action.analytics(tracker: tracker)
            case let .medicationReminder(action):
                action.analytics(tracker: tracker)
            case let .dosageInstructionsInfo(action):
                action.analytics(tracker: tracker)
            case let .matrixCode(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension PrescriptionDosageInstructionsDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension PrescriptionDosageInstructionsDomain.DelegateAction {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension PrescriptionListDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension PrescriptionValidityDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension PrescriptionValidityDomain.DelegateAction {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension ProfilesDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension ReadCardHelpDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension ReadCardHelpDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension RedeemMethodsDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension RedeemMethodsDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .matrixCode(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension RedeemSuccessDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension RegisterAuthenticationDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension RegisterPasswordDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension RegisteredDevicesDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension RegisteredDevicesDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .cardWallCAN(action):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension ScannerDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension ScannerDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension SelectEUPrescriptionsDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension SelectEUPrescriptionsDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension ServiceOptionDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension SettingsDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case let .profiles(action: action):
                action.analytics(tracker: tracker)
            case let .destination(.presented(action)):
                action.analytics(tracker: tracker)
            case _: break
        }
    }
}
extension SettingsDomain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
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
            case _: break
        }
    }
}
extension ShareSheetDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension SubstitutionInfoDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension SubstitutionInfoDomain.DelegateAction {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension TCAToast_PreviewProvider.Domain.Destination.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension TechnicalInformationsDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
extension TeratogenicInfoDomain.Action {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func analytics(tracker: Tracker) {
        switch self {
            case _: break
        }
    }
}
