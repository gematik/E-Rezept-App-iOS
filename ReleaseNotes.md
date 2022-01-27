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


