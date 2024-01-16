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

import Foundation
import Nimble
@testable import TrustStore
import XCTest

final class OCSPListTests: XCTestCase {
    func testDecodeValidListJson() throws {
        // given
        guard let url = Bundle(for: Self.self).url(forResource: "oscp-responses-fd-enc-idp-sig",
                                                   withExtension: "json",
                                                   subdirectory: "OCSPList.bundle"),
            let data = try? Data(contentsOf: url)
        else {
            fatalError("Could not load json")
        }

        // when
        let ocspList = try OCSPList.from(data: data)
        let ocspListBase64 = try OCSPList.Base64.from(data: data)

        // then
        expect(ocspList.responses.count) == 2
        expect(ocspListBase64.responses.count) == 2
        expect(ocspListBase64.responses.first) ==
            "MIIEggoBAKCCBHswggR3BgkrBgEFBQcwAQEEggRoMIIEZDCCAWihVzBVMQswCQYDVQQGEwJERTEaMBgGA1UECgwRZ2VtYXRpayBOT1QtVkFMSUQxKjAoBgNVBAMMIWVoY2EgT0NTUCBTaWduZXIgNTEgZWNjIFRFU1QtT05MWRgPMjAyMzA2MDkxMzM1NDRaMIG2MIGzMEAwCQYFKw4DAhoFAAQUXI3/vEvbfD7eUzpI1js5mj5OUC4EFCjw+OapyHfMQ0Xbmq7XOoOsDg+oAgcBPCti7yC3gAAYDzIwMjMwNjA5MTMzNTQ0WqFcMFowGgYFKyQIAwwEERgPMjAyMDEwMDcwNjI4NDJaMDwGBSskCAMNBDMwMTANBglghkgBZQMEAgEFAAQgincq5kR9WEXBnsjx8YY/V0XAELeEhrVEDYE1ebae/5OhQzBBMB4GCSsGAQUFBzABBgQRGA8xODcwMDEwNzAwMDAwMFowHwYJKwYBBQUHMAECBBIEEJY+ZPGccvM4XXt/7e3NFYEwCgYIKoZIzj0EAwIDRwAwRAIgWFiPlsS4fU22mLklsI2nPQhYBXevnJRHmsYcj+goldECIEaelpqNZhjtlLWKRRX+8uY4ZamBlsYJcdMLEQ7uwjDSoIICnzCCApswggKXMIICPqADAgECAgcBHrSiPtbTMAoGCCqGSM49BAMCMIGEMQswCQYDVQQGEwJERTEfMB0GA1UECgwWZ2VtYXRpayBHbWJIIE5PVC1WQUxJRDEyMDAGA1UECwwpS29tcG9uZW50ZW4tQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxIDAeBgNVBAMMF0dFTS5LT01QLUNBNTEgVEVTVC1PTkxZMB4XDTIzMDYwOTAwMDAwMFoXDTI4MDYwOTIzNTk1OVowVTELMAkGA1UEBhMCREUxGjAYBgNVBAoMEWdlbWF0aWsgTk9ULVZBTElEMSowKAYDVQQDDCFlaGNhIE9DU1AgU2lnbmVyIDUxIGVjYyBURVNULU9OTFkwWjAUBgcqhkjOPQIBBgkrJAMDAggBAQcDQgAEZA/FqZU1dvguzr0ffUeFUGaCqT28tieqkzl6DoNavCYFHXV5Pw/GEJPZc5AyWW7xKr3QoQVZ27WF0NnG91ZNmKOBxzCBxDAOBgNVHQ8BAf8EBAMCBkAwFQYDVR0gBA4wDDAKBggqghQATASBIzATBgNVHSUEDDAKBggrBgEFBQcDCTA4BggrBgEFBQcBAQQsMCowKAYIKwYBBQUHMAGGHGh0dHA6Ly9laGNhLmdlbWF0aWsuZGUvb2NzcC8wHwYDVR0jBBgwFoAUYpW77kbZKi/y6cjMbJck1FWVMXcwHQYDVR0OBBYEFDvzrvgjZHB8gSvexfaRgZyyaLMtMAwGA1UdEwEB/wQCMAAwCgYIKoZIzj0EAwIDRwAwRAIgSroV0m3/RJZnfBtpAykWFHprklSpb84854hWX3fvkbcCIGhuVx00UsksozPUdg/u62ekQ6P/5e5xyA7tRSvK0hMD"
        // swiftlint:disable:previous line_length
    }
}
