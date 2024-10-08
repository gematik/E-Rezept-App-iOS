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
import IDP
import Nimble
import XCTest

@MainActor
final class RegisteredDevicesDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<RegisteredDevicesDomain>

    let testScheduler = DispatchQueue.test
    var schedulers: Schedulers!
    var mockUserSession: MockUserSession!
    var mockUserSessionProvider: MockUserSessionProvider!
    var mockSecureEnclaveSignatureProvider: MockSecureEnclaveSignatureProvider!
    var mockNFCSignatureProvider: MockNFCSignatureProvider!
    var mockSessionProvider: MockProfileBasedSessionProvider!
    var mockRegisteredDevicesService: MockRegisteredDevicesService!
    let uidateFormatter = UIDateFormatter(fhirDateFormatter: FHIRDateFormatter.shared)

    override func setUp() {
        super.setUp()

        schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        mockUserSession = MockUserSession()
        mockUserSessionProvider = MockUserSessionProvider()
        mockSecureEnclaveSignatureProvider = MockSecureEnclaveSignatureProvider()
        mockNFCSignatureProvider = MockNFCSignatureProvider()
        mockSessionProvider = MockProfileBasedSessionProvider()
        mockRegisteredDevicesService = MockRegisteredDevicesService()
    }

    private func testStore(for state: RegisteredDevicesDomain.State) -> TestStore {
        TestStore(
            initialState: state
        ) {
            RegisteredDevicesDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = schedulers
            dependencies.registeredDevicesService = mockRegisteredDevicesService
            dependencies.uiDateFormatter = uidateFormatter
        }
    }

    let testProfileId = UUID()

    func testLoadDevicesTriggersCardwall() async {
        let store = testStore(for: .init(profileId: testProfileId))
        let cardWallState = CardWallCANDomain.State(
            isDemoModus: false,
            profileId: testProfileId,
            can: ""
        )

        mockRegisteredDevicesService.registeredDevicesForReturnValue =
            Fail(error: RegisteredDevicesServiceError.missingAuthentication)
                .eraseToAnyPublisher()

        mockRegisteredDevicesService.deviceIdForReturnValue = Just(nil)
            .eraseToAnyPublisher()

        mockRegisteredDevicesService.cardWallForReturnValue = Just(cardWallState)
            .eraseToAnyPublisher()

        await store.send(.loadDevices) { state in
            state.content = .loading([])
        }
        await testScheduler.run()

        await store.receive(.showCardWall(cardWallState)) { state in
            state.content = .notLoaded
            state.destination = .cardWallCAN(cardWallState)
        }

        await store.receive(.response(.deviceIdReceived(nil)))

        // when returing from cardwall a refresh loading should occur
    }

    func testWhenReturningFromCardwallThatReloadIsTriggered() async {
        let store = testStore(for: .init(profileId: testProfileId))
        let cardWallState = CardWallCANDomain.State(
            isDemoModus: false,
            profileId: testProfileId,
            can: ""
        )

        let expectedDevices = Fixtures.pairingEntriesSetB
        mockRegisteredDevicesService.registeredDevicesForReturnValue = Just(expectedDevices)
            .setFailureType(to: RegisteredDevicesServiceError.self)
            .eraseToAnyPublisher()

        mockRegisteredDevicesService.deviceIdForReturnValue = Just(nil)
            .eraseToAnyPublisher()

        mockRegisteredDevicesService.cardWallForReturnValue = Just(cardWallState)
            .eraseToAnyPublisher()

        await store.send(.showCardWall(cardWallState)) { state in
            state.destination = .cardWallCAN(cardWallState)
        }
        await testScheduler.run()

        // when returning from cardwall
        await store.send(.destination(.presented(.cardWallCAN(.delegate(.close))))) {
            $0.destination = nil
        }

        await testScheduler.run()

        // then a refresh loading should occur
        await store.receive(.task) { state in
            state.content = .loading([])
        }
        await testScheduler.run()

        await store.receive(.response(.taskReceived(.success(expectedDevices)))) {
            $0.content = .loaded(
                expectedDevices.pairingEntries
                    .map { ($0, self.uidateFormatter.compactDateAndTimeFormatter) }
                    .map(RegisteredDevicesDomain.State.Entry.init)
            )
        }
        await store.receive(.response(.deviceIdReceived(nil)))
    }

    func testLoadDevicesAuthenticationErrorShows() async {
        let store = testStore(for: .init(profileId: testProfileId))

        mockRegisteredDevicesService.registeredDevicesForReturnValue =
            Fail(error: RegisteredDevicesServiceError.missingToken)
                .eraseToAnyPublisher()

        mockRegisteredDevicesService.deviceIdForReturnValue = Just(nil)
            .eraseToAnyPublisher()

        await store.send(.loadDevices) { state in
            state.content = .loading([])
        }
        await testScheduler.run()

        await store
            .receive(.response(.loadDevicesReceived(.failure(RegisteredDevicesServiceError.missingToken)))) { state in
                state.content = .notLoaded
                state.destination = .alert(.init(for: RegisteredDevicesServiceError.missingToken))
            }

        await store.receive(.response(.deviceIdReceived(nil)))
    }

    func testDeleteDeviceSuccess() async {
        let store = testStore(
            for: .init(profileId: UUID(),
                       destination: nil,
                       thisDeviceKeyIdentifier: nil,
                       content: .loaded(Fixtures.loadedDataA))
        )

        let deviceId = "KEY234567890"

        mockRegisteredDevicesService.deleteDeviceOfReturnValue =
            Just(true)
                .setFailureType(to: RegisteredDevicesServiceError.self)
                .eraseToAnyPublisher()

        mockRegisteredDevicesService.registeredDevicesForReturnValue =
            Just(Fixtures.pairingEntriesSetB)
                .setFailureType(to: RegisteredDevicesServiceError.self)
                .eraseToAnyPublisher()

        await store.send(RegisteredDevicesDomain.Action.deleteDevice(deviceId))

        await testScheduler.run()

        expect(self.mockRegisteredDevicesService.deleteDeviceOfCalled).to(beTrue())

        await store.receive(.response(.deleteDeviceReceived(.success(true))))

        await testScheduler.run()

        await store.receive(.response(.loadDevicesReceived(.success(Fixtures.pairingEntriesSetB)))) { state in
            state.content = .loaded(Fixtures.loadedDataB)
        }
    }

    func testDeleteDeviceFailure() async {
        let store = testStore(
            for: .init(profileId: UUID(),
                       destination: nil,
                       thisDeviceKeyIdentifier: nil,
                       content: .loaded(Fixtures.loadedDataA))
        )

        let deviceId = "KEY234567890"

        mockRegisteredDevicesService.deleteDeviceOfReturnValue =
            Fail(error: RegisteredDevicesServiceError.missingToken)
                .eraseToAnyPublisher()

        await store.send(RegisteredDevicesDomain.Action.deleteDevice(deviceId))

        await testScheduler.run()

        expect(self.mockRegisteredDevicesService.deleteDeviceOfCalled).to(beTrue())

        await store
            .receive(.response(.deleteDeviceReceived(.failure(RegisteredDevicesServiceError.missingToken)))) { state in
                state.destination = .alert(.init(for: RegisteredDevicesServiceError.missingToken))
            }
    }
}

