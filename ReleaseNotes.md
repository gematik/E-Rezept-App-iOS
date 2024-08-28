# Release 1.25.0

### fixed (5 changes)

- Fix multiple redeem triggers by adding blocking to redeem button
- Fix UITests where in progress prescription should never be archived
- Fix warning dialog not showing while using biometrics
- Fixed archived prescriptions can be selected
- Fix wrong direct assignment hint view

### internal (4 changes)

- Replace GemCommonsKit logging with OSLog
- Add E2E Test trigger for nightly builds
- Fix build for Xcode > beta 3
- Change clientId to new value, remove old, no longer functional environments

### added (4 changes)

- Add share button to data matrix code view
- Add pharmacy infos to order details
- Add tap for dismiss for action toasts.
- Add update for remote prescriptions before redeeming prescriptions

### changed (1 change)

- Change prescription status message to be more precise for status computed and inProgess

# Release 1.24.0

### changed (2 changes)

 - Change prescription status message to be more precise for status computed and inProgess
 - Parse environment variables from development.env{,.default} file
 
### added (8 changes)

 - Add pharmacy infos to order details
 - Add tap for dismiss for action toasts.
 - Add feedback for various AFOs
 - Add Remember Insurance Name
 - Add alert before deleting prescriptions with charge item
 - Add Switch to map from searchresult
 - Add waiting status for remote prescription
 - Add medication reminder for scanned tasks

### fixed (6 changes)

 - Fix warning dialog not showing while using biometrics
 - Fix archived prescriptions can be selected
 - Fix wrong direct assignment hint view
 - Fix cardwall delegate finish for charge items
 - Fix a pharmacy’s cached location gets send when the near-filter has been removed
 - Fix that MVOs are sometimes redeemable when they shouldn't be

### internal (2 changes)

 - Refactor environment configuration of App/IntegrationTests
 - Replace zxingify-objc dependency with zxing-cpp

# Release 1.23.1

### added (12 changes)

 - Add alert before deleting prescriptions with charge item
 - Add Switch to map from searchresult
 - Add waiting status for remote prescription
 - Add uitests for ChangePasswordView
 - Add and improve AFO references and generation script
 - Add a help screen for GID login
 - Add uitests for prescription detail testing aut idem
 - Add auto trigger for biometrics when password is also setup
 - Add share functionallity to prescription detail
 - Add item based backport for NavigationLink supporting onTap
 - Add language settings button to settings
 - Add Emoji and Memoji (via Stickers) support for profile avatars

### internal (7 changes)

 - Refactor environment configuration of App/IntergrationTests
 - Replace zxingify-objc dependency with zxing-cpp
 - Change SAST and SCA to Snyk
 - Update to SwiftUI Introspect v1.1.3
 - Fix warnings with unknown and default enum cases
 - Add automated E2E Test builds to Release and MR builds
 - Automate Health Insurance contact list pulling

### removed (1 change)

 - Remove TLS Pinning in favor of Certificate Transparency (agreed upon with BSI)

### fixed (5 changes)

 - Fix localization for toasts
 - Fix snapshot tests using current date instead of static one
 - Fix additional string localizations
 - Use correct Dates for MVO
 - Fix manual logout sometimes not removing biometrics.

### changed (6 changes)

 - Upgrade Swift-OpenSSL dependency (OpenSSL 3.2.1)
 - Avoid reading the Authentication certificate from HealthCard when the one read...
 - Add extra aut idem entry to PrescriptionDetailView
 - Bump TCA Version to 1.9.1
 - Add password change option in security settings
 - Main Screen NewProfile and EditProfileName

# Release 1.22.1

### internal (6 changes)

 - Add automated E2E Test builds to Release and MR builds
 - Automate Health Insurance contact list pulling
 - Add fastlane plugin for bumping versions and setting API Keys
 - Prepare TCA 1.8
 - Add integration tests trigger to release builds
 - Added missing dependencies for IntegrationTests

### changed (5 changes)

 - Bump TCA Version to 1.9.1
 - Add password change option in security settings
 - Main Screen NewProfile and EditProfileName
 - Update localization
 - Rename eRpApp to eRpFeatures and moved it to SPM

### added (4 changes)

 - Add language settings button to settings
 - Add Emoji and Memoji (via Stickers) support for profile avatars
 - Add Community to contact options
 - Add UI-Test for MapSearch

