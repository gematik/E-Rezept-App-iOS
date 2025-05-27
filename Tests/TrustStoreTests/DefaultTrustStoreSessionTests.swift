//
//  Copyright (c) 2024 gematik GmbH
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

import Combine
import Foundation
import Nimble
import TestUtils
@testable import TrustStore
import XCTest

final class DefaultTrustStoreSessionTests: XCTestCase {
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()

    private lazy var certList: CertList = {
        guard let url = Bundle.module
            .url(
                forResource: "kompca10-fd-enc-idp-sig1-idp-sig3",
                withExtension: "json",
                subdirectory: "Resources/CertList.bundle"
            ),
            let json = try? Data(contentsOf: url)
        else {
            fatalError("Could not load json")
        }
        return try! CertList.from(data: json)
    }()

    private lazy var ocspList: OCSPList = {
        guard let url = Bundle.module.url(forResource: "oscp-responses-fd-enc-idp-sig1-idp-sig3",
                                          withExtension: "json",
                                          subdirectory: "Resources/OCSPList.bundle"),
            let json = try? Data(contentsOf: url)
        else {
            fatalError("Could not load json")
        }
        return try! OCSPList.from(data: json)
    }()

    private lazy var ocspList_NotVerifiableByTrustStore: OCSPList = {
        guard let url = Bundle.module.url(forResource: "oscp-responses-fd-enc-idp-sig",
                                          withExtension: "json",
                                          subdirectory: "Resources/OCSPList.bundle"),
            let json = try? Data(contentsOf: url)
        else {
            fatalError("Could not load json")
        }
        return try! OCSPList.from(data: json)
    }()

    // TODO: test data expired ERA-7662 swiftlint:disable:this todo
    func disabled_testLoadVauCertificateFromServer() throws {
        // given
        let serverURL = URL(string: "http://some-service.com/path")!
        let trustStoreClient = TrustStoreClientMock()
        trustStoreClient.loadCertListFromServerAnyPublisherCertListTrustStoreErrorReturnValue = Just(certList)
            .setFailureType(to: TrustStoreError.self)
            .eraseToAnyPublisher()
        trustStoreClient.loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorReturnValue = Just(ocspList)
            .setFailureType(to: TrustStoreError.self)
            .eraseToAnyPublisher()
        let storage = MemStorage()
        storage.set(certList: nil)
        storage.set(ocspList: nil)
        // Some hours after the OCSPResponse's producedAt value 2023-06-09 13:35:44 UTC
        var currentDate = dateFormatter.date(from: "2023-06-09 18:00:00.0000+0000")!

        let dateProvider: TrustStoreTimeProvider = {
            currentDate
        }
        let expirationInterval = TimeInterval(DefaultTrustStoreSession.ocspResponseExpiration)

        let sut = DefaultTrustStoreSession(
            serverURL: serverURL,
            trustAnchor: rootCa3TestOnlyTrustAnchor,
            trustStoreStorage: storage,
            trustStoreClient: trustStoreClient,
            time: dateProvider
        )
        var success = false

        // then
        expect(trustStoreClient.loadCertListFromServerAnyPublisherCertListTrustStoreErrorCalled) == false
        expect(trustStoreClient.loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorCalled) == false

        sut.loadVauCertificate()
            .test(
                expectations: { _ in
                    expect(trustStoreClient.loadCertListFromServerAnyPublisherCertListTrustStoreErrorCalled) == true
                    expect(trustStoreClient.loadCertListFromServerAnyPublisherCertListTrustStoreErrorCallsCount) == 1
                    expect(storage.certListState) == self.certList

                    expect(trustStoreClient.loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorCalled) == true
                    expect(trustStoreClient.loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorCallsCount) == 1
                    expect(storage.ocspListState) == self.ocspList
                    success = true
                }
            )

        expect(success) == true; success = false

        // When saved in storage, the object will not be requested from the server again
        sut.loadVauCertificate()
            .test(expectations: { _ in
                expect(trustStoreClient.loadCertListFromServerAnyPublisherCertListTrustStoreErrorCallsCount) == 1
                expect(trustStoreClient.loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorCallsCount) == 1
                success = true
            })

        expect(success) == true; success = false

        // Advance the time so that saved mocked OCSP responses will be invalidated
        // The same mocked OCSP responses will be received by the client cannot be validated,
        //  so expect a session failure.
        // [REQ:gemSpec_Krypt:A_21218] If only OCSP responses >12h available, we must request new ones
        currentDate = currentDate.advanced(by: TimeInterval(expirationInterval))
        sut.loadVauCertificate()
            .test(failure: { error in
                expect(trustStoreClient.loadCertListFromServerAnyPublisherCertListTrustStoreErrorCallsCount) == 1
                expect(trustStoreClient.loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorCallsCount) == 2

                expect(error) == TrustStoreError.invalidOCSPResponse
                success = true

            }) { _ in
                fail("Expected failing test")
            }
        expect(success) == true
    }

    func testLoadVauCertificateFromServer_failWhenOCSPResponsesCannotBeVerified() throws {
        // given
        let serverURL = URL(string: "http://some-service.com/path")!
        let trustStoreClient = TrustStoreClientMock()
        trustStoreClient.loadCertListFromServerAnyPublisherCertListTrustStoreErrorReturnValue = Just(certList)
            .setFailureType(to: TrustStoreError.self)
            .eraseToAnyPublisher()
        trustStoreClient
            .loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorReturnValue =
            Just(ocspList_NotVerifiableByTrustStore)
                .setFailureType(to: TrustStoreError.self)
                .eraseToAnyPublisher()
        let storage = MemStorage()
        storage.set(certList: nil)
        storage.set(ocspList: nil)
        let currentDate = dateFormatter.date(from: "2021-04-22 11:00:00.0000+0000")!

        let dateProvider: TrustStoreTimeProvider = {
            currentDate
        }

        let sut = DefaultTrustStoreSession(
            serverURL: serverURL,
            trustAnchor: rootCa3TestOnlyTrustAnchor,
            trustStoreStorage: storage,
            trustStoreClient: trustStoreClient,
            time: dateProvider
        )

        // then
        expect(trustStoreClient.loadCertListFromServerAnyPublisherCertListTrustStoreErrorCalled) == false
        expect(trustStoreClient.loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorCalled) == false

        sut.loadVauCertificate()
            .test(failure: { error in
                expect(trustStoreClient.loadCertListFromServerAnyPublisherCertListTrustStoreErrorCalled) == true
                expect(trustStoreClient.loadCertListFromServerAnyPublisherCertListTrustStoreErrorCallsCount) == 1
                expect(storage.certListState).to(beNil())

                expect(trustStoreClient.loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorCalled) == true
                expect(trustStoreClient.loadOCSPListFromServerAnyPublisherOCSPListTrustStoreErrorCallsCount) == 1
                expect(storage.ocspListState) == self.ocspList_NotVerifiableByTrustStore

                expect(error) == .eeCertificateOCSPStatusVerification
            }) { _ in
                fail("Expected failing test")
            }
    }

