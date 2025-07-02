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

import Combine
import CombineSchedulers
import CoreData
import eRpKit
@testable import eRpLocalStorage
import Foundation
import Nimble
import OpenSSL
import XCTest

final class PharmacyCoreDataStoreTests: XCTestCase {
    private var databaseFile: URL!
    private let fileManager = FileManager.default
    private var factory: CoreDataControllerFactory?

    override func setUp() {
        super.setUp()
        databaseFile = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    }

    override func tearDown() {
        if let controller = try? factory?.loadCoreDataController() {
            expect(try controller.destroyPersistentStore(at: self.databaseFile)).toNot(throwError())
        }

        super.tearDown()
    }

    let foregroundQueue: AnySchedulerOf<DispatchQueue> = .immediate
    let backgroundQueue: AnySchedulerOf<DispatchQueue> = .immediate

    private func loadFactory() -> CoreDataControllerFactory {
        guard let factory = factory else {
            #if os(macOS)
            let factory = LocalStoreFactory(
                url: databaseFile,
                fileProtection: FileProtectionType(rawValue: "none")
            )
            #else
            let factory = LocalStoreFactory(
                url: databaseFile,
                fileProtection: .completeUnlessOpen
            )
            #endif
            self.factory = factory
            return factory
        }

        return factory
    }

    private func loadPharmacyCoreDataStore(for _: UUID? = nil) -> PharmacyCoreDataStore {
        PharmacyCoreDataStore(
            coreDataControllerFactory: loadFactory(),
            foregroundQueue: foregroundQueue,
            backgroundQueue: backgroundQueue
        )
    }

    private lazy var pharmacySimple: PharmacyLocation = {
        let telecom = PharmacyLocation.Telecom(
            phone: "09876543",
            fax: "123456789",
            email: "app-feedback@gematik.de",
            web: "https://www.das-e-rezept-fuer-deutschland.de"
        )

        return PharmacyLocation(
            id: "1234",
            status: nil,
            telematikID: "T.S-1",
            name: "Simple Pharmacy",
            types: [],
            position: nil,
            telecom: telecom,
            hoursOfOperation: []
        )
    }()

