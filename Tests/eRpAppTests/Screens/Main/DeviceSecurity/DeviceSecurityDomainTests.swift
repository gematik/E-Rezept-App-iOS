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
import Nimble
import XCTest

@MainActor
final class DeviceSecurityDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<DeviceSecurityDomain>

    var mockDeviceSecurityManager: MockDeviceSecurityManager!

    override func setUp() {
        super.setUp()
        mockDeviceSecurityManager = MockDeviceSecurityManager()
    }

    func testStore(for state: DeviceSecurityDomain.State) -> TestStore {
        TestStore(initialState: state) {
            DeviceSecurityDomain()
        } withDependencies: { dependencies in
            dependencies.deviceSecurityManager = mockDeviceSecurityManager
        }
    }

    func testCloseDeviceSecurityPinViewWhenOkButtonTapped_HideScreenForSession() async {
        let store = testStore(for: .init(warningType: .devicePinMissing))
        expect(self.mockDeviceSecurityManager.setIgnoreDeviceSystemPinWarningForSessionCalled).to(beFalse())
        await store.send(.acceptMissingPin(permanently: false))
        await store.receive(.delegate(.close))
        expect(self.mockDeviceSecurityManager.setIgnoreDeviceSystemPinWarningForSessionCalled).to(beTrue())
        expect(self.mockDeviceSecurityManager.setIgnoreDeviceSystemPinWarningPermanentlyCalled).to(beTrue())
        expect(self.mockDeviceSecurityManager.setIgnoreDeviceSystemPinWarningPermanentlyReceivedInvocations)
            .to(equal([false]))
    }

    func testCloseDeviceSecurityPinViewWhenOkButtonTapped_HideScreenPermanently() async {
        let store = testStore(for: .init(warningType: .devicePinMissing))
        expect(self.mockDeviceSecurityManager.setIgnoreDeviceSystemPinWarningForSessionCalled).to(beFalse())
        expect(self.mockDeviceSecurityManager.setIgnoreDeviceSystemPinWarningPermanentlyCalled).to(beFalse())
        await store.send(.acceptMissingPin(permanently: true))
        await store.receive(.delegate(.close))
        expect(self.mockDeviceSecurityManager.setIgnoreDeviceSystemPinWarningForSessionCalled).to(beTrue())
        expect(self.mockDeviceSecurityManager.setIgnoreDeviceSystemPinWarningPermanentlyCalled).to(beTrue())
        expect(self.mockDeviceSecurityManager.setIgnoreDeviceSystemPinWarningPermanentlyReceivedInvocations)
            .to(equal([true]))
    }

    func testCloseDeviceSecurityRootedDeviceViewWhenOkButtonTapped_HideScreenForSession() async {
        let store = testStore(for: .init(warningType: .jailbreakDetected))
        expect(self.mockDeviceSecurityManager.setIgnoreDeviceSystemPinWarningForSessionCalled).to(beFalse())
        expect(self.mockDeviceSecurityManager.setIgnoreDeviceSystemPinWarningPermanentlyCalled).to(beFalse())
        expect(self.mockDeviceSecurityManager.setIgnoreRootedDeviceWarningForSessionCalled).to(beFalse())
        await store.send(.acceptRootedDevice)
        await store.receive(.delegate(.close))
        expect(self.mockDeviceSecurityManager.setIgnoreDeviceSystemPinWarningForSessionCalled).to(beFalse())
        expect(self.mockDeviceSecurityManager.setIgnoreDeviceSystemPinWarningPermanentlyCalled).to(beFalse())
        expect(self.mockDeviceSecurityManager.setIgnoreRootedDeviceWarningForSessionCalled).to(beTrue())
        expect(self.mockDeviceSecurityManager.setIgnoreRootedDeviceWarningForSessionReceivedInvocations)
            .to(equal([true]))
    }
}

// MARK: - MockDeviceSecurityManager -

final class MockDeviceSecurityManager: DeviceSecurityManager {
    // MARK: - showSystemSecurityWarning

    var showSystemSecurityWarning: AnyPublisher<DeviceSecurityWarningType, Never> {
        get { underlyingShowSystemSecurityWarning }
        set(value) { underlyingShowSystemSecurityWarning = value }
    }

    var underlyingShowSystemSecurityWarning: AnyPublisher<DeviceSecurityWarningType, Never>!

    // MARK: - informMissingSystemPin

