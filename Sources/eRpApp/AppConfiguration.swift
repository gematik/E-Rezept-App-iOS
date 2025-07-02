//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import Combine
import eRpKit
import eRpRemoteStorage
import Foundation
import IDP
import TrustStore

extension AppConfiguration {
    enum Environment {
        // Values are read from the development({.apikeys,.static}).env(.default) files
        // and written to an output file via ErpAppPlugin and EnvironmentParser at compile time.
    }
}

extension AppConfiguration.Environment {
    // swiftlint:disable:next todo
    // TODO: after merging this, we remove the "*_PU_URL" variables from the other source
    // afterwards we rename these vars here back to "IDP_RISE_PU_URL", ...
    // swiftlint:disable identifier_name
    static let IDP_RISE_PU_URL_TEMP: String = "https://idp.app.ti-dienste.de/.well-known/openid-configuration"
    static let ERP_IBM_PU_URL_TEMP: String = "https://erp.app.ti-dienste.de/"
    static let FHIRVZD_PU_URL_TEMP: String = "https://fhir-directory.vzd.ti-dienste.de/"
    static let API_EREZEPT_GEMATIK_DE_PU_URL_TEMP: String = "https://api.erezept.gematik.de/"
    // swiftlint:enable identifier_name
}

/// Actual AppConfiguration for all backend services
struct AppConfiguration: Equatable {
    internal init?(
        name: String,
        trustAnchor: TrustAnchor,
        idp: Server?,
        idpDefaultScopes: [String] = ["e-rezept", "openid"],
        erp: Server?,
        base: String = "https://this.is.the.inner.vau.request/",
        fhirVzd: Server?,
        eRezept: Server?,
        organDonationUrl: URL?,
        clientId: String,
        userAgent: String? = nil
    ) {
        self.clientId = clientId
        let userAgent = userAgent ?? "eRp-App-iOS/\(AppVersion.current.productVersion) GMTIK/\(clientId)"
        let sharedHeader: [String: String] = ["User-Agent": userAgent]
        guard let idp, let erp, let fhirVzd, let eRezept
        else { return nil }
        self.name = name
        self.trustAnchor = trustAnchor
        self.idp = idp.url
        idpAdditionalHeader = sharedHeader.merging(idp.header) { _, new in new }
        self.idpDefaultScopes = idpDefaultScopes
        self.base = URL(string: base)! // swiftlint:disable:this force_unwrapping
        self.erp = erp.url
        erpAdditionalHeader = sharedHeader.merging(erp.header) { _, new in new }
        self.fhirVzd = fhirVzd.url
        fhirVzdAdditionalHeader = sharedHeader.merging(fhirVzd.header) { _, new in new }
        self.eRezept = eRezept.url
        eRezeptAdditionalHeader = sharedHeader.merging(eRezept.header) { _, new in new }
        self.organDonationUrl = organDonationUrl
    }

    let name: String
    let uuid = UUID()

    // idp
    /// URL for the IDP discovery document
    let idp: URL
    let idpAdditionalHeader: [String: String]
    let idpDefaultScopes: [String]

    let trustAnchor: TrustAnchor
    // erp fd

    /// The base url
    let base: URL
    /// URL for the vau server
    let erp: URL
    let erpAdditionalHeader: [String: String]

    // clientId
    // [REQ:gemSpec_IDP_Frontend:A_20603] Actual ID
    let clientId: String
    // [REQ:gemSpec_IDP_Frontend:A_20740] Actual redirect uri
    let redirectUri = URL(string: "https://redirect.gematik.de/erezept")! // swiftlint:disable:this force_unwrapping
    let extAuthRedirectUri = URL(
        string: "https://das-e-rezept-fuer-deutschland.de/extauth"
    )! // swiftlint:disable:this force_unwrapping

    // FHIR VZD
    let fhirVzd: URL
    let fhirVzdAdditionalHeader: [String: String]

    // eRezept backend
    let eRezept: URL
    let eRezeptAdditionalHeader: [String: String]

    let organDonationUrl: URL?

    struct Server {
        let url: URL
        let header: [String: String]

        init?(url: String, header: [String: String]) {
            guard let url = URL(string: url) else {
                return nil
            }
            self.init(url: url, header: header)
        }

        init(url: URL, header: [String: String]) {
            self.url = url
            self.header = header
        }
    }
}

// MARK: - # Server --

// swiftlint:disable identifier_name

// MARK: - ## IDP