### fixed (2 changes)

 - Fix bugged string localization
 - Fix issues and UITests with redeeming from details

### other (2 changes)

 - Refactor HealthCardPasswordReadCardDomain to use NFCHealthCardSession API
 - Refactor ReadCardDomain to use NFCHealthCardSession API Part 2 (w/ biometrics)

# Release 1.21.0

### added (7 changes)

 - Add tests for MedicationScheduleStore
 - Add more interpretations for dosage instructions
 - Reintroduce redeem buttons within prescription details
 - Add PictureButtonStyle
 - Add trigger for rating dialog after successful redeeming a prescription
 - Add UITest Helpers & Convenience to support testing redeeming
 - Add localization for "bg", "da", "he_IL", "cs", "nl", "it", "ro"

### fixed (2 changes)

 - Fix generated DMC codes to only contain 3 prescriptions
 - Fix address validation against specification

### other (1 change)

 - Refactor ReadCardDomain to use NFCHealthCardSession API Part 1 (w/o biometrics)

### changed (2 changes)

 - Moved eRpStyleKit to SPM
 - Moved FHIRClient AVS Pharmacy eRpRemoteStorage eRpLocalStorage and eRpKit to SPM

# Release 1.20.0

### fixed (6 changes)

 - Fix feedback and add tests
 - Fix prescriptions that are still in progress but expired
 - Fix accessibility and time sorting of MedicationReminders
 - Fix Gesundheits ID bottom banner to reappear
 - Fix chargeItem revoke consent
 - Fix deleting scheduled notifications

### added (11 changes)

 - Add check for forced update upon app startup
 - Add UITests for Prescription Status
 - Add recommendation for eGK while selection login method
 - Add UITests for MedicationReminder
 - Add Map for searching pharmacies
 - Add german dictionary for password strength tester
 - Add LoginHandlerServiceFactory and SmartMockLoginHandler
 - Add Medication Reminder
 - Add new pinning of RSA Certificate for FD
 - Add medication schedule to medication detail
 - Medication plan for scheduling applications

### changed (8 changes)

 - Moved IDP TrustStore HTTPClient TestUtils and VAUClient to SPM
 - Update Datenschutzerklärung
 - Change the demo mode to be logged in immediately
 - Change the 5 seconds forced delay for gID login in favor of just waiting for...
 - Changed medication reminder finite name, default dosage and dosage instructions
 - Fix buttons embedded in SwiftUI forms
 - Fix crash with negative day count in medication reminder
 - Changed MedicationReminder layout and options

### internal (1 change)

 - Removed Fasttrack name in favor of gID

### removed (1 change)

 - Remove Fasttrack implementation from IDPSession and IDPClient

# Release 1.19.0

### changed (5 changes)

 - Change the 5 seconds forced delay for gID login
 - Changed medication reminder finite name, default dosage and dosage instructions
 - Fix buttons embedded in SwiftUI forms
 - Fix crash with negative day count in medication reminder
 - Changed MedicationPlan layout and options

### fixed (3 changes)

 - Fix GesundheitsID bottom banner to reappear
 - Fix chargeItem revoke consent
 - Fix deleting scheduled notifications

### added (4 changes)

 - Add Medication Reminder
 - Add new pinning of RSA Certificate for FD
 - Add medication schedule to medication detail
 - Medication plan for scheduling applications

### removed (1 change)

 - Remove Fasttrack implementation from IDPSession and IDPClient

# Release 1.18.0

fixed (7 changes)

  - Fix biometrics registering FaceID instead of TouchID
  - Fix usage of correct profile when storing key for biometrics
  - Fix the favorite status of pharmacies within the list when update through the details
  - Fix alerts with double cancel buttons
  - Fix sorting of registered devices by date
  - Fix TabView not Updating in iO15
  - Fix Bug that disables AppSecurityOptions and wont let it activate it anymore

changed (6 changes)

  - Change UI of ChargeItemView
  - Change Primary Button paddings
  - Refine MainView drawers' UI
  - Change OrdersDomain to use OrdersRepository as preperation for adding ChargeItems
  - Change UI of PharmacyRedeemView
  - Improve ChargeItemConsentService error handling

