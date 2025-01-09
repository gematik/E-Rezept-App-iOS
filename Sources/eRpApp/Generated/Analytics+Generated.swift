// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

protocol AnalyticsScreen {
    var name: String { get }
}
typealias AnalyticsEvent = String

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - YAML Files












// swiftlint:disable identifier_name line_length number_separator type_body_length
 enum Analytics {
  enum Screens {
    static let alert = Alert()
    struct Alert: AnalyticsScreen {
      let name = "General Alert Dialog"
    }
    static let cardWall = CardWall()
    struct CardWall: AnalyticsScreen {
      let name = "cardWall"
    }
    static let cardWall_CAN = CardWall_CAN()
    struct CardWall_CAN: AnalyticsScreen {
      let name = "cardWall:CAN"
    }
    static let cardWall_PIN = CardWall_PIN()
    struct CardWall_PIN: AnalyticsScreen {
      let name = "cardWall:PIN"
    }
    static let cardWall_extAuth = CardWall_extAuth()
    struct CardWall_extAuth: AnalyticsScreen {
      let name = "cardWall:extAuth"
    }
    static let cardWall_extAuthConfirm = CardWall_extAuthConfirm()
    struct CardWall_extAuthConfirm: AnalyticsScreen {
      let name = "cardWall:extAuthConfirm"
    }
    static let cardWall_extAuthSelectionHelp = CardWall_extAuthSelectionHelp()
    struct CardWall_extAuthSelectionHelp: AnalyticsScreen {
      let name = "cardWall:extAuthSelectionHelp"
    }
    static let cardWall_introduction = CardWall_introduction()
    struct CardWall_introduction: AnalyticsScreen {
      let name = "cardWall:welcome"
    }
    static let cardWall_notCapable = CardWall_notCapable()
    struct CardWall_notCapable: AnalyticsScreen {
      let name = "cardWall:notCapable"
    }
    static let cardWall_readCard = CardWall_readCard()
    struct CardWall_readCard: AnalyticsScreen {
      let name = "cardWall:connect"
    }
    static let cardWall_saveLogin = CardWall_saveLogin()
    struct CardWall_saveLogin: AnalyticsScreen {
      let name = "cardWall:saveCredentials:initial"
    }
    static let cardWall_saveLoginSecurityInfo = CardWall_saveLoginSecurityInfo()
    struct CardWall_saveLoginSecurityInfo: AnalyticsScreen {
      let name = "cardWall:saveCredentials:information"
    }
    static let cardWall_scanCAN = CardWall_scanCAN()
    struct CardWall_scanCAN: AnalyticsScreen {
      let name = "cardWall:scanCAN"
    }
    static let chargeItemDetails = ChargeItemDetails()
    struct ChargeItemDetails: AnalyticsScreen {
      let name = "chargeItemDetails"
    }
    static let chargeItemList = ChargeItemList()
    struct ChargeItemList: AnalyticsScreen {
      let name = "chargeItemList"
    }
    static let chargeItemList_toast = ChargeItemList_toast()
    struct ChargeItemList_toast: AnalyticsScreen {
      let name = "chargeItemList:toast"
    }
    static let contactInsuranceCompany = ContactInsuranceCompany()
    struct ContactInsuranceCompany: AnalyticsScreen {
      let name = "contactInsuranceCompany"
    }
    static let contactInsuranceCompany_selectKK = ContactInsuranceCompany_selectKK()
    struct ContactInsuranceCompany_selectKK: AnalyticsScreen {
      let name = "contactInsuranceCompany:selectKK"
    }
    static let contactInsuranceCompany_selectMethod = ContactInsuranceCompany_selectMethod()
    struct ContactInsuranceCompany_selectMethod: AnalyticsScreen {
      let name = "contactInsuranceCompany:selectMethod"
    }
    static let contactInsuranceCompany_selectReason = ContactInsuranceCompany_selectReason()
    struct ContactInsuranceCompany_selectReason: AnalyticsScreen {
      let name = "contactInsuranceCompany:selectReason"
    }
    static let errorAlert = ErrorAlert()
    struct ErrorAlert: AnalyticsScreen {
      let name = "Error Alert"
    }
    static let healthCardPassword_can = HealthCardPassword_can()
    struct HealthCardPassword_can: AnalyticsScreen {
      let name = "healthCardPassword:can"
    }
    static let healthCardPassword_forgotPin = HealthCardPassword_forgotPin()
    struct HealthCardPassword_forgotPin: AnalyticsScreen {
      let name = "healthCardPassword:forgotPin"
    }
    static let healthCardPassword_introduction = HealthCardPassword_introduction()
    struct HealthCardPassword_introduction: AnalyticsScreen {
      let name = "healthCardPassword:introduction"
    }
    static let healthCardPassword_oldPin = HealthCardPassword_oldPin()
    struct HealthCardPassword_oldPin: AnalyticsScreen {
      let name = "healthCardPassword:oldPin"
    }
    static let healthCardPassword_pin = HealthCardPassword_pin()
    struct HealthCardPassword_pin: AnalyticsScreen {
      let name = "healthCardPassword:pin"
    }
    static let healthCardPassword_pin_alert = HealthCardPassword_pin_alert()
    struct HealthCardPassword_pin_alert: AnalyticsScreen {
      let name = "healthCardPassword:pinAlert"
    }
    static let healthCardPassword_puk = HealthCardPassword_puk()
    struct HealthCardPassword_puk: AnalyticsScreen {
      let name = "healthCardPassword:puk"
    }
    static let healthCardPassword_readCard = HealthCardPassword_readCard()
    struct HealthCardPassword_readCard: AnalyticsScreen {
      let name = "healthCardPassword:readCard"
    }
    static let healthCardPassword_scanner = HealthCardPassword_scanner()
    struct HealthCardPassword_scanner: AnalyticsScreen {
      let name = "healthCardPassword:scanner"
    }
    static let healthCardPassword_setCustomPin = HealthCardPassword_setCustomPin()
    struct HealthCardPassword_setCustomPin: AnalyticsScreen {
      let name = "healthCardPassword:setCustomPin"
    }
    static let healthCardPassword_unlockCard = HealthCardPassword_unlockCard()
    struct HealthCardPassword_unlockCard: AnalyticsScreen {
      let name = "healthCardPassword:unlockCard"
    }
    static let main = Main()
    struct Main: AnalyticsScreen {
      let name = "main"
    }
    static let main_consentDrawer = Main_consentDrawer()
    struct Main_consentDrawer: AnalyticsScreen {
      let name = "main:consentDrawer"
    }
    static let main_createProfile = Main_createProfile()
    struct Main_createProfile: AnalyticsScreen {
      let name = "main:createProfile"
    }
    static let main_deviceSecurity = Main_deviceSecurity()
    struct Main_deviceSecurity: AnalyticsScreen {
      let name = "main:deviceSecurity"
    }
    static let main_editName = Main_editName()
    struct Main_editName: AnalyticsScreen {
      let name = "main:editName"
    }
    static let main_editProfilePicture = Main_editProfilePicture()
    struct Main_editProfilePicture: AnalyticsScreen {
      let name = "main:editProfilePicture"
    }
    static let main_medicationReminder = Main_medicationReminder()
    struct Main_medicationReminder: AnalyticsScreen {
      let name = "main:medicationReminder"
    }
    static let main_prescriptionArchive = Main_prescriptionArchive()
    struct Main_prescriptionArchive: AnalyticsScreen {
      let name = "main:prescriptionArchive"
    }
    static let main_scanner = Main_scanner()
    struct Main_scanner: AnalyticsScreen {
      let name = "main:scanner"
    }
    static let main_welcomeDrawer = Main_welcomeDrawer()
    struct Main_welcomeDrawer: AnalyticsScreen {
      let name = "main:welcomeDrawer"
    }
    static let matrixCode_sharePrescription = MatrixCode_sharePrescription()
    struct MatrixCode_sharePrescription: AnalyticsScreen {
      let name = "matrixCode:sharePrescription"
    }
    static let medicationReminder_dosageInstruction = MedicationReminder_dosageInstruction()
    struct MedicationReminder_dosageInstruction: AnalyticsScreen {
      let name = "medicationReminder:dosageInstructionsInfo"
    }
    static let medicationReminder_repetitionDetails = MedicationReminder_repetitionDetails()
    struct MedicationReminder_repetitionDetails: AnalyticsScreen {
      let name = "medicationReminder:repetitionDetails"
    }
    static let mlKit = MlKit()
    struct MlKit: AnalyticsScreen {
      let name = "mlKit"
    }
    static let mlKit_information = MlKit_information()
    struct MlKit_information: AnalyticsScreen {
      let name = "mlKit:information"
    }
    static let orders = Orders()
    struct Orders: AnalyticsScreen {
      let name = "orders"
    }
    static let orders_detail = Orders_detail()
    struct Orders_detail: AnalyticsScreen {
      let name = "orders:detail"
    }
    static let orders_pharmacyDetail = Orders_pharmacyDetail()
    struct Orders_pharmacyDetail: AnalyticsScreen {
      let name = "orders:pharmacyDetail"
    }
    static let orders_pickupCode = Orders_pickupCode()
    struct Orders_pickupCode: AnalyticsScreen {
      let name = "orders:pickupCode"
    }
    static let pharmacySearch = PharmacySearch()
    struct PharmacySearch: AnalyticsScreen {
      let name = "pharmacySearch"
    }
    static let pharmacySearch_clusterAnnotation = PharmacySearch_clusterAnnotation()
    struct PharmacySearch_clusterAnnotation: AnalyticsScreen {
      let name = "pharmacySearch:clusterAnnotation"
    }
    static let pharmacySearch_detail = PharmacySearch_detail()
    struct PharmacySearch_detail: AnalyticsScreen {
      let name = "pharmacySearch:detail"
    }
    static let pharmacySearch_filter = PharmacySearch_filter()
    struct PharmacySearch_filter: AnalyticsScreen {
      let name = "pharmacySearch:filter"
    }
    static let pharmacySearch_map = PharmacySearch_map()
    struct PharmacySearch_map: AnalyticsScreen {
      let name = "pharmacySearch:map"
    }
    static let prescriptionDetail = PrescriptionDetail()
    struct PrescriptionDetail: AnalyticsScreen {
      let name = "prescriptionDetail"
    }
    static let prescriptionDetail_accidentInfo = PrescriptionDetail_accidentInfo()
    struct PrescriptionDetail_accidentInfo: AnalyticsScreen {
      let name = "prescriptionDetail:accidentInfo"
    }
    static let prescriptionDetail_coPaymentInfo = PrescriptionDetail_coPaymentInfo()
    struct PrescriptionDetail_coPaymentInfo: AnalyticsScreen {
      let name = "prescriptionDetail:coPaymentInfo"
    }
    static let prescriptionDetail_directAssignmentInfo = PrescriptionDetail_directAssignmentInfo()
    struct PrescriptionDetail_directAssignmentInfo: AnalyticsScreen {
      let name = "prescriptionDetail:directAssignmentInfo"
    }
    static let prescriptionDetail_dosageInstructionsInfo = PrescriptionDetail_dosageInstructionsInfo()
    struct PrescriptionDetail_dosageInstructionsInfo: AnalyticsScreen {
      let name = "prescriptionDetail:dosageInstructionsInfo"
    }
    static let prescriptionDetail_emergencyServiceFeeInfo = PrescriptionDetail_emergencyServiceFeeInfo()
    struct PrescriptionDetail_emergencyServiceFeeInfo: AnalyticsScreen {
      let name = "prescriptionDetail:emergencyServiceFeeInfo"
    }
    static let prescriptionDetail_epaMedication = PrescriptionDetail_epaMedication()
    struct PrescriptionDetail_epaMedication: AnalyticsScreen {
      let name = "prescriptionDetail:epaMedication"
    }
    static let prescriptionDetail_epa_medication_codable_ingredient = PrescriptionDetail_epa_medication_codable_ingredient()
    struct PrescriptionDetail_epa_medication_codable_ingredient: AnalyticsScreen {
      let name = "prescriptionDetail:epa_medication_codable_ingredient"
    }
    static let prescriptionDetail_epa_medication_ingredient = PrescriptionDetail_epa_medication_ingredient()
    struct PrescriptionDetail_epa_medication_ingredient: AnalyticsScreen {
      let name = "prescriptionDetail:epa_medication_ingredient"
    }
    static let prescriptionDetail_errorInfo = PrescriptionDetail_errorInfo()
    struct PrescriptionDetail_errorInfo: AnalyticsScreen {
      let name = "prescriptionDetail:errorInfo"
    }
    static let prescriptionDetail_matrixCode = PrescriptionDetail_matrixCode()
    struct PrescriptionDetail_matrixCode: AnalyticsScreen {
      let name = "prescriptionDetail:matrixCode"
    }
    static let prescriptionDetail_medication = PrescriptionDetail_medication()
    struct PrescriptionDetail_medication: AnalyticsScreen {
      let name = "prescriptionDetail:medication"
    }
    static let prescriptionDetail_medicationOverview = PrescriptionDetail_medicationOverview()
    struct PrescriptionDetail_medicationOverview: AnalyticsScreen {
      let name = "prescriptionDetail:medicationOverview"
    }
    static let prescriptionDetail_medication_ingredients = PrescriptionDetail_medication_ingredients()
    struct PrescriptionDetail_medication_ingredients: AnalyticsScreen {
      let name = "prescriptionDetail:medication_ingredients"
    }
    static let prescriptionDetail_organization = PrescriptionDetail_organization()
    struct PrescriptionDetail_organization: AnalyticsScreen {
      let name = "prescriptionDetail:organization"
    }
    static let prescriptionDetail_patient = PrescriptionDetail_patient()
    struct PrescriptionDetail_patient: AnalyticsScreen {
      let name = "prescriptionDetail:patient"
    }
    static let prescriptionDetail_practitioner = PrescriptionDetail_practitioner()
    struct PrescriptionDetail_practitioner: AnalyticsScreen {
      let name = "prescriptionDetail:practitioner"
    }
    static let prescriptionDetail_prescriptionValidityInfo = PrescriptionDetail_prescriptionValidityInfo()
    struct PrescriptionDetail_prescriptionValidityInfo: AnalyticsScreen {
      let name = "prescriptionDetail:prescriptionValidityInfo"
    }
    static let prescriptionDetail_scannedPrescriptionInfo = PrescriptionDetail_scannedPrescriptionInfo()
    struct PrescriptionDetail_scannedPrescriptionInfo: AnalyticsScreen {
      let name = "prescriptionDetail:scannedPrescriptionInfo"
    }
    static let prescriptionDetail_selfPayerPrescriptionBottomSheet = PrescriptionDetail_selfPayerPrescriptionBottomSheet()
    struct PrescriptionDetail_selfPayerPrescriptionBottomSheet: AnalyticsScreen {
      let name = "prescriptionDetail:selfPayerPrescriptionBottomSheet"
    }
    static let prescriptionDetail_setupMedicationSchedule = PrescriptionDetail_setupMedicationSchedule()
    struct PrescriptionDetail_setupMedicationSchedule: AnalyticsScreen {
      let name = "prescriptionDetail:setupMedicationSchedule"
    }
    static let prescriptionDetail_sharePrescription = PrescriptionDetail_sharePrescription()
    struct PrescriptionDetail_sharePrescription: AnalyticsScreen {
      let name = "prescriptionDetail:sharePrescription"
    }
    static let prescriptionDetail_substitutionInfo = PrescriptionDetail_substitutionInfo()
    struct PrescriptionDetail_substitutionInfo: AnalyticsScreen {
      let name = "prescriptionDetail:substitutionInfo"
    }
    static let prescriptionDetail_technicalInfo = PrescriptionDetail_technicalInfo()
    struct PrescriptionDetail_technicalInfo: AnalyticsScreen {
      let name = "prescriptionDetail:technicalInfo"
    }
    static let prescriptionDetail_toast = PrescriptionDetail_toast()
    struct PrescriptionDetail_toast: AnalyticsScreen {
      let name = "prescriptionDetail:toast"
    }
    static let profile = Profile()
    struct Profile: AnalyticsScreen {
      let name = "profile"
    }
    static let profile_auditEvents = Profile_auditEvents()
    struct Profile_auditEvents: AnalyticsScreen {
      let name = "profile:auditEvents"
    }
    static let profile_editPicture = Profile_editPicture()
    struct Profile_editPicture: AnalyticsScreen {
      let name = "profile:editPicture"
    }
    static let profile_registeredDevices = Profile_registeredDevices()
    struct Profile_registeredDevices: AnalyticsScreen {
      let name = "profile:registeredDevices"
    }
    static let profile_token = Profile_token()
    struct Profile_token: AnalyticsScreen {
      let name = "profile:token"
    }
    static let redeem_editContactInformation = Redeem_editContactInformation()
    struct Redeem_editContactInformation: AnalyticsScreen {
      let name = "redeem:editContactInformation"
    }
    static let redeem_matrixCode = Redeem_matrixCode()
    struct Redeem_matrixCode: AnalyticsScreen {
      let name = "redeem:matrixCode"
    }
    static let redeem_methodSelection = Redeem_methodSelection()
    struct Redeem_methodSelection: AnalyticsScreen {
      let name = "redeem:methodSelection"
    }
    static let redeem_prescriptionAllOrSelection = Redeem_prescriptionAllOrSelection()
    struct Redeem_prescriptionAllOrSelection: AnalyticsScreen {
      let name = "redeem:prescriptionAllOrSelection"
    }
    static let redeem_prescriptionChooseSubset = Redeem_prescriptionChooseSubset()
    struct Redeem_prescriptionChooseSubset: AnalyticsScreen {
      let name = "redeem:prescriptionChooseSubset"
    }
    static let redeem_prescriptionSelection = Redeem_prescriptionSelection()
    struct Redeem_prescriptionSelection: AnalyticsScreen {
      let name = "redeem:prescriptionSelection"
    }
    static let redeem_success = Redeem_success()
    struct Redeem_success: AnalyticsScreen {
      let name = "redeem:success"
    }
    static let redeem_viaAVS = Redeem_viaAVS()
    struct Redeem_viaAVS: AnalyticsScreen {
      let name = "redeem:viaAVS"
    }
    static let redeem_viaTI = Redeem_viaTI()
    struct Redeem_viaTI: AnalyticsScreen {
      let name = "redeem:viaTI"
    }
    static let scanner_documentImporter = Scanner_documentImporter()
    struct Scanner_documentImporter: AnalyticsScreen {
      let name = "scanner:documentImporter"
    }
    static let scanner_imageGallery = Scanner_imageGallery()
    struct Scanner_imageGallery: AnalyticsScreen {
      let name = "scanner:imageGallery"
    }
    static let settings = Settings()
    struct Settings: AnalyticsScreen {
      let name = "settings"
    }
    static let settings_accessibility = Settings_accessibility()
    struct Settings_accessibility: AnalyticsScreen {
      let name = "settings:accessibility"
    }
    static let settings_additionalLicence = Settings_additionalLicence()
    struct Settings_additionalLicence: AnalyticsScreen {
      let name = "settings:additionalLicence"
    }
    static let settings_authenticationMethods = Settings_authenticationMethods()
    struct Settings_authenticationMethods: AnalyticsScreen {
      let name = "settings:authenticationMethods"
    }
    static let settings_authenticationMethods_setAppPassword = Settings_authenticationMethods_setAppPassword()
    struct Settings_authenticationMethods_setAppPassword: AnalyticsScreen {
      let name = "settings:authenticationMethods:setAppPassword"
    }
    static let settings_dataProtection = Settings_dataProtection()
    struct Settings_dataProtection: AnalyticsScreen {
      let name = "settings:dataProtection"
    }
    static let settings_legalNotice = Settings_legalNotice()
    struct Settings_legalNotice: AnalyticsScreen {
      let name = "settings:legalNotice"
    }
    static let settings_medicationReminderList = Settings_medicationReminderList()
    struct Settings_medicationReminderList: AnalyticsScreen {
      let name = "settings:medicationReminderList"
    }
    static let settings_newProfile = Settings_newProfile()
    struct Settings_newProfile: AnalyticsScreen {
      let name = "settings:newProfile"
    }
    static let settings_openSourceLicence = Settings_openSourceLicence()
    struct Settings_openSourceLicence: AnalyticsScreen {
      let name = "settings:openSourceLicence"
    }
    static let settings_productImprovements = Settings_productImprovements()
    struct Settings_productImprovements: AnalyticsScreen {
      let name = "settings:productImprovements"
    }
    static let settings_productImprovements_complyTracking = Settings_productImprovements_complyTracking()
    struct Settings_productImprovements_complyTracking: AnalyticsScreen {
      let name = "settings:productImprovements:complyTracking"
    }
    static let settings_termsOfUse = Settings_termsOfUse()
    struct Settings_termsOfUse: AnalyticsScreen {
      let name = "settings:termsOfUse"
    }
    static let troubleShooting = TroubleShooting()
    struct TroubleShooting: AnalyticsScreen {
      let name = "troubleShooting"
    }
    static let troubleShooting_readCardHelp1 = TroubleShooting_readCardHelp1()
    struct TroubleShooting_readCardHelp1: AnalyticsScreen {
      let name = "troubleShooting:readCardHelp1"
    }
    static let troubleShooting_readCardHelp2 = TroubleShooting_readCardHelp2()
    struct TroubleShooting_readCardHelp2: AnalyticsScreen {
      let name = "troubleShooting:readCardHelp2"
    }
    static let troubleShooting_readCardHelp3 = TroubleShooting_readCardHelp3()
    struct TroubleShooting_readCardHelp3: AnalyticsScreen {
      let name = "troubleShooting:readCardHelp3"
    }
    static let troubleShooting_readCardHelp4 = TroubleShooting_readCardHelp4()
    struct TroubleShooting_readCardHelp4: AnalyticsScreen {
      let name = "troubleShooting:readCardHelp4"
    }
  }
}
// swiftlint:enable identifier_name line_length number_separator type_body_length
