// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

internal typealias A18n = A11y

// MARK: - YAML Files

// swiftlint:disable identifier_name line_length number_separator type_body_length
internal enum A11y {
    internal enum auth {
      static let authBtnBiometricsFaceid = "auth_btn_biometrics_faceid"
      static let authBtnBiometricsTouchid = "auth_btn_biometrics_touchid"
      static let authBtnPasswordContinue = "auth_btn_password_continue"
      static let authTxtPasswordFailure = "auth_txt_password_failure"
      static let authEdtPasswordInput = "auth_edt_password_input"
      static let authTxtFailedLoginHint = "auth_txt_failed_login_hint"
  }
    internal enum cardWall { 
    internal enum canInput {
      static let cdwTxtCanInput = "cdw_txt_can_input"
      static let cdwTxtCanInstruction = "cdw_txt_can_instruction"
      static let cdwImgCanCard = "cdw_img_can_card"
      static let cdwBtnCanCancel = "cdw_btn_can_cancel"
      static let cdwBtnCanDone = "cdw_btn_can_done"
      static let cdwBtnCanMore = "cdw_btn_can_more"
  }
    internal enum extAuthConfirmation {
      static let cdwBtnExtauthConfirmSend = "cdw_btn_extauth_confirm_send"
      static let cdwBtnExtauthConfirmCancel = "cdw_btn_extauth_confirm_cancel"
      static let cdwBtnExtauthConfirmContact = "cdw_btn_extauth_confirm_contact"
  }
    internal enum extAuthFallback {
      static let cdwBtnExtauthFallbackOrderegk = "cdw_btn_extauth_fallback_orderegk"
      static let cdwBtnExtauthFallbackCancel = "cdw_btn_extauth_fallback_cancel"
  }
    internal enum extAuthSelection {
      static let cdwBtnExtauthSelectionRetry = "cdw_btn_extauth_selection_retry"
      static let cdwBtnExtauthSelectionCancel = "cdw_btn_extauth_selection_cancel"
      static let cdwBtnExtauthSelectionConfirm = "cdw_btn_extauth_selection_confirm"
  }
    internal enum intro {
      static let cdwBtnIntroLater = "cdw_btn_intro_later"
      static let cdwBtnIntroCancel = "cdw_btn_intro_cancel"
      static let cdwBtnIntroMore = "cdw_btn_intro_more"
      static let cdwImgIntroMain = "cdw_img_intro_main"
      static let cdwTxtIntroHeaderBottom = "cdw_txt_intro_header_bottom"
      static let cdwTxtIntroDescription = "cdw_txt_intro_description"
      static let cdwTxtIntroListTitle = "cdw_txt_intro_list_title"
      static let cdwTxtIntroRequirementCard = "cdw_txt_intro_requirement_card"
      static let cdwTxtIntroRequirementPin = "cdw_txt_intro_requirement_pin"
      static let cdwTxtIntroRequirementPhone = "cdw_txt_intro_requirement_phone"
  }
    internal enum loginOption {
      static let cdwTxtLoginOptionSubtitle = "cdw_txt_loginOption_subtitle"
      static let cdwBtnLoginOptionCancel = "cdw_btn_loginOption_cancel"
      static let cdwBtnLoginOptionBack = "cdw_btn_loginOption_back"
      static let cdwBtnLoginOptionContinue = "cdw_btn_loginOption_continue"
      static let cdwTxtLoginOptionBiometry = "cdw_txt_loginOption_biometry"
      static let cdwTxtLoginOptionWithoutBiometry = "cdw_txt_loginOption_without_biometry"
      static let cdwTxtLoginOptionSecurityWarningTitle = "cdw_txt_loginOption_security_warning_title"
      static let cdwTxtLoginOptionSecurityWarningDescription = "cdw_txt_loginOption_security_warning_description"
      static let cdwBtnLoginOptionSecurityWarningAccept = "cdw_btn_loginOption_security_warning_accept"
  }
    internal enum notForYou {
      static let cdwBtnNfuDone = "cdw_btn_nfu_done"
      static let cdwBtnNfuCancel = "cdw_btn_nfu_cancel"
      static let cdwImgNfu = "cdw_img_nfu"
      static let cdwTxtNfuSubtitle = "cdw_txt_nfu_subtitle"
      static let cdwTxtNfuDescription = "cdw_txt_nfu_description"
      static let cdwTxtNfuFootnote = "cdw_txt_nfu_footnote"
      static let cdwBtnNfuMore = "cdw_btn_nfu_more"
  }
    internal enum pinInput {
      static let cdwTxtPinSubtitle = "cdw_txt_pin_subtitle"
      static let cdwBtnPinCancel = "cdw_btn_pin_cancel"
      static let cdwBtnPinDone = "cdw_btn_pin_done"
      static let cdwEdtPinInput = "cdw_edt_pin_input"
      static let cdwTxtPinHint = "cdw_txt_pin_hint"
      static let cdwTxtPinWarning = "cdw_txt_pin_warning"
      static let cdwHintGetPin = "cdw_hint_get_pin"
  }
    internal enum readCard {
      static let cdwBtnRcNext = "cdw_btn_rc_next"
      static let cdwBtnRcCancel = "cdw_btn_rc_cancel"
      static let cdwTxtRcHeadline = "cdw_txt_rc_headline"
      static let cdwTxtRcDescription = "cdw_txt_rc_description"
  }
    internal enum select {
      static let cdwBtnSelContinue = "cdw_btn_sel_continue"
      static let cdwBtnSelEgk = "cdw_btn_sel_egk"
      static let cdwBtnSelKkapp = "cdw_btn_sel_kkapp"
  }
    }
    internal enum controls { 
    internal enum emojiPicker {
      static let ctlBtnEmojiPickerEditSave = "ctl_btn_emoji_picker_edit_save"
      static let ctlBtnEmojiPickerEdit = "ctl_btn_emoji_picker_edit"
  }
    internal enum searchBar {
      static let ctlTxtSearchBarField = "ctl_txt_search_bar_field"
      static let ctlBtnSearchBarDeleteText = "ctl_btn_search_bar_delete_text"
      static let ctlBtnSearchBarCancel = "ctl_btn_search_bar_cancel"
  }
    }
    internal enum mainScreen {
      static let erxBtnRefresh = "erx_btn_refresh"
      static let erxDetailedBlock = "erx_detailed_block"
      static let erxDetailedBlockDoctor = "erx_detailed_block_doctor"
      static let erxDetailedBlockDate = "erx_detailed_block_date"
      static let erxDetailedBlockPrescriptions = "erx_detailed_block_prescriptions"
      static let erxDetailedBlockPrescriptionName = "erx_detailed_block_prescription_name"
      static let erxDetailedBlockPrescriptionValidity = "erx_detailed_block_prescription_validity"
      static let erxDetailedBlockRedeemAll = "erx_detailed_block_redeem_all"
      static let erxDetailedBlockStatus = "erx_detailed_block_status"
      static let erxBtnProfile = "erx_btn_profile"
      static let erxBtnScnPrescription = "erx_btn_scn_prescription"
      static let erxHntDemoModeTour = "erx_hnt_demo_mode_tour"
      static let erxHntDemoModeWelcome = "erx_hnt_demo_mode_welcome"
      static let erxHntOpenScanner = "erx_hnt_open_scanner"
      static let erxHntShowCardWall = "erx_hnt_show_card_wall"
      static let erxHntUnreadMessages = "erx_hnt_unread_messages"
  }
    internal enum messages { 
    internal enum list {
      static let msgsTxtEmptyList = "msgs_txt_empty_list"
      static let msgsTxtTitle = "msgs_txt_title"
  }
    internal enum pickupCode {
      static let pucTxtTitle = "puc_txt_title"
      static let pucTxtSubtitle = "puc_txt_subtitle"
      static let pucTxtHrCode = "puc_txt_hrCode"
  }
    }
    internal enum migration {
      static let amgTxtAndSpinner = "amg_txt_and_spinner"
  }
    internal enum onboarding { 
    internal enum authentication {
      static let onbAuthInpPasswordA = "onb_auth_inp_passwordA"
      static let onbAuthInpPasswordB = "onb_auth_inp_passwordB"
      static let onbAuthTxtPasswordRecommendation = "onb_auth_txt_password_recommendation"
      static let onbAuthTxtPasswordsDontMatch = "onb_auth_txt_passwords_dont_match"
      static let onbAuthTxtNoSelection = "onb_auth_txt_no_selection"
      static let onbAuthTxtAltDescription = "onb_auth_txt_alt_description"
      static let onbAuthTxtNoBiometrics = "onb_auth_txt_no_biometrics"
      static let onbAuthTxtSectionTitle = "onb_auth_txt_section_title"
      static let onbAuthBtnFaceid = "onb_auth_btn_faceid"
      static let onbAuthBtnTouchid = "onb_auth_btn_touchid"
  }
    internal enum features {
      static let onbTxtFeaturesTitle = "onb_txt_features_title"
      static let onbImgHandWithCard = "onb_img_hand_with_card"
  }
    internal enum legalInfo {
      static let onbTxtLegalInfoTitle = "onb_txt_legal_info_title"
      static let onbBtnAccept = "onb_btn_accept"
      static let onbTxtTermsOfUse = "onb_txt_terms_of_use"
      static let onbBtnAcceptTermsOfUse = "onb_btn_accept_terms_of_use"
      static let onbTxtTermsOfPrivacy = "onb_txt_terms_of_privacy"
      static let onbBtnAcceptPrivacy = "onb_btn_accept_privacy"
  }
    internal enum newProfile {
      static let onbPrfTxtTitle = "onb_prf_txt_title"
      static let onbPrfTxtAlertEmpty = "onb_prf_txt_alert_empty"
      static let onbPrfTxtFootnote = "onb_prf_txt_footnote"
      static let onbPrfTxtField = "onb_prf_txt_field"
  }
    internal enum start {
      static let onbTxtStartTitle = "onb_txt_start_title"
      static let onbImgGematikLogo = "onb_img_gematik_logo"
      static let onbImgMan1 = "onb_img_man1"
      static let onbBtnNext = "onb_btn_next"
  }
    internal enum welcome {
      static let onbTxtWelcomeTitle = "onb_txt_welcome_title"
      static let onbImgFrau1 = "onb_img_frau1"
  }
    }
    internal enum orderEGK {
      static let ogkTxtHeadline = "ogk_txt_headline"
      static let ogkBtnCancel = "ogk_btn_cancel"
      static let ogkBtnPhone = "ogk_btn_phone"
      static let ogkBtnWeb = "ogk_btn_web"
      static let ogkBtnMail = "ogk_btn_mail"
      static let ogkBtnEgkInfo = "ogk_btn_egk_info"
      static let ogkTxtNoSelectionHint = "ogk_txt_no_selection_hint"
      static let ogkTxtInsuranceCompanyHeader = "ogk_txt_insurance_company_header"
      static let ogkTxtServiceSelectionHeader = "ogk_txt_service_selection_header"
      static let ogkTxtContactCompanyHeader = "ogk_txt_contact_company_header"
  }
    internal enum pharmacyDetail {
      static let phaDetailTxtSubtitle = "pha_detail_txt_subtitle"
      static let phaDetailBtnOrganization = "pha_detail_btn_organization"
      static let phaDetailBtnHealthcareService = "pha_detail_btn_healthcare_service"
      static let phaDetailBtnLocation = "pha_detail_btn_location"
      static let phaDetailHint = "pha_detail_hint"
      static let phaDetailHintNotErxReady = "pha_detail_hint_not_erx_ready"
      static let phaDetailContact = "pha_detail_contact"
      static let phaDetailWeb = "pha_detail_web"
      static let phaDetailMail = "pha_detail_mail"
      static let phaDetailPhone = "pha_detail_phone"
  }
    internal enum pharmacyGlobal {
      static let phaGlobalImgReadinessBadge = "pha_global_img_readiness_badge"
      static let phaGlobalTxtReadinessBadge = "pha_global_txt_readiness_badge"
  }
    internal enum pharmacyRedeem {
      static let phaRedeemTxtTitle = "pha_redeem_txt_title"
      static let phaRedeemTxtSubtitle = "pha_redeem_txt_subtitle"
      static let phaRedeemTxtAddressTitle = "pha_redeem_txt_address_title"
      static let phaRedeemTxtAddressFootnote = "pha_redeem_txt_address_footnote"
      static let phaRedeemTxtPrescriptionTitle = "pha_redeem_txt_prescription_title"
      static let phaRedeemBtnRedeem = "pha_redeem_btn_redeem"
      static let phaRedeemBtnRedeemFootnote = "pha_redeem_btn_redeem_footnote"
  }
    internal enum pharmacySearch {
      static let phaSearchTxtResultList = "pha_search_txt_result_list"
      static let phaSearchTxtResultListEntry = "pha_search_txt_result_list_entry"
      static let phaSearchSearchRunning = "pha_search_search_running"
      static let phaSearchLocalizingDevice = "pha_search_localizing_device"
      static let phaSearchStart = "pha_search_start"
      static let phaSearchNoResults = "pha_search_no_results"
      static let phaSearchError = "pha_search_error"
  }
    internal enum prescriptionDetails {
      static let prscDtlTxtMedInfo = "prsc_dtl_txt_med_info"
      static let prscDtlTxtMedDosageInstructions = "prsc_dtl_txt_med_dosage_instructions"
      static let prscDtlBtnDeleteMedication = "prsc_dtl_btn_delete_medication"
      static let prscDtlBtnToggleRedeem = "prsc_dtl_btn_toggle_redeem"
      static let prscDtlHntNoctuFeeWaiver = "prsc_dtl_hnt_noctu_fee_waiver"
      static let prscDtlHntSubstitution = "prsc_dtl_hnt_substitution"
      static let prscDtlHntDosageInstructions = "prsc_dtl_hnt_dosage_instructions"
      static let prscDtlHntKeepOverview = "prsc_dtl_hnt_keep_overview"
      static let prscDtlTxtTaskId = "prsc_dtl_txt_task_id"
      static let prscDtlTxtAccessCode = "prsc_dtl_txt_access_code"
  }
    internal enum profileSelection {
      static let proTxtSelectionProfileList = "pro_txt_selection_profile_list"
      static let proTxtSelectionProfileListEntry = "pro_txt_selection_profile_list_entry"
      static let proBtnSelectionEdit = "pro_btn_selection_edit"
  }
    internal enum redeem { 
    internal enum matrixCode {
      static let rphTxtTitle = "rph_txt_title"
      static let rphTxtSubtitle = "rph_txt_subtitle"
      static let rphImgMatrixcodeLoadingIndicator = "rph_img_matrixcode_loading_indicator"
      static let rphImgMatrixcode = "rph_img_matrixcode"
      static let rphBtnCloseButton = "rph_btn_close_button"
  }
    internal enum overview {
      static let rdmTxtPharmacyTitle = "rdm_txt_pharmacy_title"
      static let rdmTxtPharmacySubtitle = "rdm_txt_pharmacy_subtitle"
      static let rdmBtnPharmacyTile = "rdm_btn_pharmacy_tile"
      static let rdmBtnDeliveryTile = "rdm_btn_delivery_tile"
      static let rdmBtnCloseButton = "rdm_btn_close_button"
  }
    }
    internal enum scanner {
      static let scnTxtScanState = "scn_txt_scan_state"
      static let scnImgScanAlert = "scn_img_scan_alert"
      static let scnBtnScanningDone = "scn_btn_scanning_done"
      static let scnBtnCancelScan = "scn_btn_cancel_scan"
  }
    internal enum security {
      static let secTxtSystemPinHeadline = "sec_txt_system_pin_headline"
      static let secTxtSystemPinTitle = "sec_txt_system_pin_title"
      static let secTxtSystemPinMessage = "sec_txt_system_pin_message"
      static let secTxtSystemPinSelection = "sec_txt_system_pin_selection"
      static let secBtnSystemPinDone = "sec_btn_system_pin_done"
      static let secTxtSystemRootDetectionHeadline = "sec_txt_system_root_detection_headline"
      static let secTxtSystemRootDetectionTitle = "sec_txt_system_root_detection_title"
      static let secTxtSystemRootDetectionMessage = "sec_txt_system_root_detection_message"
      static let secTxtSystemRootDetectionSelection = "sec_txt_system_root_detection_selection"
      static let secTxtSystemRootDetectionFootnote = "sec_txt_system_root_detection_footnote"
      static let secBtnSystemRootDetectionFootnoteMore = "sec_btn_system_root_detection_footnote_more"
      static let secBtnSystemRootDetectionDone = "sec_btn_system_root_detection_done"
  }
    internal enum settings { 
    internal enum auditEvents {
      static let stgCtnAuditEventsEvents = "stg_ctn_audit_events_events"
      static let stgCtnAuditEventsEventTitle = "stg_ctn_audit_events_event_title"
      static let stgCtnAuditEventsEventDescription = "stg_ctn_audit_events_event_description"
      static let stgCtnAuditEventsEventDate = "stg_ctn_audit_events_event_date"
      static let stgTxtAuditEventsLastUpdated = "stg_txt_audit_events_last_updated"
      static let stgCtnAuditEventsNavigationContainer = "stg_ctn_audit_events_navigation_container"
      static let stgCtnAuditEventsNavigationNext = "stg_ctn_audit_events_navigation_next"
      static let stgCtnAuditEventsNavigationPageIndicator = "stg_ctn_audit_events_navigation_page_indicator"
      static let stgCtnAuditEventsNavigationPrevious = "stg_ctn_audit_events_navigation_previous"
      static let stgTxtAuditEventsActivityIndicator = "stg_txt_audit_events_activity_indicator"
      static let stgTxtAuditEventsNoProtocolTitle = "stg_txt_audit_events_no_protocol_title"
      static let stgTxtAuditEventsNoProtocolDescription = "stg_txt_audit_events_no_protocol_description"
  }
    internal enum createPassword {
      static let cpwBtnSave = "cpw_btn_save"
      static let cpwBtnUpdate = "cpw_btn_update"
      static let cpwInpCurrentPassword = "cpw_inp_current_password"
      static let cpwInpPasswordA = "cpw_inp_passwordA"
      static let cpwInpPasswordB = "cpw_inp_passwordB"
      static let cpwTxtPasswordRecommendation = "cpw_txt_password_recommendation"
      static let cpwTxtSectionTitle = "cpw_txt_section_title"
      static let cpwTxtSectionUpdateTitle = "cpw_txt_section_update_title"
  }
    internal enum dataPrivacy {
      static let stgDprTxtDataPrivacy = "stg_dpr_txt_data_privacy"
      static let stgWwDataPrivacy = "stg_ww_data_privacy"
      static let stgBtnDataPrivacyClose = "stg_btn_data_privacy_close"
  }
    internal enum demo {
      static let navDone = "nav_done"
      static let stgTxtDemoMode = "stg_txt_demo_mode"
      static let stgTxtHeaderDemoMode = "stg_txt_header_demo_mode"
      static let stgTxtFootnoteDemoMode = "stg_txt_footnote_demo_mode"
  }
    internal enum editProfile {
      static let stgTxtEditProfileNameInput = "stg_txt_edit_profile_name_input"
      static let stgTxtEditProfileBgColorTitle = "stg_txt_edit_profile_bg_color_title"
      static let stgTxtEditProfileBgColorPicker = "stg_txt_edit_profile_bg_color_picker"
      static let stgBtnEditProfileDelete = "stg_btn_edit_profile_delete"
      static let stgBtnEditProfileLogin = "stg_btn_edit_profile_login"
      static let stgBtnEditProfileLogout = "stg_btn_edit_profile_logout"
      static let stgTxtEditProfileLogoutInfo = "stg_txt_edit_profile_logout_info"
      static let stgTxtEditProfileName = "stg_txt_edit_profile_name"
      static let stgTxtEditProfileInsuranceCompany = "stg_txt_edit_profile_insurance_company"
      static let stgTxtEditProfileCan = "stg_txt_edit_profile_can"
      static let stgTxtEditProfileInsuranceId = "stg_txt_edit_profile_insurance_id"
      static let stgTxtEditProfileLoginSectionTitle = "stg_txt_edit_profile_login_section_title"
      static let stgTxtEditProfileLoginSectionActivate = "stg_txt_edit_profile_login_section_activate"
      static let stgTxtEditProfileLoginSectionConnectedDevices = "stg_txt_edit_profile_login_section_connected_devices"
      static let stgTxtEditProfileLoginSectionShowHint = "stg_txt_edit_profile_login_section_show_hint"
      static let stgTxtEditProfileSecuritySectionTitle = "stg_txt_edit_profile_security_section_title"
      static let stgBtnEditProfileSecuritySectionShowTokens = "stg_btn_edit_profile_security_section_show_tokens"
      static let stgBtnEditProfileSecuritySectionShowAuditEvents = "stg_btn_edit_profile_security_section_show_audit_events"
      static let stgTxtEditProfileSecurityShowTokensHint = "stg_txt_edit_profile_security_show_tokens_hint"
  }
    internal enum foss {
      static let stgDprTxtFoss = "stg_dpr_txt_foss"
  }
    internal enum hint {
      static let hintTxtOrderEgk = "hint_txt_order_egk"
  }
    internal enum legalNotice {
      static let stgLnoTxtHeaderLegalInfo = "stg_lno_txt_header_legal_info"
      static let stgLnoTxtLegalNotice = "stg_lno_txt_legal_notice"
      static let stgLnoLinkContact = "stg_lno_link_contact"
      static let stgLnoMailContact = "stg_lno_mail_contact"
      static let stgLnoPhoneContact = "stg_lno_phone_contact"
  }
    internal enum newProfile {
      static let stgTxtNewProfileBgColorTitle = "stg_txt_new_profile_bg_color_title"
      static let stgTxtNewProfileBgColorPicker = "stg_txt_new_profile_bg_color_picker"
      static let stgBtnNewProfileSave = "stg_btn_new_profile_save"
      static let stgBtnNewProfileCancel = "stg_btn_new_profile_cancel"
      static let stgInpNewProfileName = "stg_inp_new_profile_name"
  }
    internal enum profiles {
      static let stgTxtHeaderProfiles = "stg_txt_header_profiles"
      static let stgBtnProfile = "stg_btn_profile"
      static let stgConProfiles = "stg_con_profiles"
      static let stgBtnNewProfile = "stg_btn_new_profile"
  }
    internal enum security {
      static let stgTxtHeaderSecurity = "stg_txt_header_security"
      static let stgTxtSecurityFaceid = "stg_txt_security_faceid"
      static let stgTxtSecurityTouchid = "stg_txt_security_touchid"
      static let stgTxtSecurityPassword = "stg_txt_security_password"
      static let stgTxtSecurityTokens = "stg_txt_security_tokens"
  }
    internal enum termsOfUse {
      static let stgTouTxtTermsOfUse = "stg_tou_txt_terms_of_use"
      static let stgWwTermsOfUse = "stg_ww_terms_of_use"
      static let stgBtnTermsOfUseClose = "stg_btn_terms_of_use_close"
  }
    internal enum tokens {
      static let stgTknTxtAccessToken = "stg_tkn_txt_access_token"
      static let stgTknTxtSsoToken = "stg_tkn_txt_sso_token"
  }
    internal enum tracking {
      static let stgTrkTxtTitle = "stg_trk_txt_title"
      static let stgTrkTxtExplanation = "stg_trk_txt_explanation"
      static let stgTrkBtnTitle = "stg_trk_btn_title"
      static let stgTrkTxtFootnote = "stg_trk_txt_footnote"
      static let stgTrkBtnYes = "stg_trk_btn_yes"
      static let stgTrkBtnNo = "stg_trk_btn_no"
  }
    }
}
// swiftlint:enable identifier_name line_length number_separator type_body_length
