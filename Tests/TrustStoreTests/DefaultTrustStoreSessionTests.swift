//
//  Copyright (c) 2023 gematik GmbH
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

    // TODO: test data expired ERA-7662 swiftlint:disable:this todo
    func disabled_testLoadVauCertificateFromServer() throws {
        // given
        let serverURL = URL(string: "http://some-service.com/path")!
        let trustStoreClient = MockTrustStoreClient()
        trustStoreClient.loadCertListFromServerReturnValue = Just(certList)
            .setFailureType(to: TrustStoreError.self)
            .eraseToAnyPublisher()
        trustStoreClient.loadOCSPListFromServerReturnValue = Just(ocspList)
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
        expect(trustStoreClient.loadCertListFromServerCalled) == false
        expect(trustStoreClient.loadCertListFromServerCalled) == false

        sut.loadVauCertificate()
            .test(
                expectations: { _ in
                    expect(trustStoreClient.loadCertListFromServerCalled) == true
                    expect(trustStoreClient.loadCertListFromServerCallsCount) == 1
                    expect(storage.certListState) == self.certList

                    expect(trustStoreClient.loadOCSPListFromServerCalled) == true
                    expect(trustStoreClient.loadOCSPListFromServerCallsCount) == 1
                    expect(storage.ocspListState) == self.ocspList
                    success = true
                }
            )

        expect(success) == true; success = false

        // When saved in storage, the object will not be requested from the server again
        sut.loadVauCertificate()
            .test(expectations: { _ in
                expect(trustStoreClient.loadCertListFromServerCallsCount) == 1
                expect(trustStoreClient.loadOCSPListFromServerCallsCount) == 1
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
                expect(trustStoreClient.loadCertListFromServerCallsCount) == 1
                expect(trustStoreClient.loadOCSPListFromServerCallsCount) == 2

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
        let trustStoreClient = MockTrustStoreClient()
        trustStoreClient.loadCertListFromServerReturnValue = Just(certList)
            .setFailureType(to: TrustStoreError.self)
            .eraseToAnyPublisher()
        trustStoreClient.loadOCSPListFromServerReturnValue = Just(ocspList_NotVerifiableByTrustStore)
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
        expect(trustStoreClient.loadCertListFromServerCalled) == false
        expect(trustStoreClient.loadOCSPListFromServerCalled) == false

        sut.loadVauCertificate()
            .test(failure: { error in
                expect(trustStoreClient.loadCertListFromServerCalled) == true
                expect(trustStoreClient.loadCertListFromServerCallsCount) == 1
                expect(storage.certListState).to(beNil())

                expect(trustStoreClient.loadOCSPListFromServerCalled) == true
                expect(trustStoreClient.loadOCSPListFromServerCallsCount) == 1
                expect(storage.ocspListState) == self.ocspList_NotVerifiableByTrustStore

                expect(error) == .eeCertificateOCSPStatusVerification
            }) { _ in
                fail("Expected failing test")
            }
    }
}
