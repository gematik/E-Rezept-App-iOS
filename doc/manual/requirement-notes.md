[REQ:gemSpec_Krypt:A_17207,A_17359] brainpoolP256r1 is used for creating/verifying key for signature usage; exception: Biometric use case uses secp256r1 (is considered in respective specification)
[REQ:gemSpec_IDP_Frontend:A_20607,A_20609,A_20618] no exceptions set in NSAppTransportSecurity, HTTP via TLS is enforced; OS will use system root certificates in combination with set pinned certificates. see also: [Requirements for Connecting Using ATS](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html)
[REQ:gemSpec_Krypt:A_17322,A_17124,A_21275,A_21332,GS-A_4359,A_21275−01] no exceptions set in NSAppTransportSecurity, see also: [Requirements for Connecting Using ATS](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html) 
[REQ:gemSpec_eRp_FdV:A_20032-01] Note: grace period for OCSP responses is 12h
[REQ:gemSpec_Krypt:A_21218] Note: grace period for OCSP responses is 12h
[REQ:gemSpec_eRp_FdV:A_19188] session data (ACCESS_TOKEN, ID_TOKEN, SSO_TOKEN, CAN) is saved in the keychain. Its deletion is managed by the OS. The key chain is sandboxed and can only be shared with other apps by the same vendor when explicitly set. All other mentioned data is deleted.
[REQ:gemSpec_eRp_FdV:A_19229] Audit events will be deleted when the referencing task is deleted. Cascading relationship "task -> audit event" is defined in Sources/eRpLocalStorage/Prescriptions/ErxTask.xcdatamodeld/ErxTask.xcdatamodel/contents
[REQ:gemSpec_IDP_Frontend:A_20741] Configuration within `app-configuration.json`, organizational process as in A_20603
[REQ:gemSpec_Krypt:A_17205] The app does not use the TSL. All TSL related parts are handled within the eRp-FD.
[REQ:gemSpec_Krypt:A_17775,GS−A_5339] We cannot interfere with cipher suite lists, see [Requirements for Connecting Using ATS](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html) for actual order.
[REQ:gemSpec_Krypt:GS−A_5035,A_19215,A_20607] We use https only, see `DefaultHTTPClient.swift`. ATS forbids other connections.
[REQ:gemSpec_Krypt:GS−A_5322] There is no API to control the session length, developer forums suggest it is 10 minutes for iOS.
[REQ:gemSpec_Krypt:GS−A_5526,GS−A_5542] We use the recommended NSURLSession for best network security [Preventing insecure network connections](https://developer.apple.com/documentation/security/preventing_insecure_network_connections)
[REQ:gemSpec_eRp_FdV:A_19983] All used services except our analytics framework are permitted and attested by the Gematik and under the TI monitoring. The usage of our analytics framework is not under our control, but we exclusively send data to it and receive none.
[REQ:gemSpec_eRp_FdV:A_19982#1] The agreement to the use of the analytics framework can be revoked. But other agreements cannot be revoked, since the app would not operate properly.
[REQ:gemSpec_eRp_FdV:A_19981] The user is informed and required to accept this information via the data protection statement. Related data and services are listed in sections 5.
[REQ:gemSpec_eRp_FdV:A_19980#1] The user is informed and required to accept this information via the data protection statement. Related data and services are listed in sections 5.
[REQ:gemSpec_eRp_FdV:A_19979] We use external services: The Apothekenverzeichnis and our analytics framework. During the communication with the pharmacy, there will be data shared via a prescription code. The requirement to this feature is described in gemSpec_eRp_FdV sectin 5.2.3.10 and 5.2.3.11.
Our analytics framework does not use medical personal data, see DSFA section 5.6 Verarbeitungsvorgang 4: Rezepte einlösen
[REQ:gemSpec_eRp_FdV:A_19178] Is covered by our MSTG.
[REQ:gemSpec_eRp_FdV:A_19179#1] Annotation in code
[REQ:gemSpec_eRp_FdV:A_19181-01] There is an opt-in option for analytics. Full app functionality is available also without opting in. The user's choice is requested during onboarding and the user can opt-in and opt-out of analytics at any time. There are no further configuration choices. After successful authentication via health card the corresponding prescriptions, protocol data and messages are displayed.
[REQ:gemSpec_eRp_FdV:A_19182] In order to minimize the risk of unknown vulnerabilities in dependencies, we use different measures: We develop according to Security by Design Principles (see E-Rezept-App - SSDLC.pdf - Section Richtlinien, Vorgaben und Best Practices). We train our engineers focussing on secure design and coding best practices (see Sicherheitsschulungen.pdf). We publish our Code on Github and use a bug bounty program (https://www.gematik.de/datensicherheit -> Coordinated Vulnerability Disclosure Program) 
[REQ:gemSpec_eRp_FdV:A_19185] Communication with the Fachdienst is protocoled via Audit Events. The user can revise them in the Settings menu (Profile Settings).
[REQ:gemSpec_eRp_FdV:A_21324#1] Token-key and code-verifier are encoded into an JSON object.
[REQ:gemSpec_eRp_FdV:A_21325#1] AccessToken is encyrpted for each network request to the Fachdienst via VAUClient module.
[REQ:gemSpec_eRp_FdV:A_21326#1] ACCESS_TOKEN information is managed by IDPToken structure
[REQ:gemSpec_eRp_FdV:A_21327#1] ID_TOKEN information is managed by IDPToken structure 
[REQ:gemSpec_eRp_FdV:A_21328#1] Keychain storage encrypts session tokens.
[REQ:gemSpec_IDP_Frontend:A_20525] Not applicable as authenticator module is within FdV, not 3rd party app
[REQ:gemSpec_IDP_Frontend:A_20527] Not directly applicable as authenticator module is within FdV, not 3rd party app. AUTHORIZATION_CODE will be used directly.
[REQ:gemSpec_IDP_Frontend:A_20499] Not applicable as authenticator module is within FdV, not 3rd party app.
[REQ:gemSpec_IDP_Frontend:A_20525] Not applicable as authenticator module is within FdV. Consent is given by using the app.
[REQ:gemSpec_IDP_Frontend:A_21578] iOS only allows Biometric access via secure enclave or higher order apis.
[REQ:gemSpec_IDP_Frontend:A_21583] Secure Enclave is enforced with code attributes.
[REQ:gemSpec_IDP_Frontend:A_21584] There is no API to allow or disallow an biometric authentication, iOS is handling the authorization process while using the private key for any cryptographic operation.
[REQ:gemSpec_IDP_Frontend:A_21585] Default behavior for all apps when using private access group (https://developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps)
[REQ:gemSpec_IDP_Frontend:A_21586] iOS will delete all user related data after user-account reset. Key-Chain data is not being synced with iCloud since `kSecAttrSynchronizable` is not applied  
[REQ:gemSpec_IDP_Frontend:A_21590] References of `SecureEnclaveSignatureProvider` is limited to registration and altVerify usage.
[REQ:gemSpec_IDP_Frontend:A_20608,A_20608-01,A_20609,A_20618,A_20068-01]: Implemented with ATS within `Info.plist`, path: `NSAppTransportSecurity.NSPinnedDomains`
[REQ:gemSpec_eRp_FdV:A_20033,A_19739] Implemented with ATS within `Info.plist`, path: `NSAppTransportSecurity.NSPinnedDomains`
[REQ:gemSpec_eRp_FdV:A_19086,A_19087#1] Tracking is only implemented for the purpose of Usability-Tracking. Sessions are not persisted, session ids are recreated each app startup.
[REQ:gemSpec_eRp_FdV:A_19093#1,A_19094] Usage Tracking is called very sparse and boils down to one place where all visited screens are recorded. See usage of `@Dependency(\.tracker)` for all cases where the actual analytics framework is used.
[REQ:gemSpec_eRp_FdV:A_20193,A_20194] Camera is only used for scanning recipes and avatar setup. CoreLocation is used for pharmacy search. Usage is requested before actual first usage, the user is asked for permission. This is also enforced by the OS.
[REQ:gemSpec_eRp_FdV:A_22778#1] Encryption of message to the Pharmacy is done with/for all provided certificates/recipients.
[REQ:gemSpec_eRp_FdV:A_22779#1] Encrypted message is of form of a PKCS#7 container (CMS)
[REQ:gemSpec_eRp_FdV:A_20181#1] Screen that presents the DataMatrix code for redeeming a prescription only contains some static texts and the image of the code.
[REQ:gemSpec_eRp_FdV:A_20182] No advertisement or similar is presented in the app. Assigning a prescription to an pharmacy in only possible via the app's pharmacy search. Pharmacy search results are only based on search term and filter criteria set by the user.
[REQ:BSI-eRp-ePA:O.Purp_6#2] As most of the user decisions are client side no history is available. Only the current state can be inspected.
[REQ:BSI-eRp-ePA:O.Purp_7] Most libraries are self written and cover only what is needed. Dependencies are only included if really necessary. We think about including only sub packages, but as most dependencies are very small, this is hardly used. Besides that, no means of removing unused dependency functionality is available for the platform.
[REQ:BSI-eRp-ePA:O.Arch_1#1] See external SSDLC documentation.
[REQ:BSI-eRp-ePA:O.Arch_2#1] Data storage is divided into service driven data that is stored within a database, user driven data that must be secured, such as the eGK CAN or the eGK Certificate and user specific data that is not critical, such as already seen tooltips or preferences.
[REQ:BSI-eRp-ePA:O.Arch_3#1] All cryptography is specified by gemSpec_Krypt in corporation with BSI
[REQ:BSI-eRp-ePA:O.Arch_4#1] All data is either stored encrypted within the keychain or excluded from system backup, which also excludes files from cloud backup.
[REQ:BSI-eRp-ePA:O.Arch_5#1] See server audit for verification.
[REQ:BSI-eRp-ePA:O.Arch_6#1] Apple already implements this with a signed binary delivered to customers. An altered application can only run on a jailbroken device. If a user is using a jailbroken device, may it be known or unknown, we display a security alert so a user can make an informed decision to use or not use the application.
[REQ:BSI-eRp-ePA:O.Arch_7#1] We use OSS where no guarantees are made. Besides OpenSSL and XZING we screen the whole code and know pretty good what the libraries are doing. Most dependencies have a very narrow use case and are UI related.
[REQ:BSI-eRp-ePA:O.Arch_9#1] Link within DataPrivacy.html to https://www.gematik.de/datensicherheit
[REQ:BSI-eRp-ePA:O.Arch_10#1] Currently only implemented via APIKey usage against APOVZD and FD. All requests against the backends may respond with an 403 status code. The App stays usable, but only without any server connection.
[REQ:BSI-eRp-ePA:O.Arch_11#1] Not implemented
[REQ:BSI-eRp-ePA:O.Arch_12#1] Not necessary due to O.Arch_11 not being implemented.
[REQ:BSI-eRp-ePA:O.Source_2#1] Data escaping is done by the OS Frameworks. We never generate manual SQL Queries, CoreData is used as an ORM, Queries are build with NSFetchRequests and NSPredicates that escape all manual input.
[REQ:BSI-eRp-ePA:O.Source_3#1] Error messages are localized using the `Foundation.LocalizedError` protocol. Search for `LocalizedError` to see all instances. Most errors are localized with static text, some errors contain server side error messages. User data is never used for error messages. Logging is only active on debug builds.
[REQ:BSI-eRp-ePA:O.Source_4#1] Exception handling in swift uses Errors to represent the exception. We use a custom protocol `CodedError` that is autogenerated for all error messages. Together with `LocalizedError` we create error messages that contain a user readable description as well as some technical identifiers to easily identify specific error scenarios and give better support. See `CodedError.swift` and `CodedError.generated.swift` for the protocol and the autogenerated implementations of it.
[REQ:BSI-eRp-ePA:O.Source_5#1] As exceptions and errors are kind of the same construct in swift, this aspect is hard to answer. If a server responds with 401/403 we delete tokens or other security measures, because they are no longer valid anyways. While logging in via biometrics we create temporary data containers for the user certificate and key identifier, that are deleted if the process is not completed properly and kept if the process completes.
[REQ:BSI-eRp-ePA:O.Source_6#1] Swift uses Automatic Reference Counting that does not require active memory management. Raw memory access is possible but only used for swift-OpenSSL dependency that wraps the c library.
[REQ:BSI-eRp-ePA:O.Source_7#1] All sensitive data is handled via reference types. After usage the swift runtime handles deletion of the in memory representation. Secure enclave encryption keys can never leave the secure enclave.
[REQ:BSI-eRp-ePA:O.Source_8#1] We use swift macros to remove development code. Configuration of server Environments is done within `AppConfiguration.swift`. A debug menu is available within settings, rooted within `SettingsView.swift`.
[REQ:BSI-eRp-ePA:O.Source_9#1] We use swift macros to remove debug mechanism code. A debug menu is available within settings, rooted within `SettingsView.swift`. All debug classes are excluded from release builds by using swift macros to remove the whole classes/structs.
[REQ:BSI-eRp-ePA:O.Source_10#1] We use common defaults for all compiler security related settings. See Xcode build configuration for eRpApp Target using current Xcode for actual settings.
[REQ:BSI-eRp-ePA:O.Source_11#1] We do not create any kind of logs for release builds.
[REQ:BSI-eRp-ePA:O.TrdP_1#1] A list of all active used dependencies can be found within `dependencies.yml`. The list contains dependencies from Carthage and SwiftPM.
[REQ:BSI-eRp-ePA:O.TrdP_2#1] SAST Scans are also including external libraries.
[REQ:BSI-eRp-ePA:O.TrdP_3#1] External document
[REQ:BSI-eRp-ePA:O.TrdP_4#1] We have few dependencies with clear scopes. We activly follow developments within these libraries using GitHub and blogs.
[REQ:BSI-eRp-ePA:O.TrdP_5#1] We do not share sensitive data with third parties. Se data usages within `Purp_8` and `O.Arch_2`.
[REQ:BSI-eRp-ePA:O.TrdP_6#1] See `O.Source_1` and `O.Arch_6`.
[REQ:BSI-eRp-ePA:O.TrdP_7#1] As most libraries are source code dependencies, these scans are part of SAST Scanning. Libraries that are not source code dependencies are the precompiled OpenSSL and OpenHealthCardKit (own library but different repository). All third party libraries are mirrored into internal repositories. If necessary we fork libraries to apply fixes.

[REQ:BSI-eRp-ePA:O.Cryp_1#1] Private keys for encryption are either created and stored within the secure enclave or stored within the eGK. As encryption for Server communication is done ephemeral via ECDH-ES, no static private keys on client side are necessary.
[REQ:BSI-eRp-ePA:O.Cryp_2#1] All cryptographic requirements are defined within `gemSpec_Krypt`. The document was created together with BSI.
[REQ:BSI-eRp-ePA:O.Cryp_3#1] All cryptographic requirements are defined within `gemSpec_Krypt`. The document was created together with BSI.
[REQ:BSI-eRp-ePA:O.Cryp_4#1] All cryptographic requirements are defined within `gemSpec_Krypt`. The document was created together with BSI.
[REQ:BSI-eRp-ePA:O.Cryp_5#1] We use Brainpool256R1 and ECSECPrimeRandom 256, see usages in O.Cryp_1 to O.Cryp_4
[REQ:BSI-eRp-ePA:O.Cryp_6#1] Persisted cryptographic keys are created within the devices secure enclave. Temporal keys are discarded as soon as usage is no longer needed.
[REQ:BSI-eRp-ePA:O.Cryp_7#1] As Brainpool256R1 is not available within secure enclave but enforced by BSI where possible, we use secure enclave encryption only for biometric authentication. Everywhere else, cryptographic operations are ephemeral or use the eGK as a secure execution environment.

[REQ:BSI-eRp-ePA:O.Rand_1#1,O.Rand_2#1,O.Rand_3#1,O.Rand_4#1] We use the platform provided secure random generator. See [Apple Support Website](https://support.apple.com/en-gb/guide/security/seca0c73a75b/web) for details.

[REQ:BSI-eRp-ePA:O.Auth_1#1] Our authentication concept is described in the following repository: https://github.com/gematik/api-erp/blob/master/docs/authentisieren.adoc ||| We have more detailed diagrams regarding the context of the authentication in the SIS: Authentication on the central IDP: E-Rezept-App-Authentifizierungskonzept.pdf ||| Authentication via Fast Track: E-Rezept-App-Authentifizierungskonzept_Fast_Track.pdf
[REQ:BSI-eRp-ePA:O.Auth_2#1] There is no client side separation of authentication and authorization.
[REQ:BSI-eRp-ePA:O.Auth_3#1] One way to connect to the FD is to login by using the eGK. To login with the eGK, the card, a CAN and a PIN is needed. The other way is to use a insurance company provided app. These apps must implement a second factor as well. See all `CardWall` prefixed files for all implementation details.
[REQ:BSI-eRp-ePA:O.Auth_4#1] There is no step up from always using 2nd factor authentication. Tokens have short lifetimes of 12h (server defined) SSO-Tokens and 5m Access-Tokens.
[REQ:BSI-eRp-ePA:O.Auth_5#1] A Audit Log for every FD access is available in each user profile.
[REQ:BSI-eRp-ePA:O.Auth_6#1] There are not passwords to guess for server login within our application. Only eGK login is directly available within the application. The users application password is not delayed, as any user with PIN access would have access to the unencrypted file system as well.
[REQ:BSI-eRp-ePA:O.Auth_7#1] The SceneDelegate exchanges the active window with an authentication window every time the app gains focus
[REQ:BSI-eRp-ePA:O.Auth_8#1] A Timer is used to measure the time a user is inactive. Every user interaction resets the timer.
[REQ:BSI-eRp-ePA:O.Auth_9#1] Token invalidation happens after 12 hours. If a user is still active, a re-authentication via eGK, Biometrics or Insurance App is necessary. Each meaning the possession and or knowledge of the needed user input.
[REQ:BSI-eRp-ePA:O.Auth_10#1] Authentication via eGK cannot be altered, as the physical card cannot be modified without authentication (e.g. PIN change). See gemSpec_COS for details. Adding a authentication key that is secured via biometrics (labeled as "save login" within the card wall) enforces a new authentication via eGK on server side.
[REQ:BSI-eRp-ePA:O.Auth_11#1] We use TLS Pinning and a Trust Store for VAU communication. See TrustStore and VAU Module for implementation.
[REQ:BSI-eRp-ePA:O.Auth_12#1] unused

[REQ:BSI-eRp-ePA:O.Pass_1#1,O.Pass_2#1] We use zxcvbn-ios as a password strength indicator and enforcer for the application password.
[REQ:BSI-eRp-ePA:O.Pass_3#1] The user may change the app passwords within the settings.
[REQ:BSI-eRp-ePA:O.Pass_4#1] There is no protocol for the application password within the application. If there is one, the keychain may hold it.
[REQ:BSI-eRp-ePA:O.Pass_5#1] We use the keychain to persist the app password. The app password is not hashed.

[REQ:BSI-eRp-ePA:O.Biom_1#1] The authentication via biometric is only available upon successfull authentication via eGK + PIN.
[REQ:BSI-eRp-ePA:O.Biom_2#1] Minimal OS version is set to iOS 15 in compliance with TR-03161-1 Anhang C.
[REQ:BSI-eRp-ePA:O.Biom_3#1] Minimal OS version is set to iOS 15.
[REQ:BSI-eRp-ePA:O.Biom_4#1] Minimal OS version is set to iOS 15. 
[REQ:BSI-eRp-ePA:O.Biom_6#1] Biometric secured private keys are invalid whenever the biometrics setup changes. 
[REQ:BSI-eRp-ePA:O.Biom_8#1] If evaluation failed 5 times, a not escapable error is presented

[REQ:BSI-eRp-ePA:O.Sess_1#1] TLS Session handling is done via NSURLSession. Cookie based user sessions are never created, all connections are ephemeral, remote APIs are stateless.
[REQ:BSI-eRp-ePA:O.Sess_2#1] not applicable
[REQ:BSI-eRp-ePA:O.Sess_3#1] not applicable
[REQ:BSI-eRp-ePA:O.Sess_4#1] not applicable
[REQ:BSI-eRp-ePA:O.Sess_5#1] not applicable
[REQ:BSI-eRp-ePA:O.Sess_6#1] not applicable
[REQ:BSI-eRp-ePA:O.Sess_7#1] not applicable

[REQ:BSI-eRp-ePA:O.Tokn_1#1] The token is stored within the keychain for long lasting tokens, short living tokens as used in biometric pairing process are not persisted and only live in the memory.
[REQ:BSI-eRp-ePA:O.Tokn_2#1,O.Tokn_3#1] The token is created by the backend, we have no means of manipulating the content.
[REQ:BSI-eRp-ePA:O.Tokn_4#1] The token is created by the IDP and signed there. We have not valid signing identity within the application to sign the token.
[REQ:BSI-eRp-ePA:O.Tokn_5#1] A Section within User Profiles contains all tokens for that profile on the device
[REQ:BSI-eRp-ePA:O.Tokn_6#1] A logout button is available within each user profile.

[REQ:BSI-eRp-ePA:O.Data_1#1] User preferences are asked without discrimination within the onboarding process
[REQ:BSI-eRp-ePA:O.Data_2#1] We use the OS Keychain to persist sensitive data. The keychain either stores or encrypts via SecureEnclave. 
[REQ:BSI-eRp-ePA:O.Data_3#1] Currently it is not possible to store data within the secure enclave on iOS. We store all data on the encrypted application container on the device. See `eRpApp.entitlements` for `NSFileProtectionCompleteUnlessOpen` usage.
[REQ:BSI-eRp-ePA:O.Data_4#1] Everything we store, safe or send anywhere is both verified as in O.Resi_4 and or encrypted, such as Keychain or the application container.
[REQ:BSI-eRp-ePA:O.Data_5#1] Ephemeral private keys are released as soon as they are no longer needed (see O.Source_5)
[REQ:BSI-eRp-ePA:O.Data_6#1] Collected data is sparse and use case related as required.
[REQ:BSI-eRp-ePA:O.Data_7#1] Private data is not initially created by the application. Only additional information, such as redeeming or deleting prescriptions create data. The created data is kept on the FD.
[REQ:BSI-eRp-ePA:O.Data_8#1] The device camera is used for scanning prescriptions.
[REQ:BSI-eRp-ePA:O.Data_9#1]  The device camera is used for scanning prescriptions, no picture files are created.
[REQ:BSI-eRp-ePA:O.Data_10#1] Password fields are marked as such and thus disallow autocorrections. Search for `SecureField` or `SecureFieldWithReveal` for all usages.
[REQ:BSI-eRp-ePA:O.Data_11#1] We use default platform behavior for password fields.
[REQ:BSI-eRp-ePA:O.Data_12#1] There is no API from Apple that allows extraction of biometric data.
[REQ:BSI-eRp-ePA:O.Data_13#1] Suppressing Screenshots is not possible as of now.
[REQ:BSI-eRp-ePA:O.Data_14#1] See `eRpApp.entitlements` for `NSFileProtectionCompleteUnlessOpen` usage.
[REQ:BSI-eRp-ePA:O.Data_15#1] 
[REQ:BSI-eRp-ePA:O.Data_16#1] Storing application data is not possible on iOS.
[REQ:BSI-eRp-ePA:O.Data_17#1,O.Data_18#1] Deletion is completely handled by the OS. We have no means of doing anything while deinstallation is running. All sensitive keychain data is tied to the user profile id and cannot be accessed after deinstallation. though technically the information still persists for a short period of time (<24h) after some kind of daily cleanup routine by the OS it will be removed. The user may choose to manually logout or delete profiles before app deletion.
[REQ:BSI-eRp-ePA:O.Data_19#1] Not applicable: no kill switch realized.

[REQ:BSI-eRp-ePA:O.Paid_1#1,O.Paid_2#1,O.Paid_3#1,O.Paid_4#1,O.Paid_5#1,O.Paid_6#1,O.Paid_7#1,O.Paid_8#1,O.Paid_9#1,O.Paid_10#1] The app does not offer any purchases.

[REQ:BSI-eRp-ePA:O.Ntwk_1#1] no exceptions set in NSAppTransportSecurity, HTTP via TLS is enforced; OS will use system root certificates in combination with set pinned certificates. see also: [Requirements for Connecting Using ATS](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html)
[REQ:BSI-eRp-ePA:O.Ntwk_2#1] We use one wrapper around NSURLSession for network communication that uses an ephemeral configuration only allowing TLS 1.2 or greater.
[REQ:BSI-eRp-ePA:O.Ntwk_3#1] We use NSURLSession for network communication
[REQ:BSI-eRp-ePA:O.Ntwk_4#1] The App Transport Security Settings for all pinned certificates and the supported domains is done in `eRpApp/Resources/Info.plist`. For more informations take a look at the apple documentation of [How to configure server certificates](https://developer.apple.com/news/?id=g9ejcf8y) and [NSPinnedDomains](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity/nspinneddomains).
[REQ:BSI-eRp-ePA:O.Ntwk_5#1] By using NSURLSession ATS (App Transport Security) handles that within the application.
[REQ:BSI-eRp-ePA:O.Ntwk_6#1] The server uses extended validation certificates to ensure maximum authenticity.
[REQ:BSI-eRp-ePA:O.Ntwk_7#1] The system enforces ATS [App Transport Security](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity/) since the app uses the standard URL Loading System `URLSession` which automatically negotiate the most secure connection available from the server. Also there are no exceptions configured in the `eRpApp/Resources/Info.plist` thus insecure networt connections are disabled by default.
[REQ:BSI-eRp-ePA:O.Ntwk_8#1] Since this is a requirement for a backend system, it is not applicable to the FdV
[REQ:BSI-eRp-ePA:O.Ntwk_9#1] Since this is a requirement for a backend system, it is not applicable to the FdV

[REQ:BSI-eRp-ePA:O.Plat_1#1] We test for device pincode at startup and show a dialog if no pin is set.
[REQ:BSI-eRp-ePA:O.Plat_2#1] The app ony configures entitlements that are used for it's primary purpose. All configured entitlements are configured in `eRpApp/Resources/Info.plist` and in `eRpApp/Resources/eRpApp.entitlements`.
[REQ:BSI-eRp-ePA:O.Plat_3#1] We use the platform dialogs for this. Localizations can be found within `InfoPlist.strings`
[REQ:BSI-eRp-ePA:O.Plat_4#1] We never show sensitive data as all errors are localized with custom descriptions (See `LocalizedError` implementations). Some errors have localized parameters such as a failed PIN counter. Some errors are sent from the server, these messages show only generic information what went wrong.
[REQ:BSI-eRp-ePA:O.Plat_5#1] Not applicable: displaying of messages not realized.
[REQ:BSI-eRp-ePA:O.Plat_6#1,O.Plat_7#1] Implemented by the OS Sandboxing.
[REQ:BSI-eRp-ePA:O.Plat_8#1] Not applicable: broadcasting of messages not realized.
[REQ:BSI-eRp-ePA:O.Plat_9#1] Not applicable: broadcasting of messages not realized.
[REQ:BSI-eRp-ePA:O.Plat_10#1] Interprocess communication is implemented using Universal Linking. Current use cases are limited to login with insurance company apps. No sensitive data is transferred, the actual payload is decided by the server.
[REQ:BSI-eRp-ePA:O.Plat_11#1] WebViews only display local content that is delivered together with the application. Javascript is disabled, linking and loading other content is disabled. All website open the system browser.
[REQ:BSI-eRp-ePA:O.Plat_12#1] The content window is blurred upon leaving the application to not expose content to the system multitasking switcher.
[REQ:BSI-eRp-ePA:O.Plat_13#1] Implemented using a `WKWebViewDelegate`.
[REQ:BSI-eRp-ePA:O.Plat_14#1] WebViews only display local content that is delivered together with the application. No cookies are created.
[REQ:BSI-eRp-ePA:O.Plat_15#1] The app's memory is subject to the operating system's memory and therefore it has no control over the used memory.
[REQ:BSI-eRp-ePA:O.Plat_16#1] During the onboarding process the user is forced to secure the access to the app either via a biometric trait or a strong password.

[REQ:BSI-eRp-ePA:O.Resi_1#1] 
[REQ:BSI-eRp-ePA:O.Resi_2#1] Jailbreak detection is done on startup of the application after the app authentication. If a jailbreak is detected, a information dialog is presented to the user.
[REQ:BSI-eRp-ePA:O.Resi_3#1] 
[REQ:BSI-eRp-ePA:O.Resi_4#1] 
[REQ:BSI-eRp-ePA:O.Resi_5#1] 
[REQ:BSI-eRp-ePA:O.Resi_6#1] IDP Communication is secured by using TLS with pinned Certificates as well as JWEs with keys that are pinned using a TI specific trust anchor as well as OCSP. FD Communication is secured by using TLS and VAU encryption, again with pinned Certificates for both methods. APOVZD communication uses TLS with pinned certificates. The Pinned certificates fingerprints can be found within `Sources/eRpApp/Resources/Info.plist`.
[REQ:BSI-eRp-ePA:O.Resi_7#1] 
[REQ:BSI-eRp-ePA:O.Resi_8#1] The application source is available on github. Any measure of preventing reverse engineering would be pointless.
[REQ:BSI-eRp-ePA:O.Resi_9#1] Data is not stored while moving between platforms or devices. Private keys are stored within the secure enclave an cannot leave the device.
[REQ:BSI-eRp-ePA:O.Resi_10#1] Missing internet connection or other means of disruption use the same error mechanisms as every part of the app uses for normal errors.
