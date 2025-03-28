// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

import AVS
import Combine
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import Foundation
import IdentifiedCollections
import IDP
import OpenSSL
import Pharmacy
import TestUtils
import TrustStore
import VAUClient
import ZXingCpp

@testable import eRpFeatures
























class SearchHistoryMock: SearchHistory {




    //MARK: - addHistoryItem

    var addHistoryItemItemStringVoidCallsCount = 0
    var addHistoryItemItemStringVoidCalled: Bool {
        return addHistoryItemItemStringVoidCallsCount > 0
    }
    var addHistoryItemItemStringVoidReceivedItem: (String)?
    var addHistoryItemItemStringVoidReceivedInvocations: [(String)] = []
    var addHistoryItemItemStringVoidClosure: ((String) -> Void)?

    func addHistoryItem(_ item: String) {
        addHistoryItemItemStringVoidCallsCount += 1
        addHistoryItemItemStringVoidReceivedItem = item
        addHistoryItemItemStringVoidReceivedInvocations.append(item)
        addHistoryItemItemStringVoidClosure?(item)
    }

    //MARK: - historyItems

    var historyItemsStringCallsCount = 0
    var historyItemsStringCalled: Bool {
        return historyItemsStringCallsCount > 0
    }
    var historyItemsStringReturnValue: [String]!
    var historyItemsStringClosure: (() -> [String])?

    func historyItems() -> [String] {
        historyItemsStringCallsCount += 1
        if let historyItemsStringClosure = historyItemsStringClosure {
            return historyItemsStringClosure()
        } else {
            return historyItemsStringReturnValue
        }
    }


}
