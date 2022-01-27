// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import SwiftUI

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable function_parameter_count identifier_name line_length type_body_length
internal enum L10n {
  /// E-Rezept
  internal static let cfBundleDisplayName = LocalizedStringKey("CFBundleDisplayName")
  /// Allows you to identify and authenticate yourself by using your health insurance card
  internal static let nfcReaderUsageDescription = LocalizedStringKey("NFCReaderUsageDescription")
  /// E-Rezept needs access to your camera so that it can read your prescriptions
  internal static let nsCameraUsageDescription = LocalizedStringKey("NSCameraUsageDescription")
  /// E-Rezept uses FaceID to protect your app from unauthorized access.
  internal static let nsFaceIDUsageDescription = LocalizedStringKey("NSFaceIDUsageDescription")
  /// Reject
  internal static let alertBtnClose = LocalizedStringKey("alert_btn_close")
  /// OK
  internal static let alertBtnOk = LocalizedStringKey("alert_btn_ok")
  /// Unknown
  internal static let alertErrorMessageUnknown = LocalizedStringKey("alert_error_message_unknown")
  /// Error
  internal static let alertErrorTitle = LocalizedStringKey("alert_error_title")
  /// Abbrechen
  internal static let amgBtnAlertCancel = LocalizedStringKey("amg_btn_alert_cancel")
  /// Daten löschen
  internal static let amgBtnAlertDeleteDatabase = LocalizedStringKey("amg_btn_alert_delete_database")
  /// Wiederholen
  internal static let amgBtnAlertRetry = LocalizedStringKey("amg_btn_alert_retry")
  /// Aktualisierung fehlgeschlagen
  internal static let amgBtnAlertTitle = LocalizedStringKey("amg_btn_alert_title")
  /// Falls dieser Fehler wiederholt auftritt, bitte die App löschen und neu installieren
  internal static let amgTxtAlertMessageDeleteDatabase = LocalizedStringKey("amg_txt_alert_message_delete_database")
  /// Löschen fehlgeschlagen
  internal static let amgTxtAlertTitleDeleteDatabase = LocalizedStringKey("amg_txt_alert_title_delete_database")
  /// Aktualisieren...
  internal static let amgTxtInProgress = LocalizedStringKey("amg_txt_in_progress")
  /// Unlock with Face ID
  internal static let authBtnBiometricsFaceid = LocalizedStringKey("auth_btn_biometrics_faceid")
  /// Unlock with Touch ID
  internal static let authBtnBiometricsTouchid = LocalizedStringKey("auth_btn_biometrics_touchid")
  /// Weiter
  internal static let authBtnPasswordContinue = LocalizedStringKey("auth_btn_password_continue")
  /// You have selected Face ID to secure your data.
  internal static let authTxtBiometricsFaceidDescription = LocalizedStringKey("auth_txt_biometrics_faceid_description")
  /// Unlock with Face ID
  internal static let authTxtBiometricsFaceidStart = LocalizedStringKey("auth_txt_biometrics_faceid_start")
  /// Authentication failed
  internal static let authTxtBiometricsFailedAuthenticationFailed = LocalizedStringKey("auth_txt_biometrics_failed_authentication_failed")
  /// Login failed
  internal static let authTxtBiometricsFailedDefault = LocalizedStringKey("auth_txt_biometrics_failed_default")
  /// No biometric security has been set up on this device.
  internal static let authTxtBiometricsFailedNotEnrolled = LocalizedStringKey("auth_txt_biometrics_failed_not_enrolled")
  /// An alternative login method is not supported.
  internal static let authTxtBiometricsFailedUserFallback = LocalizedStringKey("auth_txt_biometrics_failed_user_fallback")
  /// Do you have any questions or problems concerning use of the app? You can contact our technical hotline on 0800 277 377 7. \n\nWe have already answered plenty of questions for you at das-e-rezept-fuer-deutschland.de.
  internal static let authTxtBiometricsFooter = LocalizedStringKey("auth_txt_biometrics_footer")
  /// app-feedback@gematik.de
  internal static let authTxtBiometricsFooterEmailDisplay = LocalizedStringKey("auth_txt_biometrics_footer_email_display")
  /// mailto:app-feedback@gematik.de
  internal static let authTxtBiometricsFooterEmailLink = LocalizedStringKey("auth_txt_biometrics_footer_email_link")
  /// das-e-rezept-fuer-deutschland.de
  internal static let authTxtBiometricsFooterUrlDisplay = LocalizedStringKey("auth_txt_biometrics_footer_url_display")
  /// https://www.das-e-rezept-fuer-deutschland.de
  internal static let authTxtBiometricsFooterUrlLink = LocalizedStringKey("auth_txt_biometrics_footer_url_link")
  /// Sie hatten zu viele fehlerhafte Anmeldeversuche. Gehen Sie in die Einstellungen ihres iPhones und reaktivieren sie die FaceID oder TouchID Funktion durch eine PIN Eingabe.
  internal static let authTxtBiometricsLockout = LocalizedStringKey("auth_txt_biometrics_lockout")
  /// %@ is required to protect the app from unauthorised access.
  internal static let authTxtBiometricsReason = LocalizedStringKey("auth_txt_biometrics_reason")
  /// Welcome
  internal static let authTxtBiometricsTitle = LocalizedStringKey("auth_txt_biometrics_title")
  /// You have selected Touch ID to secure your data.
  internal static let authTxtBiometricsTouchidDescription = LocalizedStringKey("auth_txt_biometrics_touchid_description")
  /// Unlock with Touch ID
  internal static let authTxtBiometricsTouchidStart = LocalizedStringKey("auth_txt_biometrics_touchid_start")
  /// Plural format key: "%#@variable_0@"
  internal static let authTxtFailedLoginHintMsg = LocalizedStringKey("auth_txt_failed_login_hint_msg")
  /// Erfolglose Anmeldeversuche
  internal static let authTxtFailedLoginHintTitle = LocalizedStringKey("auth_txt_failed_login_hint_title")
  /// Falsches Kennwort. Bitte probieren Sie es erneut.
  internal static let authTxtPasswordFailure = LocalizedStringKey("auth_txt_password_failure")
  /// Eingabefeld Kennwort
  internal static let authTxtPasswordLabel = LocalizedStringKey("auth_txt_password_label")
  /// Kennwort eingeben
  internal static let authTxtPasswordPlaceholder = LocalizedStringKey("auth_txt_password_placeholder")
  /// Demo mode enabled
  internal static let bnrTxtDemoMode = LocalizedStringKey("bnr_txt_demo_mode")
  /// inaktiv
  internal static let buttonTxtIsInactiveValue = LocalizedStringKey("button_txt_is_inactive_value")
  /// To use the scanner, you must allow the app to access your camera in the system settings.
  internal static let camInitFailMessage = LocalizedStringKey("cam_init_fail_message")
  /// Access to camera denied
  internal static let camInitFailTitle = LocalizedStringKey("cam_init_fail_title")
  /// Allow
  internal static let camPermDenyBtnSettings = LocalizedStringKey("cam_perm_deny_btn_settings")
  /// The app must be able to access the device camera in order to use the scanner.
  internal static let camPermDenyMessage = LocalizedStringKey("cam_perm_deny_message")
  /// Allow access to camera?
  internal static let camPermDenyTitle = LocalizedStringKey("cam_perm_deny_title")
  /// OK
  internal static let camTxtWarnCancel = LocalizedStringKey("cam_txt_warn_cancel")
  /// Cancel scanning?
  internal static let camTxtWarnCancelTitle = LocalizedStringKey("cam_txt_warn_cancel_title")
  /// Don't cancel
  internal static let camTxtWarnContinue = LocalizedStringKey("cam_txt_warn_continue")
  /// Close dialog
  internal static let cdwBtnBiometryCancelLabel = LocalizedStringKey("cdw_btn_biometry_cancel_label")
  /// Next
  internal static let cdwBtnBiometryContinue = LocalizedStringKey("cdw_btn_biometry_continue")
  /// Next
  internal static let cdwBtnBiometryContinueLabel = LocalizedStringKey("cdw_btn_biometry_continue_label")
  /// Agreed
  internal static let cdwBtnBiometrySecurityWarningAccept = LocalizedStringKey("cdw_btn_biometry_security_warning_accept")
  /// Cancel
  internal static let cdwBtnCanCancelLabel = LocalizedStringKey("cdw_btn_can_cancel_label")
  /// Next
  internal static let cdwBtnCanDone = LocalizedStringKey("cdw_btn_can_done")
  /// Next
  internal static let cdwBtnCanDoneLabel = LocalizedStringKey("cdw_btn_can_done_label")
  /// The access number consists of 6 digits; you have entered %@.
  internal static func cdwBtnCanDoneLabelError(_ element1: String) -> LocalizedStringKey {
    LocalizedStringKey("cdw_btn_can_done_label_error_\(element1)")
  }
  /// Schließen
  internal static let cdwBtnExtauthAlertSaveProfile = LocalizedStringKey("cdw_btn_extauth_alert_save_profile")
  /// Abbrechen
  internal static let cdwBtnExtauthConfirmCancel = LocalizedStringKey("cdw_btn_extauth_confirm_cancel")
  /// Technischen Kundendienst kontaktieren
  internal static let cdwBtnExtauthConfirmContact = LocalizedStringKey("cdw_btn_extauth_confirm_contact")
  /// Senden
  internal static let cdwBtnExtauthConfirmSend = LocalizedStringKey("cdw_btn_extauth_confirm_send")
  /// Gesundheitskarte bestellen
  internal static let cdwBtnExtauthFallbackOrderEgk = LocalizedStringKey("cdw_btn_extauth_fallback_order_egk")
  /// Abbrechen
  internal static let cdwBtnExtauthSelectionCancel = LocalizedStringKey("cdw_btn_extauth_selection_cancel")
  /// Weiter
  internal static let cdwBtnExtauthSelectionContinue = LocalizedStringKey("cdw_btn_extauth_selection_continue")
  /// Gesundheitskarte bestellen
  internal static let cdwBtnExtauthSelectionOrderEgk = LocalizedStringKey("cdw_btn_extauth_selection_order_egk")
  /// Erneut versuchen
  internal static let cdwBtnExtauthSelectionRetry = LocalizedStringKey("cdw_btn_extauth_selection_retry")
  /// Close dialog
  internal static let cdwBtnIntroCancelLabel = LocalizedStringKey("cdw_btn_intro_cancel_label")
  /// Find out more
  internal static let cdwBtnIntroMore = LocalizedStringKey("cdw_btn_intro_more")
  /// Let's get started
  internal static let cdwBtnIntroNext = LocalizedStringKey("cdw_btn_intro_next")
  /// Close dialog
  internal static let cdwBtnNfuCancelLabel = LocalizedStringKey("cdw_btn_nfu_cancel_label")
  /// Back to the homepage
  internal static let cdwBtnNfuDone = LocalizedStringKey("cdw_btn_nfu_done")
  /// Find out more
  internal static let cdwBtnNfuMore = LocalizedStringKey("cdw_btn_nfu_more")
  /// Cancel
  internal static let cdwBtnPinCancelLabel = LocalizedStringKey("cdw_btn_pin_cancel_label")
  /// Next
  internal static let cdwBtnPinDone = LocalizedStringKey("cdw_btn_pin_done")
  /// Next
  internal static let cdwBtnPinDoneLabel = LocalizedStringKey("cdw_btn_pin_done_label")
  /// Schließen
  internal static let cdwBtnRcAlertSaveProfile = LocalizedStringKey("cdw_btn_rc_alert_save_profile")
  /// Close dialog
  internal static let cdwBtnRcCancelLabel = LocalizedStringKey("cdw_btn_rc_cancel_label")
  /// Close
  internal static let cdwBtnRcClose = LocalizedStringKey("cdw_btn_rc_close")
  /// Enter correct access number
  internal static let cdwBtnRcCorrectCan = LocalizedStringKey("cdw_btn_rc_correct_can")
  /// Enter correct PIN
  internal static let cdwBtnRcCorrectPin = LocalizedStringKey("cdw_btn_rc_correct_pin")
  /// Loading
  internal static let cdwBtnRcLoading = LocalizedStringKey("cdw_btn_rc_loading")
  /// Next
  internal static let cdwBtnRcNext = LocalizedStringKey("cdw_btn_rc_next")
  /// As soon as this button is pressed, the medical card is read via NFC. To do this, hold the card directly against the device. If the connection is successful, you will receive tactile feedback. Any interruptions to the connection or errors are also communicated via tactile feedback. Communication with the medical card can take up to ten seconds. Then remove the medical card from the device.
  internal static let cdwBtnRcNextHint = LocalizedStringKey("cdw_btn_rc_next_hint")
  /// Repeat
  internal static let cdwBtnRcRetry = LocalizedStringKey("cdw_btn_rc_retry")
  /// Weiter
  internal static let cdwBtnSelContinue = LocalizedStringKey("cdw_btn_sel_continue")
  /// Please enter your PIN here
  internal static let cdwEdtPinInput = LocalizedStringKey("cdw_edt_pin_input")
  /// Find out more
  internal static let cdwHintCanOrderEgkBtn = LocalizedStringKey("cdw_hint_can_order_egk_btn")
  /// Your health insurance company will be able to help you with this.
  internal static let cdwHintCanOrderEgkMessage = LocalizedStringKey("cdw_hint_can_order_egk_message")
  /// How do I get a new medical card?
  internal static let cdwHintCanOrderEgkTitle = LocalizedStringKey("cdw_hint_can_order_egk_title")
  /// Find out more
  internal static let cdwHintPinBtn = LocalizedStringKey("cdw_hint_pin_btn")
  /// You will receive a PIN for your medical card from your health insurance company.
  internal static let cdwHintPinMsg = LocalizedStringKey("cdw_hint_pin_msg")
  /// How do I get a PIN?
  internal static let cdwHintPinTitle = LocalizedStringKey("cdw_hint_pin_title")
  /// Illustration einer Gesundheitskarte. Die Zugangsnummer finden Sie rechts oben auf der Vorderseite der Gesundheitskarte.
  internal static let cdwImgCanCardLabel = LocalizedStringKey("cdw_img_can_card_label")
  /// Illustration of a user holding their medical card to the back of their smartphone.
  internal static let cdwImgIntroMainLabel = LocalizedStringKey("cdw_img_intro_main_label")
  /// Your selection will not be saved.
  internal static let cdwTxtBiometryDemoModeInfo = LocalizedStringKey("cdw_txt_biometry_demo_mode_info")
  /// Log in conveniently with fingerprint or face scan
  internal static let cdwTxtBiometryOptionBiometryDescription = LocalizedStringKey("cdw_txt_biometry_option_biometry_description")
  /// Save login details
  internal static let cdwTxtBiometryOptionBiometryTitle = LocalizedStringKey("cdw_txt_biometry_option_biometry_title")
  /// Requires you to enter your login details each time you launch the app
  internal static let cdwTxtBiometryOptionNoneDescription = LocalizedStringKey("cdw_txt_biometry_option_none_description")
  /// Do not save login details
  internal static let cdwTxtBiometryOptionNoneTitle = LocalizedStringKey("cdw_txt_biometry_option_none_title")
  /// This app uses Face ID or Touch ID to store your login data in a protected area of the device memory.\n\nAvoid installation on the following devices:\n* Devices on which a so-called "jailbreak" has been carried out.\n* Work devices with administration rights by the employer (COPE "Corporate Owned, Personally Enabled" or BYOD "Bring Your Own Device")\nVirtual environments (emulators) that make Android available on other platforms.\n\nPlease be aware that people with whom you may share this device and whose biometrics may be stored on this device may also have access to your prescriptions.
  internal static let cdwTxtBiometrySecurityWarningDescription = LocalizedStringKey("cdw_txt_biometry_security_warning_description")
  /// Security notice
  internal static let cdwTxtBiometrySecurityWarningTitle = LocalizedStringKey("cdw_txt_biometry_security_warning_title")
  /// Would you like to save your login details for future logins?
  internal static let cdwTxtBiometrySubtitle = LocalizedStringKey("cdw_txt_biometry_subtitle")
  /// Login
  internal static let cdwTxtBiometryTitle = LocalizedStringKey("cdw_txt_biometry_title")
  /// You can enter any digits.
  internal static let cdwTxtCanDemoModeInfo = LocalizedStringKey("cdw_txt_can_demo_mode_info")
  /// Your card access number (CAN) has 6 digits. You will find the CAN in the top right-hand corner on the front of your medical card. If there is no six-digit access number here, you will need a new medical card from your health insurance company.
  internal static let cdwTxtCanInputLabel = LocalizedStringKey("cdw_txt_can_input_label")
  /// Enter access number
  internal static let cdwTxtCanSubtitle = LocalizedStringKey("cdw_txt_can_subtitle")
  /// Login
  internal static let cdwTxtCanTitle = LocalizedStringKey("cdw_txt_can_title")
  /// Ihre Kartenzugangsnummer (Card Access Number, kurz: CAN) hat 6 Stellen. Sie finden die CAN in der rechten oberen Ecke der Vorderseite Ihrer Gesundheitskarte. Steht hier keine sechsstellige Zugangsnummer, benötigen Sie eine neue Gesundheitskarte von Ihrer Krankenversicherung.
  internal static let cdwTxtCanTitleHint = LocalizedStringKey("cdw_txt_can_title_hint")
  /// Unfortunately, the CAN entered does not match the recognised card. Please enter the CAN again. Thank you!
  internal static let cdwTxtCanWarnWrongDescription = LocalizedStringKey("cdw_txt_can_warn_wrong_description")
  /// Incorrect CAN
  internal static let cdwTxtCanWarnWrongTitle = LocalizedStringKey("cdw_txt_can_warn_wrong_title")
  /// Ihre Gesundheitskarte konnte nicht mit dem Profil verknüpft werden.
  internal static let cdwTxtExtauthAlertMessageSaveProfile = LocalizedStringKey("cdw_txt_extauth_alert_message_save_profile")
  /// Fehler beim Speichern des Profils
  internal static let cdwTxtExtauthAlertTitleSaveProfile = LocalizedStringKey("cdw_txt_extauth_alert_title_save_profile")
  /// Mail
  internal static let cdwTxtExtauthConfirmContactsheetMail = LocalizedStringKey("cdw_txt_extauth_confirm_contactsheet_mail")
  /// Telefon
  internal static let cdwTxtExtauthConfirmContactsheetTelephone = LocalizedStringKey("cdw_txt_extauth_confirm_contactsheet_telephone")
  /// Kundendienst kontaktieren
  internal static let cdwTxtExtauthConfirmContactsheetTitle = LocalizedStringKey("cdw_txt_extauth_confirm_contactsheet_title")
  /// Wir fragen nun die Authentisierung bei Ihrer Krankenversicherung an.
  internal static let cdwTxtExtauthConfirmDescription = LocalizedStringKey("cdw_txt_extauth_confirm_description")
  /// Bitte erwähnen Sie diesen Fehler gegenüber unserem technischen Kundendienst, um die Suche nach einer Lösung zu erleichtern.
  internal static let cdwTxtExtauthConfirmErrorDescription = LocalizedStringKey("cdw_txt_extauth_confirm_error_description")
  /// Authentisierung wird angefragt
  internal static let cdwTxtExtauthConfirmHeadline = LocalizedStringKey("cdw_txt_extauth_confirm_headline")
  /// E-Rezept
  internal static let cdwTxtExtauthConfirmOwnAppname = LocalizedStringKey("cdw_txt_extauth_confirm_own_appname")
  /// Mit App anmelden
  internal static let cdwTxtExtauthConfirmTitle = LocalizedStringKey("cdw_txt_extauth_confirm_title")
  /// Fehler beim Öffnen der Krankenkassenapp.
  internal static let cdwTxtExtauthConfirmUniversalLinkFailedError = LocalizedStringKey("cdw_txt_extauth_confirm_universal_link_failed_error")
  /// Derzeit bereiten sich die Krankenkassen auf diese Funktion vor.
  internal static let cdwTxtExtauthFallbackDescription1 = LocalizedStringKey("cdw_txt_extauth_fallback_description1")
  /// Sie wollen nicht warten? Die Anmeldung mit Gesundheitskarte wird bereits jetzt von jeder Krankenkasse unterstützt.
  internal static let cdwTxtExtauthFallbackDescription2 = LocalizedStringKey("cdw_txt_extauth_fallback_description2")
  /// Versicherung wählen
  internal static let cdwTxtExtauthFallbackHeadline = LocalizedStringKey("cdw_txt_extauth_fallback_headline")
  /// Mit App anmelden
  internal static let cdwTxtExtauthFallbackTitle = LocalizedStringKey("cdw_txt_extauth_fallback_title")
  /// Nicht fündig geworden? Diese Liste wird ständig erweitert. Die Anmeldung mit Gesundheitskarte wird bereits jetzt von jeder Krankenkasse unterstützt.
  internal static let cdwTxtExtauthSelectionDescription = LocalizedStringKey("cdw_txt_extauth_selection_description")
  /// Bitte probieren Sie es zu einem späteren Zeitpunkt erneut.
  internal static let cdwTxtExtauthSelectionErrorFallback = LocalizedStringKey("cdw_txt_extauth_selection_error_fallback")
  /// Versicherung wählen
  internal static let cdwTxtExtauthSelectionHeadline = LocalizedStringKey("cdw_txt_extauth_selection_headline")
  /// Mit App Anmelden
  internal static let cdwTxtExtauthSelectionTitle = LocalizedStringKey("cdw_txt_extauth_selection_title")
  /// To be able to use all functions of the app, log in with your medical card. You will receive this card and the required login details from your health insurance company.
  internal static let cdwTxtIntroDescription = LocalizedStringKey("cdw_txt_intro_description")
  /// Use all functions now
  internal static let cdwTxtIntroHeaderBottom = LocalizedStringKey("cdw_txt_intro_header_bottom")
  /// Login
  internal static let cdwTxtIntroHeaderTop = LocalizedStringKey("cdw_txt_intro_header_top")
  /// What you need:
  internal static let cdwTxtIntroListTitle = LocalizedStringKey("cdw_txt_intro_list_title")
  /// A medical card with access number (CAN)
  internal static let cdwTxtIntroRequirementCard = LocalizedStringKey("cdw_txt_intro_requirement_card")
  /// An NFC-enabled device with iOS 14
  internal static let cdwTxtIntroRequirementPhone = LocalizedStringKey("cdw_txt_intro_requirement_phone")
  /// The PIN for the medical card
  internal static let cdwTxtIntroRequirementPin = LocalizedStringKey("cdw_txt_intro_requirement_pin")
  /// Unfortunately, your device does not meet the minimum requirements for logging into the e-prescription app.
  internal static let cdwTxtNfuDescription = LocalizedStringKey("cdw_txt_nfu_description")
  /// Why are there minimum requirements for logging on with your medical card?
  internal static let cdwTxtNfuFootnote = LocalizedStringKey("cdw_txt_nfu_footnote")
  /// What a pity ...
  internal static let cdwTxtNfuSubtitle = LocalizedStringKey("cdw_txt_nfu_subtitle")
  /// Login
  internal static let cdwTxtNfuTitle = LocalizedStringKey("cdw_txt_nfu_title")
  /// You can enter any digits.
  internal static let cdwTxtPinDemoModeInfo = LocalizedStringKey("cdw_txt_pin_demo_mode_info")
  /// Your PIN can have between 6 and 8 digits.
  internal static let cdwTxtPinHint = LocalizedStringKey("cdw_txt_pin_hint")
  /// Geben Sie bitte Ihre PIN ein. Ihre PIN wurde Ihnen per Post zugestellt. Die PIN ist 6 bis 8 stellig.
  internal static let cdwTxtPinInputLabel = LocalizedStringKey("cdw_txt_pin_input_label")
  /// Enter PIN
  internal static let cdwTxtPinSubtitle = LocalizedStringKey("cdw_txt_pin_subtitle")
  /// Login
  internal static let cdwTxtPinTitle = LocalizedStringKey("cdw_txt_pin_title")
  /// Unfortunately, the PIN entered does not match the recognised card. Are you sure you entered the PIN you received from your health insurance company?
  internal static let cdwTxtPinWarnWrongDescription = LocalizedStringKey("cdw_txt_pin_warn_wrong_description")
  /// Incorrect PIN
  internal static let cdwTxtPinWarnWrongTitle = LocalizedStringKey("cdw_txt_pin_warn_wrong_title")
  /// A PIN consists of digits only.
  internal static let cdwTxtPinWarningChar = LocalizedStringKey("cdw_txt_pin_warning_char")
  /// The PIN consists of 6 to 8 digits; you have entered %@.
  internal static func cdwTxtPinWarningCount(_ element1: String) -> LocalizedStringKey {
    LocalizedStringKey("cdw_txt_pin_warning_count \(element1)")
  }
  /// Ihre Gesundheitskarte konnte nicht mit dem Profil verknüpft werden.
  internal static let cdwTxtRcAlertMessageSaveProfile = LocalizedStringKey("cdw_txt_rc_alert_message_save_profile")
  /// Fehler beim Speichern des Profils
  internal static let cdwTxtRcAlertTitleSaveProfile = LocalizedStringKey("cdw_txt_rc_alert_title_save_profile")
  /// You do not need a medical card in demo mode.
  internal static let cdwTxtRcDemoModeInfo = LocalizedStringKey("cdw_txt_rc_demo_mode_info")
  /// Click Login and hold your card against the device as shown. Do not move the card once a connection has been established.
  internal static let cdwTxtRcDescription = LocalizedStringKey("cdw_txt_rc_description")
  /// Error reading the medical card
  internal static let cdwTxtRcErrorGenericCardDescription = LocalizedStringKey("cdw_txt_rc_error_generic_card_description")
  /// Please try again
  internal static let cdwTxtRcErrorGenericCardRecovery = LocalizedStringKey("cdw_txt_rc_error_generic_card_recovery")
  /// Incorrect access number
  internal static let cdwTxtRcErrorWrongCanDescription = LocalizedStringKey("cdw_txt_rc_error_wrong_can_description")
  /// Please enter the correct access number (CAN)
  internal static let cdwTxtRcErrorWrongCanRecovery = LocalizedStringKey("cdw_txt_rc_error_wrong_can_recovery")
  /// Incorrect pin
  internal static func cdwTxtRcErrorWrongPinDescription(_ element1: String) -> LocalizedStringKey {
    LocalizedStringKey("cdw_txt_rc_error_wrong_pin_description_\(element1)")
  }
  /// %@ attempts left. Please enter the correct PIN.
  internal static func cdwTxtRcErrorWrongPinRecovery(_ element1: String) -> LocalizedStringKey {
    LocalizedStringKey("cdw_txt_rc_error_wrong_pin_recovery_\(element1)")
  }
  /// Have your medical card ready
  internal static let cdwTxtRcHeadline = LocalizedStringKey("cdw_txt_rc_headline")
  /// Connection interrupted
  internal static let cdwTxtRcNfcDialogCancel = LocalizedStringKey("cdw_txt_rc_nfc_dialog_cancel")
  /// Establishing a secure connection
  internal static let cdwTxtRcNfcDialogOpenPace = LocalizedStringKey("cdw_txt_rc_nfc_dialog_open_pace")
  /// Authentication
  internal static let cdwTxtRcNfcDialogSignChallenge = LocalizedStringKey("cdw_txt_rc_nfc_dialog_sign_challenge")
  /// Medical card successfully read
  internal static let cdwTxtRcNfcDialogSuccess = LocalizedStringKey("cdw_txt_rc_nfc_dialog_success")
  /// Verifying PIN
  internal static let cdwTxtRcNfcDialogVerifyPin = LocalizedStringKey("cdw_txt_rc_nfc_dialog_verify_pin")
  /// Connection failed
  internal static let cdwTxtRcNfcMessageConnectionErrorMessage = LocalizedStringKey("cdw_txt_rc_nfc_message_connectionErrorMessage")
  /// Medical card found. Please do not move.
  internal static let cdwTxtRcNfcMessageConnectMessage = LocalizedStringKey("cdw_txt_rc_nfc_message_connectMessage")
  /// Hold your medical card to the back of the device
  internal static let cdwTxtRcNfcMessageDiscoveryMessage = LocalizedStringKey("cdw_txt_rc_nfc_message_discoveryMessage")
  /// Several medical cards found
  internal static let cdwTxtRcNfcMessageMultipleCardsMessage = LocalizedStringKey("cdw_txt_rc_nfc_message_multipleCardsMessage")
  /// No medical card found
  internal static let cdwTxtRcNfcMessageNoCardMessage = LocalizedStringKey("cdw_txt_rc_nfc_message_noCardMessage")
  /// This card type is not supported
  internal static let cdwTxtRcNfcMessageUnsupportedCardMessage = LocalizedStringKey("cdw_txt_rc_nfc_message_unsupportedCardMessage")
  /// Connecting to the server
  internal static let cdwTxtRcStepGetChallenge = LocalizedStringKey("cdw_txt_rc_step_get_challenge")
  /// Reading medical card
  internal static let cdwTxtRcStepSignChallenge = LocalizedStringKey("cdw_txt_rc_step_sign_challenge")
  /// Login to prescription directory
  internal static let cdwTxtRcStepVerifyAtIdp = LocalizedStringKey("cdw_txt_rc_step_verify_at_idp")
  /// Steps
  internal static let cdwTxtRcStepsTitle = LocalizedStringKey("cdw_txt_rc_steps_title")
  /// Login
  internal static let cdwTxtRcTitle = LocalizedStringKey("cdw_txt_rc_title")
  /// Wählen Sie eine Anmeldemethode um automatisch Rezepte zu empfangen.
  internal static let cdwTxtSelDescription = LocalizedStringKey("cdw_txt_sel_description")
  /// Sichere Anmeldung mit Ihrer neuen elektronischen Gesundheitskarte
  internal static let cdwTxtSelEgkDescription = LocalizedStringKey("cdw_txt_sel_egk_description")
  /// Mit Gesundheitskarte anmelden
  internal static let cdwTxtSelEgkTitle = LocalizedStringKey("cdw_txt_sel_egk_title")
  /// Wie möchten Sie sich anmelden?
  internal static let cdwTxtSelHeadline = LocalizedStringKey("cdw_txt_sel_headline")
  /// Nutzen Sie eine App Ihrer Krankenversicherung zur Freischaltung
  internal static let cdwTxtSelKkappComingSoonDescription = LocalizedStringKey("cdw_txt_sel_kkapp_coming_soon_description")
  /// Nächstes Jahr: Mit Kassen-App anmelden
  internal static let cdwTxtSelKkappComingSoonTitle = LocalizedStringKey("cdw_txt_sel_kkapp_coming_soon_title")
  /// Nutzen Sie eine App Ihrer Krankenversicherung zur Freischaltung
  internal static let cdwTxtSelKkappDescription = LocalizedStringKey("cdw_txt_sel_kkapp_description")
  /// Mit Kassen-App anmelden
  internal static let cdwTxtSelKkappTitle = LocalizedStringKey("cdw_txt_sel_kkapp_title")
  /// Anmeldung
  internal static let cdwTxtSelTitle = LocalizedStringKey("cdw_txt_sel_title")
  /// Zuletzt aktualisiert %@
  internal static func cpnTxtRelativeTimerViewLastUpdate(_ element1: String) -> LocalizedStringKey {
    LocalizedStringKey("cpn_txt_relative_timer_view_last_update_\(element1)")
  }
  /// vor wenigen Sekunden
  internal static let cpnTxtRelativeTimerViewLastUpdateRecent = LocalizedStringKey("cpn_txt_relative_timer_view_last_update_recent")
  /// Speichern
  internal static let cpwBtnAltAuthSave = LocalizedStringKey("cpw_btn_alt_auth_save")
  /// Neues Kennwort speichern
  internal static let cpwBtnChange = LocalizedStringKey("cpw_btn_change")
  /// Kennwort speichern
  internal static let cpwBtnSave = LocalizedStringKey("cpw_btn_save")
  /// Aktuelles Kennwort
  internal static let cpwInpCurrentPasswordPlaceholder = LocalizedStringKey("cpw_inp_current_password_placeholder")
  /// Kennwort eingeben
  internal static let cpwInpPasswordAPlaceholder = LocalizedStringKey("cpw_inp_passwordA_placeholder")
  /// Kennwort wiederholen
  internal static let cpwInpPasswordBPlaceholder = LocalizedStringKey("cpw_inp_passwordB_placeholder")
  /// Das Kennwort ist falsch.
  internal static let cpwTxtCurrentPasswordWrong = LocalizedStringKey("cpw_txt_current_password_wrong")
  /// Empfehlung: Möglichst wenige Worte und keine Redewendungen verwenden.\nSymbole, Zahlen oder Großbuchstaben sind nicht notwendig.
  internal static let cpwTxtPasswordRecommendation = LocalizedStringKey("cpw_txt_password_recommendation")
  /// Sicherheitsstufe des gewählten Kennworts nicht ausreichend
  internal static let cpwTxtPasswordStrengthInsufficient = LocalizedStringKey("cpw_txt_password_strength_insufficient")
  /// Zweite Eingabe des Kennwortes, um Tippfehler zu erkennen
  internal static let cpwTxtPasswordBAccessibility = LocalizedStringKey("cpw_txt_passwordB_accessibility")
  /// Die Eingaben weichen voneinander ab.
  internal static let cpwTxtPasswordsDontMatch = LocalizedStringKey("cpw_txt_passwords_dont_match")
  /// Neues Kennwort
  internal static let cpwTxtSectionTitle = LocalizedStringKey("cpw_txt_section_title")
  /// Altes Kennwort
  internal static let cpwTxtSectionUpdateTitle = LocalizedStringKey("cpw_txt_section_update_title")
  /// Kennwort
  internal static let cpwTxtTitle = LocalizedStringKey("cpw_txt_title")
  /// Kennwort ändern
  internal static let cpwTxtUpdateTitle = LocalizedStringKey("cpw_txt_update_title")
  /// Bild bearbeiten
  internal static let ctlBtnProfilePickerEdit = LocalizedStringKey("ctl_btn_profile_picker_edit")
  /// Bild zurücksetzen
  internal static let ctlBtnProfilePickerReset = LocalizedStringKey("ctl_btn_profile_picker_reset")
  /// Speichern
  internal static let ctlBtnProfilePickerSet = LocalizedStringKey("ctl_btn_profile_picker_set")
  /// Kennwortstärke
  internal static let ctlTxtPasswordStrength0 = LocalizedStringKey("ctl_txt_password_strength_0")
  /// Kennwortstärke
  internal static let ctlTxtPasswordStrength1 = LocalizedStringKey("ctl_txt_password_strength_1")
  /// Kennwortstärke ausreichend
  internal static let ctlTxtPasswordStrength2 = LocalizedStringKey("ctl_txt_password_strength_2")
  /// Kennwortstärke gut
  internal static let ctlTxtPasswordStrength3 = LocalizedStringKey("ctl_txt_password_strength_3")
  /// Kennwortstärke sehr gut
  internal static let ctlTxtPasswordStrength4 = LocalizedStringKey("ctl_txt_password_strength_4")
  /// Kennwortstärke exzellent
  internal static let ctlTxtPasswordStrength5 = LocalizedStringKey("ctl_txt_password_strength_5")
  /// Ok
  internal static let ctlTxtPasswordStrengthAccessiblityValueMedium = LocalizedStringKey("ctl_txt_password_strength_accessiblity_value_medium")
  /// Stark
  internal static let ctlTxtPasswordStrengthAccessiblityValueStrong = LocalizedStringKey("ctl_txt_password_strength_accessiblity_value_strong")
  /// Sehr Stark
  internal static let ctlTxtPasswordStrengthAccessiblityValueVeryStrong = LocalizedStringKey("ctl_txt_password_strength_accessiblity_value_very_strong")
  /// Sehr schwach
  internal static let ctlTxtPasswordStrengthAccessiblityValueVeryWeak = LocalizedStringKey("ctl_txt_password_strength_accessiblity_value_very_weak")
  /// Schwach
  internal static let ctlTxtPasswordStrengthAccessiblityValueWeak = LocalizedStringKey("ctl_txt_password_strength_accessiblity_value_weak")
  /// Nicht angemeldet
  internal static let ctlTxtProfileCellNotConnected = LocalizedStringKey("ctl_txt_profile__cell_not_connected")
  /// Blau
  internal static let ctlTxtProfileColorPickerBlue = LocalizedStringKey("ctl_txt_profile_color_picker_blue")
  /// Grün
  internal static let ctlTxtProfileColorPickerGreen = LocalizedStringKey("ctl_txt_profile_color_picker_green")
  /// Grau
  internal static let ctlTxtProfileColorPickerGrey = LocalizedStringKey("ctl_txt_profile_color_picker_grey")
  /// Rosa
  internal static let ctlTxtProfileColorPickerPink = LocalizedStringKey("ctl_txt_profile_color_picker_pink")
  /// Ausgewählt
  internal static let ctlTxtProfileColorPickerSelected = LocalizedStringKey("ctl_txt_profile_color_picker_selected")
  /// Gelb
  internal static let ctlTxtProfileColorPickerYellow = LocalizedStringKey("ctl_txt_profile_color_picker_yellow")
  /// Copy
  internal static let dtlBtnCopyClipboard = LocalizedStringKey("dtl_btn_copy_clipboard")
  /// Delete from this device
  internal static let dtlBtnDeleteMedication = LocalizedStringKey("dtl_btn_delete_medication")
  /// Order
  internal static let dtlBtnPharmacySearch = LocalizedStringKey("dtl_btn_pharmacy_search")
  /// Mark as redeemed
  internal static let dtlBtnToogleMarkRedeemed = LocalizedStringKey("dtl_btn_toogle_mark_redeemed")
  /// Mark as not redeemed
  internal static let dtlBtnToogleMarkedRedeemed = LocalizedStringKey("dtl_btn_toogle_marked_redeemed")
  /// Access code
  internal static let dtlTxtAccessCode = LocalizedStringKey("dtl_txt_access_code")
  /// Do you want to permanently delete this prescription?
  internal static let dtlTxtDeleteAlertMessage = LocalizedStringKey("dtl_txt_delete_alert_message")
  /// Delete this prescription?
  internal static let dtlTxtDeleteAlertTitle = LocalizedStringKey("dtl_txt_delete_alert_title")
  /// The connection to the server was lost. Please log in again.
  internal static let dtlTxtDeleteMissingTokenAlertMessage = LocalizedStringKey("dtl_txt_delete_missing_token_alert_message")
  /// Deletion failed
  internal static let dtlTxtDeleteMissingTokenAlertTitle = LocalizedStringKey("dtl_txt_delete_missing_token_alert_title")
  /// Cancel
  internal static let dtlTxtDeleteNo = LocalizedStringKey("dtl_txt_delete_no")
  /// Delete
  internal static let dtlTxtDeleteYes = LocalizedStringKey("dtl_txt_delete_yes")
  /// Mark this prescription as redeemed as soon as you have received your medication.
  internal static let dtlTxtHintOverviewMessage = LocalizedStringKey("dtl_txt_hint_overview_message")
  /// Keep track of things
  internal static let dtlTxtHintOverviewTitle = LocalizedStringKey("dtl_txt_hint_overview_title")
  /// Technical information
  internal static let dtlTxtMedInfo = LocalizedStringKey("dtl_txt_med_info")
  /// Log
  internal static let dtlTxtMedProtocol = LocalizedStringKey("dtl_txt_med_protocol")
  /// Eingelöst: %@
  internal static func dtlTxtMedRedeemedOn(_ element1: String) -> LocalizedStringKey {
    LocalizedStringKey("dtl_txt_med_redeemed_on_\(element1)")
  }
  /// Scanned on
  internal static let dtlTxtScannedOn = LocalizedStringKey("dtl_txt_scanned_on")
  /// Task ID
  internal static let dtlTxtTaskId = LocalizedStringKey("dtl_txt_task_id")
  /// Details
  internal static let dtlTxtTitle = LocalizedStringKey("dtl_txt_title")
  /// Fehler beim Zugriff auf die Datenbank
  internal static let errTxtDatabaseAccess = LocalizedStringKey("err_txt_database_access")
  /// Redeem all
  internal static let erxBtnRedeem = LocalizedStringKey("erx_btn_redeem")
  /// Update
  internal static let erxBtnRefresh = LocalizedStringKey("erx_btn_refresh")
  /// Open prescription scanner
  internal static let erxBtnScnPrescription = LocalizedStringKey("erx_btn_scn_prescription")
  /// Open settings
  internal static let erxBtnShowSettings = LocalizedStringKey("erx_btn_show_settings")
  /// Prescriptions
  internal static let erxTitle = LocalizedStringKey("erx_title")
  /// Plural format key: "%#@variable_0@"
  internal static let erxTxtAcceptedUntil = LocalizedStringKey("erx_txt_accepted_until")
  /// Current
  internal static let erxTxtCurrent = LocalizedStringKey("erx_txt_current")
  /// Plural format key: "%#@v1_days_variable@"
  internal static let erxTxtExpiresIn = LocalizedStringKey("erx_txt_expires_in")
  /// Nicht mehr gültig
  internal static let erxTxtInvalid = LocalizedStringKey("erx_txt_invalid")
  /// Unknown medicine
  internal static let erxTxtMedicationPlaceholder = LocalizedStringKey("erx_txt_medication_placeholder")
  /// You do not have any current prescriptions
  internal static let erxTxtNoCurrentPrescriptions = LocalizedStringKey("erx_txt_no_current_prescriptions")
  /// You haven't redeemed any prescriptions yet
  internal static let erxTxtNotYetRedeemed = LocalizedStringKey("erx_txt_not_yet_redeemed")
  /// Archive
  internal static let erxTxtRedeemed = LocalizedStringKey("erx_txt_redeemed")
  /// Loading ...
  internal static let erxTxtRefreshLoading = LocalizedStringKey("erx_txt_refresh_loading")
  /// Log in now
  internal static let hintBtnCardWall = LocalizedStringKey("hint_btn_card_wall")
  /// Open scanner
  internal static let hintBtnOpenScn = LocalizedStringKey("hint_btn_open_scn")
  /// Launch demo mode
  internal static let hintBtnTryDemoMode = LocalizedStringKey("hint_btn_try_demo_mode")
  /// View new messages now
  internal static let hintBtnUnreadMessages = LocalizedStringKey("hint_btn_unread_messages")
  /// Unlock many more functions.
  internal static let hintTxtCardWall = LocalizedStringKey("hint_txt_card_wall")
  /// Log in with your medical card
  internal static let hintTxtCardWallTitle = LocalizedStringKey("hint_txt_card_wall_title")
  /// Our demo mode shows you all the functions of the app – without a medical card.
  internal static let hintTxtDemoMode = LocalizedStringKey("hint_txt_demo_mode")
  /// Would you like a tour of the app?
  internal static let hintTxtDemoModeTitle = LocalizedStringKey("hint_txt_demo_mode_title")
  /// Scan the prescription code to add it.
  internal static let hintTxtOpenScn = LocalizedStringKey("hint_txt_open_scn")
  /// New prescription
  internal static let hintTxtOpenScnTitle = LocalizedStringKey("hint_txt_open_scn_title")
  /// Our demo mode shows you all the functions of the app – without a medical card.
  internal static let hintTxtTryDemoMode = LocalizedStringKey("hint_txt_try_demo_mode")
  /// Would you like a tour of the app?
  internal static let hintTxtTryDemoModeTitle = LocalizedStringKey("hint_txt_try_demo_mode_title")
  /// You have received a new message from the health network.
  internal static let hintTxtUnreadMessages = LocalizedStringKey("hint_txt_unread_messages")
  /// New messages
  internal static let hintTxtUnreadMessagesTitle = LocalizedStringKey("hint_txt_unread_messages_title")
  /// Essential oil
  internal static let kbvCodeDosageFormAeo = LocalizedStringKey("kbv_code_dosage_form_aeo")
  /// Ampoules
  internal static let kbvCodeDosageFormAmp = LocalizedStringKey("kbv_code_dosage_form_amp")
  /// Pairs of ampoules
  internal static let kbvCodeDosageFormApa = LocalizedStringKey("kbv_code_dosage_form_apa")
  /// Eye and nose ointment
  internal static let kbvCodeDosageFormAsn = LocalizedStringKey("kbv_code_dosage_form_asn")
  /// Eye and ear ointment
  internal static let kbvCodeDosageFormAso = LocalizedStringKey("kbv_code_dosage_form_aso")
  /// Eye and ear drops
  internal static let kbvCodeDosageFormAto = LocalizedStringKey("kbv_code_dosage_form_ato")
  /// Eye drops
  internal static let kbvCodeDosageFormAtr = LocalizedStringKey("kbv_code_dosage_form_atr")
  /// Eye bath
  internal static let kbvCodeDosageFormAub = LocalizedStringKey("kbv_code_dosage_form_aub")
  /// Eye cream
  internal static let kbvCodeDosageFormAuc = LocalizedStringKey("kbv_code_dosage_form_auc")
  /// Eye gel
  internal static let kbvCodeDosageFormAug = LocalizedStringKey("kbv_code_dosage_form_aug")
  /// Eye ointment
  internal static let kbvCodeDosageFormAus = LocalizedStringKey("kbv_code_dosage_form_aus")
  /// Bath
  internal static let kbvCodeDosageFormBad = LocalizedStringKey("kbv_code_dosage_form_bad")
  /// Balsam
  internal static let kbvCodeDosageFormBal = LocalizedStringKey("kbv_code_dosage_form_bal")
  /// Bandage
  internal static let kbvCodeDosageFormBan = LocalizedStringKey("kbv_code_dosage_form_ban")
  /// Sachet
  internal static let kbvCodeDosageFormBeu = LocalizedStringKey("kbv_code_dosage_form_beu")
  /// Bindings
  internal static let kbvCodeDosageFormBin = LocalizedStringKey("kbv_code_dosage_form_bin")
  /// Sweets
  internal static let kbvCodeDosageFormBon = LocalizedStringKey("kbv_code_dosage_form_bon")
  /// Base plate
  internal static let kbvCodeDosageFormBpl = LocalizedStringKey("kbv_code_dosage_form_bpl")
  /// Puree
  internal static let kbvCodeDosageFormBre = LocalizedStringKey("kbv_code_dosage_form_bre")
  /// Effervescent tablets
  internal static let kbvCodeDosageFormBta = LocalizedStringKey("kbv_code_dosage_form_bta")
  /// Cream
  internal static let kbvCodeDosageFormCre = LocalizedStringKey("kbv_code_dosage_form_cre")
  /// Vials
  internal static let kbvCodeDosageFormDfl = LocalizedStringKey("kbv_code_dosage_form_dfl")
  /// Dilution
  internal static let kbvCodeDosageFormDil = LocalizedStringKey("kbv_code_dosage_form_dil")
  /// Depot injection suspension
  internal static let kbvCodeDosageFormDis = LocalizedStringKey("kbv_code_dosage_form_dis")
  /// Dragées in calendar pack
  internal static let kbvCodeDosageFormDka = LocalizedStringKey("kbv_code_dosage_form_dka")
  /// Metered dose inhaler
  internal static let kbvCodeDosageFormDos = LocalizedStringKey("kbv_code_dosage_form_dos")
  /// Dragées
  internal static let kbvCodeDosageFormDra = LocalizedStringKey("kbv_code_dosage_form_dra")
  /// Enteric-coated dragées
  internal static let kbvCodeDosageFormDrm = LocalizedStringKey("kbv_code_dosage_form_drm")
  /// Metered-dose foam
  internal static let kbvCodeDosageFormDsc = LocalizedStringKey("kbv_code_dosage_form_dsc")
  /// Metered-dose spray
  internal static let kbvCodeDosageFormDss = LocalizedStringKey("kbv_code_dosage_form_dss")
  /// Single-dose pipettes
  internal static let kbvCodeDosageFormEdp = LocalizedStringKey("kbv_code_dosage_form_edp")
  /// Lotion
  internal static let kbvCodeDosageFormEin = LocalizedStringKey("kbv_code_dosage_form_ein")
  /// Electrodes
  internal static let kbvCodeDosageFormEle = LocalizedStringKey("kbv_code_dosage_form_ele")
  /// Elixir
  internal static let kbvCodeDosageFormEli = LocalizedStringKey("kbv_code_dosage_form_eli")
  /// Emulsion
  internal static let kbvCodeDosageFormEmu = LocalizedStringKey("kbv_code_dosage_form_emu")
  /// Essence
  internal static let kbvCodeDosageFormEss = LocalizedStringKey("kbv_code_dosage_form_ess")
  /// Adult suppositories
  internal static let kbvCodeDosageFormEsu = LocalizedStringKey("kbv_code_dosage_form_esu")
  /// Extract
  internal static let kbvCodeDosageFormExt = LocalizedStringKey("kbv_code_dosage_form_ext")
  /// Filter bags
  internal static let kbvCodeDosageFormFbe = LocalizedStringKey("kbv_code_dosage_form_fbe")
  /// Rubbing alcohol
  internal static let kbvCodeDosageFormFbw = LocalizedStringKey("kbv_code_dosage_form_fbw")
  /// Film-coated dragées
  internal static let kbvCodeDosageFormFda = LocalizedStringKey("kbv_code_dosage_form_fda")
  /// Ready-to-fill syringes
  internal static let kbvCodeDosageFormFer = LocalizedStringKey("kbv_code_dosage_form_fer")
  /// Grease ointment
  internal static let kbvCodeDosageFormFet = LocalizedStringKey("kbv_code_dosage_form_fet")
  /// Bottle
  internal static let kbvCodeDosageFormFla = LocalizedStringKey("kbv_code_dosage_form_fla")
  /// Oral liquid
  internal static let kbvCodeDosageFormFle = LocalizedStringKey("kbv_code_dosage_form_fle")
  /// Liquid
  internal static let kbvCodeDosageFormFlu = LocalizedStringKey("kbv_code_dosage_form_flu")
  /// Enteric-resistant film-coated tablets
  internal static let kbvCodeDosageFormFmr = LocalizedStringKey("kbv_code_dosage_form_fmr")
  /// Foil
  internal static let kbvCodeDosageFormFol = LocalizedStringKey("kbv_code_dosage_form_fol")
  /// Sachet of sustained release film-coated tablets
  internal static let kbvCodeDosageFormFrb = LocalizedStringKey("kbv_code_dosage_form_frb")
  /// Liquid soap
  internal static let kbvCodeDosageFormFse = LocalizedStringKey("kbv_code_dosage_form_fse")
  /// Film-coated tablet
  internal static let kbvCodeDosageFormFta = LocalizedStringKey("kbv_code_dosage_form_fta")
  /// Granules in capsules for opening
  internal static let kbvCodeDosageFormGek = LocalizedStringKey("kbv_code_dosage_form_gek")
  /// Gel
  internal static let kbvCodeDosageFormGel = LocalizedStringKey("kbv_code_dosage_form_gel")
  /// Gas and solvent for the preparation of an injection/infusion dispersion
  internal static let kbvCodeDosageFormGli = LocalizedStringKey("kbv_code_dosage_form_gli")
  /// Globules
  internal static let kbvCodeDosageFormGlo = LocalizedStringKey("kbv_code_dosage_form_glo")
  /// Enteric-resistant granules
  internal static let kbvCodeDosageFormGmr = LocalizedStringKey("kbv_code_dosage_form_gmr")
  /// Gel plate
  internal static let kbvCodeDosageFormGpa = LocalizedStringKey("kbv_code_dosage_form_gpa")
  /// Granules
  internal static let kbvCodeDosageFormGra = LocalizedStringKey("kbv_code_dosage_form_gra")
  /// Granules for the preparation of an oral suspension
  internal static let kbvCodeDosageFormGse = LocalizedStringKey("kbv_code_dosage_form_gse")
  /// Gargling solution
  internal static let kbvCodeDosageFormGul = LocalizedStringKey("kbv_code_dosage_form_gul")
  /// Glove
  internal static let kbvCodeDosageFormHas = LocalizedStringKey("kbv_code_dosage_form_has")
  /// Enteric-resistant hard capsules
  internal static let kbvCodeDosageFormHkm = LocalizedStringKey("kbv_code_dosage_form_hkm")
  /// Hard capsules
  internal static let kbvCodeDosageFormHkp = LocalizedStringKey("kbv_code_dosage_form_hkp")
  /// Hard capsules with powder for inhalation
  internal static let kbvCodeDosageFormHpi = LocalizedStringKey("kbv_code_dosage_form_hpi")
  /// Modified-release hard capsules
  internal static let kbvCodeDosageFormHvw = LocalizedStringKey("kbv_code_dosage_form_hvw")
  /// Infusion ampoules
  internal static let kbvCodeDosageFormIfa = LocalizedStringKey("kbv_code_dosage_form_ifa")
  /// Infusion bag
  internal static let kbvCodeDosageFormIfb = LocalizedStringKey("kbv_code_dosage_form_ifb")
  /// Infusion dispersion
  internal static let kbvCodeDosageFormIfd = LocalizedStringKey("kbv_code_dosage_form_ifd")
  /// Solution for injection in a ready-to-fill syringe
  internal static let kbvCodeDosageFormIfe = LocalizedStringKey("kbv_code_dosage_form_ife")
  /// Infusion bottles
  internal static let kbvCodeDosageFormIff = LocalizedStringKey("kbv_code_dosage_form_iff")
  /// Infusion solution concentrate
  internal static let kbvCodeDosageFormIfk = LocalizedStringKey("kbv_code_dosage_form_ifk")
  /// Injection bottles
  internal static let kbvCodeDosageFormIfl = LocalizedStringKey("kbv_code_dosage_form_ifl")
  /// Infusion set
  internal static let kbvCodeDosageFormIfs = LocalizedStringKey("kbv_code_dosage_form_ifs")
  /// Inhalation ampoules
  internal static let kbvCodeDosageFormIha = LocalizedStringKey("kbv_code_dosage_form_iha")
  /// Inhalation powder
  internal static let kbvCodeDosageFormIhp = LocalizedStringKey("kbv_code_dosage_form_ihp")
  /// Injection or infusion solution or oral solution
  internal static let kbvCodeDosageFormIie = LocalizedStringKey("kbv_code_dosage_form_iie")
  /// Solution for injection/infusion
  internal static let kbvCodeDosageFormIil = LocalizedStringKey("kbv_code_dosage_form_iil")
  /// Solution for injection for intramuscular use
  internal static let kbvCodeDosageFormIim = LocalizedStringKey("kbv_code_dosage_form_iim")
  /// Inhalation capsules
  internal static let kbvCodeDosageFormIka = LocalizedStringKey("kbv_code_dosage_form_ika")
  /// Injection solution
  internal static let kbvCodeDosageFormIlo = LocalizedStringKey("kbv_code_dosage_form_ilo")
  /// Implant
  internal static let kbvCodeDosageFormImp = LocalizedStringKey("kbv_code_dosage_form_imp")
  /// Infusion solution
  internal static let kbvCodeDosageFormInf = LocalizedStringKey("kbv_code_dosage_form_inf")
  /// Inhalant
  internal static let kbvCodeDosageFormInh = LocalizedStringKey("kbv_code_dosage_form_inh")
  /// Injection and infusion bottles
  internal static let kbvCodeDosageFormIni = LocalizedStringKey("kbv_code_dosage_form_ini")
  /// Inhalation solution
  internal static let kbvCodeDosageFormInl = LocalizedStringKey("kbv_code_dosage_form_inl")
  /// Instant tea
  internal static let kbvCodeDosageFormIns = LocalizedStringKey("kbv_code_dosage_form_ins")
  /// Instillation
  internal static let kbvCodeDosageFormIst = LocalizedStringKey("kbv_code_dosage_form_ist")
  /// Injection suspension
  internal static let kbvCodeDosageFormIsu = LocalizedStringKey("kbv_code_dosage_form_isu")
  /// Intrauterine device
  internal static let kbvCodeDosageFormIup = LocalizedStringKey("kbv_code_dosage_form_iup")
  /// Cannulas
  internal static let kbvCodeDosageFormKan = LocalizedStringKey("kbv_code_dosage_form_kan")
  /// Capsules
  internal static let kbvCodeDosageFormKap = LocalizedStringKey("kbv_code_dosage_form_kap")
  /// Catheter
  internal static let kbvCodeDosageFormKat = LocalizedStringKey("kbv_code_dosage_form_kat")
  /// Chews
  internal static let kbvCodeDosageFormKda = LocalizedStringKey("kbv_code_dosage_form_kda")
  /// Cone
  internal static let kbvCodeDosageFormKeg = LocalizedStringKey("kbv_code_dosage_form_keg")
  /// Kernels
  internal static let kbvCodeDosageFormKer = LocalizedStringKey("kbv_code_dosage_form_ker")
  /// Chewing gum
  internal static let kbvCodeDosageFormKgu = LocalizedStringKey("kbv_code_dosage_form_kgu")
  /// Concentrate for the preparation of an infusion dispersion
  internal static let kbvCodeDosageFormKid = LocalizedStringKey("kbv_code_dosage_form_kid")
  /// Concentrate for the preparation of an injection or infusion solution
  internal static let kbvCodeDosageFormKii = LocalizedStringKey("kbv_code_dosage_form_kii")
  /// Infant suppositories
  internal static let kbvCodeDosageFormKks = LocalizedStringKey("kbv_code_dosage_form_kks")
  /// Enemas
  internal static let kbvCodeDosageFormKli = LocalizedStringKey("kbv_code_dosage_form_kli")
  /// Enema tablets
  internal static let kbvCodeDosageFormKlt = LocalizedStringKey("kbv_code_dosage_form_klt")
  /// Hard capsules with enteric-coated pellets
  internal static let kbvCodeDosageFormKmp = LocalizedStringKey("kbv_code_dosage_form_kmp")
  /// Enteric-resistant capsules
  internal static let kbvCodeDosageFormKmr = LocalizedStringKey("kbv_code_dosage_form_kmr")
  /// Condoms
  internal static let kbvCodeDosageFormKod = LocalizedStringKey("kbv_code_dosage_form_kod")
  /// Compresses
  internal static let kbvCodeDosageFormKom = LocalizedStringKey("kbv_code_dosage_form_kom")
  /// Concentrate
  internal static let kbvCodeDosageFormKon = LocalizedStringKey("kbv_code_dosage_form_kon")
  /// Combination pack
  internal static let kbvCodeDosageFormKpg = LocalizedStringKey("kbv_code_dosage_form_kpg")
  /// Crystal suspension
  internal static let kbvCodeDosageFormKri = LocalizedStringKey("kbv_code_dosage_form_kri")
  /// Children's and infant suppositories
  internal static let kbvCodeDosageFormKss = LocalizedStringKey("kbv_code_dosage_form_kss")
  /// Children's suppositories
  internal static let kbvCodeDosageFormKsu = LocalizedStringKey("kbv_code_dosage_form_ksu")
  /// Chewable tablets
  internal static let kbvCodeDosageFormKta = LocalizedStringKey("kbv_code_dosage_form_kta")
  /// Lancets
  internal static let kbvCodeDosageFormLan = LocalizedStringKey("kbv_code_dosage_form_lan")
  /// Solution for injection, infusion and inhalation
  internal static let kbvCodeDosageFormLii = LocalizedStringKey("kbv_code_dosage_form_lii")
  /// Liquid paraffin
  internal static let kbvCodeDosageFormLiq = LocalizedStringKey("kbv_code_dosage_form_liq")
  /// Solution
  internal static let kbvCodeDosageFormLoe = LocalizedStringKey("kbv_code_dosage_form_loe")
  /// Lotion
  internal static let kbvCodeDosageFormLot = LocalizedStringKey("kbv_code_dosage_form_lot")
  /// Nebuliser solution
  internal static let kbvCodeDosageFormLov = LocalizedStringKey("kbv_code_dosage_form_lov")
  /// Oral solution
  internal static let kbvCodeDosageFormLse = LocalizedStringKey("kbv_code_dosage_form_lse")
  /// Lacquer tablets
  internal static let kbvCodeDosageFormLta = LocalizedStringKey("kbv_code_dosage_form_lta")
  /// Hard pastilles
  internal static let kbvCodeDosageFormLup = LocalizedStringKey("kbv_code_dosage_form_lup")
  /// Lozenges
  internal static let kbvCodeDosageFormLut = LocalizedStringKey("kbv_code_dosage_form_lut")
  /// Milk
  internal static let kbvCodeDosageFormMil = LocalizedStringKey("kbv_code_dosage_form_mil")
  /// Blend
  internal static let kbvCodeDosageFormMis = LocalizedStringKey("kbv_code_dosage_form_mis")
  /// Mixture
  internal static let kbvCodeDosageFormMix = LocalizedStringKey("kbv_code_dosage_form_mix")
  /// Enteric-resistant sustained-release granules
  internal static let kbvCodeDosageFormMrg = LocalizedStringKey("kbv_code_dosage_form_mrg")
  /// Enteric-resistant pellets
  internal static let kbvCodeDosageFormMrp = LocalizedStringKey("kbv_code_dosage_form_mrp")
  /// Coated tablets
  internal static let kbvCodeDosageFormMta = LocalizedStringKey("kbv_code_dosage_form_mta")
  /// Mouthwash
  internal static let kbvCodeDosageFormMuw = LocalizedStringKey("kbv_code_dosage_form_muw")
  /// Nasal gel
  internal static let kbvCodeDosageFormNag = LocalizedStringKey("kbv_code_dosage_form_nag")
  /// Nose oil
  internal static let kbvCodeDosageFormNao = LocalizedStringKey("kbv_code_dosage_form_nao")
  /// Nasal spray
  internal static let kbvCodeDosageFormNas = LocalizedStringKey("kbv_code_dosage_form_nas")
  /// Nail varnish containing active ingredients
  internal static let kbvCodeDosageFormNaw = LocalizedStringKey("kbv_code_dosage_form_naw")
  /// Nasal dosing spray
  internal static let kbvCodeDosageFormNds = LocalizedStringKey("kbv_code_dosage_form_nds")
  /// Nasal ointment
  internal static let kbvCodeDosageFormNsa = LocalizedStringKey("kbv_code_dosage_form_nsa")
  /// Nasal drops
  internal static let kbvCodeDosageFormNtr = LocalizedStringKey("kbv_code_dosage_form_ntr")
  /// Occusert
  internal static let kbvCodeDosageFormOcu = LocalizedStringKey("kbv_code_dosage_form_ocu")
  /// Oil
  internal static let kbvCodeDosageFormOel = LocalizedStringKey("kbv_code_dosage_form_oel")
  /// Ear drops
  internal static let kbvCodeDosageFormOht = LocalizedStringKey("kbv_code_dosage_form_oht")
  /// Ovula
  internal static let kbvCodeDosageFormOvu = LocalizedStringKey("kbv_code_dosage_form_ovu")
  /// Packing dimensions
  internal static let kbvCodeDosageFormPam = LocalizedStringKey("kbv_code_dosage_form_pam")
  /// Pastilles
  internal static let kbvCodeDosageFormPas = LocalizedStringKey("kbv_code_dosage_form_pas")
  /// Pellets
  internal static let kbvCodeDosageFormPel = LocalizedStringKey("kbv_code_dosage_form_pel")
  /// Solution for injection in a pre-filled pen
  internal static let kbvCodeDosageFormPen = LocalizedStringKey("kbv_code_dosage_form_pen")
  /// Beads
  internal static let kbvCodeDosageFormPer = LocalizedStringKey("kbv_code_dosage_form_per")
  /// Plaster
  internal static let kbvCodeDosageFormPfl = LocalizedStringKey("kbv_code_dosage_form_pfl")
  /// Transdermal patch
  internal static let kbvCodeDosageFormPft = LocalizedStringKey("kbv_code_dosage_form_pft")
  /// Powder for the preparation of a solution for injection, infusion or inhalation
  internal static let kbvCodeDosageFormPhi = LocalizedStringKey("kbv_code_dosage_form_phi")
  /// Powder for the preparation of an injection or infusion solution or powder and solvent for the preparation of a solution for intravesical use.
  internal static let kbvCodeDosageFormPhv = LocalizedStringKey("kbv_code_dosage_form_phv")
  /// Powder for a concentrate for an infusion solution Powder for the preparation of an oral solution
  internal static let kbvCodeDosageFormPie = LocalizedStringKey("kbv_code_dosage_form_pie")
  /// Powder for the preparation of an infusion solution
  internal static let kbvCodeDosageFormPif = LocalizedStringKey("kbv_code_dosage_form_pif")
  /// Powder for the preparation of an injection or infusion solution
  internal static let kbvCodeDosageFormPii = LocalizedStringKey("kbv_code_dosage_form_pii")
  /// Powder for the preparation of an injection solution
  internal static let kbvCodeDosageFormPij = LocalizedStringKey("kbv_code_dosage_form_pij")
  /// Powder for the preparation of an infusion solution concentrate
  internal static let kbvCodeDosageFormPik = LocalizedStringKey("kbv_code_dosage_form_pik")
  /// Powder for the preparation of an infusion suspension
  internal static let kbvCodeDosageFormPis = LocalizedStringKey("kbv_code_dosage_form_pis")
  /// Powder for the preparation of an injection or infusion solution or a solution for intravesical use
  internal static let kbvCodeDosageFormPiv = LocalizedStringKey("kbv_code_dosage_form_piv")
  /// Powder for a concentrate for the preparation of an infusion solution
  internal static let kbvCodeDosageFormPki = LocalizedStringKey("kbv_code_dosage_form_pki")
  /// Powder for the preparation of an oral solution
  internal static let kbvCodeDosageFormPle = LocalizedStringKey("kbv_code_dosage_form_ple")
  /// Powder and solvent for the preparation of an infusion solution
  internal static let kbvCodeDosageFormPlf = LocalizedStringKey("kbv_code_dosage_form_plf")
  /// Perlongets
  internal static let kbvCodeDosageFormPlg = LocalizedStringKey("kbv_code_dosage_form_plg")
  /// Powder and solvent for the preparation of an injection or infusion solution
  internal static let kbvCodeDosageFormPlh = LocalizedStringKey("kbv_code_dosage_form_plh")
  /// Powder and solvent for the preparation of an injection solution
  internal static let kbvCodeDosageFormPli = LocalizedStringKey("kbv_code_dosage_form_pli")
  /// Powder and solvent for a concentrate for the preparation of an infusion solution
  internal static let kbvCodeDosageFormPlk = LocalizedStringKey("kbv_code_dosage_form_plk")
  /// Powder and solvent for the preparation of an injection suspension
  internal static let kbvCodeDosageFormPls = LocalizedStringKey("kbv_code_dosage_form_pls")
  /// Powder and solvent for the preparation of a solution for intravesical use
  internal static let kbvCodeDosageFormPlv = LocalizedStringKey("kbv_code_dosage_form_plv")
  /// Pump solution
  internal static let kbvCodeDosageFormPpl = LocalizedStringKey("kbv_code_dosage_form_ppl")
  /// Pellets
  internal static let kbvCodeDosageFormPrs = LocalizedStringKey("kbv_code_dosage_form_prs")
  /// Powder for the preparation of an oral suspension
  internal static let kbvCodeDosageFormPse = LocalizedStringKey("kbv_code_dosage_form_pse")
  /// Paste
  internal static let kbvCodeDosageFormPst = LocalizedStringKey("kbv_code_dosage_form_pst")
  /// Powder for external use
  internal static let kbvCodeDosageFormPud = LocalizedStringKey("kbv_code_dosage_form_pud")
  /// Powder
  internal static let kbvCodeDosageFormPul = LocalizedStringKey("kbv_code_dosage_form_pul")
  /// Sustained-release dragées
  internal static let kbvCodeDosageFormRed = LocalizedStringKey("kbv_code_dosage_form_red")
  /// Sustained-release capsules
  internal static let kbvCodeDosageFormRek = LocalizedStringKey("kbv_code_dosage_form_rek")
  /// Sustained-release tablets
  internal static let kbvCodeDosageFormRet = LocalizedStringKey("kbv_code_dosage_form_ret")
  /// Sustained-release granules
  internal static let kbvCodeDosageFormRgr = LocalizedStringKey("kbv_code_dosage_form_rgr")
  /// Rectal capsules
  internal static let kbvCodeDosageFormRka = LocalizedStringKey("kbv_code_dosage_form_rka")
  /// Sustained-release microcapsules and suspension agents
  internal static let kbvCodeDosageFormRms = LocalizedStringKey("kbv_code_dosage_form_rms")
  /// Rectal foam
  internal static let kbvCodeDosageFormRsc = LocalizedStringKey("kbv_code_dosage_form_rsc")
  /// Rectal suspension
  internal static let kbvCodeDosageFormRsu = LocalizedStringKey("kbv_code_dosage_form_rsu")
  /// Sustained-release coated tablets
  internal static let kbvCodeDosageFormRut = LocalizedStringKey("kbv_code_dosage_form_rut")
  /// Juice
  internal static let kbvCodeDosageFormSaf = LocalizedStringKey("kbv_code_dosage_form_saf")
  /// Ointment
  internal static let kbvCodeDosageFormSal = LocalizedStringKey("kbv_code_dosage_form_sal")
  /// Ointment for use in the oral cavity
  internal static let kbvCodeDosageFormSam = LocalizedStringKey("kbv_code_dosage_form_sam")
  /// Foam
  internal static let kbvCodeDosageFormSch = LocalizedStringKey("kbv_code_dosage_form_sch")
  /// Soap
  internal static let kbvCodeDosageFormSei = LocalizedStringKey("kbv_code_dosage_form_sei")
  /// Shampoo
  internal static let kbvCodeDosageFormSha = LocalizedStringKey("kbv_code_dosage_form_sha")
  /// Syrup
  internal static let kbvCodeDosageFormSir = LocalizedStringKey("kbv_code_dosage_form_sir")
  /// Salt
  internal static let kbvCodeDosageFormSlz = LocalizedStringKey("kbv_code_dosage_form_slz")
  /// Orodispersible film
  internal static let kbvCodeDosageFormSmf = LocalizedStringKey("kbv_code_dosage_form_smf")
  /// Orodispersible tablets
  internal static let kbvCodeDosageFormSmt = LocalizedStringKey("kbv_code_dosage_form_smt")
  /// Suppositories with gauze inlay
  internal static let kbvCodeDosageFormSmu = LocalizedStringKey("kbv_code_dosage_form_smu")
  /// Injection ampoules
  internal static let kbvCodeDosageFormSpa = LocalizedStringKey("kbv_code_dosage_form_spa")
  /// Spray bottle
  internal static let kbvCodeDosageFormSpf = LocalizedStringKey("kbv_code_dosage_form_spf")
  /// Rinsing solution
  internal static let kbvCodeDosageFormSpl = LocalizedStringKey("kbv_code_dosage_form_spl")
  /// Spray
  internal static let kbvCodeDosageFormSpr = LocalizedStringKey("kbv_code_dosage_form_spr")
  /// Transdermal spray
  internal static let kbvCodeDosageFormSpt = LocalizedStringKey("kbv_code_dosage_form_spt")
  /// Syringes
  internal static let kbvCodeDosageFormSri = LocalizedStringKey("kbv_code_dosage_form_sri")
  /// Infant suppositories
  internal static let kbvCodeDosageFormSsu = LocalizedStringKey("kbv_code_dosage_form_ssu")
  /// Lancing ampoules
  internal static let kbvCodeDosageFormSta = LocalizedStringKey("kbv_code_dosage_form_sta")
  /// Sticks
  internal static let kbvCodeDosageFormStb = LocalizedStringKey("kbv_code_dosage_form_stb")
  /// Pens
  internal static let kbvCodeDosageFormSti = LocalizedStringKey("kbv_code_dosage_form_sti")
  /// Strips
  internal static let kbvCodeDosageFormStr = LocalizedStringKey("kbv_code_dosage_form_str")
  /// Substance
  internal static let kbvCodeDosageFormSub = LocalizedStringKey("kbv_code_dosage_form_sub")
  /// Oral suspension
  internal static let kbvCodeDosageFormSue = LocalizedStringKey("kbv_code_dosage_form_sue")
  /// Sublingual spray solution
  internal static let kbvCodeDosageFormSul = LocalizedStringKey("kbv_code_dosage_form_sul")
  /// Suppositories
  internal static let kbvCodeDosageFormSup = LocalizedStringKey("kbv_code_dosage_form_sup")
  /// Suspension
  internal static let kbvCodeDosageFormSus = LocalizedStringKey("kbv_code_dosage_form_sus")
  /// Sublingual tablets
  internal static let kbvCodeDosageFormSut = LocalizedStringKey("kbv_code_dosage_form_sut")
  /// Suspension for a nebuliser
  internal static let kbvCodeDosageFormSuv = LocalizedStringKey("kbv_code_dosage_form_suv")
  /// Sponges
  internal static let kbvCodeDosageFormSwa = LocalizedStringKey("kbv_code_dosage_form_swa")
  /// Pills
  internal static let kbvCodeDosageFormTab = LocalizedStringKey("kbv_code_dosage_form_tab")
  /// Tablets
  internal static let kbvCodeDosageFormTae = LocalizedStringKey("kbv_code_dosage_form_tae")
  /// Dry ampoules
  internal static let kbvCodeDosageFormTam = LocalizedStringKey("kbv_code_dosage_form_tam")
  /// Tea
  internal static let kbvCodeDosageFormTee = LocalizedStringKey("kbv_code_dosage_form_tee")
  /// Oral drops
  internal static let kbvCodeDosageFormTei = LocalizedStringKey("kbv_code_dosage_form_tei")
  /// Test
  internal static let kbvCodeDosageFormTes = LocalizedStringKey("kbv_code_dosage_form_tes")
  /// Tincture
  internal static let kbvCodeDosageFormTin = LocalizedStringKey("kbv_code_dosage_form_tin")
  /// Tablets in calendar pack
  internal static let kbvCodeDosageFormTka = LocalizedStringKey("kbv_code_dosage_form_tka")
  /// Tablet for the preparation of an oral solution
  internal static let kbvCodeDosageFormTle = LocalizedStringKey("kbv_code_dosage_form_tle")
  /// Enteric-resistant tablets
  internal static let kbvCodeDosageFormTmr = LocalizedStringKey("kbv_code_dosage_form_tmr")
  /// Tonic
  internal static let kbvCodeDosageFormTon = LocalizedStringKey("kbv_code_dosage_form_ton")
  /// Tampon
  internal static let kbvCodeDosageFormTpn = LocalizedStringKey("kbv_code_dosage_form_tpn")
  /// Tamponades
  internal static let kbvCodeDosageFormTpo = LocalizedStringKey("kbv_code_dosage_form_tpo")
  /// Drinking ampoules
  internal static let kbvCodeDosageFormTra = LocalizedStringKey("kbv_code_dosage_form_tra")
  /// Trituration
  internal static let kbvCodeDosageFormTri = LocalizedStringKey("kbv_code_dosage_form_tri")
  /// Drops
  internal static let kbvCodeDosageFormTro = LocalizedStringKey("kbv_code_dosage_form_tro")
  /// Dry substance with solvent
  internal static let kbvCodeDosageFormTrs = LocalizedStringKey("kbv_code_dosage_form_trs")
  /// Drinking tablets
  internal static let kbvCodeDosageFormTrt = LocalizedStringKey("kbv_code_dosage_form_trt")
  /// Dry syrup
  internal static let kbvCodeDosageFormTsa = LocalizedStringKey("kbv_code_dosage_form_tsa")
  /// Tablets for the preparation of an oral suspension for a dosing dispenser
  internal static let kbvCodeDosageFormTsd = LocalizedStringKey("kbv_code_dosage_form_tsd")
  /// Tablet for the preparation of an oral suspension
  internal static let kbvCodeDosageFormTse = LocalizedStringKey("kbv_code_dosage_form_tse")
  /// Dry substance without solvent
  internal static let kbvCodeDosageFormTss = LocalizedStringKey("kbv_code_dosage_form_tss")
  /// Test sticks
  internal static let kbvCodeDosageFormTst = LocalizedStringKey("kbv_code_dosage_form_tst")
  /// Transdermal system
  internal static let kbvCodeDosageFormTsy = LocalizedStringKey("kbv_code_dosage_form_tsy")
  /// Test strips
  internal static let kbvCodeDosageFormTtr = LocalizedStringKey("kbv_code_dosage_form_ttr")
  /// Tube
  internal static let kbvCodeDosageFormTub = LocalizedStringKey("kbv_code_dosage_form_tub")
  /// Cloths
  internal static let kbvCodeDosageFormTue = LocalizedStringKey("kbv_code_dosage_form_tue")
  /// Swab
  internal static let kbvCodeDosageFormTup = LocalizedStringKey("kbv_code_dosage_form_tup")
  /// Modified-release tablet
  internal static let kbvCodeDosageFormTvw = LocalizedStringKey("kbv_code_dosage_form_tvw")
  /// Coated tablets
  internal static let kbvCodeDosageFormUta = LocalizedStringKey("kbv_code_dosage_form_uta")
  /// Vaginal solution
  internal static let kbvCodeDosageFormVal = LocalizedStringKey("kbv_code_dosage_form_val")
  /// Vaginal ring
  internal static let kbvCodeDosageFormVar = LocalizedStringKey("kbv_code_dosage_form_var")
  /// Vaginal cream
  internal static let kbvCodeDosageFormVcr = LocalizedStringKey("kbv_code_dosage_form_vcr")
  /// Dressing
  internal static let kbvCodeDosageFormVer = LocalizedStringKey("kbv_code_dosage_form_ver")
  /// Vaginal gel
  internal static let kbvCodeDosageFormVge = LocalizedStringKey("kbv_code_dosage_form_vge")
  /// Vaginal capsules
  internal static let kbvCodeDosageFormVka = LocalizedStringKey("kbv_code_dosage_form_vka")
  /// Fleece
  internal static let kbvCodeDosageFormVli = LocalizedStringKey("kbv_code_dosage_form_vli")
  /// Vaginal ovules
  internal static let kbvCodeDosageFormVov = LocalizedStringKey("kbv_code_dosage_form_vov")
  /// Vaginal swabs
  internal static let kbvCodeDosageFormVst = LocalizedStringKey("kbv_code_dosage_form_vst")
  /// Vaginal suppositories
  internal static let kbvCodeDosageFormVsu = LocalizedStringKey("kbv_code_dosage_form_vsu")
  /// Vaginal tablets
  internal static let kbvCodeDosageFormVta = LocalizedStringKey("kbv_code_dosage_form_vta")
  /// Cotton wool
  internal static let kbvCodeDosageFormWat = LocalizedStringKey("kbv_code_dosage_form_wat")
  /// Wound gauze
  internal static let kbvCodeDosageFormWga = LocalizedStringKey("kbv_code_dosage_form_wga")
  /// Soft capsules
  internal static let kbvCodeDosageFormWka = LocalizedStringKey("kbv_code_dosage_form_wka")
  /// Enteric-resistant soft capsules
  internal static let kbvCodeDosageFormWkm = LocalizedStringKey("kbv_code_dosage_form_wkm")
  /// Cube
  internal static let kbvCodeDosageFormWue = LocalizedStringKey("kbv_code_dosage_form_wue")
  /// Shower gel
  internal static let kbvCodeDosageFormXdg = LocalizedStringKey("kbv_code_dosage_form_xdg")
  /// Deodorant spray
  internal static let kbvCodeDosageFormXds = LocalizedStringKey("kbv_code_dosage_form_xds")
  /// Firming agent
  internal static let kbvCodeDosageFormXfe = LocalizedStringKey("kbv_code_dosage_form_xfe")
  /// Face mask
  internal static let kbvCodeDosageFormXgm = LocalizedStringKey("kbv_code_dosage_form_xgm")
  /// Collar
  internal static let kbvCodeDosageFormXha = LocalizedStringKey("kbv_code_dosage_form_xha")
  /// Hair conditioner
  internal static let kbvCodeDosageFormXhs = LocalizedStringKey("kbv_code_dosage_form_xhs")
  /// Night cream
  internal static let kbvCodeDosageFormXnc = LocalizedStringKey("kbv_code_dosage_form_xnc")
  /// Body care
  internal static let kbvCodeDosageFormXpk = LocalizedStringKey("kbv_code_dosage_form_xpk")
  /// Day cream
  internal static let kbvCodeDosageFormXtc = LocalizedStringKey("kbv_code_dosage_form_xtc")
  /// Cylinder ampoule
  internal static let kbvCodeDosageFormZam = LocalizedStringKey("kbv_code_dosage_form_zam")
  /// Toothbrush
  internal static let kbvCodeDosageFormZbu = LocalizedStringKey("kbv_code_dosage_form_zbu")
  /// Dentifrice
  internal static let kbvCodeDosageFormZcr = LocalizedStringKey("kbv_code_dosage_form_zcr")
  /// Tooth gel
  internal static let kbvCodeDosageFormZge = LocalizedStringKey("kbv_code_dosage_form_zge")
  /// Chewable capsules
  internal static let kbvCodeDosageFormZka = LocalizedStringKey("kbv_code_dosage_form_zka")
  /// Toothpaste
  internal static let kbvCodeDosageFormZpa = LocalizedStringKey("kbv_code_dosage_form_zpa")
  /// Members
  internal static let kbvMemberStatus1 = LocalizedStringKey("kbv_member_status_1")
  /// Family members
  internal static let kbvMemberStatus3 = LocalizedStringKey("kbv_member_status_3")
  /// Pensioner
  internal static let kbvMemberStatus5 = LocalizedStringKey("kbv_member_status_5")
  /// Not specified
  internal static let kbvNormSizeKa = LocalizedStringKey("kbv_norm_size_ka")
  /// No package size suitable for therapy
  internal static let kbvNormSizeKtp = LocalizedStringKey("kbv_norm_size_ktp")
  /// Standard size 1
  internal static let kbvNormSizeN1 = LocalizedStringKey("kbv_norm_size_n1")
  /// Standard size 2
  internal static let kbvNormSizeN2 = LocalizedStringKey("kbv_norm_size_n2")
  /// Standard size 3
  internal static let kbvNormSizeN3 = LocalizedStringKey("kbv_norm_size_n3")
  /// Not affected
  internal static let kbvNormSizeNb = LocalizedStringKey("kbv_norm_size_nb")
  /// Other
  internal static let kbvNormSizeSonstiges = LocalizedStringKey("kbv_norm_size_sonstiges")
  /// Abbrechen
  internal static let mainTxtPendingextauthCancel = LocalizedStringKey("main_txt_pendingextauth_cancel")
  /// Authentisierung mit %@ fehlgeschlagen
  internal static func mainTxtPendingextauthFailed(_ element1: String) -> LocalizedStringKey {
    LocalizedStringKey("main_txt_pendingextauth_failed_\(element1)")
  }
  /// Authentisierung in %@ ausstehend
  internal static func mainTxtPendingextauthPending(_ element1: String) -> LocalizedStringKey {
    LocalizedStringKey("main_txt_pendingextauth_pending_\(element1)")
  }
  /// Authentisierung für %@ wird verarbeitet
  internal static func mainTxtPendingextauthResolving(_ element1: String) -> LocalizedStringKey {
    LocalizedStringKey("main_txt_pendingextauth_resolving_\(element1)")
  }
  /// Wiederholen
  internal static let mainTxtPendingextauthRetry = LocalizedStringKey("main_txt_pendingextauth_retry")
  /// Authentisierung mit %@ erfolgreich
  internal static func mainTxtPendingextauthSuccessful(_ element1: String) -> LocalizedStringKey {
    LocalizedStringKey("main_txt_pendingextauth_successful_\(element1)")
  }
  /// Profilname
  internal static let mgmFallbackProfileName = LocalizedStringKey("mgm_fallback_profile_name")
  /// Es konnte kein Profil bei der Aktualisierung erstellt werden
  internal static let mgmTxtAlertMessageProfileCreation = LocalizedStringKey("mgm_txt_alert_message_profile_creation")
  /// Die App ist bereits auf dem neusten Stand
  internal static let mgmTxtAlertMessageUpToDate = LocalizedStringKey("mgm_txt_alert_message_up_to_date")
  /// Report error
  internal static let msgsBtnFormatError = LocalizedStringKey("msgs_btn_format_error")
  /// Show pickup code
  internal static let msgsBtnOnPremise = LocalizedStringKey("msgs_btn_onPremise")
  /// Show shopping cart
  internal static let msgsBtnShipment = LocalizedStringKey("msgs_btn_shipment")
  /// Message received
  internal static let msgsTxtDeliveryTitle = LocalizedStringKey("msgs_txt_delivery_title")
  /// app-fehlermeldung@ti-support.de
  internal static let msgsTxtEmailSupport = LocalizedStringKey("msgs_txt_email_support")
  /// You haven't received any messages yet
  internal static let msgsTxtEmptyListMessage = LocalizedStringKey("msgs_txt_empty_list_message")
  /// No messages
  internal static let msgsTxtEmptyListTitle = LocalizedStringKey("msgs_txt_empty_list_title")
  /// Unfortunately, your pharmacy's message was empty. Please contact your pharmacy.
  internal static let msgsTxtEmptyMessage = LocalizedStringKey("msgs_txt_empty_message")
  /// A pharmacy has sent a message in an incorrect format.
  internal static let msgsTxtFormatErrorMessage = LocalizedStringKey("msgs_txt_format_error_message")
  /// Defective message received
  internal static let msgsTxtFormatErrorTitle = LocalizedStringKey("msgs_txt_format_error_title")
  /// Dear Service Team, I received a message from a pharmacy. Unfortunately, however, I could not pass the message on to my user because I did not understand it. Please check what happened here and help us. Thank you very much! The e-prescription app
  internal static let msgsTxtMailBody1 = LocalizedStringKey("msgs_txt_mail_body1")
  /// You are sending us this information for purposes of troubleshooting. Please note that your email address and any name you include will also be transferred. If you do not wish to transfer this information either in full or in part, please remove it from this email. \n\nAll data will only be stored or processed by gematik GmbH or its appointed companies in order to deal with this error message. Deletion takes place automatically a maximum of 180 days after the ticket has been processed. We will use your email address exclusively to contact you regarding this error message. If you have any questions, or require an earlier deletion, you can contact the data protection representative responsible for the e-prescription system. You can find further information in the menu below the entry for data protection in the e-prescription app.
  internal static let msgsTxtMailBody2 = LocalizedStringKey("msgs_txt_mail_body2")
  /// Fehler 40 42 67336
  internal static let msgsTxtMailError = LocalizedStringKey("msgs_txt_mail_error")
  /// Error message from the e-prescription app
  internal static let msgsTxtMailSubject = LocalizedStringKey("msgs_txt_mail_subject")
  /// Received pickup code
  internal static let msgsTxtOnPremiseTitle = LocalizedStringKey("msgs_txt_onPremise_title")
  /// The email app could not be opened. Please use the hotline
  internal static let msgsTxtOpenMailErrorMessage = LocalizedStringKey("msgs_txt_open_mail_error_message")
  /// Error
  internal static let msgsTxtOpenMailErrorTitle = LocalizedStringKey("msgs_txt_open_mail_error_title")
  /// Your shopping cart is ready
  internal static let msgsTxtShipmentTitle = LocalizedStringKey("msgs_txt_shipment_title")
  /// Messages
  internal static let msgsTxtTitle = LocalizedStringKey("msgs_txt_title")
  /// Back
  internal static let navBack = LocalizedStringKey("nav_back")
  /// Cancel
  internal static let navCancel = LocalizedStringKey("nav_cancel")
  /// Ready
  internal static let navDone = LocalizedStringKey("nav_done")
  /// Machen Sie es Unbefugten schwerer an Ihre Daten zu gelangen und sichern Sie den Start der App.
  internal static let onbAuthTxtAltDescription = LocalizedStringKey("onb_auth_txt_alt_description")
  /// ODER
  internal static let onbAuthTxtDivider = LocalizedStringKey("onb_auth_txt_divider")
  /// Bitte wählen Sie eine Methode zum absichern der App aus:
  internal static let onbAuthTxtNoSelection = LocalizedStringKey("onb_auth_txt_no_selection")
  /// Sicherheitsstufe des gewählten Kennworts nicht ausreichend
  internal static let onbAuthTxtPasswordStrengthInsufficient = LocalizedStringKey("onb_auth_txt_password_strength_insufficient")
  /// Die Eingaben weichen voneinander ab.
  internal static let onbAuthTxtPasswordsDontMatch = LocalizedStringKey("onb_auth_txt_passwords_dont_match")
  /// Wie möchten Sie diese App absichern?
  internal static let onbAuthTxtTitle = LocalizedStringKey("onb_auth_txt_title")
  /// Next
  internal static let onbBtnNextHint = LocalizedStringKey("onb_btn_next_hint")
  /// Automatically update your new prescriptions
  internal static let onbFeaTxtFeature1 = LocalizedStringKey("onb_fea_txt_feature_1")
  /// Information on how to take your medication and dosages
  internal static let onbFeaTxtFeature2 = LocalizedStringKey("onb_fea_txt_feature_2")
  /// Receive messages from your pharmacy about your order
  internal static let onbFeaTxtFeature3 = LocalizedStringKey("onb_fea_txt_feature_3")
  /// More features with your medical card
  internal static let onbFeaTxtTitle = LocalizedStringKey("onb_fea_txt_title")
  /// Gematik logo
  internal static let onbImgGematikLogo = LocalizedStringKey("onb_img_gematik_logo")
  /// Illustration of a hand holding a medical card to the back of a smartphone.
  internal static let onbImgMan1 = LocalizedStringKey("onb_img_man1")
  /// Accept Privacy Policy
  internal static let onbLegBtnPrivacyHint = LocalizedStringKey("onb_leg_btn_privacy_hint")
  /// Accept Terms of Use
  internal static let onbLegBtnTermsOfUseHint = LocalizedStringKey("onb_leg_btn_terms_of_use_hint")
  /// Confirm
  internal static let onbLegBtnTitle = LocalizedStringKey("onb_leg_btn_title")
  /// In order to use the app, please agree to the Terms of Use and confirm that you have read and understood the Privacy Policy. Only data that is essential for the functioning of the services is collected.
  internal static let onbLegTxtSubtitle = LocalizedStringKey("onb_leg_txt_subtitle")
  /// Terms of Use & Privacy Policy
  internal static let onbLegTxtTitle = LocalizedStringKey("onb_leg_txt_title")
  /// Das Namensfeld darf nicht leer sein
  internal static let onbPrfTxtAlertMessage = LocalizedStringKey("onb_prf_txt_alert_message")
  /// Fehler
  internal static let onbPrfTxtAlertTitle = LocalizedStringKey("onb_prf_txt_alert_title")
  /// Das hilft Ihnen dabei, den Überblick zu behalten, wenn Sie die Rezepte für mehrere Personen verwalten möchten.
  internal static let onbPrfTxtFootnote = LocalizedStringKey("onb_prf_txt_footnote")
  /// Erstes Profil
  internal static let onbPrfTxtInitialName = LocalizedStringKey("onb_prf_txt_initial_name")
  /// Vorname und Nachname
  internal static let onbPrfTxtPlaceholder = LocalizedStringKey("onb_prf_txt_placeholder")
  /// Wie sollen wir Sie nennen?
  internal static let onbPrfTxtTitle = LocalizedStringKey("onb_prf_txt_title")
  /// Digital. Fast. Secure.
  internal static let onbStrTxtSubtitle = LocalizedStringKey("onb_str_txt_subtitle")
  /// The e-prescription
  internal static let onbStrTxtTitle = LocalizedStringKey("onb_str_txt_title")
  /// Privacy Policy
  internal static let onbTxtTermsOfPrivacyLink = LocalizedStringKey("onb_txt_terms_of_privacy_link")
  /// I accept the 
  internal static let onbTxtTermsOfPrivacyPrefix = LocalizedStringKey("onb_txt_terms_of_privacy_prefix")
  ///  of this app
  internal static let onbTxtTermsOfPrivacySuffix = LocalizedStringKey("onb_txt_terms_of_privacy_suffix")
  /// Terms of Use
  internal static let onbTxtTermsOfUseLink = LocalizedStringKey("onb_txt_terms_of_use_link")
  /// I accept the 
  internal static let onbTxtTermsOfUsePrefix = LocalizedStringKey("onb_txt_terms_of_use_prefix")
  ///  of this app
  internal static let onbTxtTermsOfUseSuffix = LocalizedStringKey("onb_txt_terms_of_use_suffix")
  /// Illustration of a smiling pharmacist
  internal static let onbWelImgFrau1 = LocalizedStringKey("onb_wel_img_frau1")
  /// Here you can redeem electronic prescriptions at a pharmacy of your choice, directly in person or online.
  internal static let onbWelTxtExplanation = LocalizedStringKey("onb_wel_txt_explanation")
  /// Welcome to the e-prescription app
  internal static let onbWelTxtTitle = LocalizedStringKey("onb_wel_txt_title")
  /// So erkennen Sie eine NFC-fähige Gesundheitskarte
  internal static let orderEgkBtnInfoButton = LocalizedStringKey("order_egk_btn_info_button")
  /// Mail
  internal static let orderEgkTxtContactOptionMail = LocalizedStringKey("order_egk_txt_contact_option_mail")
  /// Telefon
  internal static let orderEgkTxtContactOptionTelephone = LocalizedStringKey("order_egk_txt_contact_option_telephone")
  /// Webseite
  internal static let orderEgkTxtContactOptionWeb = LocalizedStringKey("order_egk_txt_contact_option_web")
  /// Um sich in dieser App anmelden zu können, benötigen Sie eine NFC-fähige Gesundheitskarte sowie eine zugehörige PIN.
  internal static let orderEgkTxtDescription1 = LocalizedStringKey("order_egk_txt_description_1")
  /// Diese erhalten Sie kostenfrei von Ihrer Krankenversicherung. Hierfür müssen Sie sich mittels amtlichem Ausweisdokument identifiziert haben.
  internal static let orderEgkTxtDescription2 = LocalizedStringKey("order_egk_txt_description_2")
  /// Krankenversicherung kontaktieren
  internal static let orderEgkTxtHeadline = LocalizedStringKey("order_egk_txt_headline")
  /// Bitte nutzen Sie die üblichen Kanäle, um Ihre Versicherung zu kontaktieren.
  internal static let orderEgkTxtHintNoContactOptionMessage = LocalizedStringKey("order_egk_txt_hint_no_contact_option_message")
  /// Keine Kontaktaufnahme über diese App möglich
  internal static let orderEgkTxtHintNoContactOptionTitle = LocalizedStringKey("order_egk_txt_hint_no_contact_option_title")
  /// https://www.das-e-rezept-fuer-deutschland.de/fragen-antworten/woran-erkenne-ich-ob-ich-eine-nfc-faehige-gesundheitskarte-habe#c204
  internal static let orderEgkTxtInfoLink = LocalizedStringKey("order_egk_txt_info_link")
  /// 
  internal static let orderEgkTxtMailHealthcardAndPinBody = LocalizedStringKey("order_egk_txt_mail_healthcard_and_pin_body")
  /// Bestellung einer NFC-fähigen Gesundheitskarte inklusive PIN
  internal static let orderEgkTxtMailHealthcardAndPinSubject = LocalizedStringKey("order_egk_txt_mail_healthcard_and_pin_subject")
  /// Krankenversicherung wählen
  internal static let orderEgkTxtPickerInsuranceHeader = LocalizedStringKey("order_egk_txt_picker_insurance_header")
  /// Auswahl treffen
  internal static let orderEgkTxtPickerInsurancePlaceholder = LocalizedStringKey("order_egk_txt_picker_insurance_placeholder")
  /// Was möchten Sie beantragen?
  internal static let orderEgkTxtPickerServiceHeader = LocalizedStringKey("order_egk_txt_picker_service_header")
  /// Sollten Sie bereits über eine Gesundheitskarte mit NFC-Funktion verfügen, müssen Sie lediglich die Zusendung einer PIN beantragen.
  internal static let orderEgkTxtPickerServiceInfoFootnote = LocalizedStringKey("order_egk_txt_picker_service_info_footnote")
  /// Auswahl treffen
  internal static let orderEgkTxtPickerServiceLabel = LocalizedStringKey("order_egk_txt_picker_service_label")
  /// Auswählen
  internal static let orderEgkTxtPickerServiceNavigationTitle = LocalizedStringKey("order_egk_txt_picker_service_navigation_title")
  /// Kontaktieren Sie Ihre Krankenversicherung
  internal static let orderEgkTxtSectionContactInsurance = LocalizedStringKey("order_egk_txt_section_contact_insurance")
  /// Gesundheitskarte & PIN
  internal static let orderEgkTxtServiceInquiryHealthcardAndPin = LocalizedStringKey("order_egk_txt_service_inquiry_healthcard_and_pin")
  /// Nur PIN
  internal static let orderEgkTxtServiceInquiryOnlyPin = LocalizedStringKey("order_egk_txt_service_inquiry_only_pin")
  /// Find out more
  internal static let phaDetailBtnFooter = LocalizedStringKey("pha_detail_btn_footer")
  /// Request delivery service
  internal static let phaDetailBtnHealthcareService = LocalizedStringKey("pha_detail_btn_healthcare_service")
  /// Reserve for collection
  internal static let phaDetailBtnLocation = LocalizedStringKey("pha_detail_btn_location")
  /// Delivery by mail order
  internal static let phaDetailBtnOrganization = LocalizedStringKey("pha_detail_btn_organization")
  /// Contact
  internal static let phaDetailContact = LocalizedStringKey("pha_detail_contact")
  /// Please note that prescribed medication may also be subject to additional payments.
  internal static let phaDetailHintMessage = LocalizedStringKey("pha_detail_hint_message")
  /// This pharmacy is not currently able to receive any e-prescriptions.
  internal static let phaDetailHintNotErxReadyMessage = LocalizedStringKey("pha_detail_hint_not_erx_ready_message")
  /// Can be redeemed soon
  internal static let phaDetailHintNotErxReadyTitle = LocalizedStringKey("pha_detail_hint_not_erx_ready_title")
  /// Email address
  internal static let phaDetailMail = LocalizedStringKey("pha_detail_mail")
  /// Opening hours
  internal static let phaDetailOpeningTime = LocalizedStringKey("pha_detail_opening_time")
  /// Telephone number
  internal static let phaDetailPhone = LocalizedStringKey("pha_detail_phone")
  ///  provided by the Deutscher Apothekenverband e.V. Have you found an error or would you like to correct any data?
  internal static let phaDetailTxtFooterEnd = LocalizedStringKey("pha_detail_txt_footer_end")
  /// mein-apothekenportal.de
  internal static let phaDetailTxtFooterMid = LocalizedStringKey("pha_detail_txt_footer_mid")
  /// Note to pharmacies: this app obtains the contact details for and information about pharmacies from 
  internal static let phaDetailTxtFooterStart = LocalizedStringKey("pha_detail_txt_footer_start")
  /// Pharmacy
  internal static let phaDetailTxtSubtitleFallback = LocalizedStringKey("pha_detail_txt_subtitle_fallback")
  /// Details
  internal static let phaDetailTxtTitle = LocalizedStringKey("pha_detail_txt_title")
  /// Website
  internal static let phaDetailWeb = LocalizedStringKey("pha_detail_web")
  /// E-prescription
  internal static let phaGlobalTxtReadinessBadge = LocalizedStringKey("pha_global_txt_readiness_badge")
  /// Ready for the e-prescription
  internal static let phaGlobalTxtReadinessBadgeDetailed = LocalizedStringKey("pha_global_txt_readiness_badge_detailed")
  /// Redeem now
  internal static let phaRedeemBtnAlertApproval = LocalizedStringKey("pha_redeem_btn_alert_approval")
  /// Cancel
  internal static let phaRedeemBtnAlertCancel = LocalizedStringKey("pha_redeem_btn_alert_cancel")
  /// Redeem
  internal static let phaRedeemBtnRedeem = LocalizedStringKey("pha_redeem_btn_redeem")
  /// Your prescription will be sent to this pharmacy. It is not possible to redeem your prescription at another pharmacy.
  internal static let phaRedeemBtnRedeemFootnote = LocalizedStringKey("pha_redeem_btn_redeem_footnote")
  /// ⚕︎ Redeem
  internal static let phaRedeemTitle = LocalizedStringKey("pha_redeem_title")
  /// Delivery address
  internal static let phaRedeemTxtAddress = LocalizedStringKey("pha_redeem_txt_address")
  /// You can change your delivery address on the website of the mail-order pharmacy.
  internal static let phaRedeemTxtAddressFootnote = LocalizedStringKey("pha_redeem_txt_address_footnote")
  /// Your prescriptions will be sent to this pharmacy. You will then not be able to redeem them in any other pharmacy.
  internal static let phaRedeemTxtAlertMessage = LocalizedStringKey("pha_redeem_txt_alert_message")
  /// Redeem with binding effect?
  internal static let phaRedeemTxtAlertTitle = LocalizedStringKey("pha_redeem_txt_alert_title")
  /// You are no longer logged in. Please log back in to redeem prescriptions.
  internal static let phaRedeemTxtNotLoggedIn = LocalizedStringKey("pha_redeem_txt_not_logged_in")
  /// Prescriptions
  internal static let phaRedeemTxtPrescription = LocalizedStringKey("pha_redeem_txt_prescription")
  /// Substitutes are permitted. You may be given an alternative due to the legal requirements of your health insurance.
  internal static let phaRedeemTxtPrescriptionSub = LocalizedStringKey("pha_redeem_txt_prescription_sub")
  /// Commit to redeeming the following prescriptions at the %@?
  internal static func phaRedeemTxtSubtitle(_ element1: String) -> LocalizedStringKey {
    LocalizedStringKey("pha_redeem_txt_subtitle_\(element1)")
  }
  /// Delivery service
  internal static let phaRedeemTxtTitleDelivery = LocalizedStringKey("pha_redeem_txt_title_delivery")
  /// Mail order
  internal static let phaRedeemTxtTitleMail = LocalizedStringKey("pha_redeem_txt_title_mail")
  /// Reservation
  internal static let phaRedeemTxtTitleReservation = LocalizedStringKey("pha_redeem_txt_title_reservation")
  /// Erneut probieren
  internal static let phaSearchBtnErrorNoServerResponse = LocalizedStringKey("pha_search_btn_error_no_server_response")
  /// Share location
  internal static let phaSearchBtnLocationHintAction = LocalizedStringKey("pha_search_btn_location_hint_action")
  /// Filter
  internal static let phaSearchBtnShowFilterView = LocalizedStringKey("pha_search_btn_show_filter_view")
  /// Alphabetical
  internal static let phaSearchBtnSortAlpha = LocalizedStringKey("pha_search_btn_sort_alpha")
  /// Distance
  internal static let phaSearchBtnSortDistance = LocalizedStringKey("pha_search_btn_sort_distance")
  /// Filter
  internal static let phaSearchFilterTxtTitle = LocalizedStringKey("pha_search_filter_txt_title")
  /// Closed
  internal static let phaSearchTxtClosed = LocalizedStringKey("pha_search_txt_closed")
  /// Closing soon
  internal static let phaSearchTxtClosingSoon = LocalizedStringKey("pha_search_txt_closing_soon")
  /// Unfortunately, communication with the pharmacy service seems to be disrupted at the moment.
  internal static let phaSearchTxtErrorAlertMessage = LocalizedStringKey("pha_search_txt_error_alert_message")
  /// Error
  internal static let phaSearchTxtErrorAlertTitle = LocalizedStringKey("pha_search_txt_error_alert_title")
  /// Server antwortet nicht
  internal static let phaSearchTxtErrorNoServerResponseHeadline = LocalizedStringKey("pha_search_txt_error_no_server_response_headline")
  /// Bitte probieren Sie es in einigen Minuten erneut.
  internal static let phaSearchTxtErrorNoServerResponseSubheadline = LocalizedStringKey("pha_search_txt_error_no_server_response_subheadline")
  /// Delivery service
  internal static let phaSearchTxtFilterMessenger = LocalizedStringKey("pha_search_txt_filter_messenger")
  /// Mail order
  internal static let phaSearchTxtFilterOrder = LocalizedStringKey("pha_search_txt_filter_order")
  /// Start the search by tapping Open on the keypad
  internal static let phaSearchTxtHintStartSearch = LocalizedStringKey("pha_search_txt_hint_start_search")
  /// Share your location to find pharmacies near you.
  internal static let phaSearchTxtLocationAlertMessage = LocalizedStringKey("pha_search_txt_location_alert_message")
  /// Share location
  internal static let phaSearchTxtLocationAlertTitle = LocalizedStringKey("pha_search_txt_location_alert_title")
  /// Share your location and find pharmacies in your area
  internal static let phaSearchTxtLocationHintMessage = LocalizedStringKey("pha_search_txt_location_hint_message")
  /// Find pharmacies easily
  internal static let phaSearchTxtLocationHintTitle = LocalizedStringKey("pha_search_txt_location_hint_title")
  /// Please start your search with at least three letters.
  internal static let phaSearchTxtMinSearchChars = LocalizedStringKey("pha_search_txt_min_search_chars")
  /// We couldn't find any results with this search term.
  internal static let phaSearchTxtNoResults = LocalizedStringKey("pha_search_txt_no_results")
  /// No results
  internal static let phaSearchTxtNoResultsTitle = LocalizedStringKey("pha_search_txt_no_results_title")
  /// Open until
  internal static let phaSearchTxtOpenUntil = LocalizedStringKey("pha_search_txt_open_until")
  /// Opens at
  internal static let phaSearchTxtOpensAt = LocalizedStringKey("pha_search_txt_opens_at")
  /// Determining device location...
  internal static let phaSearchTxtProgressLocating = LocalizedStringKey("pha_search_txt_progress_locating")
  /// Searching...
  internal static let phaSearchTxtProgressSearch = LocalizedStringKey("pha_search_txt_progress_search")
  /// Searched name, e.g. Spessart Pharmacy
  internal static let phaSearchTxtSearchHint = LocalizedStringKey("pha_search_txt_search_hint")
  /// Select pharmacy
  internal static let phaSearchTxtTitle = LocalizedStringKey("pha_search_txt_title")
  /// Done! 🎉
  internal static let phaSuccessRedeemTitle = LocalizedStringKey("pha_success_redeem_title")
  /// Fertig
  internal static let proBtnSelectionClose = LocalizedStringKey("pro_btn_selection_close")
  /// Profile bearbeiten
  internal static let proBtnSelectionEdit = LocalizedStringKey("pro_btn_selection_edit")
  /// Nicht angemeldet
  internal static let proTxtSelectionProfileNotConnected = LocalizedStringKey("pro_txt_selection_profile_not_connected")
  /// Profil wählen
  internal static let proTxtSelectionTitle = LocalizedStringKey("pro_txt_selection_title")
  /// gesund.bund.de öffnen
  internal static let prscDtlHntGesundBundDeBtn = LocalizedStringKey("prsc_dtl_hnt_gesund_bund_de_btn")
  /// Fachlich geprüfte Informationen zu Krankheiten, ICD-Codes und zu Vorsorge- und Pflegethemen finden Sie im Nationalen Gesundheitsportal.
  internal static let prscDtlHntGesundBundDeText = LocalizedStringKey("prsc_dtl_hnt_gesund_bund_de_text")
  /// Date of accident
  internal static let prscFdTxtAccidentDate = LocalizedStringKey("prsc_fd_txt_accident_date")
  /// Accident company or employer number
  internal static let prscFdTxtAccidentId = LocalizedStringKey("prsc_fd_txt_accident_id")
  /// Accident at work
  internal static let prscFdTxtAccidentTitle = LocalizedStringKey("prsc_fd_txt_accident_title")
  /// Dosage form
  internal static let prscFdTxtDetailsDosageForm = LocalizedStringKey("prsc_fd_txt_details_dosage_form")
  /// Package size
  internal static let prscFdTxtDetailsDose = LocalizedStringKey("prsc_fd_txt_details_dose")
  /// Pharma central number (PZN)
  internal static let prscFdTxtDetailsPzn = LocalizedStringKey("prsc_fd_txt_details_pzn")
  /// Details about this medicine
  internal static let prscFdTxtDetailsTitle = LocalizedStringKey("prsc_fd_txt_details_title")
  /// Please follow the directions for use in your medication schedule or the written dosage instructions from your doctor.
  internal static let prscFdTxtDosageInstructionsNa = LocalizedStringKey("prsc_fd_txt_dosage_instructions_na")
  /// Directions for use
  internal static let prscFdTxtDosageInstructionsTitle = LocalizedStringKey("prsc_fd_txt_dosage_instructions_title")
  /// Not specified
  internal static let prscFdTxtNa = LocalizedStringKey("prsc_fd_txt_na")
  /// Detail
  internal static let prscFdTxtNavigationTitle = LocalizedStringKey("prsc_fd_txt_navigation_title")
  /// This medication can also be redeemed in a pharmacy at night without an emergency service fee.
  internal static let prscFdTxtNoctuDescription = LocalizedStringKey("prsc_fd_txt_noctu_description")
  /// This is a matter of urgency
  internal static let prscFdTxtNoctuTitle = LocalizedStringKey("prsc_fd_txt_noctu_title")
  /// Address
  internal static let prscFdTxtOrganizationAddress = LocalizedStringKey("prsc_fd_txt_organization_address")
  /// Email address
  internal static let prscFdTxtOrganizationEmail = LocalizedStringKey("prsc_fd_txt_organization_email")
  /// Establishment number
  internal static let prscFdTxtOrganizationId = LocalizedStringKey("prsc_fd_txt_organization_id")
  /// Name
  internal static let prscFdTxtOrganizationName = LocalizedStringKey("prsc_fd_txt_organization_name")
  /// Telephone number
  internal static let prscFdTxtOrganizationPhone = LocalizedStringKey("prsc_fd_txt_organization_phone")
  /// Institution
  internal static let prscFdTxtOrganizationTitle = LocalizedStringKey("prsc_fd_txt_organization_title")
  /// Address
  internal static let prscFdTxtPatientAddress = LocalizedStringKey("prsc_fd_txt_patient_address")
  /// Date of birth
  internal static let prscFdTxtPatientBirthdate = LocalizedStringKey("prsc_fd_txt_patient_birthdate")
  /// Health insurance / cost unit
  internal static let prscFdTxtPatientInsurance = LocalizedStringKey("prsc_fd_txt_patient_insurance")
  /// Insurance number
  internal static let prscFdTxtPatientInsuranceId = LocalizedStringKey("prsc_fd_txt_patient_insurance_id")
  /// Name
  internal static let prscFdTxtPatientName = LocalizedStringKey("prsc_fd_txt_patient_name")
  /// Telephone number
  internal static let prscFdTxtPatientPhone = LocalizedStringKey("prsc_fd_txt_patient_phone")
  /// Status
  internal static let prscFdTxtPatientStatus = LocalizedStringKey("prsc_fd_txt_patient_status")
  /// Insured person
  internal static let prscFdTxtPatientTitle = LocalizedStringKey("prsc_fd_txt_patient_title")
  /// Physician number (LANR)
  internal static let prscFdTxtPractitionerId = LocalizedStringKey("prsc_fd_txt_practitioner_id")
  /// Name
  internal static let prscFdTxtPractitionerName = LocalizedStringKey("prsc_fd_txt_practitioner_name")
  /// Specialist physician
  internal static let prscFdTxtPractitionerQualification = LocalizedStringKey("prsc_fd_txt_practitioner_qualification")
  /// Prescriber
  internal static let prscFdTxtPractitionerTitle = LocalizedStringKey("prsc_fd_txt_practitioner_title")
  /// Update failed. Please try again later.
  internal static let prscFdTxtProtocolDownloadError = LocalizedStringKey("prsc_fd_txt_protocol_download_error")
  /// Last updated
  internal static let prscFdTxtProtocolLastUpdated = LocalizedStringKey("prsc_fd_txt_protocol_last_updated")
  /// Substitutes are permitted. You may be given an alternative due to the legal requirements of your health insurance.
  internal static let prscFdTxtSubstitutionDescription = LocalizedStringKey("prsc_fd_txt_substitution_description")
  /// Find out more
  internal static let prscFdTxtSubstitutionReadFurther = LocalizedStringKey("prsc_fd_txt_substitution_read_further")
  /// https://www.das-e-rezept-fuer-deutschland.de/fragen-antworten
  internal static let prscFdTxtSubstitutionReadFurtherLink = LocalizedStringKey("prsc_fd_txt_substitution_read_further_link")
  /// Substitute medication possible
  internal static let prscFdTxtSubstitutionTitle = LocalizedStringKey("prsc_fd_txt_substitution_title")
  /// Show this code at your pharmacy.
  internal static let pucTxtSubtitle = LocalizedStringKey("puc_txt_subtitle")
  /// Collection code
  internal static let pucTxtTitle = LocalizedStringKey("puc_txt_title")
  /// You are in a pharmacy and want to redeem your prescription.
  internal static let rdmBtnRedeemPharmacyDescription = LocalizedStringKey("rdm_btn_redeem_pharmacy_description")
  /// I'm in the pharmacy
  internal static let rdmBtnRedeemPharmacyTitle = LocalizedStringKey("rdm_btn_redeem_pharmacy_title")
  /// Submit your prescription to a pharmacy and decide how you would like to receive your medication.
  internal static let rdmBtnRedeemSearchPharmacyDescription = LocalizedStringKey("rdm_btn_redeem_search_pharmacy_description")
  /// I would like to make a reservation or order
  internal static let rdmBtnRedeemSearchPharmacyTitle = LocalizedStringKey("rdm_btn_redeem_search_pharmacy_title")
  /// To the homepage
  internal static let rdmSccBtnReturnToMain = LocalizedStringKey("rdm_scc_btn_return_to_main")
  /// The pharmacy will contact you as soon as possible to verify the delivery details with you.
  internal static let rdmSccTxtDeliveryContent = LocalizedStringKey("rdm_scc_txt_delivery_content")
  /// Successfully redeemed
  internal static let rdmSccTxtDeliveryTitle = LocalizedStringKey("rdm_scc_txt_delivery_title")
  /// Your order will usually be ready for you as soon as possible. Please contact the pharmacy for an exact time.
  internal static let rdmSccTxtOnpremiseContent = LocalizedStringKey("rdm_scc_txt_onpremise_content")
  /// Successfully redeemed
  internal static let rdmSccTxtOnpremiseTitle = LocalizedStringKey("rdm_scc_txt_onpremise_title")
  /// Go to homepage
  internal static let rdmSccTxtShipmentContent1 = LocalizedStringKey("rdm_scc_txt_shipment_content_1")
  /// The mail-order pharmacy will create a shopping cart for you with your medicines. This process may take a few minutes.
  internal static let rdmSccTxtShipmentContent2 = LocalizedStringKey("rdm_scc_txt_shipment_content_2")
  /// Tap "Open shopping cart" and complete your order on the pharmacy's website.
  internal static let rdmSccTxtShipmentContent3 = LocalizedStringKey("rdm_scc_txt_shipment_content_3")
  /// Your next steps
  internal static let rdmSccTxtShipmentTitle = LocalizedStringKey("rdm_scc_txt_shipment_title")
  /// Choose how you would like to redeem your prescription.
  internal static let rdmTxtSubtitle = LocalizedStringKey("rdm_txt_subtitle")
  /// Redeem
  internal static let rdmTxtTitle = LocalizedStringKey("rdm_txt_title")
  /// Not redeemed
  internal static let rphBtnCloseAlertKeep = LocalizedStringKey("rph_btn_close_alert_keep")
  /// Redeemed
  internal static let rphBtnCloseAlertMarkRedeemed = LocalizedStringKey("rph_btn_close_alert_mark_redeemed")
  /// Would you like to mark this prescription as redeemed?
  internal static let rphTxtCloseAlertMessage = LocalizedStringKey("rph_txt_close_alert_message")
  /// Prescription redeemed?
  internal static let rphTxtCloseAlertTitle = LocalizedStringKey("rph_txt_close_alert_title")
  /// Have this prescription code scanned at your pharmacy.
  internal static let rphTxtMatrixcodeHint = LocalizedStringKey("rph_txt_matrixcode_hint")
  /// Have this prescription code scanned at your pharmacy.
  internal static let rphTxtSubtitle = LocalizedStringKey("rph_txt_subtitle")
  /// Prescription code
  internal static let rphTxtTitle = LocalizedStringKey("rph_txt_title")
  /// Cancel scanning
  internal static let scnBtnCancelScan = LocalizedStringKey("scn_btn_cancel_scan")
  /// Plural format key: "%#@variable_0@"
  internal static let scnBtnScanningDone = LocalizedStringKey("scn_btn_scanning_done")
  /// Analysing prescription code
  internal static let scnMsgAnalysingCode = LocalizedStringKey("scn_msg_analysing_code")
  /// An error occurred while saving. Please restart the app.
  internal static let scnMsgSavingError = LocalizedStringKey("scn_msg_saving_error")
  /// This prescription code has already been scanned
  internal static let scnMsgScannedCodeDuplicate = LocalizedStringKey("scn_msg_scanned_code_duplicate")
  /// This is not a valid prescription code
  internal static let scnMsgScannedCodeFailed = LocalizedStringKey("scn_msg_scanned_code_failed")
  /// Prescription code recognised, please do not move the device
  internal static let scnMsgScannedCodeRecognized = LocalizedStringKey("scn_msg_scanned_code_recognized")
  /// This prescription code has already been scanned
  internal static let scnMsgScannedCodeStoreDuplicate = LocalizedStringKey("scn_msg_scanned_code_store_duplicate")
  /// Focus the camera on a prescription code
  internal static let scnMsgScanningCode = LocalizedStringKey("scn_msg_scanning_code")
  /// Ready for another prescription code
  internal static let scnMsgScanningCodeConsecutive = LocalizedStringKey("scn_msg_scanning_code_consecutive")
  /// Scanned prescription
  internal static let scnTxtAuthor = LocalizedStringKey("scn_txt_author")
  /// Medicine %@
  internal static func scnTxtMedication(_ element1: String) -> LocalizedStringKey {
    LocalizedStringKey("scn_txt_medication_\(element1)")
  }
  /// OK
  internal static let secBtnSystemPinDone = LocalizedStringKey("sec_btn_system_pin_done")
  /// Okay
  internal static let secBtnSystemRootDetectionDone = LocalizedStringKey("sec_btn_system_root_detection_done")
  /// Mehr erfahren
  internal static let secBtnSystemRootDetectionMore = LocalizedStringKey("sec_btn_system_root_detection_more")
  /// Hinweis
  internal static let secTxtSystemPinHeadline = LocalizedStringKey("sec_txt_system_pin_headline")
  /// Wir empfehlen Ihnen, Ihre medizinischen Daten zusätzlich durch eine Gerätesicherung wie beispielsweise einen Code oder Biometrie zu schützen.
  internal static let secTxtSystemPinMessage = LocalizedStringKey("sec_txt_system_pin_message")
  /// Diesen Hinweis in Zukunft nicht mehr anzeigen.
  internal static let secTxtSystemPinSelection = LocalizedStringKey("sec_txt_system_pin_selection")
  /// Für dieses Gerät wurde keine Zugangssperre eingerichtet
  internal static let secTxtSystemPinTitle = LocalizedStringKey("sec_txt_system_pin_title")
  /// Weshalb sind Geräte mit Root-Zugriff ein potentielles Sicherheitsrisiko?
  internal static let secTxtSystemRootDetectionFootnote = LocalizedStringKey("sec_txt_system_root_detection_footnote")
  /// Warnung
  internal static let secTxtSystemRootDetectionHeadline = LocalizedStringKey("sec_txt_system_root_detection_headline")
  /// Diese App sollte aus Sicherheitsgründen nicht auf gejailbreakten Geräten genutzt werden.
  internal static let secTxtSystemRootDetectionMessage = LocalizedStringKey("sec_txt_system_root_detection_message")
  /// Ich nehme das erhöhte Risiko zur Kenntnis und möchte dennoch fortfahren.
  internal static let secTxtSystemRootDetectionSelection = LocalizedStringKey("sec_txt_system_root_detection_selection")
  /// Eventuell wurde dieses Gerät gejailbreakt
  internal static let secTxtSystemRootDetectionTitle = LocalizedStringKey("sec_txt_system_root_detection_title")
  /// Ausgewählt
  internal static let sectionTxtIsActiveValue = LocalizedStringKey("section_txt_is_active_value")
  /// Nicht Ausgewählt
  internal static let sectionTxtIsInactiveValue = LocalizedStringKey("section_txt_is_inactive_value")
  /// Ihre Gesundheitskarte ist bereits mit einem anderen Profil verbunden. Wechseln Sie zu Profil %@.
  internal static func sessionErrorCardConnectedWithOtherProfile(_ element1: String) -> LocalizedStringKey {
    LocalizedStringKey("session_error_card_connected_with_other_profile_\(element1)")
  }
  /// Das aktuelle Profil ist bereits mit einer anderen Gesundheitskarte (Krankenversichertennummer: %@) verbunden.
  internal static func sessionErrorCardProfileMismatch(_ element1: String) -> LocalizedStringKey {
    LocalizedStringKey("session_error_card_profile_mismatch_\(element1)")
  }
  /// Es konnte kein ausgewähltes Profil gefunden werden. Bitte wählen Sie ein Profil aus.
  internal static let sessionErrorNoProfile = LocalizedStringKey("session_error_no_profile")
  /// Profil hinzufügen
  internal static let stgBtnAddProfile = LocalizedStringKey("stg_btn_add_profile")
  /// Profil löschen
  internal static let stgBtnEditProfileDelete = LocalizedStringKey("stg_btn_edit_profile_delete")
  /// Abbrechen
  internal static let stgBtnEditProfileDeleteAlertCancel = LocalizedStringKey("stg_btn_edit_profile_delete_alert_cancel")
  /// Anmelden
  internal static let stgBtnEditProfileLogin = LocalizedStringKey("stg_btn_edit_profile_login")
  /// Abmelden
  internal static let stgBtnEditProfileLogout = LocalizedStringKey("stg_btn_edit_profile_logout")
  /// Speichern
  internal static let stgBtnNewProfileCreate = LocalizedStringKey("stg_btn_new_profile_create")
  /// Privacy Policy
  internal static let stgDpoTxtDataPrivacy = LocalizedStringKey("stg_dpo_txt_data_privacy")
  /// Open source licences
  internal static let stgDpoTxtFoss = LocalizedStringKey("stg_dpo_txt_foss")
  /// Terms of Use
  internal static let stgDpoTxtTermsOfUse = LocalizedStringKey("stg_dpo_txt_terms_of_use")
  /// https://www.das-e-rezept-fuer-deutschland.de/
  internal static let stgLnoLinkContact = LocalizedStringKey("stg_lno_link_contact")
  /// Open website
  internal static let stgLnoLinkTextContact = LocalizedStringKey("stg_lno_link_text_contact")
  /// app-feedback@gematik.de
  internal static let stgLnoMailContact = LocalizedStringKey("stg_lno_mail_contact")
  /// Write email
  internal static let stgLnoMailTextContact = LocalizedStringKey("stg_lno_mail_text_contact")
  /// +49-0800-277-3777
  internal static let stgLnoPhoneContact = LocalizedStringKey("stg_lno_phone_contact")
  /// Call technical hotline
  internal static let stgLnoPhoneTextContact = LocalizedStringKey("stg_lno_phone_text_contact")
  /// Imprint
  internal static let stgLnoTxtLegalNotice = LocalizedStringKey("stg_lno_txt_legal_notice")
  /// gematik GmbH\nFriedrichstr. 136\n10117 Berlin, Germany
  internal static let stgLnoTxtTextIssuer = LocalizedStringKey("stg_lno_txt_text_issuer")
  /// We strive to use gender-sensitive language. If you notice any errors, we would be pleased to hear from you by email.
  internal static let stgLnoTxtTextNote = LocalizedStringKey("stg_lno_txt_text_note")
  /// Dr. med. Markus Leyck Dieken
  internal static let stgLnoTxtTextResponsible = LocalizedStringKey("stg_lno_txt_text_responsible")
  /// Managing Director: Dr. med. Markus Leyck Dieken\nRegister Court: Amtsgericht Berlin-Charlottenburg\nCommercial register no.: HRB 96351\nVAT ID: DE241843684
  internal static let stgLnoTxtTextTaxAndMore = LocalizedStringKey("stg_lno_txt_text_taxAndMore")
  /// Contact
  internal static let stgLnoTxtTitleContact = LocalizedStringKey("stg_lno_txt_title_contact")
  /// Publisher
  internal static let stgLnoTxtTitleIssuer = LocalizedStringKey("stg_lno_txt_title_issuer")
  /// Note
  internal static let stgLnoTxtTitleNote = LocalizedStringKey("stg_lno_txt_title_note")
  /// Responsible for the content
  internal static let stgLnoTxtTitleResponsible = LocalizedStringKey("stg_lno_txt_title_responsible")
  /// Deutschlands moderne Plattform für digitale Medizin
  internal static let stgLnoYouKnowUs = LocalizedStringKey("stg_lno_you_know_us")
  /// Access Token
  internal static let stgTknTxtAccessToken = LocalizedStringKey("stg_tkn_txt_access_token")
  /// Token in Zwischenablage kopiert
  internal static let stgTknTxtCopyToClipboard = LocalizedStringKey("stg_tkn_txt_copy_to_clipboard")
  /// SSO Token
  internal static let stgTknTxtSsoToken = LocalizedStringKey("stg_tkn_txt_sso_token")
  /// Tokens
  internal static let stgTknTxtTitleTokens = LocalizedStringKey("stg_tkn_txt_title_tokens")
  /// Decline
  internal static let stgTrkBtnAlertNo = LocalizedStringKey("stg_trk_btn_alert_no")
  /// Agree
  internal static let stgTrkBtnAlertYes = LocalizedStringKey("stg_trk_btn_alert_yes")
  /// Allow anonymous analysis
  internal static let stgTrkBtnTitle = LocalizedStringKey("stg_trk_btn_title")
  /// In order to understand which functions are used frequently, we need your consent to analyse your usage behaviour. This analysis includes information about your phone's hardware and software (device type, operating system version etc.), settings of the e-prescription app as well as the extent of use, but never any personal or health data concerning you. \n\nThis data is made available exclusively to gematik GmbH by data processors and is deleted after 180 days at the latest. You can disable the analysis of your usage behaviour at any time in the settings menu of the app.
  internal static let stgTrkTxtAlertMessage = LocalizedStringKey("stg_trk_txt_alert_message")
  /// Do you consent to the anonymous analysis of usage behaviour by the e-prescription app?
  internal static let stgTrkTxtAlertTitle = LocalizedStringKey("stg_trk_txt_alert_title")
  /// Help us make this app better. All usage data is collected anonymously and is used solely to improve the user experience.
  internal static let stgTrkTxtExplanation = LocalizedStringKey("stg_trk_txt_explanation")
  /// In the event of a crash or an error in the app, the app sends us information about the reasons along with the operating system version and details of the hardware used.
  internal static let stgTrkTxtFootnote = LocalizedStringKey("stg_trk_txt_footnote")
  /// The collection of usage data is disabled in demo mode.
  internal static let stgTrkTxtFootnoteDisabled = LocalizedStringKey("stg_trk_txt_footnote_disabled")
  /// Improve user experience
  internal static let stgTrkTxtTitle = LocalizedStringKey("stg_trk_txt_title")
  /// Demo mode is disabled
  internal static let stgTxtAlertMessageDemoModeOff = LocalizedStringKey("stg_txt_alert_message_demo_mode_off")
  /// Demo mode is active. You do not need a medical card or a connection to the Internet. The displayed test prescriptions cannot be redeemed in a pharmacy.
  internal static let stgTxtAlertMessageDemoModeOn = LocalizedStringKey("stg_txt_alert_message_demo_mode_on")
  /// Would you like a tour of the app?
  internal static let stgTxtAlertTitleDemoMode = LocalizedStringKey("stg_txt_alert_title_demo_mode")
  /// Demo mode
  internal static let stgTxtDemoMode = LocalizedStringKey("stg_txt_demo_mode")
  /// Hintergrundfarbe
  internal static let stgTxtEditProfileBackgroundSectionTitle = LocalizedStringKey("stg_txt_edit_profile_background_section_title")
  /// Hiermit werden alle Daten auf diesem Gerät gelöscht. Ihre Rezepte im Gesundheitsnetzwerk bleiben erhalten.
  internal static let stgTxtEditProfileDeleteConfirmationMessage = LocalizedStringKey("stg_txt_edit_profile_delete_confirmation_message")
  /// Profil löschen?
  internal static let stgTxtEditProfileDeleteConfirmationTitle = LocalizedStringKey("stg_txt_edit_profile_delete_confirmation_title")
  /// Das Namensfeld darf nicht leer sein
  internal static let stgTxtEditProfileEmptyNameErrorMessage = LocalizedStringKey("stg_txt_edit_profile_empty_name_error_message")
  /// Fehler
  internal static let stgTxtEditProfileErrorMessageTitle = LocalizedStringKey("stg_txt_edit_profile_error_message_title")
  /// Hiermit trennen Sie die Verbindung zum Gesundheitsnetzwerk. Sie erhalten keine neuen Rezepte oder Nachrichten.
  internal static let stgTxtEditProfileLogoutInfo = LocalizedStringKey("stg_txt_edit_profile_logout_info")
  /// Name eingeben
  internal static let stgTxtEditProfileNamePlaceholder = LocalizedStringKey("stg_txt_edit_profile_name_placeholder")
  /// Sicherheit
  internal static let stgTxtEditProfileSecuritySectionTitle = LocalizedStringKey("stg_txt_edit_profile_security_section_title")
  /// Zugangsschlüssel zum Rezeptdienst
  internal static let stgTxtEditProfileSecurityShowTokensDescription = LocalizedStringKey("stg_txt_edit_profile_security_show_tokens_description")
  /// Sie erhalten einen Token, wenn Sie am Rezeptdienst angemeldet sind.
  internal static let stgTxtEditProfileSecurityShowTokensHint = LocalizedStringKey("stg_txt_edit_profile_security_show_tokens_hint")
  /// Tokens anzeigen
  internal static let stgTxtEditProfileSecurityShowTokensLabel = LocalizedStringKey("stg_txt_edit_profile_security_show_tokens_label")
  /// Profil
  internal static let stgTxtEditProfileTitle = LocalizedStringKey("stg_txt_edit_profile_title")
  /// Our demo mode shows you all the functions of the app – without a medical card.
  internal static let stgTxtFootnoteDemoMode = LocalizedStringKey("stg_txt_footnote_demo_mode")
  /// Launch demo mode
  internal static let stgTxtHeaderDemoMode = LocalizedStringKey("stg_txt_header_demo_mode")
  /// Legal information
  internal static let stgTxtHeaderLegalInfo = LocalizedStringKey("stg_txt_header_legal_info")
  /// Profile
  internal static let stgTxtHeaderProfiles = LocalizedStringKey("stg_txt_header_profiles")
  /// Security
  internal static let stgTxtHeaderSecurity = LocalizedStringKey("stg_txt_header_security")
  /// Hintergrundfarbe
  internal static let stgTxtNewProfileBackgroundSectionTitle = LocalizedStringKey("stg_txt_new_profile_background_section_title")
  /// Fehler
  internal static let stgTxtNewProfileErrorMessageTitle = LocalizedStringKey("stg_txt_new_profile_error_message_title")
  /// Das Namensfeld darf nicht leer sein
  internal static let stgTxtNewProfileMissingNameError = LocalizedStringKey("stg_txt_new_profile_missing_name_error")
  /// Name eingeben
  internal static let stgTxtNewProfileNamePlaceholder = LocalizedStringKey("stg_txt_new_profile_name_placeholder")
  /// Neues Profil anlegen
  internal static let stgTxtNewProfileTitle = LocalizedStringKey("stg_txt_new_profile_title")
  /// Face ID
  internal static let stgTxtSecurityOptionFaceidTitle = LocalizedStringKey("stg_txt_security_option_faceid_title")
  /// Kennwort
  internal static let stgTxtSecurityOptionPasswordTitle = LocalizedStringKey("stg_txt_security_option_password_title")
  /// Touch ID
  internal static let stgTxtSecurityOptionTouchidTitle = LocalizedStringKey("stg_txt_security_option_touchid_title")
  /// Tokens anzeigen
  internal static let stgTxtSecurityTokens = LocalizedStringKey("stg_txt_security_tokens")
  /// This app has not yet been secured. Improve the protection of your data with a fingerprint or face scan.
  internal static let stgTxtSecurityWarning = LocalizedStringKey("stg_txt_security_warning")
  /// Settings
  internal static let stgTxtTitle = LocalizedStringKey("stg_txt_title")
  /// Version %@ • Build %@
  internal static func stgTxtVersionAndBuild(_ element1: String,_ element2: String) -> LocalizedStringKey {
    LocalizedStringKey("stg_txt_version_\(element1)_and_build_\(element2)")
  }
  /// Prescriptions
  internal static let tabTxtMain = LocalizedStringKey("tab_txt_main")
  /// Messages
  internal static let tabTxtMessages = LocalizedStringKey("tab_txt_messages")
  /// Apotheken
  internal static let tabTxtPharmacySearch = LocalizedStringKey("tab_txt_pharmacy_search")
  /// Einstellungen
  internal static let tabTxtSettings = LocalizedStringKey("tab_txt_settings")
}
// swiftlint:enable function_parameter_count identifier_name line_length type_body_length


