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
@testable import eRpApp
import eRpKit
import Foundation

// MARK: - AVSTransactionDataStoreMock -

final class MockAVSTransactionDataStore: AVSTransactionDataStore {
    // MARK: - fetchAVSTransaction

    var fetchAVSTransactionByCallsCount = 0
    var fetchAVSTransactionByCalled: Bool {
        fetchAVSTransactionByCallsCount > 0
    }

    var fetchAVSTransactionByReceivedIdentifier: UUID?
    var fetchAVSTransactionByReceivedInvocations: [UUID] = []
    var fetchAVSTransactionByReturnValue: AnyPublisher<AVSTransaction?, LocalStoreError>!
    var fetchAVSTransactionByClosure: ((UUID) -> AnyPublisher<AVSTransaction?, LocalStoreError>)?

    func fetchAVSTransaction(by identifier: UUID) -> AnyPublisher<AVSTransaction?, LocalStoreError> {
        fetchAVSTransactionByCallsCount += 1
        fetchAVSTransactionByReceivedIdentifier = identifier
        fetchAVSTransactionByReceivedInvocations.append(identifier)
        return fetchAVSTransactionByClosure.map { $0(identifier) } ?? fetchAVSTransactionByReturnValue
    }

    // MARK: - listAllAVSTransactions

    var listAllAVSTransactionsCallsCount = 0
    var listAllAVSTransactionsCalled: Bool {
        listAllAVSTransactionsCallsCount > 0
    }

    var listAllAVSTransactionsReturnValue: AnyPublisher<[AVSTransaction], LocalStoreError>!
    var listAllAVSTransactionsClosure: (() -> AnyPublisher<[AVSTransaction], LocalStoreError>)?

    func listAllAVSTransactions() -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        listAllAVSTransactionsCallsCount += 1
        return listAllAVSTransactionsClosure.map { $0() } ?? listAllAVSTransactionsReturnValue
    }

    // MARK: - save

    var saveAvsTransactionsCallsCount = 0
    var saveAvsTransactionsCalled: Bool {
        saveAvsTransactionsCallsCount > 0
    }

    var saveAvsTransactionsReceivedAvsTransactions: [AVSTransaction]?
    var saveAvsTransactionsReceivedInvocations: [[AVSTransaction]] = []
    var saveAvsTransactionsReturnValue: AnyPublisher<[AVSTransaction], LocalStoreError>!
    var saveAvsTransactionsClosure: (([AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError>)?

    func save(avsTransactions: [AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        saveAvsTransactionsCallsCount += 1
        saveAvsTransactionsReceivedAvsTransactions = avsTransactions
        saveAvsTransactionsReceivedInvocations.append(avsTransactions)
        return saveAvsTransactionsClosure.map { $0(avsTransactions) } ?? saveAvsTransactionsReturnValue
    }

    // MARK: - delete

    var deleteAvsTransactionsCallsCount = 0
    var deleteAvsTransactionsCalled: Bool {
        deleteAvsTransactionsCallsCount > 0
    }

    var deleteAvsTransactionsReceivedAvsTransactions: [AVSTransaction]?
    var deleteAvsTransactionsReceivedInvocations: [[AVSTransaction]] = []
    var deleteAvsTransactionsReturnValue: AnyPublisher<[AVSTransaction], LocalStoreError>!
    var deleteAvsTransactionsClosure: (([AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError>)?

    func delete(avsTransactions: [AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        deleteAvsTransactionsCallsCount += 1
        deleteAvsTransactionsReceivedAvsTransactions = avsTransactions
        deleteAvsTransactionsReceivedInvocations.append(avsTransactions)
        return deleteAvsTransactionsClosure.map { $0(avsTransactions) } ?? deleteAvsTransactionsReturnValue
    }
}
