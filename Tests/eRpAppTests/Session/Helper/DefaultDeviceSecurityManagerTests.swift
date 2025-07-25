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
@testable import eRpFeatures
import Nimble
import TestUtils
import XCTest

final class DefaultDeviceSecurityManagerTests: XCTestCase {
    var mockUserDataStore: MockUserDataStore!
    var deviceSecurityManagerSessionStorage: MockDeviceSecurityManagerSessionStorage!
    var securityPolicyEvaluator: MockSecurityPolicyEvaluator!

    var sut: DefaultDeviceSecurityManager!

    override func setUp() {
        super.setUp()

        mockUserDataStore = MockUserDataStore()
        deviceSecurityManagerSessionStorage = MockDeviceSecurityManagerSessionStorage()
        securityPolicyEvaluator = MockSecurityPolicyEvaluator()

        sut = DefaultDeviceSecurityManager(userDataStore: mockUserDataStore,
                                           sessionStorage: deviceSecurityManagerSessionStorage,
                                           laContext: securityPolicyEvaluator)
    }

    func testWhenPinMissing() {
        var result: Bool?

        securityPolicyEvaluator.canEvaluatePolicyErrorReturnValue = false
        mockUserDataStore.ignoreDeviceNotSecuredWarningPermanently = Just(false).eraseToAnyPublisher()
        deviceSecurityManagerSessionStorage.ignoreDeviceNotSecuredWarningForSession = Just(false).eraseToAnyPublisher()

        sut.informMissingSystemPin
            .test(expectations: { value in
                result = value
            })

        expect(result).to(beTrue())
    }

    func testWhenPinSet() {
        var result: Bool?

        securityPolicyEvaluator.canEvaluatePolicyErrorReturnValue = true
        mockUserDataStore.ignoreDeviceNotSecuredWarningPermanently = Just(false).eraseToAnyPublisher()
        deviceSecurityManagerSessionStorage.ignoreDeviceNotSecuredWarningForSession = Just(false).eraseToAnyPublisher()

        sut.informMissingSystemPin
            .test(expectations: { value in
                result = value
            })

        expect(result).to(beFalse())
    }

    func testWhenPinMissingAndWarningIgnoredTemporarily() {
        var result: Bool?

        securityPolicyEvaluator.canEvaluatePolicyErrorReturnValue = false
        mockUserDataStore.ignoreDeviceNotSecuredWarningPermanently = Just(false).eraseToAnyPublisher()
        deviceSecurityManagerSessionStorage.ignoreDeviceNotSecuredWarningForSession = Just(true).eraseToAnyPublisher()

        sut.informMissingSystemPin
            .test(expectations: { value in
                result = value
            })

        expect(result).to(beFalse())
    }

    func testWhenPinSetAndWarningIgnoredTemporarily() {
        var result: Bool?

        securityPolicyEvaluator.canEvaluatePolicyErrorReturnValue = true
        mockUserDataStore.ignoreDeviceNotSecuredWarningPermanently = Just(false).eraseToAnyPublisher()
        deviceSecurityManagerSessionStorage.ignoreDeviceNotSecuredWarningForSession = Just(true).eraseToAnyPublisher()

        sut.informMissingSystemPin
            .test(expectations: { value in
                result = value
            })

        expect(result).to(beFalse())
    }

    func testWhenPinMissingAndWarningIgnoredTemporarilyAndWarningIgnoredPermanently() {
        var result: Bool?

        securityPolicyEvaluator.canEvaluatePolicyErrorReturnValue = false
        mockUserDataStore.ignoreDeviceNotSecuredWarningPermanently = Just(true).eraseToAnyPublisher()
        deviceSecurityManagerSessionStorage.ignoreDeviceNotSecuredWarningForSession = Just(true).eraseToAnyPublisher()

        sut.informMissingSystemPin
            .test(expectations: { value in
                result = value
            })

        expect(result).to(beFalse())
    }

    func testWhenPinSetAndWarningIgnoredTemporarilyAndWarningIgnoredPermanently() {
        var result: Bool?

        securityPolicyEvaluator.canEvaluatePolicyErrorReturnValue = true
        mockUserDataStore.ignoreDeviceNotSecuredWarningPermanently = Just(true).eraseToAnyPublisher()
        deviceSecurityManagerSessionStorage.ignoreDeviceNotSecuredWarningForSession = Just(true).eraseToAnyPublisher()

        sut.informMissingSystemPin
            .test(expectations: { value in
                result = value
            })

        expect(result).to(beFalse())
    }

    func testWhenPinMissingAndWarningIgnoredPermanently() {
        var result: Bool?

        securityPolicyEvaluator.canEvaluatePolicyErrorReturnValue = false
        mockUserDataStore.ignoreDeviceNotSecuredWarningPermanently = Just(true).eraseToAnyPublisher()
        deviceSecurityManagerSessionStorage.ignoreDeviceNotSecuredWarningForSession = Just(false).eraseToAnyPublisher()

        sut.informMissingSystemPin
            .test(expectations: { value in
                result = value
            })

        expect(result).to(beFalse())
    }

    func testWhenPinSetAndWarningIgnoredPermanently() {
        var result: Bool?

        securityPolicyEvaluator.canEvaluatePolicyErrorReturnValue = true
        mockUserDataStore.ignoreDeviceNotSecuredWarningPermanently = Just(true).eraseToAnyPublisher()
        deviceSecurityManagerSessionStorage.ignoreDeviceNotSecuredWarningForSession = Just(false).eraseToAnyPublisher()

        sut.informMissingSystemPin
            .test(expectations: { value in
                result = value
            })

        expect(result).to(beFalse())
    }
}
