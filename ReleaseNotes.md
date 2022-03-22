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