    func testLoadVauCertificate() async throws {
        // given
        let serverURL = URL(string: "http://some-service.com/path")!
        let trustStoreClient = MockTrustStoreClient()
        let trustStoreStorage = MockTrustStoreStorage()

        // Some hours after the OCSPResponse's producedAt value 2024-10-28 09:45:17Z
        var testDate = dateFormatter.date(from: "2024-10-28 15:00:00.0000+0000")!

        let dateProvider: TrustStoreTimeProvider = {
            testDate
        }

        let sut = DefaultTrustStoreSession(
            serverURL: serverURL,
            trustAnchor: rootCa3TestOnlyTrustAnchor,
            trustStoreStorage: trustStoreStorage,
            trustStoreClient: trustStoreClient,
            time: dateProvider
        )

        // when all certificates / OCSP responses are available in storage and valid
        trustStoreStorage.getPKICertificatesReturnValue = Self.Fixtures.pkiCertificatesRca3TestOnly
        trustStoreStorage.getVauCertificateReturnValue = Self.Fixtures.vauCertificateData
        trustStoreStorage.getVauCertificateOcspResponseReturnValue = Self.Fixtures.ocspResponseData
        let vauCertificate = try await sut.vauCertificate()

        // then
        expect(vauCertificate).toNot(beNil())
        expect(vauCertificate.derBytes) == Self.Fixtures.vauCertificateData
        expect(trustStoreStorage.getPKICertificatesCalled) == true
        expect(trustStoreStorage.getPKICertificatesCallsCount) == 1
        expect(trustStoreStorage.getVauCertificateCalled) == true
        expect(trustStoreStorage.getVauCertificateCallsCount) == 1
        expect(trustStoreStorage.getVauCertificateOcspResponseCalled) == true
        expect(trustStoreStorage.getVauCertificateOcspResponseCallsCount) == 1

        // when we advance the time so that the now stored mocked OCSP response is invalid
        // and the very same mocked OCSP response is received by the client so it cannot be validated
        testDate = testDate.advanced(by: TimeInterval(TimeInterval(60 * 60 * 24)))
        trustStoreClient.loadOcspResponseFromServerIssuerCnSerialNrReturnValue = Self.Fixtures.ocspResponseData

        // then
        await expect { try await sut.vauCertificate() }.to(throwError(TrustStoreError.invalidOCSPResponse))
        expect(trustStoreStorage.getPKICertificatesCallsCount) == 2
        expect(trustStoreStorage.getVauCertificateCallsCount) == 2
        expect(trustStoreStorage.getVauCertificateOcspResponseCallsCount) == 2
        expect(trustStoreClient.loadOcspResponseFromServerIssuerCnSerialNrCallsCount) == true
        expect(trustStoreClient.loadOcspResponseFromServerIssuerCnSerialNrCallsCount) == 1

        // when the client receives an updated OCSP response that has been produced more recently
        trustStoreClient.loadOcspResponseFromServerIssuerCnSerialNrReturnValue = Self.Fixtures
            .ocspResponseDataMoreRecentProducedAt
        trustStoreClient.loadPKICertificatesFromServerRootSubjectCnReturnValue = Self.Fixtures
            .pkiCertificatesRca3TestOnly
        trustStoreClient.loadVauCertificateFromServerReturnValue = Self.Fixtures.vauCertificateData
        let vauCertificate2 = try await sut.vauCertificate()

        // then
        expect(vauCertificate2).toNot(beNil())
        expect(vauCertificate2.derBytes) == Self.Fixtures.vauCertificateData
        expect(trustStoreStorage.getPKICertificatesCallsCount) == 3
        expect(trustStoreStorage.getVauCertificateCallsCount) == 3
        expect(trustStoreStorage.getVauCertificateOcspResponseCallsCount) == 3
        expect(trustStoreClient.loadOcspResponseFromServerIssuerCnSerialNrCallsCount) == 2
    }

    func testLoadVauCertificate_memStorage() async throws {
        // This test uses the MemStorage as TrustStoreStorage implementation to store the certificates' data
        // so only the TrustStoreClient is mocked.
        // given
        let serverURL = URL(string: "http://some-service.com/path")!
        let trustStoreClient = MockTrustStoreClient()
        let trustStoreStorage = MemStorage()

        // Some hours after the OCSPResponse's producedAt value  UTC
        var testDate = dateFormatter.date(from: "2024-10-28 15:00:00.0000+0000")!

        let dateProvider: TrustStoreTimeProvider = {
            testDate
        }

        let sut = DefaultTrustStoreSession(
            serverURL: serverURL,
            trustAnchor: rootCa3TestOnlyTrustAnchor,
            trustStoreStorage: trustStoreStorage,
            trustStoreClient: trustStoreClient,
            time: dateProvider
        )

        // when
        trustStoreClient.loadPKICertificatesFromServerRootSubjectCnReturnValue = Self.Fixtures
            .pkiCertificatesRca3TestOnly
        trustStoreClient.loadVauCertificateFromServerReturnValue = Self.Fixtures.vauCertificateData
        trustStoreClient.loadOcspResponseFromServerIssuerCnSerialNrReturnValue = Self.Fixtures.ocspResponseData
        let vauCertificate = try await sut.vauCertificate()

        // then
        expect(vauCertificate).toNot(beNil())
        expect(vauCertificate.derBytes) == Self.Fixtures.vauCertificateData
        expect(trustStoreClient.loadPKICertificatesFromServerRootSubjectCnCalled) == true
        expect(trustStoreClient.loadPKICertificatesFromServerRootSubjectCnCallsCount) == 1
        expect(trustStoreClient.loadVauCertificateFromServerCalled) == true
        expect(trustStoreClient.loadVauCertificateFromServerCallsCount) == 1
        expect(trustStoreClient.loadOcspResponseFromServerIssuerCnSerialNrCalled) == true
        expect(trustStoreClient.loadOcspResponseFromServerIssuerCnSerialNrCallsCount) == 1

        // When already saved in storage...
        let vauCertificate2 = try await sut.vauCertificate()

        // then the object is not be requested from the server again
        expect(vauCertificate2).toNot(beNil())
        expect(vauCertificate2.derBytes) == Self.Fixtures.vauCertificateData
        expect(trustStoreClient.loadPKICertificatesFromServerRootSubjectCnCallsCount) == 1
        expect(trustStoreClient.loadVauCertificateFromServerCallsCount) == 1
        expect(trustStoreClient.loadOcspResponseFromServerIssuerCnSerialNrCallsCount) == 1

        // when we advance the time so that the now stored mocked OCSP response is invalid...
        testDate = testDate.advanced(by: TimeInterval(DefaultTrustStoreSession.ocspResponseExpiration))

        // ... and the very same mocked OCSP response is received by the client and cannot be validated
        // then we expect a session failure.
        await expect { try await sut.vauCertificate() }.to(throwError(TrustStoreError.invalidOCSPResponse))
        expect(trustStoreClient.loadOcspResponseFromServerIssuerCnSerialNrCallsCount) == 2
    }
}

extension DefaultTrustStoreSessionTests {
    enum Fixtures {
        // swiftlint:disable line_length
        static let vauCertificateData = Data(base64Encoded: vauCertificateBase64)!

        static let pkiCertificatesRca3TestOnly = try! PKICertificates.from(string: pkiCertificatesJson)

