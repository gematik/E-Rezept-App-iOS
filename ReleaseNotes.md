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


