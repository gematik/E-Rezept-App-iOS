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

import AVS
@testable import eRpFeatures
import eRpKit
import Foundation
import OpenSSL

extension OrderRequest {
    enum Fixtures {
        static let order1 = OrderRequest(
            redeemType: .onPremise,
            flowType: "160",
            taskID: "task_id_1",
            accessCode: "access_code_1",
            endpoint: endpoint,
            recipients: certificates
        )

        static let order2 = OrderRequest(
            redeemType: .onPremise,
            flowType: "160",
            taskID: "task_id_2",
            accessCode: "access_code_2",
            endpoint: endpoint,
            recipients: certificates
        )

        static let order3 = OrderRequest(
            redeemType: .onPremise,
            flowType: "160",
            taskID: "task_id_3",
            accessCode: "access_code_3",
            endpoint: endpoint,
            recipients: certificates
        )

        static func orders(with id: UUID) -> [OrderRequest] {
            [
                OrderRequest(
                    orderID: id,
                    redeemType: .onPremise,
                    flowType: "160",
                    taskID: "task_id_1",
                    accessCode: "access_code_1",
                    endpoint: endpoint,
                    recipients: certificates
                ),
                OrderRequest(
                    orderID: id,
                    redeemType: .onPremise,
                    flowType: "160",
                    taskID: "task_id_2",
                    accessCode: "access_code_2",
                    endpoint: endpoint,
                    recipients: certificates
                ),
                OrderRequest(
                    orderID: id,
                    redeemType: .onPremise,
                    flowType: "160",
                    taskID: "task_id_3",
                    accessCode: "access_code_3",
                    endpoint: endpoint,
                    recipients: certificates
                ),
            ]
        }

        static let orderNoEndpoint = OrderRequest(
            redeemType: .onPremise,
            flowType: "160",
            taskID: "task_id_1",
            accessCode: "access_code_1"
        )

        static let endpoint = PharmacyLocation.AVSEndpoints.Endpoint(url: URL(string: "http://some-service.com:8003/")!)
        static let certificates = [x509]

        static let x509: X509 = {
            let derBytes = Data(base64Encoded: derBase64Cert)!
            return try! X509(der: derBytes)
        }()

        // swiftlint:disable line_length
        private static let derBase64Cert: String =
            """
            MIIE4TCCA8mgAwIBAgIDD0vlMA0GCSqGSIb3DQEBCwUAMIGuMQswCQYDVQQGEwJERTEzMDEGA1UECgwqQXRvcyBJbmZvcm1hdGlvbiBUZWNobm9sb2d5IEdtYkggTk9ULVZBTElEMUgwRgYDVQQLDD9JbnN0aXR1dGlvbiBkZXMgR2VzdW5kaGVpdHN3ZXNlbnMtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxIDAeBgNVBAMMF0FUT1MuU01DQi1DQTMgVEVTVC1PTkxZMB4XDTE5MDkxNzEyMzYxNloXDTI0MDkxNzEyMzYxNlowXDELMAkGA1UEBhMCREUxIDAeBgNVBAoMFzEtMjExMjM0NTY3ODkgTk9ULVZBTElEMSswKQYDVQQDDCJBcnp0cHJheGlzIERyLiBBxJ9hb8SfbHUgVEVTVC1PTkxZMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmdmUeBLB6UDh4u8FAvi7B3hpAhJYXBlx+IJXLiSrhgCu/T/L5vVlCQb+1gYybWhHT5YlxafTJpOcXSfcixJbFWGxn+iQLqo+LCp/ljLBz5JoU+IXIxRKZCi5SZ9APeglGs4R0/xpPBtsJzihFXVu+B8qGm2oqmvVV91u+MoJ5asC6C+rVOecLxqy/OdmeKfaNSgH2NxVzNc19VmFUkFDGUFJjG4ZgatW4V6AuAhiPnDkEg8gfXr5L7ycQRZUNlEGMmDhh+noHU/doxSU2cgBaiTZNmu17FJLXlBLRISpWcQitcjOkjrJDt4Z0Yta64yZe13+a5dANh32Zeeg5jDQRQIDAQABo4IBVzCCAVMwHQYDVR0OBBYEFF/uDhGziRKzsUC9Nkat5xQojOUZMA4GA1UdDwEB/wQEAwIEMDAMBgNVHRMBAf8EAjAAMCAGA1UdIAQZMBcwCQYHKoIUAEwETDAKBggqghQATASBIzBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLXNtY2IuZWdrLXRlc3QtdHNwLmRlL0FUT1MuU01DQi1DQTNfVEVTVC1PTkxZLmNybDA8BggrBgEFBQcBAQQwMC4wLAYIKwYBBQUHMAGGIGh0dHA6Ly9vY3NwLXNtY2IuZWdrLXRlc3QtdHNwLmRlMB8GA1UdIwQYMBaAFD+eHl4mKtYMlaF4nqrz1drzQaf8MEUGBSskCAMDBDwwOjA4MDYwNDAyMBYMFEJldHJpZWJzc3TDpHR0ZSBBcnp0MAkGByqCFABMBDITDTEtMjExMjM0NTY3ODkwDQYJKoZIhvcNAQELBQADggEBACUnL3MxjyoEyUBRxcBAjl7FdePW0O1/UCeDAbH2b4ob9GjMGjL5OoBmhj9GsUORg/K4cIiqTot2TcPtdooKCI5a5Jupp0nYoAuzdrNlvGYEm0S/cvlyYJXjfhrEIHmlDY0/hpJX3S/hYgkniJ1Wg70MfLLcib05+31OijZmEzpChioIm4KmumEKU4ODsLWr/4OEw9KCYfuNpjiSyyAEd2pMgnGU8MKCJhrR/ZKSteAxAPKTXVtNTKndbptvcsaEZPp//vNdbBh+k8P642P2DHYfeDoUgivEYXdE5ABixtG9sk1Q2DPfTXoS+CKv45ae0vejBnRjuA28lmkmuIp+f+s=
            """
        // swiftlint:enable line_length
    }
}
