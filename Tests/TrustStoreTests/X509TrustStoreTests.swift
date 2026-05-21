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

import Foundation
import Nimble
import OpenSSL
@testable import TrustStore
import XCTest

// swiftlint:disable line_length identifier_name
final class X509TrustStoreTests: XCTestCase {
    lazy var epaVauEnc: X509 = {
        let file = "2_C.FD.AUT_oid_epa_vau_ecc"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var vauEncExpired: X509 = {
        let file = "c.fd.enc-erp-erpserver-expired"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var vauEncOtherCa: X509 = {
        let file = "c.fd.enc-erp-erpserver-otherCA"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var vauEncReference: X509 = {
        let file = "c.fd.enc-erp-erpserverReferenz"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var vauSigReference: X509 = {
        let file = "c.fd.sig-erp-erpserverReferenz"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var kompCa10TestOnly: X509 = {
        let file = "GEM.KOMP-CA10-TEST-ONLY"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    /// rca5TestOnly + kompCa51TestOnly validate the OCSPResponse-signer
    lazy var rca5TestOnly: X509 = {
        let file = "GEM.RCA5-TEST-ONLY"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    /// rca5TestOnly + kompCa51TestOnly validate the OCSPResponse-signer
    lazy var kompCa51TestOnly: X509 = {
        let file = "GEM.KOMP-CA51-TEST-ONLY"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var kompCa11TestOnly: X509 = {
        let file = "GEM.KOMP-CA11-TEST-ONLY"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var rootCa3TestOnly: X509 = {
        let file = "GEM.RCA3-TEST-ONLY"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var rootCa4TestOnlyCrossRootCa3TestOnly: X509 = {
        let file = "GEM.RCA4_TEST-ONLY-CROSS-GEM.RCA3_TEST-ONLY"
        return try! X509(der: CertificateResourceFileReader.readFromCertificatesBundle(file: file, inForm: .der))
    }()

    lazy var rootCa5TestOnlyCrossRootCa4TestOnly: X509 = {
        let file = "GEM.RCA5_TEST-ONLY-CROSS-GEM.RCA4_TEST-ONLY"
        return try! X509(der: CertificateResourceFileReader.readFromCertificatesBundle(file: file, inForm: .der))
    }()

    lazy var idpSigReference1: X509 = {
        let file = "idp-fd-sig-refimpl-1"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var idpSigReference2: X509 = {
        let file = "idp-fd-sig-refimpl-2"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    lazy var idpSigReference3: X509 = {
        let file = "idp-fd-sig-refimpl-3"
        return try! X509(pem: CertificateResourceFileReader.readFromCertificatesBundle(file: file))
    }()

    /// See gemSpec_Krypt: A_21217 + Tab_KRYPT_ERP_FdV_Truststore_aktualisieren
    func testInitializeValid() throws {
        // given
        let caCerts = [kompCa10TestOnly]
        let eeCerts = [vauEncReference, idpSigReference2, idpSigReference3]

        // when
        let sut = try X509TrustStore(
            trustAnchor: rootCa3TestOnlyTrustAnchor.certificate,
            addRoots: [],
            caCerts: caCerts,
            eeCerts: eeCerts,
            validationTime: Date(timeIntervalSince1970: 1_736_329_189)
        )

        // then
        expect(sut.vauCert) == vauEncReference
        expect(sut.idpCerts) == [idpSigReference2, idpSigReference3]
    }

    func testValidateCaCertsForCategoryB() {
        // given
        let trustStore = [rootCa3TestOnly]
        let caCerts = [kompCa10TestOnly, kompCa11TestOnly]

        // when
        let validatedCerts = X509TrustStore.filter(
            caCerts: caCerts,
            trusting: trustStore,
            validationTime: Date(timeIntervalSince1970: 1_736_329_189)
        )

        // then
        expect(validatedCerts) == [kompCa10TestOnly, kompCa11TestOnly]
    }

    func testValidateCaCertsForCategoryCPlusD() {
        // given
        let trustStore = [rootCa3TestOnly, kompCa10TestOnly]
        let eeCerts = [vauEncReference, idpSigReference2, idpSigReference3]

        // when
        let validatedCerts = X509TrustStore.filter(
            eeCerts: eeCerts,
            trusting: trustStore,
            validationTime: Date(timeIntervalSince1970: 1_736_329_189)
        )

        // then
        expect(validatedCerts.vauCerts) == [vauEncReference]
        expect(validatedCerts.idpCerts) == [idpSigReference2, idpSigReference3]
    }

    func testValidateCaCertsForCategoryC_alternative() {
        // given
        let trustStore = [rootCa3TestOnly, kompCa11TestOnly]
        let eeCerts = [vauEncOtherCa]

        // when
        let validatedCerts = X509TrustStore.filter(
            eeCerts: eeCerts,
            trusting: trustStore,
            validationTime: Date(timeIntervalSince1970: 1_736_329_189)
        )

        // expect
        expect(validatedCerts.vauCerts) == [vauEncOtherCa]
        expect(validatedCerts.idpCerts) == []
    }

    func testValidateCaCertsForCategoryC_invalid() {
        // given
        let trustStore = [rootCa3TestOnly, kompCa10TestOnly]
        let eeCerts = [vauSigReference, vauEncExpired, vauEncOtherCa]

        // when
        let validatedCerts = X509TrustStore.filter(
            eeCerts: eeCerts,
            trusting: trustStore,
            validationTime: Date(timeIntervalSince1970: 1_736_329_189)
        )

        // then
        expect(validatedCerts.vauCerts) == []
        expect(validatedCerts.idpCerts) == []
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
            eeCerts: eeCerts,
            validationTime: Date(timeIntervalSince1970: 1_736_329_189)
        )

        // then
        expect(sut.containsEECert(self.vauEncReference)) == true
        expect(sut.containsEECert(self.idpSigReference2)) == true
        expect(sut.containsEECert(self.kompCa10TestOnly)) == false
    }

    func testCrossValidation_succes() throws {
        // given
        // rca3TestOnly validates rca4TestOnly
        // rc4TestOnly validates rca5TestOnly
        // rca5TestOnly validates kompCa51TestOnly
        let addRootCerts = [rootCa4TestOnlyCrossRootCa3TestOnly, rootCa5TestOnlyCrossRootCa4TestOnly]
        let caCerts = [kompCa10TestOnly, kompCa51TestOnly]
        let eeCerts = [vauEncReference]

        // when
        let sut = try X509TrustStore(
            trustAnchor: rootCa3TestOnlyTrustAnchor.certificate,
            addRoots: addRootCerts,
            caCerts: caCerts,
            eeCerts: eeCerts,
            validationTime: Date(timeIntervalSince1970: 1_736_329_189)
        )

        // then
        expect(sut.addRoots.contains([self.rootCa4TestOnlyCrossRootCa3TestOnly])).to(beTrue())
        expect(sut.addRoots.contains([self.rootCa5TestOnlyCrossRootCa4TestOnly])).to(beTrue())
        expect(sut.caCerts.contains([self.kompCa51TestOnly])).to(beTrue())
    }

    func testCrossValidation_cossCertificateMissing() throws {
        // given
        // rca3TestOnly cross rca4TestOnly missing!
        // rc4TestOnly validates rca5TestOnly
        // rca5TestOnly validates kompCa51TestOnly
        let addRootCerts = [rootCa5TestOnlyCrossRootCa4TestOnly]
        let caCerts = [kompCa10TestOnly, kompCa51TestOnly]
        let eeCerts = [vauEncReference]

        // when
        let sut = try X509TrustStore(
            trustAnchor: rootCa3TestOnlyTrustAnchor.certificate,
            addRoots: addRootCerts,
            caCerts: caCerts,
            eeCerts: eeCerts,
            validationTime: Date(timeIntervalSince1970: 1_736_329_189)
        )

        // then
        expect(sut.addRoots.contains([self.rootCa5TestOnlyCrossRootCa4TestOnly])).to(beFalse())
        expect(sut.caCerts.contains([self.kompCa51TestOnly])).to(beFalse())
    }

    private lazy var ocspList_FdEnc: OCSPList = {
        guard let url = Bundle.module.url(forResource: "oscp-responses-fd-enc",
                                          withExtension: "json",
                                          subdirectory: "Resources/OCSPList.bundle"),
            let json = try? Data(contentsOf: url)
        else {
            fatalError("Could not load json")
        }
        return try! OCSPList.from(data: json)
    }()

    private lazy var ocspList_FdEncIdpSig3: OCSPList = {
        guard let url = Bundle.module.url(forResource: "oscp-responses-fd-enc-idp-sig3",
                                          withExtension: "json",
                                          subdirectory: "Resources/OCSPList.bundle"),
            let json = try? Data(contentsOf: url)
        else {
            fatalError("Could not load json")
        }
        return try! OCSPList.from(data: json)
    }()

    private lazy var ocspList_NotSignedByKompCa: OCSPList = {
        guard let url = Bundle.module.url(forResource: "oscp-responses-fd-enc-idp-sig_notKompCa10signed",
                                          withExtension: "json",
                                          subdirectory: "Resources/OCSPList.bundle"),
            let json = try? Data(contentsOf: url)
        else {
            fatalError("Could not load json")
        }
        return try! OCSPList.from(data: json)
    }()

    // [REQ:gemSpec_Krypt:A_21218]
    func testCheckCertificateStatus_FdEnc() throws {
        // given
        // rca5TestOnly + kompCa51TestOnly validate the OCSPResponse-signer
        let addRootCerts = [rootCa4TestOnlyCrossRootCa3TestOnly, rootCa5TestOnlyCrossRootCa4TestOnly]
        let caCerts = [kompCa10TestOnly, kompCa51TestOnly]
        let eeCerts = [vauEncReference]
        let sut = try X509TrustStore(
            trustAnchor: rootCa3TestOnlyTrustAnchor.certificate,
            addRoots: addRootCerts,
            caCerts: caCerts,
            eeCerts: eeCerts,
            validationTime: Date(timeIntervalSince1970: 1_736_329_189)
        )
        let ocspResponses_FdEnc = try ocspList_FdEnc.responses.map { try OCSPResponse(der: $0) }

        // then
        expect(try sut.checkEeCertificatesStatus(with: ocspResponses_FdEnc)) == true
    }

    // [REQ:gemSpec_Krypt:A_21218]
    func testCheckCertificateStatus_FdEncIdpSig1IdpSig3() throws {
        // given
        // rca5TestOnly + kompCa51TestOnly validate the OCSPResponse-signer
        let addRootCerts = [rootCa4TestOnlyCrossRootCa3TestOnly, rootCa5TestOnlyCrossRootCa4TestOnly]
        let caCerts = [kompCa10TestOnly, kompCa51TestOnly]
        let eeCerts = [vauEncReference, idpSigReference3]
        let sut = try X509TrustStore(
            trustAnchor: rootCa3TestOnlyTrustAnchor.certificate,
            addRoots: addRootCerts,
            caCerts: caCerts,
            eeCerts: eeCerts,
            validationTime: Date(timeIntervalSince1970: 1_736_329_189) // Wed Jan 08 2025 09:39:49 GMT+0000
        )
        let ocspResponses_FdEncIdpSig3 = try ocspList_FdEncIdpSig3.responses
            .map { try OCSPResponse(der: $0) }

        // then
        expect(try sut.checkEeCertificatesStatus(with: ocspResponses_FdEncIdpSig3)) == true
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
            eeCerts: eeCerts,
            validationTime: Date(timeIntervalSince1970: 1_736_329_189) // Wed Jan 08 2025 09:39:49 GMT+0000
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
        // enforce for this test: responses.count == eeCerts.count == 2
        let eeCerts = [vauEncReference] // missing idpSigReference3
        let sut = try X509TrustStore(
            trustAnchor: rootCa3TestOnlyTrustAnchor.certificate,
            addRoots: [],
            caCerts: caCerts,
            eeCerts: eeCerts,
            validationTime: Date(timeIntervalSince1970: 1_736_329_189) // Wed Jan 08 2025 09:39:49 GMT+0000
        )
        let ocspResponses_FdEncIdpSig3 = try ocspList_FdEncIdpSig3.responses
            .map { try OCSPResponse(der: $0) }

        // then
        expect(try sut.checkEeCertificatesStatus(with: ocspResponses_FdEncIdpSig3)) == false
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
            eeCerts: eeCerts,
            validationTime: Date(timeIntervalSince1970: 1_736_329_189) // Wed Jan 08 2025 09:39:49 GMT+0000
        )
        let ocspResponses = try ocspList_NotSignedByKompCa.responses.map { try OCSPResponse(der: $0) }

        expect(try sut.checkEeCertificatesStatus(with: ocspResponses)) == false
    }
}

enum CertificateResourceFileReader {
    enum InForm: String {
        case pem
        case der
    }

    enum Error: Swift.Error {
        case fileNotFound(String)
    }

    static func readFromCertificatesBundle(file: String, inForm: InForm = .pem) throws -> Data {
        let bundle = Bundle.module
        guard let url = bundle.url(forResource: file,
                                   withExtension: inForm.rawValue,
                                   subdirectory: "Resources/Certificates.bundle")
        else {
            throw Error.fileNotFound(file)
        }
        return try Data(contentsOf: url, options: .mappedIfSafe)
    }
}

let rootCa3TestOnlyTrustAnchor: TrustAnchor = {
    let file = "GEM.RCA3-TEST-ONLY"
    let pem = try! CertificateResourceFileReader.readFromCertificatesBundle(file: file)
    return try! TrustAnchor(withPEM: String(data: pem, encoding: .utf8)!)
}()

// swiftlint:enable line_length identifier_name
