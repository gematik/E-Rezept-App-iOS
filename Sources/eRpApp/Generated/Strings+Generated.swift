// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import SwiftUI

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable function_parameter_count identifier_name line_length type_body_length
internal enum L10n {
  /// E-Rezept
  internal static let cfBundleDisplayName = StringAsset("CFBundleDisplayName")
  /// Allows you to identify and authenticate yourself by using your health insurance card
  internal static let nfcReaderUsageDescription = StringAsset("NFCReaderUsageDescription")
  /// E-Rezept needs access to your camera so that it can read your prescriptions
  internal static let nsCameraUsageDescription = StringAsset("NSCameraUsageDescription")
  /// E-Rezept uses FaceID to protect your app from unauthorized access.
  internal static let nsFaceIDUsageDescription = StringAsset("NSFaceIDUsageDescription")
  /// Reject
  internal static let alertBtnClose = StringAsset("alert_btn_close")
  /// OK
  internal static let alertBtnOk = StringAsset("alert_btn_ok")
  /// Unknown
  internal static let alertErrorMessageUnknown = StringAsset("alert_error_message_unknown")
  /// Error
  internal static let alertErrorTitle = StringAsset("alert_error_title")
  /// Abbrechen
  internal static let amgBtnAlertCancel = StringAsset("amg_btn_alert_cancel")
  /// Daten löschen
  internal static let amgBtnAlertDeleteDatabase = StringAsset("amg_btn_alert_delete_database")
  /// Wiederholen
  internal static let amgBtnAlertRetry = StringAsset("amg_btn_alert_retry")
  /// Aktualisierung fehlgeschlagen
  internal static let amgBtnAlertTitle = StringAsset("amg_btn_alert_title")
  /// Falls dieser Fehler wiederholt auftritt, bitte die App löschen und neu installieren
  internal static let amgTxtAlertMessageDeleteDatabase = StringAsset("amg_txt_alert_message_delete_database")
  /// Löschen fehlgeschlagen
  internal static let amgTxtAlertTitleDeleteDatabase = StringAsset("amg_txt_alert_title_delete_database")
  /// Aktualisieren...
  internal static let amgTxtInProgress = StringAsset("amg_txt_in_progress")
  /// Unlock with Face ID
  internal static let authBtnBiometricsFaceid = StringAsset("auth_btn_biometrics_faceid")
  /// Unlock with Touch ID
  internal static let authBtnBiometricsTouchid = StringAsset("auth_btn_biometrics_touchid")
  /// Weiter
  internal static let authBtnPasswordContinue = StringAsset("auth_btn_password_continue")
  /// You have selected Face ID to secure your data.
  internal static let authTxtBiometricsFaceidDescription = StringAsset("auth_txt_biometrics_faceid_description")
  /// Unlock with Face ID
  internal static let authTxtBiometricsFaceidStart = StringAsset("auth_txt_biometrics_faceid_start")
  /// Authentication failed
  internal static let authTxtBiometricsFailedAuthenticationFailed = StringAsset("auth_txt_biometrics_failed_authentication_failed")
  /// Login failed
  internal static let authTxtBiometricsFailedDefault = StringAsset("auth_txt_biometrics_failed_default")
  /// No biometric security has been set up on this device.
  internal static let authTxtBiometricsFailedNotEnrolled = StringAsset("auth_txt_biometrics_failed_not_enrolled")
  /// An alternative login method is not supported.
  internal static let authTxtBiometricsFailedUserFallback = StringAsset("auth_txt_biometrics_failed_user_fallback")
  /// Do you have any questions or problems concerning use of the app? You can contact our technical hotline on 0800 277 377 7. \n\nWe have already answered plenty of questions for you at das-e-rezept-fuer-deutschland.de.
  internal static let authTxtBiometricsFooter = StringAsset("auth_txt_biometrics_footer")
  /// app-feedback@gematik.de
  internal static let authTxtBiometricsFooterEmailDisplay = StringAsset("auth_txt_biometrics_footer_email_display")
  /// mailto:app-feedback@gematik.de
  internal static let authTxtBiometricsFooterEmailLink = StringAsset("auth_txt_biometrics_footer_email_link")
  /// das-e-rezept-fuer-deutschland.de
  internal static let authTxtBiometricsFooterUrlDisplay = StringAsset("auth_txt_biometrics_footer_url_display")
  /// https://www.das-e-rezept-fuer-deutschland.de
  internal static let authTxtBiometricsFooterUrlLink = StringAsset("auth_txt_biometrics_footer_url_link")
  /// Sie hatten zu viele fehlerhafte Anmeldeversuche. Gehen Sie in die Einstellungen ihres iPhones und reaktivieren sie die FaceID oder TouchID Funktion durch eine PIN Eingabe.
  internal static let authTxtBiometricsLockout = StringAsset("auth_txt_biometrics_lockout")
  /// %@ is required to protect the app from unauthorised access.
  internal static let authTxtBiometricsReason = StringAsset("auth_txt_biometrics_reason")
  /// Welcome
  internal static let authTxtBiometricsTitle = StringAsset("auth_txt_biometrics_title")
  /// You have selected Touch ID to secure your data.
  internal static let authTxtBiometricsTouchidDescription = StringAsset("auth_txt_biometrics_touchid_description")
  /// Unlock with Touch ID
  internal static let authTxtBiometricsTouchidStart = StringAsset("auth_txt_biometrics_touchid_start")
  /// Plural format key: "%#@variable_0@"
  internal static let authTxtFailedLoginHintMsg = StringAsset("auth_txt_failed_login_hint_msg")
  /// Erfolglose Anmeldeversuche
  internal static let authTxtFailedLoginHintTitle = StringAsset("auth_txt_failed_login_hint_title")
  /// Falsches Kennwort. Bitte probieren Sie es erneut.
  internal static let authTxtPasswordFailure = StringAsset("auth_txt_password_failure")
  /// Eingabefeld Kennwort
  internal static let authTxtPasswordLabel = StringAsset("auth_txt_password_label")
  /// Kennwort eingeben
  internal static let authTxtPasswordPlaceholder = StringAsset("auth_txt_password_placeholder")
  /// Demo mode enabled
  internal static let bnrTxtDemoMode = StringAsset("bnr_txt_demo_mode")
  /// inaktiv
  internal static let buttonTxtIsInactiveValue = StringAsset("button_txt_is_inactive_value")
  /// To use the scanner, you must allow the app to access your camera in the system settings.
  internal static let camInitFailMessage = StringAsset("cam_init_fail_message")
  /// Access to camera denied
  internal static let camInitFailTitle = StringAsset("cam_init_fail_title")
  /// Allow
  internal static let camPermDenyBtnSettings = StringAsset("cam_perm_deny_btn_settings")
  /// The app must be able to access the device camera in order to use the scanner.
  internal static let camPermDenyMessage = StringAsset("cam_perm_deny_message")
  /// Allow access to camera?
  internal static let camPermDenyTitle = StringAsset("cam_perm_deny_title")
  /// OK
  internal static let camTxtWarnCancel = StringAsset("cam_txt_warn_cancel")
  /// Cancel scanning?
  internal static let camTxtWarnCancelTitle = StringAsset("cam_txt_warn_cancel_title")
  /// Don't cancel
  internal static let camTxtWarnContinue = StringAsset("cam_txt_warn_continue")
  /// Close dialog
  internal static let cdwBtnBiometryCancelLabel = StringAsset("cdw_btn_biometry_cancel_label")
  /// Next
  internal static let cdwBtnBiometryContinue = StringAsset("cdw_btn_biometry_continue")
  /// Next
  internal static let cdwBtnBiometryContinueLabel = StringAsset("cdw_btn_biometry_continue_label")
  /// Agreed
  internal static let cdwBtnBiometrySecurityWarningAccept = StringAsset("cdw_btn_biometry_security_warning_accept")
  /// Cancel
  internal static let cdwBtnCanCancelLabel = StringAsset("cdw_btn_can_cancel_label")
  /// Next
  internal static let cdwBtnCanDone = StringAsset("cdw_btn_can_done")
  /// Next
  internal static let cdwBtnCanDoneLabel = StringAsset("cdw_btn_can_done_label")
  /// The access number consists of 6 digits; you have entered %@.
  internal static func cdwBtnCanDoneLabelError(_ element1: String) -> StringAsset {
    StringAsset("cdw_btn_can_done_label_error_%@", arguments: [element1])
  }
  /// Schließen
  internal static let cdwBtnExtauthAlertSaveProfile = StringAsset("cdw_btn_extauth_alert_save_profile")
  /// Abbrechen
  internal static let cdwBtnExtauthConfirmCancel = StringAsset("cdw_btn_extauth_confirm_cancel")
  /// Technischen Kundendienst kontaktieren
  internal static let cdwBtnExtauthConfirmContact = StringAsset("cdw_btn_extauth_confirm_contact")
  /// Senden
  internal static let cdwBtnExtauthConfirmSend = StringAsset("cdw_btn_extauth_confirm_send")
  /// Gesundheitskarte bestellen
  internal static let cdwBtnExtauthFallbackOrderEgk = StringAsset("cdw_btn_extauth_fallback_order_egk")
  /// Abbrechen
  internal static let cdwBtnExtauthSelectionCancel = StringAsset("cdw_btn_extauth_selection_cancel")
  /// Weiter
  internal static let cdwBtnExtauthSelectionContinue = StringAsset("cdw_btn_extauth_selection_continue")
  /// Gesundheitskarte bestellen
  internal static let cdwBtnExtauthSelectionOrderEgk = StringAsset("cdw_btn_extauth_selection_order_egk")
  /// Erneut versuchen
  internal static let cdwBtnExtauthSelectionRetry = StringAsset("cdw_btn_extauth_selection_retry")
  /// Close dialog
  internal static let cdwBtnIntroCancelLabel = StringAsset("cdw_btn_intro_cancel_label")
  /// Find out more
  internal static let cdwBtnIntroMore = StringAsset("cdw_btn_intro_more")
  /// Let's get started
  internal static let cdwBtnIntroNext = StringAsset("cdw_btn_intro_next")
  /// Close dialog
  internal static let cdwBtnNfuCancelLabel = StringAsset("cdw_btn_nfu_cancel_label")
  /// Back to the homepage
  internal static let cdwBtnNfuDone = StringAsset("cdw_btn_nfu_done")
  /// Find out more
  internal static let cdwBtnNfuMore = StringAsset("cdw_btn_nfu_more")
  /// Cancel
  internal static let cdwBtnPinCancelLabel = StringAsset("cdw_btn_pin_cancel_label")
  /// Next
  internal static let cdwBtnPinDone = StringAsset("cdw_btn_pin_done")
  /// Next
  internal static let cdwBtnPinDoneLabel = StringAsset("cdw_btn_pin_done_label")
  /// Abbrechen
  internal static let cdwBtnRcAlertCancel = StringAsset("cdw_btn_rc_alert_cancel")
  /// Schließen
  internal static let cdwBtnRcAlertClose = StringAsset("cdw_btn_rc_alert_close")
  /// Schließen
  internal static let cdwBtnRcAlertSaveProfile = StringAsset("cdw_btn_rc_alert_save_profile")
  /// Zurück
  internal static let cdwBtnRcBack = StringAsset("cdw_btn_rc_back")
  /// Close dialog
  internal static let cdwBtnRcCancelLabel = StringAsset("cdw_btn_rc_cancel_label")
  /// Close
  internal static let cdwBtnRcClose = StringAsset("cdw_btn_rc_close")
  /// Enter correct access number
  internal static let cdwBtnRcCorrectCan = StringAsset("cdw_btn_rc_correct_can")
  /// Enter correct PIN
  internal static let cdwBtnRcCorrectPin = StringAsset("cdw_btn_rc_correct_pin")
  /// Loading
  internal static let cdwBtnRcLoading = StringAsset("cdw_btn_rc_loading")
  /// Next
  internal static let cdwBtnRcNext = StringAsset("cdw_btn_rc_next")
  /// As soon as this button is pressed, the medical card is read via NFC. To do this, hold the card directly against the device. If the connection is successful, you will receive tactile feedback. Any interruptions to the connection or errors are also communicated via tactile feedback. Communication with the medical card can take up to ten seconds. Then remove the medical card from the device.
  internal static let cdwBtnRcNextHint = StringAsset("cdw_btn_rc_next_hint")
  /// Repeat
  internal static let cdwBtnRcRetry = StringAsset("cdw_btn_rc_retry")
  /// Videoanleitung ansehen
  internal static let cdwBtnRcVideo = StringAsset("cdw_btn_rc_video")
  /// Weiter
  internal static let cdwBtnSelContinue = StringAsset("cdw_btn_sel_continue")
  /// Please enter your PIN here
  internal static let cdwEdtPinInput = StringAsset("cdw_edt_pin_input")
  /// Find out more
  internal static let cdwHintCanOrderEgkBtn = StringAsset("cdw_hint_can_order_egk_btn")
  /// Your health insurance company will be able to help you with this.
  internal static let cdwHintCanOrderEgkMessage = StringAsset("cdw_hint_can_order_egk_message")
  /// How do I get a new medical card?
  internal static let cdwHintCanOrderEgkTitle = StringAsset("cdw_hint_can_order_egk_title")
  /// Find out more
  internal static let cdwHintPinBtn = StringAsset("cdw_hint_pin_btn")
  /// You will receive a PIN for your medical card from your health insurance company.
  internal static let cdwHintPinMsg = StringAsset("cdw_hint_pin_msg")
  /// How do I get a PIN?
  internal static let cdwHintPinTitle = StringAsset("cdw_hint_pin_title")
  /// Illustration einer Gesundheitskarte. Die Zugangsnummer finden Sie rechts oben auf der Vorderseite der Gesundheitskarte.
  internal static let cdwImgCanCardLabel = StringAsset("cdw_img_can_card_label")
  /// Illustration of a user holding their medical card to the back of their smartphone.
  internal static let cdwImgIntroMainLabel = StringAsset("cdw_img_intro_main_label")
  /// Your selection will not be saved.
  internal static let cdwTxtBiometryDemoModeInfo = StringAsset("cdw_txt_biometry_demo_mode_info")
  /// Log in conveniently with fingerprint or face scan
  internal static let cdwTxtBiometryOptionBiometryDescription = StringAsset("cdw_txt_biometry_option_biometry_description")
  /// Save login details
  internal static let cdwTxtBiometryOptionBiometryTitle = StringAsset("cdw_txt_biometry_option_biometry_title")
  /// Requires you to enter your login details each time you launch the app
  internal static let cdwTxtBiometryOptionNoneDescription = StringAsset("cdw_txt_biometry_option_none_description")
  /// Do not save login details
  internal static let cdwTxtBiometryOptionNoneTitle = StringAsset("cdw_txt_biometry_option_none_title")
  /// This app uses Face ID or Touch ID to store your login data in a protected area of the device memory.\n\nAvoid installation on the following devices:\n* Devices on which a so-called "jailbreak" has been carried out.\n* Work devices with administration rights by the employer (COPE "Corporate Owned, Personally Enabled" or BYOD "Bring Your Own Device")\nVirtual environments (emulators) that make Android available on other platforms.\n\nPlease be aware that people with whom you may share this device and whose biometrics may be stored on this device may also have access to your prescriptions.
  internal static let cdwTxtBiometrySecurityWarningDescription = StringAsset("cdw_txt_biometry_security_warning_description")
  /// Security notice
  internal static let cdwTxtBiometrySecurityWarningTitle = StringAsset("cdw_txt_biometry_security_warning_title")
  /// Would you like to save your login details for future logins?
  internal static let cdwTxtBiometrySubtitle = StringAsset("cdw_txt_biometry_subtitle")
  /// Login
  internal static let cdwTxtBiometryTitle = StringAsset("cdw_txt_biometry_title")
  /// You can enter any digits.
  internal static let cdwTxtCanDemoModeInfo = StringAsset("cdw_txt_can_demo_mode_info")
  /// Your card access number (CAN) has 6 digits. You will find the CAN in the top right-hand corner on the front of your medical card. If there is no six-digit access number here, you will need a new medical card from your health insurance company.
  internal static let cdwTxtCanInputLabel = StringAsset("cdw_txt_can_input_label")
  /// Enter access number
  internal static let cdwTxtCanSubtitle = StringAsset("cdw_txt_can_subtitle")
  /// Login
  internal static let cdwTxtCanTitle = StringAsset("cdw_txt_can_title")
  /// Ihre Kartenzugangsnummer (Card Access Number, kurz: CAN) hat 6 Stellen. Sie finden die CAN in der rechten oberen Ecke der Vorderseite Ihrer Gesundheitskarte. Steht hier keine sechsstellige Zugangsnummer, benötigen Sie eine neue Gesundheitskarte von Ihrer Krankenversicherung.
  internal static let cdwTxtCanTitleHint = StringAsset("cdw_txt_can_title_hint")
  /// Unfortunately, the CAN entered does not match the recognised card. Please enter the CAN again. Thank you!
  internal static let cdwTxtCanWarnWrongDescription = StringAsset("cdw_txt_can_warn_wrong_description")
  /// Incorrect CAN
  internal static let cdwTxtCanWarnWrongTitle = StringAsset("cdw_txt_can_warn_wrong_title")
  /// Ihre Gesundheitskarte konnte nicht mit dem Profil verknüpft werden.
  internal static let cdwTxtExtauthAlertMessageSaveProfile = StringAsset("cdw_txt_extauth_alert_message_save_profile")
  /// Fehler beim Speichern des Profils
  internal static let cdwTxtExtauthAlertTitleSaveProfile = StringAsset("cdw_txt_extauth_alert_title_save_profile")
  /// Mail
  internal static let cdwTxtExtauthConfirmContactsheetMail = StringAsset("cdw_txt_extauth_confirm_contactsheet_mail")
  /// Telefon
  internal static let cdwTxtExtauthConfirmContactsheetTelephone = StringAsset("cdw_txt_extauth_confirm_contactsheet_telephone")
  /// Kundendienst kontaktieren
  internal static let cdwTxtExtauthConfirmContactsheetTitle = StringAsset("cdw_txt_extauth_confirm_contactsheet_title")
  /// Wir fragen nun die Authentisierung bei Ihrer Krankenversicherung an.
  internal static let cdwTxtExtauthConfirmDescription = StringAsset("cdw_txt_extauth_confirm_description")
  /// Bitte erwähnen Sie diesen Fehler gegenüber unserem technischen Kundendienst, um die Suche nach einer Lösung zu erleichtern.
  internal static let cdwTxtExtauthConfirmErrorDescription = StringAsset("cdw_txt_extauth_confirm_error_description")
  /// Authentisierung wird angefragt
  internal static let cdwTxtExtauthConfirmHeadline = StringAsset("cdw_txt_extauth_confirm_headline")
  /// E-Rezept
  internal static let cdwTxtExtauthConfirmOwnAppname = StringAsset("cdw_txt_extauth_confirm_own_appname")
  /// Mit App anmelden
  internal static let cdwTxtExtauthConfirmTitle = StringAsset("cdw_txt_extauth_confirm_title")
  /// Fehler beim Öffnen der Krankenkassenapp.
  internal static let cdwTxtExtauthConfirmUniversalLinkFailedError = StringAsset("cdw_txt_extauth_confirm_universal_link_failed_error")
  /// Derzeit bereiten sich die Krankenkassen auf diese Funktion vor.
  internal static let cdwTxtExtauthFallbackDescription1 = StringAsset("cdw_txt_extauth_fallback_description1")
  /// Sie wollen nicht warten? Die Anmeldung mit Gesundheitskarte wird bereits jetzt von jeder Krankenkasse unterstützt.
  internal static let cdwTxtExtauthFallbackDescription2 = StringAsset("cdw_txt_extauth_fallback_description2")
  /// Versicherung wählen
  internal static let cdwTxtExtauthFallbackHeadline = StringAsset("cdw_txt_extauth_fallback_headline")
  /// Mit App anmelden
  internal static let cdwTxtExtauthFallbackTitle = StringAsset("cdw_txt_extauth_fallback_title")
  /// Nicht fündig geworden? Diese Liste wird ständig erweitert. Die Anmeldung mit Gesundheitskarte wird bereits jetzt von jeder Krankenkasse unterstützt.
  internal static let cdwTxtExtauthSelectionDescription = StringAsset("cdw_txt_extauth_selection_description")
  /// Bitte probieren Sie es zu einem späteren Zeitpunkt erneut.
  internal static let cdwTxtExtauthSelectionErrorFallback = StringAsset("cdw_txt_extauth_selection_error_fallback")
  /// Versicherung wählen
  internal static let cdwTxtExtauthSelectionHeadline = StringAsset("cdw_txt_extauth_selection_headline")
  /// Mit App Anmelden
  internal static let cdwTxtExtauthSelectionTitle = StringAsset("cdw_txt_extauth_selection_title")
  /// To be able to use all functions of the app, log in with your medical card. You will receive this card and the required login details from your health insurance company.
  internal static let cdwTxtIntroDescription = StringAsset("cdw_txt_intro_description")
  /// Use all functions now
  internal static let cdwTxtIntroHeaderBottom = StringAsset("cdw_txt_intro_header_bottom")
  /// Login
  internal static let cdwTxtIntroHeaderTop = StringAsset("cdw_txt_intro_header_top")
  /// What you need:
  internal static let cdwTxtIntroListTitle = StringAsset("cdw_txt_intro_list_title")
  /// A medical card with access number (CAN)
  internal static let cdwTxtIntroRequirementCard = StringAsset("cdw_txt_intro_requirement_card")
  /// An NFC-enabled device with iOS 14
  internal static let cdwTxtIntroRequirementPhone = StringAsset("cdw_txt_intro_requirement_phone")
  /// The PIN for the medical card
  internal static let cdwTxtIntroRequirementPin = StringAsset("cdw_txt_intro_requirement_pin")
  /// Unfortunately, your device does not meet the minimum requirements for logging into the e-prescription app.
  internal static let cdwTxtNfuDescription = StringAsset("cdw_txt_nfu_description")
  /// Why are there minimum requirements for logging on with your medical card?
  internal static let cdwTxtNfuFootnote = StringAsset("cdw_txt_nfu_footnote")
  /// What a pity ...
  internal static let cdwTxtNfuSubtitle = StringAsset("cdw_txt_nfu_subtitle")
  /// Login
  internal static let cdwTxtNfuTitle = StringAsset("cdw_txt_nfu_title")
  /// You can enter any digits.
  internal static let cdwTxtPinDemoModeInfo = StringAsset("cdw_txt_pin_demo_mode_info")
  /// Your PIN can have between 6 and 8 digits.
  internal static let cdwTxtPinHint = StringAsset("cdw_txt_pin_hint")
  /// Geben Sie bitte Ihre PIN ein. Ihre PIN wurde Ihnen per Post zugestellt. Die PIN ist 6 bis 8 stellig.
  internal static let cdwTxtPinInputLabel = StringAsset("cdw_txt_pin_input_label")
  /// Enter PIN
  internal static let cdwTxtPinSubtitle = StringAsset("cdw_txt_pin_subtitle")
  /// Login
  internal static let cdwTxtPinTitle = StringAsset("cdw_txt_pin_title")
  /// Unfortunately, the PIN entered does not match the recognised card. Are you sure you entered the PIN you received from your health insurance company?
  internal static let cdwTxtPinWarnWrongDescription = StringAsset("cdw_txt_pin_warn_wrong_description")
  /// Incorrect PIN
  internal static let cdwTxtPinWarnWrongTitle = StringAsset("cdw_txt_pin_warn_wrong_title")
  /// A PIN consists of digits only.
  internal static let cdwTxtPinWarningChar = StringAsset("cdw_txt_pin_warning_char")
  /// The PIN consists of 6 to 8 digits; you have entered %@.
  internal static func cdwTxtPinWarningCount(_ element1: String) -> StringAsset {
    StringAsset("cdw_txt_pin_warning_count %@", arguments: [element1])
  }
  /// Ihre Gesundheitskarte konnte nicht mit dem Profil verknüpft werden.
  internal static let cdwTxtRcAlertMessageSaveProfile = StringAsset("cdw_txt_rc_alert_message_save_profile")
  /// Fehler beim Speichern des Profils
  internal static let cdwTxtRcAlertTitleSaveProfile = StringAsset("cdw_txt_rc_alert_title_save_profile")
  /// Halten Sie jetzt Ihre Karte auf das Display und drücken Sie auf “Karte verbinden”
  internal static let cdwTxtRcCta = StringAsset("cdw_txt_rc_cta")
  /// You do not need a medical card in demo mode.
  internal static let cdwTxtRcDemoModeInfo = StringAsset("cdw_txt_rc_demo_mode_info")
  /// Click Login and hold your card against the device as shown. Do not move the card once a connection has been established.
  internal static let cdwTxtRcDescription = StringAsset("cdw_txt_rc_description")
  /// Error reading the medical card
  internal static let cdwTxtRcErrorGenericCardDescription = StringAsset("cdw_txt_rc_error_generic_card_description")
  /// Please try again
  internal static let cdwTxtRcErrorGenericCardRecovery = StringAsset("cdw_txt_rc_error_generic_card_recovery")
  /// Incorrect access number
  internal static let cdwTxtRcErrorWrongCanDescription = StringAsset("cdw_txt_rc_error_wrong_can_description")
  /// Please enter the correct access number (CAN)
  internal static let cdwTxtRcErrorWrongCanRecovery = StringAsset("cdw_txt_rc_error_wrong_can_recovery")
  /// Incorrect pin
  internal static func cdwTxtRcErrorWrongPinDescription(_ element1: String) -> StringAsset {
    StringAsset("cdw_txt_rc_error_wrong_pin_description_%@", arguments: [element1])
  }
  /// %@ attempts left. Please enter the correct PIN.
  internal static func cdwTxtRcErrorWrongPinRecovery(_ element1: String) -> StringAsset {
    StringAsset("cdw_txt_rc_error_wrong_pin_recovery_%@", arguments: [element1])
  }
  /// Have your medical card ready
  internal static let cdwTxtRcHeadline = StringAsset("cdw_txt_rc_headline")
  /// Connection interrupted
  internal static let cdwTxtRcNfcDialogCancel = StringAsset("cdw_txt_rc_nfc_dialog_cancel")
  /// Establishing a secure connection
  internal static let cdwTxtRcNfcDialogOpenPace = StringAsset("cdw_txt_rc_nfc_dialog_open_pace")
  /// Authentication
  internal static let cdwTxtRcNfcDialogSignChallenge = StringAsset("cdw_txt_rc_nfc_dialog_sign_challenge")
  /// Medical card successfully read
  internal static let cdwTxtRcNfcDialogSuccess = StringAsset("cdw_txt_rc_nfc_dialog_success")
  /// Verifying PIN
  internal static let cdwTxtRcNfcDialogVerifyPin = StringAsset("cdw_txt_rc_nfc_dialog_verify_pin")
  /// Connection failed
  internal static let cdwTxtRcNfcMessageConnectionErrorMessage = StringAsset("cdw_txt_rc_nfc_message_connectionErrorMessage")
  /// Medical card found. Please do not move.
  internal static let cdwTxtRcNfcMessageConnectMessage = StringAsset("cdw_txt_rc_nfc_message_connectMessage")
  /// Hold your medical card to the back of the device
  internal static let cdwTxtRcNfcMessageDiscoveryMessage = StringAsset("cdw_txt_rc_nfc_message_discoveryMessage")
  /// Several medical cards found
  internal static let cdwTxtRcNfcMessageMultipleCardsMessage = StringAsset("cdw_txt_rc_nfc_message_multipleCardsMessage")
  /// No medical card found
  internal static let cdwTxtRcNfcMessageNoCardMessage = StringAsset("cdw_txt_rc_nfc_message_noCardMessage")
  /// This card type is not supported
  internal static let cdwTxtRcNfcMessageUnsupportedCardMessage = StringAsset("cdw_txt_rc_nfc_message_unsupportedCardMessage")
  /// Hier anlegen 👆
  internal static let cdwTxtRcPlacement = StringAsset("cdw_txt_rc_placement")
  /// Login
  internal static let cdwTxtRcTitle = StringAsset("cdw_txt_rc_title")
  /// Wählen Sie eine Anmeldemethode um automatisch Rezepte zu empfangen.
  internal static let cdwTxtSelDescription = StringAsset("cdw_txt_sel_description")
  /// Sichere Anmeldung mit Ihrer neuen elektronischen Gesundheitskarte
  internal static let cdwTxtSelEgkDescription = StringAsset("cdw_txt_sel_egk_description")
  /// Mit Gesundheitskarte anmelden
  internal static let cdwTxtSelEgkTitle = StringAsset("cdw_txt_sel_egk_title")
  /// Wie möchten Sie sich anmelden?
  internal static let cdwTxtSelHeadline = StringAsset("cdw_txt_sel_headline")
  /// Nutzen Sie eine App Ihrer Krankenversicherung zur Freischaltung
  internal static let cdwTxtSelKkappComingSoonDescription = StringAsset("cdw_txt_sel_kkapp_coming_soon_description")
  /// Nächstes Jahr: Mit Kassen-App anmelden
  internal static let cdwTxtSelKkappComingSoonTitle = StringAsset("cdw_txt_sel_kkapp_coming_soon_title")
  /// Nutzen Sie eine App Ihrer Krankenversicherung zur Freischaltung
  internal static let cdwTxtSelKkappDescription = StringAsset("cdw_txt_sel_kkapp_description")
  /// Mit Kassen-App anmelden
  internal static let cdwTxtSelKkappTitle = StringAsset("cdw_txt_sel_kkapp_title")
  /// Anmeldung
  internal static let cdwTxtSelTitle = StringAsset("cdw_txt_sel_title")
  /// Zuletzt aktualisiert %@
  internal static func cpnTxtRelativeTimerViewLastUpdate(_ element1: String) -> StringAsset {
    StringAsset("cpn_txt_relative_timer_view_last_update_%@", arguments: [element1])
  }
  /// vor wenigen Sekunden
  internal static let cpnTxtRelativeTimerViewLastUpdateRecent = StringAsset("cpn_txt_relative_timer_view_last_update_recent")
  /// Speichern
  internal static let cpwBtnAltAuthSave = StringAsset("cpw_btn_alt_auth_save")
  /// Neues Kennwort speichern
  internal static let cpwBtnChange = StringAsset("cpw_btn_change")
  /// Kennwort speichern
  internal static let cpwBtnSave = StringAsset("cpw_btn_save")
  /// Aktuelles Kennwort
  internal static let cpwInpCurrentPasswordPlaceholder = StringAsset("cpw_inp_current_password_placeholder")
  /// Kennwort eingeben
  internal static let cpwInpPasswordAPlaceholder = StringAsset("cpw_inp_passwordA_placeholder")
  /// Kennwort wiederholen
  internal static let cpwInpPasswordBPlaceholder = StringAsset("cpw_inp_passwordB_placeholder")
  /// Das Kennwort ist falsch.
  internal static let cpwTxtCurrentPasswordWrong = StringAsset("cpw_txt_current_password_wrong")
  /// Empfehlung: Möglichst wenige Worte und keine Redewendungen verwenden.\nSymbole, Zahlen oder Großbuchstaben sind nicht notwendig.
  internal static let cpwTxtPasswordRecommendation = StringAsset("cpw_txt_password_recommendation")
  /// Sicherheitsstufe des gewählten Kennworts nicht ausreichend
  internal static let cpwTxtPasswordStrengthInsufficient = StringAsset("cpw_txt_password_strength_insufficient")
  /// Zweite Eingabe des Kennwortes, um Tippfehler zu erkennen
  internal static let cpwTxtPasswordBAccessibility = StringAsset("cpw_txt_passwordB_accessibility")
  /// Die Eingaben weichen voneinander ab.
  internal static let cpwTxtPasswordsDontMatch = StringAsset("cpw_txt_passwords_dont_match")
  /// Neues Kennwort
  internal static let cpwTxtSectionTitle = StringAsset("cpw_txt_section_title")
  /// Altes Kennwort
  internal static let cpwTxtSectionUpdateTitle = StringAsset("cpw_txt_section_update_title")
  /// Kennwort
  internal static let cpwTxtTitle = StringAsset("cpw_txt_title")
  /// Kennwort ändern
  internal static let cpwTxtUpdateTitle = StringAsset("cpw_txt_update_title")
  /// Bild bearbeiten
  internal static let ctlBtnProfilePickerEdit = StringAsset("ctl_btn_profile_picker_edit")
  /// Bild zurücksetzen
  internal static let ctlBtnProfilePickerReset = StringAsset("ctl_btn_profile_picker_reset")
  /// Speichern
  internal static let ctlBtnProfilePickerSet = StringAsset("ctl_btn_profile_picker_set")
  /// Aktuelles Profil
  internal static let ctlBtnProfileToolbarItem = StringAsset("ctl_btn_profile_toolbar_item")
  /// Abbrechen
  internal static let ctlBtnSearchBarCancel = StringAsset("ctl_btn_search_bar_cancel")
  /// Text löschen
  internal static let ctlBtnSearchBarDeleteTextLabel = StringAsset("ctl_btn_search_bar_delete_text_label")
  /// Kennwortstärke
  internal static let ctlTxtPasswordStrength0 = StringAsset("ctl_txt_password_strength_0")
  /// Kennwortstärke
  internal static let ctlTxtPasswordStrength1 = StringAsset("ctl_txt_password_strength_1")
  /// Kennwortstärke ausreichend
  internal static let ctlTxtPasswordStrength2 = StringAsset("ctl_txt_password_strength_2")
  /// Kennwortstärke gut
  internal static let ctlTxtPasswordStrength3 = StringAsset("ctl_txt_password_strength_3")
  /// Kennwortstärke sehr gut
  internal static let ctlTxtPasswordStrength4 = StringAsset("ctl_txt_password_strength_4")
  /// Kennwortstärke exzellent
  internal static let ctlTxtPasswordStrength5 = StringAsset("ctl_txt_password_strength_5")
  /// Ok
  internal static let ctlTxtPasswordStrengthAccessiblityValueMedium = StringAsset("ctl_txt_password_strength_accessiblity_value_medium")
  /// Stark
  internal static let ctlTxtPasswordStrengthAccessiblityValueStrong = StringAsset("ctl_txt_password_strength_accessiblity_value_strong")
  /// Sehr Stark
  internal static let ctlTxtPasswordStrengthAccessiblityValueVeryStrong = StringAsset("ctl_txt_password_strength_accessiblity_value_very_strong")
  /// Sehr schwach
  internal static let ctlTxtPasswordStrengthAccessiblityValueVeryWeak = StringAsset("ctl_txt_password_strength_accessiblity_value_very_weak")
  /// Schwach
  internal static let ctlTxtPasswordStrengthAccessiblityValueWeak = StringAsset("ctl_txt_password_strength_accessiblity_value_weak")
  /// Nicht angemeldet
  internal static let ctlTxtProfileCellNotConnected = StringAsset("ctl_txt_profile__cell_not_connected")
  /// Blau
  internal static let ctlTxtProfileColorPickerBlue = StringAsset("ctl_txt_profile_color_picker_blue")
  /// Grün
  internal static let ctlTxtProfileColorPickerGreen = StringAsset("ctl_txt_profile_color_picker_green")
  /// Grau
  internal static let ctlTxtProfileColorPickerGrey = StringAsset("ctl_txt_profile_color_picker_grey")
  /// Rosa
  internal static let ctlTxtProfileColorPickerPink = StringAsset("ctl_txt_profile_color_picker_pink")
  /// Ausgewählt
  internal static let ctlTxtProfileColorPickerSelected = StringAsset("ctl_txt_profile_color_picker_selected")
  /// Gelb
  internal static let ctlTxtProfileColorPickerYellow = StringAsset("ctl_txt_profile_color_picker_yellow")
  /// Suchfeld
  internal static let ctlTxtSearchBarFieldLabel = StringAsset("ctl_txt_search_bar_field_label")
  /// Copy
  internal static let dtlBtnCopyClipboard = StringAsset("dtl_btn_copy_clipboard")
  /// Delete from this device
  internal static let dtlBtnDeleteMedication = StringAsset("dtl_btn_delete_medication")
  /// Order
  internal static let dtlBtnPharmacySearch = StringAsset("dtl_btn_pharmacy_search")
  /// Mark as redeemed
  internal static let dtlBtnToogleMarkRedeemed = StringAsset("dtl_btn_toogle_mark_redeemed")
  /// Mark as not redeemed
  internal static let dtlBtnToogleMarkedRedeemed = StringAsset("dtl_btn_toogle_marked_redeemed")
  /// Access code
  internal static let dtlTxtAccessCode = StringAsset("dtl_txt_access_code")
  /// Do you want to permanently delete this prescription?
  internal static let dtlTxtDeleteAlertMessage = StringAsset("dtl_txt_delete_alert_message")
  /// Delete this prescription?
  internal static let dtlTxtDeleteAlertTitle = StringAsset("dtl_txt_delete_alert_title")
  /// The connection to the server was lost. Please log in again.
  internal static let dtlTxtDeleteMissingTokenAlertMessage = StringAsset("dtl_txt_delete_missing_token_alert_message")
  /// Deletion failed
  internal static let dtlTxtDeleteMissingTokenAlertTitle = StringAsset("dtl_txt_delete_missing_token_alert_title")
  /// Cancel
  internal static let dtlTxtDeleteNo = StringAsset("dtl_txt_delete_no")
  /// Delete
  internal static let dtlTxtDeleteYes = StringAsset("dtl_txt_delete_yes")
  /// Mark this prescription as redeemed as soon as you have received your medication.
  internal static let dtlTxtHintOverviewMessage = StringAsset("dtl_txt_hint_overview_message")
  /// Keep track of things
  internal static let dtlTxtHintOverviewTitle = StringAsset("dtl_txt_hint_overview_title")
  /// Technical information
  internal static let dtlTxtMedInfo = StringAsset("dtl_txt_med_info")
  /// Log
  internal static let dtlTxtMedProtocol = StringAsset("dtl_txt_med_protocol")
  /// Eingelöst: %@
  internal static func dtlTxtMedRedeemedOn(_ element1: String) -> StringAsset {
    StringAsset("dtl_txt_med_redeemed_on_%@", arguments: [element1])
  }
  /// Scanned on
  internal static let dtlTxtScannedOn = StringAsset("dtl_txt_scanned_on")
  /// Task ID
  internal static let dtlTxtTaskId = StringAsset("dtl_txt_task_id")
  /// Details
  internal static let dtlTxtTitle = StringAsset("dtl_txt_title")
  /// Fehler beim Zugriff auf die Datenbank
  internal static let errTxtDatabaseAccess = StringAsset("err_txt_database_access")
  /// Redeem all
  internal static let erxBtnRedeem = StringAsset("erx_btn_redeem")
  /// Update
  internal static let erxBtnRefresh = StringAsset("erx_btn_refresh")
  /// Open prescription scanner
  internal static let erxBtnScnPrescription = StringAsset("erx_btn_scn_prescription")
  /// Prescriptions
  internal static let erxTitle = StringAsset("erx_title")
  /// Plural format key: "%#@variable_0@"
  internal static let erxTxtAcceptedUntil = StringAsset("erx_txt_accepted_until")
  /// Current
  internal static let erxTxtCurrent = StringAsset("erx_txt_current")
  /// Plural format key: "%#@v1_days_variable@"
  internal static let erxTxtExpiresIn = StringAsset("erx_txt_expires_in")
  /// Nicht mehr gültig
  internal static let erxTxtInvalid = StringAsset("erx_txt_invalid")
  /// Unknown medicine
  internal static let erxTxtMedicationPlaceholder = StringAsset("erx_txt_medication_placeholder")
  /// You do not have any current prescriptions
  internal static let erxTxtNoCurrentPrescriptions = StringAsset("erx_txt_no_current_prescriptions")
  /// You haven't redeemed any prescriptions yet
  internal static let erxTxtNotYetRedeemed = StringAsset("erx_txt_not_yet_redeemed")
  /// Archive
  internal static let erxTxtRedeemed = StringAsset("erx_txt_redeemed")
  /// Loading ...
  internal static let erxTxtRefreshLoading = StringAsset("erx_txt_refresh_loading")
  /// Open scanner
  internal static let hintBtnOpenScn = StringAsset("hint_btn_open_scn")
  /// Launch demo mode
  internal static let hintBtnTryDemoMode = StringAsset("hint_btn_try_demo_mode")
  /// View new messages now
  internal static let hintBtnUnreadMessages = StringAsset("hint_btn_unread_messages")
  /// Our demo mode shows you all the functions of the app – without a medical card.
  internal static let hintTxtDemoMode = StringAsset("hint_txt_demo_mode")
  /// Would you like a tour of the app?
  internal static let hintTxtDemoModeTitle = StringAsset("hint_txt_demo_mode_title")
  /// Scan the prescription code to add it.
  internal static let hintTxtOpenScn = StringAsset("hint_txt_open_scn")
  /// New prescription
  internal static let hintTxtOpenScnTitle = StringAsset("hint_txt_open_scn_title")
  /// Für die Anmeldung benötigen Sie eine geeignete Karte mit NFC. Wir unterstützen Sie bei der Bestellung
  internal static let hintTxtOrderEgk = StringAsset("hint_txt_order_egk")
  /// Fortfahren
  internal static let hintTxtOrderEgkButton = StringAsset("hint_txt_order_egk_button")
  /// Neue Gesundheitskarte bestellen
  internal static let hintTxtOrderEgkTitel = StringAsset("hint_txt_order_egk_titel")
  /// Our demo mode shows you all the functions of the app – without a medical card.
  internal static let hintTxtTryDemoMode = StringAsset("hint_txt_try_demo_mode")
  /// You have received a new message from the health network.
  internal static let hintTxtUnreadMessages = StringAsset("hint_txt_unread_messages")
  /// New messages
  internal static let hintTxtUnreadMessagesTitle = StringAsset("hint_txt_unread_messages_title")
  /// Essential oil
  internal static let kbvCodeDosageFormAeo = StringAsset("kbv_code_dosage_form_aeo")
  /// Ampoules
  internal static let kbvCodeDosageFormAmp = StringAsset("kbv_code_dosage_form_amp")
  /// Pairs of ampoules
  internal static let kbvCodeDosageFormApa = StringAsset("kbv_code_dosage_form_apa")
  /// Eye and nose ointment
  internal static let kbvCodeDosageFormAsn = StringAsset("kbv_code_dosage_form_asn")
  /// Eye and ear ointment
  internal static let kbvCodeDosageFormAso = StringAsset("kbv_code_dosage_form_aso")
  /// Eye and ear drops
  internal static let kbvCodeDosageFormAto = StringAsset("kbv_code_dosage_form_ato")
  /// Eye drops
  internal static let kbvCodeDosageFormAtr = StringAsset("kbv_code_dosage_form_atr")
  /// Eye bath
  internal static let kbvCodeDosageFormAub = StringAsset("kbv_code_dosage_form_aub")
  /// Eye cream
  internal static let kbvCodeDosageFormAuc = StringAsset("kbv_code_dosage_form_auc")
  /// Eye gel
  internal static let kbvCodeDosageFormAug = StringAsset("kbv_code_dosage_form_aug")
  /// Eye ointment
  internal static let kbvCodeDosageFormAus = StringAsset("kbv_code_dosage_form_aus")
  /// Bath
  internal static let kbvCodeDosageFormBad = StringAsset("kbv_code_dosage_form_bad")
  /// Balsam
  internal static let kbvCodeDosageFormBal = StringAsset("kbv_code_dosage_form_bal")
  /// Bandage
  internal static let kbvCodeDosageFormBan = StringAsset("kbv_code_dosage_form_ban")
  /// Sachet
  internal static let kbvCodeDosageFormBeu = StringAsset("kbv_code_dosage_form_beu")
  /// Bindings
  internal static let kbvCodeDosageFormBin = StringAsset("kbv_code_dosage_form_bin")
  /// Sweets
  internal static let kbvCodeDosageFormBon = StringAsset("kbv_code_dosage_form_bon")
  /// Base plate
  internal static let kbvCodeDosageFormBpl = StringAsset("kbv_code_dosage_form_bpl")
  /// Puree
  internal static let kbvCodeDosageFormBre = StringAsset("kbv_code_dosage_form_bre")
  /// Effervescent tablets
  internal static let kbvCodeDosageFormBta = StringAsset("kbv_code_dosage_form_bta")
  /// Cream
  internal static let kbvCodeDosageFormCre = StringAsset("kbv_code_dosage_form_cre")
  /// Vials
  internal static let kbvCodeDosageFormDfl = StringAsset("kbv_code_dosage_form_dfl")
  /// Dilution
  internal static let kbvCodeDosageFormDil = StringAsset("kbv_code_dosage_form_dil")
  /// Depot injection suspension
  internal static let kbvCodeDosageFormDis = StringAsset("kbv_code_dosage_form_dis")
  /// Dragées in calendar pack
  internal static let kbvCodeDosageFormDka = StringAsset("kbv_code_dosage_form_dka")
  /// Metered dose inhaler
  internal static let kbvCodeDosageFormDos = StringAsset("kbv_code_dosage_form_dos")
  /// Dragées
  internal static let kbvCodeDosageFormDra = StringAsset("kbv_code_dosage_form_dra")
  /// Enteric-coated dragées
  internal static let kbvCodeDosageFormDrm = StringAsset("kbv_code_dosage_form_drm")
  /// Metered-dose foam
  internal static let kbvCodeDosageFormDsc = StringAsset("kbv_code_dosage_form_dsc")
  /// Metered-dose spray
  internal static let kbvCodeDosageFormDss = StringAsset("kbv_code_dosage_form_dss")
  /// Single-dose pipettes
  internal static let kbvCodeDosageFormEdp = StringAsset("kbv_code_dosage_form_edp")
  /// Lotion
  internal static let kbvCodeDosageFormEin = StringAsset("kbv_code_dosage_form_ein")
  /// Electrodes
  internal static let kbvCodeDosageFormEle = StringAsset("kbv_code_dosage_form_ele")
  /// Elixir
  internal static let kbvCodeDosageFormEli = StringAsset("kbv_code_dosage_form_eli")
  /// Emulsion
  internal static let kbvCodeDosageFormEmu = StringAsset("kbv_code_dosage_form_emu")
  /// Essence
  internal static let kbvCodeDosageFormEss = StringAsset("kbv_code_dosage_form_ess")
  /// Adult suppositories
  internal static let kbvCodeDosageFormEsu = StringAsset("kbv_code_dosage_form_esu")
  /// Extract
  internal static let kbvCodeDosageFormExt = StringAsset("kbv_code_dosage_form_ext")
  /// Filter bags
  internal static let kbvCodeDosageFormFbe = StringAsset("kbv_code_dosage_form_fbe")
  /// Rubbing alcohol
  internal static let kbvCodeDosageFormFbw = StringAsset("kbv_code_dosage_form_fbw")
  /// Film-coated dragées
  internal static let kbvCodeDosageFormFda = StringAsset("kbv_code_dosage_form_fda")
  /// Ready-to-fill syringes
  internal static let kbvCodeDosageFormFer = StringAsset("kbv_code_dosage_form_fer")
  /// Grease ointment
  internal static let kbvCodeDosageFormFet = StringAsset("kbv_code_dosage_form_fet")
  /// Bottle
  internal static let kbvCodeDosageFormFla = StringAsset("kbv_code_dosage_form_fla")
  /// Oral liquid
  internal static let kbvCodeDosageFormFle = StringAsset("kbv_code_dosage_form_fle")
  /// Liquid
  internal static let kbvCodeDosageFormFlu = StringAsset("kbv_code_dosage_form_flu")
  /// Enteric-resistant film-coated tablets
  internal static let kbvCodeDosageFormFmr = StringAsset("kbv_code_dosage_form_fmr")
  /// Foil
  internal static let kbvCodeDosageFormFol = StringAsset("kbv_code_dosage_form_fol")
  /// Sachet of sustained release film-coated tablets
  internal static let kbvCodeDosageFormFrb = StringAsset("kbv_code_dosage_form_frb")
  /// Liquid soap
  internal static let kbvCodeDosageFormFse = StringAsset("kbv_code_dosage_form_fse")
  /// Film-coated tablet
  internal static let kbvCodeDosageFormFta = StringAsset("kbv_code_dosage_form_fta")
  /// Granules in capsules for opening
  internal static let kbvCodeDosageFormGek = StringAsset("kbv_code_dosage_form_gek")
  /// Gel
  internal static let kbvCodeDosageFormGel = StringAsset("kbv_code_dosage_form_gel")
  /// Gas and solvent for the preparation of an injection/infusion dispersion
  internal static let kbvCodeDosageFormGli = StringAsset("kbv_code_dosage_form_gli")
  /// Globules
  internal static let kbvCodeDosageFormGlo = StringAsset("kbv_code_dosage_form_glo")
  /// Enteric-resistant granules
  internal static let kbvCodeDosageFormGmr = StringAsset("kbv_code_dosage_form_gmr")
  /// Gel plate
  internal static let kbvCodeDosageFormGpa = StringAsset("kbv_code_dosage_form_gpa")
  /// Granules
  internal static let kbvCodeDosageFormGra = StringAsset("kbv_code_dosage_form_gra")
  /// Granules for the preparation of an oral suspension
  internal static let kbvCodeDosageFormGse = StringAsset("kbv_code_dosage_form_gse")
  /// Gargling solution
  internal static let kbvCodeDosageFormGul = StringAsset("kbv_code_dosage_form_gul")
  /// Glove
  internal static let kbvCodeDosageFormHas = StringAsset("kbv_code_dosage_form_has")
  /// Enteric-resistant hard capsules
  internal static let kbvCodeDosageFormHkm = StringAsset("kbv_code_dosage_form_hkm")
  /// Hard capsules
  internal static let kbvCodeDosageFormHkp = StringAsset("kbv_code_dosage_form_hkp")
  /// Hard capsules with powder for inhalation
  internal static let kbvCodeDosageFormHpi = StringAsset("kbv_code_dosage_form_hpi")
  /// Modified-release hard capsules
  internal static let kbvCodeDosageFormHvw = StringAsset("kbv_code_dosage_form_hvw")
  /// Infusion ampoules
  internal static let kbvCodeDosageFormIfa = StringAsset("kbv_code_dosage_form_ifa")
  /// Infusion bag
  internal static let kbvCodeDosageFormIfb = StringAsset("kbv_code_dosage_form_ifb")
  /// Infusion dispersion
  internal static let kbvCodeDosageFormIfd = StringAsset("kbv_code_dosage_form_ifd")
  /// Solution for injection in a ready-to-fill syringe
  internal static let kbvCodeDosageFormIfe = StringAsset("kbv_code_dosage_form_ife")
  /// Infusion bottles
  internal static let kbvCodeDosageFormIff = StringAsset("kbv_code_dosage_form_iff")
  /// Infusion solution concentrate
  internal static let kbvCodeDosageFormIfk = StringAsset("kbv_code_dosage_form_ifk")
  /// Injection bottles
  internal static let kbvCodeDosageFormIfl = StringAsset("kbv_code_dosage_form_ifl")
  /// Infusion set
  internal static let kbvCodeDosageFormIfs = StringAsset("kbv_code_dosage_form_ifs")
  /// Inhalation ampoules
  internal static let kbvCodeDosageFormIha = StringAsset("kbv_code_dosage_form_iha")
  /// Inhalation powder
  internal static let kbvCodeDosageFormIhp = StringAsset("kbv_code_dosage_form_ihp")
  /// Injection or infusion solution or oral solution
  internal static let kbvCodeDosageFormIie = StringAsset("kbv_code_dosage_form_iie")
  /// Solution for injection/infusion
  internal static let kbvCodeDosageFormIil = StringAsset("kbv_code_dosage_form_iil")
  /// Solution for injection for intramuscular use
  internal static let kbvCodeDosageFormIim = StringAsset("kbv_code_dosage_form_iim")
  /// Inhalation capsules
  internal static let kbvCodeDosageFormIka = StringAsset("kbv_code_dosage_form_ika")
  /// Injection solution
  internal static let kbvCodeDosageFormIlo = StringAsset("kbv_code_dosage_form_ilo")
  /// Implant
  internal static let kbvCodeDosageFormImp = StringAsset("kbv_code_dosage_form_imp")
  /// Infusion solution
  internal static let kbvCodeDosageFormInf = StringAsset("kbv_code_dosage_form_inf")
  /// Inhalant
  internal static let kbvCodeDosageFormInh = StringAsset("kbv_code_dosage_form_inh")
  /// Injection and infusion bottles
  internal static let kbvCodeDosageFormIni = StringAsset("kbv_code_dosage_form_ini")
  /// Inhalation solution
  internal static let kbvCodeDosageFormInl = StringAsset("kbv_code_dosage_form_inl")
  /// Instant tea
  internal static let kbvCodeDosageFormIns = StringAsset("kbv_code_dosage_form_ins")
  /// Instillation
  internal static let kbvCodeDosageFormIst = StringAsset("kbv_code_dosage_form_ist")
  /// Injection suspension
  internal static let kbvCodeDosageFormIsu = StringAsset("kbv_code_dosage_form_isu")
  /// Intrauterine device
  internal static let kbvCodeDosageFormIup = StringAsset("kbv_code_dosage_form_iup")
  /// Cannulas
  internal static let kbvCodeDosageFormKan = StringAsset("kbv_code_dosage_form_kan")
  /// Capsules
  internal static let kbvCodeDosageFormKap = StringAsset("kbv_code_dosage_form_kap")
  /// Catheter
  internal static let kbvCodeDosageFormKat = StringAsset("kbv_code_dosage_form_kat")
  /// Chews
  internal static let kbvCodeDosageFormKda = StringAsset("kbv_code_dosage_form_kda")
  /// Cone
  internal static let kbvCodeDosageFormKeg = StringAsset("kbv_code_dosage_form_keg")
  /// Kernels
  internal static let kbvCodeDosageFormKer = StringAsset("kbv_code_dosage_form_ker")
  /// Chewing gum
  internal static let kbvCodeDosageFormKgu = StringAsset("kbv_code_dosage_form_kgu")
  /// Concentrate for the preparation of an infusion dispersion
  internal static let kbvCodeDosageFormKid = StringAsset("kbv_code_dosage_form_kid")
  /// Concentrate for the preparation of an injection or infusion solution
  internal static let kbvCodeDosageFormKii = StringAsset("kbv_code_dosage_form_kii")
  /// Infant suppositories
  internal static let kbvCodeDosageFormKks = StringAsset("kbv_code_dosage_form_kks")
  /// Enemas
  internal static let kbvCodeDosageFormKli = StringAsset("kbv_code_dosage_form_kli")
  /// Enema tablets
  internal static let kbvCodeDosageFormKlt = StringAsset("kbv_code_dosage_form_klt")
  /// Hard capsules with enteric-coated pellets
  internal static let kbvCodeDosageFormKmp = StringAsset("kbv_code_dosage_form_kmp")
  /// Enteric-resistant capsules
  internal static let kbvCodeDosageFormKmr = StringAsset("kbv_code_dosage_form_kmr")
  /// Condoms
  internal static let kbvCodeDosageFormKod = StringAsset("kbv_code_dosage_form_kod")
  /// Compresses
  internal static let kbvCodeDosageFormKom = StringAsset("kbv_code_dosage_form_kom")
  /// Concentrate
  internal static let kbvCodeDosageFormKon = StringAsset("kbv_code_dosage_form_kon")
  /// Combination pack
  internal static let kbvCodeDosageFormKpg = StringAsset("kbv_code_dosage_form_kpg")
  /// Crystal suspension
  internal static let kbvCodeDosageFormKri = StringAsset("kbv_code_dosage_form_kri")
  /// Children's and infant suppositories
  internal static let kbvCodeDosageFormKss = StringAsset("kbv_code_dosage_form_kss")
  /// Children's suppositories
  internal static let kbvCodeDosageFormKsu = StringAsset("kbv_code_dosage_form_ksu")
  /// Chewable tablets
  internal static let kbvCodeDosageFormKta = StringAsset("kbv_code_dosage_form_kta")
  /// Lancets
  internal static let kbvCodeDosageFormLan = StringAsset("kbv_code_dosage_form_lan")
  /// Solution for injection, infusion and inhalation
  internal static let kbvCodeDosageFormLii = StringAsset("kbv_code_dosage_form_lii")
  /// Liquid paraffin
  internal static let kbvCodeDosageFormLiq = StringAsset("kbv_code_dosage_form_liq")
  /// Solution
  internal static let kbvCodeDosageFormLoe = StringAsset("kbv_code_dosage_form_loe")
  /// Lotion
  internal static let kbvCodeDosageFormLot = StringAsset("kbv_code_dosage_form_lot")
  /// Nebuliser solution
  internal static let kbvCodeDosageFormLov = StringAsset("kbv_code_dosage_form_lov")
  /// Oral solution
  internal static let kbvCodeDosageFormLse = StringAsset("kbv_code_dosage_form_lse")
  /// Lacquer tablets
  internal static let kbvCodeDosageFormLta = StringAsset("kbv_code_dosage_form_lta")
  /// Hard pastilles
  internal static let kbvCodeDosageFormLup = StringAsset("kbv_code_dosage_form_lup")
  /// Lozenges
  internal static let kbvCodeDosageFormLut = StringAsset("kbv_code_dosage_form_lut")
  /// Milk
  internal static let kbvCodeDosageFormMil = StringAsset("kbv_code_dosage_form_mil")
  /// Blend
  internal static let kbvCodeDosageFormMis = StringAsset("kbv_code_dosage_form_mis")
  /// Mixture
  internal static let kbvCodeDosageFormMix = StringAsset("kbv_code_dosage_form_mix")
  /// Enteric-resistant sustained-release granules
  internal static let kbvCodeDosageFormMrg = StringAsset("kbv_code_dosage_form_mrg")
  /// Enteric-resistant pellets
  internal static let kbvCodeDosageFormMrp = StringAsset("kbv_code_dosage_form_mrp")
  /// Coated tablets
  internal static let kbvCodeDosageFormMta = StringAsset("kbv_code_dosage_form_mta")
  /// Mouthwash
  internal static let kbvCodeDosageFormMuw = StringAsset("kbv_code_dosage_form_muw")
  /// Nasal gel
  internal static let kbvCodeDosageFormNag = StringAsset("kbv_code_dosage_form_nag")
  /// Nose oil
  internal static let kbvCodeDosageFormNao = StringAsset("kbv_code_dosage_form_nao")
  /// Nasal spray
  internal static let kbvCodeDosageFormNas = StringAsset("kbv_code_dosage_form_nas")
  /// Nail varnish containing active ingredients
  internal static let kbvCodeDosageFormNaw = StringAsset("kbv_code_dosage_form_naw")
  /// Nasal dosing spray
  internal static let kbvCodeDosageFormNds = StringAsset("kbv_code_dosage_form_nds")
  /// Nasal ointment
  internal static let kbvCodeDosageFormNsa = StringAsset("kbv_code_dosage_form_nsa")
  /// Nasal drops
  internal static let kbvCodeDosageFormNtr = StringAsset("kbv_code_dosage_form_ntr")
  /// Occusert
  internal static let kbvCodeDosageFormOcu = StringAsset("kbv_code_dosage_form_ocu")
  /// Oil
  internal static let kbvCodeDosageFormOel = StringAsset("kbv_code_dosage_form_oel")
  /// Ear drops
  internal static let kbvCodeDosageFormOht = StringAsset("kbv_code_dosage_form_oht")
  /// Ovula
  internal static let kbvCodeDosageFormOvu = StringAsset("kbv_code_dosage_form_ovu")
  /// Packing dimensions
  internal static let kbvCodeDosageFormPam = StringAsset("kbv_code_dosage_form_pam")
  /// Pastilles
  internal static let kbvCodeDosageFormPas = StringAsset("kbv_code_dosage_form_pas")
  /// Pellets
  internal static let kbvCodeDosageFormPel = StringAsset("kbv_code_dosage_form_pel")
  /// Solution for injection in a pre-filled pen
  internal static let kbvCodeDosageFormPen = StringAsset("kbv_code_dosage_form_pen")
  /// Beads
  internal static let kbvCodeDosageFormPer = StringAsset("kbv_code_dosage_form_per")
  /// Plaster
  internal static let kbvCodeDosageFormPfl = StringAsset("kbv_code_dosage_form_pfl")
  /// Transdermal patch
  internal static let kbvCodeDosageFormPft = StringAsset("kbv_code_dosage_form_pft")
  /// Powder for the preparation of a solution for injection, infusion or inhalation
  internal static let kbvCodeDosageFormPhi = StringAsset("kbv_code_dosage_form_phi")
  /// Powder for the preparation of an injection or infusion solution or powder and solvent for the preparation of a solution for intravesical use.
  internal static let kbvCodeDosageFormPhv = StringAsset("kbv_code_dosage_form_phv")
  /// Powder for a concentrate for an infusion solution Powder for the preparation of an oral solution
  internal static let kbvCodeDosageFormPie = StringAsset("kbv_code_dosage_form_pie")
  /// Powder for the preparation of an infusion solution
  internal static let kbvCodeDosageFormPif = StringAsset("kbv_code_dosage_form_pif")
  /// Powder for the preparation of an injection or infusion solution
  internal static let kbvCodeDosageFormPii = StringAsset("kbv_code_dosage_form_pii")
  /// Powder for the preparation of an injection solution
  internal static let kbvCodeDosageFormPij = StringAsset("kbv_code_dosage_form_pij")
  /// Powder for the preparation of an infusion solution concentrate
  internal static let kbvCodeDosageFormPik = StringAsset("kbv_code_dosage_form_pik")
  /// Powder for the preparation of an infusion suspension
  internal static let kbvCodeDosageFormPis = StringAsset("kbv_code_dosage_form_pis")
  /// Powder for the preparation of an injection or infusion solution or a solution for intravesical use
  internal static let kbvCodeDosageFormPiv = StringAsset("kbv_code_dosage_form_piv")
  /// Powder for a concentrate for the preparation of an infusion solution
  internal static let kbvCodeDosageFormPki = StringAsset("kbv_code_dosage_form_pki")
  /// Powder for the preparation of an oral solution
  internal static let kbvCodeDosageFormPle = StringAsset("kbv_code_dosage_form_ple")
  /// Powder and solvent for the preparation of an infusion solution
  internal static let kbvCodeDosageFormPlf = StringAsset("kbv_code_dosage_form_plf")
  /// Perlongets
  internal static let kbvCodeDosageFormPlg = StringAsset("kbv_code_dosage_form_plg")
  /// Powder and solvent for the preparation of an injection or infusion solution
  internal static let kbvCodeDosageFormPlh = StringAsset("kbv_code_dosage_form_plh")
  /// Powder and solvent for the preparation of an injection solution
  internal static let kbvCodeDosageFormPli = StringAsset("kbv_code_dosage_form_pli")
  /// Powder and solvent for a concentrate for the preparation of an infusion solution
  internal static let kbvCodeDosageFormPlk = StringAsset("kbv_code_dosage_form_plk")
  /// Powder and solvent for the preparation of an injection suspension
  internal static let kbvCodeDosageFormPls = StringAsset("kbv_code_dosage_form_pls")
  /// Powder and solvent for the preparation of a solution for intravesical use
  internal static let kbvCodeDosageFormPlv = StringAsset("kbv_code_dosage_form_plv")
  /// Pump solution
  internal static let kbvCodeDosageFormPpl = StringAsset("kbv_code_dosage_form_ppl")
  /// Pellets
  internal static let kbvCodeDosageFormPrs = StringAsset("kbv_code_dosage_form_prs")
  /// Powder for the preparation of an oral suspension
  internal static let kbvCodeDosageFormPse = StringAsset("kbv_code_dosage_form_pse")
  /// Paste
  internal static let kbvCodeDosageFormPst = StringAsset("kbv_code_dosage_form_pst")
  /// Powder for external use
  internal static let kbvCodeDosageFormPud = StringAsset("kbv_code_dosage_form_pud")
  /// Powder
  internal static let kbvCodeDosageFormPul = StringAsset("kbv_code_dosage_form_pul")
  /// Sustained-release dragées
  internal static let kbvCodeDosageFormRed = StringAsset("kbv_code_dosage_form_red")
  /// Sustained-release capsules
  internal static let kbvCodeDosageFormRek = StringAsset("kbv_code_dosage_form_rek")
  /// Sustained-release tablets
  internal static let kbvCodeDosageFormRet = StringAsset("kbv_code_dosage_form_ret")
  /// Sustained-release granules
  internal static let kbvCodeDosageFormRgr = StringAsset("kbv_code_dosage_form_rgr")
  /// Rectal capsules
  internal static let kbvCodeDosageFormRka = StringAsset("kbv_code_dosage_form_rka")
  /// Sustained-release microcapsules and suspension agents
  internal static let kbvCodeDosageFormRms = StringAsset("kbv_code_dosage_form_rms")
  /// Rectal foam
  internal static let kbvCodeDosageFormRsc = StringAsset("kbv_code_dosage_form_rsc")
  /// Rectal suspension
  internal static let kbvCodeDosageFormRsu = StringAsset("kbv_code_dosage_form_rsu")
  /// Sustained-release coated tablets
  internal static let kbvCodeDosageFormRut = StringAsset("kbv_code_dosage_form_rut")
  /// Juice
  internal static let kbvCodeDosageFormSaf = StringAsset("kbv_code_dosage_form_saf")
  /// Ointment
  internal static let kbvCodeDosageFormSal = StringAsset("kbv_code_dosage_form_sal")
  /// Ointment for use in the oral cavity
  internal static let kbvCodeDosageFormSam = StringAsset("kbv_code_dosage_form_sam")
  /// Foam
  internal static let kbvCodeDosageFormSch = StringAsset("kbv_code_dosage_form_sch")
  /// Soap
  internal static let kbvCodeDosageFormSei = StringAsset("kbv_code_dosage_form_sei")
  /// Shampoo
  internal static let kbvCodeDosageFormSha = StringAsset("kbv_code_dosage_form_sha")
  /// Syrup
  internal static let kbvCodeDosageFormSir = StringAsset("kbv_code_dosage_form_sir")
  /// Salt
  internal static let kbvCodeDosageFormSlz = StringAsset("kbv_code_dosage_form_slz")
  /// Orodispersible film
  internal static let kbvCodeDosageFormSmf = StringAsset("kbv_code_dosage_form_smf")
  /// Orodispersible tablets
  internal static let kbvCodeDosageFormSmt = StringAsset("kbv_code_dosage_form_smt")
  /// Suppositories with gauze inlay
  internal static let kbvCodeDosageFormSmu = StringAsset("kbv_code_dosage_form_smu")
  /// Injection ampoules
  internal static let kbvCodeDosageFormSpa = StringAsset("kbv_code_dosage_form_spa")
  /// Spray bottle
  internal static let kbvCodeDosageFormSpf = StringAsset("kbv_code_dosage_form_spf")
  /// Rinsing solution
  internal static let kbvCodeDosageFormSpl = StringAsset("kbv_code_dosage_form_spl")
  /// Spray
  internal static let kbvCodeDosageFormSpr = StringAsset("kbv_code_dosage_form_spr")
  /// Transdermal spray
  internal static let kbvCodeDosageFormSpt = StringAsset("kbv_code_dosage_form_spt")
  /// Syringes
  internal static let kbvCodeDosageFormSri = StringAsset("kbv_code_dosage_form_sri")
  /// Infant suppositories
  internal static let kbvCodeDosageFormSsu = StringAsset("kbv_code_dosage_form_ssu")
  /// Lancing ampoules
  internal static let kbvCodeDosageFormSta = StringAsset("kbv_code_dosage_form_sta")
  /// Sticks
  internal static let kbvCodeDosageFormStb = StringAsset("kbv_code_dosage_form_stb")
  /// Pens
  internal static let kbvCodeDosageFormSti = StringAsset("kbv_code_dosage_form_sti")
  /// Strips
  internal static let kbvCodeDosageFormStr = StringAsset("kbv_code_dosage_form_str")
  /// Substance
  internal static let kbvCodeDosageFormSub = StringAsset("kbv_code_dosage_form_sub")
  /// Oral suspension
  internal static let kbvCodeDosageFormSue = StringAsset("kbv_code_dosage_form_sue")
  /// Sublingual spray solution
  internal static let kbvCodeDosageFormSul = StringAsset("kbv_code_dosage_form_sul")
  /// Suppositories
  internal static let kbvCodeDosageFormSup = StringAsset("kbv_code_dosage_form_sup")
  /// Suspension
  internal static let kbvCodeDosageFormSus = StringAsset("kbv_code_dosage_form_sus")
  /// Sublingual tablets
  internal static let kbvCodeDosageFormSut = StringAsset("kbv_code_dosage_form_sut")
  /// Suspension for a nebuliser
  internal static let kbvCodeDosageFormSuv = StringAsset("kbv_code_dosage_form_suv")
  /// Sponges
  internal static let kbvCodeDosageFormSwa = StringAsset("kbv_code_dosage_form_swa")
  /// Pills
  internal static let kbvCodeDosageFormTab = StringAsset("kbv_code_dosage_form_tab")
  /// Tablets
  internal static let kbvCodeDosageFormTae = StringAsset("kbv_code_dosage_form_tae")
  /// Dry ampoules
  internal static let kbvCodeDosageFormTam = StringAsset("kbv_code_dosage_form_tam")
  /// Tea
  internal static let kbvCodeDosageFormTee = StringAsset("kbv_code_dosage_form_tee")
  /// Oral drops
  internal static let kbvCodeDosageFormTei = StringAsset("kbv_code_dosage_form_tei")
  /// Test
  internal static let kbvCodeDosageFormTes = StringAsset("kbv_code_dosage_form_tes")
  /// Tincture
  internal static let kbvCodeDosageFormTin = StringAsset("kbv_code_dosage_form_tin")
  /// Tablets in calendar pack
  internal static let kbvCodeDosageFormTka = StringAsset("kbv_code_dosage_form_tka")
  /// Tablet for the preparation of an oral solution
  internal static let kbvCodeDosageFormTle = StringAsset("kbv_code_dosage_form_tle")
  /// Enteric-resistant tablets
  internal static let kbvCodeDosageFormTmr = StringAsset("kbv_code_dosage_form_tmr")
  /// Tonic
  internal static let kbvCodeDosageFormTon = StringAsset("kbv_code_dosage_form_ton")
  /// Tampon
  internal static let kbvCodeDosageFormTpn = StringAsset("kbv_code_dosage_form_tpn")
  /// Tamponades
  internal static let kbvCodeDosageFormTpo = StringAsset("kbv_code_dosage_form_tpo")
  /// Drinking ampoules
  internal static let kbvCodeDosageFormTra = StringAsset("kbv_code_dosage_form_tra")
  /// Trituration
  internal static let kbvCodeDosageFormTri = StringAsset("kbv_code_dosage_form_tri")
  /// Drops
  internal static let kbvCodeDosageFormTro = StringAsset("kbv_code_dosage_form_tro")
  /// Dry substance with solvent
  internal static let kbvCodeDosageFormTrs = StringAsset("kbv_code_dosage_form_trs")
  /// Drinking tablets
  internal static let kbvCodeDosageFormTrt = StringAsset("kbv_code_dosage_form_trt")
  /// Dry syrup
  internal static let kbvCodeDosageFormTsa = StringAsset("kbv_code_dosage_form_tsa")
  /// Tablets for the preparation of an oral suspension for a dosing dispenser
  internal static let kbvCodeDosageFormTsd = StringAsset("kbv_code_dosage_form_tsd")
  /// Tablet for the preparation of an oral suspension
  internal static let kbvCodeDosageFormTse = StringAsset("kbv_code_dosage_form_tse")
  /// Dry substance without solvent
  internal static let kbvCodeDosageFormTss = StringAsset("kbv_code_dosage_form_tss")
  /// Test sticks
  internal static let kbvCodeDosageFormTst = StringAsset("kbv_code_dosage_form_tst")
  /// Transdermal system
  internal static let kbvCodeDosageFormTsy = StringAsset("kbv_code_dosage_form_tsy")
  /// Test strips
  internal static let kbvCodeDosageFormTtr = StringAsset("kbv_code_dosage_form_ttr")
  /// Tube
  internal static let kbvCodeDosageFormTub = StringAsset("kbv_code_dosage_form_tub")
  /// Cloths
  internal static let kbvCodeDosageFormTue = StringAsset("kbv_code_dosage_form_tue")
  /// Swab
  internal static let kbvCodeDosageFormTup = StringAsset("kbv_code_dosage_form_tup")
  /// Modified-release tablet
  internal static let kbvCodeDosageFormTvw = StringAsset("kbv_code_dosage_form_tvw")
  /// Coated tablets
  internal static let kbvCodeDosageFormUta = StringAsset("kbv_code_dosage_form_uta")
  /// Vaginal solution
  internal static let kbvCodeDosageFormVal = StringAsset("kbv_code_dosage_form_val")
  /// Vaginal ring
  internal static let kbvCodeDosageFormVar = StringAsset("kbv_code_dosage_form_var")
  /// Vaginal cream
  internal static let kbvCodeDosageFormVcr = StringAsset("kbv_code_dosage_form_vcr")
  /// Dressing
  internal static let kbvCodeDosageFormVer = StringAsset("kbv_code_dosage_form_ver")
  /// Vaginal gel
  internal static let kbvCodeDosageFormVge = StringAsset("kbv_code_dosage_form_vge")
  /// Vaginal capsules
  internal static let kbvCodeDosageFormVka = StringAsset("kbv_code_dosage_form_vka")
  /// Fleece
  internal static let kbvCodeDosageFormVli = StringAsset("kbv_code_dosage_form_vli")
  /// Vaginal ovules
  internal static let kbvCodeDosageFormVov = StringAsset("kbv_code_dosage_form_vov")
  /// Vaginal swabs
  internal static let kbvCodeDosageFormVst = StringAsset("kbv_code_dosage_form_vst")
  /// Vaginal suppositories
  internal static let kbvCodeDosageFormVsu = StringAsset("kbv_code_dosage_form_vsu")
  /// Vaginal tablets
  internal static let kbvCodeDosageFormVta = StringAsset("kbv_code_dosage_form_vta")
  /// Cotton wool
  internal static let kbvCodeDosageFormWat = StringAsset("kbv_code_dosage_form_wat")
  /// Wound gauze
  internal static let kbvCodeDosageFormWga = StringAsset("kbv_code_dosage_form_wga")
  /// Soft capsules
  internal static let kbvCodeDosageFormWka = StringAsset("kbv_code_dosage_form_wka")
  /// Enteric-resistant soft capsules
  internal static let kbvCodeDosageFormWkm = StringAsset("kbv_code_dosage_form_wkm")
  /// Cube
  internal static let kbvCodeDosageFormWue = StringAsset("kbv_code_dosage_form_wue")
  /// Shower gel
  internal static let kbvCodeDosageFormXdg = StringAsset("kbv_code_dosage_form_xdg")
  /// Deodorant spray
  internal static let kbvCodeDosageFormXds = StringAsset("kbv_code_dosage_form_xds")
  /// Firming agent
  internal static let kbvCodeDosageFormXfe = StringAsset("kbv_code_dosage_form_xfe")
  /// Face mask
  internal static let kbvCodeDosageFormXgm = StringAsset("kbv_code_dosage_form_xgm")
  /// Collar
  internal static let kbvCodeDosageFormXha = StringAsset("kbv_code_dosage_form_xha")
  /// Hair conditioner
  internal static let kbvCodeDosageFormXhs = StringAsset("kbv_code_dosage_form_xhs")
  /// Night cream
  internal static let kbvCodeDosageFormXnc = StringAsset("kbv_code_dosage_form_xnc")
  /// Body care
  internal static let kbvCodeDosageFormXpk = StringAsset("kbv_code_dosage_form_xpk")
  /// Day cream
  internal static let kbvCodeDosageFormXtc = StringAsset("kbv_code_dosage_form_xtc")
  /// Cylinder ampoule
  internal static let kbvCodeDosageFormZam = StringAsset("kbv_code_dosage_form_zam")
  /// Toothbrush
  internal static let kbvCodeDosageFormZbu = StringAsset("kbv_code_dosage_form_zbu")
  /// Dentifrice
  internal static let kbvCodeDosageFormZcr = StringAsset("kbv_code_dosage_form_zcr")
  /// Tooth gel
  internal static let kbvCodeDosageFormZge = StringAsset("kbv_code_dosage_form_zge")
  /// Chewable capsules
  internal static let kbvCodeDosageFormZka = StringAsset("kbv_code_dosage_form_zka")
  /// Toothpaste
  internal static let kbvCodeDosageFormZpa = StringAsset("kbv_code_dosage_form_zpa")
  /// Members
  internal static let kbvMemberStatus1 = StringAsset("kbv_member_status_1")
  /// Family members
  internal static let kbvMemberStatus3 = StringAsset("kbv_member_status_3")
  /// Pensioner
  internal static let kbvMemberStatus5 = StringAsset("kbv_member_status_5")
  /// Not specified
  internal static let kbvNormSizeKa = StringAsset("kbv_norm_size_ka")
  /// No package size suitable for therapy
  internal static let kbvNormSizeKtp = StringAsset("kbv_norm_size_ktp")
  /// Standard size 1
  internal static let kbvNormSizeN1 = StringAsset("kbv_norm_size_n1")
  /// Standard size 2
  internal static let kbvNormSizeN2 = StringAsset("kbv_norm_size_n2")
  /// Standard size 3
  internal static let kbvNormSizeN3 = StringAsset("kbv_norm_size_n3")
  /// Not affected
  internal static let kbvNormSizeNb = StringAsset("kbv_norm_size_nb")
  /// Other
  internal static let kbvNormSizeSonstiges = StringAsset("kbv_norm_size_sonstiges")
  /// Abbrechen
  internal static let mainTxtPendingextauthCancel = StringAsset("main_txt_pendingextauth_cancel")
  /// Authentisierung mit %@ fehlgeschlagen
  internal static func mainTxtPendingextauthFailed(_ element1: String) -> StringAsset {
    StringAsset("main_txt_pendingextauth_failed_%@", arguments: [element1])
  }
  /// Authentisierung in %@ ausstehend
  internal static func mainTxtPendingextauthPending(_ element1: String) -> StringAsset {
    StringAsset("main_txt_pendingextauth_pending_%@", arguments: [element1])
  }
  /// Authentisierung für %@ wird verarbeitet
  internal static func mainTxtPendingextauthResolving(_ element1: String) -> StringAsset {
    StringAsset("main_txt_pendingextauth_resolving_%@", arguments: [element1])
  }
  /// Wiederholen
  internal static let mainTxtPendingextauthRetry = StringAsset("main_txt_pendingextauth_retry")
  /// Authentisierung mit %@ erfolgreich
  internal static func mainTxtPendingextauthSuccessful(_ element1: String) -> StringAsset {
    StringAsset("main_txt_pendingextauth_successful_%@", arguments: [element1])
  }
  /// Report error
  internal static let msgsBtnFormatError = StringAsset("msgs_btn_format_error")
  /// Show pickup code
  internal static let msgsBtnOnPremise = StringAsset("msgs_btn_onPremise")
  /// Show shopping cart
  internal static let msgsBtnShipment = StringAsset("msgs_btn_shipment")
  /// Message received
  internal static let msgsTxtDeliveryTitle = StringAsset("msgs_txt_delivery_title")
  /// app-fehlermeldung@ti-support.de
  internal static let msgsTxtEmailSupport = StringAsset("msgs_txt_email_support")
  /// You haven't received any messages yet
  internal static let msgsTxtEmptyListMessage = StringAsset("msgs_txt_empty_list_message")
  /// No messages
  internal static let msgsTxtEmptyListTitle = StringAsset("msgs_txt_empty_list_title")
  /// Unfortunately, your pharmacy's message was empty. Please contact your pharmacy.
  internal static let msgsTxtEmptyMessage = StringAsset("msgs_txt_empty_message")
  /// A pharmacy has sent a message in an incorrect format.
  internal static let msgsTxtFormatErrorMessage = StringAsset("msgs_txt_format_error_message")
  /// Defective message received
  internal static let msgsTxtFormatErrorTitle = StringAsset("msgs_txt_format_error_title")
  /// Dear Service Team, I received a message from a pharmacy. Unfortunately, however, I could not pass the message on to my user because I did not understand it. Please check what happened here and help us. Thank you very much! The e-prescription app
  internal static let msgsTxtMailBody1 = StringAsset("msgs_txt_mail_body1")
  /// You are sending us this information for purposes of troubleshooting. Please note that your email address and any name you include will also be transferred. If you do not wish to transfer this information either in full or in part, please remove it from this email. \n\nAll data will only be stored or processed by gematik GmbH or its appointed companies in order to deal with this error message. Deletion takes place automatically a maximum of 180 days after the ticket has been processed. We will use your email address exclusively to contact you regarding this error message. If you have any questions, or require an earlier deletion, you can contact the data protection representative responsible for the e-prescription system. You can find further information in the menu below the entry for data protection in the e-prescription app.
  internal static let msgsTxtMailBody2 = StringAsset("msgs_txt_mail_body2")
  /// Fehler 40 42 67336
  internal static let msgsTxtMailError = StringAsset("msgs_txt_mail_error")
  /// Error message from the e-prescription app
  internal static let msgsTxtMailSubject = StringAsset("msgs_txt_mail_subject")
  /// Received pickup code
  internal static let msgsTxtOnPremiseTitle = StringAsset("msgs_txt_onPremise_title")
  /// The email app could not be opened. Please use the hotline
  internal static let msgsTxtOpenMailErrorMessage = StringAsset("msgs_txt_open_mail_error_message")
  /// Error
  internal static let msgsTxtOpenMailErrorTitle = StringAsset("msgs_txt_open_mail_error_title")
  /// Your shopping cart is ready
  internal static let msgsTxtShipmentTitle = StringAsset("msgs_txt_shipment_title")
  /// Messages
  internal static let msgsTxtTitle = StringAsset("msgs_txt_title")
  /// Back
  internal static let navBack = StringAsset("nav_back")
  /// Cancel
  internal static let navCancel = StringAsset("nav_cancel")
  /// Machen Sie es Unbefugten schwerer an Ihre Daten zu gelangen und sichern Sie den Start der App.
  internal static let onbAuthTxtAltDescription = StringAsset("onb_auth_txt_alt_description")
  /// ODER
  internal static let onbAuthTxtDivider = StringAsset("onb_auth_txt_divider")
  /// Bitte wählen Sie eine Methode zum absichern der App aus:
  internal static let onbAuthTxtNoSelection = StringAsset("onb_auth_txt_no_selection")
  /// Sicherheitsstufe des gewählten Kennworts nicht ausreichend
  internal static let onbAuthTxtPasswordStrengthInsufficient = StringAsset("onb_auth_txt_password_strength_insufficient")
  /// Die Eingaben weichen voneinander ab.
  internal static let onbAuthTxtPasswordsDontMatch = StringAsset("onb_auth_txt_passwords_dont_match")
  /// Wie möchten Sie diese App absichern?
  internal static let onbAuthTxtTitle = StringAsset("onb_auth_txt_title")
  /// Next
  internal static let onbBtnNextHint = StringAsset("onb_btn_next_hint")
  /// Automatically update your new prescriptions
  internal static let onbFeaTxtFeature1 = StringAsset("onb_fea_txt_feature_1")
  /// Information on how to take your medication and dosages
  internal static let onbFeaTxtFeature2 = StringAsset("onb_fea_txt_feature_2")
  /// Receive messages from your pharmacy about your order
  internal static let onbFeaTxtFeature3 = StringAsset("onb_fea_txt_feature_3")
  /// More features with your medical card
  internal static let onbFeaTxtTitle = StringAsset("onb_fea_txt_title")
  /// Gematik logo
  internal static let onbImgGematikLogo = StringAsset("onb_img_gematik_logo")
  /// Illustration of a hand holding a medical card to the back of a smartphone.
  internal static let onbImgMan1 = StringAsset("onb_img_man1")
  /// Accept Privacy Policy
  internal static let onbLegBtnPrivacyHint = StringAsset("onb_leg_btn_privacy_hint")
  /// Accept Terms of Use
  internal static let onbLegBtnTermsOfUseHint = StringAsset("onb_leg_btn_terms_of_use_hint")
  /// Confirm
  internal static let onbLegBtnTitle = StringAsset("onb_leg_btn_title")
  /// In order to use the app, please agree to the Terms of Use and confirm that you have read and understood the Privacy Policy. Only data that is essential for the functioning of the services is collected.
  internal static let onbLegTxtSubtitle = StringAsset("onb_leg_txt_subtitle")
  /// Terms of Use & Privacy Policy
  internal static let onbLegTxtTitle = StringAsset("onb_leg_txt_title")
  /// Das Namensfeld darf nicht leer sein
  internal static let onbPrfTxtAlertMessage = StringAsset("onb_prf_txt_alert_message")
  /// Fehler
  internal static let onbPrfTxtAlertTitle = StringAsset("onb_prf_txt_alert_title")
  /// Das hilft Ihnen dabei, den Überblick zu behalten, wenn Sie die Rezepte für mehrere Personen verwalten möchten.
  internal static let onbPrfTxtFootnote = StringAsset("onb_prf_txt_footnote")
  /// Vorname und Nachname
  internal static let onbPrfTxtPlaceholder = StringAsset("onb_prf_txt_placeholder")
  /// Wie sollen wir Sie nennen?
  internal static let onbPrfTxtTitle = StringAsset("onb_prf_txt_title")
  /// Digital. Fast. Secure.
  internal static let onbStrTxtSubtitle = StringAsset("onb_str_txt_subtitle")
  /// The e-prescription
  internal static let onbStrTxtTitle = StringAsset("onb_str_txt_title")
  /// Privacy Policy
  internal static let onbTxtTermsOfPrivacyLink = StringAsset("onb_txt_terms_of_privacy_link")
  /// I accept the 
  internal static let onbTxtTermsOfPrivacyPrefix = StringAsset("onb_txt_terms_of_privacy_prefix")
  ///  of this app
  internal static let onbTxtTermsOfPrivacySuffix = StringAsset("onb_txt_terms_of_privacy_suffix")
  /// Terms of Use
  internal static let onbTxtTermsOfUseLink = StringAsset("onb_txt_terms_of_use_link")
  /// I accept the 
  internal static let onbTxtTermsOfUsePrefix = StringAsset("onb_txt_terms_of_use_prefix")
  ///  of this app
  internal static let onbTxtTermsOfUseSuffix = StringAsset("onb_txt_terms_of_use_suffix")
  /// Illustration of a smiling pharmacist
  internal static let onbWelImgFrau1 = StringAsset("onb_wel_img_frau1")
  /// Here you can redeem electronic prescriptions at a pharmacy of your choice, directly in person or online.
  internal static let onbWelTxtExplanation = StringAsset("onb_wel_txt_explanation")
  /// Welcome to the e-prescription app
  internal static let onbWelTxtTitle = StringAsset("onb_wel_txt_title")
  /// So erkennen Sie eine NFC-fähige Gesundheitskarte
  internal static let orderEgkBtnInfoButton = StringAsset("order_egk_btn_info_button")
  /// Mail
  internal static let orderEgkTxtContactOptionMail = StringAsset("order_egk_txt_contact_option_mail")
  /// Telefon
  internal static let orderEgkTxtContactOptionTelephone = StringAsset("order_egk_txt_contact_option_telephone")
  /// Webseite
  internal static let orderEgkTxtContactOptionWeb = StringAsset("order_egk_txt_contact_option_web")
  /// Um sich in dieser App anmelden zu können, benötigen Sie eine NFC-fähige Gesundheitskarte sowie eine zugehörige PIN.
  internal static let orderEgkTxtDescription1 = StringAsset("order_egk_txt_description_1")
  /// Diese erhalten Sie kostenfrei von Ihrer Krankenversicherung. Hierfür müssen Sie sich mittels amtlichem Ausweisdokument identifiziert haben.
  internal static let orderEgkTxtDescription2 = StringAsset("order_egk_txt_description_2")
  /// Krankenversicherung kontaktieren
  internal static let orderEgkTxtHeadline = StringAsset("order_egk_txt_headline")
  /// Bitte nutzen Sie die üblichen Kanäle, um Ihre Versicherung zu kontaktieren.
  internal static let orderEgkTxtHintNoContactOptionMessage = StringAsset("order_egk_txt_hint_no_contact_option_message")
  /// Keine Kontaktaufnahme über diese App möglich
  internal static let orderEgkTxtHintNoContactOptionTitle = StringAsset("order_egk_txt_hint_no_contact_option_title")
  /// https://www.das-e-rezept-fuer-deutschland.de/fragen-antworten/woran-erkenne-ich-ob-ich-eine-nfc-faehige-gesundheitskarte-habe#c204
  internal static let orderEgkTxtInfoLink = StringAsset("order_egk_txt_info_link")
  /// 
  internal static let orderEgkTxtMailHealthcardAndPinBody = StringAsset("order_egk_txt_mail_healthcard_and_pin_body")
  /// Bestellung einer NFC-fähigen Gesundheitskarte inklusive PIN
  internal static let orderEgkTxtMailHealthcardAndPinSubject = StringAsset("order_egk_txt_mail_healthcard_and_pin_subject")
  /// Krankenversicherung wählen
  internal static let orderEgkTxtPickerInsuranceHeader = StringAsset("order_egk_txt_picker_insurance_header")
  /// Auswahl treffen
  internal static let orderEgkTxtPickerInsurancePlaceholder = StringAsset("order_egk_txt_picker_insurance_placeholder")
  /// Was möchten Sie beantragen?
  internal static let orderEgkTxtPickerServiceHeader = StringAsset("order_egk_txt_picker_service_header")
  /// Sollten Sie bereits über eine Gesundheitskarte mit NFC-Funktion verfügen, müssen Sie lediglich die Zusendung einer PIN beantragen.
  internal static let orderEgkTxtPickerServiceInfoFootnote = StringAsset("order_egk_txt_picker_service_info_footnote")
  /// Auswahl treffen
  internal static let orderEgkTxtPickerServiceLabel = StringAsset("order_egk_txt_picker_service_label")
  /// Auswählen
  internal static let orderEgkTxtPickerServiceNavigationTitle = StringAsset("order_egk_txt_picker_service_navigation_title")
  /// Kontaktieren Sie Ihre Krankenversicherung
  internal static let orderEgkTxtSectionContactInsurance = StringAsset("order_egk_txt_section_contact_insurance")
  /// Gesundheitskarte & PIN
  internal static let orderEgkTxtServiceInquiryHealthcardAndPin = StringAsset("order_egk_txt_service_inquiry_healthcard_and_pin")
  /// Nur PIN
  internal static let orderEgkTxtServiceInquiryOnlyPin = StringAsset("order_egk_txt_service_inquiry_only_pin")
  /// Find out more
  internal static let phaDetailBtnFooter = StringAsset("pha_detail_btn_footer")
  /// Request delivery service
  internal static let phaDetailBtnHealthcareService = StringAsset("pha_detail_btn_healthcare_service")
  /// Reserve for collection
  internal static let phaDetailBtnLocation = StringAsset("pha_detail_btn_location")
  /// Delivery by mail order
  internal static let phaDetailBtnOrganization = StringAsset("pha_detail_btn_organization")
  /// Contact
  internal static let phaDetailContact = StringAsset("pha_detail_contact")
  /// Please note that prescribed medication may also be subject to additional payments.
  internal static let phaDetailHintMessage = StringAsset("pha_detail_hint_message")
  /// This pharmacy is not currently able to receive any e-prescriptions.
  internal static let phaDetailHintNotErxReadyMessage = StringAsset("pha_detail_hint_not_erx_ready_message")
  /// Can be redeemed soon
  internal static let phaDetailHintNotErxReadyTitle = StringAsset("pha_detail_hint_not_erx_ready_title")
  /// Email address
  internal static let phaDetailMail = StringAsset("pha_detail_mail")
  /// Opening hours
  internal static let phaDetailOpeningTime = StringAsset("pha_detail_opening_time")
  /// Telephone number
  internal static let phaDetailPhone = StringAsset("pha_detail_phone")
  ///  provided by the Deutscher Apothekenverband e.V. Have you found an error or would you like to correct any data?
  internal static let phaDetailTxtFooterEnd = StringAsset("pha_detail_txt_footer_end")
  /// mein-apothekenportal.de
  internal static let phaDetailTxtFooterMid = StringAsset("pha_detail_txt_footer_mid")
  /// Note to pharmacies: this app obtains the contact details for and information about pharmacies from 
  internal static let phaDetailTxtFooterStart = StringAsset("pha_detail_txt_footer_start")
  /// Pharmacy
  internal static let phaDetailTxtSubtitleFallback = StringAsset("pha_detail_txt_subtitle_fallback")
  /// Details
  internal static let phaDetailTxtTitle = StringAsset("pha_detail_txt_title")
  /// Website
  internal static let phaDetailWeb = StringAsset("pha_detail_web")
  /// E-prescription
  internal static let phaGlobalTxtReadinessBadge = StringAsset("pha_global_txt_readiness_badge")
  /// Ready for the e-prescription
  internal static let phaGlobalTxtReadinessBadgeDetailed = StringAsset("pha_global_txt_readiness_badge_detailed")
  /// Redeem now
  internal static let phaRedeemBtnAlertApproval = StringAsset("pha_redeem_btn_alert_approval")
  /// Cancel
  internal static let phaRedeemBtnAlertCancel = StringAsset("pha_redeem_btn_alert_cancel")
  /// Redeem
  internal static let phaRedeemBtnRedeem = StringAsset("pha_redeem_btn_redeem")
  /// Your prescription will be sent to this pharmacy. It is not possible to redeem your prescription at another pharmacy.
  internal static let phaRedeemBtnRedeemFootnote = StringAsset("pha_redeem_btn_redeem_footnote")
  /// ⚕︎ Redeem
  internal static let phaRedeemTitle = StringAsset("pha_redeem_title")
  /// Delivery address
  internal static let phaRedeemTxtAddress = StringAsset("pha_redeem_txt_address")
  /// You can change your delivery address on the website of the mail-order pharmacy.
  internal static let phaRedeemTxtAddressFootnote = StringAsset("pha_redeem_txt_address_footnote")
  /// Your prescriptions will be sent to this pharmacy. You will then not be able to redeem them in any other pharmacy.
  internal static let phaRedeemTxtAlertMessage = StringAsset("pha_redeem_txt_alert_message")
  /// Redeem with binding effect?
  internal static let phaRedeemTxtAlertTitle = StringAsset("pha_redeem_txt_alert_title")
  /// You are no longer logged in. Please log back in to redeem prescriptions.
  internal static let phaRedeemTxtNotLoggedIn = StringAsset("pha_redeem_txt_not_logged_in")
  /// Prescriptions
  internal static let phaRedeemTxtPrescription = StringAsset("pha_redeem_txt_prescription")
  /// Substitutes are permitted. You may be given an alternative due to the legal requirements of your health insurance.
  internal static let phaRedeemTxtPrescriptionSub = StringAsset("pha_redeem_txt_prescription_sub")
  /// Commit to redeeming the following prescriptions at the %@?
  internal static func phaRedeemTxtSubtitle(_ element1: String) -> StringAsset {
    StringAsset("pha_redeem_txt_subtitle_%@", arguments: [element1])
  }
  /// Delivery service
  internal static let phaRedeemTxtTitleDelivery = StringAsset("pha_redeem_txt_title_delivery")
  /// Mail order
  internal static let phaRedeemTxtTitleMail = StringAsset("pha_redeem_txt_title_mail")
  /// Reservation
  internal static let phaRedeemTxtTitleReservation = StringAsset("pha_redeem_txt_title_reservation")
  /// Erneut probieren
  internal static let phaSearchBtnErrorNoServerResponse = StringAsset("pha_search_btn_error_no_server_response")
  /// Share location
  internal static let phaSearchBtnLocationHintAction = StringAsset("pha_search_btn_location_hint_action")
  /// Filter
  internal static let phaSearchBtnShowFilterView = StringAsset("pha_search_btn_show_filter_view")
  /// Filter
  internal static let phaSearchFilterTxtTitle = StringAsset("pha_search_filter_txt_title")
  /// Closed
  internal static let phaSearchTxtClosed = StringAsset("pha_search_txt_closed")
  /// Closing soon
  internal static let phaSearchTxtClosingSoon = StringAsset("pha_search_txt_closing_soon")
  /// Server antwortet nicht
  internal static let phaSearchTxtErrorNoServerResponseHeadline = StringAsset("pha_search_txt_error_no_server_response_headline")
  /// Bitte probieren Sie es in einigen Minuten erneut.
  internal static let phaSearchTxtErrorNoServerResponseSubheadline = StringAsset("pha_search_txt_error_no_server_response_subheadline")
  /// Delivery service
  internal static let phaSearchTxtFilterMessenger = StringAsset("pha_search_txt_filter_messenger")
  /// Start the search by tapping Open on the keypad
  internal static let phaSearchTxtHintStartSearch = StringAsset("pha_search_txt_hint_start_search")
  /// Share your location to find pharmacies near you.
  internal static let phaSearchTxtLocationAlertMessage = StringAsset("pha_search_txt_location_alert_message")
  /// Share location
  internal static let phaSearchTxtLocationAlertTitle = StringAsset("pha_search_txt_location_alert_title")
  /// Share your location and find pharmacies in your area
  internal static let phaSearchTxtLocationHintMessage = StringAsset("pha_search_txt_location_hint_message")
  /// Find pharmacies easily
  internal static let phaSearchTxtLocationHintTitle = StringAsset("pha_search_txt_location_hint_title")
  /// Please start your search with at least three letters.
  internal static let phaSearchTxtMinSearchChars = StringAsset("pha_search_txt_min_search_chars")
  /// We couldn't find any results with this search term.
  internal static let phaSearchTxtNoResults = StringAsset("pha_search_txt_no_results")
  /// No results
  internal static let phaSearchTxtNoResultsTitle = StringAsset("pha_search_txt_no_results_title")
  /// Open until
  internal static let phaSearchTxtOpenUntil = StringAsset("pha_search_txt_open_until")
  /// Opens at
  internal static let phaSearchTxtOpensAt = StringAsset("pha_search_txt_opens_at")
  /// Determining device location...
  internal static let phaSearchTxtProgressLocating = StringAsset("pha_search_txt_progress_locating")
  /// Searching...
  internal static let phaSearchTxtProgressSearch = StringAsset("pha_search_txt_progress_search")
  /// Searched name, e.g. Spessart Pharmacy
  internal static let phaSearchTxtSearchHint = StringAsset("pha_search_txt_search_hint")
  /// Select pharmacy
  internal static let phaSearchTxtTitle = StringAsset("pha_search_txt_title")
  /// Done! 🎉
  internal static let phaSuccessRedeemTitle = StringAsset("pha_success_redeem_title")
  /// Fertig
  internal static let proBtnSelectionClose = StringAsset("pro_btn_selection_close")
  /// Profile bearbeiten
  internal static let proBtnSelectionEdit = StringAsset("pro_btn_selection_edit")
  /// Nicht angemeldet
  internal static let proTxtSelectionProfileNotConnected = StringAsset("pro_txt_selection_profile_not_connected")
  /// Profil wählen
  internal static let proTxtSelectionTitle = StringAsset("pro_txt_selection_title")
  /// gesund.bund.de öffnen
  internal static let prscDtlHntGesundBundDeBtn = StringAsset("prsc_dtl_hnt_gesund_bund_de_btn")
  /// Fachlich geprüfte Informationen zu Krankheiten, ICD-Codes und zu Vorsorge- und Pflegethemen finden Sie im Nationalen Gesundheitsportal.
  internal static let prscDtlHntGesundBundDeText = StringAsset("prsc_dtl_hnt_gesund_bund_de_text")
  /// Date of accident
  internal static let prscFdTxtAccidentDate = StringAsset("prsc_fd_txt_accident_date")
  /// Accident company or employer number
  internal static let prscFdTxtAccidentId = StringAsset("prsc_fd_txt_accident_id")
  /// Accident at work
  internal static let prscFdTxtAccidentTitle = StringAsset("prsc_fd_txt_accident_title")
  /// Dosage form
  internal static let prscFdTxtDetailsDosageForm = StringAsset("prsc_fd_txt_details_dosage_form")
  /// Package size
  internal static let prscFdTxtDetailsDose = StringAsset("prsc_fd_txt_details_dose")
  /// Pharma central number (PZN)
  internal static let prscFdTxtDetailsPzn = StringAsset("prsc_fd_txt_details_pzn")
  /// Details about this medicine
  internal static let prscFdTxtDetailsTitle = StringAsset("prsc_fd_txt_details_title")
  /// Please follow the directions for use in your medication schedule or the written dosage instructions from your doctor.
  internal static let prscFdTxtDosageInstructionsNa = StringAsset("prsc_fd_txt_dosage_instructions_na")
  /// Directions for use
  internal static let prscFdTxtDosageInstructionsTitle = StringAsset("prsc_fd_txt_dosage_instructions_title")
  /// Not specified
  internal static let prscFdTxtNa = StringAsset("prsc_fd_txt_na")
  /// Detail
  internal static let prscFdTxtNavigationTitle = StringAsset("prsc_fd_txt_navigation_title")
  /// This medication can also be redeemed in a pharmacy at night without an emergency service fee.
  internal static let prscFdTxtNoctuDescription = StringAsset("prsc_fd_txt_noctu_description")
  /// This is a matter of urgency
  internal static let prscFdTxtNoctuTitle = StringAsset("prsc_fd_txt_noctu_title")
  /// Address
  internal static let prscFdTxtOrganizationAddress = StringAsset("prsc_fd_txt_organization_address")
  /// Email address
  internal static let prscFdTxtOrganizationEmail = StringAsset("prsc_fd_txt_organization_email")
  /// Establishment number
  internal static let prscFdTxtOrganizationId = StringAsset("prsc_fd_txt_organization_id")
  /// Name
  internal static let prscFdTxtOrganizationName = StringAsset("prsc_fd_txt_organization_name")
  /// Telephone number
  internal static let prscFdTxtOrganizationPhone = StringAsset("prsc_fd_txt_organization_phone")
  /// Institution
  internal static let prscFdTxtOrganizationTitle = StringAsset("prsc_fd_txt_organization_title")
  /// Address
  internal static let prscFdTxtPatientAddress = StringAsset("prsc_fd_txt_patient_address")
  /// Date of birth
  internal static let prscFdTxtPatientBirthdate = StringAsset("prsc_fd_txt_patient_birthdate")
  /// Health insurance / cost unit
  internal static let prscFdTxtPatientInsurance = StringAsset("prsc_fd_txt_patient_insurance")
  /// Insurance number
  internal static let prscFdTxtPatientInsuranceId = StringAsset("prsc_fd_txt_patient_insurance_id")
  /// Name
  internal static let prscFdTxtPatientName = StringAsset("prsc_fd_txt_patient_name")
  /// Telephone number
  internal static let prscFdTxtPatientPhone = StringAsset("prsc_fd_txt_patient_phone")
  /// Status
  internal static let prscFdTxtPatientStatus = StringAsset("prsc_fd_txt_patient_status")
  /// Insured person
  internal static let prscFdTxtPatientTitle = StringAsset("prsc_fd_txt_patient_title")
  /// Physician number (LANR)
  internal static let prscFdTxtPractitionerId = StringAsset("prsc_fd_txt_practitioner_id")
  /// Name
  internal static let prscFdTxtPractitionerName = StringAsset("prsc_fd_txt_practitioner_name")
  /// Specialist physician
  internal static let prscFdTxtPractitionerQualification = StringAsset("prsc_fd_txt_practitioner_qualification")
  /// Prescriber
  internal static let prscFdTxtPractitionerTitle = StringAsset("prsc_fd_txt_practitioner_title")
  /// Update failed. Please try again later.
  internal static let prscFdTxtProtocolDownloadError = StringAsset("prsc_fd_txt_protocol_download_error")
  /// Last updated
  internal static let prscFdTxtProtocolLastUpdated = StringAsset("prsc_fd_txt_protocol_last_updated")
  /// Substitutes are permitted. You may be given an alternative due to the legal requirements of your health insurance.
  internal static let prscFdTxtSubstitutionDescription = StringAsset("prsc_fd_txt_substitution_description")
  /// Find out more
  internal static let prscFdTxtSubstitutionReadFurther = StringAsset("prsc_fd_txt_substitution_read_further")
  /// https://www.das-e-rezept-fuer-deutschland.de/fragen-antworten
  internal static let prscFdTxtSubstitutionReadFurtherLink = StringAsset("prsc_fd_txt_substitution_read_further_link")
  /// Substitute medication possible
  internal static let prscFdTxtSubstitutionTitle = StringAsset("prsc_fd_txt_substitution_title")
  /// Abgebrochen
  internal static let prscStatusCanceled = StringAsset("prsc_status_canceled")
  /// Eingelöst
  internal static let prscStatusCompleted = StringAsset("prsc_status_completed")
  /// Abgelaufen
  internal static let prscStatusExpired = StringAsset("prsc_status_expired")
  /// In Einlösung
  internal static let prscStatusInProgress = StringAsset("prsc_status_in_progress")
  /// Einlösbar
  internal static let prscStatusReady = StringAsset("prsc_status_ready")
  /// Unbekannt
  internal static let prscStatusUndefined = StringAsset("prsc_status_undefined")
  /// Show this code at your pharmacy.
  internal static let pucTxtSubtitle = StringAsset("puc_txt_subtitle")
  /// Collection code
  internal static let pucTxtTitle = StringAsset("puc_txt_title")
  /// You are in a pharmacy and want to redeem your prescription.
  internal static let rdmBtnRedeemPharmacyDescription = StringAsset("rdm_btn_redeem_pharmacy_description")
  /// I'm in the pharmacy
  internal static let rdmBtnRedeemPharmacyTitle = StringAsset("rdm_btn_redeem_pharmacy_title")
  /// Submit your prescription to a pharmacy and decide how you would like to receive your medication.
  internal static let rdmBtnRedeemSearchPharmacyDescription = StringAsset("rdm_btn_redeem_search_pharmacy_description")
  /// I would like to make a reservation or order
  internal static let rdmBtnRedeemSearchPharmacyTitle = StringAsset("rdm_btn_redeem_search_pharmacy_title")
  /// To the homepage
  internal static let rdmSccBtnReturnToMain = StringAsset("rdm_scc_btn_return_to_main")
  /// The pharmacy will contact you as soon as possible to verify the delivery details with you.
  internal static let rdmSccTxtDeliveryContent = StringAsset("rdm_scc_txt_delivery_content")
  /// Successfully redeemed
  internal static let rdmSccTxtDeliveryTitle = StringAsset("rdm_scc_txt_delivery_title")
  /// Your order will usually be ready for you as soon as possible. Please contact the pharmacy for an exact time.
  internal static let rdmSccTxtOnpremiseContent = StringAsset("rdm_scc_txt_onpremise_content")
  /// Successfully redeemed
  internal static let rdmSccTxtOnpremiseTitle = StringAsset("rdm_scc_txt_onpremise_title")
  /// Go to homepage
  internal static let rdmSccTxtShipmentContent1 = StringAsset("rdm_scc_txt_shipment_content_1")
  /// The mail-order pharmacy will create a shopping cart for you with your medicines. This process may take a few minutes.
  internal static let rdmSccTxtShipmentContent2 = StringAsset("rdm_scc_txt_shipment_content_2")
  /// Tap "Open shopping cart" and complete your order on the pharmacy's website.
  internal static let rdmSccTxtShipmentContent3 = StringAsset("rdm_scc_txt_shipment_content_3")
  /// Your next steps
  internal static let rdmSccTxtShipmentTitle = StringAsset("rdm_scc_txt_shipment_title")
  /// Choose how you would like to redeem your prescription.
  internal static let rdmTxtSubtitle = StringAsset("rdm_txt_subtitle")
  /// Redeem
  internal static let rdmTxtTitle = StringAsset("rdm_txt_title")
  /// Not redeemed
  internal static let rphBtnCloseAlertKeep = StringAsset("rph_btn_close_alert_keep")
  /// Redeemed
  internal static let rphBtnCloseAlertMarkRedeemed = StringAsset("rph_btn_close_alert_mark_redeemed")
  /// Would you like to mark this prescription as redeemed?
  internal static let rphTxtCloseAlertMessage = StringAsset("rph_txt_close_alert_message")
  /// Prescription redeemed?
  internal static let rphTxtCloseAlertTitle = StringAsset("rph_txt_close_alert_title")
  /// Have this prescription code scanned at your pharmacy.
  internal static let rphTxtMatrixcodeHint = StringAsset("rph_txt_matrixcode_hint")
  /// Have this prescription code scanned at your pharmacy.
  internal static let rphTxtSubtitle = StringAsset("rph_txt_subtitle")
  /// Prescription code
  internal static let rphTxtTitle = StringAsset("rph_txt_title")
  /// Cancel scanning
  internal static let scnBtnCancelScan = StringAsset("scn_btn_cancel_scan")
  /// Plural format key: "%#@variable_0@"
  internal static let scnBtnScanningDone = StringAsset("scn_btn_scanning_done")
  /// Analysing prescription code
  internal static let scnMsgAnalysingCode = StringAsset("scn_msg_analysing_code")
  /// An error occurred while saving. Please restart the app.
  internal static let scnMsgSavingError = StringAsset("scn_msg_saving_error")
  /// This prescription code has already been scanned
  internal static let scnMsgScannedCodeDuplicate = StringAsset("scn_msg_scanned_code_duplicate")
  /// This is not a valid prescription code
  internal static let scnMsgScannedCodeFailed = StringAsset("scn_msg_scanned_code_failed")
  /// Prescription code recognised, please do not move the device
  internal static let scnMsgScannedCodeRecognized = StringAsset("scn_msg_scanned_code_recognized")
  /// This prescription code has already been scanned
  internal static let scnMsgScannedCodeStoreDuplicate = StringAsset("scn_msg_scanned_code_store_duplicate")
  /// Focus the camera on a prescription code
  internal static let scnMsgScanningCode = StringAsset("scn_msg_scanning_code")
  /// Ready for another prescription code
  internal static let scnMsgScanningCodeConsecutive = StringAsset("scn_msg_scanning_code_consecutive")
  /// Scanned prescription
  internal static let scnTxtAuthor = StringAsset("scn_txt_author")
  /// Medicine %@
  internal static func scnTxtMedication(_ element1: String) -> StringAsset {
    StringAsset("scn_txt_medication_%@", arguments: [element1])
  }
  /// OK
  internal static let secBtnSystemPinDone = StringAsset("sec_btn_system_pin_done")
  /// Okay
  internal static let secBtnSystemRootDetectionDone = StringAsset("sec_btn_system_root_detection_done")
  /// Mehr erfahren
  internal static let secBtnSystemRootDetectionMore = StringAsset("sec_btn_system_root_detection_more")
  /// Hinweis
  internal static let secTxtSystemPinHeadline = StringAsset("sec_txt_system_pin_headline")
  /// Wir empfehlen Ihnen, Ihre medizinischen Daten zusätzlich durch eine Gerätesicherung wie beispielsweise einen Code oder Biometrie zu schützen.
  internal static let secTxtSystemPinMessage = StringAsset("sec_txt_system_pin_message")
  /// Diesen Hinweis in Zukunft nicht mehr anzeigen.
  internal static let secTxtSystemPinSelection = StringAsset("sec_txt_system_pin_selection")
  /// Für dieses Gerät wurde keine Zugangssperre eingerichtet
  internal static let secTxtSystemPinTitle = StringAsset("sec_txt_system_pin_title")
  /// Weshalb sind Geräte mit Root-Zugriff ein potentielles Sicherheitsrisiko?
  internal static let secTxtSystemRootDetectionFootnote = StringAsset("sec_txt_system_root_detection_footnote")
  /// Warnung
  internal static let secTxtSystemRootDetectionHeadline = StringAsset("sec_txt_system_root_detection_headline")
  /// Diese App sollte aus Sicherheitsgründen nicht auf gejailbreakten Geräten genutzt werden.
  internal static let secTxtSystemRootDetectionMessage = StringAsset("sec_txt_system_root_detection_message")
  /// Ich nehme das erhöhte Risiko zur Kenntnis und möchte dennoch fortfahren.
  internal static let secTxtSystemRootDetectionSelection = StringAsset("sec_txt_system_root_detection_selection")
  /// Eventuell wurde dieses Gerät gejailbreakt
  internal static let secTxtSystemRootDetectionTitle = StringAsset("sec_txt_system_root_detection_title")
  /// Ausgewählt
  internal static let sectionTxtIsActiveValue = StringAsset("section_txt_is_active_value")
  /// Nicht Ausgewählt
  internal static let sectionTxtIsInactiveValue = StringAsset("section_txt_is_inactive_value")
  /// Ihre Gesundheitskarte ist bereits mit einem anderen Profil verbunden. Wechseln Sie zu Profil %@.
  internal static func sessionErrorCardConnectedWithOtherProfile(_ element1: String) -> StringAsset {
    StringAsset("session_error_card_connected_with_other_profile_%@", arguments: [element1])
  }
  /// Das aktuelle Profil ist bereits mit einer anderen Gesundheitskarte (Krankenversichertennummer: %@) verbunden.
  internal static func sessionErrorCardProfileMismatch(_ element1: String) -> StringAsset {
    StringAsset("session_error_card_profile_mismatch_%@", arguments: [element1])
  }
  /// Es konnte kein ausgewähltes Profil gefunden werden. Bitte wählen Sie ein Profil aus.
  internal static let sessionErrorNoProfile = StringAsset("session_error_no_profile")
  /// Profil hinzufügen
  internal static let stgBtnAddProfile = StringAsset("stg_btn_add_profile")
  /// Profil löschen
  internal static let stgBtnEditProfileDelete = StringAsset("stg_btn_edit_profile_delete")
  /// Abbrechen
  internal static let stgBtnEditProfileDeleteAlertCancel = StringAsset("stg_btn_edit_profile_delete_alert_cancel")
  /// Anmelden
  internal static let stgBtnEditProfileLogin = StringAsset("stg_btn_edit_profile_login")
  /// Abmelden
  internal static let stgBtnEditProfileLogout = StringAsset("stg_btn_edit_profile_logout")
  /// Speichern
  internal static let stgBtnNewProfileCreate = StringAsset("stg_btn_new_profile_create")
  /// Privacy Policy
  internal static let stgDpoTxtDataPrivacy = StringAsset("stg_dpo_txt_data_privacy")
  /// Open source licences
  internal static let stgDpoTxtFoss = StringAsset("stg_dpo_txt_foss")
  /// Terms of Use
  internal static let stgDpoTxtTermsOfUse = StringAsset("stg_dpo_txt_terms_of_use")
  /// https://www.das-e-rezept-fuer-deutschland.de/
  internal static let stgLnoLinkContact = StringAsset("stg_lno_link_contact")
  /// Open website
  internal static let stgLnoLinkTextContact = StringAsset("stg_lno_link_text_contact")
  /// app-feedback@gematik.de
  internal static let stgLnoMailContact = StringAsset("stg_lno_mail_contact")
  /// Write email
  internal static let stgLnoMailTextContact = StringAsset("stg_lno_mail_text_contact")
  /// +49-0800-277-3777
  internal static let stgLnoPhoneContact = StringAsset("stg_lno_phone_contact")
  /// Call technical hotline
  internal static let stgLnoPhoneTextContact = StringAsset("stg_lno_phone_text_contact")
  /// Imprint
  internal static let stgLnoTxtLegalNotice = StringAsset("stg_lno_txt_legal_notice")
  /// gematik GmbH\nFriedrichstr. 136\n10117 Berlin, Germany
  internal static let stgLnoTxtTextIssuer = StringAsset("stg_lno_txt_text_issuer")
  /// We strive to use gender-sensitive language. If you notice any errors, we would be pleased to hear from you by email.
  internal static let stgLnoTxtTextNote = StringAsset("stg_lno_txt_text_note")
  /// Dr. med. Markus Leyck Dieken
  internal static let stgLnoTxtTextResponsible = StringAsset("stg_lno_txt_text_responsible")
  /// Managing Director: Dr. med. Markus Leyck Dieken\nRegister Court: Amtsgericht Berlin-Charlottenburg\nCommercial register no.: HRB 96351\nVAT ID: DE241843684
  internal static let stgLnoTxtTextTaxAndMore = StringAsset("stg_lno_txt_text_taxAndMore")
  /// Contact
  internal static let stgLnoTxtTitleContact = StringAsset("stg_lno_txt_title_contact")
  /// Publisher
  internal static let stgLnoTxtTitleIssuer = StringAsset("stg_lno_txt_title_issuer")
  /// Note
  internal static let stgLnoTxtTitleNote = StringAsset("stg_lno_txt_title_note")
  /// Responsible for the content
  internal static let stgLnoTxtTitleResponsible = StringAsset("stg_lno_txt_title_responsible")
  /// Deutschlands moderne Plattform für digitale Medizin
  internal static let stgLnoYouKnowUs = StringAsset("stg_lno_you_know_us")
  /// Access Token
  internal static let stgTknTxtAccessToken = StringAsset("stg_tkn_txt_access_token")
  /// Token in Zwischenablage kopiert
  internal static let stgTknTxtCopyToClipboard = StringAsset("stg_tkn_txt_copy_to_clipboard")
  /// SSO Token
  internal static let stgTknTxtSsoToken = StringAsset("stg_tkn_txt_sso_token")
  /// Tokens
  internal static let stgTknTxtTitleTokens = StringAsset("stg_tkn_txt_title_tokens")
  /// Decline
  internal static let stgTrkBtnAlertNo = StringAsset("stg_trk_btn_alert_no")
  /// Agree
  internal static let stgTrkBtnAlertYes = StringAsset("stg_trk_btn_alert_yes")
  /// Allow anonymous analysis
  internal static let stgTrkBtnTitle = StringAsset("stg_trk_btn_title")
  /// In order to understand which functions are used frequently, we need your consent to analyse your usage behaviour. This analysis includes information about your phone's hardware and software (device type, operating system version etc.), settings of the e-prescription app as well as the extent of use, but never any personal or health data concerning you. \n\nThis data is made available exclusively to gematik GmbH by data processors and is deleted after 180 days at the latest. You can disable the analysis of your usage behaviour at any time in the settings menu of the app.
  internal static let stgTrkTxtAlertMessage = StringAsset("stg_trk_txt_alert_message")
  /// Do you consent to the anonymous analysis of usage behaviour by the e-prescription app?
  internal static let stgTrkTxtAlertTitle = StringAsset("stg_trk_txt_alert_title")
  /// Help us make this app better. All usage data is collected anonymously and is used solely to improve the user experience.
  internal static let stgTrkTxtExplanation = StringAsset("stg_trk_txt_explanation")
  /// In the event of a crash or an error in the app, the app sends us information about the reasons along with the operating system version and details of the hardware used.
  internal static let stgTrkTxtFootnote = StringAsset("stg_trk_txt_footnote")
  /// The collection of usage data is disabled in demo mode.
  internal static let stgTrkTxtFootnoteDisabled = StringAsset("stg_trk_txt_footnote_disabled")
  /// Improve user experience
  internal static let stgTrkTxtTitle = StringAsset("stg_trk_txt_title")
  /// Demo mode is disabled
  internal static let stgTxtAlertMessageDemoModeOff = StringAsset("stg_txt_alert_message_demo_mode_off")
  /// Demo mode is active. You do not need a medical card or a connection to the Internet. The displayed test prescriptions cannot be redeemed in a pharmacy.
  internal static let stgTxtAlertMessageDemoModeOn = StringAsset("stg_txt_alert_message_demo_mode_on")
  /// Would you like a tour of the app?
  internal static let stgTxtAlertTitleDemoMode = StringAsset("stg_txt_alert_title_demo_mode")
  /// Zuletzt aktualisiert: %@
  internal static func stgTxtAuditEventsLastUpdated(_ element1: String) -> StringAsset {
    StringAsset("stg_txt_audit_events_last_updated_%@", arguments: [element1])
  }
  /// Kein Zeitstempel
  internal static let stgTxtAuditEventsMissingDate = StringAsset("stg_txt_audit_events_missing_date")
  /// Keine Angabe
  internal static let stgTxtAuditEventsMissingDescription = StringAsset("stg_txt_audit_events_missing_description")
  /// Ohne Titel
  internal static let stgTxtAuditEventsMissingTitle = StringAsset("stg_txt_audit_events_missing_title")
  /// Nächste
  internal static let stgTxtAuditEventsNext = StringAsset("stg_txt_audit_events_next")
  /// Sie erhalten Zugriffsprotokolle, wenn Sie am Rezeptdienst angemeldet sind.
  internal static let stgTxtAuditEventsNoProtocolDescription = StringAsset("stg_txt_audit_events_no_protocol_description")
  /// Keine Zugriffsprotokolle
  internal static let stgTxtAuditEventsNoProtocolTitle = StringAsset("stg_txt_audit_events_no_protocol_title")
  /// Seite %@ von %@
  internal static func stgTxtAuditEventsPageSelectionOf(_ element1: String,_ element2: String) -> StringAsset {
    StringAsset("stg_txt_audit_events_page_selection_%@_of_%@", arguments: [element1, element2])
  }
  /// Vorherige
  internal static let stgTxtAuditEventsPrevious = StringAsset("stg_txt_audit_events_previous")
  /// Zugriffsprotokolle
  internal static let stgTxtAuditEventsTitle = StringAsset("stg_txt_audit_events_title")
  /// Demo mode
  internal static let stgTxtDemoMode = StringAsset("stg_txt_demo_mode")
  /// Hintergrundfarbe
  internal static let stgTxtEditProfileBackgroundSectionTitle = StringAsset("stg_txt_edit_profile_background_section_title")
  /// Hiermit werden alle Daten auf diesem Gerät gelöscht. Ihre Rezepte im Gesundheitsnetzwerk bleiben erhalten.
  internal static let stgTxtEditProfileDeleteConfirmationMessage = StringAsset("stg_txt_edit_profile_delete_confirmation_message")
  /// Profil löschen?
  internal static let stgTxtEditProfileDeleteConfirmationTitle = StringAsset("stg_txt_edit_profile_delete_confirmation_title")
  /// Das Namensfeld darf nicht leer sein
  internal static let stgTxtEditProfileEmptyNameErrorMessage = StringAsset("stg_txt_edit_profile_empty_name_error_message")
  /// Fehler
  internal static let stgTxtEditProfileErrorMessageTitle = StringAsset("stg_txt_edit_profile_error_message_title")
  /// Zugangsnummer (CAN)
  internal static let stgTxtEditProfileLabelCan = StringAsset("stg_txt_edit_profile_label_can")
  /// Versicherung
  internal static let stgTxtEditProfileLabelInsuranceCompany = StringAsset("stg_txt_edit_profile_label_insurance_company")
  /// Versichertennummer
  internal static let stgTxtEditProfileLabelKvnr = StringAsset("stg_txt_edit_profile_label_kvnr")
  /// Name
  internal static let stgTxtEditProfileLabelName = StringAsset("stg_txt_edit_profile_label_name")
  /// Hiermit trennen Sie die Verbindung zum Gesundheitsnetzwerk. Sie erhalten keine neuen Rezepte oder Nachrichten.
  internal static let stgTxtEditProfileLogoutInfo = StringAsset("stg_txt_edit_profile_logout_info")
  /// Verknüpft mit: %@
  internal static func stgTxtEditProfileNameConnection(_ element1: String) -> StringAsset {
    StringAsset("stg_txt_edit_profile_name_connection_%@", arguments: [element1])
  }
  /// Dieses Profil wurde noch nicht mit einer Versichertennummer verbunden. Hierfür müssen Sie sich am Rezeptserver anmelden.
  internal static let stgTxtEditProfileNameConnectionPlaceholder = StringAsset("stg_txt_edit_profile_name_connection_placeholder")
  /// Name eingeben
  internal static let stgTxtEditProfileNamePlaceholder = StringAsset("stg_txt_edit_profile_name_placeholder")
  /// Sicherheit
  internal static let stgTxtEditProfileSecuritySectionTitle = StringAsset("stg_txt_edit_profile_security_section_title")
  /// Wer hat wann auf Ihre Rezepte zugegriffen?
  internal static let stgTxtEditProfileSecurityShowAuditEventsDescription = StringAsset("stg_txt_edit_profile_security_show_audit_events_description")
  /// Zugriffsprotokolle anzeigen
  internal static let stgTxtEditProfileSecurityShowAuditEventsLabel = StringAsset("stg_txt_edit_profile_security_show_audit_events_label")
  /// Zugangsschlüssel zum Rezeptdienst
  internal static let stgTxtEditProfileSecurityShowTokensDescription = StringAsset("stg_txt_edit_profile_security_show_tokens_description")
  /// Sie erhalten einen Token, wenn Sie am Rezeptdienst angemeldet sind.
  internal static let stgTxtEditProfileSecurityShowTokensHint = StringAsset("stg_txt_edit_profile_security_show_tokens_hint")
  /// Tokens anzeigen
  internal static let stgTxtEditProfileSecurityShowTokensLabel = StringAsset("stg_txt_edit_profile_security_show_tokens_label")
  /// Profil
  internal static let stgTxtEditProfileTitle = StringAsset("stg_txt_edit_profile_title")
  /// Versichertendaten
  internal static let stgTxtEditProfileUserDataSectionTitle = StringAsset("stg_txt_edit_profile_user_data_section_title")
  /// Our demo mode shows you all the functions of the app – without a medical card.
  internal static let stgTxtFootnoteDemoMode = StringAsset("stg_txt_footnote_demo_mode")
  /// Launch demo mode
  internal static let stgTxtHeaderDemoMode = StringAsset("stg_txt_header_demo_mode")
  /// Legal information
  internal static let stgTxtHeaderLegalInfo = StringAsset("stg_txt_header_legal_info")
  /// Profile
  internal static let stgTxtHeaderProfiles = StringAsset("stg_txt_header_profiles")
  /// Security
  internal static let stgTxtHeaderSecurity = StringAsset("stg_txt_header_security")
  /// Hintergrundfarbe
  internal static let stgTxtNewProfileBackgroundSectionTitle = StringAsset("stg_txt_new_profile_background_section_title")
  /// Fehler
  internal static let stgTxtNewProfileErrorMessageTitle = StringAsset("stg_txt_new_profile_error_message_title")
  /// Das Namensfeld darf nicht leer sein
  internal static let stgTxtNewProfileMissingNameError = StringAsset("stg_txt_new_profile_missing_name_error")
  /// Name eingeben
  internal static let stgTxtNewProfileNamePlaceholder = StringAsset("stg_txt_new_profile_name_placeholder")
  /// Neues Profil anlegen
  internal static let stgTxtNewProfileTitle = StringAsset("stg_txt_new_profile_title")
  /// Face ID
  internal static let stgTxtSecurityOptionFaceidTitle = StringAsset("stg_txt_security_option_faceid_title")
  /// Kennwort
  internal static let stgTxtSecurityOptionPasswordTitle = StringAsset("stg_txt_security_option_password_title")
  /// Touch ID
  internal static let stgTxtSecurityOptionTouchidTitle = StringAsset("stg_txt_security_option_touchid_title")
  /// This app has not yet been secured. Improve the protection of your data with a fingerprint or face scan.
  internal static let stgTxtSecurityWarning = StringAsset("stg_txt_security_warning")
  /// Settings
  internal static let stgTxtTitle = StringAsset("stg_txt_title")
  /// Version %@ • Build %@
  internal static func stgTxtVersionAndBuild(_ element1: String,_ element2: String) -> StringAsset {
    StringAsset("stg_txt_version_%@_and_build_%@", arguments: [element1, element2])
  }
  /// Prescriptions
  internal static let tabTxtMain = StringAsset("tab_txt_main")
  /// Messages
  internal static let tabTxtMessages = StringAsset("tab_txt_messages")
  /// Apotheken
  internal static let tabTxtPharmacySearch = StringAsset("tab_txt_pharmacy_search")
  /// Einstellungen
  internal static let tabTxtSettings = StringAsset("tab_txt_settings")
}
// swiftlint:enable function_parameter_count identifier_name line_length type_body_length
