// Generated using Sourcery 1.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation


extension AppDomain.Route {
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
extension CardWallCANDomain.Route {
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
extension CardWallExtAuthSelectionDomain.Route {
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
extension CardWallIntroductionDomain.Route {
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
extension CardWallLoginOptionDomain.Route {
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
extension CardWallPINDomain.Route {
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
extension CardWallReadCardDomain.Route {
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
extension EditProfileDomain.Route {
    enum Tag: Int {
        case alert
        case token
        case linkedDevices
        case auditEvents
        case registeredDevices
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
        }
    }
}
extension HealthCardPasswordDomain.Route {
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
extension HealthCardPasswordReadCardDomain.Route {
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
extension MainDomain.Route {
    enum Tag: Int {
        case addProfile
        case welcomeDrawer
        case scanner
        case deviceSecurity
        case cardWall
        case prescriptionArchive
        case prescriptionDetail
        case redeem
        case alert
    }

    var tag: Tag {
        switch self {
            case .addProfile:
                return .addProfile
            case .welcomeDrawer:
                return .welcomeDrawer
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
            case .alert:
                return .alert
        }
    }
}
extension OrderDetailDomain.Route {
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
extension OrderHealthCardDomain.Route {
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
extension OrdersDomain.Route {
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
extension PharmacyDetailDomain.Route {
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
extension PharmacyRedeemDomain.Route {
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
extension PharmacySearchDomain.Route {
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
extension PrescriptionArchiveDomain.Route {
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
extension PrescriptionDetailDomain.Route {
    enum Tag: Int {
        case alert
        case sharePrescription
        case directAssignment
    }

    var tag: Tag {
        switch self {
            case .alert:
                return .alert
            case .sharePrescription:
                return .sharePrescription
            case .directAssignment:
                return .directAssignment
        }
    }
}
extension ProfileSelectionDomain.Route {
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
extension ProfilesDomain.Route {
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
extension RedeemMethodsDomain.Route {
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
extension RegisteredDevicesDomain.Route {
    enum Tag: Int {
        case cardWall
        case alert
    }

    var tag: Tag {
        switch self {
            case .cardWall:
                return .cardWall
            case .alert:
                return .alert
        }
    }
}
extension SettingsDomain.Route {
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

extension AppMigrationDomain.State {
    enum Tag: Int {
        case none
        case inProgress
        case finished
        case failed
    }

    var tag: Tag {
        switch self {
            case .none:
                return .none
            case .inProgress:
                return .inProgress
            case .finished:
                return .finished
            case .failed:
                return .failed
        }
    }
}
extension AppStartDomain.State {
    enum Tag: Int {
        case loading
        case onboarding
        case app
    }

    var tag: Tag {
        switch self {
            case .loading:
                return .loading
            case .onboarding:
                return .onboarding
            case .app:
                return .app
        }
    }
}
extension CardWallReadCardHelpDomain.State {
    enum Tag: Int {
        case first
        case second
        case third
    }

    var tag: Tag {
        switch self {
            case .first:
                return .first
            case .second:
                return .second
            case .third:
                return .third
        }
    }
}
extension ExtAuthPendingDomain.State {
    enum Tag: Int {
        case empty
        case pendingExtAuth
        case extAuthReceived
        case extAuthSuccessful
        case extAuthFailed
    }

    var tag: Tag {
        switch self {
            case .empty:
                return .empty
            case .pendingExtAuth:
                return .pendingExtAuth
            case .extAuthReceived:
                return .extAuthReceived
            case .extAuthSuccessful:
                return .extAuthSuccessful
            case .extAuthFailed:
                return .extAuthFailed
        }
    }
}
