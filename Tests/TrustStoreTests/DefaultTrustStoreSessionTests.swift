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

import Combine
import DataKit
import Foundation
import Nimble
import TestUtils
@testable import TrustStore
import XCTest

// swiftlint:disable identifier_name
final class DefaultTrustStoreSessionTests: XCTestCase {
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()

    private lazy var certList: CertList = {
        guard let url = Bundle(for: Self.self)
                .url(
                    forResource: "kompca10-fd-enc-idp-sig1-idp-sig3",
                    withExtension: "json",
                    subdirectory: "CertList.bundle"
                ),
              let json = try? Data(contentsOf: url)
                else {
            fatalError("Could not load json")
        }
        return try! CertList.from(data: json)
    }()

    private lazy var ocspList: OCSPList = {
        guard let url = Bundle(for: Self.self).url(forResource: "oscp-responses-fd-enc-idp-sig1-idp-sig3",
                                                   withExtension: "json",
                                                   subdirectory: "OCSPList.bundle"),
              let json = try? Data(contentsOf: url)
                else {
            fatalError("Could not load json")
        }
        return try! OCSPList.from(data: json)
    }()

    private lazy var ocspList_NotVerifiableByTrustStore: OCSPList = {
        guard let url = Bundle(for: Self.self).url(forResource: "oscp-responses-fd-enc-idp-sig",
                                                   withExtension: "json",
                                                   subdirectory: "OCSPList.bundle"),
              let json = try? Data(contentsOf: url)
                else {
            fatalError("Could not load json")
        }
        return try! OCSPList.from(data: json)
    }()

    func testLoadVauCertificateFromServer() throws {
        // given
        let serverURL = URL(string: "http://some-service.com/path")!
        let trustStoreClient = TrustStoreClientMock()
        trustStoreClient.certList = certList
        trustStoreClient.ocspList = ocspList
        let storage = MemStorage()
        storage.set(certList: nil)
        storage.set(ocspList: nil)
        var currentDate = dateFormatter.date(from: "2021-05-08 11:08:00.0000+0000")!

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

        // then
        expect(trustStoreClient.loadCertListFromServer_Called) == false
        expect(trustStoreClient.loadOCSPListFromServer_Called) == false

        sut.loadVauCertificate()
                .test(expectations: { _ in
                    expect(trustStoreClient.loadCertListFromServer_Called) == true
                    expect(trustStoreClient.loadCertListFromServer_CallsCount) == 1
                    expect(storage.certListState) == self.certList

                    expect(trustStoreClient.loadOCSPListFromServer_Called) == true
                    expect(trustStoreClient.loadOCSPListFromServer_CallsCount) == 1
                    expect(storage.ocspListState) == self.ocspList
                })

        // When saved in storage, the object will not be requested from the server again
        sut.loadVauCertificate()
                .test(expectations: { _ in
                    expect(trustStoreClient.loadCertListFromServer_CallsCount) == 1
                    expect(trustStoreClient.loadOCSPListFromServer_CallsCount) == 1
                })

        // Advance the time so that saved mocked OCSP responses will be invalidated
        // The same mocked OCSP responses will be received by the client cannot be validated,
        //  so expect a session failure.
        // [REQ:gemSpec_Krypt:A_21218] If only OCSP responses >12h available, we must request new ones
        currentDate = currentDate.advanced(by: TimeInterval(expirationInterval))
        sut.loadVauCertificate()
                .test(failure: { error in
                    expect(trustStoreClient.loadCertListFromServer_CallsCount) == 1
                    expect(trustStoreClient.loadOCSPListFromServer_CallsCount) == 2

                    expect(error) == TrustStoreError.invalidOCSPResponse
                }) { _ in
                    fail("Expected failing test")
                }
    }

    func testLoadVauCertificateFromServer_failWhenOCSPResponsesCannotBeVerified() throws {
        // given
        let serverURL = URL(string: "http://some-service.com/path")!
        let trustStoreClient = TrustStoreClientMock()
        trustStoreClient.certList = certList
        trustStoreClient.ocspList = ocspList_NotVerifiableByTrustStore
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
        expect(trustStoreClient.loadCertListFromServer_Called) == false
        expect(trustStoreClient.loadOCSPListFromServer_Called) == false

        sut.loadVauCertificate()
                .test(failure: { error in
                    expect(trustStoreClient.loadCertListFromServer_Called) == true
                    expect(trustStoreClient.loadCertListFromServer_CallsCount) == 1
                    expect(storage.certListState).to(beNil())

                    expect(trustStoreClient.loadOCSPListFromServer_Called) == true
                    expect(trustStoreClient.loadOCSPListFromServer_CallsCount) == 1
                    expect(storage.ocspListState) == self.ocspList_NotVerifiableByTrustStore

                    expect(error) == .eeCertificateOCSPStatusVerification
                }) { _ in
                    fail("Expected failing test")
                }
    }
}