        static let vauCertificateBase64 = #"""
        MIIDAzCCAqmgAwIBAgICJGQwCgYIKoZIzj0EAwIwgYQxCzAJBgNVBAYTAkRFMR8wHQYDVQQKDBZnZW1hdGlrIEdtYkggTk9ULVZBTElEMTIwMAYDVQQLDClLb21wb25lbnRlbi1DQSBkZXIgVGVsZW1hdGlraW5mcmFzdHJ1a3R1cjEgMB4GA1UEAwwXR0VNLktPTVAtQ0EyOCBURVNULU9OTFkwHhcNMjEwNjAyMTQzNDIwWhcNMjYwNjAxMTQzNDE5WjBgMQswCQYDVQQGEwJERTEiMCAGA1UECgwZSUJNIFRFU1QtT05MWSAtIE5PVC1WQUxJRDEXMBUGA1UEBRMOMDg3NDctVFVFTkMwMDIxFDASBgNVBAMMC2VyZXplcHQtdmF1MFowFAYHKoZIzj0CAQYJKyQDAwIIAQEHA0IABHDBv8a30jresYlldF9SID3T9YfKoZ7KSdoeqojRfNRDAXf4B6f3wMov1rNk+Mll9I2Cj+JY5FzICU2q1APtKuyjggErMIIBJzAdBgNVHQ4EFgQU30hPeqdh/lP/yqE/38++gSgMzMswHwYDVR0jBBgwFoAUAGo4kPOZriGPUtruwYxugK1hIskwTwYIKwYBBQUHAQEEQzBBMD8GCCsGAQUFBzABhjNodHRwOi8vb2NzcDItdGVzdHJlZi5rb21wLWNhLnRlbGVtYXRpay10ZXN0L29jc3AvZWMwDgYDVR0PAQH/BAQDAgMIMCEGA1UdIAQaMBgwCgYIKoIUAEwEgSMwCgYIKoIUAEwEgUowDAYDVR0TAQH/BAIwADBTBgUrJAgDAwRKMEgwRjBEMEIwQDAyDDBFLVJlemVwdCB2ZXJ0cmF1ZW5zd8O8cmRpZ2UgQXVzZsO8aHJ1bmdzdW1nZWJ1bmcwCgYIKoIUAEwEggIwCgYIKoZIzj0EAwIDSAAwRQIhAJd3Y/mAenNWdA0CLO2b6uT/8N68kx76sZiW8Psf6DxKAiAJkgWX1UBQgy1me3+/tpmA4owd9gsbrmiV5hyw3Cl5vQ==
        """#.data(using: .utf8)!

        // producedAt: 20241028094517Z
        static let ocspResponseData = #"""
        MIIEVAoBAKCCBE0wggRJBgkrBgEFBQcwAQEEggQ6MIIENjCCAQ2hYjBgMQswCQYDVQQGEwJERTEmMCQGA1UECgwdYXJ2YXRvIFN5c3RlbXMgR21iSCBOT1QtVkFMSUQxKTAnBgNVBAMMIEtvbXAtQ0EyOCBPQ1NQLVNpZ25lcjMgVEVTVC1PTkxZGA8yMDI0MTAyODA5NDUxN1owgZUwgZIwOzAJBgUrDgMCGgUABBT8X79XfV64wqxpB3xpQTrtT+Z95AQUAGo4kPOZriGPUtruwYxugK1hIskCAiRkgAAYDzIwMjQxMDI4MDk0NTE3WqFAMD4wPAYFKyQIAw0EMzAxMA0GCWCGSAFlAwQCAQUABCCgLhMDx789ZyyhhqnQTlU+vsneAba3iJxV6S9+CFqnyTAKBggqhkjOPQQDAgNHADBEAiAtsSwE9c2zfNAMkOCWacESCbyg0u8k6soYOGFeiKBwPgIgHiA6YuEeY/TsHzpwidy0RTrMkEKzCFa26Lp5Qi6OSJagggLMMIICyDCCAsQwggJqoAMCAQICAiR5MAoGCCqGSM49BAMCMIGEMQswCQYDVQQGEwJERTEfMB0GA1UECgwWZ2VtYXRpayBHbWJIIE5PVC1WQUxJRDEyMDAGA1UECwwpS29tcG9uZW50ZW4tQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxIDAeBgNVBAMMF0dFTS5LT01QLUNBMjggVEVTVC1PTkxZMB4XDTI0MDExMTA5MTMzMVoXDTI2MDYxODA5NDk1OFowYDELMAkGA1UEBhMCREUxJjAkBgNVBAoMHWFydmF0byBTeXN0ZW1zIEdtYkggTk9ULVZBTElEMSkwJwYDVQQDDCBLb21wLUNBMjggT0NTUC1TaWduZXIzIFRFU1QtT05MWTBaMBQGByqGSM49AgEGCSskAwMCCAEBBwNCAASGrAw+ofrVoXyVqYdc1eljrC/eBl4Zt3NXpqvy5AnAWnkkp+y8PaHtGjUojhv6rUr0jqG0+5Av89pvxStC6cwVo4HtMIHqMB0GA1UdDgQWBBQgo+RdT/93cwD9tt9IDGFv2Ke8/DAfBgNVHSMEGDAWgBQAajiQ85muIY9S2u7BjG6ArWEiyTBNBggrBgEFBQcBAQRBMD8wPQYIKwYBBQUHMAGGMWh0dHA6Ly9kb3dubG9hZC10ZXN0cmVmLmNybC50aS1kaWVuc3RlLmRlL29jc3AvZWMwDgYDVR0PAQH/BAQDAgZAMBUGA1UdIAQOMAwwCgYIKoIUAEwEgSMwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDCTAPBgkrBgEFBQcwAQUEAgUAMAoGCCqGSM49BAMCA0gAMEUCIG8tSrDhLVvdqoIR3lT1um4SF6p+60n5WVVYq+nFTKKmAiEAjJo0edwJ3iXgrAOiUU+Ymyb/Bh7NIGXi4G7/jIfmg8M=
        """#.data(using: .utf8)!

        // producedAt: 20241029054517Z
        static let ocspResponseDataMoreRecentProducedAt = #"""
        MIIEVAoBAKCCBE0wggRJBgkrBgEFBQcwAQEEggQ6MIIENjCCAQ2hYjBgMQswCQYDVQQGEwJERTEmMCQGA1UECgwdYXJ2YXRvIFN5c3RlbXMgR21iSCBOT1QtVkFMSUQxKTAnBgNVBAMMIEtvbXAtQ0EyOCBPQ1NQLVNpZ25lcjMgVEVTVC1PTkxZGA8yMDI0MTAyOTA1NDUxN1owgZUwgZIwOzAJBgUrDgMCGgUABBT8X79XfV64wqxpB3xpQTrtT+Z95AQUAGo4kPOZriGPUtruwYxugK1hIskCAiRkgAAYDzIwMjQxMDI5MDU0NTE3WqFAMD4wPAYFKyQIAw0EMzAxMA0GCWCGSAFlAwQCAQUABCCgLhMDx789ZyyhhqnQTlU+vsneAba3iJxV6S9+CFqnyTAKBggqhkjOPQQDAgNHADBEAiBhaUEuzhZLi2fUHuehUf129d0SSNG033iNMh9nuWO5BwIgfl0QSP5V7jk3pYXgUGKAk+ATFY/HyXCvKDL2NYOa4MugggLMMIICyDCCAsQwggJqoAMCAQICAiR5MAoGCCqGSM49BAMCMIGEMQswCQYDVQQGEwJERTEfMB0GA1UECgwWZ2VtYXRpayBHbWJIIE5PVC1WQUxJRDEyMDAGA1UECwwpS29tcG9uZW50ZW4tQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxIDAeBgNVBAMMF0dFTS5LT01QLUNBMjggVEVTVC1PTkxZMB4XDTI0MDExMTA5MTMzMVoXDTI2MDYxODA5NDk1OFowYDELMAkGA1UEBhMCREUxJjAkBgNVBAoMHWFydmF0byBTeXN0ZW1zIEdtYkggTk9ULVZBTElEMSkwJwYDVQQDDCBLb21wLUNBMjggT0NTUC1TaWduZXIzIFRFU1QtT05MWTBaMBQGByqGSM49AgEGCSskAwMCCAEBBwNCAASGrAw+ofrVoXyVqYdc1eljrC/eBl4Zt3NXpqvy5AnAWnkkp+y8PaHtGjUojhv6rUr0jqG0+5Av89pvxStC6cwVo4HtMIHqMB0GA1UdDgQWBBQgo+RdT/93cwD9tt9IDGFv2Ke8/DAfBgNVHSMEGDAWgBQAajiQ85muIY9S2u7BjG6ArWEiyTBNBggrBgEFBQcBAQRBMD8wPQYIKwYBBQUHMAGGMWh0dHA6Ly9kb3dubG9hZC10ZXN0cmVmLmNybC50aS1kaWVuc3RlLmRlL29jc3AvZWMwDgYDVR0PAQH/BAQDAgZAMBUGA1UdIAQOMAwwCgYIKoIUAEwEgSMwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDCTAPBgkrBgEFBQcwAQUEAgUAMAoGCCqGSM49BAMCA0gAMEUCIG8tSrDhLVvdqoIR3lT1um4SF6p+60n5WVVYq+nFTKKmAiEAjJo0edwJ3iXgrAOiUU+Ymyb/Bh7NIGXi4G7/jIfmg8M=
        """#.data(using: .utf8)!

        static let pkiCertificatesJson = #"""
         {"ca_certs":["MIIEUTCCAzmgAwIBAgIBPDANBgkqhkiG9w0BAQsFADCBgTELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxNDAyBgNVBAsMK1plbnRyYWxlIFJvb3QtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxGzAZBgNVBAMMEkdFTS5SQ0EyIFRFU1QtT05MWTAeFw0yMDA4MDUxMjU1NDRaFw0yNjExMTQxMjU1NDNaMIGIMQswCQYDVQQGEwJERTEfMB0GA1UECgwWYWNoZWxvcyBHbWJIIE5PVC1WQUxJRDEyMDAGA1UECwwpS29tcG9uZW50ZW4tQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxJDAiBgNVBAMMG0FDSEVMT1MuS09NUC1DQTIwIFRFU1QtT05MWTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJRW9Gna++LE+Wa42K3qsEdFT3OQPO+ZHzPw5WdAtgrCc9InlNHS+HA4HkEto7GrO9gq7MBgMrCr+yTz5WDkAN\/fNXZ33JHzsw0sYqxNJHAoumPojayaPHZSHAlCBaPFDbTE1zM9DpGuAQiYmXGBVP1xHlvkmp2Qy8oA9+VOiIWKcUboG5K3qJXcOnvyQWpxUPiUE\/Nxzxn2fm9xe1uHUIXWGSgLyKwi13d7S7drmAKJVh7jMTPjJ10ZhbWDpohMe2GsY+lGcT\/yP4EhiDH8V7xD6zdOKhaOkTdlh0\/XEsVLD7rdgitHAD1voZjJOHegGx\/\/jJGU83y+oQa4QZJ8RNkCAwEAAaOByjCBxzAdBgNVHQ4EFgQUV2kXIEqUq4lyCUHUdNbacHrFEGswHwYDVR0jBBgwFoAULWkAu6H0zI4DoiWDksnSY+HZRLgwSgYIKwYBBQUHAQEEPjA8MDoGCCsGAQUFBzABhi5odHRwOi8vb2NzcC10ZXN0cmVmLnJvb3QtY2EudGktZGllbnN0ZS5kZS9vY3NwMBIGA1UdEwEB\/wQIMAYBAf8CAQAwDgYDVR0PAQH\/BAQDAgEGMBUGA1UdIAQOMAwwCgYIKoIUAEwEgSMwDQYJKoZIhvcNAQELBQADggEBAE5\/annMoGCqlBrNfVF3FbAqQjwtFJH4xCmypelDh2jSrJ7bzEikrXQBq9eQwsh0DCJlIP2Uk7z9MficOJ52uNfGKkE9ZMUvnzcLXhtdN0pm5QtIXFH+xiAu+jvleuAswFTie5onNFTY+dKn7+krTDyY080yQzVTYyTtzbQL9u\/7uf1fAg6PvHDxDagNH8cw\/SBZK4lRaXRjmXqR\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\/BAgwBgEB\/wIBADAKBggqhkjOPQQDAgNHADBEAiBxWVtueiCPZ1A5xFZutehkJg019HwbN8bA6VBm3zcCUQIgHVb2mgvU2Rlw2l2ZmLcoNqoqBpwRWpeM6u35ztGxNMM=","MIICxTCCAmygAwIBAgIBGTAKBggqhkjOPQQDAjCBgTELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxNDAyBgNVBAsMK1plbnRyYWxlIFJvb3QtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxGzAZBgNVBAMMEkdFTS5SQ0E0IFRFU1QtT05MWTAeFw0yMDA4MDUxMjU1NTlaFw0yODA4MDMxMjU1NThaMIGIMQswCQYDVQQGEwJERTEfMB0GA1UECgwWYWNoZWxvcyBHbWJIIE5PVC1WQUxJRDEyMDAGA1UECwwpS29tcG9uZW50ZW4tQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxJDAiBgNVBAMMG0FDSEVMT1MuS09NUC1DQTIxIFRFU1QtT05MWTBaMBQGByqGSM49AgEGCSskAwMCCAEBBwNCAAQbtf0eiyZ6fBUQy5W12V2oqj5HvbVPFHO18jATiTBQR0IaRFyyFXaULqd+GO28mCC7Z0jkQCdXbaw\/+Wo8nu7po4HKMIHHMB0GA1UdDgQWBBStYutS+oCXc7rH6Cyb4BkUhrSVgTAfBgNVHSMEGDAWgBRR29lmQrNKKz9XLFSNhXMd51fPfzBKBggrBgEFBQcBAQQ+MDwwOgYIKwYBBQUHMAGGLmh0dHA6Ly9vY3NwLXRlc3RyZWYucm9vdC1jYS50aS1kaWVuc3RlLmRlL29jc3AwEgYDVR0TAQH\/BAgwBgEB\/wIBADAOBgNVHQ8BAf8EBAMCAQYwFQYDVR0gBA4wDDAKBggqghQATASBIzAKBggqhkjOPQQDAgNHADBEAiB\/ukrRoHFv5pVNo8Ke5fx+eVGpmMJem3C\/2D\/LAN6zKwIgXm0mRo+BfvQMKHuZZbGnSJNlWHhdyFp+8I4LoPBNmDs=","MIIC8TCCApigAwIBAgIBCjAKBggqhkjOPQQDAjCBgTELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxNDAyBgNVBAsMK1plbnRyYWxlIFJvb3QtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxGzAZBgNVBAMMEkdFTS5SQ0E3IFRFU1QtT05MWTAeFw0yMzA3MTExMTI0MTJaFw0zMTA3MDkxMTI0MTFaMIGEMQswCQYDVQQGEwJERTEfMB0GA1UECgwWZ2VtYXRpayBHbWJIIE5PVC1WQUxJRDEyMDAGA1UECwwpS29tcG9uZW50ZW4tQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxIDAeBgNVBAMMF0dFTS5LT01QLUNBNTUgVEVTVC1PTkxZMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEsNwTdQTsntXYLp4Xy9TFDRNkVeNv2kA80uMpUMlAb9XSZCh2Gyz64UboKm7m4VagLyPoGuWzAFQ6qEfkT0E+CqOB+zCB+DAdBgNVHQ4EFgQUHmWV\/ABjHrP0TVqJEvoc0L8+fjAwHwYDVR0jBBgwFoAUsvAJPk0L4wgkgJY1bjo2MyvySxowSgYIKwYBBQUHAQEEPjA8MDoGCCsGAQUFBzABhi5odHRwOi8vb2NzcC10ZXN0cmVmLnJvb3QtY2EudGktZGllbnN0ZS5kZS9vY3NwMA4GA1UdDwEB\/wQEAwIBBjBGBgNVHSAEPzA9MDsGCCqCFABMBIEjMC8wLQYIKwYBBQUHAgEWIWh0dHA6Ly93d3cuZ2VtYXRpay5kZS9nby9wb2xpY2llczASBgNVHRMBAf8ECDAGAQH\/AgEAMAoGCCqGSM49BAMCA0cAMEQCIAcCpEG\/g4t2tKWtAXfU3fIlJ49LLbPh37RLq2Xf8\/IkAiAXrmaRDv5GPGH8QPdqP7D1+NXWu1yMJu956LoSkQDoZA==","MIIETTCCAzWgAwIBAgIBFzANBgkqhkiG9w0BAQsFADCBgTELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxNDAyBgNVBAsMK1plbnRyYWxlIFJvb3QtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxGzAZBgNVBAMMEkdFTS5SQ0EyIFRFU1QtT05MWTAeFw0xNzA3MzExNTIwNTJaFw0yNTA3MjkxNTIwNTFaMIGEMQswCQYDVQQGEwJERTEfMB0GA1UECgwWZ2VtYXRpayBHbWJIIE5PVC1WQUxJRDEyMDAGA1UECwwpS29tcG9uZW50ZW4tQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxIDAeBgNVBAMMF0dFTS5LT01QLUNBMjcgVEVTVC1PTkxZMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtX5gcTxty7nFCuPu\/XWlYo+dfj7WxErQ9Fd16\/ss9+N4TN0ym4VM+a52q0Lnpm1ouIyXdW6+JFLhic0uBhZKC7iNqJcZ+UnCzbT1BqXNUkskWHx0PEZXZESohR0Qqcq8q6P92aGFkp87DpS8tTlw7saViEP6tbVmYug2qooPYbAhH1IhY99qJEsNYMp\/VIxT85HNgarGZjD3bc4ojaLCua4xNhh206vGFreKtRFufWI315vqSrfM1rxMSA3rt8\/lOrUPDN7kQyWOxg3XkDIqotGpJKUhE4\/eocMU7gXxTGK5ASEthAp\/+YzEk2nrF4hPlVwr9CzcRuEBsGQv7\/ZtZQIDAQABo4HKMIHHMB0GA1UdDgQWBBR9bWRDxYnwBKdi2QBq62TMXu13dDAfBgNVHSMEGDAWgBQtaQC7ofTMjgOiJYOSydJj4dlEuDBKBggrBgEFBQcBAQQ+MDwwOgYIKwYBBQUHMAGGLmh0dHA6Ly9vY3NwLXRlc3RyZWYucm9vdC1jYS50aS1kaWVuc3RlLmRlL29jc3AwEgYDVR0TAQH\/BAgwBgEB\/wIBADAOBgNVHQ8BAf8EBAMCAQYwFQYDVR0gBA4wDDAKBggqghQATASBIzANBgkqhkiG9w0BAQsFAAOCAQEAfa8WKjRrfdoanNrtCBp\/qpv+UZrLqWLOyizBI4NzIirbo2bDybi2M2HxoTgjxgYJYWqNQOTzsT7fT6TsKUN3\/KzU6Tr4nPnhLIaBT5XfCy4Z\/H0SxKB9Wbe995e\/rz4m8WPxuW0OC6+t\/b8ubB5GW1PW8zPyhEiNPSJIQtpeBRSp1T6CsZWmaJWj24qyZy\/jYwJ1WBagHH2\/D4q2EKHMrO1TVlYsttna8mIiHYRV08+PCCDFsQ535k4rEir3HP4loEeTT1hWpFCUDUbMSEbJqe\/8gcAtCTqkgKCxyNF18vBnJ+avZvbJogNC3m\/SGwrEudXLBrjtse7blixB0SKTwg==","MIICuTCCAmCgAwIBAgIBIjAKBggqhkjOPQQDAjCBgTELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxNDAyBgNVBAsMK1plbnRyYWxlIFJvb3QtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxGzAZBgNVBAMMEkdFTS5SQ0EzIFRFU1QtT05MWTAeFw0xODA2MjAwOTQ5NTlaFw0yNjA2MTgwOTQ5NThaMIGEMQswCQYDVQQGEwJERTEfMB0GA1UECgwWZ2VtYXRpayBHbWJIIE5PVC1WQUxJRDEyMDAGA1UECwwpS29tcG9uZW50ZW4tQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxIDAeBgNVBAMMF0dFTS5LT01QLUNBMjggVEVTVC1PTkxZMFowFAYHKoZIzj0CAQYJKyQDAwIIAQEHA0IABFuRbiWZxMO8y+FvvQAPuAC+1NbkMRMTEyuFj9REDzkCYwFezS+WwbsCmsXgcDRnkDZ0lqFpQR0eS+T+\/6etrtijgcIwgb8wHQYDVR0OBBYEFABqOJDzma4hj1La7sGMboCtYSLJMB8GA1UdIwQYMBaAFAeQMy11U15\/+Mg3v37JJldo3zjSMEIGCCsGAQUFBwEBBDYwNDAyBggrBgEFBQcwAYYmaHR0cDovL29jc3Aucm9vdC1jYS50aS1kaWVuc3RlLmRlL29jc3AwEgYDVR0TAQH\/BAgwBgEB\/wIBADAOBgNVHQ8BAf8EBAMCAQYwFQYDVR0gBA4wDDAKBggqghQATASBIzAKBggqhkjOPQQDAgNHADBEAiBlbZRIayrzTk21ghnuni8u3trfhqwoNOHHRYpEMTTpLQIgdjiy1cKJSwLfRQ2RKI1NrI7ogEk\/PQvw7c3iGbFVGMY=","MIIEfjCCA2agAwIBAgIBDjANBgkqhkiG9w0BAQsFADCBgTELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxNDAyBgNVBAsMK1plbnRyYWxlIFJvb3QtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxGzAZBgNVBAMMEkdFTS5SQ0E2IFRFU1QtT05MWTAeFw0yMTExMDgxNDM0MTlaFw0yOTExMDYxNDM0MThaMIGEMQswCQYDVQQGEwJERTEfMB0GA1UECgwWZ2VtYXRpayBHbWJIIE5PVC1WQUxJRDEyMDAGA1UECwwpS29tcG9uZW50ZW4tQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxIDAeBgNVBAMMF0dFTS5LT01QLUNBNDEgVEVTVC1PTkxZMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAy6Q+sxYjCXgXbfnXJSzHwrkXxxRA3C+gYpydcoIH4ibVpY6d5zKkoKo8HF9qy+GkQ\/SdaqicOexCS7xTob1Onj8UH\/u0YV6n2BprjiwvCV7sITWBWoQ4Lz8sc79ZGeYCp5S6IObbKz17qwUXXh60xjNeUw400LZMC6jC+IY7WY8ZVHlw5bKZQxwKkc2hM3tZFjAAds+kqilcgEbCEy\/VQJnyCwsng3H3lNFb7zbuf2pEbiO1kjnHDZdkIaFMLpULf6vlU4jdsLixSpbTIwJ4hsNa8NgzrpjFCx+wQiVZoxeq6zRSKZtbrqAEAjqXDJdl3KcSokSyEFNOHg017rb07wIDAQABo4H7MIH4MB0GA1UdDgQWBBS7hCp7URCMz8JhyWG0l\/JLVGyS4TAfBgNVHSMEGDAWgBRM9+BlWFWY5jmLyAd1PUymcCzPKTBKBggrBgEFBQcBAQQ+MDwwOgYIKwYBBQUHMAGGLmh0dHA6Ly9vY3NwLXRlc3RyZWYucm9vdC1jYS50aS1kaWVuc3RlLmRlL29jc3AwDgYDVR0PAQH\/BAQDAgEGMEYGA1UdIAQ\/MD0wOwYIKoIUAEwEgSMwLzAtBggrBgEFBQcCARYhaHR0cDovL3d3dy5nZW1hdGlrLmRlL2dvL3BvbGljaWVzMBIGA1UdEwEB\/wQIMAYBAf8CAQAwDQYJKoZIhvcNAQELBQADggEBADM5JxlGtvpqLf\/0dPjpeqK0qRqFZ5G62HTC+xsc7TNUQE+17ImDxAkV0+OYUkljhNXEbhle9EXHSv\/KwyxTbiXbKznvqO44tmOX06OmqluKOB+2VSWjRYBiyEcu753MD3aMiX+OQ2pJbUf\/CaawM6talG0w0cor9KtrXagEKpVTmwxwactW8aqJDpp156aRQuiVsU1E9wfO8ENZv6PQ8X5tF5Pn\/YCcU1MaLTGmxE9xjmQVejoH+NhOoMzNRmM9s5KJCLXWVGbhCF04FlmL3U9N1MRBDd\/JV+8\/akr808lUBoA2b+MIhkpfrvbjjcHl61noyIiraSAgtyJt8sIJTsI=","MIIC8jCCApmgAwIBAgIBDDAKBggqhkjOPQQDAjCBgTELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxNDAyBgNVBAsMK1plbnRyYWxlIFJvb3QtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxGzAZBgNVBAMMEkdFTS5SQ0E4IFRFU1QtT05MWTAeFw0yNDA1MjExMTU3MTRaFw0zMjA1MTkxMTU3MTNaMIGEMQswCQYDVQQGEwJERTEfMB0GA1UECgwWZ2VtYXRpayBHbWJIIE5PVC1WQUxJRDEyMDAGA1UECwwpS29tcG9uZW50ZW4tQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxIDAeBgNVBAMMF0dFTS5LT01QLUNBNTYgVEVTVC1PTkxZMFowFAYHKoZIzj0CAQYJKyQDAwIIAQEHA0IABKLai2mGfuARDG+es6jKpkcVPzQ00rX98OKlPIWRq8GiBfsfZRM8b1lJ4yblA7Pqs+193EW5\/fYcjDson6UXYL2jgfswgfgwHQYDVR0OBBYEFNW4HHmJo6WtxY22\/lv+EDcDnQPDMB8GA1UdIwQYMBaAFKG5FDonMHtcZx71MsSx1RqJ\/LxTMEoGCCsGAQUFBwEBBD4wPDA6BggrBgEFBQcwAYYuaHR0cDovL29jc3AtdGVzdHJlZi5yb290LWNhLnRpLWRpZW5zdGUuZGUvb2NzcDAOBgNVHQ8BAf8EBAMCAQYwRgYDVR0gBD8wPTA7BggqghQATASBIzAvMC0GCCsGAQUFBwIBFiFodHRwOi8vd3d3LmdlbWF0aWsuZGUvZ28vcG9saWNpZXMwEgYDVR0TAQH\/BAgwBgEB\/wIBADAKBggqhkjOPQQDAgNHADBEAiBH0ciuge1LcDAtCgvDBeuNr7ZvdNQ8EKxEkTPxEx3r6wIgFt\/Em7E5a3RsA1Xa0zGlH6VcPKDoj0VqCWVcPXUIJhk=","MIIDUjCCAvigAwIBAgIBJTAKBggqhkjOPQQDAjCBgTELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxNDAyBgNVBAsMK1plbnRyYWxlIFJvb3QtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxGzAZBgNVBAMMEkdFTS5SQ0E0IFRFU1QtT05MWTAeFw0yMTA2MTAxMDQ1MjJaFw0yOTA2MDgxMDQ1MjFaMIGEMQswCQYDVQQGEwJERTEfMB0GA1UECgwWZ2VtYXRpayBHbWJIIE5PVC1WQUxJRDEyMDAGA1UECwwpS29tcG9uZW50ZW4tQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxIDAeBgNVBAMMF0dFTS5LT01QLUNBNTAgVEVTVC1PTkxZMFowFAYHKoZIzj0CAQYJKyQDAwIIAQEHA0IABGDIQ\/rR6jYzxjGyPmesnz5SbWNShsVyV4xDAkTYCqYrDCcsT8hYY7f\/i9SvsePMTT4FiISKsE1i6TgnZmxW3OejggFZMIIBVTAdBgNVHQ4EFgQUOuKqJZJOrKmUfc8ZaeoTBrmoMNMwHwYDVR0jBBgwFoAUUdvZZkKzSis\/VyxUjYVzHedXz38wSgYIKwYBBQUHAQEEPjA8MDoGCCsGAQUFBzABhi5odHRwOi8vb2NzcC10ZXN0cmVmLnJvb3QtY2EudGktZGllbnN0ZS5kZS9vY3NwMA4GA1UdDwEB\/wQEAwIBBjBGBgNVHSAEPzA9MDsGCCqCFABMBIEjMC8wLQYIKwYBBQUHAgEWIWh0dHA6Ly93d3cuZ2VtYXRpay5kZS9nby9wb2xpY2llczBbBgNVHREEVDBSoFAGA1UECqBJDEdnZW1hdGlrIEdlc2VsbHNjaGFmdCBmw7xyIFRlbGVtYXRpa2Fud2VuZHVuZ2VuIGRlciBHZXN1bmRoZWl0c2thcnRlIG1iSDASBgNVHRMBAf8ECDAGAQH\/AgEAMAoGCCqGSM49BAMCA0gAMEUCIFon6V178kFN5t6+CyZG+QxZ2uM4J31\/lVe7LZyG2edMAiEAgNKUdc2aq8Sl32sDt46OAid4UWRGDwnkdij5dR1s5xA=","MIIEfjCCA2agAwIBAgIBHjANBgkqhkiG9w0BAQsFADCBgTELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxNDAyBgNVBAsMK1plbnRyYWxlIFJvb3QtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxGzAZBgNVBAMMEkdFTS5SQ0E2IFRFU1QtT05MWTAeFw0yMTExMjMxMDI3MjRaFw0yOTExMjExMDI3MjNaMIGEMQswCQYDVQQGEwJERTEfMB0GA1UECgwWZ2VtYXRpayBHbWJIIE5PVC1WQUxJRDEyMDAGA1UECwwpS29tcG9uZW50ZW4tQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxIDAeBgNVBAMMF0dFTS5LT01QLUNBNTQgVEVTVC1PTkxZMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoulzTBJFr7iJOnoX2b8rExhMwwCY9Y13dZWcYiQexRq7hdKn+cdMcd2P0eKeB\/Y\/ppRgByaKgHAhhcLQwCd5i3NpTsRzfbYCwDr5cdGKCBopoPwgDoM46OyIHFHIX4XVh7+\/ijtjgVHJB7IesgoIHwMLOYwV26bEfzO34zrxmvwm+H7wnRLfr5CloTfvt0z47gzkPK3xty4AYHHsEGMaZ1Ei1xqkHmoTJROeWCNhc6sT+WXfq4w4\/OW7HtOByhmW7UFqNQmDFRoEzdR\/HxT0ds2MheouuRTdW5CX92eEOf5c\/kM8nLM4blwKP7KOCXzxxZfAYjKMEoAc5Fl7PNBY5QIDAQABo4H7MIH4MB0GA1UdDgQWBBSkGuFQXQyl4faNhGMB8GMz3X69gzAfBgNVHSMEGDAWgBRM9+BlWFWY5jmLyAd1PUymcCzPKTBKBggrBgEFBQcBAQQ+MDwwOgYIKwYBBQUHMAGGLmh0dHA6Ly9vY3NwLXRlc3RyZWYucm9vdC1jYS50aS1kaWVuc3RlLmRlL29jc3AwDgYDVR0PAQH\/BAQDAgEGMEYGA1UdIAQ\/MD0wOwYIKoIUAEwEgSMwLzAtBggrBgEFBQcCARYhaHR0cDovL3d3dy5nZW1hdGlrLmRlL2dvL3BvbGljaWVzMBIGA1UdEwEB\/wQIMAYBAf8CAQAwDQYJKoZIhvcNAQELBQADggEBAKqBcKKypm6gVJRUUe00am1W8VA\/Ddn8QxRBSMUB8+9gM8vsKw0owYamEUCzz8hLVl7B9AtG2qgbAlkZpiVGqLAJo8y1VP4jeTSjEaWEP+ykOw+Ud0TWfIFDa8VIB6A7LBRA9\/id6gk4gsJq0+f0dQ06+gKxLR7gmtR1oR9AT6Y2ClKIgbu4k7jIN1l3MqH5q7TUCfmeMD4r7OLbz9KQi6WYw4qqXKX2CAT6syf5HRRiiQwUGT1nv9Q2r82nyN\/zhyXtMnoBSrCBekHcj7i4T927qLiQHBf2oU8xKjHTVdEYWNS+6f2jpsBcrvit\/J20Mrg\/id7rbqWvlmRpVflvMMI=","MIIDGjCCAr+gAwIBAgIBFzAKBggqhkjOPQQDAjCBgTELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxNDAyBgNVBAsMK1plbnRyYWxlIFJvb3QtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxGzAZBgNVBAMMEkdFTS5SQ0EzIFRFU1QtT05MWTAeFw0xNzA4MzAxMTM2MjJaFw0yNTA4MjgxMTM2MjFaMIGEMQswCQYDVQQGEwJERTEfMB0GA1UECgwWZ2VtYXRpayBHbWJIIE5PVC1WQUxJRDEyMDAGA1UECwwpS29tcG9uZW50ZW4tQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxIDAeBgNVBAMMF0dFTS5LT01QLUNBMTAgVEVTVC1PTkxZMFowFAYHKoZIzj0CAQYJKyQDAwIIAQEHA0IABDFinQgzfsT1CN0QWwdm7e2JiaDYHocCiy1TWpOPyHwoPC54RULeUIBJeX199Qm1FFpgeIRP1E8cjbHGNsRbju6jggEgMIIBHDAdBgNVHQ4EFgQUKPD45qnId8xDRduartc6g6wOD6gwHwYDVR0jBBgwFoAUB5AzLXVTXn\/4yDe\/fskmV2jfONIwQgYIKwYBBQUHAQEENjA0MDIGCCsGAQUFBzABhiZodHRwOi8vb2NzcC5yb290LWNhLnRpLWRpZW5zdGUuZGUvb2NzcDASBgNVHRMBAf8ECDAGAQH\/AgEAMA4GA1UdDwEB\/wQEAwIBBjAVBgNVHSAEDjAMMAoGCCqCFABMBIEjMFsGA1UdEQRUMFKgUAYDVQQKoEkMR2dlbWF0aWsgR2VzZWxsc2NoYWZ0IGbDvHIgVGVsZW1hdGlrYW53ZW5kdW5nZW4gZGVyIEdlc3VuZGhlaXRza2FydGUgbWJIMAoGCCqGSM49BAMCA0kAMEYCIQCprLtIIRx1Y4mKHlNngOVAf6D7rkYSa723oRyX7J2qwgIhAKPi9GSJyYp4gMTFeZkqvj8pcAqxNR9UKV7UYBlHrdxC","MIIErDCCA5SgAwIBAgIBCTANBgkqhkiG9w0BAQsFADCBgTELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxNDAyBgNVBAsMK1plbnRyYWxlIFJvb3QtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxGzAZBgNVBAMMEkdFTS5SQ0EyIFRFU1QtT05MWTAeFw0xNjEyMTQxMDE3NTJaFw0yNDEyMTIxMDE3NTFaMIGEMQswCQYDVQQGEwJERTEfMB0GA1UECgwWZ2VtYXRpayBHbWJIIE5PVC1WQUxJRDEyMDAGA1UECwwpS29tcG9uZW50ZW4tQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxIDAeBgNVBAMMF0dFTS5LT01QLUNBMjQgVEVTVC1PTkxZMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7nGt2dCCcFbdhSr6m2oQw+VbbHNgNg6XSivv2xb4gJ658Nua7fJkNp1G9YpvK5l1dUxJPlXBAclgBpvq+dFv9eX4C0LheThmL8HdGnpa7zMO4gXp8GLEHBR5l01GtYYIEeOlb1QH5V\/ufQYam7nS54OShoDQyQDx6JQoL0Z0oS2VNPeV5HPQDN7gOfOkEWE8VS70W1cESf4xSVjgsPZvxpsE3O0A5MsyYFyA0nwBY+e7T\/KxUhR74B9HQGa7FX7k+pwQjdCgC+qMnTMbQL9bxVnUShzhI+YETS66DTrJKOP8Ew6eXdepjCuoMkz+375IjSOLwl58SGbeXiXr0nZ9TwIDAQABo4IBKDCCASQwHQYDVR0OBBYEFD+2guJpWXnMOdLVUSeO4KZZCjGvMB8GA1UdIwQYMBaAFC1pALuh9MyOA6Ilg5LJ0mPh2US4MEoGCCsGAQUFBwEBBD4wPDA6BggrBgEFBQcwAYYuaHR0cDovL29jc3AtdGVzdHJlZi5yb290LWNhLnRpLWRpZW5zdGUuZGUvb2NzcDASBgNVHRMBAf8ECDAGAQH\/AgEAMA4GA1UdDwEB\/wQEAwIBBjAVBgNVHSAEDjAMMAoGCCqCFABMBIEjMFsGA1UdEQRUMFKgUAYDVQQKoEkMR2dlbWF0aWsgR2VzZWxsc2NoYWZ0IGbDvHIgVGVsZW1hdGlrYW53ZW5kdW5nZW4gZGVyIEdlc3VuZGhlaXRza2FydGUgbWJIMA0GCSqGSIb3DQEBCwUAA4IBAQCdpyJCzBbIou6BlZ+O1RF\/AAM03vLM+5tjFkv9M0QrK8afWwhUby3wxevYdrSs2pA4Lx2gdrXMsmML\/tP5TTO5W\/YeBTktM3CDhUhTdE1raSkuBv3eGawW1wX4A24ejOjSwGZLjG3M5pYjEl0eUQMPSmY\/FY0P8uzaZ9N6n3ybBaKlGM0iyKe6jE9d0mpsmsl\/myPRIbnOuNgGHoS3jVtx2sK2GPMRsvRo4O3HQ3NTPyp9\/E\/ZbUGgnBmrqljFPkNqlH4YcTf1PJy4T\/Tz8EhxesfH8lVOJ8NY3ZaABpIyp5ninEfJ41R6S9TvS7JN2fos4\/5FyxW4fg+4YHDaLhBU"],"add_roots":["MIICtDCCAlqgAwIBAgIBKzAKBggqhkjOPQQDAjCBgTELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxNDAyBgNVBAsMK1plbnRyYWxlIFJvb3QtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxGzAZBgNVBAMMEkdFTS5SQ0EzIFRFU1QtT05MWTAeFw0xOTA4MDcxMDE3MjdaFw0yNzA4MDkwODM4NDVaMIGBMQswCQYDVQQGEwJERTEfMB0GA1UECgwWZ2VtYXRpayBHbWJIIE5PVC1WQUxJRDE0MDIGA1UECwwrWmVudHJhbGUgUm9vdC1DQSBkZXIgVGVsZW1hdGlraW5mcmFzdHJ1a3R1cjEbMBkGA1UEAwwSR0VNLlJDQTQgVEVTVC1PTkxZMFowFAYHKoZIzj0CAQYJKyQDAwIIAQEHA0IABD2om+MtwPSn89HGErbYvxjoWRwHoO\/JJXf51n8L\/NsdPjZUIVrveL\/ydaJJZNaEx4syq\/O5e8Q5WkEFB8kbm5Sjgb8wgbwwHQYDVR0OBBYEFFHb2WZCs0orP1csVI2Fcx3nV89\/MB8GA1UdIwQYMBaAFAeQMy11U15\/+Mg3v37JJldo3zjSMEIGCCsGAQUFBwEBBDYwNDAyBggrBgEFBQcwAYYmaHR0cDovL29jc3Aucm9vdC1jYS50aS1kaWVuc3RlLmRlL29jc3AwDwYDVR0TAQH\/BAUwAwEB\/zAOBgNVHQ8BAf8EBAMCAQYwFQYDVR0gBA4wDDAKBggqghQATASBIzAKBggqhkjOPQQDAgNIADBFAiEAi3HsZud766MjjCBamvjY0PJ9nSNhWEgO3dv+3CRZbvwCIF\/Ftch7+izD9L7Q\/BhqlxS9Pr5Zv6nBDjbUze6qzuNv","MIIC7DCCApOgAwIBAgIBKTAKBggqhkjOPQQDAjCBgTELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxNDAyBgNVBAsMK1plbnRyYWxlIFJvb3QtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxGzAZBgNVBAMMEkdFTS5SQ0E0IFRFU1QtT05MWTAeFw0yMTA3MjMxMTMyNDlaFw0yOTA4MDQxMDE0NDZaMIGBMQswCQYDVQQGEwJERTEfMB0GA1UECgwWZ2VtYXRpayBHbWJIIE5PVC1WQUxJRDE0MDIGA1UECwwrWmVudHJhbGUgUm9vdC1DQSBkZXIgVGVsZW1hdGlraW5mcmFzdHJ1a3R1cjEbMBkGA1UEAwwSR0VNLlJDQTUgVEVTVC1PTkxZMFowFAYHKoZIzj0CAQYJKyQDAwIIAQEHA0IABJukjjeYlo6B3WTeNVof861qQRIa3ZcAkUyj1zMER6I+aley7K\/U1XCFQ72ADk9qoRAYNspYA1dVQiFsXML32PWjgfgwgfUwHQYDVR0OBBYEFOGt4Af80iB5JPTcl70yZM1rFIUJMB8GA1UdIwQYMBaAFFHb2WZCs0orP1csVI2Fcx3nV89\/MEoGCCsGAQUFBwEBBD4wPDA6BggrBgEFBQcwAYYuaHR0cDovL29jc3AtdGVzdHJlZi5yb290LWNhLnRpLWRpZW5zdGUuZGUvb2NzcDAOBgNVHQ8BAf8EBAMCAQYwRgYDVR0gBD8wPTA7BggqghQATASBIzAvMC0GCCsGAQUFBwIBFiFodHRwOi8vd3d3LmdlbWF0aWsuZGUvZ28vcG9saWNpZXMwDwYDVR0TAQH\/BAUwAwEB\/zAKBggqhkjOPQQDAgNHADBEAiAryU2k1dZAABPmVWBJtxjNooi1421TIilqn1vqztaG6wIgajX6VL8Kek6S3L6B55WX5wxv9a20NtzbI4\/nSF4LlPE=","MIIDtjCCA12gAwIBAgIBDDAKBggqhkjOPQQDAjCBgTELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxNDAyBgNVBAsMK1plbnRyYWxlIFJvb3QtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxGzAZBgNVBAMMEkdFTS5SQ0E1IFRFU1QtT05MWTAeFw0yMTEwMjgwNzM0MjZaFw0zMTA3MjAwNzM0MjVaMIGBMQswCQYDVQQGEwJERTEfMB0GA1UECgwWZ2VtYXRpayBHbWJIIE5PVC1WQUxJRDE0MDIGA1UECwwrWmVudHJhbGUgUm9vdC1DQSBkZXIgVGVsZW1hdGlraW5mcmFzdHJ1a3R1cjEbMBkGA1UEAwwSR0VNLlJDQTYgVEVTVC1PTkxZMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvnQeiBEfnRD7wzhhF7Ah0LnVKdm7XkhQfrVbfIcJSmFyIWXYJhrui3oYErcVBDhcEiHqB8EptvyiPW4TH76LTq1ea6ulvr\/OzdwnMc8N9RiYjiPr4rLo\/8SBPo0crxfAUkLVmnokipGkv+AESuCfzFmNnd1D1pd\/NI3dF1++QWZ1CT4VlYEL73YQko4DRlyIVJl\/LPNZXwCmImlWCkNABVINRXyKhG2AAmOYKrJQ0DhC17HadToLwd1jKtfYqHjC28kdPeVA30hQY4C+Wb6XeAAFAnruY6lBkeav6i2Do64Plac+8nzYhhHwU4dHinYcpz\/FN3nhzu87eX5qyVY1XwIDAQABo4H4MIH1MB0GA1UdDgQWBBRM9+BlWFWY5jmLyAd1PUymcCzPKTAfBgNVHSMEGDAWgBThreAH\/NIgeST03Je9MmTNaxSFCTBKBggrBgEFBQcBAQQ+MDwwOgYIKwYBBQUHMAGGLmh0dHA6Ly9vY3NwLXRlc3RyZWYucm9vdC1jYS50aS1kaWVuc3RlLmRlL29jc3AwDgYDVR0PAQH\/BAQDAgEGMEYGA1UdIAQ\/MD0wOwYIKoIUAEwEgSMwLzAtBggrBgEFBQcCARYhaHR0cDovL3d3dy5nZW1hdGlrLmRlL2dvL3BvbGljaWVzMA8GA1UdEwEB\/wQFMAMBAf8wCgYIKoZIzj0EAwIDRwAwRAIgFL1kx8WwpvE6Z1Qgxp3hVuuFmtJboMFphPnqrSnI0bECICDH1I7wiv\/0M9F+OtOryHifOrGUXc13uj0vjULnPMMo","MIIDrTCCApWgAwIBAgIBKzANBgkqhkiG9w0BAQsFADCBgTELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxNDAyBgNVBAsMK1plbnRyYWxlIFJvb3QtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxGzAZBgNVBAMMEkdFTS5SQ0E2IFRFU1QtT05MWTAeFw0yMzA1MjUxMzAyMjJaFw0zMTEwMjYwNzI0MTRaMIGBMQswCQYDVQQGEwJERTEfMB0GA1UECgwWZ2VtYXRpayBHbWJIIE5PVC1WQUxJRDE0MDIGA1UECwwrWmVudHJhbGUgUm9vdC1DQSBkZXIgVGVsZW1hdGlraW5mcmFzdHJ1a3R1cjEbMBkGA1UEAwwSR0VNLlJDQTcgVEVTVC1PTkxZMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEGv3lzIASzKQHW0YbxoaSIFUlGcgH8c\/JEWOifqVVKkJUS81zG1ogcL6skAhGCtkksfdSJKiZnmnKeQ\/yAgGZUaOB+DCB9TAdBgNVHQ4EFgQUsvAJPk0L4wgkgJY1bjo2MyvySxowHwYDVR0jBBgwFoAUTPfgZVhVmOY5i8gHdT1MpnAszykwSgYIKwYBBQUHAQEEPjA8MDoGCCsGAQUFBzABhi5odHRwOi8vb2NzcC10ZXN0cmVmLnJvb3QtY2EudGktZGllbnN0ZS5kZS9vY3NwMA4GA1UdDwEB\/wQEAwIBBjBGBgNVHSAEPzA9MDsGCCqCFABMBIEjMC8wLQYIKwYBBQUHAgEWIWh0dHA6Ly93d3cuZ2VtYXRpay5kZS9nby9wb2xpY2llczAPBgNVHRMBAf8EBTADAQH\/MA0GCSqGSIb3DQEBCwUAA4IBAQCK4eAldg1bck+LdGU+ebCYtW\/ceqd9fSmmiOTZw1cldBsK+\/ouQh7d9KcaLmpdr1y3JFnAzzwZtaEbD0B41grVmKYTXVMYur+mt5ypX8fMg1FK95CRJa7gfULNPrInP5qpVJnTK1pJuh0Lf3zRJLCOpTNoXJoHjOZaa4xfS300chKkBQUtAqjOcxSex4JBUAoX1GVKDNNwFoR5\/gBQ0bNuRYMNzvhC5ZIV+AL0IKdyWIMmgs1cZgRvASuLcvNTcYhna4qzXgwfWRKzpgdW4aTUh6\/GuatTLWSqvHl55Uy5gVqPL6P9p7hks0O1Zx4cNgDOO2Wu2gOh0ENC+r1pPf6K","MIIC7jCCApOgAwIBAgIBDTAKBggqhkjOPQQDAjCBgTELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxNDAyBgNVBAsMK1plbnRyYWxlIFJvb3QtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxGzAZBgNVBAMMEkdFTS5SQ0E3IFRFU1QtT05MWTAeFw0yMzEyMDcxMDMzMDNaFw0zMzA1MjIxMDMzMDJaMIGBMQswCQYDVQQGEwJERTEfMB0GA1UECgwWZ2VtYXRpayBHbWJIIE5PVC1WQUxJRDE0MDIGA1UECwwrWmVudHJhbGUgUm9vdC1DQSBkZXIgVGVsZW1hdGlraW5mcmFzdHJ1a3R1cjEbMBkGA1UEAwwSR0VNLlJDQTggVEVTVC1PTkxZMFowFAYHKoZIzj0CAQYJKyQDAwIIAQEHA0IABDLncr51uoi5aGXoctM3aIm\/tjMRXGu+57M1TUjwsy2HhyjEBaMWqlGMBcmcGZhbcKt\/lepwcDk3EvGRmDJWGQ2jgfgwgfUwHQYDVR0OBBYEFKG5FDonMHtcZx71MsSx1RqJ\/LxTMB8GA1UdIwQYMBaAFLLwCT5NC+MIJICWNW46NjMr8ksaMEoGCCsGAQUFBwEBBD4wPDA6BggrBgEFBQcwAYYuaHR0cDovL29jc3AtdGVzdHJlZi5yb290LWNhLnRpLWRpZW5zdGUuZGUvb2NzcDAOBgNVHQ8BAf8EBAMCAQYwRgYDVR0gBD8wPTA7BggqghQATASBIzAvMC0GCCsGAQUFBwIBFiFodHRwOi8vd3d3LmdlbWF0aWsuZGUvZ28vcG9saWNpZXMwDwYDVR0TAQH\/BAUwAwEB\/zAKBggqhkjOPQQDAgNJADBGAiEAyAtlvkMU95ct0hExTlWneNaZbxHElhHvXMXkBG36ZGsCIQCZeHYcj0hW2nT9849pFU1fStnfZ0m6dd5vsqfk83dwEw==","MIIDfTCCAySgAwIBAgIBAjAKBggqhkjOPQQDAjCBgTELMAkGA1UEBhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxNDAyBgNVBAsMK1plbnRyYWxlIFJvb3QtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxGzAZBgNVBAMMEkdFTS5SQ0EzIFRFU1QtT05MWTAeFw0xNzA4MTEwODU5MTdaFw0yNTA4MDkwODU5MTZaMIGBMQswCQYDVQQGEwJERTEfMB0GA1UECgwWZ2VtYXRpayBHbWJIIE5PVC1WQUxJRDE0MDIGA1UECwwrWmVudHJhbGUgUm9vdC1DQSBkZXIgVGVsZW1hdGlraW5mcmFzdHJ1a3R1cjEbMBkGA1UEAwwSR0VNLlJDQTIgVEVTVC1PTkxZMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAymBHUufkzEqjXvCxEPCWUp80vuk8pyXVv\/IMngAu87GFjQW62xYtcQDWICaeLEoWIybEF\/JKm6vbSCnqIFYP5BsrOPXPY6B56Xb6PatxqS2AXbYxr0Jkl5K1HPWCK7jZlYep\/tfhw+Xo\/IoYMSkDb0CfNb5GCYJauIN8lOGLbHiMg6oMLfxvTniQA3g4cfdzsbo4f9kAkDZxqmoZLduhcXv31g\/JDdds1BIgiiu1iUbr2KOYRw2Ya0gvJ8ec2RMioC87uvyzbofuvSBK5T49pjSsgIne7OKPnBz1mfVD1g37IYVNFOgWyOFKKoZU7ryYdizWNcs\/tzVACd5VRqMPYwIDAQABo4G\/MIG8MB0GA1UdDgQWBBQtaQC7ofTMjgOiJYOSydJj4dlEuDAfBgNVHSMEGDAWgBQHkDMtdVNef\/jIN79+ySZXaN840jBCBggrBgEFBQcBAQQ2MDQwMgYIKwYBBQUHMAGGJmh0dHA6Ly9vY3NwLnJvb3QtY2EudGktZGllbnN0ZS5kZS9vY3NwMA8GA1UdEwEB\/wQFMAMBAf8wDgYDVR0PAQH\/BAQDAgEGMBUGA1UdIAQOMAwwCgYIKoIUAEwEgSMwCgYIKoZIzj0EAwIDRwAwRAIgVwwI9otCVf9IW1nccyU2asZNdCZ0AMd4uA3z6rLJTs0CIC0K3YUlD4rdSHWUK\/AnMW3MpaEDnanQkeJ06eCu+sim"]}
        """#
    }
    // swiftlint:enable line_length
}
