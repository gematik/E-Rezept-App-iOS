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
    /// Cancel
    internal static let amgBtnAlertCancel = StringAsset("amg_btn_alert_cancel")
    /// Delete data
    internal static let amgBtnAlertDeleteDatabase = StringAsset("amg_btn_alert_delete_database")
    /// Repeat
    internal static let amgBtnAlertRetry = StringAsset("amg_btn_alert_retry")
    /// Update failed
    internal static let amgBtnAlertTitle = StringAsset("amg_btn_alert_title")
    /// If this error occurs repeatedly, please delete the app and reinstall it
    internal static let amgTxtAlertMessageDeleteDatabase = StringAsset("amg_txt_alert_message_delete_database")
    /// Deletion failed
    internal static let amgTxtAlertTitleDeleteDatabase = StringAsset("amg_txt_alert_title_delete_database")
    /// Update...
    internal static let amgTxtInProgress = StringAsset("amg_txt_in_progress")
    /// Unlock with Face ID
    internal static let authBtnBiometricsFaceid = StringAsset("auth_btn_biometrics_faceid")
    /// Unlock with Touch ID
    internal static let authBtnBiometricsTouchid = StringAsset("auth_btn_biometrics_touchid")
    /// Continue
    internal static let authBtnPasswordContinue = StringAsset("auth_btn_password_continue")
    /// Please be aware that people with whom you may share this device and whose biometrics may be stored on this device may also have access to your prescriptions.
    internal static let authTxtBiometricsDisclaimer = StringAsset("auth_txt_biometrics_disclaimer")
    /// Secure with Face ID
    internal static let authTxtBiometricsFaceIdTitle = StringAsset("auth_txt_biometrics_face_id_title")
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
    /// Do you have any questions or problems concerning use of the app? You can contact our technical hotline on 0800 277 377 7. 
    /// 
    /// We have already answered plenty of questions for you at das-e-rezept-fuer-deutschland.de.
    internal static let authTxtBiometricsFooter = StringAsset("auth_txt_biometrics_footer")
    /// app-feedback@gematik.de
    internal static let authTxtBiometricsFooterEmailDisplay = StringAsset("auth_txt_biometrics_footer_email_display")
    /// mailto:app-feedback@gematik.de
    internal static let authTxtBiometricsFooterEmailLink = StringAsset("auth_txt_biometrics_footer_email_link")
    /// das-e-rezept-fuer-deutschland.de
    internal static let authTxtBiometricsFooterUrlDisplay = StringAsset("auth_txt_biometrics_footer_url_display")
    /// https://www.das-e-rezept-fuer-deutschland.de
    internal static let authTxtBiometricsFooterUrlLink = StringAsset("auth_txt_biometrics_footer_url_link")
    /// You have had too many incorrect login attempts. Go to  your iPhone settings and reactivate the FaceID or TouchID function by entering a PIN.
    internal static let authTxtBiometricsLockout = StringAsset("auth_txt_biometrics_lockout")
    /// Secure with password
    internal static let authTxtBiometricsPasswordTitle = StringAsset("auth_txt_biometrics_password_title")
    /// %@ is required to protect the app from unauthorised access.
    internal static func authTxtBiometricsReason(_ element1: String) -> StringAsset {
        StringAsset("auth_txt_biometrics_reason", arguments: [element1])
    }
    /// Welcome
    internal static let authTxtBiometricsTitle = StringAsset("auth_txt_biometrics_title")
    /// Secure with Touch ID
    internal static let authTxtBiometricsTouchIdTitle = StringAsset("auth_txt_biometrics_touch_id_title")
    /// You have selected Touch ID to secure your data.
    internal static let authTxtBiometricsTouchidDescription = StringAsset("auth_txt_biometrics_touchid_description")
    /// Unlock with Touch ID
    internal static let authTxtBiometricsTouchidStart = StringAsset("auth_txt_biometrics_touchid_start")
    /// Plural format key: "%#@variable_0@"
    internal static func authTxtFailedLoginHintMsg(_ element1: Int) -> StringAsset {
        StringAsset("auth_txt_failed_login_hint_msg", arguments: [element1])
    }
    /// Unsuccessful login attempts
    internal static let authTxtFailedLoginHintTitle = StringAsset("auth_txt_failed_login_hint_title")
    /// Incorrect password. Please try again.
    internal static let authTxtPasswordFailure = StringAsset("auth_txt_password_failure")
    /// Password input field
    internal static let authTxtPasswordLabel = StringAsset("auth_txt_password_label")
    /// Enter password
    internal static let authTxtPasswordPlaceholder = StringAsset("auth_txt_password_placeholder")
    /// Interner Fehler (%@)
    internal static func avsErrInternal(_ element1: String) -> StringAsset {
        StringAsset("avs_err_internal_%@", arguments: [element1])
    }
    /// Ungültiges Apothekenzertifikat
    internal static let avsErrInvalidCert = StringAsset("avs_err_invalid_cert")
    /// Fehlerhafte Nachricht
    internal static let avsErrInvalidInput = StringAsset("avs_err_invalid_input")
    /// Bitte informieren Sie den Support, sollte der Fehler dauerhaft auftreten.
    internal static let avsErrRecoveryInternal = StringAsset("avs_err_recovery_internal")
    /// Das Zertifikat der Apotheke zur Übertragung ist ungültig. Bitte melden Sie sich an oder wählen eine andere Apotheke.
    internal static let avsErrRecoveryInvalidCert = StringAsset("avs_err_recovery_invalid_cert")
    /// Die Daten für die Reservierung in der ausgewählten Apotheke sind unvollständig. Bitte melden Sie sich an oder wählen eine andere Apotheke.
    internal static let avsErrRecoveryInvalidInput = StringAsset("avs_err_recovery_invalid_input")
    /// Demo mode enabled
    internal static let bnrTxtDemoMode = StringAsset("bnr_txt_demo_mode")
    /// inactive
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
    /// Zugangsnummer mit Kamera einlesen
    internal static let cdwBtnCanScanner = StringAsset("cdw_btn_can_scanner")
    /// Close
    internal static let cdwBtnExtauthAlertSaveProfile = StringAsset("cdw_btn_extauth_alert_save_profile")
    /// Cancel
    internal static let cdwBtnExtauthConfirmCancel = StringAsset("cdw_btn_extauth_confirm_cancel")
    /// Contact technical customer service
    internal static let cdwBtnExtauthConfirmContact = StringAsset("cdw_btn_extauth_confirm_contact")
    /// Send
    internal static let cdwBtnExtauthConfirmSend = StringAsset("cdw_btn_extauth_confirm_send")
    /// Order medical card
    internal static let cdwBtnExtauthFallbackOrderEgk = StringAsset("cdw_btn_extauth_fallback_order_egk")
    /// Cancel
    internal static let cdwBtnExtauthSelectionCancel = StringAsset("cdw_btn_extauth_selection_cancel")
    /// Continue
    internal static let cdwBtnExtauthSelectionContinue = StringAsset("cdw_btn_extauth_selection_continue")
    /// Order medical card
    internal static let cdwBtnExtauthSelectionOrderEgk = StringAsset("cdw_btn_extauth_selection_order_egk")
    /// Try again
    internal static let cdwBtnExtauthSelectionRetry = StringAsset("cdw_btn_extauth_selection_retry")
    /// Direkt nach Drücken dieses Buttons wird die Gesundheitskarte über NFC eingelesen. Halten Sie die Karte dafür direkt ans Gerät. Im Falle einer erfolgreichen Verbindung erhalten Sie haptisches Feedback. Ein Abbruch der Verbindung oder Fehler werden ebenfalls über haptisches Feedback kommuniziert. Die Kommunikation mit der Gesundheitskarte kann bis zu zehn Sekunden dauern. Entfernen Sie anschließend die Gesundheitskarte vom Gerät.
    internal static let cdwBtnHelpNextHint = StringAsset("cdw_btn_help_next_hint")
    /// Close dialog
    internal static let cdwBtnIntroCancelLabel = StringAsset("cdw_btn_intro_cancel_label")
    /// health insurance app
    internal static let cdwBtnIntroFasttrackCenter = StringAsset("cdw_btn_intro_fasttrack_center")
    /// Or: Sign in with your
    internal static let cdwBtnIntroFasttrackLeading = StringAsset("cdw_btn_intro_fasttrack_leading")
    /// .
    internal static let cdwBtnIntroFasttrackTrailing = StringAsset("cdw_btn_intro_fasttrack_trailing")
    /// Order now
    internal static let cdwBtnIntroFootnote = StringAsset("cdw_btn_intro_footnote")
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
    /// Meine Karte verfügt über keine Zugangsnummer
    internal static let cdwBtnNoCan = StringAsset("cdw_btn_no_can")
    /// Zurück
    internal static let cdwBtnPinBack = StringAsset("cdw_btn_pin_back")
    /// Cancel
    internal static let cdwBtnPinCancelLabel = StringAsset("cdw_btn_pin_cancel_label")
    /// Next
    internal static let cdwBtnPinDone = StringAsset("cdw_btn_pin_done")
    /// Next
    internal static let cdwBtnPinDoneLabel = StringAsset("cdw_btn_pin_done_label")
    /// Keine PIN erhalten?
    internal static let cdwBtnPinNoPin = StringAsset("cdw_btn_pin_no_pin")
    /// Cancel
    internal static let cdwBtnRcAlertCancel = StringAsset("cdw_btn_rc_alert_cancel")
    /// Close
    internal static let cdwBtnRcAlertClose = StringAsset("cdw_btn_rc_alert_close")
    /// Report
    internal static let cdwBtnRcAlertReport = StringAsset("cdw_btn_rc_alert_report")
    /// Close
    internal static let cdwBtnRcAlertSaveProfile = StringAsset("cdw_btn_rc_alert_save_profile")
    /// Back
    internal static let cdwBtnRcBack = StringAsset("cdw_btn_rc_back")
    /// Close dialog
    internal static let cdwBtnRcCancelLabel = StringAsset("cdw_btn_rc_cancel_label")
    /// Close
    internal static let cdwBtnRcClose = StringAsset("cdw_btn_rc_close")
    /// Enter correct access number
    internal static let cdwBtnRcCorrectCan = StringAsset("cdw_btn_rc_correct_can")
    /// Enter correct PIN
    internal static let cdwBtnRcCorrectPin = StringAsset("cdw_btn_rc_correct_pin")
    /// Help
    internal static let cdwBtnRcHelp = StringAsset("cdw_btn_rc_help")
    /// Back
    internal static let cdwBtnRcHelpBack = StringAsset("cdw_btn_rc_help_back")
    /// Close
    internal static let cdwBtnRcHelpClose = StringAsset("cdw_btn_rc_help_close")
    /// https://www.youtube.com/watch?v=EqY6tF7UU-c
    internal static let cdwBtnRcHelpUrl = StringAsset("cdw_btn_rc_help_url")
    /// Loading
    internal static let cdwBtnRcLoading = StringAsset("cdw_btn_rc_loading")
    /// Connect card
    internal static let cdwBtnRcNext = StringAsset("cdw_btn_rc_next")
    /// As soon as this button is pressed, the medical card is read via NFC. To do this, hold the card directly against the device. If the connection is successful, you will receive tactile feedback. Any interruptions to the connection or errors are also communicated via tactile feedback. Communication with the medical card can take up to ten seconds. Then remove the medical card from the device.
    internal static let cdwBtnRcNextHint = StringAsset("cdw_btn_rc_next_hint")
    /// Next tip
    internal static let cdwBtnRcNextTip = StringAsset("cdw_btn_rc_next_tip")
    /// Repeat
    internal static let cdwBtnRcRetry = StringAsset("cdw_btn_rc_retry")
    /// Try out
    internal static let cdwBtnRcTryout = StringAsset("cdw_btn_rc_tryout")
    /// Watch video tutorial
    internal static let cdwBtnRcVideo = StringAsset("cdw_btn_rc_video")
    /// As soon as this button is pressed, the medical card is read via NFC. To do this, hold the card directly against the device. If the connection is successful, you will receive tactile feedback. Any interruptions to the connection or errors are also communicated via tactile feedback. Communication with the medical card can take up to ten seconds. Then remove the medical card from the device.
    internal static let cdwBtnRchelpNextHint = StringAsset("cdw_btn_rchelp_next_hint")
    /// Next
    internal static let cdwBtnSelContinue = StringAsset("cdw_btn_sel_continue")
    /// Cancel scanning
    internal static let cdwCanScanBtnClose = StringAsset("cdw_can_scan_btn_close")
    /// Accept
    internal static let cdwCanScanBtnConfirm = StringAsset("cdw_can_scan_btn_confirm")
    /// Platzieren Sie die Gesundheitskarte innerhalb des Ausschnitts
    internal static let cdwCanScanTxtHint = StringAsset("cdw_can_scan_txt_hint")
    /// Zugangsnummer erkannt:
    internal static let cdwCanScanTxtResult = StringAsset("cdw_can_scan_txt_result")
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
    /// Dauerhafte Verbindungsproblem?
    internal static let cdwRcTxtErrorBadCardDescription = StringAsset("cdw_rc_txt_error_bad_card_description")
    /// Einige Karten haben schwache Antennen. Bitte melden Sie uns Ihre Karte, damit wir gemeinsam mit den Kassen an einer Verbesserung arbeiten können.
    internal static let cdwRcTxtErrorBadCardRecovery = StringAsset("cdw_rc_txt_error_bad_card_recovery")
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
    /// This app uses Face ID or Touch ID to store your login data in a protected area of the device memory.
    /// 
    /// Avoid installation on the following devices:
    /// * Devices on which a so-called "jailbreak" has been carried out.
    /// * Work devices with administration rights by the employer (COPE "Corporate Owned, Personally Enabled" or BYOD "Bring Your Own Device")
    /// Virtual environments (emulators) that make Android available on other platforms.
    /// 
    /// Please be aware that people with whom you may share this device and whose biometrics may be stored on this device may also have access to your prescriptions.
    internal static let cdwTxtBiometrySecurityWarningDescription = StringAsset("cdw_txt_biometry_security_warning_description")
    /// Security notice
    internal static let cdwTxtBiometrySecurityWarningTitle = StringAsset("cdw_txt_biometry_security_warning_title")
    /// Zugangsdaten speichern nicht möglich. Richten Sie zuvor auf Ihrem Gerät eine biometrische Absicherung mit Face ID oder Touch ID ein.
    internal static let cdwTxtBiometrySetupIncomplete = StringAsset("cdw_txt_biometry_setup_incomplete")
    /// Would you like to save your login details for future logins?
    internal static let cdwTxtBiometrySubtitle = StringAsset("cdw_txt_biometry_subtitle")
    /// Login
    internal static let cdwTxtBiometryTitle = StringAsset("cdw_txt_biometry_title")
    /// You can enter any digits.
    internal static let cdwTxtCanDemoModeInfo = StringAsset("cdw_txt_can_demo_mode_info")
    /// Ihre Zugangsnummer (Card Access Number, kurz: CAN) finden Sie in der rechten oberen Ecke Ihrer Gesundheitskarte.
    internal static let cdwTxtCanDescription = StringAsset("cdw_txt_can_description")
    /// Enter access number
    internal static let cdwTxtCanSubtitle = StringAsset("cdw_txt_can_subtitle")
    /// Login
    internal static let cdwTxtCanTitle = StringAsset("cdw_txt_can_title")
    /// Geben Sie hier Ihre Kartenzugangsnummer ein. Sie hat 6 Stellen. Sie finden die Zugangsnummer in der rechten oberen Ecke der Vorderseite Ihrer Gesundheitskarte. Sie können die CAN über die Kamera einlesen. Steht hier keine 6-stellige Zugangsnummer, benötigen Sie eine neue Gesundheitskarte von Ihrer Krankenversicherung. Zum bearbeiten doppeltippen.
    internal static let cdwTxtCanTitleHint = StringAsset("cdw_txt_can_title_hint")
    /// Unfortunately, the CAN entered does not match the recognised card. Please enter the CAN again. Thank you!
    internal static let cdwTxtCanWarnWrongDescription = StringAsset("cdw_txt_can_warn_wrong_description")
    /// Incorrect CAN
    internal static let cdwTxtCanWarnWrongTitle = StringAsset("cdw_txt_can_warn_wrong_title")
    /// Your medical card could not be linked to the profile.
    internal static let cdwTxtExtauthAlertMessageSaveProfile = StringAsset("cdw_txt_extauth_alert_message_save_profile")
    /// Error saving profile
    internal static let cdwTxtExtauthAlertTitleSaveProfile = StringAsset("cdw_txt_extauth_alert_title_save_profile")
    /// Email
    internal static let cdwTxtExtauthConfirmContactsheetMail = StringAsset("cdw_txt_extauth_confirm_contactsheet_mail")
    /// Phone
    internal static let cdwTxtExtauthConfirmContactsheetTelephone = StringAsset("cdw_txt_extauth_confirm_contactsheet_telephone")
    /// Contact customer service
    internal static let cdwTxtExtauthConfirmContactsheetTitle = StringAsset("cdw_txt_extauth_confirm_contactsheet_title")
    /// We will now request authentication from your health insurance company.
    internal static let cdwTxtExtauthConfirmDescription = StringAsset("cdw_txt_extauth_confirm_description")
    /// Please mention this error to our technical customer service to facilitate the search for a solution.
    internal static let cdwTxtExtauthConfirmErrorDescription = StringAsset("cdw_txt_extauth_confirm_error_description")
    /// Requesting  authentication
    internal static let cdwTxtExtauthConfirmHeadline = StringAsset("cdw_txt_extauth_confirm_headline")
    /// E-prescription
    internal static let cdwTxtExtauthConfirmOwnAppname = StringAsset("cdw_txt_extauth_confirm_own_appname")
    /// Log in with app
    internal static let cdwTxtExtauthConfirmTitle = StringAsset("cdw_txt_extauth_confirm_title")
    /// Error opening the health insurance app.
    internal static let cdwTxtExtauthConfirmUniversalLinkFailedError = StringAsset("cdw_txt_extauth_confirm_universal_link_failed_error")
    /// The health insurance companies are currently preparing for this function.
    internal static let cdwTxtExtauthFallbackDescription1 = StringAsset("cdw_txt_extauth_fallback_description1")
    /// You don't want to wait? Registration with a medical card is already supported by every health insurance company.
    internal static let cdwTxtExtauthFallbackDescription2 = StringAsset("cdw_txt_extauth_fallback_description2")
    /// Select  insurance company
    internal static let cdwTxtExtauthFallbackHeadline = StringAsset("cdw_txt_extauth_fallback_headline")
    /// Log in with app
    internal static let cdwTxtExtauthFallbackTitle = StringAsset("cdw_txt_extauth_fallback_title")
    /// Didn't find what you were looking for? This list is constantly being expanded. Login with a medical card is already supported by every health insurance company.
    internal static let cdwTxtExtauthSelectionDescription = StringAsset("cdw_txt_extauth_selection_description")
    /// This feature will be available in a few days. Please try again later.
    internal static let cdwTxtExtauthSelectionEmptyListDescription = StringAsset("cdw_txt_extauth_selection_empty_list_description")
    /// Not yet available
    internal static let cdwTxtExtauthSelectionEmptyListHeadline = StringAsset("cdw_txt_extauth_selection_empty_list_headline")
    ///  Please try again later.
    internal static let cdwTxtExtauthSelectionErrorFallback = StringAsset("cdw_txt_extauth_selection_error_fallback")
    /// Select  insurance company
    internal static let cdwTxtExtauthSelectionHeadline = StringAsset("cdw_txt_extauth_selection_headline")
    /// Log in with app
    internal static let cdwTxtExtauthSelectionTitle = StringAsset("cdw_txt_extauth_selection_title")
    /// To be able to use all functions of the app, log in with your medical card. You will receive this card and the required login details from your health insurance company.
    internal static let cdwTxtIntroDescription = StringAsset("cdw_txt_intro_description")
    /// Receive prescriptions online and forward them to a pharmacy.
    internal static let cdwTxtIntroDescriptionNew = StringAsset("cdw_txt_intro_description_new")
    /// NFC-enabled medical card
    internal static let cdwTxtIntroEgkCheckmark = StringAsset("cdw_txt_intro_egk_checkmark")
    /// Don't have an NFC-enabled medical card and PIN yet?
    internal static let cdwTxtIntroFootnote = StringAsset("cdw_txt_intro_footnote")
    /// Use all functions now
    internal static let cdwTxtIntroHeaderBottom = StringAsset("cdw_txt_intro_header_bottom")
    /// Login
    internal static let cdwTxtIntroHeaderTop = StringAsset("cdw_txt_intro_header_top")
    /// What you need:
    internal static let cdwTxtIntroListTitle = StringAsset("cdw_txt_intro_list_title")
    /// What you need:
    internal static let cdwTxtIntroNeededSubheadline = StringAsset("cdw_txt_intro_needed_subheadline")
    /// Medical card PIN
    internal static let cdwTxtIntroPinCheckmark = StringAsset("cdw_txt_intro_pin_checkmark")
    /// An NFC-enabled medical card with access number (CAN)
    internal static let cdwTxtIntroRequirementCard = StringAsset("cdw_txt_intro_requirement_card")
    /// An NFC-enabled device with iOS 14
    internal static let cdwTxtIntroRequirementPhone = StringAsset("cdw_txt_intro_requirement_phone")
    /// The PIN for the medical card
    internal static let cdwTxtIntroRequirementPin = StringAsset("cdw_txt_intro_requirement_pin")
    /// iOS App: NFC read error
    internal static let cdwTxtMailSubject = StringAsset("cdw_txt_mail_subject")
    /// Unfortunately, your device does not meet the minimum requirements for logging into the e-prescription app. For secure authentication with your medical card, at least iOS 14 and an NFC chip are required.
    internal static let cdwTxtNfuDescription = StringAsset("cdw_txt_nfu_description")
    /// What a pity ...
    internal static let cdwTxtNfuSubtitle = StringAsset("cdw_txt_nfu_subtitle")
    /// Login
    internal static let cdwTxtNfuTitle = StringAsset("cdw_txt_nfu_title")
    /// You can enter any digits.
    internal static let cdwTxtPinDemoModeInfo = StringAsset("cdw_txt_pin_demo_mode_info")
    /// Ihre PIN haben Sie in einem Brief von Ihrer Krankenversicherung erhalten.
    internal static let cdwTxtPinDescription = StringAsset("cdw_txt_pin_description")
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
    /// Your medical card could not be linked to the profile.
    internal static let cdwTxtRcAlertMessageSaveProfile = StringAsset("cdw_txt_rc_alert_message_save_profile")
    /// Error saving profile
    internal static let cdwTxtRcAlertTitleSaveProfile = StringAsset("cdw_txt_rc_alert_title_save_profile")
    /// Der NFC-Empfänger Ihres Geräts befindet sich bei der Markierung. Halten Sie Ihre Karte so nah wie möglich an diese Stelle.
    internal static let cdwTxtRcCard = StringAsset("cdw_txt_rc_card")
    /// Karte am NFC-Empfänger platzieren
    internal static let cdwTxtRcCardHeader = StringAsset("cdw_txt_rc_card_header")
    /// Now hold your card on the display and press "Connect card".
    internal static let cdwTxtRcCta = StringAsset("cdw_txt_rc_cta")
    /// You do not need a medical card in demo mode.
    internal static let cdwTxtRcDemoModeInfo = StringAsset("cdw_txt_rc_demo_mode_info")
    /// Click Login and hold your card against the device as shown. Do not move the card once a connection has been established.
    internal static let cdwTxtRcDescription = StringAsset("cdw_txt_rc_description")
    /// Card blocked
    internal static let cdwTxtRcErrorCardLockedDescription = StringAsset("cdw_txt_rc_error_card_locked_description")
    /// The PIN was entered incorrectly three times. Your card has therefore been blocked for security reasons.
    internal static let cdwTxtRcErrorCardLockedRecovery = StringAsset("cdw_txt_rc_error_card_locked_recovery")
    /// Error reading the medical card
    internal static let cdwTxtRcErrorGenericCardDescription = StringAsset("cdw_txt_rc_error_generic_card_description")
    /// Please try again
    internal static let cdwTxtRcErrorGenericCardRecovery = StringAsset("cdw_txt_rc_error_generic_card_recovery")
    /// Schreibvorgang nicht erfolgreich
    internal static let cdwTxtRcErrorMemoryFailureDescription = StringAsset("cdw_txt_rc_error_memory_failure_description")
    /// PIN konnte nicht gespeichert werden.
    internal static let cdwTxtRcErrorMemoryFailureRecovery = StringAsset("cdw_txt_rc_error_memory_failure_recovery")
    /// Eigene PIN vergeben
    internal static let cdwTxtRcErrorOwnPinDescription = StringAsset("cdw_txt_rc_error_own_pin_description")
    /// Die Karte ist mit einer PIN Ihrer Krankenkasse (Transport-PIN) gesichert, bitte vergeben Sie eine eigene PIN.
    internal static let cdwTxtRcErrorOwnPinRecovery = StringAsset("cdw_txt_rc_error_own_pin_recovery")
    /// Passwort nicht gefunden
    internal static let cdwTxtRcErrorPasswordMissingDescription = StringAsset("cdw_txt_rc_error_password_missing_description")
    /// Es ist kein Passwort auf Ihrer Karte hinterlegt.
    internal static let cdwTxtRcErrorPasswordMissingRecovery = StringAsset("cdw_txt_rc_error_password_missing_recovery")
    /// Zugriffsregel verletzt
    internal static let cdwTxtRcErrorSecStatusDescription = StringAsset("cdw_txt_rc_error_sec_status_description")
    /// Sie haben nicht die Berechtigung, auf das Kartenverzeichnis zuzugreifen.
    internal static let cdwTxtRcErrorSecStatusRecovery = StringAsset("cdw_txt_rc_error_sec_status_recovery")
    /// Zugangsdaten speichern nicht möglich. Richten Sie zuvor auf Ihrem Gerät eine biometrische Absicherung mit Face ID oder Touch ID ein.
    internal static let cdwTxtRcErrorSecureEnclaveIssue = StringAsset("cdw_txt_rc_error_secure_enclave_issue")
    /// Unbekannter Kartenfehler
    internal static let cdwTxtRcErrorUnknownFailureDescription = StringAsset("cdw_txt_rc_error_unknown_failure_description")
    /// Die Karte antwortet mit einem nicht spezifizierten Fehler.
    internal static let cdwTxtRcErrorUnknownFailureRecovery = StringAsset("cdw_txt_rc_error_unknown_failure_recovery")
    /// Incorrect access number
    internal static let cdwTxtRcErrorWrongCanDescription = StringAsset("cdw_txt_rc_error_wrong_can_description")
    /// Please enter the correct access number (CAN)
    internal static let cdwTxtRcErrorWrongCanRecovery = StringAsset("cdw_txt_rc_error_wrong_can_recovery")
    /// Incorrect pin
    internal static let cdwTxtRcErrorWrongPinDescription = StringAsset("cdw_txt_rc_error_wrong_pin_description_%@")
    /// %@ attempts left. Please enter the correct PIN.
    internal static func cdwTxtRcErrorWrongPinRecovery(_ element1: String) -> StringAsset {
        StringAsset("cdw_txt_rc_error_wrong_pin_recovery_%@", arguments: [element1])
    }
    /// Have your medical card ready
    internal static let cdwTxtRcHeadline = StringAsset("cdw_txt_rc_headline")
    /// Überprüfen Sie, ob Ihr Gerät ausreichend geladen ist.
    internal static let cdwTxtRcListCharge = StringAsset("cdw_txt_rc_list_charge")
    /// Remove the protective case if necessary.
    internal static let cdwTxtRcListCover = StringAsset("cdw_txt_rc_list_cover")
    /// Legen Sie die Karte direkt auf das Gerät.
    internal static let cdwTxtRcListDevice = StringAsset("cdw_txt_rc_list_device")
    /// Schalten Sie Ihr Display aus und wieder an.
    internal static let cdwTxtRcListDisplay = StringAsset("cdw_txt_rc_list_display")
    /// Authentifizieren Sie sich mit einer App Ihrer Krankenversicherung.
    internal static let cdwTxtRcListFasttrack = StringAsset("cdw_txt_rc_list_fasttrack")
    /// Jetzt Anmelden
    internal static let cdwTxtRcListFasttrackMore = StringAsset("cdw_txt_rc_list_fasttrack_more")
    /// Nicht geklappt? Hier ein paar weitere Tipps.
    internal static let cdwTxtRcListHeader = StringAsset("cdw_txt_rc_list_header")
    /// Starten Sie die E-Rezept App oder das Mobilgerät neu.
    internal static let cdwTxtRcListRestart = StringAsset("cdw_txt_rc_list_restart")
    /// Zur Veranschaulichung haben wir in einem kurzen Video unsere Tipps zur Verbindung zwischen Mobilgerät und Gesundheitskarte für Sie zusammengetragen.
    internal static let cdwTxtRcNfc = StringAsset("cdw_txt_rc_nfc")
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
    /// Wo ist NFC in meinem Handy?
    internal static let cdwTxtRcNfcHeader = StringAsset("cdw_txt_rc_nfc_header")
    /// Connection failed
    internal static let cdwTxtRcNfcMessageConnectionErrorMessage = StringAsset("cdw_txt_rc_nfc_message_connectionErrorMessage")
    /// Medical card found. Please do not move.
    internal static let cdwTxtRcNfcMessageConnectMessage = StringAsset("cdw_txt_rc_nfc_message_connectMessage")
    /// Place your medical card on the dotted line at the top of the display
    internal static let cdwTxtRcNfcMessageDiscoveryMessage = StringAsset("cdw_txt_rc_nfc_message_discoveryMessage")
    /// Several medical cards found
    internal static let cdwTxtRcNfcMessageMultipleCardsMessage = StringAsset("cdw_txt_rc_nfc_message_multipleCardsMessage")
    /// No medical card found
    internal static let cdwTxtRcNfcMessageNoCardMessage = StringAsset("cdw_txt_rc_nfc_message_noCardMessage")
    /// This card type is not supported
    internal static let cdwTxtRcNfcMessageUnsupportedCardMessage = StringAsset("cdw_txt_rc_nfc_message_unsupportedCardMessage")
    /// Create here 👆
    internal static let cdwTxtRcPlacement = StringAsset("cdw_txt_rc_placement")
    /// Tipp 1 von 3
    internal static let cdwTxtRcTipOne = StringAsset("cdw_txt_rc_tip_one")
    /// Tipp 3 von 3
    internal static let cdwTxtRcTipThree = StringAsset("cdw_txt_rc_tip_three")
    /// Tipp 2 von 3
    internal static let cdwTxtRcTipTwo = StringAsset("cdw_txt_rc_tip_two")
    /// Login
    internal static let cdwTxtRcTitle = StringAsset("cdw_txt_rc_title")
    /// Select a login methid to receive prescriptions automatically.
    internal static let cdwTxtSelDescription = StringAsset("cdw_txt_sel_description")
    /// Secure login with your new electronic medical card
    internal static let cdwTxtSelEgkDescription = StringAsset("cdw_txt_sel_egk_description")
    /// Log in with medical card
    internal static let cdwTxtSelEgkTitle = StringAsset("cdw_txt_sel_egk_title")
    /// How would you like to log in?
    internal static let cdwTxtSelHeadline = StringAsset("cdw_txt_sel_headline")
    /// Use an app from your health insurance company for activation
    internal static let cdwTxtSelKkappComingSoonDescription = StringAsset("cdw_txt_sel_kkapp_coming_soon_description")
    /// Next year: log in with health insurance app
    internal static let cdwTxtSelKkappComingSoonTitle = StringAsset("cdw_txt_sel_kkapp_coming_soon_title")
    /// Use an app from your health insurance company for activation
    internal static let cdwTxtSelKkappDescription = StringAsset("cdw_txt_sel_kkapp_description")
    /// Log in with health insurance app
    internal static let cdwTxtSelKkappTitle = StringAsset("cdw_txt_sel_kkapp_title")
    /// Login
    internal static let cdwTxtSelTitle = StringAsset("cdw_txt_sel_title")
    /// Last updated %@
    internal static func cpnTxtRelativeTimerViewLastUpdate(_ element1: String) -> StringAsset {
        StringAsset("cpn_txt_relative_timer_view_last_update_%@", arguments: [element1])
    }
    /// a few seconds ago
    internal static let cpnTxtRelativeTimerViewLastUpdateRecent = StringAsset("cpn_txt_relative_timer_view_last_update_recent")
    /// Save
    internal static let cpwBtnAltAuthSave = StringAsset("cpw_btn_alt_auth_save")
    /// Save new password
    internal static let cpwBtnChange = StringAsset("cpw_btn_change")
    /// Save password
    internal static let cpwBtnSave = StringAsset("cpw_btn_save")
    /// Current password
    internal static let cpwInpCurrentPasswordPlaceholder = StringAsset("cpw_inp_current_password_placeholder")
    /// Enter password
    internal static let cpwInpPasswordAPlaceholder = StringAsset("cpw_inp_passwordA_placeholder")
    /// Repeat password
    internal static let cpwInpPasswordBPlaceholder = StringAsset("cpw_inp_passwordB_placeholder")
    /// The password is incorrect.
    internal static let cpwTxtCurrentPasswordWrong = StringAsset("cpw_txt_current_password_wrong")
    /// Recommendation: Use as few words as possible and no idioms.
    ///  Symbols, numbers or capital letters are not necessary.
    internal static let cpwTxtPasswordRecommendation = StringAsset("cpw_txt_password_recommendation")
    /// The security level of the chosen password is not sufficient
    internal static let cpwTxtPasswordStrengthInsufficient = StringAsset("cpw_txt_password_strength_insufficient")
    /// Second password input to detect any typos
    internal static let cpwTxtPasswordBAccessibility = StringAsset("cpw_txt_passwordB_accessibility")
    /// The entries differ from each other.
    internal static let cpwTxtPasswordsDontMatch = StringAsset("cpw_txt_passwords_dont_match")
    /// New password
    internal static let cpwTxtSectionTitle = StringAsset("cpw_txt_section_title")
    /// Old password
    internal static let cpwTxtSectionUpdateTitle = StringAsset("cpw_txt_section_update_title")
    /// Password
    internal static let cpwTxtTitle = StringAsset("cpw_txt_title")
    /// Change password
    internal static let cpwTxtUpdateTitle = StringAsset("cpw_txt_update_title")
    /// Edit image
    internal static let ctlBtnProfilePickerEdit = StringAsset("ctl_btn_profile_picker_edit")
    /// Reset image
    internal static let ctlBtnProfilePickerReset = StringAsset("ctl_btn_profile_picker_reset")
    /// Save
    internal static let ctlBtnProfilePickerSet = StringAsset("ctl_btn_profile_picker_set")
    /// Current profile
    internal static let ctlBtnProfileToolbarItem = StringAsset("ctl_btn_profile_toolbar_item")
    /// Cancel
    internal static let ctlBtnSearchBarCancel = StringAsset("ctl_btn_search_bar_cancel")
    /// Delete text
    internal static let ctlBtnSearchBarDeleteTextLabel = StringAsset("ctl_btn_search_bar_delete_text_label")
    /// Password strength
    internal static let ctlTxtPasswordStrength0 = StringAsset("ctl_txt_password_strength_0")
    /// Password strength
    internal static let ctlTxtPasswordStrength1 = StringAsset("ctl_txt_password_strength_1")
    /// Password strength sufficient
    internal static let ctlTxtPasswordStrength2 = StringAsset("ctl_txt_password_strength_2")
    /// Password strength good
    internal static let ctlTxtPasswordStrength3 = StringAsset("ctl_txt_password_strength_3")
    /// Password strength very good
    internal static let ctlTxtPasswordStrength4 = StringAsset("ctl_txt_password_strength_4")
    /// Password strength excellent
    internal static let ctlTxtPasswordStrength5 = StringAsset("ctl_txt_password_strength_5")
    /// OK
    internal static let ctlTxtPasswordStrengthAccessiblityValueMedium = StringAsset("ctl_txt_password_strength_accessiblity_value_medium")
    /// Strong
    internal static let ctlTxtPasswordStrengthAccessiblityValueStrong = StringAsset("ctl_txt_password_strength_accessiblity_value_strong")
    /// Very strong
    internal static let ctlTxtPasswordStrengthAccessiblityValueVeryStrong = StringAsset("ctl_txt_password_strength_accessiblity_value_very_strong")
    /// Very weak
    internal static let ctlTxtPasswordStrengthAccessiblityValueVeryWeak = StringAsset("ctl_txt_password_strength_accessiblity_value_very_weak")
    /// Weak
    internal static let ctlTxtPasswordStrengthAccessiblityValueWeak = StringAsset("ctl_txt_password_strength_accessiblity_value_weak")
    /// Not logged in
    internal static let ctlTxtProfileCellNotConnected = StringAsset("ctl_txt_profile__cell_not_connected")
    /// Blue
    internal static let ctlTxtProfileColorPickerBlue = StringAsset("ctl_txt_profile_color_picker_blue")
    /// Green
    internal static let ctlTxtProfileColorPickerGreen = StringAsset("ctl_txt_profile_color_picker_green")
    /// Grey
    internal static let ctlTxtProfileColorPickerGrey = StringAsset("ctl_txt_profile_color_picker_grey")
    /// Pink
    internal static let ctlTxtProfileColorPickerPink = StringAsset("ctl_txt_profile_color_picker_pink")
    /// Selected
    internal static let ctlTxtProfileColorPickerSelected = StringAsset("ctl_txt_profile_color_picker_selected")
    /// Yellow
    internal static let ctlTxtProfileColorPickerYellow = StringAsset("ctl_txt_profile_color_picker_yellow")
    /// Connected
    internal static let ctlTxtProfileConnectionStatusConnected = StringAsset("ctl_txt_profile_connection_status_connected")
    /// Not connected
    internal static let ctlTxtProfileConnectionStatusDisconnected = StringAsset("ctl_txt_profile_connection_status_disconnected")
    /// Search box
    internal static let ctlTxtSearchBarFieldLabel = StringAsset("ctl_txt_search_bar_field_label")
    /// Bei einer Direktzuweisungen wird ein Rezept von einer Praxis oder einem Krankenhaus direkt bei einer Apotheke eingelöst. Versicherte müssen hierbei nicht tätig werden und können nicht in den Einlösungsprozess eingreifen.
    /// 
    /// Direktzuweisungen werden in der E-Rezept App aufgeführt, um Ihre Behandlung für Sie transparenter zu machen.
    internal static let davTxtDirectAssignmentHint = StringAsset("dav_txt_direct_assignment_hint")
    /// Was ist eine Direktzuweisung?
    internal static let davTxtDirectAssignmentTitle = StringAsset("dav_txt_direct_assignment_title")
    /// Copy
    internal static let dtlBtnCopyClipboard = StringAsset("dtl_btn_copy_clipboard")
    /// The prescription is currently being processed by a pharmacy and cannot be deleted.
    internal static let dtlBtnDeleteDisabledNote = StringAsset("dtl_btn_delete_disabled_note")
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
    /// An unexpected error has occurred. Please try again.
    internal static let dtlTxtDeleteFallbackMessage = StringAsset("dtl_txt_delete_fallback_message")
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
    /// Received %@ from the prescription server
    internal static func dtlTxtMedAuthoredOn(_ element1: String) -> StringAsset {
        StringAsset("dtl_txt_med_authored_on_%@", arguments: [element1])
    }
    /// Technical information
    internal static let dtlTxtMedInfo = StringAsset("dtl_txt_med_info")
    /// Log
    internal static let dtlTxtMedProtocol = StringAsset("dtl_txt_med_protocol")
    /// Redeemed: %@
    internal static func dtlTxtMedRedeemedOn(_ element1: String) -> StringAsset {
        StringAsset("dtl_txt_med_redeemed_on_%@", arguments: [element1])
    }
    /// Scanned on
    internal static let dtlTxtScannedOn = StringAsset("dtl_txt_scanned_on")
    /// Task ID
    internal static let dtlTxtTaskId = StringAsset("dtl_txt_task_id")
    /// Details
    internal static let dtlTxtTitle = StringAsset("dtl_txt_title")
    /// iOS App: Error report
    internal static let emailSubjectFallback = StringAsset("email_subject_fallback")
    /// Cancel
    internal static let errBtnCancel = StringAsset("err_btn_cancel")
    /// Fehlernummern: 
    internal static let errCodesPrefix = StringAsset("err_codes_prefix")
    /// Ihre biometrischen Daten haben sich geändert. Wurde z.B. ein Fingerabdruck hinzugefügt? Aus Sicherheitsgründen müssen Sie sich erneut mit Ihrer Gesundheitskarte anmelden.
    internal static let errSpecificI10018Description = StringAsset("err_specific_i10018_description")
    /// Please try again.
    internal static let errSpecificI10808Description = StringAsset("err_specific_i10808_description")
    /// Unfortunately that didn't work
    internal static let errSpecificI10808Title = StringAsset("err_specific_i10808_title")
    /// Ein Fehler ist aufgetreten
    internal static let errTitleGeneric = StringAsset("err_title_generic")
    /// Anmeldung erforderlich
    internal static let errTitleLoginNecessary = StringAsset("err_title_login_necessary")
    /// Error accessing the database
    internal static let errTxtDatabaseAccess = StringAsset("err_txt_database_access")
    /// Log in
    internal static let erxBtnAlertLogin = StringAsset("erx_btn_alert_login")
    /// Redeem all
    internal static let erxBtnRedeem = StringAsset("erx_btn_redeem")
    /// Update
    internal static let erxBtnRefresh = StringAsset("erx_btn_refresh")
    /// Open prescription scanner
    internal static let erxBtnScnPrescription = StringAsset("erx_btn_scn_prescription")
    /// Prescriptions
    internal static let erxTitle = StringAsset("erx_title")
    /// Plural format key: "%#@v1_days_variable@"
    internal static func erxTxtAcceptedUntil(_ element1: Int) -> StringAsset {
        StringAsset("erx_txt_accepted_until", arguments: [element1])
    }
    /// Ausgestellt
    internal static let erxTxtAuthored = StringAsset("erx_txt_authored")
    /// Current
    internal static let erxTxtCurrent = StringAsset("erx_txt_current")
    /// Plural format key: "%#@variable_0@"
    internal static func erxTxtExpiresIn(_ element1: Int) -> StringAsset {
        StringAsset("erx_txt_expires_in", arguments: [element1])
    }
    /// No longer valid
    internal static let erxTxtInvalid = StringAsset("erx_txt_invalid")
    /// Unknown medicine
    internal static let erxTxtMedicationPlaceholder = StringAsset("erx_txt_medication_placeholder")
    /// You do not have any current prescriptions
    internal static let erxTxtNoCurrentPrescriptions = StringAsset("erx_txt_no_current_prescriptions")
    /// You haven't redeemed any prescriptions yet
    internal static let erxTxtNotYetRedeemed = StringAsset("erx_txt_not_yet_redeemed")
    /// Rezept erfolgreich hinzugefügt
    internal static let erxTxtPrescriptionAddedAlertTitle = StringAsset("erx_txt_prescription_added_alert_title")
    /// Das Rezept wurde bereits importiert.
    internal static let erxTxtPrescriptionDuplicateAlertMessage = StringAsset("erx_txt_prescription_duplicate_alert_message")
    /// Rezept nicht hinzugefügt
    internal static let erxTxtPrescriptionDuplicateAlertTitle = StringAsset("erx_txt_prescription_duplicate_alert_title")
    /// Archive
    internal static let erxTxtRedeemed = StringAsset("erx_txt_redeemed")
    /// Loading ...
    internal static let erxTxtRefreshLoading = StringAsset("erx_txt_refresh_loading")
    /// close
    internal static let hintBtnClose = StringAsset("hint_btn_close")
    /// Open scanner
    internal static let hintBtnOpenScn = StringAsset("hint_btn_open_scn")
    /// Launch demo mode
    internal static let hintBtnTryDemoMode = StringAsset("hint_btn_try_demo_mode")
    /// View new messages now
    internal static let hintBtnUnreadMessages = StringAsset("hint_btn_unread_messages")
    /// Woman scanning e-prescription
    internal static let hintPicScanner = StringAsset("hint_pic_scanner")
    /// Our demo mode shows you all the functions of the app – without a medical card.
    internal static let hintTxtDemoMode = StringAsset("hint_txt_demo_mode")
    /// Would you like a tour of the app?
    internal static let hintTxtDemoModeTitle = StringAsset("hint_txt_demo_mode_title")
    /// Scan the prescription code to add it.
    internal static let hintTxtOpenScn = StringAsset("hint_txt_open_scn")
    /// New prescription
    internal static let hintTxtOpenScnTitle = StringAsset("hint_txt_open_scn_title")
    /// Our demo mode shows you all the functions of the app – without a medical card.
    internal static let hintTxtTryDemoMode = StringAsset("hint_txt_try_demo_mode")
    /// You have received a new message from the health network.
    internal static let hintTxtUnreadMessages = StringAsset("hint_txt_unread_messages")
    /// New messages
    internal static let hintTxtUnreadMessagesTitle = StringAsset("hint_txt_unread_messages_title")
    /// Beenden Sie den Demo-Modus, um die Funktion nutzen zu können.
    internal static let idpErrNotAvailableInDemoModeRecovery = StringAsset("idp_err_not_available_in_demo_mode_recovery")
    /// Nicht verfügbar im Demo-Modus
    internal static let idpErrNotAvailableInDemoModeText = StringAsset("idp_err_not_available_in_demo_mode_text")
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
    /// Digital health applications
    internal static let kbvCodeDosageFormDig = StringAsset("kbv_code_dosage_form_dig")
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
    /// No dosage form
    internal static let kbvCodeDosageFormNone = StringAsset("kbv_code_dosage_form_none")
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
    /// Cancel
    internal static let mainTxtPendingextauthCancel = StringAsset("main_txt_pendingextauth_cancel")
    /// Authentication with %@ failed
    internal static func mainTxtPendingextauthFailed(_ element1: String) -> StringAsset {
        StringAsset("main_txt_pendingextauth_failed_%@", arguments: [element1])
    }
    /// Authentication pending in %@
    internal static func mainTxtPendingextauthPending(_ element1: String) -> StringAsset {
        StringAsset("main_txt_pendingextauth_pending_%@", arguments: [element1])
    }
    /// Processing authentication for %@
    internal static func mainTxtPendingextauthResolving(_ element1: String) -> StringAsset {
        StringAsset("main_txt_pendingextauth_resolving_%@", arguments: [element1])
    }
    /// Repeat
    internal static let mainTxtPendingextauthRetry = StringAsset("main_txt_pendingextauth_retry")
    /// Authentication with %@ successful
    internal static func mainTxtPendingextauthSuccessful(_ element1: String) -> StringAsset {
        StringAsset("main_txt_pendingextauth_successful_%@", arguments: [element1])
    }
    /// Profile name
    internal static let mgmFallbackProfileName = StringAsset("mgm_fallback_profile_name")
    /// No profile could be created during the update
    internal static let mgmTxtAlertMessageProfileCreation = StringAsset("mgm_txt_alert_message_profile_creation")
    /// The app is already up to date
    internal static let mgmTxtAlertMessageUpToDate = StringAsset("mgm_txt_alert_message_up_to_date")
    /// Back
    internal static let navBack = StringAsset("nav_back")
    /// Cancel
    internal static let navCancel = StringAsset("nav_cancel")
    /// Verbindung abgebrochen
    internal static let ohcTxtNfcErrorInvalidatedDescription = StringAsset("ohc_txt_nfc_error_invalidated_description")
    /// Die NFC-Verbindung wurde unerwartet abgebrochen, bitte versuchen Sie es erneut.
    internal static let ohcTxtNfcErrorInvalidatedRecovery = StringAsset("ohc_txt_nfc_error_invalidated_recovery")
    /// Karte nicht gefunden
    internal static let ohcTxtNfcErrorSessionTimeoutDescription = StringAsset("ohc_txt_nfc_error_session_timeout_description")
    /// Legen Sie die Karte oben auf das Display. Eine schwache Antenne in Ihrer Karte kann zu Problemen führen. Sollte dies wiederholt passieren, melden Sie uns Ihre Karte.
    internal static let ohcTxtNfcErrorSessionTimeoutRecovery = StringAsset("ohc_txt_nfc_error_session_timeout_recovery")
    /// Verbindung zur Karte unterbrochen
    internal static let ohcTxtNfcErrorTagLostDescription = StringAsset("ohc_txt_nfc_error_tag_lost_description")
    /// Bitte probieren Sie es erneut. Halten Sie die Karte möglichst ruhig bis eine Erfolgsmeldung erscheint.
    internal static let ohcTxtNfcErrorTagLostRecovery = StringAsset("ohc_txt_nfc_error_tag_lost_recovery")
    /// NFC nicht verfügbar
    internal static let ohcTxtNfcErrorUnsupportedDescription = StringAsset("ohc_txt_nfc_error_unsupported_description")
    /// Der NFC-Leser Ihres Geräts ist nicht verfügbar.
    internal static let ohcTxtNfcErrorUnsupportedRecovery = StringAsset("ohc_txt_nfc_error_unsupported_recovery")
    /// Make it difficult for unauthorised users to access your data and make the app secure on launch.
    internal static let onbAuthTxtAltDescription = StringAsset("onb_auth_txt_alt_description")
    /// OR
    internal static let onbAuthTxtDivider = StringAsset("onb_auth_txt_divider")
    /// Please select a method to secure the app:
    internal static let onbAuthTxtNoSelection = StringAsset("onb_auth_txt_no_selection")
    /// The security level of the chosen password is not sufficient
    internal static let onbAuthTxtPasswordStrengthInsufficient = StringAsset("onb_auth_txt_password_strength_insufficient")
    /// The entries differ from each other.
    internal static let onbAuthTxtPasswordsDontMatch = StringAsset("onb_auth_txt_passwords_dont_match")
    /// How would you like to secure this app?
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
    /// The name field must not be empty
    internal static let onbPrfTxtAlertMessage = StringAsset("onb_prf_txt_alert_message")
    /// Error
    internal static let onbPrfTxtAlertTitle = StringAsset("onb_prf_txt_alert_title")
    /// This helps you keep track if you want to manage the prescriptions for several people.
    internal static let onbPrfTxtFootnote = StringAsset("onb_prf_txt_footnote")
    /// First name and surname
    internal static let onbPrfTxtPlaceholder = StringAsset("onb_prf_txt_placeholder")
    /// What should we call you?
    internal static let onbPrfTxtTitle = StringAsset("onb_prf_txt_title")
    /// Profil 1
    internal static let onbProfileName = StringAsset("onb_profile_name")
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
    /// Fehler melden
    internal static let ordDetailBtnError = StringAsset("ord_detail_btn_error")
    /// Abholcode anzeigen
    internal static let ordDetailBtnOnPremise = StringAsset("ord_detail_btn_onPremise")
    /// Warenkorb-Link anzeigen
    internal static let ordDetailBtnShipment = StringAsset("ord_detail_btn_shipment")
    /// Leider war die Nachricht Ihrer Apotheke leer. Bitte kontaktieren Sie Ihre Apotheke.
    internal static let ordDetailMsgsTxtEmpty = StringAsset("ord_detail_msgs_txt_empty")
    /// Warenkorb steht bereit
    internal static let ordDetailSheetTitle = StringAsset("ord_detail_sheet_title")
    /// Abholcode erhalten
    internal static let ordDetailSheetTitleOnPremise = StringAsset("ord_detail_sheet_title_on_premise")
    /// Warenkorb steht bereit
    internal static let ordDetailSheetTitleShipment = StringAsset("ord_detail_sheet_title_shipment")
    /// Warenkorb öffnen
    internal static let ordDetailShipmentLinkBtn = StringAsset("ord_detail_shipment_link_btn")
    /// Bitte wechseln Sie nun auf die Website der Apotheke, um die Bestellung abzuschließen.
    internal static let ordDetailShipmentLinkText = StringAsset("ord_detail_shipment_link_text")
    /// %@ an %@ gesendet.
    internal static func ordDetailTxtSendTo(_ element1: String, _ element2: String) -> StringAsset {
        StringAsset("ord_detail_txt_%@_send_to_%@", arguments: [element1, element2])
    }
    /// Kontakt Optionen
    internal static let ordDetailTxtContact = StringAsset("ord_detail_txt_contact")
    /// Mail schreiben
    internal static let ordDetailTxtContactEmail = StringAsset("ord_detail_txt_contact_email")
    /// Route anzeigen
    internal static let ordDetailTxtContactMap = StringAsset("ord_detail_txt_contact_map")
    /// Anrufen
    internal static let ordDetailTxtContactPhone = StringAsset("ord_detail_txt_contact_phone")
    /// app-fehlermeldung@ti-support.de
    internal static let ordDetailTxtEmailSupport = StringAsset("ord_detail_txt_email_support")
    /// Eine Apotheke hat eine Mitteilung in einem fehlerhaften Format versendet.
    internal static let ordDetailTxtError = StringAsset("ord_detail_txt_error")
    /// Fehlerhafte Mitteilung erhalten
    internal static let ordDetailTxtErrorTitle = StringAsset("ord_detail_txt_error_title")
    /// Verlauf
    internal static let ordDetailTxtHistory = StringAsset("ord_detail_txt_history")
    /// Liebes Service-Team, ich habe eine Nachricht von einer Apotheke erhalten. Leider konnte ich meinem Nutzer die Nachricht aber nicht mitteilen, da ich sie nicht verstanden habe. Bitte prüft, was hier passiert ist, und helft uns. Vielen Dank! Die E-Rezept App
    internal static let ordDetailTxtMailBody1 = StringAsset("ord_detail_txt_mail_body1")
    /// Sie senden uns diese Informationen zum Zwecke der Fehlersuche. Bitte beachten Sie, dass auch Ihre Mailadresse sowie ggf. Ihr darin enthaltener Name übertragen wird. Wenn Sie diese Informationen ganz oder teilweise nicht übermitteln möchten, löschen Sie diese bitte aus dieser Mail. 
    /// 
    /// Alle Daten werden von der gematik GmbH oder deren beauftragten Unternehmen nur zur Bearbeitung dieser Fehlermeldung gespeichert und verarbeitet. Die Löschung erfolgt automatisiert, spätestens 180 Tage nach Bearbeitung des Tickets. Ihre Mailadresse nutzen wir ausschließlich, um mit Ihnen Kontakt in Bezug auf diese Fehlermeldung aufzunehmen. Für Fragen oder eine vorzeitige Löschung können Sie sich jederzeit an den Datenschutzverantwortlichen des E-Rezept Systems wenden. Sie finden weitere Informationen in der E-Rezept App im Menü unter dem Datenschutz-Eintrag.
    internal static let ordDetailTxtMailBody2 = StringAsset("ord_detail_txt_mail_body2")
    /// Fehler 40 42 67336
    internal static let ordDetailTxtMailError = StringAsset("ord_detail_txt_mail_error")
    /// Fehlermeldung aus der E-Rezept App
    internal static let ordDetailTxtMailSubject = StringAsset("ord_detail_txt_mail_subject")
    /// Die Mail-App konnte nicht geöffnet werden. Nutzen Sie bitte die Hotline
    internal static let ordDetailTxtOpenMailError = StringAsset("ord_detail_txt_open_mail_error")
    /// Fehler
    internal static let ordDetailTxtOpenMailErrorTitle = StringAsset("ord_detail_txt_open_mail_error_title")
    /// Bestellung
    internal static let ordDetailTxtOrders = StringAsset("ord_detail_txt_orders")
    /// Plural format key: "%#@variable_0@"
    internal static func ordDetailTxtPresc(_ element1: Int) -> StringAsset {
        StringAsset("ord_detail_txt_presc", arguments: [element1])
    }
    /// Bestellübersicht
    internal static let ordDetailTxtTitle = StringAsset("ord_detail_txt_title")
    /// Plural format key: "%#@variable_0@"
    internal static func ordListStatusCount(_ element1: Int) -> StringAsset {
        StringAsset("ord_list_status_count", arguments: [element1])
    }
    /// Neu
    internal static let ordListStatusNew = StringAsset("ord_list_status_new")
    /// Sie haben noch keine Mitteilungen erhalten
    internal static let ordTxtEmptyListMessage = StringAsset("ord_txt_empty_list_message")
    /// Keine Bestellungen
    internal static let ordTxtEmptyListTitle = StringAsset("ord_txt_empty_list_title")
    /// Unbekannte Apotheke
    internal static let ordTxtNoPharmacyName = StringAsset("ord_txt_no_pharmacy_name")
    /// Bestellungen
    internal static let ordTxtTitle = StringAsset("ord_txt_title")
    /// How to identify an NFC-enabled medical card
    internal static let orderEgkBtnInfoButton = StringAsset("order_egk_btn_info_button")
    /// Email
    internal static let orderEgkTxtContactOptionMail = StringAsset("order_egk_txt_contact_option_mail")
    /// Phone
    internal static let orderEgkTxtContactOptionTelephone = StringAsset("order_egk_txt_contact_option_telephone")
    /// Website
    internal static let orderEgkTxtContactOptionWeb = StringAsset("order_egk_txt_contact_option_web")
    /// You can use an NFC-enabled medical card and the associated PIN to log into this app.
    internal static let orderEgkTxtDescription1 = StringAsset("order_egk_txt_description_1")
    /// You can obtain one free of charge from your health insurance company. You need to provide an official form of indentification as proof of identity.
    internal static let orderEgkTxtDescription2 = StringAsset("order_egk_txt_description_2")
    /// Contact health insurance company
    internal static let orderEgkTxtHeadline = StringAsset("order_egk_txt_headline")
    /// Please contact your health insurance company via the usual channels.
    internal static let orderEgkTxtHintNoContactOptionMessage = StringAsset("order_egk_txt_hint_no_contact_option_message")
    /// Contact is not possible via this app
    internal static let orderEgkTxtHintNoContactOptionTitle = StringAsset("order_egk_txt_hint_no_contact_option_title")
    /// https://www.das-e-rezept-fuer-deutschland.de/fragen-antworten/woran-erkenne-ich-ob-ich-eine-nfc-faehige-gesundheitskarte-habe#c204
    internal static let orderEgkTxtInfoLink = StringAsset("order_egk_txt_info_link")
    /// Select health insurance company
    internal static let orderEgkTxtPickerInsuranceHeader = StringAsset("order_egk_txt_picker_insurance_header")
    /// Make a selection
    internal static let orderEgkTxtPickerInsurancePlaceholder = StringAsset("order_egk_txt_picker_insurance_placeholder")
    /// What would you like to apply for?
    internal static let orderEgkTxtPickerServiceHeader = StringAsset("order_egk_txt_picker_service_header")
    /// If you already have a medical card with NFC function, all you have to do is ask for a PIN to be sent to you.
    internal static let orderEgkTxtPickerServiceInfoFootnote = StringAsset("order_egk_txt_picker_service_info_footnote")
    /// Make a selection
    internal static let orderEgkTxtPickerServiceLabel = StringAsset("order_egk_txt_picker_service_label")
    /// Select
    internal static let orderEgkTxtPickerServiceNavigationTitle = StringAsset("order_egk_txt_picker_service_navigation_title")
    /// Nach Krankenkasse suchen
    internal static let orderEgkTxtSearchPrompt = StringAsset("order_egk_txt_search_prompt")
    /// Contact your health insurance company
    internal static let orderEgkTxtSectionContactInsurance = StringAsset("order_egk_txt_section_contact_insurance")
    /// Medical card & PIN
    internal static let orderEgkTxtServiceInquiryHealthcardAndPin = StringAsset("order_egk_txt_service_inquiry_healthcard_and_pin")
    /// PIN only
    internal static let orderEgkTxtServiceInquiryOnlyPin = StringAsset("order_egk_txt_service_inquiry_only_pin")
    /// Different delivery address
    internal static let phaContactBtnNewAddress = StringAsset("pha_contact_btn_new_address")
    /// Address on your prescription
    internal static let phaContactBtnPrsciptionAddress = StringAsset("pha_contact_btn_prsciption_address")
    /// Save
    internal static let phaContactBtnSave = StringAsset("pha_contact_btn_save")
    /// Please enter
    internal static let phaContactPlaceholder = StringAsset("pha_contact_placeholder")
    /// e.g. rear building
    internal static let phaContactPlaceholderDeliveryInfo = StringAsset("pha_contact_placeholder_deliveryInfo")
    /// Delivery address
    internal static let phaContactTitleAddress = StringAsset("pha_contact_title_address")
    /// Contact
    internal static let phaContactTitleContact = StringAsset("pha_contact_title_contact")
    /// Place
    internal static let phaContactTxtCity = StringAsset("pha_contact_txt_city")
    /// Delivery instructions (optional)
    internal static let phaContactTxtDeliveryInfo = StringAsset("pha_contact_txt_delivery_info")
    /// Email address
    internal static let phaContactTxtMail = StringAsset("pha_contact_txt_mail")
    /// Name
    internal static let phaContactTxtName = StringAsset("pha_contact_txt_name")
    /// Area code and telephone number
    internal static let phaContactTxtPhone = StringAsset("pha_contact_txt_phone")
    /// Street and house number
    internal static let phaContactTxtStreet = StringAsset("pha_contact_txt_street")
    /// Postcode
    internal static let phaContactTxtZip = StringAsset("pha_contact_txt_zip")
    /// Find out more
    internal static let phaDetailBtnFooter = StringAsset("pha_detail_btn_footer")
    /// Request delivery service
    internal static let phaDetailBtnHealthcareService = StringAsset("pha_detail_btn_healthcare_service")
    /// Reserve for collection
    internal static let phaDetailBtnLocation = StringAsset("pha_detail_btn_location")
    /// Einlösen nur nach Anmeldung möglich
    internal static let phaDetailBtnLoginNote = StringAsset("pha_detail_btn_login_note")
    /// Delivery by mail order
    internal static let phaDetailBtnOrganization = StringAsset("pha_detail_btn_organization")
    /// Contact
    internal static let phaDetailContact = StringAsset("pha_detail_contact")
    /// Please note that prescribed medication may also be subject to additional payments.
    internal static let phaDetailHintMessage = StringAsset("pha_detail_hint_message")
    /// This pharmacy is not currently able to receive any e-prescriptions.
    internal static let phaDetailHintNotErxReadyMessage = StringAsset("pha_detail_hint_not_erx_ready_message")
    /// Pharmacist stocks medicine
    internal static let phaDetailHintNotErxReadyPic = StringAsset("pha_detail_hint_not_erx_ready_pic")
    /// Can be redeemed soon
    internal static let phaDetailHintNotErxReadyTitle = StringAsset("pha_detail_hint_not_erx_ready_title")
    /// Email address
    internal static let phaDetailMail = StringAsset("pha_detail_mail")
    /// Opening hours
    internal static let phaDetailOpeningTime = StringAsset("pha_detail_opening_time")
    /// o'clock
    internal static let phaDetailOpeningTimeVoice = StringAsset("pha_detail_opening_time_voice")
    /// Today
    internal static let phaDetailOpeningToday = StringAsset("pha_detail_opening_today")
    /// until
    internal static let phaDetailOpeningUntil = StringAsset("pha_detail_opening_until")
    /// Telephone number
    internal static let phaDetailPhone = StringAsset("pha_detail_phone")
    /// . Have you found an error or would you like to correct any data?
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
    /// Versuchen Sie es erneut und wählen evtl. eine andere Apotheke aus. Sollte der Fehler weiterhin bestehen, informieren Sie bitte den Support.
    internal static let phaRedeemAlertMessageFailure = StringAsset("pha_redeem_alert_message_failure")
    /// We require your telephone number for any queries.
    internal static let phaRedeemAlertMessageMissingPhone = StringAsset("pha_redeem_alert_message_missing_phone")
    /// Plural format key: "%#@variable_0@"
    internal static func phaRedeemAlertTitleFailure(_ element1: Int) -> StringAsset {
        StringAsset("pha_redeem_alert_title_failure", arguments: [element1])
    }
    /// Contact details missing
    internal static let phaRedeemAlertTitleMissingPhone = StringAsset("pha_redeem_alert_title_missing_phone")
    /// Enter contact details
    internal static let phaRedeemBtnAddAddress = StringAsset("pha_redeem_btn_add_address")
    /// Cancel
    internal static let phaRedeemBtnAlertCancel = StringAsset("pha_redeem_btn_alert_cancel")
    /// Add
    internal static let phaRedeemBtnAlertComplete = StringAsset("pha_redeem_btn_alert_complete")
    /// Redeem
    internal static let phaRedeemBtnRedeem = StringAsset("pha_redeem_btn_redeem")
    /// Your prescription will be sent to this pharmacy. It is not possible to redeem your prescription at another pharmacy.
    internal static let phaRedeemBtnRedeemFootnote = StringAsset("pha_redeem_btn_redeem_footnote")
    /// ⚕︎ Redeem
    internal static let phaRedeemTitle = StringAsset("pha_redeem_title")
    /// Delivery address
    internal static let phaRedeemTxtAddress = StringAsset("pha_redeem_txt_address")
    /// Interner Fehler (%@)
    internal static func phaRedeemTxtInternalErr(_ element1: String) -> StringAsset {
        StringAsset("pha_redeem_txt_internal_err_%@", arguments: [element1])
    }
    /// Bitte informieren Sie den Support, sollte der Fehler dauerhaft auftreten.
    internal static let phaRedeemTxtInternalErrRecovery = StringAsset("pha_redeem_txt_internal_err_recovery")
    /// We require your contact details in order for the pharmacy to be able to advise you and let you know the current status of your order.
    internal static let phaRedeemTxtMissingAddress = StringAsset("pha_redeem_txt_missing_address")
    /// Your telephone number is required
    internal static let phaRedeemTxtMissingPhone = StringAsset("pha_redeem_txt_missing_phone")
    /// You are no longer logged in. Please log back in to redeem prescriptions.
    internal static let phaRedeemTxtNotLoggedIn = StringAsset("pha_redeem_txt_not_logged_in")
    /// Nicht am Gesundheitssystem angemeldet
    internal static let phaRedeemTxtNotLoggedInTitle = StringAsset("pha_redeem_txt_not_logged_in_title")
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
    /// Try again
    internal static let phaSearchBtnErrorNoServerResponse = StringAsset("pha_search_btn_error_no_server_response")
    /// Filter
    internal static let phaSearchBtnFilterTitle = StringAsset("pha_search_btn_filter_title")
    /// Share location
    internal static let phaSearchBtnLocationHintAction = StringAsset("pha_search_btn_location_hint_action")
    /// Filter
    internal static let phaSearchBtnShowFilterView = StringAsset("pha_search_btn_show_filter_view")
    /// Filter
    internal static let phaSearchFilterTxtTitle = StringAsset("pha_search_filter_txt_title")
    /// Close location sharing, don't share location
    internal static let phaSearchHintTxtClose = StringAsset("pha_search_hint_txt_close")
    /// Closed
    internal static let phaSearchTxtClosed = StringAsset("pha_search_txt_closed")
    /// Closing soon
    internal static let phaSearchTxtClosingSoon = StringAsset("pha_search_txt_closing_soon")
    /// Server not responding
    internal static let phaSearchTxtErrorNoServerResponseHeadline = StringAsset("pha_search_txt_error_no_server_response_headline")
    /// Please try again in a few minutes.
    internal static let phaSearchTxtErrorNoServerResponseSubheadline = StringAsset("pha_search_txt_error_no_server_response_subheadline")
    /// Delivery service
    internal static let phaSearchTxtFilterDelivery = StringAsset("pha_search_txt_filter_delivery")
    /// Open now
    internal static let phaSearchTxtFilterOpen = StringAsset("pha_search_txt_filter_open")
    /// Ready for the e-prescription
    internal static let phaSearchTxtFilterReady = StringAsset("pha_search_txt_filter_ready")
    /// Mail order
    internal static let phaSearchTxtFilterShipment = StringAsset("pha_search_txt_filter_shipment")
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
    /// Search for name or address
    internal static let phaSearchTxtSearchHint = StringAsset("pha_search_txt_search_hint")
    /// Select pharmacy
    internal static let phaSearchTxtTitle = StringAsset("pha_search_txt_title")
    /// Done! 🎉
    internal static let phaSuccessRedeemTitle = StringAsset("pha_success_redeem_title")
    /// Done
    internal static let proBtnSelectionClose = StringAsset("pro_btn_selection_close")
    /// Edit profiles
    internal static let proBtnSelectionEdit = StringAsset("pro_btn_selection_edit")
    /// Not logged in
    internal static let proTxtSelectionProfileNotConnected = StringAsset("pro_txt_selection_profile_not_connected")
    /// Select profile
    internal static let proTxtSelectionTitle = StringAsset("pro_txt_selection_title")
    /// Dieses Rezept wird im Rahmen einer Behandlung für Sie eingelöst und kann währenddessen nicht gelöscht werden.
    internal static let prscDeleteNoteDirectAssignment = StringAsset("prsc_delete_note_direct_assignment")
    /// Direktzuweisung
    internal static let prscDtlBtnDirectAssignment = StringAsset("prsc_dtl_btn_direct_assignment")
    /// Teilen
    internal static let prscDtlBtnShareTitle = StringAsset("prsc_dtl_btn_share_title")
    /// Open gesund.bund.de
    internal static let prscDtlHntGesundBundDeBtn = StringAsset("prsc_dtl_hnt_gesund_bund_de_btn")
    /// You can find professionally verified information on illnesses, ICD codes and issues to do with prevention and healthcare in the National Health Portal.
    internal static let prscDtlHntGesundBundDeText = StringAsset("prsc_dtl_hnt_gesund_bund_de_text")
    /// Report
    internal static let prscFdBtnErrorBanner = StringAsset("prsc_fd_btn_error_banner")
    /// Doctor
    internal static let prscFdHintDosageInstructionsPic = StringAsset("prsc_fd_hint_dosageInstructions_pic")
    /// Pharmacist
    internal static let prscFdHintNoctuPic = StringAsset("prsc_fd_hint_noctu_pic")
    /// Doctor
    internal static let prscFdHintSubstitutionPic = StringAsset("prsc_fd_hint_substitution_pic")
    /// Date of accident
    internal static let prscFdTxtAccidentDate = StringAsset("prsc_fd_txt_accident_date")
    /// Accident company or employer number
    internal static let prscFdTxtAccidentId = StringAsset("prsc_fd_txt_accident_id")
    /// Accident at work
    internal static let prscFdTxtAccidentTitle = StringAsset("prsc_fd_txt_accident_title")
    /// Plural format key: "%#@variable_0@"
    internal static func prscFdTxtDetailsActualMedicationTitle(_ element1: Int) -> StringAsset {
        StringAsset("prsc_fd_txt_details_actual_medication_title", arguments: [element1])
    }
    /// Dosage form
    internal static let prscFdTxtDetailsDosageForm = StringAsset("prsc_fd_txt_details_dosage_form")
    /// Package size
    internal static let prscFdTxtDetailsDose = StringAsset("prsc_fd_txt_details_dose")
    /// Verwendbar bis
    internal static let prscFdTxtDetailsExpiresOn = StringAsset("prsc_fd_txt_details_expires_on")
    /// Chargenbezeichnung
    internal static let prscFdTxtDetailsLot = StringAsset("prsc_fd_txt_details_lot")
    /// Verordnetes Medikament
    internal static let prscFdTxtDetailsPrescripedMedicationTitle = StringAsset("prsc_fd_txt_details_prescriped_medication_title")
    /// Pharma central number (PZN)
    internal static let prscFdTxtDetailsPzn = StringAsset("prsc_fd_txt_details_pzn")
    /// Details about this medicine
    internal static let prscFdTxtDetailsTitle = StringAsset("prsc_fd_txt_details_title")
    /// Please follow the directions for use in your medication schedule or the written dosage instructions from your doctor.
    internal static let prscFdTxtDosageInstructionsNa = StringAsset("prsc_fd_txt_dosage_instructions_na")
    /// Directions for use
    internal static let prscFdTxtDosageInstructionsTitle = StringAsset("prsc_fd_txt_dosage_instructions_title")
    /// Something seems to have gone wrong when creating your prescription. Report an error?
    internal static let prscFdTxtErrorBannerMessage = StringAsset("prsc_fd_txt_error_banner_message")
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
    /// Policyholder number
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
    /// Dieses Rezept wird im Rahmen einer Behandlung für Sie eingelöst.
    internal static let prscRedeemNoteDirectAssignment = StringAsset("prsc_redeem_note_direct_assignment")
    /// Cancelled
    internal static let prscStatusCanceled = StringAsset("prsc_status_canceled")
    /// Redeemed
    internal static let prscStatusCompleted = StringAsset("prsc_status_completed")
    /// Wird für Sie eingelöst
    internal static let prscStatusDirectAssigned = StringAsset("prsc_status_direct_assigned")
    /// Defective prescription
    internal static let prscStatusError = StringAsset("prsc_status_error")
    /// Expired
    internal static let prscStatusExpired = StringAsset("prsc_status_expired")
    /// Being redeemed
    internal static let prscStatusInProgress = StringAsset("prsc_status_in_progress")
    /// Redeemable
    internal static let prscStatusReady = StringAsset("prsc_status_ready")
    /// Unknown
    internal static let prscStatusUndefined = StringAsset("prsc_status_undefined")
    /// Medicine
    internal static let prscTxtFallbackName = StringAsset("prsc_txt_fallback_name")
    /// Done
    internal static let psfBtnAccept = StringAsset("psf_btn_accept")
    /// Common filters
    internal static let psfTxtCommonSubheadline = StringAsset("psf_txt_common_subheadline")
    /// Filters
    internal static let psfTxtCommonTitle = StringAsset("psf_txt_common_title")
    /// Filters
    internal static let psfTxtTitle = StringAsset("psf_txt_title")
    /// Zeigen Sie diesen Abholcode in der %@ vor.
    internal static func pucTxtSubtitle(_ element1: String) -> StringAsset {
        StringAsset("puc_txt_subtitle_%@", arguments: [element1])
    }
    /// Abholcode erhalten
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
    /// Die eingegebene Stadt überschrietet die erlaubte Maximallänge von %@ Zeichen.
    internal static func rivAvsInvalidCity(_ element1: String) -> StringAsset {
        StringAsset("riv_avs_invalid_city_%@", arguments: [element1])
    }
    /// Der eingegebene Hinweis überschreitet die erlaubte Maximallänge von %@ Zeichen.
    internal static func rivAvsInvalidHint(_ element1: String) -> StringAsset {
        StringAsset("riv_avs_invalid_hint_%@", arguments: [element1])
    }
    /// Die eingegebene E-Mail-Adresse ist ungültig. Bitte korrigieren Sie Ihre Angabe.
    internal static let rivAvsInvalidMail = StringAsset("riv_avs_invalid_mail_%@")
    /// Für die gewählte Versandoption muss eine gültige Telefonnummer oder E-Mail Adresse angegeben werden.
    internal static let rivAvsInvalidMissingContact = StringAsset("riv_avs_invalid_missing_contact_%@")
    /// Der gewählte Name überscheitet die Maximallänge von %@ Zeichen.
    internal static func rivAvsInvalidName(_ element1: String) -> StringAsset {
        StringAsset("riv_avs_invalid_name_%@", arguments: [element1])
    }
    /// Die gewählte Telefonummer ist ungültig. Bitte korrigieren Sie Ihre Angabe.
    internal static let rivAvsInvalidPhone = StringAsset("riv_avs_invalid_phone_%@")
    /// Die eingegebene Straße überschrietet die erlaubte Maximallänge von %@ Zeichen.
    internal static func rivAvsInvalidStreet(_ element1: String) -> StringAsset {
        StringAsset("riv_avs_invalid_street_%@", arguments: [element1])
    }
    /// Der eingegebene Text überschreitet die erlaubte Maximallänge von %@ Zeichen.
    internal static func rivAvsInvalidText(_ element1: String) -> StringAsset {
        StringAsset("riv_avs_invalid_text_%@", arguments: [element1])
    }
    /// Die eingegebene Postleitzahl überschrietet die erlaubte Maximallänge von %@ Zeichen.
    internal static func rivAvsInvalidZip(_ element1: String) -> StringAsset {
        StringAsset("riv_avs_invalid_zip_%@", arguments: [element1])
    }
    /// Ungültige Versionsnummer.
    internal static let rivAvsWrongVersion = StringAsset("riv_avs_wrong_version")
    /// Die eingegebene Stadt überschrietet die erlaubte Maximallänge von %@ Zeichen.
    internal static func rivTiInvalidCity(_ element1: String) -> StringAsset {
        StringAsset("riv_ti_invalid_city_%@", arguments: [element1])
    }
    /// Der eingegebene Hinweis überschreitet die erlaubte Maximallänge von %@ Zeichen.
    internal static func rivTiInvalidHint(_ element1: String) -> StringAsset {
        StringAsset("riv_ti_invalid_hint_%@", arguments: [element1])
    }
    /// Die eingegebene E-Mail-Adresse ist ungültig. Bitte korrigieren Sie Ihre Angabe.
    internal static let rivTiInvalidMail = StringAsset("riv_ti_invalid_mail_%@")
    /// Für die gewählte Versandoption muss eine gültige Telefonnummer angegeben werden.
    internal static let rivTiInvalidMissingContact = StringAsset("riv_ti_invalid_missing_contact_%@")
    /// Der gewählte Name überscheitet die Maximallänge von %@ Zeichen.
    internal static func rivTiInvalidName(_ element1: String) -> StringAsset {
        StringAsset("riv_ti_invalid_name_%@", arguments: [element1])
    }
    /// Die gewählte Telefonummer ist ungültig. Bitte korrigieren Sie Ihre Angabe.
    internal static let rivTiInvalidPhone = StringAsset("riv_ti_invalid_phone_%@")
    /// Die eingegebene Straße überschrietet die erlaubte Maximallänge von %@ Zeichen.
    internal static func rivTiInvalidStreet(_ element1: String) -> StringAsset {
        StringAsset("riv_ti_invalid_street_%@", arguments: [element1])
    }
    /// Die eingegebene Postleitzahl überschrietet die erlaubte Maximallänge von %@ Zeichen.
    internal static func rivTiInvalidZip(_ element1: String) -> StringAsset {
        StringAsset("riv_ti_invalid_zip_%@", arguments: [element1])
    }
    /// Ungültige Versionsnummer.
    internal static let rivTiWrongVersion = StringAsset("riv_ti_wrong_version")
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
    /// Licht aus
    internal static let scnBtnLightOff = StringAsset("scn_btn_light_off")
    /// Licht an
    internal static let scnBtnLightOn = StringAsset("scn_btn_light_on")
    /// Plural format key: "%#@variable_0@"
    internal static func scnBtnScanningDone(_ element1: Int) -> StringAsset {
        StringAsset("scn_btn_scanning_done", arguments: [element1])
    }
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
    /// OK
    internal static let secBtnSystemRootDetectionDone = StringAsset("sec_btn_system_root_detection_done")
    /// Find out more
    internal static let secBtnSystemRootDetectionMore = StringAsset("sec_btn_system_root_detection_more")
    /// Note
    internal static let secTxtSystemPinHeadline = StringAsset("sec_txt_system_pin_headline")
    /// We recommend that you add additional protection for your medical data by securing your device for instance with a code or biometrics.
    internal static let secTxtSystemPinMessage = StringAsset("sec_txt_system_pin_message")
    /// Do not show this message in future.
    internal static let secTxtSystemPinSelection = StringAsset("sec_txt_system_pin_selection")
    /// No access lock has been set up for this device
    internal static let secTxtSystemPinTitle = StringAsset("sec_txt_system_pin_title")
    /// Why are devices with root access a potential security risk?
    internal static let secTxtSystemRootDetectionFootnote = StringAsset("sec_txt_system_root_detection_footnote")
    /// Warning
    internal static let secTxtSystemRootDetectionHeadline = StringAsset("sec_txt_system_root_detection_headline")
    /// For security reasons, this app should not be used on jailbroken devices.
    internal static let secTxtSystemRootDetectionMessage = StringAsset("sec_txt_system_root_detection_message")
    /// I acknowledge the increased risk and would like to continue anyway.
    internal static let secTxtSystemRootDetectionSelection = StringAsset("sec_txt_system_root_detection_selection")
    /// This device may have been jailbroken
    internal static let secTxtSystemRootDetectionTitle = StringAsset("sec_txt_system_root_detection_title")
    /// Selected
    internal static let sectionTxtIsActiveValue = StringAsset("section_txt_is_active_value")
    /// Not selected
    internal static let sectionTxtIsInactiveValue = StringAsset("section_txt_is_inactive_value")
    /// Your medical card is already linked to another profile. Switch to profile %@.
    internal static func sessionErrorCardConnectedWithOtherProfile(_ element1: String) -> StringAsset {
        StringAsset("session_error_card_connected_with_other_profile_%@", arguments: [element1])
    }
    /// The current profile is already linked to another medical card (policyholder number: %@).
    internal static func sessionErrorCardProfileMismatch(_ element1: String) -> StringAsset {
        StringAsset("session_error_card_profile_mismatch_%@", arguments: [element1])
    }
    /// No selected profile could be found. Please select a profile.
    internal static let sessionErrorNoProfile = StringAsset("session_error_no_profile")
    /// Add profile
    internal static let stgBtnAddProfile = StringAsset("stg_btn_add_profile")
    /// Weiter
    internal static let stgBtnCardResetAdvance = StringAsset("stg_btn_card_reset_advance")
    /// OK
    internal static let stgBtnCardResetPinAlertOk = StringAsset("stg_btn_card_reset_pin_alert_ok")
    /// OK
    internal static let stgBtnCardResetRcAlertOk = StringAsset("stg_btn_card_reset_rc_alert_ok")
    /// Karte verbinden
    internal static let stgBtnCardResetRead = StringAsset("stg_btn_card_reset_read")
    /// Delete profile
    internal static let stgBtnEditProfileDelete = StringAsset("stg_btn_edit_profile_delete")
    /// Cancel
    internal static let stgBtnEditProfileDeleteAlertCancel = StringAsset("stg_btn_edit_profile_delete_alert_cancel")
    /// Log in
    internal static let stgBtnEditProfileLogin = StringAsset("stg_btn_edit_profile_login")
    /// Log out
    internal static let stgBtnEditProfileLogout = StringAsset("stg_btn_edit_profile_logout")
    /// Connected devices
    internal static let stgBtnEditProfileRegisteredDevices = StringAsset("stg_btn_edit_profile_registered_devices")
    /// Save
    internal static let stgBtnNewProfileCreate = StringAsset("stg_btn_new_profile_create")
    /// Authenticate
    internal static let stgBtnRegDevicesLoad = StringAsset("stg_btn_reg_devices_load")
    /// app-feedback@gematik.de
    internal static let stgConFbkMail = StringAsset("stg_con_fbk_mail")
    /// Feedback from the e-prescription app
    internal static let stgConFbkSubjectMail = StringAsset("stg_con_fbk_subject_mail")
    /// Toll-free for the caller. Service times: Monday - Friday 8:00 a.m. - 8:00 p.m. except on German national holidays
    internal static let stgConHotlineAva = StringAsset("stg_con_hotline_ava")
    /// +49 0800 277 3777
    internal static let stgConHotlineContact = StringAsset("stg_con_hotline_contact")
    /// Call technical hotline
    internal static let stgConTextContactHotline = StringAsset("stg_con_text_contact_hotline")
    /// Write email
    internal static let stgConTextMail = StringAsset("stg_con_text_mail")
    /// An Umfrage teilnehmen
    internal static let stgConTextSurvey = StringAsset("stg_con_text_survey")
    /// Privacy Policy
    internal static let stgDpoTxtDataPrivacy = StringAsset("stg_dpo_txt_data_privacy")
    /// Open source licences
    internal static let stgDpoTxtFoss = StringAsset("stg_dpo_txt_foss")
    /// Terms of Use
    internal static let stgDpoTxtTermsOfUse = StringAsset("stg_dpo_txt_terms_of_use")
    /// PIN eingeben
    internal static let stgEdtCardResetOldpinInput = StringAsset("stg_edt_card_reset_oldpin_input")
    /// Neue PIN eingeben
    internal static let stgEdtCardResetPinInputPin1 = StringAsset("stg_edt_card_reset_pin_input_pin1")
    /// PIN wiederholen
    internal static let stgEdtCardResetPinInputPin2 = StringAsset("stg_edt_card_reset_pin_input_pin2")
    /// PUK eingeben
    internal static let stgEdtCardResetPukInput = StringAsset("stg_edt_card_reset_puk_input")
    /// Mit Ihrer PIN haben Sie eine 8-stellige PUK von Ihrer Versicherung erhalten.
    internal static let stgEdtCardResetPukInputLabel = StringAsset("stg_edt_card_reset_puk_input_label")
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
    /// gematik GmbH
    /// Friedrichstr. 136
    /// 10117 Berlin, Germany
    internal static let stgLnoTxtTextIssuer = StringAsset("stg_lno_txt_text_issuer")
    /// We strive to use gender-sensitive language. If you notice any errors, we would be pleased to hear from you by email.
    internal static let stgLnoTxtTextNote = StringAsset("stg_lno_txt_text_note")
    /// Dr. med. Markus Leyck Dieken
    internal static let stgLnoTxtTextResponsible = StringAsset("stg_lno_txt_text_responsible")
    /// Managing Director: Dr. med. Markus Leyck Dieken
    /// Register Court: Amtsgericht Berlin-Charlottenburg
    /// Commercial register no.: HRB 96351
    /// VAT ID: DE241843684
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
    /// Access token
    internal static let stgTknTxtAccessToken = StringAsset("stg_tkn_txt_access_token")
    /// Token copied to clipboard
    internal static let stgTknTxtCopyToClipboard = StringAsset("stg_tkn_txt_copy_to_clipboard")
    /// SSO token
    internal static let stgTknTxtSsoToken = StringAsset("stg_tkn_txt_sso_token")
    /// Tokens
    internal static let stgTknTxtTitleTokens = StringAsset("stg_tkn_txt_title_tokens")
    /// Decline
    internal static let stgTrkBtnAlertNo = StringAsset("stg_trk_btn_alert_no")
    /// Agree
    internal static let stgTrkBtnAlertYes = StringAsset("stg_trk_btn_alert_yes")
    /// Allow anonymous analysis
    internal static let stgTrkBtnTitle = StringAsset("stg_trk_btn_title")
    /// In order to understand which functions are used frequently, we need your consent to analyse your usage behaviour. This analysis includes information about your phone's hardware and software (device type, operating system version etc.), settings of the e-prescription app as well as the extent of use, but never any personal or health data concerning you. 
    /// 
    /// This data is made available exclusively to gematik GmbH by data processors and is deleted after 180 days at the latest. You can disable the analysis of your usage behaviour at any time in the settings menu of the app.
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
    /// Last updated: %@
    internal static func stgTxtAuditEventsLastUpdated(_ element1: String) -> StringAsset {
        StringAsset("stg_txt_audit_events_last_updated_%@", arguments: [element1])
    }
    /// No timestamp
    internal static let stgTxtAuditEventsMissingDate = StringAsset("stg_txt_audit_events_missing_date")
    /// Not specified
    internal static let stgTxtAuditEventsMissingDescription = StringAsset("stg_txt_audit_events_missing_description")
    /// Untitled
    internal static let stgTxtAuditEventsMissingTitle = StringAsset("stg_txt_audit_events_missing_title")
    /// Next
    internal static let stgTxtAuditEventsNext = StringAsset("stg_txt_audit_events_next")
    /// You will receive access logs when you are logged in to the prescription service.
    internal static let stgTxtAuditEventsNoProtocolDescription = StringAsset("stg_txt_audit_events_no_protocol_description")
    /// No access logs
    internal static let stgTxtAuditEventsNoProtocolTitle = StringAsset("stg_txt_audit_events_no_protocol_title")
    /// Page %@ of %@
    internal static func stgTxtAuditEventsPageSelectionOf(_ element1: String, _ element2: String) -> StringAsset {
        StringAsset("stg_txt_audit_events_page_selection_%@_of_%@", arguments: [element1, element2])
    }
    /// Previous
    internal static let stgTxtAuditEventsPrevious = StringAsset("stg_txt_audit_events_previous")
    /// Access logs
    internal static let stgTxtAuditEventsTitle = StringAsset("stg_txt_audit_events_title")
    /// Wunsch-PIN wählen
    internal static let stgTxtCardCustomPin = StringAsset("stg_txt_card_custom_pin")
    /// Neue Karte bestellen
    internal static let stgTxtCardOrderNewCard = StringAsset("stg_txt_card_order_new_card")
    /// Wunsch-PIN wählen
    internal static let stgTxtCardResetIntroCustomPin = StringAsset("stg_txt_card_reset_intro_custom_pin")
    /// Mit Ihrer PIN haben Sie eine 8-stellige PUK von Ihrer Versicherung erhalten.
    internal static let stgTxtCardResetIntroHint = StringAsset("stg_txt_card_reset_intro_hint")
    /// Mit Ihrer Karte haben Sie eine 6-stellige PIN von Ihrer Versicherung erhalten.
    internal static let stgTxtCardResetIntroHintCustomPin = StringAsset("stg_txt_card_reset_intro_hint_custom_pin")
    /// Ihre Gesundheitskarte
    internal static let stgTxtCardResetIntroNeedYourCard = StringAsset("stg_txt_card_reset_intro_need_your_card")
    /// PIN Ihrer Gesundheitskarte
    internal static let stgTxtCardResetIntroNeedYourCardsPin = StringAsset("stg_txt_card_reset_intro_need_your_cards_pin")
    /// PUK Ihrer Gesundheitskarte
    internal static let stgTxtCardResetIntroNeedYourCardsPuk = StringAsset("stg_txt_card_reset_intro_need_your_cards_puk")
    /// Was Sie benötigen:
    internal static let stgTxtCardResetIntroSubheadline = StringAsset("stg_txt_card_reset_intro_subheadline")
    /// Karte entsperren
    internal static let stgTxtCardResetIntroUnlockCard = StringAsset("stg_txt_card_reset_intro_unlock_card")
    /// Aktuelle PIN eingeben
    internal static let stgTxtCardResetOldpinHeadline = StringAsset("stg_txt_card_reset_oldpin_headline")
    /// Bitte geben Sie aus Sicherheitsgründen Ihre aktuelle PIN ein.
    internal static let stgTxtCardResetOldpinHint = StringAsset("stg_txt_card_reset_oldpin_hint")
    /// Eine PIN darf nur 6-8 Zeichen lang sein.
    internal static let stgTxtCardResetPinAlertPinTooLongMessage = StringAsset("stg_txt_card_reset_pin_alert_pin_too_long_message")
    /// Maximale Länge erreicht
    internal static let stgTxtCardResetPinAlertPinTooLongTitle = StringAsset("stg_txt_card_reset_pin_alert_pin_too_long_title")
    /// Wunsch-PIN wählen
    internal static let stgTxtCardResetPinHeadline = StringAsset("stg_txt_card_reset_pin_headline")
    /// Ihre neue persönliche Identifikationsnummer (PIN) können Sie selbst wählen (6 bis 8 Stellen).
    internal static let stgTxtCardResetPinHint = StringAsset("stg_txt_card_reset_pin_hint")
    /// Bitte notieren Sie sich Ihre PIN und bewahren Sie diese an einem sicheren Ort auf.
    internal static let stgTxtCardResetPinHintMessage = StringAsset("stg_txt_card_reset_pin_hint_message")
    /// PIN gemerkt?
    internal static let stgTxtCardResetPinHintTitle = StringAsset("stg_txt_card_reset_pin_hint_title")
    /// Die Eingaben weichen voneinander ab.
    internal static let stgTxtCardResetPinWarning = StringAsset("stg_txt_card_reset_pin_warning")
    /// PUK eingeben
    internal static let stgTxtCardResetPukHeadline = StringAsset("stg_txt_card_reset_puk_headline")
    /// Mit Ihrer PIN haben Sie eine 8-stellige PUK von Ihrer Versicherung erhalten.
    internal static let stgTxtCardResetPukHint = StringAsset("stg_txt_card_reset_puk_hint")
    /// Wunsch-PIN gespeichert
    internal static let stgTxtCardResetRcAlertCardSetNewPinTitle = StringAsset("stg_txt_card_reset_rc_alert_card_set_new_pin_title")
    /// Sie können eine PUK für bis zu 10 Entsperrvorgänge nutzen.
    internal static let stgTxtCardResetRcAlertCardUnlockedMessage = StringAsset("stg_txt_card_reset_rc_alert_card_unlocked_message")
    /// Karte entsperrt
    internal static let stgTxtCardResetRcAlertCardUnlockedTitle = StringAsset("stg_txt_card_reset_rc_alert_card_unlocked_title")
    /// Sie können eine PUK für bis zu 10 Entsperrvorgänge nutzen.
    internal static let stgTxtCardResetRcAlertCardUnlockedWithPinMessage = StringAsset("stg_txt_card_reset_rc_alert_card_unlocked_with_pin_message")
    /// Wunsch-PIN gespeichert
    internal static let stgTxtCardResetRcAlertCardUnlockedWithPinTitle = StringAsset("stg_txt_card_reset_rc_alert_card_unlocked_with_pin_title")
    /// Sie haben mit dieser PUK die maximale Anzahl an Karten-Entsperrungen erreicht oder sie wiederholt falsch eingegeben. Bitte wenden Sie sich an Ihre Versicherung.
    internal static let stgTxtCardResetRcAlertCounterExhaustedMessage = StringAsset("stg_txt_card_reset_rc_alert_counter_exhausted_message")
    /// Entsperren nicht möglich
    internal static let stgTxtCardResetRcAlertCounterExhaustedTitle = StringAsset("stg_txt_card_reset_rc_alert_counter_exhausted_title")
    /// Sie haben mit dieser PUK die maximale Anzahl an Karten-Entsperrungen erreicht oder sie wiederholt falsch eingegeben. Bitte wenden Sie sich an Ihre Versicherung.
    internal static let stgTxtCardResetRcAlertCounterExhaustedWithPinMessage = StringAsset("stg_txt_card_reset_rc_alert_counter_exhausted_with_pin_message")
    /// Speichern der Wunsch-PIN nicht möglich
    internal static let stgTxtCardResetRcAlertCounterExhaustedWithPinTitle = StringAsset("stg_txt_card_reset_rc_alert_counter_exhausted_with_pin_title")
    /// Entsperren Sie Ihre Karte unter Einstellungen > Karte entsperren.
    internal static let stgTxtCardResetRcAlertPinCounterExhaustedMessage = StringAsset("stg_txt_card_reset_rc_alert_pin_counter_exhausted_message")
    /// Karte gesperrt
    internal static let stgTxtCardResetRcAlertPinCounterExhaustedTitle = StringAsset("stg_txt_card_reset_rc_alert_pin_counter_exhausted_title")
    /// Bitte probieren Sie es erneut.
    internal static let stgTxtCardResetRcAlertUnknownErrorMessage = StringAsset("stg_txt_card_reset_rc_alert_unknown_error_message")
    /// Ein Fehler ist aufgetreten
    internal static let stgTxtCardResetRcAlertUnknownErrorTitle = StringAsset("stg_txt_card_reset_rc_alert_unknown_error_title")
    /// Bitte korrigieren Sie Ihre Zugangsnummer (CAN)
    internal static let stgTxtCardResetRcAlertWrongCanMessage = StringAsset("stg_txt_card_reset_rc_alert_wrong_can_message")
    /// Falsche CAN
    internal static let stgTxtCardResetRcAlertWrongCanTitle = StringAsset("stg_txt_card_reset_rc_alert_wrong_can_title")
    /// Plural format key: "%#@variable_0@"
    internal static func stgTxtCardResetRcAlertWrongPinMessage(_ element1: Int) -> StringAsset {
        StringAsset("stg_txt_card_reset_rc_alert_wrong_pin_message", arguments: [element1])
    }
    /// PIN falsch eingegeben
    internal static let stgTxtCardResetRcAlertWrongPinTitle = StringAsset("stg_txt_card_reset_rc_alert_wrong_pin_title")
    /// Plural format key: "%#@variable_0@"
    internal static func stgTxtCardResetRcAlertWrongPukMessage(_ element1: Int) -> StringAsset {
        StringAsset("stg_txt_card_reset_rc_alert_wrong_puk_message", arguments: [element1])
    }
    /// PUK falsch eingegeben
    internal static let stgTxtCardResetRcAlertWrongPukTitle = StringAsset("stg_txt_card_reset_rc_alert_wrong_puk_title")
    /// Sie haben leider keine weiteren Versuche Ihre PUK einzugeben. Bitte wenden Sie sich an Ihre Krankenversicherung.
    internal static let stgTxtCardResetRcAlertWrongPukZeroRetriesMessage = StringAsset("stg_txt_card_reset_rc_alert_wrong_puk_zero_retries_message")
    /// Keine weitere Eingabe möglich
    internal static let stgTxtCardResetRcAlertWrongPukZeroRetriesTitle = StringAsset("stg_txt_card_reset_rc_alert_wrong_puk_zero_retries_title")
    /// Setze Wunsch-PIN
    internal static let stgTxtCardResetRcNfcDialogChangeReferenceData = StringAsset("stg_txt_card_reset_rc_nfc_dialog_change_reference_data")
    /// Nicht erfolgreich
    internal static let stgTxtCardResetRcNfcDialogError = StringAsset("stg_txt_card_reset_rc_nfc_dialog_error")
    /// Entsperre Karte
    internal static let stgTxtCardResetRcNfcDialogUnlockCard = StringAsset("stg_txt_card_reset_rc_nfc_dialog_unlock_card")
    /// Setze PIN
    internal static let stgTxtCardResetRcNfcDialogUnlockCardWithPin = StringAsset("stg_txt_card_reset_rc_nfc_dialog_unlock_card_with_pin")
    /// Gesundheitskarte
    internal static let stgTxtCardSectionHeader = StringAsset("stg_txt_card_section_header")
    /// Karte entsperren
    internal static let stgTxtCardUnlockCard = StringAsset("stg_txt_card_unlock_card")
    /// Demo mode
    internal static let stgTxtDemoMode = StringAsset("stg_txt_demo_mode")
    /// Background colour
    internal static let stgTxtEditProfileBackgroundSectionTitle = StringAsset("stg_txt_edit_profile_background_section_title")
    /// Profile name
    internal static let stgTxtEditProfileDefaultName = StringAsset("stg_txt_edit_profile_default_name")
    /// This will erase all data on this device. Your prescriptions in the health network will be retained.
    internal static let stgTxtEditProfileDeleteConfirmationMessage = StringAsset("stg_txt_edit_profile_delete_confirmation_message")
    /// Delete profile?
    internal static let stgTxtEditProfileDeleteConfirmationTitle = StringAsset("stg_txt_edit_profile_delete_confirmation_title")
    /// Delete access data
    internal static let stgTxtEditProfileDeletePairing = StringAsset("stg_txt_edit_profile_delete_pairing")
    /// The access data could not be deleted from the server. Please try again
    internal static let stgTxtEditProfileDeletePairingError = StringAsset("stg_txt_edit_profile_delete_pairing_error")
    /// You will no longer automatically receive new prescriptions.
    internal static let stgTxtEditProfileDeletePairingMessage = StringAsset("stg_txt_edit_profile_delete_pairing_message")
    /// The name field must not be empty
    internal static let stgTxtEditProfileEmptyNameErrorMessage = StringAsset("stg_txt_edit_profile_empty_name_error_message")
    /// Error
    internal static let stgTxtEditProfileErrorMessageTitle = StringAsset("stg_txt_edit_profile_error_message_title")
    /// Access number
    internal static let stgTxtEditProfileLabelCan = StringAsset("stg_txt_edit_profile_label_can")
    /// Insurance
    internal static let stgTxtEditProfileLabelInsuranceCompany = StringAsset("stg_txt_edit_profile_label_insurance_company")
    /// Policyholder number
    internal static let stgTxtEditProfileLabelKvnr = StringAsset("stg_txt_edit_profile_label_kvnr")
    /// Name
    internal static let stgTxtEditProfileLabelName = StringAsset("stg_txt_edit_profile_label_name")
    /// Save login details
    internal static let stgTxtEditProfileLoginActivateDescription = StringAsset("stg_txt_edit_profile_login_activate_description")
    /// Activated
    internal static let stgTxtEditProfileLoginActivateTitle = StringAsset("stg_txt_edit_profile_login_activate_title")
    /// Disabled
    internal static let stgTxtEditProfileLoginDeactivateTitle = StringAsset("stg_txt_edit_profile_login_deactivate_title")
    /// Connected devices
    internal static let stgTxtEditProfileLoginDeviceTitle = StringAsset("stg_txt_edit_profile_login_device_title")
    /// Your device does not meet the security requirements for the permanent storage of access data to the prescription server.
    internal static let stgTxtEditProfileLoginFootnoteBiometry = StringAsset("stg_txt_edit_profile_login_footnote_biometry")
    /// Find out more
    internal static let stgTxtEditProfileLoginFootnoteMore = StringAsset("stg_txt_edit_profile_login_footnote_more")
    /// Next time you connect to the health network, you can save the access data during the connection process
    internal static let stgTxtEditProfileLoginFootnoteRetry = StringAsset("stg_txt_edit_profile_login_footnote_retry")
    /// Device management
    internal static let stgTxtEditProfileLoginSectionTitle = StringAsset("stg_txt_edit_profile_login_section_title")
    /// This disconnects you from the health network. You will not receive any new prescriptions or messages.
    internal static let stgTxtEditProfileLogoutInfo = StringAsset("stg_txt_edit_profile_logout_info")
    /// Connected to: %@
    internal static func stgTxtEditProfileNameConnection(_ element1: String) -> StringAsset {
        StringAsset("stg_txt_edit_profile_name_connection_%@", arguments: [element1])
    }
    /// This profile has not yet been linked to a policyholder number. To do this, you must log in to the prescription server.
    internal static let stgTxtEditProfileNameConnectionPlaceholder = StringAsset("stg_txt_edit_profile_name_connection_placeholder")
    /// Enter name
    internal static let stgTxtEditProfileNamePlaceholder = StringAsset("stg_txt_edit_profile_name_placeholder")
    /// Security
    internal static let stgTxtEditProfileSecuritySectionTitle = StringAsset("stg_txt_edit_profile_security_section_title")
    /// Who accessed your prescriptions and when?
    internal static let stgTxtEditProfileSecurityShowAuditEventsDescription = StringAsset("stg_txt_edit_profile_security_show_audit_events_description")
    /// Display access logs
    internal static let stgTxtEditProfileSecurityShowAuditEventsLabel = StringAsset("stg_txt_edit_profile_security_show_audit_events_label")
    /// Access key to the prescription service
    internal static let stgTxtEditProfileSecurityShowTokensDescription = StringAsset("stg_txt_edit_profile_security_show_tokens_description")
    /// You will receive a token when you are logged in to the prescription service.
    internal static let stgTxtEditProfileSecurityShowTokensHint = StringAsset("stg_txt_edit_profile_security_show_tokens_hint")
    /// Display tokens
    internal static let stgTxtEditProfileSecurityShowTokensLabel = StringAsset("stg_txt_edit_profile_security_show_tokens_label")
    /// Profile
    internal static let stgTxtEditProfileTitle = StringAsset("stg_txt_edit_profile_title")
    /// Policyholder details
    internal static let stgTxtEditProfileUserDataSectionTitle = StringAsset("stg_txt_edit_profile_user_data_section_title")
    /// Our demo mode shows you all the functions of the app – without a medical card.
    internal static let stgTxtFootnoteDemoMode = StringAsset("stg_txt_footnote_demo_mode")
    /// Contact
    internal static let stgTxtHeaderContactInfo = StringAsset("stg_txt_header_contact_info")
    /// Launch demo mode
    internal static let stgTxtHeaderDemoMode = StringAsset("stg_txt_header_demo_mode")
    /// Legal information
    internal static let stgTxtHeaderLegalInfo = StringAsset("stg_txt_header_legal_info")
    /// Profiles
    internal static let stgTxtHeaderProfiles = StringAsset("stg_txt_header_profiles")
    /// Security
    internal static let stgTxtHeaderSecurity = StringAsset("stg_txt_header_security")
    /// Background colour
    internal static let stgTxtNewProfileBackgroundSectionTitle = StringAsset("stg_txt_new_profile_background_section_title")
    /// Error
    internal static let stgTxtNewProfileErrorMessageTitle = StringAsset("stg_txt_new_profile_error_message_title")
    /// The name field cannot be empty
    internal static let stgTxtNewProfileMissingNameError = StringAsset("stg_txt_new_profile_missing_name_error")
    /// Enter name
    internal static let stgTxtNewProfileNamePlaceholder = StringAsset("stg_txt_new_profile_name_placeholder")
    /// Create new profile
    internal static let stgTxtNewProfileTitle = StringAsset("stg_txt_new_profile_title")
    /// There are no devices associated with this medical card.
    internal static let stgTxtRegDevicesEmptyList = StringAsset("stg_txt_reg_devices_empty_list")
    /// No devices
    internal static let stgTxtRegDevicesEmptyListTitle = StringAsset("stg_txt_reg_devices_empty_list_title")
    /// Additional authentication is required to display the devices.
    internal static let stgTxtRegDevicesInfo = StringAsset("stg_txt_reg_devices_info")
    /// Authentication required
    internal static let stgTxtRegDevicesInfoTitle = StringAsset("stg_txt_reg_devices_info_title")
    /// Registered since %@
    internal static func stgTxtRegDevicesRegisteredSince(_ element1: String) -> StringAsset {
        StringAsset("stg_txt_reg_devices_registered_since_%@", arguments: [element1])
    }
    /// Registered since %@ (this device)
    internal static func stgTxtRegDevicesRegisteredSinceThisDevice(_ element1: String) -> StringAsset {
        StringAsset("stg_txt_reg_devices_registered_since_%@_this_device", arguments: [element1])
    }
    /// Connected devices
    internal static let stgTxtRegDevicesTitle = StringAsset("stg_txt_reg_devices_title")
    /// Face ID
    internal static let stgTxtSecurityOptionFaceidTitle = StringAsset("stg_txt_security_option_faceid_title")
    /// Password
    internal static let stgTxtSecurityOptionPasswordTitle = StringAsset("stg_txt_security_option_password_title")
    /// Touch ID
    internal static let stgTxtSecurityOptionTouchidTitle = StringAsset("stg_txt_security_option_touchid_title")
    /// This app has not yet been secured. Improve the protection of your data with a fingerprint or face scan.
    internal static let stgTxtSecurityWarning = StringAsset("stg_txt_security_warning")
    /// Settings
    internal static let stgTxtTitle = StringAsset("stg_txt_title")
    /// Version %@ • Build %@
    internal static func stgTxtVersionAndBuild(_ element1: String, _ element2: String) -> StringAsset {
        StringAsset("stg_txt_version_%@_and_build_%@", arguments: [element1, element2])
    }
    /// Prescriptions
    internal static let tabTxtMain = StringAsset("tab_txt_main")
    /// Bestellungen
    internal static let tabTxtOrders = StringAsset("tab_txt_orders")
    /// Pharmacies
    internal static let tabTxtPharmacySearch = StringAsset("tab_txt_pharmacy_search")
    /// Settings
    internal static let tabTxtSettings = StringAsset("tab_txt_settings")
  }
  // swiftlint:enable function_parameter_count identifier_name line_length type_body_length
  