added (6 changes)

  - Add quantity of MedicationRequest to local store and present it in UI
  - Add error handling for OrdersDomain
  - Add ChargeItems to OrderDetail
  - Add grant consent to receive ChargeItems on MainScreen after first login
  - Add charge item and hints for prescription details
  - Add GesundheitsID Implementation

# Release 1.17.0

### fixed (4 changes)
 
- Fix TabView not updating in iOS 15
- Fix bug that disables AppSecurityOptions with no possibility for re-activation
- Fix health insurance contact list
- Fix routing to specific settings-views for eGK Unlock and EditProfileView

# Release 1.16.0

## 1.16.0

### added (3 changes)

- Add toasts modifier for swiftui and swiftui + tca
- Add support for universal links for pharmacies
- Make change of scanned prescription name possible

### fixed (2 changes)

- Fix Title and Subtitle of ChargeItems-PDF
- Fix Swiping can skip pages by removing the next button and adding timer for the welcome view

### changed (1 change)

- Changed cardwall read card screen

### internal (4 changes)

- Fix warnings related to Xcode 15 / Swift 6
- Fix warnings from Xcode 15
- Fix localization keys
- Update to Xcode 15

## 1.15.0

### fixed (9 changes)

- Fix deleting profile data if authentication with pairing scope is used
- Fix CardWall to use correct profile Id in all views
- Fix cardwall help not redirecting to insurance login
- Fix prescriptions not loading in a paged manner
- Fix onboarding is skippable by fast swiping
- Fix deleting any pairing IDPToken after doing logout
- Fix alert destination for deleting tasks
- Fix async task for views with multiple actions on appear
- Fix presenting authentication hint when user is already authenticated for RegisteredDevicesDomain and ashow results after successful login

### changed (4 changes)

- Change loading audit events to only load one page per trigger
- Change UI of RedeemMethodsView
- Change using FHIR workflow version 1.2 for all requests
- Change presenting a better error and delete the pairing key when authorization with paired device fails

### refactor (1 change)

- Consolidate EditProfilePictureView and EditProfilePictureFullView

### added (1 change)

- Add UITests setup including SmartMocks to record/replay APIs

### fix (1 change)

- Fix format of tiles on redeem type selection screen

### hotfix (1 change)

- Fix blank screen in redeem process (TCA)

## 1.14.0

### fixed (3 changes)

- Fix for no pharmacy location
- Fix profile kvnr check
- Fixed NSLocationAlwaysUsageDescription deprecation

### internal (3 changes)

- Add missing Package.resolved + FOSS for TCA 0.57
- Use TCA-NavigationLinkStore when Links are ChildState-driven
- Add fetching for subtree repositiory to prevent missing commit hashes while pushing the subtree

### changed (1 change)

- Update DataPrivacy.html

### added (1 change)

- Add explanations for latest audit feedback

# Release 1.13.0

## changed (1 change)

- Change noctu yes/no to use own strings which are easier to understand

## fixed (2 changes)

- Fix delete for ChargeItem and Task
- Fix screen transitions when state is niled out

## added (2 changes)

- Add prefix of patient and practitioner to name (merge request)
- Tap on active TabItem leads to root view of the corresponding TabView's content (merge request)

## internal (1 change)

- More (BSI) requirement annotations (merge request)

# Release 1.12.0

## added (3 changes)

- Add option to take new photo
- Add dark mode colours to profile picker chips
- Add more documentation for implemented specifications

## changed (2 changes)

- Make TabView ToolBar opaque
- Boost FOSS.html automation

## fixed (8 changes)

- Fix valid date for prescription
- Fix fetching all communications without profile relation
- Fix avs redeem services after login to also load the certificate
- Fix deleting task with optional accessCode
- Fix Version detection for automatic release notes
- Fix open filter doesn't include closing soon
- Fix contact list
- Fix Insurance no contact overall shows directly

# Release 1.11.0

## fixed (9 changes)

 - Fix Insurance no contact overall shows directly
 - Fix missing ASN1Kit dependency
 - Fix UI of directAssignment
 - Fix profile picture edit in settings
 - Fix ViewStatus for PKV direct assignments
 - Fix idp cardwall background color
 - Fix flaky CardWallReadCardDomain test
 - Fix swipe bug that allows skipping LegalInfo view
 - Fix AVS certificate parsing

