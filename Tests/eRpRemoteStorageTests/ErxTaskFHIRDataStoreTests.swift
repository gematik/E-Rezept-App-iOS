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

import eRpKit
@testable import eRpRemoteStorage
import FHIRClient
import Foundation
import HTTPClient
import ModelsR4
import Nimble
import OHHTTPStubs
import OHHTTPStubsSwift
import XCTest

final class ErxTaskFHIRDataStoreTests: XCTestCase {
    var host: String!
    var url: URL!
    var fhirClient: FHIRClient!
    var sut: ErxTaskFHIRDataStore!

    override func setUpWithError() throws {
        try super.setUpWithError()
        host = "some-fhir-service.com"
        url = URL(string: "http://\(host ?? "")")!
        fhirClient = FHIRClient(
            server: url,
            httpClient: DefaultHTTPClient(urlSessionConfiguration: .default),
            receiveQueue: .immediate
        )
        sut = ErxTaskFHIRDataStore(fhirClient: fhirClient)
    }

    override func tearDownWithError() throws {
        fhirClient = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testFetchTaskById() {
        let firstTaskResponse = load(
            resource: "getTaskResponse_61704e3f-1e4f-11b2-80f4-b806a73c0cd0",
            directory: .gem_wf_v1_1_with_kbv_v1_0_2
        )
        var counter = 0
        stub(condition: isHost(host) && isPath("/Task/61704e3f-1e4f-11b2-80f4-b806a73c0cd0")) { _ in
            counter += 1
            return fixture(filePath: firstTaskResponse, headers: ["Accept": "application/fhir+json"])
        }

        sut.fetchTask(by: "61704e3f-1e4f-11b2-80f4-b806a73c0cd0", accessCode: nil)
            .test(expectations: { erxTask in
                guard let erxTask = erxTask else {
                    fail("erxTask is expected to not be nil")
                    return
                }
                expect(erxTask.id) == "61704e3f-1e4f-11b2-80f4-b806a73c0cd0"
                expect(erxTask.status) == .ready
                expect(erxTask.flowType) == .pharmacyOnly
                expect(erxTask.accessCode) == "7eccd529292631f6a7cd120b57ded23062c35932cc721bfd32b08c5fb188b642"
                expect(erxTask.medication?.name).toNot(beNil())
                expect(erxTask.medication?.name) == "Sumatriptan-1a Pharma 100 mg Tabletten"
                expect(erxTask.authoredOn).toNot(beNil())
                expect(erxTask.authoredOn) == "2021-03-24T08:35:32.311370977+00:00"
                expect(erxTask.expiresOn) == "2021-06-24"
                expect(erxTask.acceptedUntil) == "2021-04-23"
                expect(erxTask.lastModified) == "2021-03-24T08:35:32.311376627+00:00"
                expect(erxTask.author).toNot(beNil())
                expect(erxTask.author) == "Hausarztpraxis Dr. Topp-Glücklich"
                expect(erxTask.medication?.dosageForm).toNot(beNil())
                expect(erxTask.medication?.dosageForm) == "TAB"
                expect(erxTask.medication?.amount) == ErxMedication.Ratio(
                    numerator: .init(value: "12", unit: "TAB"),
                    denominator: .init(value: "1")
                )
                expect(erxTask.medication?.batch?.lotNumber) == "1234567890abcde"
                expect(erxTask.medication?.batch?.expiresOn) == "2020-02-03T00:00:00+00:00"
                expect(erxTask.medicationRequest.dosageInstructions) == "1-0-1-0"
                expect(erxTask.medicationRequest.multiplePrescription?.mark) == true
                expect(erxTask.medicationRequest.multiplePrescription?.numbering) == 2
                expect(erxTask.medicationRequest.multiplePrescription?.totalNumber) == 4
                expect(erxTask.medicationRequest.multiplePrescription?.startPeriod) == "2021-01-02"
                expect(erxTask.medicationRequest.multiplePrescription?.endPeriod) == "2021-03-30"
                expect(erxTask.patient?.name) == "Ludger Ludger Königsstein"
                expect(erxTask.patient?.coverageType) == .GKV
            })

        // test if sub has been called
        expect(counter) == 1
    }

    func testListAllTasks() {
        let taskIdsResponse = load(
            resource: "getTaskIdsWithTwoTasksResponse",
            directory: .gem_wf_v1_1_with_kbv_v1_0_2
        )
        var counter = 0
        stub(condition: isHost(host) && isPath("/Task")) { _ in
            counter += 1
            return fixture(filePath: taskIdsResponse, headers: ["Accept": "application/fhir+json"])
        }

        let firstTaskResponse = load(
            resource: "getTaskResponse_61704e3f-1e4f-11b2-80f4-b806a73c0cd0",
            directory: .gem_wf_v1_1_with_kbv_v1_0_2
        )

        stub(condition: isHost(host) && isPath("/Task/61704e3f-1e4f-11b2-80f4-b806a73c0cd0")) { _ in
            counter += 1
            return fixture(filePath: firstTaskResponse, headers: ["Accept": "application/fhir+json"])
        }
        let secondTaskResponse = load(
            resource: "getTaskResponse_5e00e907-1e4f-11b2-80be-b806a73c0cd0",
            directory: .gem_wf_v1_1_with_kbv_v1_0_2
        )
        stub(condition: isHost(host) && isPath("/Task/5e00e907-1e4f-11b2-80be-b806a73c0cd0")) { _ in
            counter += 1
            return fixture(filePath: secondTaskResponse, headers: ["Accept": "application/fhir+json"])
        }
        sut.listAllTasks(after: nil)
            .test(expectations: { erxTasks in
                expect(erxTasks.content.count).to(equal(2))
                let sortedIds = erxTasks.content.map(\.id).sorted()
                expect(sortedIds)
                    .to(equal(["5e00e907-1e4f-11b2-80be-b806a73c0cd0", "61704e3f-1e4f-11b2-80f4-b806a73c0cd0"]))
            })

        sut.listDetailedTasks(
            for: PagedContent(
                content: [
                    ErxTask(
                        identifier: "5e00e907-1e4f-11b2-80be-b806a73c0cd0",
                        status: .ready,
                        flowType: .pharmacyOnly
                    ),
                    ErxTask(
                        identifier: "61704e3f-1e4f-11b2-80f4-b806a73c0cd0",
                        status: .ready,
                        flowType: .pharmacyOnly
                    ),
                ],
                next: nil
            )
        )
        .test(expectations: { erxTasks in
            expect(erxTasks.content.count).to(equal(2))
        })

        // test if all subs have been called
        expect(counter) == 3
    }

    func testListAllAuditEvents() {
        let firstTaskResponse = load(
            resource: "getAuditEventResponse_4_entries",
            directory: .gem_wf_v1_1_with_kbv_v1_0_2
        )

        var counter = 0

        stub(condition: isHost(host) && isPath("/AuditEvent")) { _ in
            counter += 1
            return fixture(filePath: firstTaskResponse, headers: ["Accept": "application/fhir+json"])
        }

        sut.listAllAuditEvents()
            .test(expectations: { erxTasks in
                expect(erxTasks.content.count).to(equal(4))
                let sortedIds = erxTasks.content.map(\.id).sorted()
                expect(sortedIds)
                    .to(equal(["64c4f143-1de0-11b2-80eb-443cac489883",
                               "64c4f1af-1de0-11b2-80ec-443cac489883",
                               "64c4f1cc-1de0-11b2-80ed-443cac489883",
                               "64c4f1ea-1de0-11b2-80ee-443cac489883"]))
            })

        expect(counter) == 1
    }

    /// Tests a successful deletion of a task
    func testDeleteTasksSuccess() {
        let emptyResponse = load(
            resource: "emptyResponse",
            directory: .gem_wf_v1_1_with_kbv_v1_0_2
        )

        stub(condition: isHost(host) && pathStartsWith("/Task") && pathEndsWith("$abort")) { _ in
            fixture(filePath: emptyResponse, status: 204, headers: ["Accept": "application/fhir+json"])
        }
        let erxTask = ErxTask(identifier: "1", status: .ready, flowType: .pharmacyOnly, accessCode: "12")
        sut.delete(tasks: [erxTask])
            .test(expectations: { response in
                expect(response) == true
            })
    }

    /// This tests if occuring errors are mapped to false for the result.
    func testDeleteTasksError() {
        stub(condition: isHost(host) && pathEndsWith("$abort")) { _ in
            let error = NSError(domain: self.host, code: -1, userInfo: [:])
            return HTTPStubsResponse(error: error)
        }

        let erxTask = ErxTask(identifier: "1", status: .ready, flowType: .pharmacyOnly, accessCode: "12")

        sut.delete(tasks: [erxTask])
            .test(failure: { error in
                let expectedError = RemoteStoreError.fhirClient(
                    .http(.init(httpClientError: .httpError(URLError(URLError.Code(rawValue: -1))),
                                operationOutcome: nil))
                )
                expect(error.self) == expectedError.self
            })
    }

    func testRedeemShipmentOrderWithSuccess() {
        let redeemOrderResponse = load(
            resource: "redeemOrderResponse",
            directory: .gem_wf_v1_4
        )

        var counter = 0
        stub(condition: isPath("/Communication")
            && isMethodPOST()) { _ in
                counter += 1
                // Note: response is not validated for test
                return fixture(filePath: redeemOrderResponse, headers: ["Content-Type": "application/json"])
        }

        sut.redeem(order: shipmentOrder)
            .test { error in
                fail("unexpected fail with error: \(error)")
            } expectations: { order in
                expect(counter) == 1
                expect(order).to(equal(self.shipmentOrder))
            }
    }

    func testRedeemDeliveryOrderWithSuccess() {
        let redeemOrderResponse = load(
            resource: "redeemOrderResponse",
            directory: .gem_wf_v1_4
        )

        var counter = 0
        stub(condition: isPath("/Communication")
            && isMethodPOST()
            && hasBody(expectedDeliveryRequestBody)) { _ in
                counter += 1
                // Note: response is not validated for test
                return fixture(filePath: redeemOrderResponse, headers: ["Content-Type": "application/json"])
        }

        sut.redeem(order: deliveryOrder)
            .test { error in
                fail("unexpected fail with error: \(error)")
            } expectations: { order in
                expect(counter) == 1
                expect(order).to(equal(self.deliveryOrder))
            }
    }

    func testRedeemOnPremiseOrderWithSuccess() {
        let redeemOrderResponse = load(
            resource: "redeemOrderResponse",
            directory: .gem_wf_v1_4
        )

        var counter = 0
        stub(condition: isPath("/Communication")
            && isMethodPOST()
            && hasBody(expectedOnPremiseRequestBody)) { _ in
                counter += 1
                // Note: response is not validated for test
                return fixture(filePath: redeemOrderResponse, headers: ["Content-Type": "application/json"])
        }

        sut.redeem(order: onPremiseOrder)
            .test { error in
                fail("unexpected fail with error: \(error)")
            } expectations: { order in
                expect(counter) == 1
                expect(order).to(equal(self.onPremiseOrder))
            }
    }

    func testRedeemOrderWithFailure() {
        let expectedError = URLError(.notConnectedToInternet)

        var counter = 0
        stub(condition: isPath("/Communication")
            && isMethodPOST()
            && hasBody(expectedShipmentRequestBody)) { _ in
                counter += 1
                return HTTPStubsResponse(error: expectedError)
        }

        sut.redeem(order: shipmentOrder)
            .test { error in
                expect(counter) == 1
                expect(error) ==
                    .fhirClient(.http(.init(httpClientError: .httpError(expectedError), operationOutcome: nil)))
            } expectations: { _ in
                fail("this test should rase an error instead")
            }
    }

    func testListAllCommunicationsWithSuccess() {
        let expectedResponse = load(
            resource: "erxCommunicationReplyResponse",
            directory: .gem_wf_v1_1_with_kbv_v1_0_2
        )
        var counter = 0

        stub(condition: isHost(host)
            && isMethodGET()
            && isPath("/Communication")) { _ in
                counter += 1
                // Note: response is not validated for test
                return fixture(filePath: expectedResponse, headers: ["Accept": "application/fhir+json"])
        }

        sut.listAllCommunications(after: nil, for: .reply)
            .test { error in
                fail("unexpected fail with error: \(error)")
            } expectations: { communications in
                expect(counter) == 1
                expect(communications.count) == 4
                let sortedIds = communications.map(\.identifier).sorted()
                expect(sortedIds.first) == "86aa9d40-1dd2-11b2-80e5-dd3ddb83b539"
                expect(sortedIds.last) == "c54ea762-1e50-11b2-8116-dd3ddb83b539"
            }
    }

    func testListAllCommunicationsWithFailure() {
        let expectedError = URLError(.notConnectedToInternet)

        var counter = 0
        stub(condition: isHost(host)
            && isPath("/Communication")
            && isMethodGET()) { _ in
                counter += 1
                return HTTPStubsResponse(error: expectedError)
        }

        sut.listAllCommunications(after: nil, for: .reply)
            .test { error in
                expect(counter) == 1
                expect(error) ==
                    .fhirClient(.http(.init(httpClientError: .httpError(expectedError), operationOutcome: nil)))
            } expectations: { _ in
                fail("this test should rase an error instead")
            }
    }

    func testListMedicationDispensesForTaskWithSuccess() {
        let expectedResponse = load(
            resource: "MedicationDispense_with_two_Medication_PZN",
            directory: .gem_wf_v1_1_with_kbv_v1_0_2
        )
        var counter = 0

        stub(condition: isHost(host)
            && isMethodGET()
            && isPath("/MedicationDispense")) { _ in
                counter += 1
                return fixture(filePath: expectedResponse, headers: ["Accept": "application/fhir+json"])
        }

        sut.listMedicationDispenses(for: "160.000.000.014.285.76")
            .test { error in
                fail("unexpected fail with error: \(error)")
            } expectations: { medicationDispenses in
                expect(counter) == 1
                expect(medicationDispenses.count) == 2
                let sortedIds = medicationDispenses.map(\.taskId).sorted()
                expect(sortedIds.first) == "160.000.000.014.285.76"
                expect(sortedIds.last) == "160.000.000.014.298.37"
            }
    }

    func testListMedicationDispensesForTaskWithFailure() {
        let expectedError = URLError(.notConnectedToInternet)

        var counter = 0
        stub(condition: isHost(host)
            && isPath("/MedicationDispense")
            && isMethodGET()) { _ in
                counter += 1
                return HTTPStubsResponse(error: expectedError)
        }

        sut.listMedicationDispenses(for: "160.000.000.014.285.76")
            .test { error in
                expect(counter) == 1
                expect(error) ==
                    .fhirClient(.http(.init(httpClientError: .httpError(expectedError), operationOutcome: nil)))
            } expectations: { _ in
                fail("this test should rase an error instead")
            }
    }

    func testDeleteChargeItemSuccess() throws {
        let emptyResponse = load(
            resource: "emptyResponse",
            directory: .gem_wf_v1_1_with_kbv_v1_0_2
        )

        stub(condition: pathStartsWith("/ChargeItem")
            && isMethodDELETE()) { _ in
                fixture(filePath: emptyResponse, status: 204, headers: ["Accept": "application/fhir+json"])
        }
        let chargeItem = ErxChargeItem(
            identifier: "200.000.001.206.112.29",
            fhirData: "FHIRData".data(using: .utf8)!,
            accessCode: "12"
        )

        sut.delete(chargeItems: [chargeItem])
            .test(expectations: { response in
                expect(response) == true
            })
    }

    func testDeleteChargeItemWithError() {
        stub(condition: pathStartsWith("/ChargeItem")
            && isMethodDELETE()) { _ in
                let error = NSError(domain: self.host, code: -1, userInfo: [:])
                return HTTPStubsResponse(error: error)
        }

        let chargeItem = ErxChargeItem(
            identifier: "200.000.001.206.112.29",
            fhirData: "FHIRData".data(using: .utf8)!,
            accessCode: "12"
        )

        sut.delete(chargeItems: [chargeItem])
            .test(failure: { error in
                let expectedError = RemoteStoreError.fhirClient(
                    .http(.init(httpClientError: .httpError(URLError(URLError.Code(rawValue: -1))),
                                operationOutcome: nil))
                )
                expect(error.self) == expectedError.self
            })
    }

    func testGetConsentsWithSuccess() {
        let consentResponse = load(
            resource: "getConsentsResponse",
            directory: .gem_erpChrg_v1_0_0
        )

        var counter = 0
        stub(condition: isHost(host)
            && isPath("/Consent")
            && isMethodGET()) { _ in
                counter += 1
                return fixture(filePath: consentResponse, headers: ["Content-Type": "application/json"])
        }

        sut.fetchConsents()
            .test { error in
                fail("unexpected fail with error: \(error)")
            } expectations: { consent in
                expect(counter) == 1
                expect(consent.first?.category).to(equal(.chargcons))
                expect(consent.first?.insuranceId).to(equal("X764228532"))
            }
    }

    func testGetConsentsWithFailure() {
        let expectedError = URLError(.notConnectedToInternet)

        var counter = 0
        stub(condition: isHost(host)
            && isPath("/Consent")
            && isMethodGET()) { _ in
                counter += 1
                return HTTPStubsResponse(error: expectedError)
        }

        sut.fetchConsents()
            .test { error in
                expect(counter) == 1
                expect(error) ==
                    .fhirClient(.http(.init(httpClientError: .httpError(expectedError), operationOutcome: nil)))
            } expectations: { _ in
                fail("this test should rase an error instead")
            }
    }

    func testRevokeConsentWithSuccess() {
        let emptyResponse = load(
            resource: "emptyResponse",
            directory: .gem_wf_v1_1_with_kbv_v1_0_2
        )

        stub(condition: isHost(host)
            && isPath("/Consent")
            && isMethodDELETE()) { _ in
                fixture(filePath: emptyResponse, status: 204, headers: ["Accept": "application/fhir+json"])
        }

        sut.revokeConsent(.chargcons)
            .test(expectations: { response in
                expect(response) == true
            })
    }

    func testRevokeConsentWithNoConsentGivenReturnsFailure() {
        let errorResponse = load(
            resource: "revokeConsentErrorResponse",
            directory: .gem_erpChrg_v1_0_0
        )

        stub(condition: isHost(host)
            && isPath("/Consent")
            && isMethodDELETE()) { _ in
                fixture(filePath: errorResponse,
                        status: Int32(HTTPStatusCode.badRequest.rawValue),
                        headers: ["Accept": "application/fhir+json"])
        }

        sut.revokeConsent(.chargcons)
            .test(failure: { error in
                expect(error.localizedDescription)
                    .to(contain("error: Could not find any consent for given KVNR , code: not-found"))
            }, expectations: { _ in
                fail()
            })
    }

    func testGrantConsentWithSuccess() {
        let grantConsentResponse = load(
            resource: "GEM_ERPCHRG_PR_Consent",
            directory: .gem_erpChrg_v1_0_0
        )

        var counter = 0
        stub(condition: isHost(host)
            && isPath("/Consent")
            && isMethodPOST()
            && hasBody(expectedChargeConsentRequestBody)) { _ in
                counter += 1
                return fixture(filePath: grantConsentResponse, headers: ["Content-Type": "application/json"])
        }

        sut.grantConsent(chargeConsent)
            .test { error in
                fail("unexpected fail with error: \(error)")
            } expectations: { consent in
                expect(counter) == 1
                expect(consent).to(equal(self.chargeConsent))
            }
    }

    func testGrantConsentThatsAlreadyGivenReturnsFailure() {
        let errorResponse = load(
            resource: "grantConsentErrorResponse",
            directory: .gem_erpChrg_v1_0_0
        )

        stub(condition: isHost(host)
            && isPath("/Consent")
            && isMethodPOST()) { _ in
                fixture(filePath: errorResponse,
                        status: Int32(HTTPStatusCode.badRequest.rawValue),
                        headers: ["Accept": "application/fhir+json"])
        }

        sut.grantConsent(chargeConsent)
            .test(failure: { error in
                expect(error.localizedDescription)
                    .to(contain("error: Charging consent already exists for this kvnr, code: conflict"))
            }, expectations: { _ in
                fail()
            })
    }

    private var shipmentOrder: ErxTaskOrder = {
        let payload = ErxTaskOrder.Payload(supplyOptionsType: .shipment,
                                           name: "Graf Dracula",
                                           address: ["Schloss Bran",
                                                     "Strada General Traian Moșoiu 24",
                                                     "Bran 507025",
                                                     "Rumänien"],
                                           hint: "Nur bei Tageslicht liefern!",
                                           phone: "666 999 666")
        return ErxTaskOrder(identifier: "d58894dd-c93c-4841-b6f6-4ac4cda4922f",
                            erxTaskId: "39c67d5b-1df3-11b2-80b4-783a425d8e87",
                            accessCode: "777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea",
                            telematikId: "606358757",
                            flowType: "160",
                            payload: payload)
    }()

    private var deliveryOrder: ErxTaskOrder = {
        let payload = ErxTaskOrder.Payload(supplyOptionsType: .delivery,
                                           name: "Graf Dracula",
                                           address: ["Schloss Bran",
                                                     "Strada General Traian Moșoiu 24",
                                                     "Bran 507025",
                                                     "Rumänien"],
                                           hint: "Nur bei Tageslicht liefern!",
                                           phone: "666 999 666")
        return ErxTaskOrder(identifier: "d58894dd-c93c-4841-b6f6-4ac4cda4922f",
                            erxTaskId: "39c67d5b-1df3-11b2-80b4-783a425d8e87",
                            accessCode: "777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea",
                            telematikId: "606358757",
                            flowType: "160",
                            payload: payload)
    }()

    private var onPremiseOrder: ErxTaskOrder = {
        let payload = ErxTaskOrder.Payload(supplyOptionsType: .onPremise,
                                           name: "Graf Dracula",
                                           address: ["Schloss Bran",
                                                     "Strada General Traian Moșoiu 24",
                                                     "Bran 507025",
                                                     "Rumänien"],
                                           hint: "Nur bei Tageslicht liefern!",
                                           phone: "666 999 666")
        return ErxTaskOrder(identifier: "d58894dd-c93c-4841-b6f6-4ac4cda4922f",
                            erxTaskId: "39c67d5b-1df3-11b2-80b4-783a425d8e87",
                            accessCode: "777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea",
                            telematikId: "606358757",
                            flowType: "160",
                            payload: payload)
    }()

    private var chargeConsent = ErxConsent(
        identifier: "CHARGCONS-X764228532",
        insuranceId: "X764228532",
        timestamp: "2023-02-15"
    )

    // swiftlint:disable line_length
    private var expectedShipmentRequestBody: Data = {
        String(
            "{\"basedOn\":[{\"reference\":\"Task\\/39c67d5b-1df3-11b2-80b4-783a425d8e87\\/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea\"}],\"extension\":[{\"url\":\"https:\\/\\/gematik.de\\/fhir\\/erp\\/StructureDefinition\\/GEM_ERP_EX_PrescriptionType\",\"valueCoding\":{\"code\":\"160\",\"system\":\"https:\\/\\/gematik.de\\/fhir\\/erp\\/CodeSystem\\/GEM_ERP_CS_FlowType\"}}],\"identifier\":[{\"system\":\"https:\\/\\/gematik.de\\/fhir\\/NamingSystem\\/OrderID\",\"value\":\"d58894dd-c93c-4841-b6f6-4ac4cda4922f\"}],\"meta\":{\"profile\":[\"https:\\/\\/gematik.de\\/fhir\\/erp\\/StructureDefinition\\/GEM_ERP_PR_Communication_DispReq|1.4\"]},\"payload\":[{\"contentString\":\"{\\\"address\\\":[\\\"Schloss Bran\\\",\\\"Strada General Traian Moșoiu 24\\\",\\\"Bran 507025\\\",\\\"Rumänien\\\"],\\\"hint\\\":\\\"Nur bei Tageslicht liefern!\\\",\\\"name\\\":\\\"Graf Dracula\\\",\\\"phone\\\":\\\"666 999 666\\\",\\\"supplyOptionsType\\\":\\\"shipment\\\",\\\"version\\\":1}\"}],\"recipient\":[{\"identifier\":{\"system\":\"https:\\/\\/gematik.de\\/fhir\\/sid\\/telematik-id\",\"value\":\"606358757\"}}],\"resourceType\":\"Communication\",\"status\":\"unknown\"}"
        ).data(using: .utf8)!
    }()

    private var expectedDeliveryRequestBody: Data = {
        String(
            "{\"basedOn\":[{\"reference\":\"Task\\/39c67d5b-1df3-11b2-80b4-783a425d8e87\\/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea\"}],\"extension\":[{\"url\":\"https:\\/\\/gematik.de\\/fhir\\/erp\\/StructureDefinition\\/GEM_ERP_EX_PrescriptionType\",\"valueCoding\":{\"code\":\"160\",\"system\":\"https:\\/\\/gematik.de\\/fhir\\/erp\\/CodeSystem\\/GEM_ERP_CS_FlowType\"}}],\"identifier\":[{\"system\":\"https:\\/\\/gematik.de\\/fhir\\/NamingSystem\\/OrderID\",\"value\":\"d58894dd-c93c-4841-b6f6-4ac4cda4922f\"}],\"meta\":{\"profile\":[\"https:\\/\\/gematik.de\\/fhir\\/erp\\/StructureDefinition\\/GEM_ERP_PR_Communication_DispReq|1.4\"]},\"payload\":[{\"contentString\":\"{\\\"address\\\":[\\\"Schloss Bran\\\",\\\"Strada General Traian Moșoiu 24\\\",\\\"Bran 507025\\\",\\\"Rumänien\\\"],\\\"hint\\\":\\\"Nur bei Tageslicht liefern!\\\",\\\"name\\\":\\\"Graf Dracula\\\",\\\"phone\\\":\\\"666 999 666\\\",\\\"supplyOptionsType\\\":\\\"delivery\\\",\\\"version\\\":1}\"}],\"recipient\":[{\"identifier\":{\"system\":\"https:\\/\\/gematik.de\\/fhir\\/sid\\/telematik-id\",\"value\":\"606358757\"}}],\"resourceType\":\"Communication\",\"status\":\"unknown\"}"
        ).data(using: .utf8)!
    }()

    private var expectedOnPremiseRequestBody: Data = {
        String(
            "{\"basedOn\":[{\"reference\":\"Task\\/39c67d5b-1df3-11b2-80b4-783a425d8e87\\/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea\"}],\"extension\":[{\"url\":\"https:\\/\\/gematik.de\\/fhir\\/erp\\/StructureDefinition\\/GEM_ERP_EX_PrescriptionType\",\"valueCoding\":{\"code\":\"160\",\"system\":\"https:\\/\\/gematik.de\\/fhir\\/erp\\/CodeSystem\\/GEM_ERP_CS_FlowType\"}}],\"identifier\":[{\"system\":\"https:\\/\\/gematik.de\\/fhir\\/NamingSystem\\/OrderID\",\"value\":\"d58894dd-c93c-4841-b6f6-4ac4cda4922f\"}],\"meta\":{\"profile\":[\"https:\\/\\/gematik.de\\/fhir\\/erp\\/StructureDefinition\\/GEM_ERP_PR_Communication_DispReq|1.4\"]},\"payload\":[{\"contentString\":\"{\\\"address\\\":[\\\"Schloss Bran\\\",\\\"Strada General Traian Moșoiu 24\\\",\\\"Bran 507025\\\",\\\"Rumänien\\\"],\\\"hint\\\":\\\"Nur bei Tageslicht liefern!\\\",\\\"name\\\":\\\"Graf Dracula\\\",\\\"phone\\\":\\\"666 999 666\\\",\\\"supplyOptionsType\\\":\\\"onPremise\\\",\\\"version\\\":1}\"}],\"recipient\":[{\"identifier\":{\"system\":\"https:\\/\\/gematik.de\\/fhir\\/sid\\/telematik-id\",\"value\":\"606358757\"}}],\"resourceType\":\"Communication\",\"status\":\"unknown\"}"
        ).data(using: .utf8)!
    }()

    private var expectedChargeConsentRequestBody: Data = {
        String(
            "{\"category\":[{\"coding\":[{\"code\":\"CHARGCONS\",\"system\":\"https:\\/\\/gematik.de\\/fhir\\/erpchrg\\/CodeSystem\\/GEM_ERPCHRG_CS_ConsentType\"}]}],\"dateTime\":\"2023-02-15\",\"id\":\"CHARGCONS-X764228532\",\"meta\":{\"profile\":[\"https:\\/\\/gematik.de\\/fhir\\/erpchrg\\/StructureDefinition\\/GEM_ERPCHRG_PR_Consent|1.0\"]},\"patient\":{\"identifier\":{\"system\":\"http:\\/\\/fhir.de\\/sid\\/pkv\\/kvid-10\",\"value\":\"X764228532\"}},\"policyRule\":{\"coding\":[{\"code\":\"OPTIN\",\"system\":\"http:\\/\\/terminology.hl7.org\\/CodeSystem\\/v3-ActCode\"}]},\"resourceType\":\"Consent\",\"scope\":{\"coding\":[{\"code\":\"patient-privacy\",\"system\":\"http:\\/\\/terminology.hl7.org\\/CodeSystem\\/consentscope\"}]},\"status\":\"active\"}"
        ).data(using: .utf8)!
    }()

    // swiftlint:enable line_length

    private func load(
        resource name: String,
        directory: FHIRBundleDirectories
    ) -> String {
        guard let resource = Bundle.module.path(
            forResource: name,
            ofType: "json",
            inDirectory: "Resources/\(directory.rawValue).bundle"
        ) else {
            fail("Bundle could not find resource \(name)")
            return ""
        }

        return resource
    }
}
