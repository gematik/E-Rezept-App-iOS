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

import AVS
import Combine
import DataKit
@testable import eRpApp
import Foundation
import IdentifiedCollections
import Nimble
import OpenSSL
import Pharmacy
import TestUtils
import XCTest

final class AVSRedeemServiceTests: XCTestCase {
    let mockAVSService = MockAVSSession()

    // swiftlint:disable line_length
    var derBase64Cert: String {
        """
        MIIE4TCCA8mgAwIBAgIDD0vlMA0GCSqGSIb3DQEBCwUAMIGuMQswCQYDVQQGEwJERTEzMDEGA1UECgwqQXRvcyBJbmZvcm1hdGlvbiBUZWNobm9sb2d5IEdtYkggTk9ULVZBTElEMUgwRgYDVQQLDD9JbnN0aXR1dGlvbiBkZXMgR2VzdW5kaGVpdHN3ZXNlbnMtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxIDAeBgNVBAMMF0FUT1MuU01DQi1DQTMgVEVTVC1PTkxZMB4XDTE5MDkxNzEyMzYxNloXDTI0MDkxNzEyMzYxNlowXDELMAkGA1UEBhMCREUxIDAeBgNVBAoMFzEtMjExMjM0NTY3ODkgTk9ULVZBTElEMSswKQYDVQQDDCJBcnp0cHJheGlzIERyLiBBxJ9hb8SfbHUgVEVTVC1PTkxZMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmdmUeBLB6UDh4u8FAvi7B3hpAhJYXBlx+IJXLiSrhgCu/T/L5vVlCQb+1gYybWhHT5YlxafTJpOcXSfcixJbFWGxn+iQLqo+LCp/ljLBz5JoU+IXIxRKZCi5SZ9APeglGs4R0/xpPBtsJzihFXVu+B8qGm2oqmvVV91u+MoJ5asC6C+rVOecLxqy/OdmeKfaNSgH2NxVzNc19VmFUkFDGUFJjG4ZgatW4V6AuAhiPnDkEg8gfXr5L7ycQRZUNlEGMmDhh+noHU/doxSU2cgBaiTZNmu17FJLXlBLRISpWcQitcjOkjrJDt4Z0Yta64yZe13+a5dANh32Zeeg5jDQRQIDAQABo4IBVzCCAVMwHQYDVR0OBBYEFF/uDhGziRKzsUC9Nkat5xQojOUZMA4GA1UdDwEB/wQEAwIEMDAMBgNVHRMBAf8EAjAAMCAGA1UdIAQZMBcwCQYHKoIUAEwETDAKBggqghQATASBIzBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLXNtY2IuZWdrLXRlc3QtdHNwLmRlL0FUT1MuU01DQi1DQTNfVEVTVC1PTkxZLmNybDA8BggrBgEFBQcBAQQwMC4wLAYIKwYBBQUHMAGGIGh0dHA6Ly9vY3NwLXNtY2IuZWdrLXRlc3QtdHNwLmRlMB8GA1UdIwQYMBaAFD+eHl4mKtYMlaF4nqrz1drzQaf8MEUGBSskCAMDBDwwOjA4MDYwNDAyMBYMFEJldHJpZWJzc3TDpHR0ZSBBcnp0MAkGByqCFABMBDITDTEtMjExMjM0NTY3ODkwDQYJKoZIhvcNAQELBQADggEBACUnL3MxjyoEyUBRxcBAjl7FdePW0O1/UCeDAbH2b4ob9GjMGjL5OoBmhj9GsUORg/K4cIiqTot2TcPtdooKCI5a5Jupp0nYoAuzdrNlvGYEm0S/cvlyYJXjfhrEIHmlDY0/hpJX3S/hYgkniJ1Wg70MfLLcib05+31OijZmEzpChioIm4KmumEKU4ODsLWr/4OEw9KCYfuNpjiSyyAEd2pMgnGU8MKCJhrR/ZKSteAxAPKTXVtNTKndbptvcsaEZPp//vNdbBh+k8P642P2DHYfeDoUgivEYXdE5ABixtG9sk1Q2DPfTXoS+CKv45ae0vejBnRjuA28lmkmuIp+f+s=
        """
    }

    // swiftlint:enable line_length

