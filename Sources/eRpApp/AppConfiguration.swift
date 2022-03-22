//
//  Copyright (c) 2022 gematik GmbH
//  
//  Licensed under the EUPL, Version 1.2 or – as soon they will be approved by
//  the European Commission - subsequent versions of the EUPL (the Licence);
//  You may not use this work except in compliance with the Licence.
//  You may obtain a copy of the Licence at:
//  
//      https://joinup.ec.europa.eu/software/page/eupl
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the Licence for the specific language governing permissions and
//  limitations under the Licence.
//  
//
import BundleKit
import Combine
import eRpKit
import eRpRemoteStorage
import Foundation
import IDP
import TrustStore

/// Actual AppConfiguration for all backend services
struct AppConfiguration: Equatable {
    // [REQ:gemSpec_IDP_Frontend:A_20603] Actual ID
    private static let defaultClientId: String = "eRezeptApp"
    private static let defaultUserAgent = "eRp-App-iOS/\(AppVersion.current.productVersion) GMTIK/\(defaultClientId)"

    internal init(name: String,
                  trustAnchor: TrustAnchor,
                  idp: Server,
                  idpDefaultScopes: [String] = ["e-rezept", "openid"],
                  erp: Server,
                  base: String = "https://this.is.the.inner.vau.request/",
                  apoVzd: Server,
                  sharedHeader: [String: String] = ["User-Agent": defaultUserAgent]) {
        self.name = name
        self.trustAnchor = trustAnchor
        self.idp = idp.url
        idpAdditionalHeader = sharedHeader.merging(idp.header) { _, new in new }
        self.idpDefaultScopes = idpDefaultScopes
        self.base = URL(string: base)! // swiftlint:disable:this force_unwrapping
        self.erp = erp.url
        erpAdditionalHeader = sharedHeader.merging(erp.header) { _, new in new }
        self.apoVzd = apoVzd.url
        apoVzdAdditionalHeader = sharedHeader.merging(apoVzd.header) { _, new in new }
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
    let clientId: String = defaultClientId
    // [REQ:gemSpec_IDP_Frontend:A_20740] Actual redirect uri
    let redirectUri = URL(string: "https://redirect.gematik.de/erezept")! // swiftlint:disable:this force_unwrapping
    let extAuthRedirectUri = URL(
        string: "https://das-e-rezept-fuer-deutschland.de/extauth"
    )! // swiftlint:disable:this force_unwrapping

    // apo vzd
    let apoVzd: URL
    let apoVzdAdditionalHeader: [String: String]

    struct Server {
        let url: URL
        let header: [String: String]

        init(url: String, header: [String: String]) {
            self.init(url: URL(string: url)!, header: header) // swiftlint:disable:this force_unwrapping
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

#if TEST_ENVIRONMENT || (!DEFAULT_ENVIRONMENT_TU && !DEFAULT_ENVIRONMENT_RU && !DEFAULT_ENVIRONMENT_RU_DEV)

// [REQ:gemSpec_Krypt:A_21218] Gematik Root CA 3 as a trust anchor has to be set in the program code
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

#endif

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
#if TEST_ENVIRONMENT || (!DEFAULT_ENVIRONMENT_TU && !DEFAULT_ENVIRONMENT_RU)

let IDP_RISE_PU = AppConfiguration.Server(
    url: "https://idp.app.ti-dienste.de/.well-known/openid-configuration",
    header: [:]
)

#endif

// MARK: - ## ERP

#if TEST_ENVIRONMENT || (!DEFAULT_ENVIRONMENT_TU && !DEFAULT_ENVIRONMENT_RU && !DEFAULT_ENVIRONMENT_RU_DEV)

let ERP_IBM_PU = AppConfiguration.Server(
    url: "https://erp.app.ti-dienste.de/",
    header: ["X-api-key": "" +
        ""]
)

#endif

// MARK: - ## APOVZD

#if TEST_ENVIRONMENT || (!DEFAULT_ENVIRONMENT_TU && !DEFAULT_ENVIRONMENT_RU && !DEFAULT_ENVIRONMENT_RU_DEV)
let APOVZD_PU = AppConfiguration.Server(
    url: "https://apovzd.app.ti-dienste.de/api/",
    header: ["X-API-KEY": "" +
        ""]
)
#endif

#if TEST_ENVIRONMENT || (!DEFAULT_ENVIRONMENT_TU && !DEFAULT_ENVIRONMENT_RU && !DEFAULT_ENVIRONMENT_RU_DEV)

let environmentPU = AppConfiguration(
    name: "PU",
    trustAnchor: TRUSTANCHOR_GemRootCa3,
    idp: IDP_RISE_PU,
    erp: ERP_IBM_PU,
    apoVzd: APOVZD_PU
)

#endif

let defaultConfiguration = environmentPU

#if TEST_ENVIRONMENT
let configurations: [String: AppConfiguration] = [
    "PU": environmentPU,
]
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