## added (4 changes)

 - Add new intermediate certificate pinning
 - Add PDF creation for charge items
 - Add image gallery and file import with barcode detection
 - Handle external authentication for PKV

## changed (2 changes)

 - Change when AVS service configured it will also be used as configuration for TI services
 - Change sorting after date and name for prescriptions

# Release 1.9.0

## added (9 changes)

- Add logic to load avs certificates 
- Add parsing for the avs endpoints 
- Add ErxSparseChargeItem as minimal data set for a ChargeItem 
- Add RemoteStore delete for charge item 
- Add ErxChargeItem to ErxTaskRepository 
- Add and rework existing analytics identifier 
- Add toolbar menu for new PrescriptionDetailView
- Add MedicationView as child view of PrescriptionDetailView
- Add tracking keys for medication detail screens and update AccessibilityIdetifier.yaml 

## changed (7 changes)

- Change using new PrescriptionDetailView in MainView, PrescriptionArchiveView and OrderDetailView
- Change UI of CardWallIntroductionView
- Change profile for communications and consent to have version id
- Change publish repo and update jazzy for iPhone 14
- Change loading DiscoveryDocument to be loaded once instead of loading for each profile
- Change local store FHIR parsing to use duplicates from remote store
- Change name of ChargeItemsDomain to ChargeItemListDomain

## removed (2 change)

- Remove profile picker from Navigation Toolbar
- Remove old prescription detail screens


## fixed (3 changes)

- Fix parsing charge item
- Fix snapshot tests 
- Fix Integration Tests

# Release 1.8.1

## 1.8.1 (2023-05-05)

This release should fix the broken documentation pipeline. 

# Release 1.6.0

### added (2 changes)

- Add tooltips to MainView
- Add missing medication types and add some other kbv values to the parser
- Add foundation for tooltips and tooltipContainers

### changed (1 change)

- Update localization

### removed (1 change)

- Remove auditEvent variable from ErxTask since it was never used

### fixed (5 changes)

- Fix nfc alert showing up while exiting demo modus
- Fix onboarding where it was possible to pass auth screen without consious selection
- Fix sticky headers to use correct blurring material for darkmode
- Fix cardwall and main cleanups
- Fix no result message is not centered

# Release 1.5.0

### added (9 changes)

- Add search for fasttrack insurance list
- Add ScrollViewWithStickyHeader to pharmacy search and main view
- Add content square analytics to app and connect it with cardwall screens
- Add clouds and spinner in horizontal profile chips
- Add PrescriptionRepository that exposes ActivityIndicating to UserSession
- Add prescription archive view
- Add ActivityIndicating property to UserProfile
- Add WelcomeDrawer
- Add new main view empty state, profile icon and login / refresh buttons

### changed (6 changes)

- Change CS tracker with placeholder so that tracking stays disabled in next release
- Change OrderHealthCardView to use TCA (routes)
- Change debug view to be easier to understand
- Change CreatePasswordDomain to be route of settings domain
- Change SettingsView to have route for debug view
- Change SettingsView to have routes for navigation so that we can track them

### removed (1 change)

- Remove grouping from prescriptions

### fixed 7 changes)

- Fix health insurance contact list
- Fix cancel button for pharamcy search not visible correctly and dark mode ui glitch
- Fix fasttrack sso using wrong redirect
- Fix alert title when disabling demo mode
- Fix fasttrack selection domain sending multiple requests for various users
- Fix sticky scrollview header not blocking touches
- Fix iOS 16 issue while presenting app authentication dialog

### internal (4 changes)

- Added more multiple prescription snapshot test data
- Changed snapshot precision
- Make UserProfileService single point of contact for profile domains
- Change swift-composable-architecture to version 0.47.2 and remove deprecations and errors

# Release 1.4.9

### added (2 changes)
 
- Add navigation to amend CAN/PIN/PUK from alert in HealthCardPasswordDomain  
- Add autogeneration for Route.Tag types 

### changed (2 change)

- Change AlertState usage to ErpAlertState to prepare for better user facing error tracking 
- Change the alert's primary action button bold in Card Wall 

### fixed (7 changes)

