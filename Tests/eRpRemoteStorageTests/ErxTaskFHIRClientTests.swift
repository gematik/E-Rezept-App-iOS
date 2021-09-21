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

import BundleKit
import Combine
import eRpKit
@testable import eRpRemoteStorage
import FHIRClient
import Foundation
import HTTPClient
import Nimble
import OHHTTPStubs
import OHHTTPStubsSwift
import TestUtils
import XCTest

final class ErxTaskFHIRClientTests: XCTestCase {
    var host: String!
    var service: URL!
    var fhirClient: FHIRClient!
    var sut: FHIRClient!

    override func setUpWithError() throws {
        try super.setUpWithError()

        host = "some-fhir-service.com"
        service = URL(string: "http://\(host ?? "")")!
        fhirClient = FHIRClient(server: service, httpClient: DefaultHTTPClient(urlSessionConfiguration: .default))
        sut = FHIRClient(server: service, httpClient: DefaultHTTPClient(urlSessionConfiguration: .default))
    }

    func testFHIRClientTaskByIdJson() {
        let expectedResponse = load(resource: "getTaskResponse_61704e3f-1e4f-11b2-80f4-b806a73c0cd0")

        var counter = 0
        stub(condition: isPath("/Task/61704e3f-1e4f-11b2-80f4-b806a73c0cd0") && isMethodGET() &&
            hasHeaderNamed("X-AccessCode", value: "access-now") &&
            hasHeaderNamed("Accept", value: "application/fhir+json")) { _ in
                counter += 1
                return fixture(filePath: expectedResponse, headers: ["Content-Type": "application/fhir+json"])
        }

        sut.fetchTask(by: "61704e3f-1e4f-11b2-80f4-b806a73c0cd0", accessCode: "access-now")
            .test(expectations: { erxTaskBundle in
                expect(counter) == 1

                expect(erxTaskBundle?.id) == "61704e3f-1e4f-11b2-80f4-b806a73c0cd0"
                expect(erxTaskBundle?.accessCode) == "7eccd529292631f6a7cd120b57ded23062c35932cc721bfd32b08c5fb188b642"
                expect(erxTaskBundle?.fullUrl).to(beNil())
                expect(erxTaskBundle?.medication?.name) == "Sumatriptan-1a Pharma 100 mg Tabletten"
                expect(erxTaskBundle?.authoredOn) == "2020-02-03T00:00:00+00:00"
                expect(erxTaskBundle?.lastModified) == "2021-03-24T08:35:32.311376627+00:00"
                expect(erxTaskBundle?.expiresOn) == "2021-06-24"
                expect(erxTaskBundle?.author) == "Hausarztpraxis Dr. Topp-Glücklich"
                expect(erxTaskBundle?.medication?.dosageForm) == "TAB"
                expect(erxTaskBundle?.medication?.amount) == 12
            })
    }

    func testFHIRClientAllTaskIdsJson() {
        let expectedResponse = load(resource: "getTaskIdsWithTwoTasksResponse")

        var counter = 0
        stub(condition: isPath("/Task")) { _ in
            counter += 1
            return fixture(filePath: expectedResponse, headers: ["Content-Type": "application/json"])
        }

        sut.fetchAllTaskIDs(after: nil)
            .test { error in
                fail("unexpected fail with error: \(error)")
            } expectations: { taskIDs in
                expect(taskIDs.count) == 2
                expect(taskIDs[0]) == "61704e3f-1e4f-11b2-80f4-b806a73c0cd0"
                expect(taskIDs[1]) == "5e00e907-1e4f-11b2-80be-b806a73c0cd0"
            }
        expect(counter) == 1
    }

    func testFetchingTasksWithLastModifiedDate() {
        let expectedResponse = load(resource: "getTaskIdsWithTwoTasksResponse")

        let lastModified = "2021-03-24T08:35:26.548+00:00"
        let dateString = FHIRDateFormatter.shared.date(from: lastModified)!.fhirFormattedString(with: .yearMonthDayTime)

        var counter = 0
        stub(condition: isPath("/Task")
            && containsQueryParams(["modified": "ge\(dateString)"])
            && isMethodGET()) { _ in
                counter += 1
                return fixture(filePath: expectedResponse, headers: ["Content-Type": "application/json"])
        }

        sut.fetchAllTaskIDs(after: lastModified)
            .test { error in
                fail("unexpected fail with error: \(error)")
            } expectations: { taskIDs in
                expect(taskIDs.count) == 2
            }
        expect(counter) == 1
    }