    var informMissingSystemPin: AnyPublisher<Bool, Never> {
        get { underlyingShowSystemPinWarning }
        set(value) { underlyingShowSystemPinWarning = value }
    }

    private var underlyingShowSystemPinWarning: AnyPublisher<Bool, Never>!

    // MARK: - set

    var setIgnoreDeviceSystemPinWarningForSessionCallsCount = 0
    var setIgnoreDeviceSystemPinWarningForSessionCalled: Bool {
        setIgnoreDeviceSystemPinWarningForSessionCallsCount > 0
    }

    var setIgnoreDeviceSystemPinWarningForSessionReceivedIgnoreDeviceSystemPinWarningForSession: Bool?
    var setIgnoreDeviceSystemPinWarningForSessionReceivedInvocations: [Bool] = []
    var setIgnoreDeviceSystemPinWarningForSessionClosure: ((Bool) -> Void)?

    func set(ignoreDeviceSystemPinWarningForSession: Bool) {
        setIgnoreDeviceSystemPinWarningForSessionCallsCount += 1
        setIgnoreDeviceSystemPinWarningForSessionReceivedIgnoreDeviceSystemPinWarningForSession =
            ignoreDeviceSystemPinWarningForSession
        setIgnoreDeviceSystemPinWarningForSessionReceivedInvocations.append(ignoreDeviceSystemPinWarningForSession)
        setIgnoreDeviceSystemPinWarningForSessionClosure?(ignoreDeviceSystemPinWarningForSession)
    }

    // MARK: - set

    var setIgnoreDeviceSystemPinWarningPermanentlyCallsCount = 0
    var setIgnoreDeviceSystemPinWarningPermanentlyCalled: Bool {
        setIgnoreDeviceSystemPinWarningPermanentlyCallsCount > 0
    }

    var setIgnoreDeviceSystemPinWarningPermanentlyReceivedIgnoreDeviceSystemPinWarningPermanently: Bool?
    var setIgnoreDeviceSystemPinWarningPermanentlyReceivedInvocations: [Bool] = []
    var setIgnoreDeviceSystemPinWarningPermanentlyClosure: ((Bool) -> Void)?

    func set(ignoreDeviceSystemPinWarningPermanently: Bool) {
        setIgnoreDeviceSystemPinWarningPermanentlyCallsCount += 1
        setIgnoreDeviceSystemPinWarningPermanentlyReceivedIgnoreDeviceSystemPinWarningPermanently =
            ignoreDeviceSystemPinWarningPermanently
        setIgnoreDeviceSystemPinWarningPermanentlyReceivedInvocations.append(ignoreDeviceSystemPinWarningPermanently)
        setIgnoreDeviceSystemPinWarningPermanentlyClosure?(ignoreDeviceSystemPinWarningPermanently)
    }

    // MARK: - informJailbreakDetected

    var informJailbreakDetectedCallsCount = 0
    var informJailbreakDetectedCalled: Bool {
        informJailbreakDetectedCallsCount > 0
    }

    var informJailbreakDetectedReturnValue: Bool!
    var informJailbreakDetectedClosure: (() -> Bool)?

    func informJailbreakDetected() -> Bool {
        informJailbreakDetectedCallsCount += 1
        return informJailbreakDetectedClosure.map { $0() } ?? informJailbreakDetectedReturnValue
    }

    // MARK: - set

    var setIgnoreRootedDeviceWarningForSessionCallsCount = 0
    var setIgnoreRootedDeviceWarningForSessionCalled: Bool {
        setIgnoreRootedDeviceWarningForSessionCallsCount > 0
    }

    var setIgnoreRootedDeviceWarningForSessionReceivedIgnoreRootedDeviceWarningForSession: Bool?
    var setIgnoreRootedDeviceWarningForSessionReceivedInvocations: [Bool] = []
    var setIgnoreRootedDeviceWarningForSessionClosure: ((Bool) -> Void)?

    func set(ignoreRootedDeviceWarningForSession: Bool) {
        setIgnoreRootedDeviceWarningForSessionCallsCount += 1
        setIgnoreRootedDeviceWarningForSessionReceivedIgnoreRootedDeviceWarningForSession =
            ignoreRootedDeviceWarningForSession
        setIgnoreRootedDeviceWarningForSessionReceivedInvocations.append(ignoreRootedDeviceWarningForSession)
        setIgnoreRootedDeviceWarningForSessionClosure?(ignoreRootedDeviceWarningForSession)
    }
}
