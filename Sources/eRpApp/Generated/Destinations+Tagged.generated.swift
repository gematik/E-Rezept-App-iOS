// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation


extension AppDomain.Destinations.State {
    enum Tag: Int {
        case main
        case pharmacySearch
        case orders
        case settings
    }

    var tag: Tag {
        switch self {
            case .main:
                return .main
            case .pharmacySearch:
                return .pharmacySearch
            case .orders:
                return .orders
            case .settings:
                return .settings
        }
    }
}
extension AppMigrationDomain.Destinations.State {
    enum Tag: Int {
        case alert
    }

    var tag: Tag {
        switch self {
            case .alert:
                return .alert
        }
    }
}
extension AppSecurityDomain.Destinations.State {
    enum Tag: Int {
        case appPassword
    }

    var tag: Tag {
        switch self {
            case .appPassword:
                return .appPassword
        }
    }
}
extension AuditEventsDomain.Destinations.State {
    enum Tag: Int {
        case alert
        case cardWall
    }

    var tag: Tag {
        switch self {
            case .alert:
                return .alert
            case .cardWall:
                return .cardWall
        }
    }
}
extension CardWallCANDomain.Destinations.State {
    enum Tag: Int {
        case pin
        case egk
        case scanner
    }

    var tag: Tag {
        switch self {
            case .pin:
                return .pin
            case .egk:
                return .egk
            case .scanner:
                return .scanner
        }
    }
}
extension CardWallExtAuthSelectionDomain.Destinations.State {
    enum Tag: Int {
        case confirmation
        case egk
    }

    var tag: Tag {
        switch self {
            case .confirmation:
                return .confirmation
            case .egk:
                return .egk
        }
    }
}
extension CardWallIntroductionDomain.Destinations.State {
    enum Tag: Int {
        case can
        case extauth
        case egk
    }

    var tag: Tag {
        switch self {
            case .can:
                return .can
            case .extauth:
                return .extauth
            case .egk:
                return .egk
        }
    }
}
extension CardWallLoginOptionDomain.Destinations.State {
    enum Tag: Int {
        case alert
        case readcard
        case warning
    }

    var tag: Tag {
        switch self {
            case .alert:
                return .alert
            case .readcard:
                return .readcard
            case .warning:
                return .warning
        }
    }
}
extension CardWallPINDomain.Destinations.State {
    enum Tag: Int {
        case login
        case egk
    }

    var tag: Tag {
        switch self {
            case .login:
                return .login
            case .egk:
                return .egk
        }
    }
}
extension CardWallReadCardDomain.Destinations.State {
    enum Tag: Int {
        case alert
        case help
    }

    var tag: Tag {
        switch self {
            case .alert:
                return .alert
            case .help:
                return .help
        }
    }
}
extension ChargeItemDomain.Destinations.State {
    enum Tag: Int {
        case shareSheet
        case idpCardWall
        case alterChargeItem
        case alert
    }

    var tag: Tag {
        switch self {
            case .shareSheet:
                return .shareSheet
            case .idpCardWall:
                return .idpCardWall
            case .alterChargeItem:
                return .alterChargeItem
            case .alert:
                return .alert
        }
    }
}
extension ChargeItemListDomain.Destinations.State {
    enum Tag: Int {
        case idpCardWall
        case alert
        case chargeItem
        case toast
    }

    var tag: Tag {
        switch self {
            case .idpCardWall:
                return .idpCardWall
            case .alert:
                return .alert
            case .chargeItem:
                return .chargeItem
            case .toast:
                return .toast
        }
    }
}
extension EditProfileDomain.Destinations.State {
    enum Tag: Int {
        case alert
        case token
        case auditEvents
        case registeredDevices
        case chargeItemList
        case editProfilePicture
    }

    var tag: Tag {
        switch self {
            case .alert:
                return .alert
            case .token:
                return .token
            case .auditEvents:
                return .auditEvents
            case .registeredDevices:
                return .registeredDevices
            case .chargeItemList:
                return .chargeItemList
            case .editProfilePicture:
                return .editProfilePicture
        }
    }
}
extension EditProfilePictureDomain.Destinations.State {
    enum Tag: Int {
        case alert
        case cameraPicker
        case photoPicker
    }

    var tag: Tag {
        switch self {
            case .alert:
                return .alert
            case .cameraPicker:
                return .cameraPicker
            case .photoPicker:
                return .photoPicker
        }
    }
}
extension ExtAuthPendingDomain.Destinations.State {
    enum Tag: Int {
        case extAuthAlert
    }

    var tag: Tag {
        switch self {
            case .extAuthAlert:
                return .extAuthAlert
        }
    }
}
extension HealthCardPasswordDomain.Destinations.State {
    enum Tag: Int {
        case introduction
        case can
        case puk
        case oldPin
        case pin
        case readCard
        case scanner
        case pinAlert
    }

