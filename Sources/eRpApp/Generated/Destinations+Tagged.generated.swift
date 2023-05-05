// Generated using Sourcery 2.0.1 — https://github.com/krzysztofzablocki/Sourcery
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
        case fasttrack
        case egk
        case notCapable
    }

    var tag: Tag {
        switch self {
            case .can:
                return .can
            case .fasttrack:
                return .fasttrack
            case .egk:
                return .egk
            case .notCapable:
                return .notCapable
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
extension ChargeItemsDomain.Destinations.State {
    enum Tag: Int {
        case idpCardWall
        case alert
        case chargeItem
    }

    var tag: Tag {
        switch self {
            case .idpCardWall:
                return .idpCardWall
            case .alert:
                return .alert
            case .chargeItem:
                return .chargeItem
        }
    }
}
extension EditProfileDomain.Destinations.State {
    enum Tag: Int {
        case alert
        case token
        case linkedDevices
        case auditEvents
        case registeredDevices
        case chargeItems
    }

    var tag: Tag {
        switch self {
            case .alert:
                return .alert
            case .token:
                return .token
            case .linkedDevices:
                return .linkedDevices
            case .auditEvents:
                return .auditEvents
            case .registeredDevices:
                return .registeredDevices
            case .chargeItems:
                return .chargeItems
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
        case welcomeDrawer
        case alert
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
            case .welcomeDrawer:
                return .welcomeDrawer
            case .alert:
                return .alert
        }
    }
}
extension OrderDetailDomain.Destinations.State {
    enum Tag: Int {
        case pickupCode
        case prescriptionDetail
        case alert
    }

    var tag: Tag {
        switch self {
            case .pickupCode:
                return .pickupCode
            case .prescriptionDetail:
                return .prescriptionDetail
            case .alert:
                return .alert
        }
    }
}
extension OrderHealthCardDomain.Destinations.State {
    enum Tag: Int {
        case searchPicker
        case serviceInquiry
    }

    var tag: Tag {
        switch self {
            case .searchPicker:
                return .searchPicker
            case .serviceInquiry:
                return .serviceInquiry
        }
    }
}
extension OrdersDomain.Destinations.State {
    enum Tag: Int {
        case orderDetail
        case selectProfile
    }

    var tag: Tag {
        switch self {
            case .orderDetail:
                return .orderDetail
            case .selectProfile:
                return .selectProfile
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
            case .alert:
                return .alert
        }
    }
}
extension PharmacySearchDomain.Destinations.State {
    enum Tag: Int {
        case selectProfile
        case pharmacy
        case filter
        case alert
    }

    var tag: Tag {
        switch self {
            case .selectProfile:
                return .selectProfile
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
    }

    var tag: Tag {
        switch self {
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
extension ProfilesDomain.Destinations.State {
    enum Tag: Int {
        case editProfile
        case newProfile
        case alert
    }

    var tag: Tag {
        switch self {
            case .editProfile:
                return .editProfile
            case .newProfile:
                return .newProfile
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
        case idpCardWall
        case alert
    }

    var tag: Tag {
        switch self {
            case .idpCardWall:
                return .idpCardWall
            case .alert:
                return .alert
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
        case setAppPassword
        case complyTracking
        case legalNotice
        case dataProtection
        case openSourceLicence
        case termsOfUse
        case egk
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
            case .setAppPassword:
                return .setAppPassword
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
        }
    }
}
