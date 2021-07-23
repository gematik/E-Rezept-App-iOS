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
@testable import eRpLocalStorage
import Foundation
import Nimble
import TestUtils
import XCTest

final class UserDefaultsStoreTest: XCTestCase {
    let userDefaults = UserDefaults()

    func testShouldHideOnboarding() {
        let sut = UserDefaultsStore(userDefaults: userDefaults)
        sut.hideOnboarding.first().test(expectations: { shouldHide in
            expect(shouldHide) == false
            expect(self.userDefaults.shouldHideOnboarding) == false
        })

        sut.set(hideOnboarding: true)
        sut.hideOnboarding.first().test(expectations: { shouldHide in
            expect(shouldHide) == true
            expect(self.userDefaults.shouldHideOnboarding) == true
        })

        sut.set(hideOnboarding: false)
        sut.hideOnboarding.first().test(expectations: { shouldHide in
            expect(shouldHide) == false
            expect(self.userDefaults.shouldHideOnboarding) == false
        })
    }

    func testShouldHideCardWallIntro() {
        let sut = UserDefaultsStore(userDefaults: userDefaults)
        sut.hideCardWallIntro.first().test(expectations: { shouldHide in
            expect(shouldHide) == false
            expect(self.userDefaults.shouldHideCardWallIntro) == false
        })

        sut.set(hideCardWallIntro: true)
        sut.hideCardWallIntro.first().test(expectations: { shouldHide in
            expect(shouldHide) == true
            expect(self.userDefaults.shouldHideCardWallIntro) == true
        })

        sut.set(hideCardWallIntro: false)
        sut.hideCardWallIntro.first().test(expectations: { shouldHide in
            expect(shouldHide) == false
            expect(self.userDefaults.shouldHideCardWallIntro) == false
        })
    }

    func testEnvironment() {
        let sut = UserDefaultsStore(userDefaults: userDefaults)
        var count = 0
        let environmentName0 = "ABC"
        userDefaults.serverEnvironmentConfiguration = environmentName0
        var receivedEnvironments = [String?]()
        let cancellable = sut.serverEnvironmentConfiguration.sink { name in
            count += 1
            receivedEnvironments.append(name)
        }
        expect(count) == 1
        let environmentName1 = "DEF"
        userDefaults.serverEnvironmentConfiguration = environmentName1
        expect(count) == 2
        let environmentName2 = "GHI"
        sut.set(serverEnvironmentConfiguration: environmentName2)
        expect(count) == 3
        expect(receivedEnvironments) == [environmentName0, environmentName1, environmentName2]
        cancellable.cancel()
    }
}
