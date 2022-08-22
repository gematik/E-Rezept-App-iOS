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

@testable import eRpApp
import Foundation

class IntegrationTestsEnvironment {
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
    "dummy": integrationTestsEnvironmentDummy,
]

let integrationTestsEnvironmentDummy = IntegrationTestsEnvironment(
    appConfiguration: AppConfiguration(
        name: "Dummy App Configuration",
        trustAnchor: TRUSTANCHOR_GemRootCa3TestOnly,
        idp: AppConfiguration.Server(url: "http://dummy.idp.server", header: [:]),
        erp: AppConfiguration.Server(url: "http://dummy.erp.server", header: [:]),
        apoVzd: AppConfiguration.Server(url: "http://dummy.apo-vzd.server", header: [:])
    ),
    brainpool256r1Signer: nil,
    idpsekURLServer: nil,
    gemDevAvsConfiguration: nil
)