- Fix DebugPharmacy scanner and solve analyse warnings  
- Fix NFCSignature error cast return value  
- Fix wrong Voice Over text  
- Fix creating profile without name  
- Fix UI of OrderHealthCardView  
- Fix multiplePrescription to display status only if prescription is of type multiple prescription  
- Fix unusable password creation when switching from biometrics to password secured app  

### internal (4 changes)

- Update OpenSSL-Swift dependency  
- Rename an separate GroupedPrescriptionDomain from MainDomain  
- Change _pullback to use runtimeWarning instead of debugger breakpoint  
- Added multiple prescription tests  

# Release 1.4.8

### added (8 changes)

- Add multiple prescriptions UI
- Add feature to mark and unmark pharmacies as favorite
- Add new "New Profile" dialog to main screen
- Add last used pharmacies to start search view
- Add fields to PharmacyLocation and PharmacyLocationEntity that are used for the favorite feature
- Add multiple prescription information
- Add saving pharmacy location after redeem
- Add smallSheet modifier for presenting smaller sheets

### changed (3 changes)

- Change pharmacy search filters to be within a smallSheet
- Change SDK Version to 16 and Xcode to 14.0.0
- Change pharmacy search screen appearance

### fixed (4 changes)

- Fix missing localization for profile picture
- Fix password autofill preventing custom password within onboarding
- Fix iOS 16 keyboard safearea bug
- Fix tests failing due to actual time usage

# Release 1.4.7

### added (2 changes)

- Add card wall to pharmacy redeem view
- Add forgot PIN to settings view

### changed (1 change)

- Apply new style to PharmacySearchView

### fixed (4 changes)

- Fix using login option .loginWithBiometry when using DemoMode
- Fix "Direktzuweisung" in demo mode to not have an access code
- Fix redeem success video player
- Fix missing eRpKit dependency for Pharmacy module

### internal (1 change)

- Add order and order detail domain tests

# Release 1.4.6

### added (2 changes)

- Add more error cases for PIN verification
- Add feature to search for insurances in OrderHealthCardView

### changed (2 changes)

- Change to use a router for navigation in pharmacy redeem domain
- Change RedeemDomain into RedeemMethodsDomain and use router

### fixed (3 changes)

- Fix phone number URL's
- Fix health insurance list
- Fix iOS 16 navigation crash by raising publisher delay

### internal (3 changes)

- Change HealthCardPasswordDomain by introducing ViewStates and RouteTags
- Change swift snapshot testing to version 1.10.0
- Change The Composable Architecture to Version 0.40.2

# Release 1.4.5

### added (4 changes)

- Add setting custom PIN via command ChangeReferenceData (without PUK)
- Add temporary status feedback after redeeming (via TI and via AVS)
- Add custom alert messages for nfc tag connection issues
- Add alert when custom PIN is too long

### fixed (2 changes)

- Fix TransitionMode for CardWallLoginView
- Fix that CANView now displays the saved CAN

### changed (3 changes)

- Change messages are now grouped into orders with a corresponding timeline
- Change UI for order and subviews
- Change redeeming to only work on task of status `ready`

### internal (3 change)

- Update OHCKit dependency
- Add integration test for redeeming via TI
- Fix integration tests

# Release 1.4.4

### added (5 changes)

- Add direct assignment (Direktzuweisung) to prescription details
- Add flowType to ErxTask
- Add sharing and importing of prescriptions
- Add unlock eGK via PUK/custom PIN
- Add copyright info for OpenStreetMaps to FOSS.html

### fixed (3 changes)

- Fix Voiceover for CANInput Field
- Fix navigation of CardWallLoginOptionView
- Fix linting and dependency issues for published code

### internal (4 change)

- Refactor CardWall to use routes
- Add entity identifiers for prescription orders
- Inject Schedulers into DemoSessionContainer
- Refactor PrescriptionDetailDomain to use Routes

# Release 1.4.3

### added (5 changes)

- Add direct assignment (Direktzuweisung) to prescription details
- Add flowType to ErxTask
- Add sharing and importing of prescriptions
- Add unlock eGK via PUK/custom PIN
- Add copyright info for OpenStreetMaps to FOSS.html

### fixed (3 changes)

- Fix Voiceover for CANInput Field
- Fix navigation of CardWallLoginOptionView
- Fix login error, where key for biometry is available but not (anymore) registered with IDP

### internal (4 change)