    private lazy var completePharmacy: PharmacyLocation = {
        let position = PharmacyLocation.Position(
            latitude: 52.52249912396821024,
            longitude: -13.38754943050812048
        )
        let telecom = PharmacyLocation.Telecom(
            phone: "09876543",
            fax: "123456789",
            email: "app-feedback@gematik.de",
            web: "https://www.das-e-rezept-fuer-deutschland.de"
        )

        let operationHours = [PharmacyLocation.HoursOfOperation(
            daysOfWeek: ["mon"],
            openingTime: "08:00:00",
            closingTime: "18:30:00"
        )]

        let derCert =
            Data(
                base64Encoded: "MIIE4TCCA8mgAwIBAgIDD0vlMA0GCSqGSIb3DQEBCwUAMIGuMQswCQYDVQQGEwJERTEzMDEGA1UECgwqQXRvcyBJbmZvcm1hdGlvbiBUZWNobm9sb2d5IEdtYkggTk9ULVZBTElEMUgwRgYDVQQLDD9JbnN0aXR1dGlvbiBkZXMgR2VzdW5kaGVpdHN3ZXNlbnMtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxIDAeBgNVBAMMF0FUT1MuU01DQi1DQTMgVEVTVC1PTkxZMB4XDTE5MDkxNzEyMzYxNloXDTI0MDkxNzEyMzYxNlowXDELMAkGA1UEBhMCREUxIDAeBgNVBAoMFzEtMjExMjM0NTY3ODkgTk9ULVZBTElEMSswKQYDVQQDDCJBcnp0cHJheGlzIERyLiBBxJ9hb8SfbHUgVEVTVC1PTkxZMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmdmUeBLB6UDh4u8FAvi7B3hpAhJYXBlx+IJXLiSrhgCu/T/L5vVlCQb+1gYybWhHT5YlxafTJpOcXSfcixJbFWGxn+iQLqo+LCp/ljLBz5JoU+IXIxRKZCi5SZ9APeglGs4R0/xpPBtsJzihFXVu+B8qGm2oqmvVV91u+MoJ5asC6C+rVOecLxqy/OdmeKfaNSgH2NxVzNc19VmFUkFDGUFJjG4ZgatW4V6AuAhiPnDkEg8gfXr5L7ycQRZUNlEGMmDhh+noHU/doxSU2cgBaiTZNmu17FJLXlBLRISpWcQitcjOkjrJDt4Z0Yta64yZe13+a5dANh32Zeeg5jDQRQIDAQABo4IBVzCCAVMwHQYDVR0OBBYEFF/uDhGziRKzsUC9Nkat5xQojOUZMA4GA1UdDwEB/wQEAwIEMDAMBgNVHRMBAf8EAjAAMCAGA1UdIAQZMBcwCQYHKoIUAEwETDAKBggqghQATASBIzBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLXNtY2IuZWdrLXRlc3QtdHNwLmRlL0FUT1MuU01DQi1DQTNfVEVTVC1PTkxZLmNybDA8BggrBgEFBQcBAQQwMC4wLAYIKwYBBQUHMAGGIGh0dHA6Ly9vY3NwLXNtY2IuZWdrLXRlc3QtdHNwLmRlMB8GA1UdIwQYMBaAFD+eHl4mKtYMlaF4nqrz1drzQaf8MEUGBSskCAMDBDwwOjA4MDYwNDAyMBYMFEJldHJpZWJzc3TDpHR0ZSBBcnp0MAkGByqCFABMBDITDTEtMjExMjM0NTY3ODkwDQYJKoZIhvcNAQELBQADggEBACUnL3MxjyoEyUBRxcBAjl7FdePW0O1/UCeDAbH2b4ob9GjMGjL5OoBmhj9GsUORg/K4cIiqTot2TcPtdooKCI5a5Jupp0nYoAuzdrNlvGYEm0S/cvlyYJXjfhrEIHmlDY0/hpJX3S/hYgkniJ1Wg70MfLLcib05+31OijZmEzpChioIm4KmumEKU4ODsLWr/4OEw9KCYfuNpjiSyyAEd2pMgnGU8MKCJhrR/ZKSteAxAPKTXVtNTKndbptvcsaEZPp//vNdbBh+k8P642P2DHYfeDoUgivEYXdE5ABixtG9sk1Q2DPfTXoS+CKv45ae0vejBnRjuA28lmkmuIp+f+s=" // swiftlint:disable:this line_length
            )!
        let avsCert = try! X509(der: derCert)

        return PharmacyLocation(
            id: "012876",
            status: .active,
            telematikID: "T.S-1-34",
            created: Date(),
            name: "Full pharmacy",
            types: [.pharm, .outpharm, .delivery],
            position: position,
            address: PharmacyLocation.Address(
                street: "Pharmacy Street",
                houseNumber: "2",
                zip: "13267",
                city: "Berlin"
            ),
            telecom: telecom,
            lastUsed: Date(),
            isFavorite: true,
            imagePath: "path/to/image",
            countUsage: 1,
            hoursOfOperation: operationHours,
            avsEndpoints: PharmacyLocation.AVSEndpoints(),
            avsCertificates: [avsCert]
        )
    }()

    private lazy var pharmacyWithTypeAndHours: PharmacyLocation = {
        PharmacyLocation(
            id: "4567",
            status: .active,
            telematikID: "T.S-1-23",
            name: "Pharmacy with type and hours",
            types: [.pharm, .outpharm],
            hoursOfOperation: [.init(
                daysOfWeek: ["mon"],
                openingTime: "08:00:00",
                closingTime: "18:30:00"
            )]
        )
    }()

    func testSavingPharmacy() throws {
        let store = loadPharmacyCoreDataStore()
        try store.add(pharmacies: [pharmacySimple])
    }

