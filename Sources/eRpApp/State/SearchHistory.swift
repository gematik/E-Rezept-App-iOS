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

import Dependencies
import Foundation

protocol SearchHistory {
    func addHistoryItem(_ item: String)
    func historyItems() -> [String]
}

struct SearchHistoryDependency: DependencyKey {
    static let liveValue: SearchHistory = DefaultSearchHistory.pharmacySearch
    static let previewValue: SearchHistory = DefaultSearchHistory.pharmacySearch
    static let testValue: SearchHistory = unimplemented(
        "\(Self.self).SearchHistory",
        placeholder: DefaultSearchHistory.pharmacySearch
    )
}

extension DependencyValues {
    var searchHistory: SearchHistory {
        get { self[SearchHistoryDependency.self] }
        set { self[SearchHistoryDependency.self] = newValue }
    }
}

class DefaultSearchHistory: SearchHistory {
    var items: [String] = []
    let persistenceKey: String

    init(persistenceKey: String) {
        self.persistenceKey = persistenceKey
        items = UserDefaults.standard.array(forKey: persistenceKey) as? [String] ?? []
    }

    func addHistoryItem(_ item: String) {
        guard item.lengthOfBytes(using: .utf8) > 0 else {
            return
        }
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
        }
        items.insert(item, at: 0)
        items = Array(items.prefix(10))

        UserDefaults.standard.set(items, forKey: persistenceKey)
    }

    func historyItems() -> [String] {
        items
    }

    private static let pharmacySearchHistoryKey = "pharmacy_search_history_items"
    static let pharmacySearch = DefaultSearchHistory(persistenceKey: pharmacySearchHistoryKey)
}