- Refactor CardWall to use routes
- Add entity identifiers for prescription orders
- Inject Schedulers into DemoSessionContainer
- Refactor PrescriptionDetailDomain to use Routes

# Release 1.4.2

### added (4 changes)

- Add new localizations for uk, ar, pl and ru
- Adds LOT number and expiration date to prescription details
- Add flashlight when using the camera
- Add ReadCardHelpView to help connect with eGK
- Add multiple medication dispenses

### changed (1 change)

- Change loading medication dispenses after status change

### internal (1 change)

- Add AVS integration test


# Release 1.4.0

### fixed (2 changes)

- Fix the footnote is multiline for iOS 14
- Fix the insurance contact list

### added (7 changes)

- Enable profiles
- Add timer for locking an app without user interaction and enable profiles for live app
- Add Validator to PharmacyRedeemDomain and PharmacyContactDomain
- Add camera scanner to read the CAN from an eGK
- Improve error handling for redeem via AVS
- Add support for additional http header for debugging purposes
- Add workflow version 1.2.0 and prescription version 1.1.0 tests and examples

# Release 1.3.3

### added (2 changes)

- Add fallback CA for IDP
- Save Information of transaction with the AVS

### fixed (3 changes)

- Fix demo mode sometimes starting with recipes, despite being not logged in
- Fix wrong error message when biometric check fails due to user
- Fix the typos

### changed (1 change)

- Upgrade FHIR Dependency and remove several warnings

### removec (1 change)

- Change delete piwik tracker

# Release 1.3.2

### fixed

  - Fix prescription status not being updated
  - Fix pharmacies showing wrong service types
  - Fix error message for invalidated biometric keys
  - Fix saving the CAN and PIN after failed eGK connection
  - Fix UI of the Pharmacy address
  - Fix CapabilitiesView UI
  - Fix OrderEGK Hint only displayed if not logged in

### added

  - Add check for finished biometric setup before usage
  - Add validation to AVSMessage
  - Add AVS redeem service to PharmacyRedeemDomain
  - Add error identifier for all errors with annotations

### changed

  - Onboarding redesign

# Release 1.3.1 (not tagged)

### changed

  - Change audit events paging to respect FHIR paging mechanism
  - Upgrade Xcode version to 13.3.1

### added

  - Add DebugView for redeeming via AVS module
  - Alternative Zuweisung: AVS-Modul

### fixed

  - Fix recipes showing for no longer selected profile
  - Fix the insurance contact list
  - Fix textfield focus state in forms
  - Fix dependency problem of FHIR SPM package

# Release 1.3.0 (not tagged)

### fixed

  - Fix various voice over bugs
  - Fix the mail option to reset pin to displayed correctly
  - Fix profile name usability with delete Button
  - Fix pharmacy faq url
  - Fix task deletion when task status is `in-progress`
  - Fix layout and spelling issues within redeem screens

### added

  - Add possibility to report NFC card reader session error via e-mail
  - Add support for suggested passwords created by icloud keychain
  - Enable FastTrack for all users

### changed

  - Change OpenHealthCardKit dependency to version 3.0.7
  - Refactor ErxTask: Dummies, Demo, Fixture
  - Add usage of mint for xcodegen and swiftgen

# Release 1.2.7

### fixed (2 changes)

- Fix demo mode using physical card
- Fix string template for plurals
 
### feature (1 change)
 
- Parse faulty KBV FHIR bundle and display corresponding error messages

### added (3 changes)

- Add shipment info to PharmacyRedeemView
- Add contact options in settings view
- Add SelectionConfigurationStyle to support styling of a section borders

# Release 1.2.6

### fixed (2 changes)

- Fix insurance contact data
- Fix accessibility ids and behavior for various views

### internal (1 change)

- Add Domain Tests IDPCardWall

### added (1 change)

- Add store for ShipmentInfo

# Release 1.2.5

added (5 changes)

 - Delete device pairing from IDP and local in EditProfileDomain
 - Add registered devices list to profiles
 - Add new dosage form key
 - Add UserSessionProvider to allow requests for non selected profiles
 - Add edit profile login section

fixed (5 changes)

 - Fix SSO for ExtenalAuthentication
 - Fix the RedeemSuccessView not displaying the content correctly
 - Fix displaying hint in PharmacyDetailView
 - Fix email content for contacting health insurance
 - Fix display CAN in user profile

