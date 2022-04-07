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

import Combine
import ComposableArchitecture
@testable import eRpApp
import IDP
import Nimble
import XCTest

final class RegisteredDevicesDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        RegisteredDevicesDomain.State,
        RegisteredDevicesDomain.State,
        RegisteredDevicesDomain.Action,
        RegisteredDevicesDomain.Action,
        RegisteredDevicesDomain.Environment
    >

    let testScheduler = DispatchQueue.test
    var schedulers: Schedulers!
    var mockUserSession: MockUserSession!
    var mockUserSessionProvider: MockUserSessionProvider!
    var mockSecureEnclaveSignatureProvider: MockSecureEnclaveSignatureProvider!
    var mockNFCSignatureProvider: NFCSignatureProviderMock!
    var mockSessionProvider: MockProfileBasedSessionProvider!
    var mockRegisteredDevicesService: MockRegisteredDevicesService!

    override func setUp() {
        super.setUp()

        schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        mockUserSession = MockUserSession()
        mockUserSessionProvider = MockUserSessionProvider()
        mockSecureEnclaveSignatureProvider = MockSecureEnclaveSignatureProvider()
        mockNFCSignatureProvider = NFCSignatureProviderMock()
        mockSessionProvider = MockProfileBasedSessionProvider()
        mockRegisteredDevicesService = MockRegisteredDevicesService()
    }

    private func testStore(for state: RegisteredDevicesDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: RegisteredDevicesDomain.reducer,
            environment: RegisteredDevicesDomain.Environment(
                schedulers: schedulers,
                userSession: mockUserSession,
                userSessionProvider: mockUserSessionProvider,
                secureEnclaveSignatureProvider: mockSecureEnclaveSignatureProvider,
                nfcSignatureProvider: mockNFCSignatureProvider,
                sessionProvider: mockSessionProvider,
                accessibilityAnnouncementReceiver: { _ in },
                registeredDevicesService: mockRegisteredDevicesService
            )
        )
    }

    let testProfileId = UUID()

    func testLoadDevicesTriggersCardwall() {
        let store = testStore(for: .init(profileId: testProfileId))
        let cardWallState = IDPCardWallDomain.State(profileId: testProfileId, pin: .init(isDemoModus: false))

        mockRegisteredDevicesService.registeredDevicesForReturnValue =
            Fail(error: RegisteredDevicesServiceError.missingAuthentication)
                .eraseToAnyPublisher()

        mockRegisteredDevicesService.deviceIdForReturnValue = Just(nil)
            .eraseToAnyPublisher()

        mockRegisteredDevicesService.cardWallForReturnValue = Just(cardWallState)
            .eraseToAnyPublisher()

        store.send(.loadDevices) { state in
            state.content = .loading([])
        }
        testScheduler.run()

        store.receive(.showCardWall(cardWallState)) { state in
            state.route = .cardWall(cardWallState)
        }

        store.receive(.deviceIdReceived(nil))
    }

    func testLoadDevicesAuthenticationErrorShows() {
        let store = testStore(for: .init(profileId: testProfileId))

        mockRegisteredDevicesService.registeredDevicesForReturnValue =
            Fail(error: RegisteredDevicesServiceError.missingToken)
                .eraseToAnyPublisher()

        mockRegisteredDevicesService.deviceIdForReturnValue = Just(nil)
            .eraseToAnyPublisher()

        store.send(.loadDevices) { state in
            state.content = .loading([])
        }
        testScheduler.run()

        store.receive(.loadDevicesReceived(.failure(RegisteredDevicesServiceError.missingToken))) { state in
            state.route = .alert(RegisteredDevicesDomain.AlertStates.for(RegisteredDevicesServiceError.missingToken))
        }

        store.receive(.deviceIdReceived(nil))
    }

    func testDeleteDeviceSuccess() {
        let store = testStore(
            for: .init(profileId: UUID(),
                       route: nil,
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

        store.send(RegisteredDevicesDomain.Action.deleteDevice(deviceId)) { _ in }

        testScheduler.run()

        expect(self.mockRegisteredDevicesService.deleteDeviceOfCalled).to(beTrue())

        store.receive(.deleteDeviceReceived(.success(true)))

        testScheduler.run()

        store.receive(.loadDevicesReceived(.success(Fixtures.pairingEntriesSetB))) { state in
            state.content = .loaded(Fixtures.loadedDataB)
        }
    }

    func testDeleteDeviceFailure() {
        let store = testStore(
            for: .init(profileId: UUID(),
                       route: nil,
                       thisDeviceKeyIdentifier: nil,
                       content: .loaded(Fixtures.loadedDataA))
        )

        let deviceId = "KEY234567890"

        mockRegisteredDevicesService.deleteDeviceOfReturnValue =
            Fail(error: RegisteredDevicesServiceError.missingToken)
                .eraseToAnyPublisher()

        store.send(RegisteredDevicesDomain.Action.deleteDevice(deviceId)) { _ in }

        testScheduler.run()

        expect(self.mockRegisteredDevicesService.deleteDeviceOfCalled).to(beTrue())

        store.receive(.deleteDeviceReceived(.failure(RegisteredDevicesServiceError.missingToken))) { state in
            state.route = .alert(RegisteredDevicesDomain.AlertStates.for(RegisteredDevicesServiceError.missingToken))
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
