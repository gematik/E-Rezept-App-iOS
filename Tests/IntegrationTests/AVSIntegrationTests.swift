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

@testable import AVS
import Combine
@testable import eRpFeatures
import Foundation
import HTTPClient
import HTTPClientLive
import Nimble
import OpenSSL
import TestUtils
import XCTest

final class AVSIntegrationTests: XCTestCase {
    var environment: IntegrationTestsConfiguration!

    override func setUp() {
        super.setUp()

        if let integrationTestsEnvironmentString = ProcessInfo.processInfo.environment["APP_CONF"],
           let integrationTestsEnvironment = integrationTestsAppConfigurations[integrationTestsEnvironmentString] {
            environment = integrationTestsEnvironment
        } else {
            environment = integrationTestsEnvironmentDummy
        }
    }

    func testGematikDevCompleteFlow_200() async throws {
        guard let gemDevAvsConfiguration = environment.gemDevAvsConfiguration
        else {
            throw XCTSkip("Skip test because no gemDevAvsConfiguration available")
        }
        // given
        let message: AVSMessage = .Fixtures.completeExample
        let endPoint =
            AVSEndpoint(
                url: URL(string: gemDevAvsConfiguration.url)!.appendingPathComponent("200"),
                additionalHeaders: gemDevAvsConfiguration.additionalHeaders
            )

        // swiftlint:disable line_length

        let x509 = try X509(
            der: Data(
                base64Encoded: "MIIFPzCCBCegAwIBAgIHAhWxKm51ljANBgkqhkiG9w0BAQsFADCBmjELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxSDBGBgNVBAsMP0luc3RpdHV0aW9uIGRlcyBHZXN1bmRoZWl0c3dlc2Vucy1DQSBkZXIgVGVsZW1hdGlraW5mcmFzdHJ1a3R1cjEgMB4GA1UEAwwXR0VNLlNNQ0ItQ0EyNCBURVNULU9OTFkwHhcNMjAwMTI0MDAwMDAwWhcNMjQxMjExMjM1OTU5WjCB2zELMAkGA1UEBhMCREUxETAPBgNVBAcMCFTDtm5uaW5nMQ4wDAYDVQQRDAUyNTgzMjETMBEGA1UECQwKQW0gTWFya3QgMTEqMCgGA1UECgwhMy1TTUMtQi1UZXN0a2FydGUtODgzMTEwMDAwMTE2OTQ4MR0wGwYDVQQFExQ4MDI3Njg4MzExMDAwMDExNjk0ODEVMBMGA1UEBAwMQmzDtGNoLUJhdWVyMQ8wDQYDVQQqDAZTb3BoaWUxITAfBgNVBAMMGEFwb3RoZWtlIGFtIFNlZVRFU1QtT05MWTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKOgZ4thfQmIx77NLZ36mNRwEpIqcOhtMjLjPkArAQcIWnjJ7OaOUJTtel73aH38KWoMgr0+rbw+aR4U5Rkg9wdkl/FTV0ifTDzqQtLYnAg6JQDoy2wqJbLT+oXNWhlDwHhlVDnSwVM9aNvHryZOgOgilYHJcvo45g+wv9W9PO2oysBkUtf5iXhhBXaMKrIs4iJ6fV1r8WsjacBNthyaO+zw5vPtyYjZKMdrVwTvxOX59MisqOJysnGShn41Ov9PyTNolWl7xWTmFTR/bDd/1YMKsN3/nzBJn4nIh+k7qI/YB7DKm/f1IdGiPtq3yHYn1gFJYXDGSvae5kDez7PtcxUCAwEAAaOCAUUwggFBMB0GA1UdDgQWBBSQTkL3N8vhGLlatVE3Lh57+n5jIjAMBgNVHRMBAf8EAjAAMDgGCCsGAQUFBwEBBCwwKjAoBggrBgEFBQcwAYYcaHR0cDovL2VoY2EuZ2VtYXRpay5kZS9vY3NwLzAOBgNVHQ8BAf8EBAMCBDAwHwYDVR0jBBgwFoAUeunhb+oUWRYF7gPp0/0hq97p2Z4wIAYDVR0gBBkwFzAKBggqghQATASBIzAJBgcqghQATARMMIGEBgUrJAgDAwR7MHmkKDAmMQswCQYDVQQGEwJERTEXMBUGA1UECgwOZ2VtYXRpayBCZXJsaW4wTTBLMEkwRzAXDBXDlmZmZW50bGljaGUgQXBvdGhla2UwCQYHKoIUAEwENhMhMy1TTUMtQi1UZXN0a2FydGUtODgzMTEwMDAwMTE2OTQ4MA0GCSqGSIb3DQEBCwUAA4IBAQAH+r1D+L1JbtQiXs6kCoQZWpxi8sk7K+fBJXxemfwb5qED0BkdtV5Nsd4Io5osJFrIQiBccIofM4X/7p5A2OTfuG11imB9c8eVcQRdL2vEPUuUu2WgZccd0Q4gz9GaVOHVIE2CviV36/eZbSp6zauqx8efBpLta3iyxMf/vJEzRQy2RKRoeaAYDtn/wihXiwpCo1+lyMJLOFl8TER48pjb0kJQdXAhrSB8C1tRHPHb2cbeVECNwDDX9qJlGTrMwnmOVO2VgMMmZJ8iwL34oyxVF7ULaN59HsW6rVE2g88h/N8sp57PeqVA7bzASHxgCwjhQL7aqLqKDjrxhEt6m/zC"
            )!
        )

        // swiftlint:enable line_length

        let sut = DefaultAVSSession(
            httpClient: DefaultHTTPClient(
                urlSessionConfiguration: .ephemeral,
                interceptors: [
                    LoggingInterceptor(log: .body),
                ]
            )
        )

        // then
        var success = false
        let avsSessionResponse = try await sut.redeem(message: message, endpoint: endPoint, recipients: [x509])
        Swift.print(avsSessionResponse)
    }
}

struct AVSIntegrationTestConfiguration {
    let url: String
    let additionalHeaders: [String: String]
}

extension AVSMessage {
    enum Fixtures {
        static let completeExample = AVSMessage(
            version: 2,
            supplyOptionsType: .delivery,
            name: "Dr. Maximilian von Muster",
            address: ["Bundesallee", "312", "12345", "Berlin"],
            hint: "Bitte im Morsecode klingeln: -.-.",
            text: "123456",
            phone: "004916094858168",
            mail: "max@musterfrau.de",
            transactionID: UUID(uuidString: "ee63e415-9a99-4051-ab07-257632faf985")!,
            taskID: "160.123.456.789.123.58",
            accessCode: "777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"
        )
    }
}