    func testRedeemViaAVSResponses_Success() throws {
        let sut = AVSRedeemService(avsSession: mockAVSService)

        let endpoint = URL(string: "http://some-service.com:8003/")!
        let X509Cert = try cert(from: derBase64Cert)
        let certificates = [X509Cert]

        mockAVSService.redeemMessageEndpointRecipientClosure = { message in
            Just(message)
                .setFailureType(to: AVSError.self)
                .eraseToAnyPublisher()
        }

        let order1 = Order(
            redeemType: .onPremise,
            taskID: "task_id_1",
            accessCode: "access_code_1",
            endpoint: endpoint,
            recipients: certificates
        )
        let order2 = Order(
            redeemType: .onPremise,
            taskID: "task_id_2",
            accessCode: "access_code_2",
            endpoint: endpoint,
            recipients: certificates
        )
        let order3 = Order(
            redeemType: .onPremise,
            taskID: "task_id_3",
            accessCode: "access_code_3",
            endpoint: endpoint,
            recipients: certificates
        )

        var receivedResponses: [IdentifiedArrayOf<OrderResponse>] = []
        sut.redeem([order1, order2, order3])
            .test(failure: { error in
                print(error)
                fail("no error expected")
            }, expectations: { orderResponses in
                receivedResponses.append(orderResponses)
            })

        expect(receivedResponses.count).toEventually(equal(3))
        let firstResponse = receivedResponses[0]

        expect(firstResponse.count) == 3
        expect(firstResponse.inProgress).to(beTrue())
        expect(firstResponse.areFailing).to(beFalse())
        expect(firstResponse.areSuccessful).to(beFalse())
        expect(firstResponse.arePartiallySuccessful).to(beFalse())
        expect(firstResponse.progress).to(equal(Double(1) / Double(3)))
        expect(firstResponse[0].isSuccess).to(beTrue())
        expect(firstResponse[0].requested).to(equal(order1))
        expect(firstResponse[1].inProgress).to(beTrue())
        expect(firstResponse[1].requested).to(equal(order2))
        expect(firstResponse[2].inProgress).to(beTrue())
        expect(firstResponse[2].requested).to(equal(order3))

        let secondResponse = receivedResponses[1]
        expect(secondResponse.count) == 3
        expect(secondResponse.inProgress).to(beTrue())
        expect(secondResponse.areFailing).to(beFalse())
        expect(secondResponse.areSuccessful).to(beFalse())
        expect(secondResponse.arePartiallySuccessful).to(beFalse())
        expect(secondResponse.progress).to(equal(Double(2) / Double(3)))
        expect(secondResponse[0].isSuccess).to(beTrue())
        expect(secondResponse[0].requested).to(equal(order1))
        expect(secondResponse[1].isSuccess).to(beTrue())
        expect(secondResponse[1].requested).to(equal(order2))
        expect(secondResponse[2].inProgress).to(beTrue())
        expect(secondResponse[2].requested).to(equal(order3))

        let thirdResponse = receivedResponses[2]
        expect(thirdResponse.inProgress).to(beFalse())
        expect(thirdResponse.areFailing).to(beFalse())
        expect(thirdResponse.areSuccessful).to(beTrue())
        expect(thirdResponse.arePartiallySuccessful).to(beFalse())
        expect(thirdResponse.progress).to(equal(1.0))
        expect(thirdResponse.count) == 3
        expect(thirdResponse[0].isSuccess).to(beTrue())
        expect(thirdResponse[0].requested).to(equal(order1))
        expect(thirdResponse[1].isSuccess).to(beTrue())
        expect(thirdResponse[1].requested).to(equal(order2))
        expect(thirdResponse[2].isSuccess).to(beTrue())
        expect(thirdResponse[2].requested).to(equal(order3))
    }

