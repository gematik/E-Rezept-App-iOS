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

@testable import eRpApp
import Foundation
import XCTest

class MockUIApplication: ResourceHandler {
    var openCallsCount = 0
    var openCalled: Bool {
        openCallsCount > 0
    }

    var openUrlParameter: URL?

    func open(_ url: URL) {
        openUrlParameter = url
        openCallsCount += 1
    }

    var canOpenURLCallsCount = 0
    var canOpenURLCalled: Bool {
        canOpenURLCallsCount > 0
    }

    var canOpenURLParameter: URL?
    var canOpenURLReturnValue = true

    func canOpenURL(_ url: URL) -> Bool {
        canOpenURLParameter = url
        canOpenURLCallsCount += 1
        return canOpenURLReturnValue
    }
}

class FailingUIApplication: ResourceHandler {
    func open(_: URL) {
        XCTFail("This is the failing implementation that should not be called for this test case")
    }

    func canOpenURL(_: URL) -> Bool {
        XCTFail("This is the failing implementation that should not be called for this test case")
        return false
    }
}