// [REQ:gemSpec_Krypt:A_21218] Gematik Root CA 3 as a trust anchor has to be set in the program code
// [REQ:BSI-eRp-ePA:O.Ntwk_4#2|16] Gematik Root CA 3 as a trust anchor has to be set in the program code
// swiftlint:disable:next force_try
let TRUSTANCHOR_GemRootCa3 = try! TrustAnchor(withPEM: """
-----BEGIN CERTIFICATE-----
MIICaTCCAg+gAwIBAgIBATAKBggqhkjOPQQDAjBtMQswCQYDVQQGEwJERTEVMBMG
A1UECgwMZ2VtYXRpayBHbWJIMTQwMgYDVQQLDCtaZW50cmFsZSBSb290LUNBIGRl
ciBUZWxlbWF0aWtpbmZyYXN0cnVrdHVyMREwDwYDVQQDDAhHRU0uUkNBMzAeFw0x
NzEwMTcwNzEzMDNaFw0yNzEwMTUwNzEzMDNaMG0xCzAJBgNVBAYTAkRFMRUwEwYD
VQQKDAxnZW1hdGlrIEdtYkgxNDAyBgNVBAsMK1plbnRyYWxlIFJvb3QtQ0EgZGVy
IFRlbGVtYXRpa2luZnJhc3RydWt0dXIxETAPBgNVBAMMCEdFTS5SQ0EzMFowFAYH
KoZIzj0CAQYJKyQDAwIIAQEHA0IABFhZKSE0xvaeHzZB0A7sRYwIphEWYk/+uFw4
kOLnBt2kbP4P7L0lFOQfp6W0a2lCcmKk+k25VHrj7PCMyV/AVdqjgZ4wgZswHQYD
VR0OBBYEFN/DvnW+JesTMjAup1CFCJ83ENDoMEIGCCsGAQUFBwEBBDYwNDAyBggr
BgEFBQcwAYYmaHR0cDovL29jc3Aucm9vdC1jYS50aS1kaWVuc3RlLmRlL29jc3Aw
DwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYwFQYDVR0gBA4wDDAKBggq
ghQATASBIzAKBggqhkjOPQQDAgNIADBFAiEAnOlHsQ5tQ2HPoKVngVQnbvVGteLy
MSEnNGbYegnfPFECIEUlFmjATBNklr35xvWQPZUMdIsy7SzUulwFDodpdGr/
-----END CERTIFICATE-----
""")

#if TEST_ENVIRONMENT || DEFAULT_ENVIRONMENT_TU || DEFAULT_ENVIRONMENT_RU || DEFAULT_ENVIRONMENT_RU_DEV
// Note: This is temporary until the services use the Gematik Root CA3 in production.
// swiftlint:disable:next force_try
let TRUSTANCHOR_GemRootCa3TestOnly = try! TrustAnchor(withPEM: """
-----BEGIN CERTIFICATE-----
MIICkzCCAjmgAwIBAgIBATAKBggqhkjOPQQDAjCBgTELMAkGA1UEBhMCREUxHzAd
BgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxNDAyBgNVBAsMK1plbnRyYWxl
IFJvb3QtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxGzAZBgNVBAMMEkdF
TS5SQ0EzIFRFU1QtT05MWTAeFw0xNzA4MTEwODM4NDVaFw0yNzA4MDkwODM4NDVa
MIGBMQswCQYDVQQGEwJERTEfMB0GA1UECgwWZ2VtYXRpayBHbWJIIE5PVC1WQUxJ
RDE0MDIGA1UECwwrWmVudHJhbGUgUm9vdC1DQSBkZXIgVGVsZW1hdGlraW5mcmFz
dHJ1a3R1cjEbMBkGA1UEAwwSR0VNLlJDQTMgVEVTVC1PTkxZMFowFAYHKoZIzj0C
AQYJKyQDAwIIAQEHA0IABG+raY8OSxIEfrDwz4K4K1HXLXbd0ZzAKtD9SUDtSexn
fsai8lkY8rM59TLky//HB8QDkyZewRPXClwpXCrj5HOjgZ4wgZswHQYDVR0OBBYE
FAeQMy11U15/+Mg3v37JJldo3zjSMEIGCCsGAQUFBwEBBDYwNDAyBggrBgEFBQcw
AYYmaHR0cDovL29jc3Aucm9vdC1jYS50aS1kaWVuc3RlLmRlL29jc3AwDwYDVR0T
AQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYwFQYDVR0gBA4wDDAKBggqghQATASB
IzAKBggqhkjOPQQDAgNIADBFAiEAo4kNteSBVR4ovNeTBhkiSXsWzdRC0tQeMfIt
sE0s7/8CIDZ3EQxclVBV3huM8Bzl9ePbNsV+Lvnjv+Fo1om5+xJ2
-----END CERTIFICATE-----
""")
#endif

#if TEST_ENVIRONMENT || DEFAULT_ENVIRONMENT_TU

let IDP_RISE_TU = AppConfiguration.Server(
    url: AppConfiguration.Environment.IDP_RISE_TU_URL,
    header: ["X-Auth": AppConfiguration.Environment.IDP_RISE_TU_X_AUTH]
)