    func testFHIRClientAllAuditEvents() {
        let expectedResponse = load(resource: "getAuditEventResponse_4_entries")

        var counter = 0
        stub(condition: isPath("/AuditEvent")) { _ in
            counter += 1
            return fixture(filePath: expectedResponse, headers: ["Content-Type": "application/json"])
        }

        sut.fetchAllAuditEvents()
            .test { error in
                fail("unexpected fail with error: \(error)")
            } expectations: { auditEvents in
                expect(auditEvents.count) == 4
                expect(auditEvents[0].identifier) == "64c4f143-1de0-11b2-80eb-443cac489883"
                expect(auditEvents[1].identifier) == "64c4f1af-1de0-11b2-80ec-443cac489883"
                expect(auditEvents[2].identifier) == "64c4f1cc-1de0-11b2-80ed-443cac489883"
                expect(auditEvents[3].identifier) == "64c4f1ea-1de0-11b2-80ee-443cac489883"
            }
        expect(counter) == 1
    }

    func testFetchingAuditEventsWithDate() {
        let expectedResponse = load(resource: "getAuditEventResponse_4_entries")

        let timestamp = "2021-03-24T08:35:26.548+00:00"
        let dateString = FHIRDateFormatter.shared.date(from: timestamp)!
            .fhirFormattedString(with: .yearMonthDayTime)

        var counter = 0
        stub(condition: isPath("/AuditEvent")
            && containsQueryParams(["date": "ge\(dateString)"])
            && isMethodGET()) { _ in
                counter += 1
                return fixture(filePath: expectedResponse, headers: ["Content-Type": "application/json"])
        }

        sut.fetchAllAuditEvents(after: timestamp)
            .test { error in
                fail("unexpected fail with error: \(error)")
            } expectations: { auditEvents in
                expect(auditEvents.count) == 4
            }
        expect(counter) == 1
    }

    /// Tests a failure delete, e.g. when task has already been deleted on the server.
    /// The server will then respond with a http status code of 404.
    func testDeleteTasks404() {
        let errorResponse = load(resource: "errorFHIRResponse")

        stub(condition: isHost(host) && pathEndsWith("$abort")) { _ in
            fixture(filePath: errorResponse, status: 404, headers: ["Accept": "application/fhir+json"])
        }

        let erxTask = ErxTask(identifier: "1", accessCode: "12")

        sut.deleteTask(by: erxTask.id, accessCode: erxTask.accessCode)
            .test(expectations: { success in
                expect(success) == true
            })
    }

    func testRedeemOrderWithSuccess() {
        let redeemOrderResponse = load(resource: "redeemOrderResponse")

        var counter = 0
        stub(condition: isPath("/Communication")
            && isMethodPOST()
            && hasBody(expectedRequestBody)) { _ in
                counter += 1
                return fixture(filePath: redeemOrderResponse, headers: ["Content-Type": "application/json"])
        }

        sut.redeem(order: inputOrder)
            .test { error in
                fail("unexpected fail with error: \(error)")
            } expectations: { isSuccessful in
                expect(counter) == 1
                expect(isSuccessful).to(beTrue())
            }
    }

    func testRedeemOrderWithNetworkError() {
        let expectedError = URLError(.notConnectedToInternet)

        var counter = 0
        stub(condition: isPath("/Communication")
            && isMethodPOST()
            && hasBody(expectedRequestBody)) { _ in
                counter += 1
                return HTTPStubsResponse(error: expectedError)
        }

        sut.redeem(order: inputOrder)
            .test { error in
                expect(counter) == 1
                expect(error) == .httpError(.httpError(expectedError))
            } expectations: { _ in
                fail("this test should rase an error instead")
            }
    }

    func testCommunicationResourceWithSuccess() {
        let expectedResponse = load(resource: "erxCommunicationReplyResponse")

        var counter = 0
        stub(condition: isPath("/Communication")
            && isMethodGET()) { _ in
                counter += 1
                return fixture(filePath: expectedResponse, headers: ["Content-Type": "application/json"])
        }

        sut.communicationResources(after: nil)
            .test { error in
                fail("unexpected fail with error: \(error)")
            } expectations: { communications in
                expect(counter) == 1
                expect(communications.count) == 4
                expect(communications.last?.identifier) == "86aa9d40-1dd2-11b2-80e5-dd3ddb83b539"
            }
    }

    func testCommunicationResourceWithTimestamp() {
        let expectedResponse = load(resource: "erxCommunicationReplyResponse")

        let timestamp = "2021-03-24T08:35:26.54834+00:00"
        let dateString = FHIRDateFormatter.shared.date(from: timestamp)!.fhirFormattedString(with: .yearMonthDayTime)

        var counter = 0
        stub(condition: isPath("/Communication")
            && containsQueryParams(["sent": "ge\(dateString)"])
            && isMethodGET()) { _ in
                counter += 1
                return fixture(filePath: expectedResponse, headers: ["Content-Type": "application/json"])
        }

        sut.communicationResources(after: timestamp)
            .test { error in
                fail("unexpected fail with error: \(error)")
            } expectations: { communications in
                expect(counter) == 1
                expect(communications.count) == 4
            }
    }

