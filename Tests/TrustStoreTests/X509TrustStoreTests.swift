//
//  Copyright (c) 2021 gematik GmbH
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

import DataKit
import Foundation
import Nimble
import OpenSSL
@testable import TrustStore
import XCTest

// swiftlint:disable line_length identifier_name
final class X509TrustStoreTests: XCTestCase {
    lazy var epaVauEnc: X509 = {
        let file = "2_C.FD.AUT_oid_epa_vau_ecc.pem"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var vauEncExpired: X509 = {
        let file = "c.fd.enc-erp-erpserver-expired.pem"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var vauEncOtherCa: X509 = {
        let file = "c.fd.enc-erp-erpserver-otherCA.pem"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var vauEncReference: X509 = {
        let file = "c.fd.enc-erp-erpserverReferenz.pem"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var vauSigReference: X509 = {
        let file = "c.fd.sig-erp-erpserverReferenz.pem"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var kompCa10TestOnly: X509 = {
        let file = "GEM.KOMP-CA10-TEST-ONLY.pem"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var kompCa11TestOnly: X509 = {
        let file = "GEM.KOMP-CA11-TEST-ONLY.pem"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var rootCa3TestOnly: X509 = {
        let file = "GEM.RCA3-TEST-ONLY.pem"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var idpSigReference1: X509 = {
        let file = "idp-fd-sig-refimpl-1.pem"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var idpSigReference2: X509 = {
        let file = "idp-fd-sig-refimpl-2.pem"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var idpSigReference3: X509 = {
        let file = "idp-fd-sig-refimpl-3.pem"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    // See gemSpec_Krypt: A_21217 + Tab_KRYPT_ERP_FdV_Truststore_aktualisieren
    func testInitializeValid() throws {
        // given
        let caCerts = [kompCa10TestOnly]
        let eeCerts = [vauEncReference, idpSigReference2, idpSigReference3]

        // when
        let sut = try X509TrustStore(
            trustAnchor: rootCa3TestOnlyTrustAnchor.certificate,
            addRoots: [],
            caCerts: caCerts,
            eeCerts: eeCerts
        )

        // then
        expect(sut.vauCert) == vauEncReference
        expect(sut.idpCerts) == [idpSigReference2, idpSigReference3]
    }

    func testValidateCaCertsForCategoryB() throws {
        // given
        let trustStore = [rootCa3TestOnly]
        let caCerts = [kompCa10TestOnly, kompCa11TestOnly]

        // when
        let validatedCerts = X509TrustStore.filter(caCerts: caCerts, trusting: trustStore)

        // then
        expect(validatedCerts) == [kompCa10TestOnly, kompCa11TestOnly]
    }

    func testValidateCaCertsForCategoryCPlusD() throws {
        // given
        let trustStore = [rootCa3TestOnly, kompCa10TestOnly]
        let eeCerts = [vauEncReference, idpSigReference2, idpSigReference3]

        // when
        let validatedCerts = X509TrustStore.filter(eeCerts: eeCerts, trusting: trustStore)

        // then
        expect(validatedCerts.vauCerts) == [vauEncReference]
        expect(validatedCerts.idpCerts) == [idpSigReference2, idpSigReference3]
    }

    func testValidateCaCertsForCategoryC_alternative() throws {
        // given
        let trustStore = [rootCa3TestOnly, kompCa11TestOnly]
        let eeCerts = [vauEncOtherCa]

        // when
        let validatedCerts = X509TrustStore.filter(eeCerts: eeCerts, trusting: trustStore)

        // expect
        expect(validatedCerts.vauCerts) == [vauEncOtherCa]
        expect(validatedCerts.idpCerts) == []
    }

    func testValidateCaCertsForCategoryC_invalid() throws {
        // given
        let trustStore = [rootCa3TestOnly, kompCa10TestOnly]
        let eeCerts = [vauSigReference, vauEncExpired, vauEncOtherCa]

        // when
        let validatedCerts = X509TrustStore.filter(eeCerts: eeCerts, trusting: trustStore)

        // then
        expect(validatedCerts.vauCerts) == []
        expect(validatedCerts.idpCerts) == []
    }

    func testBuildFromCertList() throws {
        // given
        guard let url = Bundle(for: Self.self)
            .url(forResource: "kompca10-vauref-idpsig3", withExtension: "json", subdirectory: "CertList.bundle"),
            let json = try? Data(contentsOf: url)
        else {
            fatalError("Could not load json")
        }
        let certList = try CertList.from(data: json)

        // when
        let sut = try X509TrustStore(trustAnchor: rootCa3TestOnlyTrustAnchor, certList: certList)

        // then
        let expectedVauCert =
            "MIIC7jCCApWgAwIBAgIHATwrYu8gtzAKBggqhkjOPQQDAjCBhDELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxMjAwBgNVBAsMKUtvbXBvbmVudGVuLUNBIGRlciBUZWxlbWF0aWtpbmZyYXN0cnVrdHVyMSAwHgYDVQQDDBdHRU0uS09NUC1DQTEwIFRFU1QtT05MWTAeFw0yMDEwMDcwMDAwMDBaFw0yNTA4MDcwMDAwMDBaMF4xCzAJBgNVBAYTAkRFMSYwJAYDVQQKDB1nZW1hdGlrIFRFU1QtT05MWSAtIE5PVC1WQUxJRDEnMCUGA1UEAwweRVJQIFJlZmVyZW56ZW50d2lja2x1bmcgRkQgRW5jMFowFAYHKoZIzj0CAQYJKyQDAwIIAQEHA0IABKYLzjl704qFX+oEuUOyLV70i2Bn2K4jekh/YOxExtdADB3X/q7fX/tVr09GtDRxe3h1yov9TwuHaHYh91RlyMejggEUMIIBEDAMBgNVHRMBAf8EAjAAMCEGA1UdIAQaMBgwCgYIKoIUAEwEgSMwCgYIKoIUAEwEgUowHQYDVR0OBBYEFK5+wVL9g8tGve6b1MdHK1xs62H7MDgGCCsGAQUFBwEBBCwwKjAoBggrBgEFBQcwAYYcaHR0cDovL2VoY2EuZ2VtYXRpay5kZS9vY3NwLzAOBgNVHQ8BAf8EBAMCAwgwUwYFKyQIAwMESjBIMEYwRDBCMEAwMgwwRS1SZXplcHQgdmVydHJhdWVuc3fDvHJkaWdlIEF1c2bDvGhydW5nc3VtZ2VidW5nMAoGCCqCFABMBIICMB8GA1UdIwQYMBaAFCjw+OapyHfMQ0Xbmq7XOoOsDg+oMAoGCCqGSM49BAMCA0cAMEQCIGZ20lLY2WEAGOTmNEFBB1EeU645fE0Iy2U9ypFHMlw4AiAVEP0HYut0Z8sKUk6WVanMmKXjfxO/qgQFzjsbq954dw=="
        let expectedIdpCert =
            "MIICsTCCAligAwIBAgIHAbssqQhqOzAKBggqhkjOPQQDAjCBhDELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxMjAwBgNVBAsMKUtvbXBvbmVudGVuLUNBIGRlciBUZWxlbWF0aWtpbmZyYXN0cnVrdHVyMSAwHgYDVQQDDBdHRU0uS09NUC1DQTEwIFRFU1QtT05MWTAeFw0yMTAxMTUwMDAwMDBaFw0yNjAxMTUyMzU5NTlaMEkxCzAJBgNVBAYTAkRFMSYwJAYDVQQKDB1nZW1hdGlrIFRFU1QtT05MWSAtIE5PVC1WQUxJRDESMBAGA1UEAwwJSURQIFNpZyAzMFowFAYHKoZIzj0CAQYJKyQDAwIIAQEHA0IABIYZnwiGAn5QYOx43Z8MwaZLD3r/bz6BTcQO5pbeum6qQzYD5dDCcriw/VNPPZCQzXQPg4StWyy5OOq9TogBEmOjge0wgeowDgYDVR0PAQH/BAQDAgeAMC0GBSskCAMDBCQwIjAgMB4wHDAaMAwMCklEUC1EaWVuc3QwCgYIKoIUAEwEggQwIQYDVR0gBBowGDAKBggqghQATASBSzAKBggqghQATASBIzAfBgNVHSMEGDAWgBQo8Pjmqch3zENF25qu1zqDrA4PqDA4BggrBgEFBQcBAQQsMCowKAYIKwYBBQUHMAGGHGh0dHA6Ly9laGNhLmdlbWF0aWsuZGUvb2NzcC8wHQYDVR0OBBYEFC94M9LgW44lNgoAbkPaomnLjS8/MAwGA1UdEwEB/wQCMAAwCgYIKoZIzj0EAwIDRwAwRAIgCg4yZDWmyBirgxzawz/S8DJnRFKtYU/YGNlRc7+kBHcCIBuzba3GspqSmoP1VwMeNNKNaLsgV8vMbDJb30aqaiX1"
        expect(sut.vauCert.derBytes?.base64EncodedString()) == expectedVauCert
        expect(sut.idpCerts.count) == 1
        expect(sut.idpCerts.first?.derBytes?.base64EncodedString()) == expectedIdpCert
    }

    func testRebuildFromCertList() throws {
        // given
        let caCerts = [kompCa10TestOnly]
        let eeCerts = [vauEncReference, idpSigReference2, idpSigReference3, vauEncExpired]
        let trustStore = try X509TrustStore(
            trustAnchor: rootCa3TestOnlyTrustAnchor.certificate,
            addRoots: [],
            caCerts: caCerts,
            eeCerts: eeCerts
        )

        // when
        let certList = trustStore.certList
        let sut = try X509TrustStore(trustAnchor: rootCa3TestOnlyTrustAnchor, certList: certList)

        // then
        expect(sut.vauCert) == vauEncReference
        expect(sut.idpCerts) == [idpSigReference2, idpSigReference3]
    }

    func testContainsEECert() throws {
        // given
        let caCerts = [kompCa10TestOnly]
        let eeCerts = [vauEncReference, idpSigReference2, idpSigReference3]

        // when
        let sut = try X509TrustStore(
            trustAnchor: rootCa3TestOnlyTrustAnchor.certificate,
            addRoots: [],
            caCerts: caCerts,
            eeCerts: eeCerts
        )

        // then
        expect(sut.containsEECert(self.vauEncReference)) == true
        expect(sut.containsEECert(self.idpSigReference2)) == true
        expect(sut.containsEECert(self.kompCa10TestOnly)) == false
    }

    private lazy var ocspList_FdEnc: OCSPList = {
        guard let url = Bundle(for: Self.self).url(forResource: "oscp-responses-fd-enc",
                                                   withExtension: "json",
                                                   subdirectory: "OCSPList.bundle"),
            let json = try? Data(contentsOf: url)
        else {
            fatalError("Could not load json")
        }
        return try! OCSPList.from(data: json)
    }()

    private lazy var ocspList_FdEncIdpSig1IdpSig3: OCSPList = {
        guard let url = Bundle(for: Self.self).url(forResource: "oscp-responses-fd-enc-idp-sig1-idp-sig3",
                                                   withExtension: "json",
                                                   subdirectory: "OCSPList.bundle"),
            let json = try? Data(contentsOf: url)
        else {
            fatalError("Could not load json")
        }
        return try! OCSPList.from(data: json)
    }()

    private lazy var ocspList_NotSignedByKompCa: OCSPList = {
        guard let url = Bundle(for: Self.self).url(forResource: "oscp-responses-fd-enc-idp-sig_notKompCa10signed",
                                                   withExtension: "json",
                                                   subdirectory: "OCSPList.bundle"),
            let json = try? Data(contentsOf: url)
        else {
            fatalError("Could not load json")
        }
        return try! OCSPList.from(data: json)
    }()

    // [REQ:gemSpec_Krypt:A_21218]
    func testCheckCertificateStatus_FdEnc() throws {
        // given
        let caCerts = [kompCa10TestOnly]
        let eeCerts = [vauEncReference]
        let sut = try X509TrustStore(
            trustAnchor: rootCa3TestOnlyTrustAnchor.certificate,
            addRoots: [],
            caCerts: caCerts,
            eeCerts: eeCerts
        )
        let ocspResponses_FdEnc = try ocspList_FdEnc.responses.map { try OCSPResponse(der: $0) }

        // then
        expect(try sut.checkEeCertificatesStatus(with: ocspResponses_FdEnc)) == true
    }

    // [REQ:gemSpec_Krypt:A_21218]
    func testCheckCertificateStatus_FdEncIdpSig1IdpSig3() throws {
        // given
        let caCerts = [kompCa10TestOnly]
        let eeCerts = [vauEncReference, idpSigReference1, idpSigReference3]
        let sut = try X509TrustStore(
            trustAnchor: rootCa3TestOnlyTrustAnchor.certificate,
            addRoots: [],
            caCerts: caCerts,
            eeCerts: eeCerts
        )
        let ocspResponses_FdEncIdpSig1IdpSig3 = try ocspList_FdEncIdpSig1IdpSig3.responses
            .map { try OCSPResponse(der: $0) }

        // then
        expect(try sut.checkEeCertificatesStatus(with: ocspResponses_FdEncIdpSig1IdpSig3)) == true
    }

    // [REQ:gemSpec_Krypt:A_21218] For every EE certificate there must be a matching OCSP response
    func testCheckCertificateStatus_failWhenOneEeCertHasNoMatchingResponse() throws {
        // given
        let caCerts = [kompCa10TestOnly]
        let eeCerts = [vauEncReference, idpSigReference1]
        let sut = try X509TrustStore(
            trustAnchor: rootCa3TestOnlyTrustAnchor.certificate,
            addRoots: [],
            caCerts: caCerts,
            eeCerts: eeCerts
        )
        let ocspResponses_FdEnc = try ocspList_FdEnc.responses.map { try OCSPResponse(der: $0) }
        // enforce for this test: responses.count == eeCerts.count == 2
        let ocspResponses_FdEnc2Times = ocspResponses_FdEnc + ocspResponses_FdEnc

        // then
        expect(try sut.checkEeCertificatesStatus(with: ocspResponses_FdEnc2Times)) == false
    }

    // [REQ:gemSpec_Krypt:A_21218] For every  OCSP response there must be a matching EE certificate
    func testCheckCertificateStatus_failWhenOneResponseHasNoMatchingEeCert() throws {
        // given
        let caCerts = [kompCa10TestOnly]
        // enforce for this test: responses.count == eeCerts.count == 3
        let eeCerts = [vauEncReference, idpSigReference1, idpSigReference1] // missing idpSigReference3
        let sut = try X509TrustStore(
            trustAnchor: rootCa3TestOnlyTrustAnchor.certificate,
            addRoots: [],
            caCerts: caCerts,
            eeCerts: eeCerts
        )
        let ocspResponses_FdEncIdpSig1IdpSig3 = try ocspList_FdEncIdpSig1IdpSig3.responses
            .map { try OCSPResponse(der: $0) }

        // then
        expect(try sut.checkEeCertificatesStatus(with: ocspResponses_FdEncIdpSig1IdpSig3)) == false
    }

    // [REQ:gemSpec_Krypt:A_21218] OCSP responder certificates must be verifiable by the trust store
    func testCheckEeCertificatesStatus_failWhenResponsesCannotBeVerifiedByTrustStore() throws {
        // given
        let caCerts = [kompCa10TestOnly]
        let eeCerts = [vauEncReference, idpSigReference2, idpSigReference3]
        let sut = try X509TrustStore(
            trustAnchor: rootCa3TestOnlyTrustAnchor.certificate,
            addRoots: [],
            caCerts: caCerts,
            eeCerts: eeCerts
        )
        let ocspResponses = try ocspList_NotSignedByKompCa.responses.map { try OCSPResponse(der: $0) }

        expect(try sut.checkEeCertificatesStatus(with: ocspResponses)) == false
    }
}

enum CertificateResourceFileReader {
    enum InForm {
        case pem
        case der
    }

    enum Error: Swift.Error {
        case fileNotFound(String)
    }

    static func readFromCertificatesBundle(file: String, inForm _: InForm = .pem) throws -> Data {
        let bundle = Bundle(for: X509TrustStoreTests.self)
        guard let url = bundle.resourceURL?
            .appendingPathComponent("Certificates.bundle")
            .appendingPathComponent(file)
        else {
            throw Error.fileNotFound(file)
        }
        return try Data(contentsOf: url, options: .mappedIfSafe)
    }
}

let rootCa3TestOnlyTrustAnchor: TrustAnchor = {
    let file = "GEM.RCA3-TEST-ONLY.pem"
    let pem = try! CertificateResourceFileReader.readFromCertificatesBundle(file: file)
    return try! TrustAnchor(withPEM: pem.utf8string!)
}()