#endif

#if TEST_ENVIRONMENT || DEFAULT_ENVIRONMENT_RU || DEFAULT_ENVIRONMENT_RU_DEV

let IDP_RISE_RU = AppConfiguration.Server(
    url: AppConfiguration.Environment.IDP_RISE_RU_URL,
    header: ["X-Auth": AppConfiguration.Environment.IDP_RISE_RU_X_AUTH]
)

#endif
let IDP_RISE_PU = AppConfiguration.Server(
    url: AppConfiguration.Environment.IDP_RISE_PU_URL_TEMP,
    header: [:]
)

// MARK: - ## ERP

#if TEST_ENVIRONMENT || DEFAULT_ENVIRONMENT_TU

let ERP_IBM_TU = AppConfiguration.Server(
    url: AppConfiguration.Environment.ERP_IBM_TU_URL,
    header: ["X-api-key": AppConfiguration.Environment.ERP_IBM_TU_X_API_KEY]
)

#endif

#if TEST_ENVIRONMENT || DEFAULT_ENVIRONMENT_RU || DEFAULT_ENVIRONMENT_RU_DEV

let ERP_IBM_RU = AppConfiguration.Server(
    url: AppConfiguration.Environment.ERP_IBM_RU_URL,
    header: ["X-api-key": AppConfiguration.Environment.ERP_IBM_RU_X_API_KEY]
)

#endif

#if TEST_ENVIRONMENT || DEFAULT_ENVIRONMENT_RU_DEV

let ERP_IBM_RU_DEV = AppConfiguration.Server(
    url: AppConfiguration.Environment.ERP_IBM_RU_DEV_URL,
    header: ["X-api-key": AppConfiguration.Environment.ERP_IBM_RU_DEV_X_API_KEY]
)

#endif
let ERP_IBM_PU = AppConfiguration.Server(
    url: AppConfiguration.Environment.ERP_IBM_PU_URL_TEMP,
    header: ["X-api-key": AppConfiguration.Environment.ERP_IBM_PU_X_API_KEY]
)

// MARK: - ## FHIRVZD

#if TEST_ENVIRONMENT || DEFAULT_ENVIRONMENT_TU || DEFAULT_ENVIRONMENT_RU || DEFAULT_ENVIRONMENT_RU_DEV
let FHIRVZD_RU: AppConfiguration.Server? = AppConfiguration.Server(
    url: AppConfiguration.Environment.FHIRVZD_RU_URL,
    header: [:]
)
#endif

let FHIRVZD_PU = AppConfiguration.Server(
    url: AppConfiguration.Environment.FHIRVZD_PU_URL_TEMP,
    header: [:]
)

// MARK: - ## eRezept Backend

#if TEST_ENVIRONMENT || DEFAULT_ENVIRONMENT_TU
let EREZEPT_API_TU: AppConfiguration.Server? = AppConfiguration.Server(
    url: AppConfiguration.Environment.API_EREZEPT_GEMATIK_DE_TU_URL,
    header: [
        "X-API-KEY": AppConfiguration.Environment.API_EREZEPT_GEMATIK_DE_API_TOKEN_TU_URL,
    ]
)
#endif

#if TEST_ENVIRONMENT || DEFAULT_ENVIRONMENT_RU || DEFAULT_ENVIRONMENT_RU_DEV
let EREZEPT_API_RU: AppConfiguration.Server? = AppConfiguration.Server(
    url: AppConfiguration.Environment.API_EREZEPT_GEMATIK_DE_RU_URL,
    header: [
        "X-API-KEY": AppConfiguration.Environment.API_EREZEPT_GEMATIK_DE_API_TOKEN_RU_URL,
    ]
)
#endif

let EREZEPT_API_PU = AppConfiguration.Server(
    url: AppConfiguration.Environment.API_EREZEPT_GEMATIK_DE_PU_URL_TEMP,
    header: [
        "X-API-KEY": AppConfiguration.Environment.API_EREZEPT_GEMATIK_DE_API_TOKEN_PU_URL,
    ]
)

// MARK: - ## OrganDonation

#if TEST_ENVIRONMENT || DEFAULT_ENVIRONMENT_TU || DEFAULT_ENVIRONMENT_RU || DEFAULT_ENVIRONMENT_RU_DEV

let ORGAN_DONATION_REGISTER_RU_URL = URL(string: AppConfiguration.Environment.ORGAN_DONATION_REGISTER_RU)

#endif

let ORGAN_DONATION_REGISTER_PU_URL = URL(string: AppConfiguration.Environment.ORGAN_DONATION_REGISTER_PU)

// swiftlint:enable identifier_name

// MARK: - # Environments -

#if TEST_ENVIRONMENT || DEFAULT_ENVIRONMENT_TU

