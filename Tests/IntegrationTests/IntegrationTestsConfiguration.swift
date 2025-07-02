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

@testable import eRpFeatures
import Foundation

extension IntegrationTestsConfiguration {
    enum Environment {
        // Values are read from the development.env(.default) files
        // and written to an output file via ErpAppPlugin and EnvironmentParser at compile time.
        static let IDP_SEK_URL_SERVER_RU_DEV_URL = AppConfiguration.Environment.IDP_SEK_URL_SERVER_RU_DEV_URL
        static let IDP_SEK_URL_SERVER_RU_DEV_X_AUTH = AppConfiguration.Environment.IDP_SEK_URL_SERVER_RU_DEV_X_AUTH
        static let IDP_SEK_URL_SERVER_RU_URL = AppConfiguration.Environment.IDP_SEK_URL_SERVER_RU_URL
        static let IDP_SEK_URL_SERVER_RU_X_AUTH = AppConfiguration.Environment.IDP_SEK_URL_SERVER_RU_X_AUTH
        static let IDP_SEK_URL_SERVER_TU_URL = AppConfiguration.Environment.IDP_SEK_URL_SERVER_TU_URL
        static let IDP_SEK_URL_SERVER_TU_X_AUTH = AppConfiguration.Environment.IDP_SEK_URL_SERVER_TU_X_AUTH
    }
}

extension Brainpool256r1Signer: @unchecked Sendable {}

final class IntegrationTestsConfiguration: Sendable {
    let appConfiguration: AppConfiguration
    let brainpool256r1Signer: Brainpool256r1Signer?
    let idpsekURLServer: AppConfiguration.Server?
    let gemDevAvsConfiguration: AVSIntegrationTestConfiguration?

    init(
        appConfiguration: AppConfiguration,
        brainpool256r1Signer: Brainpool256r1Signer? = nil,
        idpsekURLServer: AppConfiguration.Server? = nil,
        gemDevAvsConfiguration: AVSIntegrationTestConfiguration? = nil
    ) {
        self.appConfiguration = appConfiguration
        self.brainpool256r1Signer = brainpool256r1Signer
        self.idpsekURLServer = idpsekURLServer
        self.gemDevAvsConfiguration = gemDevAvsConfiguration
    }
}

let integrationTestsAppConfigurations = [
    "RU": integrationTestsEnvironmentRU,
    "RU_DEV": integrationTestsEnvironmentRUDev,
    "TU": integrationTestsEnvironmentTU,
    "PU": integrationTestsEnvironmentPU,
    "dummy": integrationTestsEnvironmentDummy,
]

let integrationTestsEnvironmentDummy = IntegrationTestsConfiguration(
    appConfiguration: AppConfiguration(
        name: "Dummy App Configuration",
        trustAnchor: TRUSTANCHOR_GemRootCa3TestOnly,
        idp: AppConfiguration.Server(url: "http://dummy.idp.server", header: [:]),
        erp: AppConfiguration.Server(url: "http://dummy.erp.server", header: [:]),
        fhirVzd: AppConfiguration.Server(url: "http://dummy.fhir-vzd.server", header: [:]),
        eRezept: AppConfiguration.Server(url: "http://dummy.api-erezept.server", header: [:]),
        organDonationUrl: nil,
        clientId: "dummyClientId"
    )!,
    brainpool256r1Signer: nil,
    idpsekURLServer: nil,
    gemDevAvsConfiguration: nil
)

extension IntegrationTestsConfiguration {
    // Signing identity for Test-User: Juna Fuchs, Kvnr: X114428530
    static let signer = try! Brainpool256r1Signer(
        x5c: Bundle(for: IntegrationTestsConfiguration.self)
            .path(
                forResource: "109500969_X114428530_c.ch.aut-ecc-51",
                ofType: "crt",
                inDirectory: "Certificates.bundle"
            )!,
        key: Bundle(for: IntegrationTestsConfiguration.self)
            .path(
                forResource: "109500969_X114428530_c.ch.aut-ecc-51",
                ofType: "bin",
                inDirectory: "Certificates.bundle"
            )!
    )
}

let integrationTestsEnvironmentRU: IntegrationTestsConfiguration = {
    guard let appConfiguration = environmentRU else {
        preconditionFailure("Environment RU not found")
    }
    return IntegrationTestsConfiguration(
        appConfiguration: appConfiguration,
        brainpool256r1Signer: IntegrationTestsConfiguration.signer,
        idpsekURLServer: AppConfiguration.Server(
            url: IntegrationTestsConfiguration.Environment.IDP_SEK_URL_SERVER_RU_URL,
            header: ["X-Authorization": IntegrationTestsConfiguration.Environment.IDP_SEK_URL_SERVER_RU_X_AUTH]
        )
    )
}()

let integrationTestsEnvironmentRUDev: IntegrationTestsConfiguration = {
    guard let appConfiguration = environmentRU else {
        preconditionFailure("Environment RU_DEV not found")
    }
    return IntegrationTestsConfiguration(
        appConfiguration: appConfiguration,
        brainpool256r1Signer: IntegrationTestsConfiguration.signer,
        idpsekURLServer: nil
    )
}()

let integrationTestsEnvironmentTU: IntegrationTestsConfiguration = {
    guard let appConfiguration = environmentTU else {
        preconditionFailure("Environment TU not found")
    }
    return IntegrationTestsConfiguration(
        appConfiguration: appConfiguration,
        brainpool256r1Signer: IntegrationTestsConfiguration.signer,
        idpsekURLServer: AppConfiguration.Server(
            url: IntegrationTestsConfiguration.Environment.IDP_SEK_URL_SERVER_TU_URL,
            header: ["X-Authorization": IntegrationTestsConfiguration.Environment.IDP_SEK_URL_SERVER_TU_X_AUTH]
        )
    )
}()

let integrationTestsEnvironmentPU: IntegrationTestsConfiguration = {
    IntegrationTestsConfiguration(
        appConfiguration: environmentPU,
        brainpool256r1Signer: nil,
        idpsekURLServer: nil
    )
}()