changed (1 change)

 - Change Profile to not parse the relation of audit events for performance reasons

# Release 1.2.4

fixed (2 changes)

  - Fix wrong URL forwarding
  - Fix animation flicker within reservation animation and compress all videos a bit

added (1 change)

  - Add hint for ordering a new health card

# Release 1.2.3

fixed (12 changes)

  - Fix settings view design
  - Fix flaky test due to timezone offsets
  - Fix low detail prescription status
  - Fix current profile icon on main screen layout issues
  - Fix Settings to popToRootview upon routing
  - Fix log details are no longer visible
  - Fix KeychainStore retain cycle
  - Fix retain cycle in DEfaultTrustStoreSession
  - Fix self retained assign
  - Fix appearing card wall after switching from a profile that was authenticated...
  - Fix self retained assign
  - Fix pharmacy search to be streamwrapped so that user session changes will be propagated
  - Fix button sizing and some colors according to figma

added (3 changes)

  - Add profile picker to pharmacy and messages tabs
  - Add Accessibility Identifier and grouping for Prescription Details
  - Add eRpStyleKit as a new shared library to style the app

internal (1 changes)

  - Add pinning for swiftpm dependencies

changed (5 changes)

  - Change CardWallReadCard to show eGK positioning
  - Change NewProfileView to use new styling
  - Change EditProfileView to use new eRpStyleKit
  - Change UI for the profile picker
  - Change order of loading from remote

# Release 1.2.2

### fixed (3 changes)

- Fix UI for current profile on mainscreen
- Fix app configuration to be observed from outside of StandardUserSession to solve memory leaks
- Fix onboarding failing on simulator export due to missing entitlement

### changed (1 change)

- Change the PickeupCode view to only show when the payload string is not empty

### added (2 changes)

- Add paging to AuditEvent View and database access
- Add test for task bundle version 1.2

### internal (1 change)

- Add StringAsset template for initializer overloads

# Release 1.2.1

### changed (5 changes)

- Change CardWallReadCard screen to reflect latest ux decisions
- Refactore old TCA test store syntax to new syntax
- Change order of tabbar items
- Change default Xcode to version 13.2.1 (and SDK 15.2)
- Use StringAsset for all localizations (not just `LocalizedStringKey`)

### fixed (4 changes)

- Fix recipe block accessibility hierarchy
- Fix uppercase letters for logout button
- Fix showing the pickup code with DMC for unread messages
- Fix crash when data matrix code message is empty

### added (5 change)

- Add implementation for retrieving list of registered biometric devices
- Add AuditEvents to profiles screen
- Add paging to AuditEvent API Calls
- Add migration step for wiping all audit events so thay can be loaded again (with paging)
- Add connection details (KVNR, name, insurance) for user profile

### removed (1 change)

- Remove main view authorisation hint

# Release 1.2.0

### added (11 changes)

- Add Migration Manager
- Add AppMigrationDomain to start migration logic if needed
- Add removal of SecureStorage data upon profile deletion
- Add database relationship between auditEvents and profile
- Add medication hint to gesund.bund.de to dosage instructions
- Add ProfilesDomain and according views
- Add Edit Profile and Add New Profile
- Add Profile functionality to DemoMode
- Add Profile Selection to MainScreen
- Add Profile creation to onboarding
- Add pharmacy search to TabBar

### changed (9 changes)

- Move IDPTokenView to be located inside EditProfile instead of SettingsView
- Change profile name length in navigation header and remove navigation title in main view
- Move logout to individual Profile Screens
- Change to fetch for a specific task to be done without profile predicate so
- Refactor pharmacy search view
- Move SettingsDomain and DebugDomain from MainDomain into AppDomain
- Empty search result view
- Location hint
- Refactor ErxTaskRepository to not be generic

### internal (3 changes)

- Update TCA, Introspect, CombineSchedulers dependencies
- Add ApoVZ Integration Tests
- Reenable Integration Tests

### removed (1 change)

- Remove unused strings and variables

# Release 1.1.2

### added (2 changes)

- Add profile entity to core data store
- Add PendingExtAuthenticationView a.k.a. snackbar to MainScreen (External Authentication)

### changed (4 changes)