    func testCommunicationResourceWithError() {
        let expectedError = URLError(.notConnectedToInternet)

        var counter = 0
        stub(condition: isPath("/Communication")
            && isMethodGET()) { _ in
                counter += 1
                return HTTPStubsResponse(error: expectedError)
        }

        sut.communicationResources(after: nil)
            .test { error in
                expect(counter) == 1
                expect(error) == .httpError(.httpError(expectedError))
            } expectations: { _ in
                fail("this test should rase an error instead")
            }
    }

    func testFetchAllMedicationDispensesWithSuccess() {
        let expectedResponse = load(resource: "medicationDispenseBundle")

        var counter = 0
        stub(condition: isPath("/MedicationDispense")
            && isMethodGET()) { _ in
                counter += 1
                return fixture(filePath: expectedResponse, headers: ["Content-Type": "application/json"])
        }

        sut.fetchAllMedicationDispenses(after: nil)
            .test { error in
                fail("unexpected fail with error: \(error)")
            } expectations: { medicationDispenses in
                expect(counter) == 1
                expect(medicationDispenses.count) == 2
                expect(medicationDispenses.last?.taskId) == "160.000.000.014.285.76"
            }
    }

    func testFetchAllMedicationDispensesWithReferenceDate() {
        let expectedResponse = load(resource: "medicationDispenseBundle")

        let timestamp = "2021-07-23T10:55:04+02:00"
        let dateString = FHIRDateFormatter.shared.date(from: timestamp)!.fhirFormattedString(with: .yearMonthDayTime)

        var counter = 0
        stub(condition: isPath("/MedicationDispense")
            && containsQueryParams(["whenHandedOver": "ge\(dateString)"])
            && isMethodGET()) { _ in
                counter += 1
                return fixture(filePath: expectedResponse, headers: ["Content-Type": "application/json"])
        }

        sut.fetchAllMedicationDispenses(after: timestamp)
            .test { error in
                fail("unexpected fail with error: \(error)")
            } expectations: { medicationDispenses in
                expect(counter) == 1
                expect(medicationDispenses.count) == 2
            }
    }

    func testFetchAllMedicationDispensesWithError() {
        let expectedError = URLError(.notConnectedToInternet)

        var counter = 0
        stub(condition: isPath("/MedicationDispense")
            && isMethodGET()) { _ in
                counter += 1
                return HTTPStubsResponse(error: expectedError)
        }

        sut.fetchAllMedicationDispenses(after: nil)
            .test { error in
                expect(counter) == 1
                expect(error) == .httpError(.httpError(expectedError))
            } expectations: { _ in
                fail("this test should rase an error instead")
            }
    }

    private var inputOrder: ErxTaskOrder = {
        let payload = ErxTaskOrder.Payload(supplyOptionsType: .shipment,
                                           name: "Graf Dracula",
                                           address: ["Schloss Bran",
                                                     "Strada General Traian Moșoiu 24",
                                                     "Bran 507025",
                                                     "Rumänien"],
                                           hint: "Nur bei Tageslicht liefern!",
                                           phone: "666 999 666")
        return ErxTaskOrder(erxTaskId: "39c67d5b-1df3-11b2-80b4-783a425d8e87",
                            accessCode: "777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea",
                            pharmacyTelematikId: "606358757",
                            payload: payload)
    }()

    // swiftlint:disable line_length
    private var expectedRequestBody: Data = {
        String(
            "{\"status\":\"unknown\",\"payload\":[{\"contentString\":\"{\\\"address\\\":[\\\"Schloss Bran\\\",\\\"Strada General Traian Moșoiu 24\\\",\\\"Bran 507025\\\",\\\"Rumänien\\\"],\\\"phone\\\":\\\"666 999 666\\\",\\\"supplyOptionsType\\\":\\\"shipment\\\",\\\"hint\\\":\\\"Nur bei Tageslicht liefern!\\\",\\\"name\\\":\\\"Graf Dracula\\\",\\\"version\\\":\\\"1\\\"}\"}],\"recipient\":[{\"identifier\":{\"system\":\"https:\\/\\/gematik.de\\/fhir\\/NamingSystem\\/TelematikID\",\"value\":\"606358757\"}}],\"meta\":{\"profile\":[\"https:\\/\\/gematik.de\\/fhir\\/StructureDefinition\\/ErxCommunicationDispReq\"]},\"resourceType\":\"Communication\",\"basedOn\":[{\"reference\":\"Task\\/39c67d5b-1df3-11b2-80b4-783a425d8e87\\/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea\"}]}"
        ).data(using: .utf8)!
    }()

    // swiftlint:enable line_length

    private func load(resource name: String) -> String {
        guard let resource = Bundle(for: Self.self).path(
            forResource: name,
            ofType: "json",
            inDirectory: "FHIRExampleData.bundle"
        ) else {
            fail("Bundle could not find resource \(name)")
            return ""
        }

        return resource
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }
}
