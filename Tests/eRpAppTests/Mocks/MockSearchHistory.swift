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

// MARK: - MockSearchHistory -

final class MockSearchHistory: SearchHistory {
    // MARK: - addHistoryItem

    var addHistoryItemCallsCount = 0
    var addHistoryItemCalled: Bool {
        addHistoryItemCallsCount > 0
    }

    var addHistoryItemReceivedItem: String?
    var addHistoryItemReceivedInvocations: [String] = []
    var addHistoryItemClosure: ((String) -> Void)?

    func addHistoryItem(_ item: String) {
        addHistoryItemCallsCount += 1
        addHistoryItemReceivedItem = item
        addHistoryItemReceivedInvocations.append(item)
        addHistoryItemClosure?(item)
    }

    // MARK: - historyItems

    var historyItemsCallsCount = 0
    var historyItemsCalled: Bool {
        historyItemsCallsCount > 0
    }

    var historyItemsReturnValue: [String]!
    var historyItemsClosure: (() -> [String])?

    func historyItems() -> [String] {
        historyItemsCallsCount += 1
        return historyItemsClosure.map { $0() } ?? historyItemsReturnValue
    }
}
