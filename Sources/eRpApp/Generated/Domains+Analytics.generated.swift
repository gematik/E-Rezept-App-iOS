// Generated using Sourcery 1.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation



extension AddProfileDomain.State {
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
        switch route {
            case .main:
                return main.routeName() ?? route.tag.analyticsName
            case .pharmacySearch:
                return pharmacySearch.routeName() ?? route.tag.analyticsName
            case .orders:
                return orders.routeName() ?? route.tag.analyticsName
            case .settings:
                return settingsState.routeName() ?? route.tag.analyticsName
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
        guard let route = route else {
            return nil
        }
        switch route {
            case let .pin(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .egk(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case .scanner:
                return route.tag.analyticsName
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
        guard let route = route else {
            return nil
        }
        switch route {
            case .confirmation:
                return route.tag.analyticsName
            case let .egk(state: state):
                return state.routeName() ?? route.tag.analyticsName
        }
    }
}

extension CardWallIntroductionDomain.State {
    func routeName() -> String? {
        guard let route = route else {
            return nil
        }
        switch route {
            case let .can(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .fasttrack(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .egk(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case .notCapable:
                return route.tag.analyticsName
        }
    }
}

extension CardWallLoginOptionDomain.State {
    func routeName() -> String? {
        guard let route = route else {
            return nil
        }
        switch route {
            case let .alert(.error(error, _)): 
                return error.analyticsName
            case .alert:
                return route.tag.analyticsName
            case let .readcard(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case .warning:
                return route.tag.analyticsName
        }
    }
}

extension CardWallPINDomain.State {
    func routeName() -> String? {
        guard let route = route else {
            return nil
        }
        switch route {
            case let .login(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .egk(state: state):
                return state.routeName() ?? route.tag.analyticsName
        }
    }
}

extension CardWallReadCardDomain.State {
    func routeName() -> String? {
        guard let route = route else {
            return nil
        }
        switch route {
            case let .alert(.error(error, _)): 
                return error.analyticsName
            case .alert:
                return route.tag.analyticsName
            case let .help(state: state):
                return state.routeName() ?? route.tag.analyticsName
        }
    }
}

extension CreatePasswordDomain.State {
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
        guard let route = route else {
            return nil
        }
        switch route {
            case let .alert(.error(error, _)): 
                return error.analyticsName
            case .alert:
                return route.tag.analyticsName
            case .token:
                return route.tag.analyticsName
            case .linkedDevices:
                return route.tag.analyticsName
            case let .auditEvents(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .registeredDevices(state: state):
                return state.routeName() ?? route.tag.analyticsName
        }
    }
}

extension HealthCardPasswordDomain.State {
    func routeName() -> String? {
        switch route {
            case .introduction:
                return route.tag.analyticsName
            case .can:
                return route.tag.analyticsName
            case .puk:
                return route.tag.analyticsName
            case .oldPin:
                return route.tag.analyticsName
            case .pin:
                return route.tag.analyticsName
            case let .readCard(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case .scanner:
                return route.tag.analyticsName
        }
    }
}

extension HealthCardPasswordReadCardDomain.State {
    func routeName() -> String? {
        guard let route = route else {
            return nil
        }
        switch route {
            case let .alert(.error(error, _)): 
                return error.analyticsName
            case .alert:
                return route.tag.analyticsName
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
        guard let route = route else {
            return nil
        }
        switch route {
            case let .addProfile(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case .welcomeDrawer:
                return route.tag.analyticsName
            case let .scanner(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .deviceSecurity(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .cardWall(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .prescriptionArchive(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .prescriptionDetail(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .redeem(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .alert(.error(error, _)): 
                return error.analyticsName
            case .alert:
                return route.tag.analyticsName
        }
    }
}

extension MainViewHintsDomain.State {
    func routeName() -> String? {
            return nil
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

extension OnboardingNewProfileDomain.State {
    func routeName() -> String? {
            return nil
    }
}

extension OrderDetailDomain.State {
    func routeName() -> String? {
        guard let route = route else {
            return nil
        }
        switch route {
            case let .pickupCode(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .prescriptionDetail(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .alert(.error(error, _)): 
                return error.analyticsName
            case .alert:
                return route.tag.analyticsName
        }
    }
}

extension OrderHealthCardDomain.State {
    func routeName() -> String? {
        guard let route = route else {
            return nil
        }
        switch route {
            case .searchPicker:
                return route.tag.analyticsName
            case .serviceInquiry:
                return route.tag.analyticsName
        }
    }
}

extension OrdersDomain.State {
    func routeName() -> String? {
        guard let route = route else {
            return nil
        }
        switch route {
            case let .orderDetail(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case .selectProfile:
                return route.tag.analyticsName
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
        guard let route = route else {
            return nil
        }
        switch route {
            case let .redeemViaAVS(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .redeemViaErxTaskRepository(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case .alert:
                return route.tag.analyticsName
        }
    }
}

extension PharmacyRedeemDomain.State {
    func routeName() -> String? {
        guard let route = route else {
            return nil
        }
        switch route {
            case let .redeemSuccess(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .contact(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .cardWall(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .alert(.error(error, _)): 
                return error.analyticsName
            case .alert:
                return route.tag.analyticsName
        }
    }
}

extension PharmacySearchDomain.State {
    func routeName() -> String? {
        guard let route = route else {
            return nil
        }
        switch route {
            case .selectProfile:
                return route.tag.analyticsName
            case let .pharmacy(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .filter(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .alert(.error(error, _)): 
                return error.analyticsName
            case .alert:
                return route.tag.analyticsName
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
        guard let route = route else {
            return nil
        }
        switch route {
            case let .prescriptionDetail(state: state):
                return state.routeName() ?? route.tag.analyticsName
        }
    }
}

extension PrescriptionDetailDomain.State {
    func routeName() -> String? {
        guard let route = route else {
            return nil
        }
        switch route {
            case let .alert(.error(error, _)): 
                return error.analyticsName
            case .alert:
                return route.tag.analyticsName
            case .sharePrescription:
                return route.tag.analyticsName
            case .directAssignment:
                return route.tag.analyticsName
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
        guard let route = route else {
            return nil
        }
        switch route {
            case let .alert(.error(error, _)): 
                return error.analyticsName
            case .alert:
                return route.tag.analyticsName
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
        guard let route = route else {
            return nil
        }
        switch route {
            case let .editProfile(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .newProfile(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .alert(.error(error, _)): 
                return error.analyticsName
            case .alert:
                return route.tag.analyticsName
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
        guard let route = route else {
            return nil
        }
        switch route {
            case let .matrixCode(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .pharmacySearch(state: state):
                return state.routeName() ?? route.tag.analyticsName
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
        guard let route = route else {
            return nil
        }
        switch route {
            case let .cardWall(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .alert(.error(error, _)): 
                return error.analyticsName
            case .alert:
                return route.tag.analyticsName
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
        guard let route = route else {
            return nil
        }
        switch route {
            case .debug:
                return nil
            case .alert:
                return route.tag.analyticsName
            case let .healthCardPasswordForgotPin(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .healthCardPasswordSetCustomPin(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .healthCardPasswordUnlockCard(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .setAppPassword(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case .complyTracking:
                return route.tag.analyticsName
            case .legalNotice:
                return route.tag.analyticsName
            case .dataProtection:
                return route.tag.analyticsName
            case .openSourceLicence:
                return route.tag.analyticsName
            case .termsOfUse:
                return route.tag.analyticsName
            case let .egk(state: state):
                return state.routeName() ?? route.tag.analyticsName
        }
    }
}


extension AppMigrationDomain.State {
    func routeName() -> String? {
        let route = self
        switch route {
            case .none:
                return route.tag.analyticsName
            case .inProgress:
                return route.tag.analyticsName
            case .finished:
                return route.tag.analyticsName
            case .failed:
                return route.tag.analyticsName
        }
    }
}

extension AppStartDomain.State {
    func routeName() -> String? {
        let route = self
        switch route {
            case .loading:
                return route.tag.analyticsName
            case let .onboarding(state: state):
                return state.routeName() ?? route.tag.analyticsName
            case let .app(state: state):
                return state.routeName() ?? route.tag.analyticsName
        }
    }
}

extension CardWallReadCardHelpDomain.State {
    func routeName() -> String? {
        let route = self
        switch route {
            case .first:
                return route.tag.analyticsName
            case .second:
                return route.tag.analyticsName
            case .third:
                return route.tag.analyticsName
        }
    }
}

extension ExtAuthPendingDomain.State {
    func routeName() -> String? {
        let route = self
        switch route {
            case .empty:
                return route.tag.analyticsName
            case .pendingExtAuth:
                return route.tag.analyticsName
            case .extAuthReceived:
                return route.tag.analyticsName
            case .extAuthSuccessful:
                return route.tag.analyticsName
            case let .extAuthFailed(.error(error, _)): 
                return error.analyticsName
            case .extAuthFailed:
                return route.tag.analyticsName
        }
    }
}



extension AppDomain.Route.Tag {
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
extension CardWallCANDomain.Route.Tag {
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
extension CardWallExtAuthSelectionDomain.Route.Tag {
    var analyticsName: String {
        switch self {
            case .confirmation: 
                return Analytics.Screens.cardWallExtAuthConfirm.name
            case .egk: 
                return "egk"
        }
    }
}
extension CardWallIntroductionDomain.Route.Tag {
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
extension CardWallLoginOptionDomain.Route.Tag {
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
extension CardWallPINDomain.Route.Tag {
    var analyticsName: String {
        switch self {
            case .login: 
                return Analytics.Screens.cardwallSaveLogin.name
            case .egk: 
                return Analytics.Screens.cardwallContactInsuranceCompany.name
        }
    }
}
extension CardWallReadCardDomain.Route.Tag {
    var analyticsName: String {
        switch self {
            case .alert: 
                return "alert"
            case .help: 
                return "help"
        }
    }
}
extension EditProfileDomain.Route.Tag {
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
        }
    }
}
extension HealthCardPasswordDomain.Route.Tag {
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
extension HealthCardPasswordReadCardDomain.Route.Tag {
    var analyticsName: String {
        switch self {
            case .alert: 
                return "alert"
        }
    }
}
extension MainDomain.Route.Tag {
    var analyticsName: String {
        switch self {
            case .addProfile: 
                return "addProfile"
            case .welcomeDrawer: 
                return "welcomeDrawer"
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
            case .alert: 
                return "alert"
        }
    }
}
extension OrderDetailDomain.Route.Tag {
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
extension OrderHealthCardDomain.Route.Tag {
    var analyticsName: String {
        switch self {
            case .searchPicker: 
                return "searchPicker"
            case .serviceInquiry: 
                return "serviceInquiry"
        }
    }
}
extension OrdersDomain.Route.Tag {
    var analyticsName: String {
        switch self {
            case .orderDetail: 
                return "orderDetail"
            case .selectProfile: 
                return "selectProfile"
        }
    }
}
extension PharmacyDetailDomain.Route.Tag {
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
extension PharmacyRedeemDomain.Route.Tag {
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
extension PharmacySearchDomain.Route.Tag {
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
extension PrescriptionArchiveDomain.Route.Tag {
    var analyticsName: String {
        switch self {
            case .prescriptionDetail: 
                return "prescriptionDetail"
        }
    }
}
extension PrescriptionDetailDomain.Route.Tag {
    var analyticsName: String {
        switch self {
            case .alert: 
                return "alert"
            case .sharePrescription: 
                return "sharePrescription"
            case .directAssignment: 
                return "directAssignment"
        }
    }
}
extension ProfileSelectionDomain.Route.Tag {
    var analyticsName: String {
        switch self {
            case .alert: 
                return "alert"
        }
    }
}
extension ProfilesDomain.Route.Tag {
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
extension RedeemMethodsDomain.Route.Tag {
    var analyticsName: String {
        switch self {
            case .matrixCode: 
                return "matrixCode"
            case .pharmacySearch: 
                return "pharmacySearch"
        }
    }
}
extension RegisteredDevicesDomain.Route.Tag {
    var analyticsName: String {
        switch self {
            case .cardWall: 
                return "cardWall"
            case .alert: 
                return "alert"
        }
    }
}
extension SettingsDomain.Route.Tag {
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