- Update health insurance contact list
- Change CoreDataController so that we can present store initialization errors to the user
- Change ErxTaskCoreDataStore to be seperated from ProfileCoreDataStore
- Updated localizations to fix typos

### fixed (2 changes)

- Fix overall performance, especially for password inputs
- Fix layouting issues within onboarding password creation and settings password creation/updating

### removed (2 changes)

- Remove AppContainer and almost all singleton like dependencies.
- Removed unused accessibility identifier and unused localization keys

# Release 1.1.1

Update, regarding the `1.1.0 RC` Releases: We accidentally tagged recent commits with wrong version labels. These were meant to be named `1.1.1 RC`. The actual 1.1.0 (without the `RC`) is tagged correctly.

### added

- Add password strength indicator and mandatory password strength
- Add localization for weekday names within pharmacies details

### internal

- Add parameterization for localization to stencils
- Move some CI tasks to Fastfile

### fixed

- Fix layouts for alternate authentication app selection screen
- Fix authentication window to be created with the correct scene so that onDismiss and onAppear are called in the correct order

# Release 1.1.0-RC3

### added (5 changes)

- Add additional jailbreak detection
- Add external authentication implementation to IDPClient as IDPService as well as simple initial UI
- Add UI for upcoming external authentication feature
- Add FeatureFlag for external authentication
- Add dedicated redirect_uri for external authentication
- Add new order health card screens with optional support for mail, phone and web
- Add password strength indicator and mandatory password strength

### changed (1 change)

- Change App Icon to new Design

### fixed (1 change)

- Fix wording for onboarding password dialog in case of an update
- Fix mandatory password for normal onboarding screen

### internal (2 changes)

- Execute parametrizable intergration tests (in Jenkins)
- Add Konny app variant

# Release 1.1.0-RC2

### added (5 changes)

- Add additional jailbreak detection
- Add external authentication implementation to IDPClient as IDPService as well as simple initial UI
- Add UI for upcoming external authentication feature
- Add FeatureFlag for external authentication
- Add dedicated redirect_uri for external authentication
- Add new order health card screens with optional support for mail, phone and web
- Add password strength indicator and mandatory password strength

### changed (1 change)

- Change App Icon to new Design

### fixed (1 change)

- Fix wording for onboarding password dialog in case of an update

### internal (2 changes)

- Execute parametrizable intergration tests (in Jenkins)
- Add Konny app variant

# Release 1.1.0

### added (5 changes)

- Add additional jailbreak detection
- Add external authentication implementation to IDPClient as IDPService as well as simple initial UI
- Add UI for upcoming external authentication feature
- Add dedicated redirect_uri for external authentication
- Add new order health card screens with optional support for mail, phone and web

### changed (1 change)

- Change App Icon to new Design

### internal (2 changes)

- Execute parametrizable intergration tests (in Jenkins)
- Add Konny app variant

# Release 1.0.12

### added (5 changes)

- Add hint for failure app access
- Add mandatory app authenication to onboarding
- Add mandatory app authenication for existing users
- Add warning screen for rooted devices
- Add warning screen for devices without system passcode

### removed (1 change)

- Remove unsecure option from app security options

# Release 1.0.11

Added:

  - Add Login-Token display to settings menu

Changed:

  - Temporarily remove Order eGK
  - Improve Accessibility for UI-Tests

Fixed:

  - Fix recipe accepted Date
  - Fix recipe status

# Release 1.0.10

## fixes (1 change)

- Fix password view layouts


# Release 1.0.9

## feature (3 changes)

- Add authentication via passwords
- Add update existing password screen
- Change medication details to include substituted medications

# Release 1.0.8

## feature (4 changes)

- Add Scan KVNR to OrderEGKHelpView
- Add `E-Rezept ready` marker to pharmacy search results
- Add `E-Rezept ready` marker to pharmacy details
- Add feedback footnote to pharmacy search results

## internal (2 changes)

- Add virtual eGK scanning to debug view, fix fake device capabilities
- Extension of Debug Menu: simulated eGK

## fixed (1 change)

- Fix settings texts that were not fully visible

# Release 1.0.7

 - Initial Code Release
 - See [https://gematik.github.io/E-Rezept-App-iOS](https://gematik.github.io/E-Rezept-App-iOS) for the initial documentation
 - We are working on improving the development experience
 - Feel free to open issues for any kind of feedback


