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

@testable import AVS
import Foundation
import Nimble
import OpenSSL
import XCTest

// swiftlint:disable line_length
final class RsaOnlyAVSCmsEncrypterTests: XCTestCase {
    func testCmsEncrypt() throws {
        // given
        let data = Data([0x00])
        let x509rsa = try X509(pem: x509rsaPem.data(using: .utf8)!)
        let recipients = [x509rsa]

        let sut = RsaOnlyAVSCmsEncrypter()

        // when
        let result = try sut.cmsEncrypt(data, recipients: recipients)

        // then expect sut to create a byte sequence that contains the representation of
        // SEQUENCE (2 elem)
        //            OBJECT IDENTIFIER 1.2.840.113549.1.1.7 rsaOAEP (PKCS #1)
        //            SEQUENCE (2 elem)
        //              [0] (1 elem)
        //                SEQUENCE (1 elem)
        //                  OBJECT IDENTIFIER 2.16.840.1.101.3.4.2.1 sha-256 (NIST Algorithm)
        //              [1] (1 elem)
        //                SEQUENCE (2 elem)
        //                  OBJECT IDENTIFIER 1.2.840.113549.1.1.8 pkcs1-MGF (PKCS #1)
        //                  SEQUENCE (1 elem)
        //                    OBJECT IDENTIFIER 2.16.840.1.101.3.4.2.1 sha-256 (NIST Algorithm)
        expect(result.hexString())
            .to(
                contain(
                    "303806092A864886F70D010107302BA00D300B0609608648016503040201A11A301806092A864886F70D010108300B0609608648016503040201"
                )
            )
    }

    let x509rsaPem =
        """
        -----BEGIN CERTIFICATE-----
        MIIFSTCCBDGgAwIBAgIHAXLewUJXxjANBgkqhkiG9w0BAQsFADCBmjELMAkGA1UE
        BhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxSDBGBgNVBAsM
        P0luc3RpdHV0aW9uIGRlcyBHZXN1bmRoZWl0c3dlc2Vucy1DQSBkZXIgVGVsZW1h
        dGlraW5mcmFzdHJ1a3R1cjEgMB4GA1UEAwwXR0VNLlNNQ0ItQ0EyNCBURVNULU9O
        TFkwHhcNMjAwMTI0MDAwMDAwWhcNMjQxMjExMjM1OTU5WjCB5TELMAkGA1UEBhMC
        REUxEDAOBgNVBAcMB0hhbWJ1cmcxDjAMBgNVBBEMBTIyNDUzMRgwFgYDVQQJDA9I
        ZXNlbHN0w7xja2VuIDkxKjAoBgNVBAoMITMtU01DLUItVGVzdGthcnRlLTg4MzEx
        MDAwMDExNjg3MzEdMBsGA1UEBRMUODAyNzY4ODMxMTAwMDAxMTY4NzMxEjAQBgNV
        BAQMCVNjaHJhw59lcjESMBAGA1UEKgwJU2llZ2ZyaWVkMScwJQYDVQQDDB5BcG90
        aGVrZSBhbSBGbHVnaGFmZW5URVNULU9OTFkwggEiMA0GCSqGSIb3DQEBAQUAA4IB
        DwAwggEKAoIBAQCZ9ihWMq2T1C9OEoXpbWJWjALF/X6pbRmzmln2gdRxW7k/BS59
        YpONamWX3Wmjc7ELpmiU+5atOpSrFhS7QCQomTyCbnuIYOB6WVaYgDREceZ7bu29
        QxD04aHGGrOwaU/55i4f3JTa88QtyMOqPEA/YW3XoCKdPwouiVEP8AXJ+8dRiYCS
        SzPUKOOy+R53sMhrTmpkwGNfOmq9Kg1uX8NRDg0Lamv41O9XbsfJTuzVa4EcKALx
        HEMprsUokV9WaGVK0nHCyU0TTi6V9EqslVoK1iyMgUUl2nfx1/aRtUViFbXtd6DR
        6SeUhcqIzFOVBnl9EY4alAnHfR/qE8iBe6bbAgMBAAGjggFFMIIBQTAdBgNVHQ4E
        FgQUGRLcBNLvAKTcCYYIS+HLzaac0EAwDAYDVR0TAQH/BAIwADA4BggrBgEFBQcB
        AQQsMCowKAYIKwYBBQUHMAGGHGh0dHA6Ly9laGNhLmdlbWF0aWsuZGUvb2NzcC8w
        DgYDVR0PAQH/BAQDAgQwMB8GA1UdIwQYMBaAFHrp4W/qFFkWBe4D6dP9Iave6dme
        MCAGA1UdIAQZMBcwCgYIKoIUAEwEgSMwCQYHKoIUAEwETDCBhAYFKyQIAwMEezB5
        pCgwJjELMAkGA1UEBhMCREUxFzAVBgNVBAoMDmdlbWF0aWsgQmVybGluME0wSzBJ
        MEcwFwwVw5ZmZmVudGxpY2hlIEFwb3RoZWtlMAkGByqCFABMBDYTITMtU01DLUIt
        VGVzdGthcnRlLTg4MzExMDAwMDExNjg3MzANBgkqhkiG9w0BAQsFAAOCAQEALmkJ
        S6sCvx0cyDcFMRFiCJ7Po3H6jAPGgVmuQsldo+AHcjN7YAuM/7JwOBulvycZOEBi
        Mf+NYkjfzQRM16h9SHspjFsr8yD78u0JfdKJEYWnpTUEDTl0C0ssv++obWLyw/lj
        1623pjn5Kb0x5yjEbzSGo3kk5S050Bnwf39JGVzv2M1j31y9CQQSAxT3EKl937Gj
        306acGmt6vjDDd0GB8P6nPreulTYh1M0Tlli53gfP7o987q2Pq/jIK13ExF6t5WN
        PCqpN2JbFY8waA6PzoT57zKdT6sB/w26rA2Gnc9eGp9pZ9DH11Qw+x+SArCs1eEh
        0jqYhPIqIs2gJPl3hw==
        -----END CERTIFICATE-----
        """
}
