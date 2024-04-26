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
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import eRpLocalStorage
import Nimble
import OpenSSL
import Pharmacy
import XCTest

class RedeemOptionProviderTests: XCTestCase {
    func testWithMixedServiceAndWithoutLogin() {
        let sut = RedeemOptionProvider(
            wasAuthenticatedBefore: false,
            pharmacy: mixedServicesPharmacy
        )

        expect(sut.reservationService) == .noService
        expect(sut.shipmentService) == .avs
        expect(sut.deliveryService) == .noService
    }

    func testWithMixedServiceAndWithLogin() {
        let sut = RedeemOptionProvider(
            wasAuthenticatedBefore: true,
            pharmacy: mixedServicesPharmacy
        )

        expect(sut.reservationService) == .noService
        expect(sut.shipmentService) == .erxTaskRepository
        expect(sut.deliveryService) == .noService
    }

    func testWithoutAVSServiceAndWithoutLogin() {
        let sut = RedeemOptionProvider(
            wasAuthenticatedBefore: false,
            pharmacy: tiServicesPharmacy
        )

        expect(sut.reservationService) == .erxTaskRepositoryAvailable
        expect(sut.shipmentService) == .erxTaskRepositoryAvailable
        expect(sut.deliveryService) == .erxTaskRepositoryAvailable
    }

    func testWithoutAVSServiceAndWithLogin() {
        let sut = RedeemOptionProvider(
            wasAuthenticatedBefore: true,
            pharmacy: tiServicesPharmacy
        )

        expect(sut.reservationService) == .erxTaskRepository
        expect(sut.shipmentService) == .erxTaskRepository
        expect(sut.deliveryService) == .erxTaskRepository
    }

    func testOneAVSServiceWithoutLogin() {
        let sut = RedeemOptionProvider(
            wasAuthenticatedBefore: false,
            pharmacy: oneAVSServicePharmacy
        )

        expect(sut.reservationService) == .noService
        expect(sut.shipmentService) == .noService
        expect(sut.deliveryService) == .avs
    }

    func testOneAVSServiceWithLogin() {
        let sut = RedeemOptionProvider(
            wasAuthenticatedBefore: true,
            pharmacy: oneAVSServicePharmacy
        )

        expect(sut.reservationService) == .noService
        expect(sut.shipmentService) == .noService
        expect(sut.deliveryService) == .erxTaskRepository
    }

    func testApolloApothekeFuerthWithLogin() {
        let sut = RedeemOptionProvider(
            wasAuthenticatedBefore: true,
            pharmacy: apolloApothekeFuerth
        )

        expect(sut.reservationService) == .erxTaskRepository
        expect(sut.shipmentService) == .noService
        expect(sut.deliveryService) == .noService
    }

    lazy var allServicesPharmacy: PharmacyLocation = {
        PharmacyLocation(
            id: "id",
            telematikID: "telematikID",
            types: [.delivery, .mobl, .outpharm],
            avsEndpoints: .init(
                onPremiseUrl: "some",
                shipmentUrl: "some",
                deliveryUrl: "some"
            ),
            avsCertificates: [avsCert]
        )
    }()

    lazy var oneAVSServicePharmacy: PharmacyLocation = {
        PharmacyLocation(
            id: "id",
            telematikID: "telematikID",
            types: [.mobl, .outpharm],
            avsEndpoints: .init(
                deliveryUrl: "some"
            ),
            avsCertificates: [avsCert]
        )
    }()

    lazy var mixedServicesPharmacy: PharmacyLocation = {
        PharmacyLocation(
            id: "id",
            telematikID: "telematikID",
            types: [.delivery, .mobl, .outpharm],
            avsEndpoints: .init(
                shipmentUrl: "some"
            ),
            avsCertificates: [avsCert]
        )
    }()

    lazy var tiServicesPharmacy: PharmacyLocation = {
        PharmacyLocation(
            id: "id",
            telematikID: "telematikID",
            types: [.delivery, .mobl, .outpharm],
            avsCertificates: []
        )
    }()

    lazy var apolloApothekeFuerth: PharmacyLocation = {
        PharmacyLocation(
            id: "id",
            telematikID: "telematikID",
            types: [.delivery, .mobl, .outpharm],
            avsEndpoints: .init(
                onPremiseUrl: "https://some-pharmacy.de"
            ),
            avsCertificates: [avsCert]
        )
    }()

