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

// MARK: - MockERPDateFormatter -

final class MockERPDateFormatter: ERPDateFormatter {
    // MARK: - string

    var stringFromCallsCount = 0
    var stringFromCalled: Bool {
        stringFromCallsCount > 0
    }

    var stringFromReceivedFrom: Date?
    var stringFromReceivedInvocations: [Date] = []
    var stringFromReturnValue: String!
    var stringFromClosure: ((Date) -> String)?

    func string(from: Date) -> String {
        stringFromCallsCount += 1
        stringFromReceivedFrom = from
        stringFromReceivedInvocations.append(from)
        return stringFromClosure.map { $0(from) } ?? stringFromReturnValue
    }
}