    func testSavingPharmacyWillNotStoreAllValues() throws {
        let store = loadPharmacyCoreDataStore()
        try store.add(pharmacies: [completePharmacy, pharmacySimple])

        var receivedListAllPharmacyValues = [[PharmacyLocation]]()
        var receivedCompletions = [Subscribers.Completion<LocalStoreError>]()
        let cancellable = store.listPharmacies()
            .sink(receiveCompletion: { completion in
                receivedCompletions.append(completion)
            }, receiveValue: { pharmacies in
                receivedListAllPharmacyValues.append(pharmacies)
            })

        expect(receivedCompletions.count) == 0
        expect(receivedListAllPharmacyValues.count).to(equal(1))
        // then two pharmacies should be received
        // (without saving status, types, hoursOfOperation, avsEndpoints, avsCertificates)
        expect(receivedListAllPharmacyValues[0].count) == 2
        let first = receivedListAllPharmacyValues[0].first(where: { $0.telematikID == pharmacySimple.telematikID })
        expect(first?.id).to(equal(pharmacySimple.id))
        expect(first?.status).to(beNil())
        expect(first?.created).to(equal(pharmacySimple.created))
        expect(first?.name).to(equal(pharmacySimple.name))
        expect(first?.types).to(equal(pharmacySimple.types))
        expect(first?.position).to(beNil())

        let second = receivedListAllPharmacyValues[0]
            .first(where: { $0.telematikID == completePharmacy.telematikID })
        expect(second?.id).to(equal(completePharmacy.id))
        expect(second?.created).to(equal(completePharmacy.created))
        expect(second?.name).to(equal(completePharmacy.name))
        expect(second?.telecom).to(equal(completePharmacy.telecom))
        expect(second?.address).to(equal(completePharmacy.address))
        expect(second?.telematikID).to(equal(completePharmacy.telematikID))
        expect(second?.lastUsed).to(equal(completePharmacy.lastUsed))
        expect(second?.countUsage).to(equal(completePharmacy.countUsage))
        expect(second?.imagePath).to(equal(completePharmacy.imagePath))
        expect(second?.isFavorite).to(equal(completePharmacy.isFavorite))
        guard let lat = second?.position?.latitude?.doubleValue,
              let long = second?.position?.longitude?.doubleValue,
              let secondPharmacyLat = completePharmacy.position?.latitude?.doubleValue,
              let secondPharmacyLong = completePharmacy.position?.longitude?.doubleValue else {
            throw LocalStoreError.notImplemented
        }
        expect(lat).to(beCloseTo(secondPharmacyLat))
        expect(long).to(beCloseTo(secondPharmacyLong))
        // these are not stored so must be empty
        expect(second?.status).to(beNil())
        expect(second?.types).to(beEmpty())
        expect(second?.hoursOfOperation).to(beEmpty())
        expect(second?.avsCertificates).to(beEmpty())
        expect(second?.avsEndpoints).to(beNil())
        cancellable.cancel()
    }