    var tag: Tag {
        switch self {
            case .introduction:
                return .introduction
            case .can:
                return .can
            case .puk:
                return .puk
            case .oldPin:
                return .oldPin
            case .pin:
                return .pin
            case .readCard:
                return .readCard
            case .scanner:
                return .scanner
            case .pinAlert:
                return .pinAlert
        }
    }
}
extension HealthCardPasswordReadCardDomain.Destinations.State {
    enum Tag: Int {
        case alert
    }

    var tag: Tag {
        switch self {
            case .alert:
                return .alert
        }
    }
}
extension MainDomain.Destinations.State {
    enum Tag: Int {
        case createProfile
        case editProfilePicture
        case editName
        case scanner
        case deviceSecurity
        case cardWall
        case prescriptionArchive
        case prescriptionDetail
        case redeem
        case medicationReminder
        case welcomeDrawer
        case grantChargeItemConsentDrawer
        case alert
        case toast
    }

    var tag: Tag {
        switch self {
            case .createProfile:
                return .createProfile
            case .editProfilePicture:
                return .editProfilePicture
            case .editName:
                return .editName
            case .scanner:
                return .scanner
            case .deviceSecurity:
                return .deviceSecurity
            case .cardWall:
                return .cardWall
            case .prescriptionArchive:
                return .prescriptionArchive
            case .prescriptionDetail:
                return .prescriptionDetail
            case .redeem:
                return .redeem
            case .medicationReminder:
                return .medicationReminder
            case .welcomeDrawer:
                return .welcomeDrawer
            case .grantChargeItemConsentDrawer:
                return .grantChargeItemConsentDrawer
            case .alert:
                return .alert
            case .toast:
                return .toast
        }
    }
}
extension MedicationDomain.Destinations.State {
    enum Tag: Int {
        case ingredient
    }

    var tag: Tag {
        switch self {
            case .ingredient:
                return .ingredient
        }
    }
}
extension MedicationOverviewDomain.Destinations.State {
    enum Tag: Int {
        case medication
    }

    var tag: Tag {
        switch self {
            case .medication:
                return .medication
        }
    }
}
extension MedicationReminderListDomain.Destinations.State {
    enum Tag: Int {
        case medicationReminder
        case alert
    }

    var tag: Tag {
        switch self {
            case .medicationReminder:
                return .medicationReminder
            case .alert:
                return .alert
        }
    }
}
extension MedicationReminderSetupDomain.Destinations.State {
    enum Tag: Int {
        case alert
        case repetitionDetails
        case dosageInstructionsInfo
    }

    var tag: Tag {
        switch self {
            case .alert:
                return .alert
            case .repetitionDetails:
                return .repetitionDetails
            case .dosageInstructionsInfo:
                return .dosageInstructionsInfo
        }
    }
}
extension NewProfileDomain.Destinations.State {
    enum Tag: Int {
        case editProfilePicture
        case alert
    }

    var tag: Tag {
        switch self {
            case .editProfilePicture:
                return .editProfilePicture
            case .alert:
                return .alert
        }
    }
}
extension OrderDetailDomain.Destinations.State {
    enum Tag: Int {
        case pickupCode
        case prescriptionDetail
        case chargeItem
        case alert
    }

    var tag: Tag {
        switch self {
            case .pickupCode:
                return .pickupCode
            case .prescriptionDetail:
                return .prescriptionDetail
            case .chargeItem:
                return .chargeItem
            case .alert:
                return .alert
        }
    }
}
extension OrderHealthCardDomain.Destinations.State {
    enum Tag: Int {
        case searchPicker
        case serviceInquiry
        case contactOptions
    }

    var tag: Tag {
        switch self {
            case .searchPicker:
                return .searchPicker
            case .serviceInquiry:
                return .serviceInquiry
            case .contactOptions:
                return .contactOptions
        }
    }
}
extension OrdersDomain.Destinations.State {
    enum Tag: Int {
        case orderDetail
        case alert
    }

    var tag: Tag {
        switch self {
            case .orderDetail:
                return .orderDetail
            case .alert:
                return .alert
        }
    }
}
extension PharmacyDetailDomain.Destinations.State {
    enum Tag: Int {
        case redeemViaAVS
        case redeemViaErxTaskRepository
        case alert
    }

    var tag: Tag {
        switch self {
            case .redeemViaAVS:
                return .redeemViaAVS
            case .redeemViaErxTaskRepository:
                return .redeemViaErxTaskRepository
            case .alert:
                return .alert
        }
    }
}
extension PharmacyRedeemDomain.Destinations.State {
    enum Tag: Int {
        case redeemSuccess
        case contact
        case cardWall
        case prescriptionSelection
        case alert
    }

    var tag: Tag {
        switch self {
            case .redeemSuccess:
                return .redeemSuccess
            case .contact:
                return .contact
            case .cardWall:
                return .cardWall
            case .prescriptionSelection:
                return .prescriptionSelection
            case .alert:
                return .alert
        }
    }
}
extension PharmacySearchDomain.Destinations.State {
    enum Tag: Int {
        case pharmacy
        case filter
        case alert
        case mapSearch
    }