let environmentTU: AppConfiguration? = AppConfiguration(
    name: "TU",
    trustAnchor: TRUSTANCHOR_GemRootCa3TestOnly,
    idp: IDP_RISE_TU,
    erp: ERP_IBM_TU,
    fhirVzd: FHIRVZD_RU,
    eRezept: EREZEPT_API_TU,
    organDonationUrl: ORGAN_DONATION_REGISTER_RU_URL,
    clientId: AppConfiguration.Environment.ERP_CLIENT_ID_TU
)

#endif

#if TEST_ENVIRONMENT || DEFAULT_ENVIRONMENT_RU || DEFAULT_ENVIRONMENT_RU_DEV

let environmentRU: AppConfiguration? = AppConfiguration(
    name: "RU",
    trustAnchor: TRUSTANCHOR_GemRootCa3TestOnly,
    idp: IDP_RISE_RU,
    erp: ERP_IBM_RU,
    fhirVzd: FHIRVZD_RU,
    eRezept: EREZEPT_API_RU,
    organDonationUrl: ORGAN_DONATION_REGISTER_RU_URL,
    clientId: AppConfiguration.Environment.ERP_CLIENT_ID_RU
)

#endif

#if TEST_ENVIRONMENT || DEFAULT_ENVIRONMENT_RU_DEV

let environmentRUDEV: AppConfiguration? = AppConfiguration(
    name: "RU DEV",
    trustAnchor: TRUSTANCHOR_GemRootCa3TestOnly,
    idp: IDP_RISE_RU,
    idpDefaultScopes: ["e-rezept-dev", "openid"],
    erp: ERP_IBM_RU_DEV,
    fhirVzd: FHIRVZD_RU,
    eRezept: EREZEPT_API_RU,
    organDonationUrl: ORGAN_DONATION_REGISTER_RU_URL,
    clientId: AppConfiguration.Environment.ERP_CLIENT_ID_RU_DEV
)

#endif

let environmentPU: AppConfiguration = {
    guard let puAppConfiguration = AppConfiguration(
        name: "PU",
        trustAnchor: TRUSTANCHOR_GemRootCa3,
        idp: IDP_RISE_PU,
        erp: ERP_IBM_PU,
        fhirVzd: FHIRVZD_PU,
        eRezept: EREZEPT_API_PU,
        organDonationUrl: ORGAN_DONATION_REGISTER_PU_URL,
        // [REQ:gemSpec_IDP_Frontend:A_20603] Actual ID
        clientId: AppConfiguration.Environment.ERP_CLIENT_ID_PU
    ) else {
        fatalError(
            // swiftlint:disable:next line_length
            "Could not create AppConfiguration for PU. Some PU_ENV_URL environment variables are missing or not castable to URL."
        )
    }
    return puAppConfiguration
}()

#if DEFAULT_ENVIRONMENT_TU
let defaultConfiguration: AppConfiguration = environmentTU ?? environmentPU
#elseif DEFAULT_ENVIRONMENT_RU
let defaultConfiguration: AppConfiguration = environmentRU ?? environmentPU
#elseif DEFAULT_ENVIRONMENT_RU_DEV
let defaultConfiguration: AppConfiguration = environmentRUDEV ?? environmentPU
#else

#if TEST_ENVIRONMENT
let defaultConfiguration: AppConfiguration = environmentTU ?? environmentPU
#else
let defaultConfiguration: AppConfiguration = environmentPU
#endif

#endif

#if TEST_ENVIRONMENT
let configurations: [String: AppConfiguration] = [
    "TU": environmentTU,
    "RU": environmentRU,
    "RU_DEV": environmentRUDEV,
    "PU": environmentPU,
].compactMapValues { $0 }
#elseif DEFAULT_ENVIRONMENT_RU_DEV
let configurations: [String: AppConfiguration] = [
    "RU": environmentRU,
    "RU_DEV": environmentRUDEV,
    "PU": environmentPU,
].compactMapValues { $0 }
#endif

#if TEST_ENVIRONMENT || DEFAULT_ENVIRONMENT_RU_DEV
extension UserDataStore {
    var configuration: AnyPublisher<AppConfiguration, Never> {
        serverEnvironmentConfiguration.map { name in
            guard let name = name,
                  let configuration = configurations[name] else {
                return defaultConfiguration
            }
            return configuration
        }
        .eraseToAnyPublisher()
    }

    var appConfiguration: AppConfiguration {
        guard let name = serverEnvironmentName,
              let configuration = configurations[name] else {
            return defaultConfiguration
        }
        return configuration
    }
}
#else

extension UserDataStore {
    var configuration: AnyPublisher<AppConfiguration, Never> {
        Just(defaultConfiguration)
            .eraseToAnyPublisher()
    }

    var appConfiguration: AppConfiguration {
        defaultConfiguration
    }
}

#endif