    func testSavePharmacyWithFailingLoadingDatabase() throws {
        let factory = MockCoreDataControllerFactory()
        factory.loadCoreDataControllerThrowableError = LocalStoreError.notImplemented
        let store = PharmacyCoreDataStore(
            coreDataControllerFactory: factory,
            backgroundQueue: AnyScheduler.main
        )

        var receivedSaveCompletions = [Subscribers.Completion<LocalStoreError>]()
        var receivedSaveResults = [Bool]()

        let cancellable = store.save(pharmacies: [pharmacySimple])
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                fail("did not expect to receive a value")
                receivedSaveResults.append(result)
            })

        expect(receivedSaveResults.count).to(equal(0))
        expect(receivedSaveCompletions.count).to(equal(1))
        expect(receivedSaveCompletions.first) ==
            .failure(LocalStoreError.initialization(error: factory.loadCoreDataControllerThrowableError!))

        cancellable.cancel()
    }

    func testUpdatingPharmacy() throws {
        let store = loadPharmacyCoreDataStore()
        // given
        try store.add(pharmacies: [pharmacySimple])

        let updatedPharmacy = PharmacyLocation(
            id: pharmacySimple.id,
            status: nil, // not stored
            telematikID: "S.0815",
            created: pharmacySimple.created,
            name: "New Pharmacy",
            types: [], // not stored
            position: nil,
            address: PharmacyLocation.Address(street: "Test Street"),
            telecom: PharmacyLocation.Telecom(phone: "1234567"),
            lastUsed: Date(),
            isFavorite: true,
            imagePath: "path/to/image",
            countUsage: 1,
            hoursOfOperation: []
        )
        try store.add(pharmacies: [updatedPharmacy])

        var receivedListAllPharmacyValues = [[PharmacyLocation]]()
        let cancellable = store.listPharmacies()
            .sink(receiveCompletion: { _ in
                fail("did not expect completion")
            }, receiveValue: { pharmacies in
                receivedListAllPharmacyValues.append(pharmacies)
            })

        // then there should be only one in store with the updated values
        expect(receivedListAllPharmacyValues.count).to(equal(1))
        expect(receivedListAllPharmacyValues[0].count) == 1
        let result = receivedListAllPharmacyValues[0].first
        expect(result).to(equal(updatedPharmacy))
        cancellable.cancel()
    }

    func testDeletePharmacy() throws {
        let store = loadPharmacyCoreDataStore()
        // given
        try store.add(pharmacies: [pharmacySimple])

        // when deleting pharmacy
        var receivedDeleteResults = [Bool]()
        var receivedDeleteCompletions = [Subscribers.Completion<LocalStoreError>]()
        _ = store.delete(pharmacies: [pharmacySimple])
            .sink(receiveCompletion: { completion in
                receivedDeleteCompletions.append(completion)
            }, receiveValue: { result in
                receivedDeleteResults.append(result)
            })
        expect(receivedDeleteResults.count).to(equal(1))
        expect(receivedDeleteResults.first).to(beTrue())
        expect(receivedDeleteCompletions.count).to(equal(1))
        expect(receivedDeleteCompletions.first) == .finished

        // then
        var receivedListAllPharmacyValues = [[PharmacyLocation]]()
        _ = store.listPharmacies()
            .sink(receiveCompletion: { _ in
                fail("did not expect to complete")
            }, receiveValue: { pharmacies in
                receivedListAllPharmacyValues.append(pharmacies)
            })

        expect(receivedListAllPharmacyValues.count).to(equal(1))
        // there should be no pharmacy left in store
        expect(receivedListAllPharmacyValues.first?.count) == 0
    }

    func testFetchPharmacyByTelematikIdSuccess() throws {
        let store = loadPharmacyCoreDataStore()
        // given
        try store.add(pharmacies: [pharmacySimple])

        // when we fetch that pharmacy
        var receivedFetchResult: PharmacyLocation?
        let cancellable = store.fetchPharmacy(by: pharmacySimple.telematikID)
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                receivedFetchResult = result
            })

        // then it should be the one we expect
        expect(receivedFetchResult).to(equal(pharmacySimple))

        cancellable.cancel()
    }

    func testFetchPharmacyByTelematikIdNoResults() throws {
        let store = loadPharmacyCoreDataStore()

        var receivedNoResult = false
        // when fetching a pharmacy that has not been added to the store
        let cancellable = store.fetchPharmacy(by: pharmacySimple.telematikID)
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                receivedNoResult = result == nil
            })

        // then it should return none
        expect(receivedNoResult).to(beTrue())

        cancellable.cancel()
    }

    func testUpdatePharmacyWithMatchingInStore() throws {
        let store = loadPharmacyCoreDataStore()
        // given
        try store.add(pharmacies: [pharmacySimple])

        // when
        var receivedUpdateValues = [PharmacyLocation]()
        var expectedResult: PharmacyLocation?
        _ = store.update(telematikId: pharmacySimple.telematikID) { pharmacy in
            pharmacy.status = nil // not stored
            pharmacy.name = "Updated Pharmacy"
            pharmacy.telematikID = "---"
            pharmacy.address = PharmacyLocation.Address(
                street: "Hey Street",
                houseNumber: "1",
                zip: "123",
                city: "Straguuns"
            )
            pharmacy.lastUsed = Date()
            pharmacy.isFavorite = true
            pharmacy.imagePath = "path/to/image"
            pharmacy.countUsage = 1
            expectedResult = pharmacy
        }
        .sink(receiveCompletion: { completion in
            expect(completion) == .finished
        }, receiveValue: { result in
            receivedUpdateValues.append(result)
        })

        expect(receivedUpdateValues.count).to(equal(1))

        var receivedListAllPharmacyValues = [[PharmacyLocation]]()
        // we observe all store changes
        let cancellable = store.listPharmacies()
            .sink(receiveCompletion: { _ in
                fail("did not expect to complete")
            }, receiveValue: { pharmacies in
                receivedListAllPharmacyValues.append(pharmacies)
            })

        // then
        expect(receivedListAllPharmacyValues.count).to(equal(1))
        expect(receivedListAllPharmacyValues.first?.count) == 1
        expect(receivedListAllPharmacyValues.first?.first) == expectedResult

        cancellable.cancel()
    }

    func testUpdatePharmacyWithoutMatchingInStore() throws {
        let store = loadPharmacyCoreDataStore()
        var receivedUpdateValues = [PharmacyLocation]()
        var receivedCompletions = [Subscribers.Completion<LocalStoreError>]()

        let cancellable = store.update(telematikId: pharmacySimple.telematikID) { _ in
            fail("should not be called if an error fetching pharmacy occurs")
        }
        .sink(receiveCompletion: { completion in
            receivedCompletions.append(completion)
        }, receiveValue: { result in
            receivedUpdateValues.append(result)
        })

        expect(receivedCompletions.count).to(equal(1))
        let expectedError = LocalStoreError.write(error: PharmacyCoreDataStore.Error.noMatchingEntity)
        expect(receivedCompletions.first) == .failure(expectedError)
        expect(receivedUpdateValues.count).to(equal(0))

        cancellable.cancel()
    }
}

extension PharmacyCoreDataStore {
    func add(pharmacies: [PharmacyLocation]) throws {
        var receivedSaveCompletions = [Subscribers.Completion<LocalStoreError>]()
        var receivedSaveResults = [Bool]()

        let cancellable = save(pharmacies: pharmacies)
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                receivedSaveResults.append(result)
            })

        expect(receivedSaveResults.count).to(equal(1))
        expect(receivedSaveResults.allSatisfy { $0 == true }).to(beTrue())
        expect(receivedSaveCompletions.count).to(equal(1))
        expect(receivedSaveCompletions.first) == .finished

        cancellable.cancel()
    }
}
