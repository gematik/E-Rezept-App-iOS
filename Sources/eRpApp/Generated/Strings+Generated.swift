// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import SwiftUI

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

  // swiftlint:disable function_parameter_count identifier_name line_length type_body_length
  internal enum L10n {
    /// E-prescription
    internal static let cfBundleDisplayName = StringAsset("CFBundleDisplayName")
    /// Allows you to identify and authenticate yourself using your electronic health card
    internal static let nfcReaderUsageDescription = StringAsset("NFCReaderUsageDescription")
    /// The camera is required to capture prescriptions or take photos.
    internal static let nsCameraUsageDescription = StringAsset("NSCameraUsageDescription")
    /// E-Rezept uses FaceID to protect your app from unauthorized access.
    internal static let nsFaceIDUsageDescription = StringAsset("NSFaceIDUsageDescription")
    /// Save
    internal static let addBtnSave = StringAsset("add_btn_save")
    /// Profile name
    internal static let addTxtProfile1 = StringAsset("add_txt_profile1")
    /// Enter name
    internal static let addTxtTitle = StringAsset("add_txt_title")
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
    /// Back to Face ID
    internal static let authBtnBapBackFaceID = StringAsset("auth_btn_bap_back_faceID")
    /// Back to Touch ID
    internal static let authBtnBapBackTouchID = StringAsset("auth_btn_bap_back_touchID")
    /// password
    internal static let authBtnBapChange = StringAsset("auth_btn_bap_change")
    /// Face ID
    internal static let authBtnBapFaceid = StringAsset("auth_btn_bap_faceid")
    /// Touch ID
    internal static let authBtnBapTouchid = StringAsset("auth_btn_bap_touchid")
    /// Unlock with Face ID
    internal static let authBtnBiometricsFaceid = StringAsset("auth_btn_biometrics_faceid")
    /// Unlock with Touch ID
    internal static let authBtnBiometricsTouchid = StringAsset("auth_btn_biometrics_touchid")
    /// Next
    internal static let authBtnPasswordContinue = StringAsset("auth_btn_password_continue")
    /// Please try again or enter your password.
    internal static let authTxtBapPasswordMessage = StringAsset("auth_txt_bap_password_message")
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
    /// An alternative to biometric login is not configured. Please deposit a password.
    internal static let authTxtBiometricsFailedUserFallback = StringAsset("auth_txt_biometrics_failed_user_fallback")
    /// Do you have any questions or problems using the app? You can reach our telephone support on 0800 277 377 7. 
    /// 
    ///  We have already answered many questions for you on das-e-rezept-fuer-deutschland.de.
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
    /// Internal error ( %@ )
    internal static func avsErrInternal(_ element1: String) -> StringAsset {
        StringAsset("avs_err_internal_%@", arguments: [element1])
    }
    /// Invalid pharmacy certificate
    internal static let avsErrInvalidCert = StringAsset("avs_err_invalid_cert")
    /// Bad message
    internal static let avsErrInvalidInput = StringAsset("avs_err_invalid_input")
    /// Please inform support if the error persists.
    internal static let avsErrRecoveryInternal = StringAsset("avs_err_recovery_internal")
    /// The pharmacy's certificate of transfer is invalid. Please log in or choose another pharmacy.
    internal static let avsErrRecoveryInvalidCert = StringAsset("avs_err_recovery_invalid_cert")
    /// The reservation data for the selected pharmacy are incomplete. Please log in or choose another pharmacy.
    internal static let avsErrRecoveryInvalidInput = StringAsset("avs_err_recovery_invalid_input")
    /// Demo mode enabled
    internal static let bnrTxtDemoMode = StringAsset("bnr_txt_demo_mode")
    /// inactive
    internal static let buttonTxtIsInactiveValue = StringAsset("button_txt_is_inactive_value")
    /// Cancel
    internal static let camBtnGallerySheetCancel = StringAsset("cam_btn_gallery_sheet_cancel")
    /// Documents
    internal static let camBtnGallerySheetDocument = StringAsset("cam_btn_gallery_sheet_document")
    /// Pictures
    internal static let camBtnGallerySheetPicture = StringAsset("cam_btn_gallery_sheet_picture")
    /// To use the scanner, you must allow the app to access your camera in the system settings.
    internal static let camInitFailMessage = StringAsset("cam_init_fail_message")
    /// Access to camera denied
    internal static let camInitFailTitle = StringAsset("cam_init_fail_title")
    /// Cancel
    internal static let camPermDenyBtnCancel = StringAsset("cam_perm_deny_btn_cancel")
    /// Allow
    internal static let camPermDenyBtnSettings = StringAsset("cam_perm_deny_btn_settings")
    /// The app must be able to access the device camera in order to use the scanner.
    internal static let camPermDenyMessage = StringAsset("cam_perm_deny_message")
    /// Allow access to camera?
    internal static let camPermDenyTitle = StringAsset("cam_perm_deny_title")
    /// Import files
    internal static let camTxtGallerySheetTitle = StringAsset("cam_txt_gallery_sheet_title")
    /// No
    internal static let camTxtWarnCancel = StringAsset("cam_txt_warn_cancel")
    /// Cancel scanning?
    internal static let camTxtWarnCancelTitle = StringAsset("cam_txt_warn_cancel_title")
    /// Yes
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
    /// Read access number with camera
    internal static let cdwBtnCanScanner = StringAsset("cdw_btn_can_scanner")
    /// Close
    internal static let cdwBtnExtauthAlertSaveProfile = StringAsset("cdw_btn_extauth_alert_save_profile")
    /// Cancel
    internal static let cdwBtnExtauthConfirmCancel = StringAsset("cdw_btn_extauth_confirm_cancel")
    /// Contact telephone support
    internal static let cdwBtnExtauthConfirmContact = StringAsset("cdw_btn_extauth_confirm_contact")
    /// Send
    internal static let cdwBtnExtauthConfirmSend = StringAsset("cdw_btn_extauth_confirm_send")
    /// Order medical card
    internal static let cdwBtnExtauthFallbackOrderEgk = StringAsset("cdw_btn_extauth_fallback_order_egk")
    /// Cancel
    internal static let cdwBtnExtauthSelectionCancel = StringAsset("cdw_btn_extauth_selection_cancel")
    /// Next
    internal static let cdwBtnExtauthSelectionContinue = StringAsset("cdw_btn_extauth_selection_continue")
    /// Help
    internal static let cdwBtnExtauthSelectionHelp = StringAsset("cdw_btn_extauth_selection_help")
    /// Order medical card
    internal static let cdwBtnExtauthSelectionOrderEgk = StringAsset("cdw_btn_extauth_selection_order_egk")
    /// Try again
    internal static let cdwBtnExtauthSelectionRetry = StringAsset("cdw_btn_extauth_selection_retry")
    /// Immediately after pressing this button, the health card is read in via NFC. To do this, hold the card directly against the device. If the connection is successful, you will receive haptic feedback. If the connection is broken or errors occur, this is also communicated via haptic feedback. Communication with the health card can take up to ten seconds. Then remove the health card from the device.
    internal static let cdwBtnHelpNextHint = StringAsset("cdw_btn_help_next_hint")
    /// Close
    internal static let cdwBtnIntroAlertClose = StringAsset("cdw_btn_intro_alert_close")
    /// Close dialog
    internal static let cdwBtnIntroCancelLabel = StringAsset("cdw_btn_intro_cancel_label")
    /// Connect to
    internal static let cdwBtnIntroDirectExtauth = StringAsset("cdw_btn_intro_direct_extauth")
    /// Digital health ID
    internal static let cdwBtnIntroExtauth = StringAsset("cdw_btn_intro_extauth")
    /// health insurance app
    internal static let cdwBtnIntroExtauthCenter = StringAsset("cdw_btn_intro_extauth_center")
    /// Additional app required
    internal static let cdwBtnIntroExtauthDescription = StringAsset("cdw_btn_intro_extauth_description")
    /// Or: Sign in with your 
    internal static let cdwBtnIntroExtauthLeading = StringAsset("cdw_btn_intro_extauth_leading")
    /// .
    internal static let cdwBtnIntroExtauthTrailing = StringAsset("cdw_btn_intro_extauth_trailing")
    /// order now
    internal static let cdwBtnIntroFootnote = StringAsset("cdw_btn_intro_footnote")
    /// Find out more
    internal static let cdwBtnIntroMore = StringAsset("cdw_btn_intro_more")
    /// Let's get started
    internal static let cdwBtnIntroNext = StringAsset("cdw_btn_intro_next")
    /// Insurance card
    internal static let cdwBtnIntroNfc = StringAsset("cdw_btn_intro_nfc")
    /// Recommended
    internal static let cdwBtnIntroRecommendation = StringAsset("cdw_btn_intro_recommendation")
    /// Close dialog
    internal static let cdwBtnNfuCancelLabel = StringAsset("cdw_btn_nfu_cancel_label")
    /// Back to the homepage
    internal static let cdwBtnNfuDone = StringAsset("cdw_btn_nfu_done")
    /// Find out more
    internal static let cdwBtnNfuMore = StringAsset("cdw_btn_nfu_more")
    /// My card does not have an access number
    internal static let cdwBtnNoCan = StringAsset("cdw_btn_no_can")
    /// Back
    internal static let cdwBtnPinBack = StringAsset("cdw_btn_pin_back")
    /// Cancel
    internal static let cdwBtnPinCancelLabel = StringAsset("cdw_btn_pin_cancel_label")
    /// Next
    internal static let cdwBtnPinDone = StringAsset("cdw_btn_pin_done")
    /// Next
    internal static let cdwBtnPinDoneLabel = StringAsset("cdw_btn_pin_done_label")
    /// No PIN received
    internal static let cdwBtnPinNoPin = StringAsset("cdw_btn_pin_no_pin")
    /// Cancel
    internal static let cdwBtnRcAlertCancel = StringAsset("cdw_btn_rc_alert_cancel")
    /// Close
    internal static let cdwBtnRcAlertClose = StringAsset("cdw_btn_rc_alert_close")
    /// Report
    internal static let cdwBtnRcAlertReport = StringAsset("cdw_btn_rc_alert_report")
    /// Close
    internal static let cdwBtnRcAlertSaveProfile = StringAsset("cdw_btn_rc_alert_save_profile")
    /// Unblock card
    internal static let cdwBtnRcAlertUnlockcard = StringAsset("cdw_btn_rc_alert_unlockcard")
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
    /// https://www.das-e-rezept-fuer-deutschland.de/ext/egk-help
    internal static let cdwBtnRcHelpUrl = StringAsset("cdw_btn_rc_help_url")
    /// Loading
    internal static let cdwBtnRcLoading = StringAsset("cdw_btn_rc_loading")
    /// Connect card
    internal static let cdwBtnRcNext = StringAsset("cdw_btn_rc_next")
    /// Immediately after pressing this button, the health card is read in via NFC. To do this, hold the card directly against the device. If the connection is successful, you will receive haptic feedback. If the connection is broken or errors occur, this is also communicated via haptic feedback. Communication with the health card can take up to ten seconds. Then remove the health card from the device.
    internal static let cdwBtnRcNextHint = StringAsset("cdw_btn_rc_next_hint")
    /// Next tip
    internal static let cdwBtnRcNextTip = StringAsset("cdw_btn_rc_next_tip")
    /// Repeat
    internal static let cdwBtnRcRetry = StringAsset("cdw_btn_rc_retry")
    /// Try out
    internal static let cdwBtnRcTryout = StringAsset("cdw_btn_rc_tryout")
    /// Watch video tutorial
    internal static let cdwBtnRcVideo = StringAsset("cdw_btn_rc_video")
    /// Immediately after pressing this button, the health card is read in via NFC. To do this, hold the card directly against the device. If the connection is successful, you will receive haptic feedback. If the connection is broken or errors occur, this is also communicated via haptic feedback. Communication with the health card can take up to ten seconds. Then remove the health card from the device.
    internal static let cdwBtnRchelpNextHint = StringAsset("cdw_btn_rchelp_next_hint")
    /// Next
    internal static let cdwBtnSelContinue = StringAsset("cdw_btn_sel_continue")
    /// Associated PIN required
    internal static let cdwBtnSubintroNfc = StringAsset("cdw_btn_subintro_nfc")
    /// NFC-enabled smartphone required
    internal static let cdwBtnSubintroNonfc = StringAsset("cdw_btn_subintro_nonfc")
    /// Cancel scanning
    internal static let cdwCanScanBtnClose = StringAsset("cdw_can_scan_btn_close")
    /// Accept
    internal static let cdwCanScanBtnConfirm = StringAsset("cdw_can_scan_btn_confirm")
    /// Place the health card within the cutout
    internal static let cdwCanScanTxtHint = StringAsset("cdw_can_scan_txt_hint")
    /// Access number detected:
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
    /// Illustration of a health card. The access number can be found on the top right of the front of the health card.
    internal static let cdwImgCanCardLabel = StringAsset("cdw_img_can_card_label")
    /// Illustration of a user holding their medical card to the back of their smartphone.
    internal static let cdwImgIntroMainLabel = StringAsset("cdw_img_intro_main_label")
    /// Persistent connection problem?
    internal static let cdwRcTxtErrorBadCardDescription = StringAsset("cdw_rc_txt_error_bad_card_description")
    /// Some cards have weak antennas. Please report your card to us so that we can work together with the cash registers to improve it.
    internal static let cdwRcTxtErrorBadCardRecovery = StringAsset("cdw_rc_txt_error_bad_card_recovery")
    /// Your selection will not be saved.
    internal static let cdwTxtBiometryDemoModeInfo = StringAsset("cdw_txt_biometry_demo_mode_info")
    /// Sign in conveniently with a fingerprint or facial scan for 6 months
    internal static let cdwTxtBiometryOptionBiometryDescription = StringAsset("cdw_txt_biometry_option_biometry_description")
    /// Save login details
    internal static let cdwTxtBiometryOptionBiometryTitle = StringAsset("cdw_txt_biometry_option_biometry_title")
    /// You will be automatically logged out after 12 hours
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
    /// Saving access data not possible. Set up biometric security with Face ID or Touch ID on your device beforehand.
    internal static let cdwTxtBiometrySetupIncomplete = StringAsset("cdw_txt_biometry_setup_incomplete")
    /// Would you like to save your login details for future logins?
    internal static let cdwTxtBiometrySubtitle = StringAsset("cdw_txt_biometry_subtitle")
    /// Login
    internal static let cdwTxtBiometryTitle = StringAsset("cdw_txt_biometry_title")
    /// You can enter any digits.
    internal static let cdwTxtCanDemoModeInfo = StringAsset("cdw_txt_can_demo_mode_info")
    /// You can find your access number in the top right corner of your health card.
    internal static let cdwTxtCanDescription = StringAsset("cdw_txt_can_description")
    /// Enter access number
    internal static let cdwTxtCanSubtitle = StringAsset("cdw_txt_can_subtitle")
    /// Login
    internal static let cdwTxtCanTitle = StringAsset("cdw_txt_can_title")
    /// Your Card Access Number (CAN) has 6 digits. You can find the CAN in the top right corner on the front of your health card. If there is no six-digit access number, you need a new health card from your health insurance company.
    internal static let cdwTxtCanTitleHint = StringAsset("cdw_txt_can_title_hint")
    /// Unfortunately, the CAN entered does not match the recognised card. Please enter the CAN again. Thank you!
    internal static let cdwTxtCanWarnWrongDescription = StringAsset("cdw_txt_can_warn_wrong_description")
    /// Wrong CAN
    internal static let cdwTxtCanWarnWrongTitle = StringAsset("cdw_txt_can_warn_wrong_title")
    /// Your medical card could not be linked to the profile.
    internal static let cdwTxtExtauthAlertMessageSaveProfile = StringAsset("cdw_txt_extauth_alert_message_save_profile")
    /// Error saving profile
    internal static let cdwTxtExtauthAlertTitleSaveProfile = StringAsset("cdw_txt_extauth_alert_title_save_profile")
    /// Email
    internal static let cdwTxtExtauthConfirmContactsheetMail = StringAsset("cdw_txt_extauth_confirm_contactsheet_mail")
    /// Phone
    internal static let cdwTxtExtauthConfirmContactsheetTelephone = StringAsset("cdw_txt_extauth_confirm_contactsheet_telephone")
    /// Contact support
    internal static let cdwTxtExtauthConfirmContactsheetTitle = StringAsset("cdw_txt_extauth_confirm_contactsheet_title")
    /// We will now request authentication from your health insurance company.
    internal static let cdwTxtExtauthConfirmDescription = StringAsset("cdw_txt_extauth_confirm_description")
    /// Please mention this error to our support to help find a solution.
    internal static let cdwTxtExtauthConfirmErrorDescription = StringAsset("cdw_txt_extauth_confirm_error_description")
    /// Requesting authentication
    internal static let cdwTxtExtauthConfirmHeadline = StringAsset("cdw_txt_extauth_confirm_headline")
    /// E-prescription
    internal static let cdwTxtExtauthConfirmOwnAppname = StringAsset("cdw_txt_extauth_confirm_own_appname")
    /// Log in with app
    internal static let cdwTxtExtauthConfirmTitle = StringAsset("cdw_txt_extauth_confirm_title")
    /// Error opening health insurance app.
    internal static let cdwTxtExtauthConfirmUniversalLinkFailedError = StringAsset("cdw_txt_extauth_confirm_universal_link_failed_error")
    /// The health insurance companies are currently preparing for this function.
    internal static let cdwTxtExtauthFallbackDescription1 = StringAsset("cdw_txt_extauth_fallback_description1")
    /// You don't want to wait? Registration with a medical card is already supported by every health insurance company.
    internal static let cdwTxtExtauthFallbackDescription2 = StringAsset("cdw_txt_extauth_fallback_description2")
    /// Select insurance company
    internal static let cdwTxtExtauthFallbackHeadline = StringAsset("cdw_txt_extauth_fallback_headline")
    /// Log in with app
    internal static let cdwTxtExtauthFallbackTitle = StringAsset("cdw_txt_extauth_fallback_title")
    /// Tips for registering with the insurance app
    internal static let cdwTxtExtauthHelpCaption = StringAsset("cdw_txt_extauth_help_caption")
    /// Your insurance company is responsible for the health ID. Please contact them if you have any questions about registration. Here are some tried and tested tips:
    internal static let cdwTxtExtauthHelpDescription = StringAsset("cdw_txt_extauth_help_description")
    /// Please note that depending on your insurance, a separate app is required. Please ask your insurance company which one this is.
    internal static let cdwTxtExtauthHelpInfo1 = StringAsset("cdw_txt_extauth_help_info_1")
    /// Start the cash register app and log in there once before you start logging in to the e-prescription app.
    internal static let cdwTxtExtauthHelpInfo2 = StringAsset("cdw_txt_extauth_help_info_2")
    /// Switching between logging in with your health ID and your health card can cause problems. Please first actively log out of your profile before changing the login option.
    internal static let cdwTxtExtauthHelpInfo3 = StringAsset("cdw_txt_extauth_help_info_3")
    /// If your insurance is not listed, you can alternatively log in using your health card and the associated PIN.
    internal static let cdwTxtExtauthHelpInfo4 = StringAsset("cdw_txt_extauth_help_info_4")
    /// If the health insurance app does not redirect you back to the e-prescription app, please report this error to your insurance company.
    internal static let cdwTxtExtauthHelpInfo5 = StringAsset("cdw_txt_extauth_help_info_5")
    /// Help
    internal static let cdwTxtExtauthHelpTitle = StringAsset("cdw_txt_extauth_help_title")
    /// We couldn't find any results with this search term.
    internal static let cdwTxtExtauthNoresults = StringAsset("cdw_txt_extauth_noresults")
    /// No results
    internal static let cdwTxtExtauthNoresultsTitle = StringAsset("cdw_txt_extauth_noresults_title")
    /// Search by name
    internal static let cdwTxtExtauthSearchprompt = StringAsset("cdw_txt_extauth_searchprompt")
    /// If registration with the Health ID does not work as expected, please follow the tips in our help.
    internal static let cdwTxtExtauthSelectionDescription = StringAsset("cdw_txt_extauth_selection_description")
    /// This feature will be available in a few days. Please try again later.
    internal static let cdwTxtExtauthSelectionEmptyListDescription = StringAsset("cdw_txt_extauth_selection_empty_list_description")
    /// Not yet available
    internal static let cdwTxtExtauthSelectionEmptyListHeadline = StringAsset("cdw_txt_extauth_selection_empty_list_headline")
    ///  Please try again later.
    internal static let cdwTxtExtauthSelectionErrorFallback = StringAsset("cdw_txt_extauth_selection_error_fallback")
    /// Select insurance company
    internal static let cdwTxtExtauthSelectionHeadline = StringAsset("cdw_txt_extauth_selection_headline")
    /// Log in with app
    internal static let cdwTxtExtauthSelectionTitle = StringAsset("cdw_txt_extauth_selection_title")
    /// Health insurance company could not be found
    internal static let cdwTxtIntroAlertKkNotFoundTitle = StringAsset("cdw_txt_intro_alert_kkNotFound_title")
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
    /// Register
    internal static let cdwTxtIntroHeaderTop = StringAsset("cdw_txt_intro_header_top")
    /// Please select your health insurance provider again.
    internal static let cdwTxtIntroKkNotFoundAlertMessage = StringAsset("cdw_txt_intro_kkNotFound_alert_message")
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
    /// How would you like to authenticate?
    internal static let cdwTxtIntroSubheader = StringAsset("cdw_txt_intro_subheader")
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
    /// You received the PIN for your health card from your health insurance company using a secure procedure such as Postident.
    internal static let cdwTxtPinDescription = StringAsset("cdw_txt_pin_description")
    /// Your PIN can have between 6 and 8 digits.
    internal static let cdwTxtPinHint = StringAsset("cdw_txt_pin_hint")
    /// Please enter your PIN. Your PIN has been sent to you by post. The PIN has 6 to 8 digits.
    internal static let cdwTxtPinInputLabel = StringAsset("cdw_txt_pin_input_label")
    /// PIN
    internal static let cdwTxtPinSubtitle = StringAsset("cdw_txt_pin_subtitle")
    /// Login
    internal static let cdwTxtPinTitle = StringAsset("cdw_txt_pin_title")
    /// Unfortunately, the PIN you entered does not match the recognized card. Are you sure you entered the PIN you received from your health insurance company?
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
    /// Your device's NFC receiver is located at the mark. Hold your card as close to this spot as possible.
    internal static let cdwTxtRcCard = StringAsset("cdw_txt_rc_card")
    /// Place the card on the NFC receiver
    internal static let cdwTxtRcCardHeader = StringAsset("cdw_txt_rc_card_header")
    /// Place the health card on the display
    internal static let cdwTxtRcCta = StringAsset("cdw_txt_rc_cta")
    /// You do not need a medical card in demo mode.
    internal static let cdwTxtRcDemoModeInfo = StringAsset("cdw_txt_rc_demo_mode_info")
    /// Click Login and hold your card against the device as shown. Do not move the card once a connection has been established.
    internal static let cdwTxtRcDescription = StringAsset("cdw_txt_rc_description")
    /// card blocked
    internal static let cdwTxtRcErrorCardLockedDescription = StringAsset("cdw_txt_rc_error_card_locked_description")
    /// The PIN was entered incorrectly three times. Your card has therefore been blocked for use with a PIN for security reasons.
    internal static let cdwTxtRcErrorCardLockedRecovery = StringAsset("cdw_txt_rc_error_card_locked_recovery")
    /// Error reading the medical card
    internal static let cdwTxtRcErrorGenericCardDescription = StringAsset("cdw_txt_rc_error_generic_card_description")
    /// Please try again
    internal static let cdwTxtRcErrorGenericCardRecovery = StringAsset("cdw_txt_rc_error_generic_card_recovery")
    /// Write operation not successful
    internal static let cdwTxtRcErrorMemoryFailureDescription = StringAsset("cdw_txt_rc_error_memory_failure_description")
    /// PIN could not be saved.
    internal static let cdwTxtRcErrorMemoryFailureRecovery = StringAsset("cdw_txt_rc_error_memory_failure_recovery")
    /// Assign your own PIN
    internal static let cdwTxtRcErrorOwnPinDescription = StringAsset("cdw_txt_rc_error_own_pin_description")
    /// The card is secured with a PIN from your health insurance company (transport PIN). Please enter your own PIN.
    internal static let cdwTxtRcErrorOwnPinRecovery = StringAsset("cdw_txt_rc_error_own_pin_recovery")
    /// Password not found
    internal static let cdwTxtRcErrorPasswordMissingDescription = StringAsset("cdw_txt_rc_error_password_missing_description")
    /// There is no password stored on your card.
    internal static let cdwTxtRcErrorPasswordMissingRecovery = StringAsset("cdw_txt_rc_error_password_missing_recovery")
    /// Access rule violated
    internal static let cdwTxtRcErrorSecStatusDescription = StringAsset("cdw_txt_rc_error_sec_status_description")
    /// You do not have permission to access the map directory.
    internal static let cdwTxtRcErrorSecStatusRecovery = StringAsset("cdw_txt_rc_error_sec_status_recovery")
    /// Saving access data not possible. Set up biometric security with Face ID or Touch ID on your device beforehand.
    internal static let cdwTxtRcErrorSecureEnclaveIssue = StringAsset("cdw_txt_rc_error_secure_enclave_issue")
    /// Unknown card error
    internal static let cdwTxtRcErrorUnknownFailureDescription = StringAsset("cdw_txt_rc_error_unknown_failure_description")
    /// The card responds with an unspecified error.
    internal static let cdwTxtRcErrorUnknownFailureRecovery = StringAsset("cdw_txt_rc_error_unknown_failure_recovery")
    /// Incorrect access number
    internal static let cdwTxtRcErrorWrongCanDescription = StringAsset("cdw_txt_rc_error_wrong_can_description")
    /// Please correct your access number (CAN)
    internal static let cdwTxtRcErrorWrongCanRecovery = StringAsset("cdw_txt_rc_error_wrong_can_recovery")
    /// Incorrect PIN
    internal static let cdwTxtRcErrorWrongPinDescription = StringAsset("cdw_txt_rc_error_wrong_pin_description_%@")
    /// %@ more attempts. Attention: it must be the PIN of your health card. Not the TK Ident PIN, for example.
    internal static func cdwTxtRcErrorWrongPinRecovery(_ element1: String) -> StringAsset {
        StringAsset("cdw_txt_rc_error_wrong_pin_recovery_%@", arguments: [element1])
    }
    /// Have your medical card ready
    internal static let cdwTxtRcHeadline = StringAsset("cdw_txt_rc_headline")
    /// Check if your device is sufficiently charged.
    internal static let cdwTxtRcListCharge = StringAsset("cdw_txt_rc_list_charge")
    /// Remove the protective case if necessary.
    internal static let cdwTxtRcListCover = StringAsset("cdw_txt_rc_list_cover")
    /// Place the card directly on the device.
    internal static let cdwTxtRcListDevice = StringAsset("cdw_txt_rc_list_device")
    /// Turn your display off and on again.
    internal static let cdwTxtRcListDisplay = StringAsset("cdw_txt_rc_list_display")
    /// Register with your health insurance app.
    internal static let cdwTxtRcListExtauth = StringAsset("cdw_txt_rc_list_extauth")
    /// Find out more
    internal static let cdwTxtRcListExtauthMore = StringAsset("cdw_txt_rc_list_extauth_more")
    /// Not work? Here are a few more tips.
    internal static let cdwTxtRcListHeader = StringAsset("cdw_txt_rc_list_header")
    /// Restart the e-prescription app or mobile device.
    internal static let cdwTxtRcListRestart = StringAsset("cdw_txt_rc_list_restart")
    /// To illustrate this, we have compiled our tips for connecting mobile devices and health cards in a short video for you.
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
    /// Where is NFC in my phone?
    internal static let cdwTxtRcNfcHeader = StringAsset("cdw_txt_rc_nfc_header")
    /// Connection failed
    internal static let cdwTxtRcNfcMessageConnectionErrorMessage = StringAsset("cdw_txt_rc_nfc_message_connectionErrorMessage")
    /// Medical card found. Please do not move.
    internal static let cdwTxtRcNfcMessageConnectMessage = StringAsset("cdw_txt_rc_nfc_message_connectMessage")
    /// Place your health card on the display or at the top of your smartphone.
    internal static let cdwTxtRcNfcMessageDiscoveryMessage = StringAsset("cdw_txt_rc_nfc_message_discoveryMessage")
    /// Several medical cards found
    internal static let cdwTxtRcNfcMessageMultipleCardsMessage = StringAsset("cdw_txt_rc_nfc_message_multipleCardsMessage")
    /// No medical card found
    internal static let cdwTxtRcNfcMessageNoCardMessage = StringAsset("cdw_txt_rc_nfc_message_noCardMessage")
    /// This card type is not supported
    internal static let cdwTxtRcNfcMessageUnsupportedCardMessage = StringAsset("cdw_txt_rc_nfc_message_unsupportedCardMessage")
    /// Place card here 👆
    internal static let cdwTxtRcPlacement = StringAsset("cdw_txt_rc_placement")
    /// Move the card so that the gold chip is above the front camera or hold the card to the iPhone head as shown in the picture.
    internal static let cdwTxtRcPositionContent = StringAsset("cdw_txt_rc_position_content")
    /// Different position
    internal static let cdwTxtRcPositionHeader = StringAsset("cdw_txt_rc_position_header")
    /// The following process can take up to 30 seconds.
    internal static let cdwTxtRcSubheadline = StringAsset("cdw_txt_rc_subheadline")
    /// Tip 4 of 4
    internal static let cdwTxtRcTipFour = StringAsset("cdw_txt_rc_tip_four")
    /// Tip 1 of 4
    internal static let cdwTxtRcTipOne = StringAsset("cdw_txt_rc_tip_one")
    /// Tip 3 of 4
    internal static let cdwTxtRcTipThree = StringAsset("cdw_txt_rc_tip_three")
    /// Tip 2 of 4
    internal static let cdwTxtRcTipTwo = StringAsset("cdw_txt_rc_tip_two")
    /// Login
    internal static let cdwTxtRcTitle = StringAsset("cdw_txt_rc_title")
    /// Select a login method to receive prescriptions automatically.
    internal static let cdwTxtSelDescription = StringAsset("cdw_txt_sel_description")
    /// Secure login with your new electronic medical card
    internal static let cdwTxtSelEgkDescription = StringAsset("cdw_txt_sel_egk_description")
    /// Log in with medical card
    internal static let cdwTxtSelEgkTitle = StringAsset("cdw_txt_sel_egk_title")
    /// How do you want to sign in?
    internal static let cdwTxtSelHeadline = StringAsset("cdw_txt_sel_headline")
    /// Use an app from your health insurance company for activation
    internal static let cdwTxtSelKkappComingSoonDescription = StringAsset("cdw_txt_sel_kkapp_coming_soon_description")
    /// Next year: Register with the health insurance app
    internal static let cdwTxtSelKkappComingSoonTitle = StringAsset("cdw_txt_sel_kkapp_coming_soon_title")
    /// Use an app from your health insurance company for activation
    internal static let cdwTxtSelKkappDescription = StringAsset("cdw_txt_sel_kkapp_description")
    /// Register with the health insurance app
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
    /// The password needs to be at least eight characters long
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
    /// Profile picture
    internal static let ctlBtnProfilePickerPictureA11yLabel = StringAsset("ctl_btn_profile_picker_picture_a11y_label")
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
    /// Blue moon September
    internal static let ctlTxtProfileColorPickerBlue = StringAsset("ctl_txt_profile_color_picker_blue")
    /// Tree
    internal static let ctlTxtProfileColorPickerGreen = StringAsset("ctl_txt_profile_color_picker_green")
    /// Spring grey
    internal static let ctlTxtProfileColorPickerGrey = StringAsset("ctl_txt_profile_color_picker_grey")
    /// It! Is! Pink!
    internal static let ctlTxtProfileColorPickerPink = StringAsset("ctl_txt_profile_color_picker_pink")
    /// Selected
    internal static let ctlTxtProfileColorPickerSelected = StringAsset("ctl_txt_profile_color_picker_selected")
    /// Sun dew
    internal static let ctlTxtProfileColorPickerYellow = StringAsset("ctl_txt_profile_color_picker_yellow")
    /// Connected
    internal static let ctlTxtProfileConnectionStatusConnected = StringAsset("ctl_txt_profile_connection_status_connected")
    /// Not connected
    internal static let ctlTxtProfileConnectionStatusDisconnected = StringAsset("ctl_txt_profile_connection_status_disconnected")
    /// Search box
    internal static let ctlTxtSearchBarFieldLabel = StringAsset("ctl_txt_search_bar_field_label")
    /// With direct referral, a prescription from a practice or hospital is filled directly at a pharmacy. Insured persons do not have to take any action and cannot intervene in the redemption process. 
    /// 
    ///  Direct referrals are listed in the e-prescription app to make your treatment more transparent for you.
    internal static let davTxtDirectAssignmentHint = StringAsset("dav_txt_direct_assignment_hint")
    /// What is a direct assignment?
    internal static let davTxtDirectAssignmentTitle = StringAsset("dav_txt_direct_assignment_title")
    /// Done
    internal static let dmcBtnClose = StringAsset("dmc_btn_close")
    /// Collection code
    internal static let dmcTxtCodeMultiple = StringAsset("dmc_txt_code_multiple")
    /// Single code
    internal static let dmcTxtCodeSingle = StringAsset("dmc_txt_code_single")
    /// %d medication(s)
    internal static func dmcTxtNumberMedicationsD(_ element1: Int) -> StringAsset {
        StringAsset("dmc_txt_number_medications_%d", arguments: [element1])
    }
    /// You have been given a prescription code via the e-prescription app with the following medications: %@
    internal static func dmcTxtShareMessage(_ element1: String) -> StringAsset {
        StringAsset("dmc_txt_share_message_%@", arguments: [element1])
    }
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
    /// The connection to the server was lost. Please sign in again.
    internal static let dtlTxtDeleteMissingTokenAlertMessage = StringAsset("dtl_txt_delete_missing_token_alert_message")
    /// Deletion failed
    internal static let dtlTxtDeleteMissingTokenAlertTitle = StringAsset("dtl_txt_delete_missing_token_alert_title")
    /// Cancel
    internal static let dtlTxtDeleteNo = StringAsset("dtl_txt_delete_no")
    /// Delete prescription and cost receipt
    internal static let dtlTxtDeleteWithChargeItemAlertTitle = StringAsset("dtl_txt_delete_with_charge_item__alert_title")
    /// If you delete the prescription, the associated expense receipt will also be deleted.
    internal static let dtlTxtDeleteWithChargeItemAlertMessage = StringAsset("dtl_txt_delete_with_charge_item_alert_message")
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
    /// Background colour
    internal static let editColorTxt = StringAsset("edit_color_txt")
    /// Edit profile picture
    internal static let editPictureTxt = StringAsset("edit_picture_txt")
    /// iOS App: Error report
    internal static let emailSubjectFallback = StringAsset("email_subject_fallback")
    /// Back
    internal static let eppBackButton = StringAsset("epp_back_button")
    /// Cancel
    internal static let eppBtnAlertAbort = StringAsset("epp_btn_alert_abort")
    /// camera
    internal static let eppBtnAlertCamera = StringAsset("epp_btn_alert_camera")
    /// Emoji
    internal static let eppBtnAlertEmoji = StringAsset("epp_btn_alert_emoji")
    /// Select photo
    internal static let eppBtnAlertLibrary = StringAsset("epp_btn_alert_library")
    /// Use
    internal static let eppBtnEmojiUse = StringAsset("epp_btn_emoji_use")
    /// Choose profile picture
    internal static let eppTxtAlertHeaderProfile = StringAsset("epp_txt_alert_header_profile")
    /// How would you like to continue?
    internal static let eppTxtAlertSubheaderChoose = StringAsset("epp_txt_alert_subheader_choose")
    /// Press here to create a new profile
    internal static let erpTxtTooltipsAddProfile = StringAsset("erp_txt_tooltips_add_profile")
    /// Long press to edit names
    internal static let erpTxtTooltipsProfileRename = StringAsset("erp_txt_tooltips_profile_rename")
    /// Tap here to scan prescriptions.
    internal static let erpTxtTooltipsScan = StringAsset("erp_txt_tooltips_scan")
    /// Cancel
    internal static let errBtnCancel = StringAsset("err_btn_cancel")
    /// Error numbers:
    internal static let errCodesPrefix = StringAsset("err_codes_prefix")
    /// For security reasons, the connection to the prescription server will be severed after six months. To access new prescriptions, you must log in again.
    internal static let errMessagePairingInvalid = StringAsset("err_message_pairing_invalid")
    /// Your biometrics have changed. For example, has a fingerprint been added? For security reasons, you must register again with your health card.
    internal static let errSpecificI10018Description = StringAsset("err_specific_i10018_description")
    /// Please try it again.
    internal static let errSpecificI10808Description = StringAsset("err_specific_i10808_description")
    /// Unfortunately that didn't work
    internal static let errSpecificI10808Title = StringAsset("err_specific_i10808_title")
    /// An error has occurred
    internal static let errTitleGeneric = StringAsset("err_title_generic")
    /// Re-login
    internal static let errTitleLoginNecessary = StringAsset("err_title_login_necessary")
    /// Re-login
    internal static let errTitlePairingInvalid = StringAsset("err_title_pairing_invalid")
    /// Error accessing the database
    internal static let errTxtDatabaseAccess = StringAsset("err_txt_database_access")
    /// Register
    internal static let erxBtnAlertLogin = StringAsset("erx_btn_alert_login")
    /// OK
    internal static let erxBtnAlertOk = StringAsset("erx_btn_alert_ok")
    /// Try again
    internal static let erxBtnAlertRetry = StringAsset("erx_btn_alert_retry")
    /// Redeem All
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
    /// Displayed
    internal static let erxTxtAuthored = StringAsset("erx_txt_authored")
    /// Assumed %@
    internal static func erxTxtClaimedAt(_ element1: String) -> StringAsset {
        StringAsset("erx_txt_claimed_at_%@", arguments: [element1])
    }
    /// Current
    internal static let erxTxtCurrent = StringAsset("erx_txt_current")
    /// Expired on %@
    internal static func erxTxtExpiredOn(_ element1: String) -> StringAsset {
        StringAsset("erx_txt_expired_on_%@", arguments: [element1])
    }
    /// Plural format key: "%#@variable_0@"
    internal static func erxTxtExpiresIn(_ element1: Int) -> StringAsset {
        StringAsset("erx_txt_expires_in", arguments: [element1])
    }
    /// Optimize your app experience by updating the app.
    internal static let erxTxtForcedUpdateAlertDescription = StringAsset("erx_txt_forced_update_alert_description")
    /// Maybe later
    internal static let erxTxtForcedUpdateAlertIgnore = StringAsset("erx_txt_forced_update_alert_ignore")
    /// New update available
    internal static let erxTxtForcedUpdateAlertTitle = StringAsset("erx_txt_forced_update_alert_title")
    /// Update now
    internal static let erxTxtForcedUpdateAlertUpdate = StringAsset("erx_txt_forced_update_alert_update")
    /// No longer valid
    internal static let erxTxtInvalid = StringAsset("erx_txt_invalid")
    /// Unknown medicine
    internal static let erxTxtMedicationPlaceholder = StringAsset("erx_txt_medication_placeholder")
    /// You do not have any current prescriptions
    internal static let erxTxtNoCurrentPrescriptions = StringAsset("erx_txt_no_current_prescriptions")
    /// You haven't redeemed any prescriptions yet
    internal static let erxTxtNotYetRedeemed = StringAsset("erx_txt_not_yet_redeemed")
    /// Prescription added successfully
    internal static let erxTxtPrescriptionAddedAlertTitle = StringAsset("erx_txt_prescription_added_alert_title")
    /// The prescription has already been imported.
    internal static let erxTxtPrescriptionDuplicateAlertMessage = StringAsset("erx_txt_prescription_duplicate_alert_message")
    /// Prescription not added
    internal static let erxTxtPrescriptionDuplicateAlertTitle = StringAsset("erx_txt_prescription_duplicate_alert_title")
    /// Redeemable from %@
    internal static func erxTxtRedeemAt(_ element1: String) -> StringAsset {
        StringAsset("erx_txt_redeem_at_%@", arguments: [element1])
    }
    /// Archive
    internal static let erxTxtRedeemed = StringAsset("erx_txt_redeemed")
    /// Loading ...
    internal static let erxTxtRefreshLoading = StringAsset("erx_txt_refresh_loading")
    /// Scanned: %@
    internal static func erxTxtScannedAt(_ element1: String) -> StringAsset {
        StringAsset("erx_txt_scanned_at_%@", arguments: [element1])
    }
    /// No reimbursement of costs
    internal static let erxTxtSelfPayer = StringAsset("erx_txt_self_payer")
    /// Sent %@
    internal static func erxTxtSentAt(_ element1: String) -> StringAsset {
        StringAsset("erx_txt_sent_at_%@", arguments: [element1])
    }
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
    /// Exit demo mode to be able to use the function.
    internal static let idpErrNotAvailableInDemoModeRecovery = StringAsset("idp_err_not_available_in_demo_mode_recovery")
    /// Not available in demo mode
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
    /// Metered-dose inhaler
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
    /// Solution for injection in a pre-filled syringe
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
    /// Powder for a concentrate for the preparation of an infusion solution Powder for the preparation of an oral solution
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
    /// prescription archive
    internal static let mainBtnArchivedPresc = StringAsset("main_btn_archived_presc")
    /// Enable
    internal static let mainBtnConsentDrawerActivate = StringAsset("main_btn_consent_drawer_activate")
    /// Maybe later
    internal static let mainBtnConsentDrawerCancel = StringAsset("main_btn_consent_drawer_cancel")
    /// Register
    internal static let mainBtnLogin = StringAsset("main_btn_login")
    /// Redeem
    internal static let mainBtnRedeem = StringAsset("main_btn_redeem")
    /// Update
    internal static let mainBtnRefresh = StringAsset("main_btn_refresh")
    /// ↓ Drag the screen down to update.
    internal static let mainEmptyTxtConnected = StringAsset("main_empty_txt_connected")
    /// Sign up to receive prescriptions automatically.
    internal static let mainEmptyTxtDisconnected = StringAsset("main_empty_txt_disconnected")
    /// No prescriptions
    internal static let mainEmptyTxtTitle = StringAsset("main_empty_txt_title")
    /// Note: You will no longer receive your cost receipts as a printout at the pharmacy.
    internal static let mainTxtConsentDrawerMessage = StringAsset("main_txt_consent_drawer_message")
    /// Receive cost receipts digitally
    internal static let mainTxtConsentDrawerTitle = StringAsset("main_txt_consent_drawer_title")
    /// Please login
    internal static let mainTxtConsentServiceErrorNotLoggedInMessage = StringAsset("main_txt_consent_service_error_not_logged_in_message")
    /// Not logged in
    internal static let mainTxtConsentServiceErrorNotLoggedInTitle = StringAsset("main_txt_consent_service_error_not_logged_in_title")
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
    /// Status: Disconnected from the prescription server
    internal static let mainTxtProfileStatusOffline = StringAsset("main_txt_profile_status_offline")
    /// Status: Profile logged in
    internal static let mainTxtProfileStatusOnline = StringAsset("main_txt_profile_status_online")
    /// Remind me
    internal static let medReminderBtnActivationToggle = StringAsset("med_reminder_btn_activation_toggle")
    /// To my medication reminders
    internal static let medReminderBtnOneDaySummaryGoToRemindersOverviewButton = StringAsset("med_reminder_btn_one_day_summary_go_to_reminders_overview_button")
    /// Last day
    internal static let medReminderBtnRepetitionDatepickerEnd = StringAsset("med_reminder_btn_repetition_datepicker_end")
    /// First day
    internal static let medReminderBtnRepetitionDatepickerStart = StringAsset("med_reminder_btn_repetition_datepicker_start")
    /// Save
    internal static let medReminderBtnSaveSchedule = StringAsset("med_reminder_btn_save_schedule")
    /// Add time
    internal static let medReminderBtnTimeScheduleAddEntry = StringAsset("med_reminder_btn_time_schedule_add_entry")
    /// Instructions for use
    internal static let medReminderTxtDosageInstructionSubtitle = StringAsset("med_reminder_txt_dosage_instruction_subtitle")
    /// No medication reminders
    internal static let medReminderTxtListEmptyListHeadline = StringAsset("med_reminder_txt_list_empty_list_headline")
    /// You can set pill reminders for your prescriptions.
    internal static let medReminderTxtListEmptyListSubheadline = StringAsset("med_reminder_txt_list_empty_list_subheadline")
    /// On
    internal static let medReminderTxtListPlanActive = StringAsset("med_reminder_txt_list_plan_active")
    /// Off
    internal static let medReminderTxtListPlanInactive = StringAsset("med_reminder_txt_list_plan_inactive")
    /// Medication reminder
    internal static let medReminderTxtNotificationContentTitle = StringAsset("med_reminder_txt_notification_content_title")
    /// You have no reminders to take your medication today.
    internal static let medReminderTxtOneDaySummaryEmptyEventSubtitle = StringAsset("med_reminder_txt_one_day_summary_empty_event_subtitle")
    /// No active reminders
    internal static let medReminderTxtOneDaySummaryEmptyEventTitle = StringAsset("med_reminder_txt_one_day_summary_empty_event_title")
    /// At evening
    internal static let medReminderTxtOneDaySummaryInTheEvening = StringAsset("med_reminder_txt_one_day_summary_in_the_evening")
    /// In the morning
    internal static let medReminderTxtOneDaySummaryInTheMorning = StringAsset("med_reminder_txt_one_day_summary_in_the_morning")
    /// At night
    internal static let medReminderTxtOneDaySummaryInTheNight = StringAsset("med_reminder_txt_one_day_summary_in_the_night")
    /// Midday
    internal static let medReminderTxtOneDaySummaryInTheNoon = StringAsset("med_reminder_txt_one_day_summary_in_the_noon")
    /// Medication reminder
    internal static let medReminderTxtOneDaySummaryTitle = StringAsset("med_reminder_txt_one_day_summary_title")
    /// dose
    internal static let medReminderTxtParserMedicationSchedulePlaceholderAmount = StringAsset("med_reminder_txt_parser_medication_schedule_placeholder_amount")
    /// Medicine
    internal static let medReminderTxtParserMedicationSchedulePlaceholderTitle = StringAsset("med_reminder_txt_parser_medication_schedule_placeholder_title")
    /// until %@
    internal static func medReminderTxtRepetitionFiniteTill(_ element1: String) -> StringAsset {
        StringAsset("med_reminder_txt_repetition_finite_till_%@", arguments: [element1])
    }
    /// Repeat
    internal static let medReminderTxtRepetitionTitle = StringAsset("med_reminder_txt_repetition_title")
    /// Limited
    internal static let medReminderTxtRepetitionTypeFinite = StringAsset("med_reminder_txt_repetition_type_finite")
    /// Unlimited
    internal static let medReminderTxtRepetitionTypeInfinite = StringAsset("med_reminder_txt_repetition_type_infinite")
    /// Time
    internal static let medReminderTxtScheduleSectionHeader = StringAsset("med_reminder_txt_schedule_section_header")
    /// Quantity
    internal static let medReminderTxtTimeScheduleAmountPlaceholder = StringAsset("med_reminder_txt_time_schedule_amount_placeholder")
    /// dosage
    internal static let medReminderTxtTimeScheduleDosageLabel = StringAsset("med_reminder_txt_time_schedule_dosage_label")
    /// Medication reminder
    internal static let medReminderTxtTitle = StringAsset("med_reminder_txt_title")
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
    /// Please contact your health insurance company via the usual channels.
    internal static let oderEgkContactNoSubtitle = StringAsset("oder_egk_contact_no_subtitle")
    /// Contact is not possible via this app
    internal static let oderEgkContactNoTitle = StringAsset("oder_egk_contact_no_title")
    /// Your insurance company offers the following contact options
    internal static let oderEgkContactSubtitle = StringAsset("oder_egk_contact_subtitle")
    /// How would you like to contact your insurance company?
    internal static let oderEgkContactTitle = StringAsset("oder_egk_contact_title")
    /// Connection interrupted
    internal static let ohcTxtNfcErrorInvalidatedDescription = StringAsset("ohc_txt_nfc_error_invalidated_description")
    /// The NFC connection was lost unexpectedly, please try again.
    internal static let ohcTxtNfcErrorInvalidatedRecovery = StringAsset("ohc_txt_nfc_error_invalidated_recovery")
    /// Card not found
    internal static let ohcTxtNfcErrorSessionTimeoutDescription = StringAsset("ohc_txt_nfc_error_session_timeout_description")
    /// Place the card on top of the display. A weak antenna in your card can cause problems. If this happens repeatedly, report your card to us.
    internal static let ohcTxtNfcErrorSessionTimeoutRecovery = StringAsset("ohc_txt_nfc_error_session_timeout_recovery")
    /// Connection to card lost
    internal static let ohcTxtNfcErrorTagLostDescription = StringAsset("ohc_txt_nfc_error_tag_lost_description")
    /// Please try it again. Hold the card as still as possible until a success message appears.
    internal static let ohcTxtNfcErrorTagLostRecovery = StringAsset("ohc_txt_nfc_error_tag_lost_recovery")
    /// NFC not available
    internal static let ohcTxtNfcErrorUnsupportedDescription = StringAsset("ohc_txt_nfc_error_unsupported_description")
    /// Your device's NFC reader is unavailable.
    internal static let ohcTxtNfcErrorUnsupportedRecovery = StringAsset("ohc_txt_nfc_error_unsupported_recovery")
    /// Allow
    internal static let onbAnaAlertAccept = StringAsset("onb_ana_alert_accept")
    /// Do not allow
    internal static let onbAnaAlertDeny = StringAsset("onb_ana_alert_deny")
    /// Your data will be used for product improvements and will not be passed on to third parties.
    internal static let onbAnaAlertMessage = StringAsset("onb_ana_alert_message")
    /// Do you allow E-Prescription to analyze your usage behavior anonymously?
    internal static let onbAnaAlertTitle = StringAsset("onb_ana_alert_title")
    /// Next
    internal static let onbAnaBtnNext = StringAsset("onb_ana_btn_next")
    /// Detect errors and crashes.
    internal static let onbAnaTxtCrash = StringAsset("onb_ana_Txt_crash")
    /// We will:
    internal static let onbAnaTxtHeader = StringAsset("onb_ana_txt_header")
    /// Help us make this app better
    internal static let onbAnaTxtTitle = StringAsset("onb_ana_txt_title")
    /// Improve usability.
    internal static let onbAnaTxtUsability = StringAsset("onb_ana_txt_usability")
    /// All data is of course collected anonymously.
    internal static let onbAnaTxtAnonymouse = StringAsset("onb_anaTxt_anonymouse")
    /// You can modify this decision in the system settings at any time
    internal static let onbAnaTxtChangeable = StringAsset("onb_anaTxt_changeable")
    /// Save
    internal static let onbAuthBtnPasswordSave = StringAsset("onb_auth_btn_password_save")
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
    /// Privacy & Use
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
    /// Profile 1
    internal static let onbProfileName = StringAsset("onb_profile_name")
    /// Digital. Fast. Safe.
    internal static let onbStrTxtSubtitle = StringAsset("onb_str_txt_subtitle")
    /// E-prescription
    internal static let onbStrTxtTitle = StringAsset("onb_str_txt_title")
    /// Privacy policy
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
    /// I have read and accept the privacy policy and terms of use.
    internal static let onbLegBtnAccept = StringAsset("onbLegBtnAccept")
    /// Show cost receipt
    internal static let ordDetailBtnChargeItem = StringAsset("ord_detail_btn_charge_item")
    /// Report error
    internal static let ordDetailBtnError = StringAsset("ord_detail_btn_error")
    /// Link to your pharmacy
    internal static let ordDetailBtnLink = StringAsset("ord_detail_btn_link")
    /// Show pickup code
    internal static let ordDetailBtnOnPremise = StringAsset("ord_detail_btn_onPremise")
    /// Show shopping cart link
    internal static let ordDetailBtnShipment = StringAsset("ord_detail_btn_shipment")
    /// Unfortunately, your pharmacy's message was empty. Please contact your pharmacy.
    internal static let ordDetailMsgsTxtEmpty = StringAsset("ord_detail_msgs_txt_empty")
    /// Shopping cart is ready
    internal static let ordDetailSheetTitle = StringAsset("ord_detail_sheet_title")
    /// Receive pickup code
    internal static let ordDetailSheetTitleOnPremise = StringAsset("ord_detail_sheet_title_on_premise")
    /// Shopping cart is ready
    internal static let ordDetailSheetTitleShipment = StringAsset("ord_detail_sheet_title_shipment")
    /// Open shopping cart
    internal static let ordDetailShipmentLinkBtn = StringAsset("ord_detail_shipment_link_btn")
    /// Please go to the pharmacy website to complete the order.
    internal static let ordDetailShipmentLinkText = StringAsset("ord_detail_shipment_link_text")
    /// %@ sent to %@ . Some pharmacies do not yet have a digital response option. If you do not receive a response by tomorrow, please call as a precaution.
    internal static func ordDetailTxtSendTo(_ element1: String, _ element2: String) -> StringAsset {
        StringAsset("ord_detail_txt_%@_send_to_%@", arguments: [element1, element2])
    }
    /// You have received a receipt for the cost of your medication %@ .
    internal static func ordDetailTxtChargeItem(_ element1: String) -> StringAsset {
        StringAsset("ord_detail_txt_charge_item%@", arguments: [element1])
    }
    /// Contact options
    internal static let ordDetailTxtContact = StringAsset("ord_detail_txt_contact")
    /// Write email
    internal static let ordDetailTxtContactEmail = StringAsset("ord_detail_txt_contact_email")
    /// Show route
    internal static let ordDetailTxtContactMap = StringAsset("ord_detail_txt_contact_map")
    /// Call
    internal static let ordDetailTxtContactPhone = StringAsset("ord_detail_txt_contact_phone")
    /// app-fehlermeldung@ti-support.de
    internal static let ordDetailTxtEmailSupport = StringAsset("ord_detail_txt_email_support")
    /// A pharmacy has sent a message in an incorrect format.
    internal static let ordDetailTxtError = StringAsset("ord_detail_txt_error")
    /// Defective message received
    internal static let ordDetailTxtErrorTitle = StringAsset("ord_detail_txt_error_title")
    /// Course
    internal static let ordDetailTxtHistory = StringAsset("ord_detail_txt_history")
    /// Dear Service Team, I received a message from a pharmacy. Unfortunately, however, I could not pass the message on to my user because I did not understand it. Please check what happened here and help us. Thank you very much! The e-prescription app
    internal static let ordDetailTxtMailBody1 = StringAsset("ord_detail_txt_mail_body1")
    /// You are sending us this information for purposes of troubleshooting. Please note that your email address and any name you include will also be transferred. If you do not wish to transfer this information either in full or in part, please remove it from this email. 
    /// 
    /// All data will only be stored or processed by gematik GmbH or its appointed companies in order to deal with this error message. Deletion takes place automatically a maximum of 180 days after the ticket has been processed. We will use your email address exclusively to contact you regarding this error message. If you have any questions, or require an earlier deletion, you can contact the data protection representative responsible for the e-prescription system. You can find further information in the menu below the entry for data protection in the e-prescription app.
    internal static let ordDetailTxtMailBody2 = StringAsset("ord_detail_txt_mail_body2")
    /// Error 40 42 67336
    internal static let ordDetailTxtMailError = StringAsset("ord_detail_txt_mail_error")
    /// Error message from the e-prescription app
    internal static let ordDetailTxtMailSubject = StringAsset("ord_detail_txt_mail_subject")
    /// The email app could not be opened. Please use the hotline
    internal static let ordDetailTxtOpenMailError = StringAsset("ord_detail_txt_open_mail_error")
    /// Error
    internal static let ordDetailTxtOpenMailErrorTitle = StringAsset("ord_detail_txt_open_mail_error_title")
    /// Order
    internal static let ordDetailTxtOrders = StringAsset("ord_detail_txt_orders")
    /// Plural format key: "%#@variable_0@"
    internal static func ordDetailTxtPresc(_ element1: Int) -> StringAsset {
        StringAsset("ord_detail_txt_presc", arguments: [element1])
    }
    /// Order overview
    internal static let ordDetailTxtTitle = StringAsset("ord_detail_txt_title")
    /// Plural format key: "%#@variable_0@"
    internal static func ordListStatusCount(_ element1: Int) -> StringAsset {
        StringAsset("ord_list_status_count", arguments: [element1])
    }
    /// New
    internal static let ordListStatusNew = StringAsset("ord_list_status_new")
    /// You haven't redeemed any prescriptions yet
    internal static let ordTxtEmptyListMessage = StringAsset("ord_txt_empty_list_message")
    /// No orders
    internal static let ordTxtEmptyListTitle = StringAsset("ord_txt_empty_list_title")
    /// Unknown pharmacy
    internal static let ordTxtNoPharmacyName = StringAsset("ord_txt_no_pharmacy_name")
    /// Orders
    internal static let ordTxtTitle = StringAsset("ord_txt_title")
    /// How to identify an NFC-enabled medical card
    internal static let orderEgkBtnInfoButton = StringAsset("order_egk_btn_info_button")
    /// PIN
    internal static let orderEgkPin = StringAsset("order_egk_pin")
    /// PIN and health card
    internal static let orderEgkPinCard = StringAsset("order_egk_pin_card")
    /// For this app you need a card and an associated PIN.
    internal static let orderEgkServiceSubtitle = StringAsset("order_egk_service_subtitle")
    /// What would you like to apply for?
    internal static let orderEgkServiceTitle = StringAsset("order_egk_service_title")
    /// Email
    internal static let orderEgkTxtContactOptionMail = StringAsset("order_egk_txt_contact_option_mail")
    /// Phone
    internal static let orderEgkTxtContactOptionTelephone = StringAsset("order_egk_txt_contact_option_telephone")
    /// Website
    internal static let orderEgkTxtContactOptionWeb = StringAsset("order_egk_txt_contact_option_web")
    /// You can use an NFC-enabled medical card and the associated PIN to log into this app.
    internal static let orderEgkTxtDescription1 = StringAsset("order_egk_txt_description_1")
    /// You can obtain one free of charge from your health insurance company. You need to provide an official form of identification as proof of identity.
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
    /// Search for health insurance
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
    /// Courier
    internal static let phaDetailBtnDelivery = StringAsset("pha_detail_btn_delivery")
    /// Find out more
    internal static let phaDetailBtnFooter = StringAsset("pha_detail_btn_footer")
    /// Request courier service
    internal static let phaDetailBtnHealthcareService = StringAsset("pha_detail_btn_healthcare_service")
    /// Reserve for collection
    internal static let phaDetailBtnLocation = StringAsset("pha_detail_btn_location")
    /// Redeem only possible after registration
    internal static let phaDetailBtnLoginNote = StringAsset("pha_detail_btn_login_note")
    /// Write email
    internal static let phaDetailBtnOpenMail = StringAsset("pha_detail_btn_open_mail")
    /// Route here
    internal static let phaDetailBtnOpenMap = StringAsset("pha_detail_btn_open_map")
    /// Call
    internal static let phaDetailBtnOpenPhone = StringAsset("pha_detail_btn_open_phone")
    /// Delivery by mail order
    internal static let phaDetailBtnOrganization = StringAsset("pha_detail_btn_organization")
    /// pick up
    internal static let phaDetailBtnPickup = StringAsset("pha_detail_btn_pickup")
    /// Shipment
    internal static let phaDetailBtnShipment = StringAsset("pha_detail_btn_shipment")
    /// Contact
    internal static let phaDetailContact = StringAsset("pha_detail_contact")
    /// You cannot yet send e-prescriptions to this pharmacy.
    internal static let phaDetailHintNotErxReadyMessage = StringAsset("pha_detail_hint_not_erx_ready_message")
    /// Pharmacist stocks medicine
    internal static let phaDetailHintNotErxReadyPic = StringAsset("pha_detail_hint_not_erx_ready_pic")
    /// Redeem on site only
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
    /// You have no prescriptions to redeem.
    internal static let phaDetailTxtNoPrescriptionToast = StringAsset("pha_detail_txt_no_prescription_toast")
    /// Today
    internal static let phaDetailTxtOpenHourToday = StringAsset("pha_detail_txt_open_hour_today")
    /// Tomorrow
    internal static let phaDetailTxtOpenHourTomorrow = StringAsset("pha_detail_txt_open_hour_tomorrow")
    /// Pharmacy
    internal static let phaDetailTxtSubtitleFallback = StringAsset("pha_detail_txt_subtitle_fallback")
    /// Details
    internal static let phaDetailTxtTitle = StringAsset("pha_detail_txt_title")
    /// Website
    internal static let phaDetailWeb = StringAsset("pha_detail_web")
    /// Try again and possibly select a different pharmacy. If the error persists, please inform support.
    internal static let phaRedeemAlertMessageFailure = StringAsset("pha_redeem_alert_message_failure")
    /// We need your telephone number for any questions.
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
    /// Change
    internal static let phaRedeemBtnChangePharmacy = StringAsset("pha_redeem_btn_change_pharmacy")
    /// Change
    internal static let phaRedeemBtnChangePrescription = StringAsset("pha_redeem_btn_change_prescription")
    /// Cancel order
    internal static let phaRedeemBtnPrescriptionAlreadyRedeemedAlertDismiss = StringAsset("pha_redeem_btn_prescription_already_redeemed_alert_dismiss")
    /// Continue without this prescription
    internal static let phaRedeemBtnPrescriptionAlreadyRedeemedAlertProceedWithout = StringAsset("pha_redeem_btn_prescription_already_redeemed_alert_proceed_without")
    /// Redeem
    internal static let phaRedeemBtnRedeem = StringAsset("pha_redeem_btn_redeem")
    /// Your prescription will be sent to this pharmacy. It is not possible to redeem your prescription at another pharmacy.
    internal static let phaRedeemBtnRedeemFootnote = StringAsset("pha_redeem_btn_redeem_footnote")
    /// Select pharmacy
    internal static let phaRedeemBtnSelectPharmacy = StringAsset("pha_redeem_btn_select_pharmacy")
    /// Select prescriptions
    internal static let phaRedeemBtnSelectPrescription = StringAsset("pha_redeem_btn_select_prescription")
    /// ⚕︎ Redeem
    internal static let phaRedeemTitle = StringAsset("pha_redeem_title")
    /// Delivery address
    internal static let phaRedeemTxtAddress = StringAsset("pha_redeem_txt_address")
    /// My order
    internal static let phaRedeemTxtHeader = StringAsset("pha_redeem_txt_header")
    /// Internal error ( %@ )
    internal static func phaRedeemTxtInternalErr(_ element1: String) -> StringAsset {
        StringAsset("pha_redeem_txt_internal_err_%@", arguments: [element1])
    }
    /// Please inform support if the error persists.
    internal static let phaRedeemTxtInternalErrRecovery = StringAsset("pha_redeem_txt_internal_err_recovery")
    /// We require your contact details in order for the pharmacy to be able to advise you and let you know the current status of your order.
    internal static let phaRedeemTxtMissingAddress = StringAsset("pha_redeem_txt_missing_address")
    /// Your telephone number is required
    internal static let phaRedeemTxtMissingPhone = StringAsset("pha_redeem_txt_missing_phone")
    /// To do this you must log in again. Please click Update on the home page.
    internal static let phaRedeemTxtNotLoggedIn = StringAsset("pha_redeem_txt_not_logged_in")
    /// Registration has expired
    internal static let phaRedeemTxtNotLoggedInTitle = StringAsset("pha_redeem_txt_not_logged_in_title")
    /// Pharmacy
    internal static let phaRedeemTxtPharmacyHeader = StringAsset("pha_redeem_txt_pharmacy_header")
    /// Prescriptions
    internal static let phaRedeemTxtPrescription = StringAsset("pha_redeem_txt_prescription")
    /// Plural format key: "%#@variable_0@"
    internal static func phaRedeemTxtPrescriptionAlreadyRedeemedError(_ element1: Int) -> StringAsset {
        StringAsset("pha_redeem_txt_prescription_already_redeemed_error", arguments: [element1])
    }
    /// Plural format key: "%#@variable_0@"
    internal static func phaRedeemTxtPrescriptionAlreadyRedeemedErrorSuggestionFormat(_ element1: Int) -> StringAsset {
        StringAsset("pha_redeem_txt_prescription_already_redeemed_error_suggestion_format", arguments: [element1])
    }
    /// Prescriptions
    internal static let phaRedeemTxtPrescriptionHeader = StringAsset("pha_redeem_txt_prescription_header")
    /// Substitutes are permitted. You may be given an alternative due to the legal requirements of your health insurance.
    internal static let phaRedeemTxtPrescriptionSub = StringAsset("pha_redeem_txt_prescription_sub")
    /// Which pharmacy can fill your prescription?
    internal static let phaRedeemTxtSelectPharamcy = StringAsset("pha_redeem_txt_select_pharamcy")
    /// Which prescriptions would you like to redeem?
    internal static let phaRedeemTxtSelectPrescription = StringAsset("pha_redeem_txt_select_prescription")
    /// Save
    internal static let phaRedeemTxtSelectedPrescriptionSave = StringAsset("pha_redeem_txt_selected_prescription_save")
    /// Commit to redeeming the following prescriptions at the %@?
    internal static func phaRedeemTxtSubtitle(_ element1: String) -> StringAsset {
        StringAsset("pha_redeem_txt_subtitle_%@", arguments: [element1])
    }
    /// courier service
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
    /// Map view
    internal static let phaSearchMapAccessibilityLabel = StringAsset("pha_search_map_accessibility_label")
    /// Pharmacy
    internal static let phaSearchMapAnnotation = StringAsset("pha_search_map_annotation")
    /// Cancel
    internal static let phaSearchMapBtnErrorCancel = StringAsset("pha_search_map_btn_Error_cancel")
    /// Search here
    internal static let phaSearchMapBtnSearchHere = StringAsset("pha_Search_Map_Btn_search_here")
    /// Close to me
    internal static let phaSearchMapHeader = StringAsset("pha_search_map_header")
    /// Pharmacies
    internal static let phaSearchMapTxtClusterHeader = StringAsset("pha_search_map_txt_cluster_header")
    /// Closed
    internal static let phaSearchTxtClosed = StringAsset("pha_search_txt_closed")
    /// Closing soon
    internal static let phaSearchTxtClosingSoon = StringAsset("pha_search_txt_closing_soon")
    /// Server not responding
    internal static let phaSearchTxtErrorNoServerResponseHeadline = StringAsset("pha_search_txt_error_no_server_response_headline")
    /// Please try again in a few minutes.
    internal static let phaSearchTxtErrorNoServerResponseSubheadline = StringAsset("pha_search_txt_error_no_server_response_subheadline")
    /// Close to me
    internal static let phaSearchTxtFilterCurrentLocation = StringAsset("pha_search_txt_filter_current_location")
    /// courier service
    internal static let phaSearchTxtFilterDelivery = StringAsset("pha_search_txt_filter_delivery")
    /// Open now
    internal static let phaSearchTxtFilterOpen = StringAsset("pha_search_txt_filter_open")
    /// Ready for the e-prescription
    internal static let phaSearchTxtFilterReady = StringAsset("pha_search_txt_filter_ready")
    /// Mail order
    internal static let phaSearchTxtFilterShipment = StringAsset("pha_search_txt_filter_shipment")
    /// Start the search by tapping Open on the keypad
    internal static let phaSearchTxtHintStartSearch = StringAsset("pha_search_txt_hint_start_search")
    /// Last searched
    internal static let phaSearchTxtHistoryTitle = StringAsset("pha_search_txt_history_title")
    /// Pharmacy not found
    internal static let phaSearchTxtLocalPharmErrNotFound = StringAsset("pha_search_txt_local_pharm_err_not_found")
    /// Please add again via pharmacy search.
    internal static let phaSearchTxtLocalPharmErrNotFoundRecovery = StringAsset("pha_search_txt_local_pharm_err_not_found_recovery")
    /// My pharmacies
    internal static let phaSearchTxtLocalPharmTitle = StringAsset("pha_search_txt_local_pharm_title")
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
    /// courier service
    internal static let phaSearchTxtQuickFilterDelivery = StringAsset("pha_search_txt_quick_filter_delivery")
    /// Currently open and near me
    internal static let phaSearchTxtQuickFilterNearbyAndOpen = StringAsset("pha_search_txt_quick_filter_nearby_and_open")
    /// Filter by ...
    internal static let phaSearchTxtQuickFilterOpenFilters = StringAsset("pha_search_txt_quick_filter_open_filters")
    /// Filters
    internal static let phaSearchTxtQuickFilterSectionTitle = StringAsset("pha_search_txt_quick_filter_section_title")
    /// Mail order
    internal static let phaSearchTxtQuickFilterShipment = StringAsset("pha_search_txt_quick_filter_shipment")
    /// Search
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
    /// child
    internal static let profileTxtBaby = StringAsset("profile_txt_baby")
    /// Blind man
    internal static let profileTxtBlindMan = StringAsset("profile_txt_blind_man")
    /// Boy with a map
    internal static let profileTxtBoy = StringAsset("profile_txt_boy")
    /// Developer
    internal static let profileTxtDeveloper = StringAsset("profile_txt_developer")
    /// Doctor
    internal static let profileTxtDoctor = StringAsset("profile_txt_doctor")
    /// Doctor
    internal static let profileTxtDoctorW = StringAsset("profile_txt_doctorW")
    /// Man with map
    internal static let profileTxtMann = StringAsset("profile_txt_mann")
    /// None selected
    internal static let profileTxtNone = StringAsset("profile_txt_none")
    /// Older doctor
    internal static let profileTxtOldDoctor = StringAsset("profile_txt_old_Doctor")
    /// Old man
    internal static let profileTxtOldMan = StringAsset("profile_txt_old_man")
    /// Older woman
    internal static let profileTxtOldWoman = StringAsset("profile_txt_old_woman")
    /// Pharmacist
    internal static let profileTxtPharmacist = StringAsset("profile_txt_pharmacist")
    /// Pharmacist with cell phone
    internal static let profileTxtPharmacistHandy = StringAsset("profile_txt_pharmacist_handy")
    /// Woman on cell phone
    internal static let profileTxtWoman = StringAsset("profile_txt_woman")
    /// prescription archive
    internal static let prscArchTxtTitle = StringAsset("prsc_arch_txt_title")
    /// This prescription will be redeemed for you as part of a treatment and cannot be deleted during this treatment.
    internal static let prscDeleteNoteDirectAssignment = StringAsset("prsc_delete_note_direct_assignment")
    /// Deletion not possible
    internal static let prscDtlAlertTitleDeleteNotAllowed = StringAsset("prsc_dtl_alert_title_delete_not_allowed")
    /// Delete
    internal static let prscDtlBtnDelete = StringAsset("prsc_dtl_btn_delete")
    /// Direct assignment
    internal static let prscDtlBtnDirectAssignment = StringAsset("prsc_dtl_btn_direct_assignment")
    /// Open gesund.bund.de
    internal static let prscDtlBtnFooter = StringAsset("prsc_dtl_btn_footer")
    /// Medication reminder
    internal static let prscDtlBtnMedicationReminder = StringAsset("prsc_dtl_btn_medication_reminder")
    /// Enable
    internal static let prscDtlBtnPkvHintActivate = StringAsset("prsc_dtl_btn_pkv_hint_activate")
    /// Cost receipt
    internal static let prscDtlBtnPkvInvoice = StringAsset("prsc_dtl_btn_pkv_invoice")
    /// Send to pharmacy
    internal static let prscDtlBtnRedeem = StringAsset("prsc_dtl_btn_redeem")
    /// No reimbursement of costs
    internal static let prscDtlBtnSelfPayer = StringAsset("prsc_dtl_btn_self_payer")
    /// Split
    internal static let prscDtlBtnShare = StringAsset("prsc_dtl_btn_share")
    /// Split
    internal static let prscDtlBtnShareTitle = StringAsset("prsc_dtl_btn_share_title")
    /// Show code
    internal static let prscDtlBtnShowMatrixCode = StringAsset("prsc_dtl_btn_show_matrix_code")
    /// Technical information
    internal static let prscDtlBtnTechnicalInformations = StringAsset("prsc_dtl_btn_technical_informations")
    /// Accident at work
    internal static let prscDtlBtnWorkRelatedAccident = StringAsset("prsc_dtl_btn_work_related_accident")
    /// You are exempt from paying a co-payment for this medication. Your health insurance company will cover the cost of the medication.
    internal static let prscDtlDrCoPaymentNoDescription = StringAsset("prsc_dtl_dr_co_payment_no_description")
    /// Exempt from additional payment
    internal static let prscDtlDrCoPaymentNoTitle = StringAsset("prsc_dtl_dr_co_payment_no_title")
    /// This drug was prescribed as part of an artificial insemination (according to §27 a SGB V). Your health insurance will cover 50 %% of the cost of this medication. You have to pay the other 50 %% to the pharmacy yourself. 
    /// 
    ///  In some cases, your share of the costs will be covered by your health insurance company as a statutory benefit.
    internal static let prscDtlDrCoPaymentPartialDescription = StringAsset("prsc_dtl_dr_co_payment_partial_description")
    /// Some medications require additional payment
    internal static let prscDtlDrCoPaymentPartialTitle = StringAsset("prsc_dtl_dr_co_payment_partial_title")
    /// People with statutory insurance usually pay a maximum of 10 euros for prescription drugs. Higher fees may apply if a drug from a specific manufacturer is requested that is not covered by a discount contract with the health insurance company ("desired drug"). 
    /// 
    ///  Children and young people under 18 are exempt from additional payments. 
    /// 
    ///  If prescriptions are redeemed later than 28 days after they are issued, the costs must be borne in full by the patient. 
    /// 
    ///  If medication expenses are high over the year, an exemption from co-payment can be requested from the health insurance company
    internal static let prscDtlDrCoPaymentYesDescription = StringAsset("prsc_dtl_dr_co_payment_yes_description")
    /// Medications subject to co-payment
    internal static let prscDtlDrCoPaymentYesTitle = StringAsset("prsc_dtl_dr_co_payment_yes_title")
    /// If a prescription is redeemed between 8 p.m. and 6 a.m. or on Sundays and public holidays, an additional fee of 2.50 euros may be charged.
    internal static let prscDtlDrEmergencyServiceFeeInfoDescription = StringAsset("prsc_dtl_dr_emergency_service_fee_info_description")
    /// Emergency service fee
    internal static let prscDtlDrEmergencyServiceFeeInfoTitle = StringAsset("prsc_dtl_dr_emergency_service_fee_info_title")
    /// Not all information is presented correctly in this prescription. However, you can still redeem it in your pharmacy.
    internal static let prscDtlDrErrorInfoDescription = StringAsset("prsc_dtl_dr_error_info_description")
    /// Prescription incorrect
    internal static let prscDtlDrErrorInfoTitle = StringAsset("prsc_dtl_dr_error_info_title")
    /// Your doctor has determined that you should receive the prescribed medication. The pharmacy should not make any exchanges based on a discount agreement (“Aut idem”).
    internal static let prscDtlDrNoSubstitutionInfoDescribtion = StringAsset("prsc_dtl_dr_no_substitution_info_describtion")
    /// No replacement product possible
    internal static let prscDtlDrNoSubstitutionInfoTitle = StringAsset("prsc_dtl_dr_no_substitution_info_title")
    /// During this period, you can redeem your prescription in any pharmacy with a maximum additional payment of €10.
    internal static let prscDtlDrPrescriptionValidityInfoAcceptDateDescription = StringAsset("prsc_dtl_dr_prescription_validity_info_accept_date_description")
    /// You can still fill the prescription at a pharmacy within this period, but you will have to pay the entire purchase price for the medication yourself. Alternatively, you can ask your practice to have the prescription reissued.
    internal static let prscDtlDrPrescriptionValidityInfoExpireDateDescription = StringAsset("prsc_dtl_dr_prescription_validity_info_expire_date_description")
    /// How long is this prescription valid for?
    internal static let prscDtlDrPrescriptionValidityInfoTitle = StringAsset("prsc_dtl_dr_prescription_validity_info_title")
    /// Prescriptions imported from a hardcopy cannot display personal or medical information for security reasons. 
    /// 
    ///  Log in to this app with health card or insurance app to view all the information contained in the prescription.
    internal static let prscDtlDrScannedPrescriptionInfoDescription = StringAsset("prsc_dtl_dr_scanned_prescription_info_description")
    /// Scanned prescription
    internal static let prscDtlDrScannedPrescriptionInfoTitle = StringAsset("prsc_dtl_dr_scanned_prescription_info_title")
    /// Pharmacists are obliged to give priority to dispensing medicines for which the patient's health insurance company has concluded a discount agreement with drug manufacturers. This only does not apply if the doctor excludes “Aut idem” on the prescription, which is not the case with your prescription.
    internal static let prscDtlDrSubstitutionInfoDescription = StringAsset("prsc_dtl_dr_substitution_info_description")
    /// Substitute medication possible
    internal static let prscDtlDrSubstitutionInfoTitle = StringAsset("prsc_dtl_dr_substitution_info_title")
    /// No reimbursement of costs
    internal static let prscDtlDrawerSelfPayerInfoHeader = StringAsset("prsc_dtl_drawer_self_payer_info_header")
    /// As a rule, health insurance does not cover the costs of this prescription. As a patient, you are therefore responsible for paying the full amount. Whether the costs will be reimbursed as part of supplementary insurance or statutory benefits must be checked individually.
    internal static let prscDtlDrawerSelfPayerInfoMessage = StringAsset("prsc_dtl_drawer_self_payer_info_message")
    /// Open gesund.bund.de
    internal static let prscDtlHntGesundBundDeBtn = StringAsset("prsc_dtl_hnt_gesund_bund_de_btn")
    /// You can find professionally verified information on illnesses, ICD codes and issues to do with prevention and healthcare in the National Health Portal.
    internal static let prscDtlHntGesundBundDeText = StringAsset("prsc_dtl_hnt_gesund_bund_de_text")
    /// Active ingredient name
    internal static let prscDtlMedIngredientName = StringAsset("prsc_dtl_med_ingredient_name")
    /// Manufacturing instructions
    internal static let prscDtlMedManufacturingInstructions = StringAsset("prsc_dtl_med_manufacturing_instructions")
    /// Receive
    internal static let prscDtlMedOvTxtDispensedHeader = StringAsset("prsc_dtl_med_ov_txt_dispensed_header")
    /// Prescribed
    internal static let prscDtlMedOvTxtSubscribedHeader = StringAsset("prsc_dtl_med_ov_txt_subscribed_header")
    /// potency and unity
    internal static let prscDtlMedTxtAmount = StringAsset("prsc_dtl_med_txt_amount")
    /// Drug Prescription Regulation
    internal static let prscDtlMedTxtAmvv = StringAsset("prsc_dtl_med_txt_amvv")
    /// Medicines and dressings
    internal static let prscDtlMedTxtAvm = StringAsset("prsc_dtl_med_txt_avm")
    /// Expiry Date
    internal static let prscDtlMedTxtBatchExpiresOn = StringAsset("prsc_dtl_med_txt_batch_expires_on")
    /// Batch description
    internal static let prscDtlMedTxtBatchLotNumber = StringAsset("prsc_dtl_med_txt_batch_lot_number")
    /// Narcotics (BtM)
    internal static let prscDtlMedTxtBtm = StringAsset("prsc_dtl_med_txt_btm")
    /// Category
    internal static let prscDtlMedTxtDrugCategory = StringAsset("prsc_dtl_med_txt_drug_category")
    /// Vaccine
    internal static let prscDtlMedTxtDrugVaccine = StringAsset("prsc_dtl_med_txt_drug_vaccine")
    /// Submission date
    internal static let prscDtlMedTxtHandedOverDate = StringAsset("prsc_dtl_med_txt_handed_over_date")
    /// Active ingredient number
    internal static let prscDtlMedTxtIngredinetNumber = StringAsset("prsc_dtl_med_txt_ingredinet_number")
    /// Trade name
    internal static let prscDtlMedTxtName = StringAsset("prsc_dtl_med_txt_name")
    /// Advice from your pharmacy
    internal static let prscDtlMedTxtNote = StringAsset("prsc_dtl_med_txt_Note")
    /// Other
    internal static let prscDtlMedTxtOther = StringAsset("prsc_dtl_med_txt_other")
    /// Packaging
    internal static let prscDtlMedTxtPackaging = StringAsset("prsc_dtl_med_txt_packaging")
    /// Address
    internal static let prscDtlPrTxtAddress = StringAsset("prsc_dtl_pr_txt_address")
    /// e-mail
    internal static let prscDtlPrTxtEmail = StringAsset("prsc_dtl_pr_txt_email")
    /// Access code
    internal static let prscDtlTiTxtAccessCode = StringAsset("prsc_dtl_ti_txt_access_code")
    /// Task ID
    internal static let prscDtlTiTxtTaskId = StringAsset("prsc_dtl_ti_txt_task_id")
    /// Technical information
    internal static let prscDtlTiTxtTitle = StringAsset("prsc_dtl_ti_txt_title")
    /// Caused
    internal static let prscDtlTxtAccidentReason = StringAsset("prsc_dtl_txt_accident_reason")
    /// Accident
    internal static let prscDtlTxtAccidentReasonGeneral = StringAsset("prsc_dtl_txt_accident_reason_general")
    /// Accident at work
    internal static let prscDtlTxtAccidentReasonWork = StringAsset("prsc_dtl_txt_accident_reason_work")
    /// Occupational disease
    internal static let prscDtlTxtAccidentReasonWorkRelated = StringAsset("prsc_dtl_txt_accident_reason_work_related")
    /// Additional payment
    internal static let prscDtlTxtAdditionalFee = StringAsset("prsc_dtl_txt_additional_fee")
    /// date of issue
    internal static let prscDtlTxtAuthoredOnDate = StringAsset("prsc_dtl_txt_authored_on_date")
    /// Eligible according to BVG
    internal static let prscDtlTxtBvg = StringAsset("prsc_dtl_txt_bvg")
    /// Directions for use
    internal static let prscDtlTxtDosageInstructions = StringAsset("prsc_dtl_txt_dosage_instructions")
    /// Your doctor has noted that you have been given instructions on how to take this medication that is not on the prescription. This could be on your medication plan, for example.
    internal static let prscDtlTxtDosageInstructionsDf = StringAsset("prsc_dtl_txt_dosage_instructions_df")
    /// at evening
    internal static let prscDtlTxtDosageInstructionsEvening = StringAsset("prsc_dtl_txt_dosage_instructions_evening")
    /// Unless your doctor has given you different instructions, the instructions for use can be understood as follows:
    internal static let prscDtlTxtDosageInstructionsFormatted = StringAsset("prsc_dtl_txt_dosage_instructions_formatted")
    /// In the morning
    internal static let prscDtlTxtDosageInstructionsMorning = StringAsset("prsc_dtl_txt_dosage_instructions_morning")
    /// at night
    internal static let prscDtlTxtDosageInstructionsNight = StringAsset("prsc_dtl_txt_dosage_instructions_night")
    /// at noon
    internal static let prscDtlTxtDosageInstructionsNoon = StringAsset("prsc_dtl_txt_dosage_instructions_noon")
    /// Your doctor has given you this information about taking the medication.
    internal static let prscDtlTxtDosageInstructionsNote = StringAsset("prsc_dtl_txt_dosage_instructions_note")
    /// Emergency service fee
    internal static let prscDtlTxtEmergencyServiceFee = StringAsset("prsc_dtl_txt_emergency_service_fee")
    /// Takes insurance
    internal static let prscDtlTxtEmergencyServiceFeeCovered = StringAsset("prsc_dtl_txt_emergency_service_fee_covered")
    /// Charges apply
    internal static let prscDtlTxtEmergencyServiceFeeNotCovered = StringAsset("prsc_dtl_txt_emergency_service_fee_not_covered")
    /// You can find professionally verified information on illnesses, ICD codes and issues to do with prevention and healthcare in the National Health Portal.
    internal static let prscDtlTxtFooter = StringAsset("prsc_dtl_txt_footer")
    /// Institution
    internal static let prscDtlTxtInstitution = StringAsset("prsc_dtl_txt_institution")
    /// Insured person
    internal static let prscDtlTxtInsuredPerson = StringAsset("prsc_dtl_txt_insured_person")
    /// Medicine
    internal static let prscDtlTxtMedication = StringAsset("prsc_dtl_txt_medication")
    /// My medication reminder
    internal static let prscDtlTxtMedicationReminder = StringAsset("prsc_dtl_txt_medication_reminder")
    /// Off
    internal static let prscDtlTxtMedicationReminderOff = StringAsset("prsc_dtl_txt_medication_reminder_off")
    /// On
    internal static let prscDtlTxtMedicationReminderOn = StringAsset("prsc_dtl_txt_medication_reminder_on")
    /// Your doctor has not given you any information about taking the medication.
    internal static let prscDtlTxtMissingDosageInstructions = StringAsset("prsc_dtl_txt_missing_dosage_instructions")
    /// Multiple prescription
    internal static let prscDtlTxtMultiPrescription = StringAsset("prsc_dtl_txt_multi_prescription")
    /// No
    internal static let prscDtlTxtNo = StringAsset("prsc_dtl_txt_no")
    /// No replacement product possible
    internal static let prscDtlTxtNoSubstitution = StringAsset("prsc_dtl_txt_no_substitution")
    /// Partially
    internal static let prscDtlTxtPartial = StringAsset("prsc_dtl_txt_partial")
    /// Once the cost receipts have been activated, you will find them here after redeeming your prescription.
    internal static let prscDtlTxtPkvHintActivateMsg = StringAsset("prsc_dtl_txt_pkv_hint_activate_msg")
    /// Receive cost receipts digitally
    internal static let prscDtlTxtPkvHintActivateTitle = StringAsset("prsc_dtl_txt_pkv_hint_activate_title")
    /// As soon as the pharmacy has deposited the cost receipt, it will appear here.
    internal static let prscDtlTxtPkvHintNoInvoiceMsg = StringAsset("prsc_dtl_txt_pkv_hint_no_invoice_msg")
    /// Digital cost receipt
    internal static let prscDtlTxtPkvHintNoInvoiceTitle = StringAsset("prsc_dtl_txt_pkv_hint_no_invoice_title")
    /// Prescriber
    internal static let prscDtlTxtPractitionerPerson = StringAsset("prsc_dtl_txt_practitioner_person")
    /// Number of packs prescribed
    internal static let prscDtlTxtQuantity = StringAsset("prsc_dtl_txt_quantity")
    /// Detailed information
    internal static let prscDtlTxtSectionDetailsHeader = StringAsset("prsc_dtl_txt_section_details_header")
    /// Replacement drug (Aut idem)
    internal static let prscDtlTxtSubstitution = StringAsset("prsc_dtl_txt_substitution")
    /// Substitute medication possible
    internal static let prscDtlTxtSubstitutionPossible = StringAsset("prsc_dtl_txt_substitution_possible")
    /// Yes
    internal static let prscDtlTxtYes = StringAsset("prsc_dtl_txt_yes")
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
    /// Use by
    internal static let prscFdTxtDetailsExpiresOn = StringAsset("prsc_fd_txt_details_expires_on")
    /// Batch description
    internal static let prscFdTxtDetailsLot = StringAsset("prsc_fd_txt_details_lot")
    /// Prescribed medication
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
    /// Prescription details
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
    /// This prescription will be redeemed for you as part of a treatment.
    internal static let prscRedeemNoteDirectAssignment = StringAsset("prsc_redeem_note_direct_assignment")
    /// Deleted
    internal static let prscStatusCanceled = StringAsset("prsc_status_canceled")
    /// Redeemed
    internal static let prscStatusCompleted = StringAsset("prsc_status_completed")
    /// Will be redeemed for you
    internal static let prscStatusDirectAssigned = StringAsset("prsc_status_direct_assigned")
    /// Defective prescription
    internal static let prscStatusError = StringAsset("prsc_status_error")
    /// Expired
    internal static let prscStatusExpired = StringAsset("prsc_status_expired")
    /// In redemption
    internal static let prscStatusInProgress = StringAsset("prsc_status_in_progress")
    /// Redeemable later
    internal static let prscStatusMultiplePrsc = StringAsset("prsc_status_multiple_prsc")
    /// Redeemable
    internal static let prscStatusReady = StringAsset("prsc_status_ready")
    /// Posted
    internal static let prscStatusSent = StringAsset("prsc_status_sent")
    /// Unknown
    internal static let prscStatusUndefined = StringAsset("prsc_status_undefined")
    /// Waiting for response
    internal static let prscStatusWaiting = StringAsset("prsc_status_waiting")
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
    /// Show this pickup code at %@ .
    internal static func pucTxtSubtitle(_ element1: String) -> StringAsset {
        StringAsset("puc_txt_subtitle_%@", arguments: [element1])
    }
    /// Collection code
    internal static let pucTxtTitle = StringAsset("puc_txt_title")
    /// Have it scanned at the pharmacy
    internal static let rdmBtnRedeemPharmacyDescription = StringAsset("rdm_btn_redeem_pharmacy_description")
    /// Show code
    internal static let rdmBtnRedeemPharmacyTitle = StringAsset("rdm_btn_redeem_pharmacy_title")
    /// Reserve or have it delivered
    internal static let rdmBtnRedeemSearchPharmacyDescription = StringAsset("rdm_btn_redeem_search_pharmacy_description")
    /// Send to pharmacy
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
    /// Wait a few minutes until you receive a response from the mail-order pharmacy.
    internal static let rdmSccTxtShipmentContent2 = StringAsset("rdm_scc_txt_shipment_content_2")
    /// The pharmacy will then inform you via the e-prescription app on how to complete the order.
    internal static let rdmSccTxtShipmentContent3 = StringAsset("rdm_scc_txt_shipment_content_3")
    /// Your next steps
    internal static let rdmSccTxtShipmentTitle = StringAsset("rdm_scc_txt_shipment_title")
    /// How would you like to redeem your prescriptions?
    internal static let rdmTxtSubtitle = StringAsset("rdm_txt_subtitle")
    /// How to redeem?
    internal static let rdmTxtTitle = StringAsset("rdm_txt_title")
    /// The city entered exceeds the maximum allowed length of %@ characters.
    internal static func rivAvsInvalidCity(_ element1: String) -> StringAsset {
        StringAsset("riv_avs_invalid_city_%@", arguments: [element1])
    }
    /// The hint you entered exceeds the maximum length of %@ characters allowed.
    internal static func rivAvsInvalidHint(_ element1: String) -> StringAsset {
        StringAsset("riv_avs_invalid_hint_%@", arguments: [element1])
    }
    /// The entered e-Mail address is invalid. Please correct your entry.
    internal static let rivAvsInvalidMail = StringAsset("riv_avs_invalid_mail_%@")
    /// A valid phone number or email address must be provided for the selected shipping option.
    internal static let rivAvsInvalidMissingContact = StringAsset("riv_avs_invalid_missing_contact_%@")
    /// The selected name exceeds the maximum length of %@ characters.
    internal static func rivAvsInvalidName(_ element1: String) -> StringAsset {
        StringAsset("riv_avs_invalid_name_%@", arguments: [element1])
    }
    /// The dialed phone number is invalid. Please correct your entry.
    internal static let rivAvsInvalidPhone = StringAsset("riv_avs_invalid_phone_%@")
    /// The entered street exceeds the allowed maximum length of %@ characters.
    internal static func rivAvsInvalidStreet(_ element1: String) -> StringAsset {
        StringAsset("riv_avs_invalid_street_%@", arguments: [element1])
    }
    /// The entered text exceeds the allowed maximum length of %@ characters.
    internal static func rivAvsInvalidText(_ element1: String) -> StringAsset {
        StringAsset("riv_avs_invalid_text_%@", arguments: [element1])
    }
    /// The postal code entered exceeds the maximum allowed length of %@ characters.
    internal static func rivAvsInvalidZip(_ element1: String) -> StringAsset {
        StringAsset("riv_avs_invalid_zip_%@", arguments: [element1])
    }
    /// Invalid version number.
    internal static let rivAvsWrongVersion = StringAsset("riv_avs_wrong_version")
    /// The city entered exceeds the maximum allowed length of %@ characters.
    internal static func rivTiInvalidCity(_ element1: String) -> StringAsset {
        StringAsset("riv_ti_invalid_city_%@", arguments: [element1])
    }
    /// The hint you entered exceeds the maximum length of %@ characters allowed.
    internal static func rivTiInvalidHint(_ element1: String) -> StringAsset {
        StringAsset("riv_ti_invalid_hint_%@", arguments: [element1])
    }
    /// The entered e-Mail address is invalid. Please correct your entry.
    internal static let rivTiInvalidMail = StringAsset("riv_ti_invalid_mail_%@")
    /// A valid phone number must be provided for the selected shipping option.
    internal static let rivTiInvalidMissingContact = StringAsset("riv_ti_invalid_missing_contact_%@")
    /// The selected name exceeds the maximum length of %@ characters.
    internal static func rivTiInvalidName(_ element1: String) -> StringAsset {
        StringAsset("riv_ti_invalid_name_%@", arguments: [element1])
    }
    /// The dialed phone number is invalid. Please correct your entry.
    internal static let rivTiInvalidPhone = StringAsset("riv_ti_invalid_phone_%@")
    /// The entered street exceeds the allowed maximum length of %@ characters.
    internal static func rivTiInvalidStreet(_ element1: String) -> StringAsset {
        StringAsset("riv_ti_invalid_street_%@", arguments: [element1])
    }
    /// The postal code entered exceeds the maximum allowed length of %@ characters.
    internal static func rivTiInvalidZip(_ element1: String) -> StringAsset {
        StringAsset("riv_ti_invalid_zip_%@", arguments: [element1])
    }
    /// Invalid version number.
    internal static let rivTiWrongVersion = StringAsset("riv_ti_wrong_version")
    /// Have this prescription code scanned at your pharmacy.
    internal static let rphTxtMatrixcodeHint = StringAsset("rph_txt_matrixcode_hint")
    /// Have this prescription code scanned at your pharmacy.
    internal static let rphTxtSubtitle = StringAsset("rph_txt_subtitle")
    /// Prescription code
    internal static let rphTxtTitle = StringAsset("rph_txt_title")
    /// Cancel scanning
    internal static let scnBtnCancelScan = StringAsset("scn_btn_cancel_scan")
    /// Light off
    internal static let scnBtnLightOff = StringAsset("scn_btn_light_off")
    /// Light on
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
    /// This can be caused, for example, by manipulated devices or when developer mode is switched on. We recommend not using the app on jailbroken devices for security reasons.
    internal static let secTxtSystemRootDetectionMessage = StringAsset("sec_txt_system_root_detection_message")
    /// I acknowledge the increased risk and would like to continue anyway.
    internal static let secTxtSystemRootDetectionSelection = StringAsset("sec_txt_system_root_detection_selection")
    /// Your device may have reduced security
    internal static let secTxtSystemRootDetectionTitle = StringAsset("sec_txt_system_root_detection_title")
    /// Selected
    internal static let sectionTxtIsActiveValue = StringAsset("section_txt_is_active_value")
    /// Not selected
    internal static let sectionTxtIsInactiveValue = StringAsset("section_txt_is_inactive_value")
    /// your insurance will not cover any costs.
    internal static let selfPayerWarningTxtEnding = StringAsset("self_payer_warning_txt_ending")
    /// Plural format key: "Your insurance will not cover any costs for %#@variable_0@ %@ . "
    internal static func selfPayerWarningTxtMessage(_ element1: Int, _ element2: String) -> StringAsset {
        StringAsset("self_payer_warning_txt_message", arguments: [element1, element2])
    }
    /// Your insurance will not cover the cost of this prescription.
    internal static let selfPayerWarningTxtMessageSingle = StringAsset("self_payer_warning_txt_message_single")
    /// Your insurance will not cover the cost of this prescription.
    internal static let selfPayerWarningTxtSolo = StringAsset("self_payer_warning_txt_solo")
    /// Register
    internal static let serviceTxtConsentAlertLogin = StringAsset("service_txt_consent_alert_login")
    /// OK
    internal static let serviceTxtConsentAlertOkay = StringAsset("service_txt_consent_alert_okay")
    /// Try again
    internal static let serviceTxtConsentAlertRetry = StringAsset("service_txt_consent_alert_retry")
    /// Incorrect request
    internal static let serviceTxtConsentErrorHttp400Description = StringAsset("service_txt_consent_error_http_400_description")
    /// There was a problem with the request. We work on a solution.
    internal static let serviceTxtConsentErrorHttp400Recovery = StringAsset("service_txt_consent_error_http_400_recovery")
    /// Login failed
    internal static let serviceTxtConsentErrorHttp401Description = StringAsset("service_txt_consent_error_http_401_description")
    /// The server had a problem logging in. Please sign in again.
    internal static let serviceTxtConsentErrorHttp401Recovery = StringAsset("service_txt_consent_error_http_401_recovery")
    /// Update app
    internal static let serviceTxtConsentErrorHttp403Description = StringAsset("service_txt_consent_error_http_403_description")
    /// To use this feature please update your app.
    internal static let serviceTxtConsentErrorHttp403Recovery = StringAsset("service_txt_consent_error_http_403_recovery")
    /// Incorrect request
    internal static let serviceTxtConsentErrorHttp404Description = StringAsset("service_txt_consent_error_http_404_description")
    /// There was a problem with the request. We work on a solution.
    internal static let serviceTxtConsentErrorHttp404Recovery = StringAsset("service_txt_consent_error_http_404_recovery")
    /// Incorrect request
    internal static let serviceTxtConsentErrorHttp405Description = StringAsset("service_txt_consent_error_http_405_description")
    /// There was a problem with the request. We work on a solution.
    internal static let serviceTxtConsentErrorHttp405Recovery = StringAsset("service_txt_consent_error_http_405_recovery")
    /// Server not responding
    internal static let serviceTxtConsentErrorHttp408Description = StringAsset("service_txt_consent_error_http_408_description")
    /// Please try again in a few minutes.
    internal static let serviceTxtConsentErrorHttp408Recovery = StringAsset("service_txt_consent_error_http_408_recovery")
    /// Rejected
    internal static let serviceTxtConsentErrorHttp429Description = StringAsset("service_txt_consent_error_http_429_description")
    /// The server rejected your request. Please try again in a few minutes.
    internal static let serviceTxtConsentErrorHttp429Recovery = StringAsset("service_txt_consent_error_http_429_recovery")
    /// Server not responding
    internal static let serviceTxtConsentErrorHttp500Description = StringAsset("service_txt_consent_error_http_500_description")
    /// Please try again in a few minutes.
    internal static let serviceTxtConsentErrorHttp500Recovery = StringAsset("service_txt_consent_error_http_500_recovery")
    /// Please try again in a few minutes.
    internal static let serviceTxtConsentErrorHttpDefaultRecovery = StringAsset("service_txt_consent_error_http_default_recovery")
    /// You already receive cost receipts digitally.
    internal static let serviceTxtConsentToastConflictMessage = StringAsset("service_txt_consent_toast_conflict_message")
    /// To the cost receipts
    internal static let serviceTxtConsentToastRouteToListMessage = StringAsset("service_txt_consent_toast_route_to_list_message")
    /// You will now receive cost receipts digitally 🥳
    internal static let serviceTxtConsentToastSuccessfullyGrantedMessage = StringAsset("service_txt_consent_toast_successfully_granted_message")
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
    /// Next
    internal static let stgBtnCardResetAdvance = StringAsset("stg_btn_card_reset_advance")
    /// OK
    internal static let stgBtnCardResetPinAlertOk = StringAsset("stg_btn_card_reset_pin_alert_ok")
    /// Correct
    internal static let stgBtnCardResetRcAlertAmend = StringAsset("stg_btn_card_reset_rc_alert_amend")
    /// Cancel
    internal static let stgBtnCardResetRcAlertCancel = StringAsset("stg_btn_card_reset_rc_alert_cancel")
    /// OK
    internal static let stgBtnCardResetRcAlertOk = StringAsset("stg_btn_card_reset_rc_alert_ok")
    /// Connect card
    internal static let stgBtnCardResetRead = StringAsset("stg_btn_card_reset_read")
    /// Delete
    internal static let stgBtnChargeItemAlertDeleteConfirmDelete = StringAsset("stg_btn_charge_item_alert_delete_confirm_delete")
    /// Connect
    internal static let stgBtnChargeItemAlertDeleteNotAuthConnect = StringAsset("stg_btn_charge_item_alert_delete_not_auth_connect")
    /// Cancel
    internal static let stgBtnChargeItemAlertErrorCancel = StringAsset("stg_btn_charge_item_alert_error_cancel")
    /// OK
    internal static let stgBtnChargeItemAlertErrorOkay = StringAsset("stg_btn_charge_item_alert_error_okay")
    /// Try again
    internal static let stgBtnChargeItemAlertErrorRetry = StringAsset("stg_btn_charge_item_alert_error_retry")
    /// In the app
    internal static let stgBtnChargeItemAlterViaApp = StringAsset("stg_btn_charge_item_alter_via_app")
    /// At the pharmacy
    internal static let stgBtnChargeItemAlterViaPharmacy = StringAsset("stg_btn_charge_item_alter_via_pharmacy")
    /// Delete
    internal static let stgBtnChargeItemDelete = StringAsset("stg_btn_charge_item_delete")
    /// Connect
    internal static let stgBtnChargeItemListBottomBannerAuthenticateButton = StringAsset("stg_btn_charge_item_list_bottom_banner_authenticate_button")
    /// Enable
    internal static let stgBtnChargeItemListBottomBannerGrantButton = StringAsset("stg_btn_charge_item_list_bottom_banner_grant_button")
    /// Done
    internal static let stgBtnChargeItemListEditingDone = StringAsset("stg_btn_charge_item_list_editing_done")
    /// Select
    internal static let stgBtnChargeItemListEditingStart = StringAsset("stg_btn_charge_item_list_editing_start")
    /// Enable
    internal static let stgBtnChargeItemListFeatureActivate = StringAsset("stg_btn_charge_item_list_feature_activate")
    /// Disable
    internal static let stgBtnChargeItemListFeatureDeactivate = StringAsset("stg_btn_charge_item_list_feature_deactivate")
    /// Options
    internal static let stgBtnChargeItemListMenu = StringAsset("stg_btn_charge_item_list_menu")
    /// Total: %@
    internal static func stgBtnChargeItemListSum(_ element1: String) -> StringAsset {
        StringAsset("stg_btn_charge_item_list_sum", arguments: [element1])
    }
    /// Show more
    internal static let stgBtnChargeItemMore = StringAsset("stg_btn_charge_item_more")
    /// For an overview of the cost receipts
    internal static let stgBtnChargeItemRouteToList = StringAsset("stg_btn_charge_item_route_to_list")
    /// Submit
    internal static let stgBtnChargeItemShare = StringAsset("stg_btn_charge_item_share")
    /// App security
    internal static let stgBtnDeviceSecurity = StringAsset("stg_btn_device_security")
    /// Edit
    internal static let stgBtnEditPicture = StringAsset("stg_btn_edit_picture")
    /// take a picture
    internal static let stgBtnEditProfileActionCamera = StringAsset("stg_btn_edit_profile_action_camera")
    /// choose picture
    internal static let stgBtnEditProfileActionLibrary = StringAsset("stg_btn_edit_profile_action_library")
    /// View cost receipts
    internal static let stgBtnEditProfileChargeItemList = StringAsset("stg_btn_edit_profile_charge_item_list")
    /// Delete profile
    internal static let stgBtnEditProfileDelete = StringAsset("stg_btn_edit_profile_delete")
    /// Cancel
    internal static let stgBtnEditProfileDeleteAlertCancel = StringAsset("stg_btn_edit_profile_delete_alert_cancel")
    /// Register
    internal static let stgBtnEditProfileLogin = StringAsset("stg_btn_edit_profile_login")
    /// Log out
    internal static let stgBtnEditProfileLogout = StringAsset("stg_btn_edit_profile_logout")
    /// Connected devices
    internal static let stgBtnEditProfileRegisteredDevices = StringAsset("stg_btn_edit_profile_registered_devices")
    /// Language
    internal static let stgBtnLanguageSettings = StringAsset("stg_btn_language_settings")
    /// Open settings
    internal static let stgBtnLanguageSettingsAlertOpenSettings = StringAsset("stg_btn_language_settings_alert_open_settings")
    /// Medication reminder
    internal static let stgBtnMedicationReminder = StringAsset("stg_btn_medication_reminder")
    /// Save
    internal static let stgBtnNewProfileCreate = StringAsset("stg_btn_new_profile_create")
    /// Register
    internal static let stgBtnRegDevicesLoad = StringAsset("stg_btn_reg_devices_load")
    /// E-prescription forum
    internal static let stgConBtnGemmunity = StringAsset("stg_con_btn_gemmunity")
    /// app-feedback@gematik.de
    internal static let stgConFbkMail = StringAsset("stg_con_fbk_mail")
    /// Feedback from the e-prescription app
    internal static let stgConFbkSubjectMail = StringAsset("stg_con_fbk_subject_mail")
    /// Free of charge for the caller. Service times: Mon - Fri 8:00 a.m. - 8:00 p.m. except on national holidays
    internal static let stgConHotlineAva = StringAsset("stg_con_hotline_ava")
    /// +49-800-277-3777
    internal static let stgConHotlineContact = StringAsset("stg_con_hotline_contact")
    /// Call telephone support
    internal static let stgConTextContactHotline = StringAsset("stg_con_text_contact_hotline")
    /// Write email
    internal static let stgConTextMail = StringAsset("stg_con_text_mail")
    /// Survey about the app
    internal static let stgConTextSurvey = StringAsset("stg_con_text_survey")
    /// Privacy policy
    internal static let stgDpoTxtDataPrivacy = StringAsset("stg_dpo_txt_data_privacy")
    /// Open source licences
    internal static let stgDpoTxtFoss = StringAsset("stg_dpo_txt_foss")
    /// Terms of Use
    internal static let stgDpoTxtTermsOfUse = StringAsset("stg_dpo_txt_terms_of_use")
    /// Enter PIN
    internal static let stgEdtCardResetOldpinInput = StringAsset("stg_edt_card_reset_oldpin_input")
    /// Enter new PIN
    internal static let stgEdtCardResetPinInputPin1 = StringAsset("stg_edt_card_reset_pin_input_pin1")
    /// Repeat PIN
    internal static let stgEdtCardResetPinInputPin2 = StringAsset("stg_edt_card_reset_pin_input_pin2")
    /// Enter PUK
    internal static let stgEdtCardResetPukInput = StringAsset("stg_edt_card_reset_puk_input")
    /// With your PIN you have received an 8-digit PUK from your insurance company.
    internal static let stgEdtCardResetPukInputLabel = StringAsset("stg_edt_card_reset_puk_input_label")
    /// https://www.das-e-rezept-fuer-deutschland.de/
    internal static let stgLnoLinkContact = StringAsset("stg_lno_link_contact")
    /// Open website
    internal static let stgLnoLinkTextContact = StringAsset("stg_lno_link_text_contact")
    /// app-feedback@gematik.de
    internal static let stgLnoMailContact = StringAsset("stg_lno_mail_contact")
    /// Write email
    internal static let stgLnoMailTextContact = StringAsset("stg_lno_mail_text_contact")
    /// +49 0800 277 3777
    internal static let stgLnoPhoneContact = StringAsset("stg_lno_phone_contact")
    /// Call telephone support
    internal static let stgLnoPhoneTextContact = StringAsset("stg_lno_phone_text_contact")
    /// Imprint
    internal static let stgLnoTxtLegalNotice = StringAsset("stg_lno_txt_legal_notice")
    /// gematik GmbH
    /// Friedrichstr. 136
    /// 10117 Berlin, Germany
    internal static let stgLnoTxtTextIssuer = StringAsset("stg_lno_txt_text_issuer")
    /// We strive to use gender-sensitive language. If you notice any errors, we would be pleased to hear from you by email.
    internal static let stgLnoTxtTextNote = StringAsset("stg_lno_txt_text_note")
    /// Dr. Florian Hartge
    internal static let stgLnoTxtTextResponsible = StringAsset("stg_lno_txt_text_responsible")
    /// Managing Director: Dr. Florian Hartge
    ///  Registration court: Berlin-Charlottenburg District Court
    ///  Commercial register number: HRB 96351
    ///  VAT identification number: DE241843684
    internal static let stgLnoTxtTextTaxAndMore = StringAsset("stg_lno_txt_text_taxAndMore")
    /// Contact
    internal static let stgLnoTxtTitleContact = StringAsset("stg_lno_txt_title_contact")
    /// Publisher
    internal static let stgLnoTxtTitleIssuer = StringAsset("stg_lno_txt_title_issuer")
    /// Note
    internal static let stgLnoTxtTitleNote = StringAsset("stg_lno_txt_title_note")
    /// Responsible for the content
    internal static let stgLnoTxtTitleResponsible = StringAsset("stg_lno_txt_title_responsible")
    /// Germany's modern platform for digital medicine
    internal static let stgLnoYouKnowUs = StringAsset("stg_lno_you_know_us")
    /// Access token
    internal static let stgTknTxtAccessToken = StringAsset("stg_tkn_txt_access_token")
    /// Token copied to clipboard
    internal static let stgTknTxtCopyToClipboard = StringAsset("stg_tkn_txt_copy_to_clipboard")
    /// SSO token
    internal static let stgTknTxtSsoToken = StringAsset("stg_tkn_txt_sso_token")
    /// Tokens
    internal static let stgTknTxtTitleTokens = StringAsset("stg_tkn_txt_title_tokens")
    /// Reject
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
    /// Demo mode disabled
    internal static let stgTxtAlertTitleDemoModeOff = StringAsset("stg_txt_alert_title_demo_mode_off")
    /// Connect
    internal static let stgTxtAuditEventsBannerConnect = StringAsset("stg_txt_audit_events_banner_connect")
    /// To receive access logs, you must be connected to the server.
    internal static let stgTxtAuditEventsBannerMessage = StringAsset("stg_txt_audit_events_banner_message")
    /// No timestamp
    internal static let stgTxtAuditEventsMissingDate = StringAsset("stg_txt_audit_events_missing_date")
    /// Not specified
    internal static let stgTxtAuditEventsMissingDescription = StringAsset("stg_txt_audit_events_missing_description")
    /// Untitled
    internal static let stgTxtAuditEventsMissingTitle = StringAsset("stg_txt_audit_events_missing_title")
    /// You will receive access logs when you are logged in to the prescription service.
    internal static let stgTxtAuditEventsNoProtocolDescription = StringAsset("stg_txt_audit_events_no_protocol_description")
    /// No access logs
    internal static let stgTxtAuditEventsNoProtocolTitle = StringAsset("stg_txt_audit_events_no_protocol_title")
    /// Access logs
    internal static let stgTxtAuditEventsTitle = StringAsset("stg_txt_audit_events_title")
    /// Select desired PIN
    internal static let stgTxtCardCustomPin = StringAsset("stg_txt_card_custom_pin")
    /// Forgotten PIN
    internal static let stgTxtCardForgotPin = StringAsset("stg_txt_card_forgot_pin")
    /// Order PIN or card
    internal static let stgTxtCardOrderNewCard = StringAsset("stg_txt_card_order_new_card")
    /// Select desired PIN
    internal static let stgTxtCardResetIntroCustomPin = StringAsset("stg_txt_card_reset_intro_custom_pin")
    /// Forgotten PIN
    internal static let stgTxtCardResetIntroForgotPin = StringAsset("stg_txt_card_reset_intro_forgot_pin")
    /// With your PIN you have received an 8-digit PUK from your insurance company.
    internal static let stgTxtCardResetIntroHint = StringAsset("stg_txt_card_reset_intro_hint")
    /// With your card you received a 6-digit PIN from your insurance company.
    internal static let stgTxtCardResetIntroHintCustomPin = StringAsset("stg_txt_card_reset_intro_hint_custom_pin")
    /// Your medical card
    internal static let stgTxtCardResetIntroNeedYourCard = StringAsset("stg_txt_card_reset_intro_need_your_card")
    /// PIN of your health card
    internal static let stgTxtCardResetIntroNeedYourCardsPin = StringAsset("stg_txt_card_reset_intro_need_your_cards_pin")
    /// Medical card PUK
    internal static let stgTxtCardResetIntroNeedYourCardsPuk = StringAsset("stg_txt_card_reset_intro_need_your_cards_puk")
    /// What you need:
    internal static let stgTxtCardResetIntroSubheadline = StringAsset("stg_txt_card_reset_intro_subheadline")
    /// unlock card
    internal static let stgTxtCardResetIntroUnlockCard = StringAsset("stg_txt_card_reset_intro_unlock_card")
    /// Enter current PIN
    internal static let stgTxtCardResetOldpinHeadline = StringAsset("stg_txt_card_reset_oldpin_headline")
    /// For security reasons, please enter your current PIN.
    internal static let stgTxtCardResetOldpinHint = StringAsset("stg_txt_card_reset_oldpin_hint")
    /// A PIN can only be 6-8 characters long.
    internal static let stgTxtCardResetPinAlertPinTooLongMessage = StringAsset("stg_txt_card_reset_pin_alert_pin_too_long_message")
    /// Maximum length reached
    internal static let stgTxtCardResetPinAlertPinTooLongTitle = StringAsset("stg_txt_card_reset_pin_alert_pin_too_long_title")
    /// Select desired PIN
    internal static let stgTxtCardResetPinHeadline = StringAsset("stg_txt_card_reset_pin_headline")
    /// You can choose your new PIN yourself (6 to 8 digits).
    internal static let stgTxtCardResetPinHint = StringAsset("stg_txt_card_reset_pin_hint")
    /// Please make a note of your PIN and keep it in a safe place.
    internal static let stgTxtCardResetPinHintMessage = StringAsset("stg_txt_card_reset_pin_hint_message")
    /// PIN remembered?
    internal static let stgTxtCardResetPinHintTitle = StringAsset("stg_txt_card_reset_pin_hint_title")
    /// The entries differ from each other.
    internal static let stgTxtCardResetPinWarning = StringAsset("stg_txt_card_reset_pin_warning")
    /// Enter PUK
    internal static let stgTxtCardResetPukHeadline = StringAsset("stg_txt_card_reset_puk_headline")
    /// With your PIN you have received an 8-digit PUK from your insurance company.
    internal static let stgTxtCardResetPukHint = StringAsset("stg_txt_card_reset_puk_hint")
    /// Desired PIN saved
    internal static let stgTxtCardResetRcAlertCardSetNewPinTitle = StringAsset("stg_txt_card_reset_rc_alert_card_set_new_pin_title")
    /// You can use one PUK for up to 10 unlocks.
    internal static let stgTxtCardResetRcAlertCardUnlockedMessage = StringAsset("stg_txt_card_reset_rc_alert_card_unlocked_message")
    /// card unlocked
    internal static let stgTxtCardResetRcAlertCardUnlockedTitle = StringAsset("stg_txt_card_reset_rc_alert_card_unlocked_title")
    /// You can use one PUK for up to 10 unlocks.
    internal static let stgTxtCardResetRcAlertCardUnlockedWithPinMessage = StringAsset("stg_txt_card_reset_rc_alert_card_unlocked_with_pin_message")
    /// Desired PIN saved
    internal static let stgTxtCardResetRcAlertCardUnlockedWithPinTitle = StringAsset("stg_txt_card_reset_rc_alert_card_unlocked_with_pin_title")
    /// You have reached the maximum number of card unlocks with this PUK or entered it incorrectly repeatedly. Please contact your insurance company.
    internal static let stgTxtCardResetRcAlertCounterExhaustedMessage = StringAsset("stg_txt_card_reset_rc_alert_counter_exhausted_message")
    /// Unable to unlock
    internal static let stgTxtCardResetRcAlertCounterExhaustedTitle = StringAsset("stg_txt_card_reset_rc_alert_counter_exhausted_title")
    /// You have reached the maximum number of card unlocks with this PUK or entered it incorrectly repeatedly. Please contact your insurance company.
    internal static let stgTxtCardResetRcAlertCounterExhaustedWithPinMessage = StringAsset("stg_txt_card_reset_rc_alert_counter_exhausted_with_pin_message")
    /// It is not possible to save the desired PIN
    internal static let stgTxtCardResetRcAlertCounterExhaustedWithPinTitle = StringAsset("stg_txt_card_reset_rc_alert_counter_exhausted_with_pin_title")
    /// Unblock your card in Settings > Unblock card.
    internal static let stgTxtCardResetRcAlertPinCounterExhaustedMessage = StringAsset("stg_txt_card_reset_rc_alert_pin_counter_exhausted_message")
    /// card blocked
    internal static let stgTxtCardResetRcAlertPinCounterExhaustedTitle = StringAsset("stg_txt_card_reset_rc_alert_pin_counter_exhausted_title")
    /// Please try it again.
    internal static let stgTxtCardResetRcAlertUnknownErrorMessage = StringAsset("stg_txt_card_reset_rc_alert_unknown_error_message")
    /// An error has occurred
    internal static let stgTxtCardResetRcAlertUnknownErrorTitle = StringAsset("stg_txt_card_reset_rc_alert_unknown_error_title")
    /// Please correct your access number (CAN)
    internal static let stgTxtCardResetRcAlertWrongCanMessage = StringAsset("stg_txt_card_reset_rc_alert_wrong_can_message")
    /// Wrong CAN
    internal static let stgTxtCardResetRcAlertWrongCanTitle = StringAsset("stg_txt_card_reset_rc_alert_wrong_can_title")
    /// Plural format key: "%#@variable_0@"
    internal static func stgTxtCardResetRcAlertWrongPinMessage(_ element1: Int) -> StringAsset {
        StringAsset("stg_txt_card_reset_rc_alert_wrong_pin_message", arguments: [element1])
    }
    /// PIN entered incorrectly
    internal static let stgTxtCardResetRcAlertWrongPinTitle = StringAsset("stg_txt_card_reset_rc_alert_wrong_pin_title")
    /// Plural format key: "%#@variable_0@"
    internal static func stgTxtCardResetRcAlertWrongPukMessage(_ element1: Int) -> StringAsset {
        StringAsset("stg_txt_card_reset_rc_alert_wrong_puk_message", arguments: [element1])
    }
    /// PUK entered incorrectly
    internal static let stgTxtCardResetRcAlertWrongPukTitle = StringAsset("stg_txt_card_reset_rc_alert_wrong_puk_title")
    /// Unfortunately, you have no further attempts to enter your PUK. Please contact your health insurance company.
    internal static let stgTxtCardResetRcAlertWrongPukZeroRetriesMessage = StringAsset("stg_txt_card_reset_rc_alert_wrong_puk_zero_retries_message")
    /// No further entry possible
    internal static let stgTxtCardResetRcAlertWrongPukZeroRetriesTitle = StringAsset("stg_txt_card_reset_rc_alert_wrong_puk_zero_retries_title")
    /// Set desired PIN
    internal static let stgTxtCardResetRcNfcDialogChangeReferenceData = StringAsset("stg_txt_card_reset_rc_nfc_dialog_change_reference_data")
    /// Not successful
    internal static let stgTxtCardResetRcNfcDialogError = StringAsset("stg_txt_card_reset_rc_nfc_dialog_error")
    /// unlock map
    internal static let stgTxtCardResetRcNfcDialogUnlockCard = StringAsset("stg_txt_card_reset_rc_nfc_dialog_unlock_card")
    /// Set PIN
    internal static let stgTxtCardResetRcNfcDialogUnlockCardWithPin = StringAsset("stg_txt_card_reset_rc_nfc_dialog_unlock_card_with_pin")
    /// Insurance card
    internal static let stgTxtCardSectionHeader = StringAsset("stg_txt_card_section_header")
    /// Unblock Card
    internal static let stgTxtCardUnlockCard = StringAsset("stg_txt_card_unlock_card")
    /// Connect failed
    internal static let stgTxtChargeItemAlertDeleteAuthTitle = StringAsset("stg_txt_charge_item_alert_delete_auth_title")
    /// This cost receipt will be irretrievably deleted on this device and on the server.
    internal static let stgTxtChargeItemAlertDeleteConfirmMessage = StringAsset("stg_txt_charge_item_alert_delete_confirm_message")
    /// Really delete?
    internal static let stgTxtChargeItemAlertDeleteConfirmTitle = StringAsset("stg_txt_charge_item_alert_delete_confirm_title")
    /// To delete, a connection to the prescription server must be established.
    internal static let stgTxtChargeItemAlertDeleteNotAuthMessage = StringAsset("stg_txt_charge_item_alert_delete_not_auth_message")
    /// Register
    internal static let stgTxtChargeItemAlertDeleteNotAuthTitle = StringAsset("stg_txt_charge_item_alert_delete_not_auth_title")
    /// Failed to delete billing information
    internal static let stgTxtChargeItemAlertErrorTitle = StringAsset("stg_txt_charge_item_alert_error_title")
    /// Have this code scanned at your pharmacy.
    internal static let stgTxtChargeItemAlterPharmacySubtitle = StringAsset("stg_txt_charge_item_alter_pharmacy_subtitle")
    /// Billing correction request
    internal static let stgTxtChargeItemAlterPharmacyTitle = StringAsset("stg_txt_charge_item_alter_pharmacy_title")
    /// Request correction
    internal static let stgTxtChargeItemAlterTitle = StringAsset("stg_txt_charge_item_alter_title")
    /// Issued on
    internal static let stgTxtChargeItemCreator = StringAsset("stg_txt_charge_item_creator")
    /// Received
    internal static let stgTxtChargeItemListAlertGrantConsentButtonActivate = StringAsset("stg_txt_charge_item_list_alert_grant_consent_button_activate")
    /// Cancel
    internal static let stgTxtChargeItemListAlertGrantConsentButtonCancel = StringAsset("stg_txt_charge_item_list_alert_grant_consent_button_cancel")
    /// Your cost receipts are also saved on the prescription server.
    internal static let stgTxtChargeItemListAlertGrantConsentMessage = StringAsset("stg_txt_charge_item_list_alert_grant_consent_message")
    /// Receive cost receipts
    internal static let stgTxtChargeItemListAlertGrantConsentTitle = StringAsset("stg_txt_charge_item_list_alert_grant_consent_title")
    /// Cancel
    internal static let stgTxtChargeItemListAlertRevokeConsentButtonCancel = StringAsset("stg_txt_charge_item_list_alert_revoke_consent_button_cancel")
    /// Disable
    internal static let stgTxtChargeItemListAlertRevokeConsentButtonDeactivate = StringAsset("stg_txt_charge_item_list_alert_revoke_consent_button_deactivate")
    /// This will delete all expense receipts from this device and the server.
    internal static let stgTxtChargeItemListAlertRevokeConsentMessage = StringAsset("stg_txt_charge_item_list_alert_revoke_consent_message")
    /// Deactivate function
    internal static let stgTxtChargeItemListAlertRevokeConsentTitle = StringAsset("stg_txt_charge_item_list_alert_revoke_consent_title")
    /// To receive cost receipts, you must be connected to the server.
    internal static let stgTxtChargeItemListBottomBannerAuthenticateMessage = StringAsset("stg_txt_charge_item_list_bottom_banner_authenticate_message")
    /// Submit paperless cost receipts to the tax office, aid agency or insurance company.
    internal static let stgTxtChargeItemListBottomBannerGrantMessage = StringAsset("stg_txt_charge_item_list_bottom_banner_grant_message")
    /// Loading cost receipts...
    internal static let stgTxtChargeItemListBottomBannerLoadingMessage = StringAsset("stg_txt_charge_item_list_bottom_banner_loading_message")
    /// No cost receipts
    internal static let stgTxtChargeItemListEmptyListReplacement = StringAsset("stg_txt_charge_item_list_empty_list_replacement")
    /// Connect failed
    internal static let stgTxtChargeItemListErrorAlertAuthenticateTitle = StringAsset("stg_txt_charge_item_list_error_alert_authenticate_title")
    /// OK
    internal static let stgTxtChargeItemListErrorAlertButtonOkay = StringAsset("stg_txt_charge_item_list_error_alert_button_okay")
    /// Try again
    internal static let stgTxtChargeItemListErrorAlertButtonRetry = StringAsset("stg_txt_charge_item_list_error_alert_button_retry")
    /// Failed to load billing information
    internal static let stgTxtChargeItemListErrorAlertFetchChargeItemListTitle = StringAsset("stg_txt_charge_item_list_error_alert_fetch_charge_item_list_title")
    /// Activation failed
    internal static let stgTxtChargeItemListErrorAlertGrantConsentTitle = StringAsset("stg_txt_charge_item_list_error_alert_grant_consent_title")
    /// Deactivation failed
    internal static let stgTxtChargeItemListErrorAlertRevokeConsentTitle = StringAsset("stg_txt_charge_item_list_error_alert_revoke_consent_title")
    /// cost receipts
    internal static let stgTxtChargeItemListTitle = StringAsset("stg_txt_charge_item_list_title")
    /// Connect
    internal static let stgTxtChargeItemListToolbarMenuAuthenticate = StringAsset("stg_txt_charge_item_list_toolbar_menu_authenticate")
    /// Enable
    internal static let stgTxtChargeItemListToolbarMenuGrant = StringAsset("stg_txt_charge_item_list_toolbar_menu_grant")
    /// Disable
    internal static let stgTxtChargeItemListToolbarMenuRevoke = StringAsset("stg_txt_charge_item_list_toolbar_menu_revoke")
    /// Redeemed in
    internal static let stgTxtChargeItemRedeemedAt = StringAsset("stg_txt_charge_item_redeemed_at")
    /// Redeemed on
    internal static let stgTxtChargeItemRedeemedOn = StringAsset("stg_txt_charge_item_redeemed_on")
    /// total price
    internal static let stgTxtChargeItemSum = StringAsset("stg_txt_charge_item_sum")
    /// Demo mode
    internal static let stgTxtDemoMode = StringAsset("stg_txt_demo_mode")
    /// Background colour
    internal static let stgTxtEditProfileBackgroundSectionTitle = StringAsset("stg_txt_edit_profile_background_section_title")
    /// cost receipts
    internal static let stgTxtEditProfileChargeItemListSectionTitle = StringAsset("stg_txt_edit_profile_charge_item_list_section_title")
    /// Profile name
    internal static let stgTxtEditProfileDefaultName = StringAsset("stg_txt_edit_profile_default_name")
    /// This will delete all data from the profile on this device. Your prescriptions in the health network will be retained.
    internal static let stgTxtEditProfileDeleteConfirmationMessage = StringAsset("stg_txt_edit_profile_delete_confirmation_message")
    /// Delete profile?
    internal static let stgTxtEditProfileDeleteConfirmationTitle = StringAsset("stg_txt_edit_profile_delete_confirmation_title")
    /// Delete access data
    internal static let stgTxtEditProfileDeletePairing = StringAsset("stg_txt_edit_profile_delete_pairing")
    /// The access data could not be deleted from the server. Please try again.
    internal static let stgTxtEditProfileDeletePairingError = StringAsset("stg_txt_edit_profile_delete_pairing_error")
    /// You will no longer automatically receive new prescriptions.
    internal static let stgTxtEditProfileDeletePairingMessage = StringAsset("stg_txt_edit_profile_delete_pairing_message")
    /// Delete access data
    internal static let stgTxtEditProfileDeletePairingTitle = StringAsset("stg_txt_edit_profile_delete_pairing_title")
    /// The name field must not be empty
    internal static let stgTxtEditProfileEmptyNameErrorMessage = StringAsset("stg_txt_edit_profile_empty_name_error_message")
    /// Error
    internal static let stgTxtEditProfileErrorMessageTitle = StringAsset("stg_txt_edit_profile_error_message_title")
    /// Access number (CAN)
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
    /// You will receive a token when you are logged in to the e-prescription server.
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
    /// Personal Settings
    internal static let stgTxtHeaderPersonalSettings = StringAsset("stg_txt_header_personal_settings")
    /// Profiles
    internal static let stgTxtHeaderProfiles = StringAsset("stg_txt_header_profiles")
    /// Security
    internal static let stgTxtHeaderSecurity = StringAsset("stg_txt_header_security")
    /// You can change the app language in System Settings.
    internal static let stgTxtLanguageSettingsAlertDescription = StringAsset("stg_txt_language_settings_alert_description")
    /// Change the language of the app
    internal static let stgTxtLanguageSettingsAlertTitle = StringAsset("stg_txt_language_settings_alert_title")
    /// Background colour
    internal static let stgTxtNewProfileBackgroundSectionTitle = StringAsset("stg_txt_new_profile_background_section_title")
    /// Error
    internal static let stgTxtNewProfileErrorMessageTitle = StringAsset("stg_txt_new_profile_error_message_title")
    /// The name field must not be empty
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
    /// Change password
    internal static let stgTxtSecurityOptionChangePasswordTitle = StringAsset("stg_txt_security_option_change_password_title")
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
    /// Orders
    internal static let tabTxtOrders = StringAsset("tab_txt_orders")
    /// Redeem
    internal static let tabTxtPharmacySearch = StringAsset("tab_txt_pharmacy_search")
    /// Settings
    internal static let tabTxtSettings = StringAsset("tab_txt_settings")
    /// Maybe later
    internal static let wlcdBtnDecline = StringAsset("wlcd_btn_decline")
    /// Register
    internal static let wlcdBtnLogin = StringAsset("wlcd_btn_login")
    /// To receive prescriptions digitally from your practice, you must be logged in.
    internal static let wlcdTxtFooter = StringAsset("wlcd_txt_footer")
    /// Receive prescriptions digitally?
    internal static let wlcdTxtHeader = StringAsset("wlcd_txt_header")
  }
  internal extension StringAsset {
    init(_ string: String, arguments: [CVarArg]? = nil) {
        self.init(string, arguments: arguments, bundle: Bundle.module)
    }
  }
  // swiftlint:enable function_parameter_count identifier_name line_length type_body_length