    func testRedeemViaAVSResponses_PartialSuccess() throws {
        let sut = AVSRedeemService(avsSession: mockAVSService)

        let endpoint = URL(string: "http://some-service.com:8003/")!
        let X509Cert = try cert(from: derBase64Cert)
        let certificates = [X509Cert]

        var callsCount = 0
        mockAVSService.redeemMessageEndpointRecipientClosure = { message in
            callsCount += 1
            if callsCount == 1 {
                return Fail(error: AVSError.internal(error: AVSError.InternalError.cmsContentCreation))
                    .eraseToAnyPublisher()
            } else {
                return Just(message)
                    .setFailureType(to: AVSError.self)
                    .eraseToAnyPublisher()
            }
        }

        let order1 = Order(
            redeemType: .onPremise,
            taskID: "task_id_1",
            accessCode: "access_code_1",
            endpoint: endpoint,
            recipients: certificates
        )
        let order2 = Order(
            redeemType: .onPremise,
            taskID: "task_id_2",
            accessCode: "access_code_2",
            endpoint: endpoint,
            recipients: certificates
        )
        let order3 = Order(
            redeemType: .onPremise,
            taskID: "task_id_3",
            accessCode: "access_code_3",
            endpoint: endpoint,
            recipients: certificates
        )

        var receivedResponses: [IdentifiedArrayOf<OrderResponse>] = []
        sut.redeem([order1, order2, order3])
            .test(failure: { error in
                print(error)
                fail("no error expected")
            }, expectations: { orderResponses in
                receivedResponses.append(orderResponses)
            })

        expect(receivedResponses.count).toEventually(equal(3))
        let firstResponse = receivedResponses[0]

        expect(firstResponse.count) == 3
        expect(firstResponse.inProgress).to(beTrue())
        expect(firstResponse.areFailing).to(beFalse())
        expect(firstResponse.areSuccessful).to(beFalse())
        expect(firstResponse.arePartiallySuccessful).to(beFalse())
        expect(firstResponse.progress).to(equal(Double(1) / Double(3)))
        expect(firstResponse[0].isFailure).to(beTrue())
        expect(firstResponse[0].requested).to(equal(order1))
        expect(firstResponse[1].inProgress).to(beTrue())
        expect(firstResponse[1].requested).to(equal(order2))
        expect(firstResponse[2].inProgress).to(beTrue())
        expect(firstResponse[2].requested).to(equal(order3))

        let secondResponse = receivedResponses[1]
        expect(secondResponse.count) == 3
        expect(secondResponse.inProgress).to(beTrue())
        expect(secondResponse.areFailing).to(beFalse())
        expect(secondResponse.areSuccessful).to(beFalse())
        expect(secondResponse.arePartiallySuccessful).to(beFalse())
        expect(secondResponse.progress).to(equal(Double(2) / Double(3)))
        expect(secondResponse[0].isFailure).to(beTrue())
        expect(secondResponse[0].requested).to(equal(order1))
        expect(secondResponse[1].isSuccess).to(beTrue())
        expect(secondResponse[1].requested).to(equal(order2))
        expect(secondResponse[2].inProgress).to(beTrue())
        expect(secondResponse[2].requested).to(equal(order3))

        let thirdResponse = receivedResponses[2]
        expect(thirdResponse.inProgress).to(beFalse())
        expect(thirdResponse.areFailing).to(beFalse())
        expect(thirdResponse.areSuccessful).to(beFalse())
        expect(thirdResponse.arePartiallySuccessful).to(beTrue())
        expect(thirdResponse.progress).to(equal(1.0))
        expect(thirdResponse.count) == 3
        expect(thirdResponse[0].isFailure).to(beTrue())
        expect(thirdResponse[0].requested).to(equal(order1))
        expect(thirdResponse[1].isSuccess).to(beTrue())
        expect(thirdResponse[1].requested).to(equal(order2))
        expect(thirdResponse[2].isSuccess).to(beTrue())
        expect(thirdResponse[2].requested).to(equal(order3))
    }