    lazy var noServicePharmacy: PharmacyLocation = {
        PharmacyLocation(id: "id", telematikID: "telematikID", types: [])
    }()

    lazy var derCert = {
        Data(
            base64Encoded: "MIIE4TCCA8mgAwIBAgIDD0vlMA0GCSqGSIb3DQEBCwUAMIGuMQswCQYDVQQGEwJERTEzMDEGA1UECgwqQXRvcyBJbmZvcm1hdGlvbiBUZWNobm9sb2d5IEdtYkggTk9ULVZBTElEMUgwRgYDVQQLDD9JbnN0aXR1dGlvbiBkZXMgR2VzdW5kaGVpdHN3ZXNlbnMtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxIDAeBgNVBAMMF0FUT1MuU01DQi1DQTMgVEVTVC1PTkxZMB4XDTE5MDkxNzEyMzYxNloXDTI0MDkxNzEyMzYxNlowXDELMAkGA1UEBhMCREUxIDAeBgNVBAoMFzEtMjExMjM0NTY3ODkgTk9ULVZBTElEMSswKQYDVQQDDCJBcnp0cHJheGlzIERyLiBBxJ9hb8SfbHUgVEVTVC1PTkxZMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmdmUeBLB6UDh4u8FAvi7B3hpAhJYXBlx+IJXLiSrhgCu/T/L5vVlCQb+1gYybWhHT5YlxafTJpOcXSfcixJbFWGxn+iQLqo+LCp/ljLBz5JoU+IXIxRKZCi5SZ9APeglGs4R0/xpPBtsJzihFXVu+B8qGm2oqmvVV91u+MoJ5asC6C+rVOecLxqy/OdmeKfaNSgH2NxVzNc19VmFUkFDGUFJjG4ZgatW4V6AuAhiPnDkEg8gfXr5L7ycQRZUNlEGMmDhh+noHU/doxSU2cgBaiTZNmu17FJLXlBLRISpWcQitcjOkjrJDt4Z0Yta64yZe13+a5dANh32Zeeg5jDQRQIDAQABo4IBVzCCAVMwHQYDVR0OBBYEFF/uDhGziRKzsUC9Nkat5xQojOUZMA4GA1UdDwEB/wQEAwIEMDAMBgNVHRMBAf8EAjAAMCAGA1UdIAQZMBcwCQYHKoIUAEwETDAKBggqghQATASBIzBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLXNtY2IuZWdrLXRlc3QtdHNwLmRlL0FUT1MuU01DQi1DQTNfVEVTVC1PTkxZLmNybDA8BggrBgEFBQcBAQQwMC4wLAYIKwYBBQUHMAGGIGh0dHA6Ly9vY3NwLXNtY2IuZWdrLXRlc3QtdHNwLmRlMB8GA1UdIwQYMBaAFD+eHl4mKtYMlaF4nqrz1drzQaf8MEUGBSskCAMDBDwwOjA4MDYwNDAyMBYMFEJldHJpZWJzc3TDpHR0ZSBBcnp0MAkGByqCFABMBDITDTEtMjExMjM0NTY3ODkwDQYJKoZIhvcNAQELBQADggEBACUnL3MxjyoEyUBRxcBAjl7FdePW0O1/UCeDAbH2b4ob9GjMGjL5OoBmhj9GsUORg/K4cIiqTot2TcPtdooKCI5a5Jupp0nYoAuzdrNlvGYEm0S/cvlyYJXjfhrEIHmlDY0/hpJX3S/hYgkniJ1Wg70MfLLcib05+31OijZmEzpChioIm4KmumEKU4ODsLWr/4OEw9KCYfuNpjiSyyAEd2pMgnGU8MKCJhrR/ZKSteAxAPKTXVtNTKndbptvcsaEZPp//vNdbBh+k8P642P2DHYfeDoUgivEYXdE5ABixtG9sk1Q2DPfTXoS+CKv45ae0vejBnRjuA28lmkmuIp+f+s=" // swiftlint:disable:this line_length
        )!
    }()

    lazy var avsCert = try! X509(der: derCert)
}