extension RegisteredDevicesDomainTests {
    enum Fixtures {
        static let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            return dateFormatter
        }()

        static let loadedDataA = [
            RegisteredDevicesDomain.State.Entry(pairingEntryA, dateFormatter: Self.dateFormatter),
            RegisteredDevicesDomain.State.Entry(pairingEntryB, dateFormatter: Self.dateFormatter),
        ]
        static let loadedDataB = [
            RegisteredDevicesDomain.State.Entry(pairingEntryA, dateFormatter: Self.dateFormatter),
        ]
        static let pairingEntryA = PairingEntry(
            name: "pairingEntryA",
            signedPairingData: signedPairingDataA.serialize(),
            creationTime: Date()
        )
        static let pairingEntryB = PairingEntry(
            name: "pairingEntryB",
            signedPairingData: signedPairingDataB.serialize(),
            creationTime: Date()
        )
        static let pairingEntriesSetA = PairingEntries(pairingEntries: [
            pairingEntryA,
            pairingEntryB,
        ])
        static let pairingEntriesSetB = PairingEntries(pairingEntries: [
            pairingEntryA,
        ])

        static let pairingDataA = PairingData(
            authCertSubjectPublicKeyInfo: "",
            notAfter: 0,
            product: "Product",
            serialnumber: "123456789",
            keyIdentifier: "KEY123456789",
            seSubjectPublicKeyInfo: "",
            issuer: ""
        )
        static let pairingDataB = PairingData(
            authCertSubjectPublicKeyInfo: "",
            notAfter: 0,
            product: "Product",
            serialnumber: "234567890",
            keyIdentifier: "KEY234567890",
            seSubjectPublicKeyInfo: "",
            issuer: ""
        )

        static let signedPairingDataA = SignedPairingData(
            originalPairingData: pairingDataA,
            signedPairingData: try! JWT(
                header: .init(),
                payload: pairingDataA
            )
        )
        static let signedPairingDataB = SignedPairingData(
            originalPairingData: pairingDataB,
            signedPairingData: try! JWT(
                header: .init(),
                payload: pairingDataB
            )
        )
    }
}