    func testRedeemViaAVSResponses_All_Fail() throws {
        let sut = AVSRedeemService(avsSession: mockAVSService)

        let endpoint = URL(string: "http://some-service.com:8003/")!
        let X509Cert = try cert(from: derBase64Cert)
        let certificates = [X509Cert]

        mockAVSService.redeemMessageEndpointRecipientClosure = { _ in
            Fail(error: AVSError.internal(error: AVSError.InternalError.cmsContentCreation))
                .eraseToAnyPublisher()
        }

        let order1 = Order(
            redeemType: .onPremise,
            taskID: "task_id_1",
            accessCode: "access_code_1",
            endpoint: endpoint,
            recipients: certificates
        )
        let order2 = Order(
            redeemType: .onPremise,
            taskID: "task_id_2",
            accessCode: "access_code_2",
            endpoint: endpoint,
            recipients: certificates
        )
        let order3 = Order(
            redeemType: .onPremise,
            taskID: "task_id_3",
            accessCode: "access_code_3",
            endpoint: endpoint,
            recipients: certificates
        )

        var receivedResponses: [IdentifiedArrayOf<OrderResponse>] = []
        sut.redeem([order1, order2, order3])
            .test(failure: { error in
                print(error)
                fail("no error expected")
            }, expectations: { orderResponses in
                receivedResponses.append(orderResponses)
            })

        expect(receivedResponses.count).toEventually(equal(3))
        let firstResponse = receivedResponses[0]

        expect(firstResponse.count) == 3
        expect(firstResponse.inProgress).to(beTrue())
        expect(firstResponse.areFailing).to(beFalse())
        expect(firstResponse.areSuccessful).to(beFalse())
        expect(firstResponse.arePartiallySuccessful).to(beFalse())
        expect(firstResponse.progress).to(equal(Double(1) / Double(3)))
        expect(firstResponse[0].isFailure).to(beTrue())
        expect(firstResponse[0].requested).to(equal(order1))
        expect(firstResponse[1].inProgress).to(beTrue())
        expect(firstResponse[1].requested).to(equal(order2))
        expect(firstResponse[2].inProgress).to(beTrue())
        expect(firstResponse[2].requested).to(equal(order3))

        let secondResponse = receivedResponses[1]
        expect(secondResponse.count) == 3
        expect(secondResponse.inProgress).to(beTrue())
        expect(secondResponse.areFailing).to(beFalse())
        expect(secondResponse.areSuccessful).to(beFalse())
        expect(secondResponse.arePartiallySuccessful).to(beFalse())
        expect(secondResponse.progress).to(equal(Double(2) / Double(3)))
        expect(secondResponse[0].isFailure).to(beTrue())
        expect(secondResponse[0].requested).to(equal(order1))
        expect(secondResponse[1].isFailure).to(beTrue())
        expect(secondResponse[1].requested).to(equal(order2))
        expect(secondResponse[2].inProgress).to(beTrue())
        expect(secondResponse[2].requested).to(equal(order3))

        let thirdResponse = receivedResponses[2]
        expect(thirdResponse.inProgress).to(beFalse())
        expect(thirdResponse.areFailing).to(beTrue())
        expect(thirdResponse.areSuccessful).to(beFalse())
        expect(thirdResponse.arePartiallySuccessful).to(beFalse())
        expect(thirdResponse.progress).to(equal(1.0))
        expect(thirdResponse.count) == 3
        expect(thirdResponse[0].isFailure).to(beTrue())
        expect(thirdResponse[0].requested).to(equal(order1))
        expect(thirdResponse[1].isFailure).to(beTrue())
        expect(thirdResponse[1].requested).to(equal(order2))
        expect(thirdResponse[2].isFailure).to(beTrue())
        expect(thirdResponse[2].requested).to(equal(order3))
    }

    func testRedeemViaAVSResponses_SetupFailure() throws {
        let sut = AVSRedeemService(avsSession: mockAVSService)

        let endpoint = URL(string: "http://some-service.com:8003/")!
        let X509Cert = try cert(from: derBase64Cert)
        let certificates = [X509Cert]

        mockAVSService.redeemMessageEndpointRecipientClosure = { message in
            Just(message)
                .setFailureType(to: AVSError.self)
                .eraseToAnyPublisher()
        }

        let order1 = Order(redeemType: .shipment, taskID: "task_id_1", accessCode: "access_code_1")
        let order2 = Order(redeemType: .shipment, taskID: "task_id_2", accessCode: "access_code_2")
        let order3 = Order(
            redeemType: .shipment,
            taskID: "task_id_3",
            accessCode: "access_code_3",
            endpoint: endpoint,
            recipients: certificates
        )

        sut.redeem([order1, order2, order3])
            .test(failure: { error in
                expect(error).to(equal(RedeemServiceError.internalError(.missingAVSEndpoint)))
            }, expectations: { _ in
                fail("no order response expected")
            })
    }

    private func cert(from derBase64: String) throws -> X509 {
        let derBytes = try Base64.decode(string: derBase64)
        return try X509(der: derBytes)
    }
}
