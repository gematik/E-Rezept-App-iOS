[REQ:gemSpec_Krypt:A_17207,17359] brainpoolP256r1 ist used for creating/verifying key for signature usage; exception: Biometric use case uses secp256r1 (is considered in repective specification)
[REQ:gemSpec_IDP_Frontend:A_20607] no exceptions set in NSAppTransportSecurity, HTTP via TLS is enforced; see also: [Requirements for Connecting Using ATS](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html)
[REQ:gemSpec_Krypt:A_17322,A_17124,A_21275,A_21332,GS-A_4359,A_21275−01] no exceptions set in NSAppTransportSecurity, see also: [Requirements for Connecting Using ATS](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html) 
[REQ:gemSpec_eRp_FdV:A_20032-01] Note: grace period for OCSP responses is 12h (gemSpec_Krypt:A_21218)
[REQ:gemSpec_eRp_FdV:A_19188] session data (ACCESS_TOKEN, ID_TOKEN, SSO_TOKEN, CAN) is saved in the keychain. Its deletion is managed by the OS. The key chain is sandboxed and can only be shared with other apps by the same vendor when explicitly set. All other mentioned data is deleted.
[REQ:gemSpec_eRp_FdV:A_19229] Audit events will be deleted when the referencing task is deleted. Cascading relationship "task -> audit event" is defined in Sources/eRpLocalStorage/Prescriptions/ErxTask.xcdatamodeld/ErxTask.xcdatamodel/contents
[REQ:gemSpec_IDP_Frontend:A_20741] Configuration within `app-configuration.json`, organisational process as in A_20603
[REQ:gemSpec_Krypt:A_17205] The app does not use the TSL. All TSL related parts are handled within the eRp-FD.
[REQ:gemSpec_Krypt:A_17775, GS−A_5339] We cannot interfere with cipher suite lists, see [Requirements for Connecting Using ATS](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html) for actual order.
[REQ:gemSpec_Krypt:GS−A_5035,A_19215,A_20607] We use https only, see `DefaultHTTPClient.swift`. ATS forbidds other connections.
[REQ:gemSpec_Krypt:GS−A_5322] There is no API to control the session length, developer forums suggest it is 10 minutes for iOS.
[REQ:gemSpec_Krypt:GS−A_5526,GS−A_5542] We use the recommended NSURLSession for best network security [Preventing insecure network connections](https://developer.apple.com/documentation/security/preventing_insecure_network_connections)
[REQ:gemspec_eRp_FdV:A_19183] No eRp-FD Data is forwarded to other systems besides eRp-FD itself.
[REQ:gemSpec_IDP_Frontend:A_20525] Not applicable as authenticator modul is within FdV, not 3rd party app
[REQ:gemSpec_IDP_Frontend:A_20527] Not directly applicable as authenticator modul is within FdV, not 3rd party app. AUTHORIZATION_CODE will be used directly.
[REQ:gemSpec_IDP_Frontend:A_20499] Not applicable as authenticator modul is within FdV, not 3rd party app.
[REQ:gemSpec_IDP_Frontend:A_20525] Not applicable as authenticator modul is within FdV. Consent is given by using the app.
[REQ:gemSpec_IDP_Frontend:A_21578] iOS only allows Biometric access via secure enclave or higher order apis.
[REQ:gemSpec_IDP_Frontend:A_21583] Secure Enclave is enforced with code attributes.
[REQ:gemSpec_IDP_Frontend:A_21584] There is no API to allow or disallow an biometric authentication, iOS is handling the authorization process while using the private key for any cryptographic operation.
[REQ:gemSpec_IDP_Frontend:A_21585] Default behaviour for all apps when using private access group (https://developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps)
[REQ:gemSpec_IDP_Frontend:A_21586] iOS will delete all user related data after user-accout reset. Key-Chain data is not beeing synced with iCloud since `kSecAttrSynchronizable` is not applied  
[REQ:gemSpec_IDP_Frontend:A_21590] References of `SecureEnclaveSignatureProvider` is limited to registration and altVerify usage.