    var tag: Tag {
        switch self {
            case .pharmacy:
                return .pharmacy
            case .filter:
                return .filter
            case .alert:
                return .alert
            case .mapSearch:
                return .mapSearch
        }
    }
}
extension PharmacySearchMapDomain.Destinations.State {
    enum Tag: Int {
        case pharmacy
        case filter
        case alert
    }

    var tag: Tag {
        switch self {
            case .pharmacy:
                return .pharmacy
            case .filter:
                return .filter
            case .alert:
                return .alert
        }
    }
}
extension PrescriptionArchiveDomain.Destinations.State {
    enum Tag: Int {
        case prescriptionDetail
    }

    var tag: Tag {
        switch self {
            case .prescriptionDetail:
                return .prescriptionDetail
        }
    }
}
extension PrescriptionDetailDomain.Destinations.State {
    enum Tag: Int {
        case chargeItem
        case medicationOverview
        case medication
        case patient
        case practitioner
        case organization
        case accidentInfo
        case technicalInformations
        case alert
        case sharePrescription
        case directAssignmentInfo
        case substitutionInfo
        case prescriptionValidityInfo
        case scannedPrescriptionInfo
        case errorInfo
        case coPaymentInfo
        case emergencyServiceFeeInfo
        case toast
        case medicationReminder
        case dosageInstructionsInfo
    }

    var tag: Tag {
        switch self {
            case .chargeItem:
                return .chargeItem
            case .medicationOverview:
                return .medicationOverview
            case .medication:
                return .medication
            case .patient:
                return .patient
            case .practitioner:
                return .practitioner
            case .organization:
                return .organization
            case .accidentInfo:
                return .accidentInfo
            case .technicalInformations:
                return .technicalInformations
            case .alert:
                return .alert
            case .sharePrescription:
                return .sharePrescription
            case .directAssignmentInfo:
                return .directAssignmentInfo
            case .substitutionInfo:
                return .substitutionInfo
            case .prescriptionValidityInfo:
                return .prescriptionValidityInfo
            case .scannedPrescriptionInfo:
                return .scannedPrescriptionInfo
            case .errorInfo:
                return .errorInfo
            case .coPaymentInfo:
                return .coPaymentInfo
            case .emergencyServiceFeeInfo:
                return .emergencyServiceFeeInfo
            case .toast:
                return .toast
            case .medicationReminder:
                return .medicationReminder
            case .dosageInstructionsInfo:
                return .dosageInstructionsInfo
        }
    }
}
extension ProfileSelectionDomain.Destinations.State {
    enum Tag: Int {
        case alert
    }

    var tag: Tag {
        switch self {
            case .alert:
                return .alert
        }
    }
}
extension RedeemMethodsDomain.Destinations.State {
    enum Tag: Int {
        case matrixCode
        case pharmacySearch
    }

    var tag: Tag {
        switch self {
            case .matrixCode:
                return .matrixCode
            case .pharmacySearch:
                return .pharmacySearch
        }
    }
}
extension RegisteredDevicesDomain.Destinations.State {
    enum Tag: Int {
        case cardWallCAN
        case alert
    }

    var tag: Tag {
        switch self {
            case .cardWallCAN:
                return .cardWallCAN
            case .alert:
                return .alert
        }
    }
}
extension ScannerDomain.Destinations.State {
    enum Tag: Int {
        case imageGallery
        case documentImporter
        case alert
        case sheet
    }

    var tag: Tag {
        switch self {
            case .imageGallery:
                return .imageGallery
            case .documentImporter:
                return .documentImporter
            case .alert:
                return .alert
            case .sheet:
                return .sheet
        }
    }
}
extension SettingsDomain.Destinations.State {
    enum Tag: Int {
        case debug
        case alert
        case healthCardPasswordForgotPin
        case healthCardPasswordSetCustomPin
        case healthCardPasswordUnlockCard
        case appSecurity
        case complyTracking
        case legalNotice
        case dataProtection
        case openSourceLicence
        case termsOfUse
        case egk
        case editProfile
        case newProfile
        case medicationReminderList
    }

    var tag: Tag {
        switch self {
            case .debug:
                return .debug
            case .alert:
                return .alert
            case .healthCardPasswordForgotPin:
                return .healthCardPasswordForgotPin
            case .healthCardPasswordSetCustomPin:
                return .healthCardPasswordSetCustomPin
            case .healthCardPasswordUnlockCard:
                return .healthCardPasswordUnlockCard
            case .appSecurity:
                return .appSecurity
            case .complyTracking:
                return .complyTracking
            case .legalNotice:
                return .legalNotice
            case .dataProtection:
                return .dataProtection
            case .openSourceLicence:
                return .openSourceLicence
            case .termsOfUse:
                return .termsOfUse
            case .egk:
                return .egk
            case .editProfile:
                return .editProfile
            case .newProfile:
                return .newProfile
            case .medicationReminderList:
                return .medicationReminderList
        }
    }
}
