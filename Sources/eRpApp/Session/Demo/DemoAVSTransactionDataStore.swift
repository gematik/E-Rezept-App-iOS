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
import eRpKit
import eRpLocalStorage
import Foundation

class DemoAVSTransactionDataStore: AVSTransactionDataStore {
    static let avsTransaction = AVSTransaction(
        httpStatusCode: 200,
        groupedRedeemTime: Date(),
        groupedRedeemID: UUID(),
        telematikID: "telematik-id",
        taskId: "12345.6789.101112"
    )

    init() {}

    private var selectedAVSTransactionId: CurrentValueSubject<UUID?, Never> = CurrentValueSubject(nil)
    private var dummyAVSTransactions: [AVSTransaction] = [
        avsTransaction,
    ]

    var avsTransactionPublisher: CurrentValueSubject<[AVSTransaction], Never> = CurrentValueSubject([avsTransaction])

    func fetchAVSTransaction(by identifier: UUID) -> AnyPublisher<AVSTransaction?, LocalStoreError> {
        Just(dummyAVSTransactions.first { $0.id == identifier })
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
    }

    func listAllAVSTransactions() -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        avsTransactionPublisher.setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
    }

    func save(avsTransactions: [AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        dummyAVSTransactions = avsTransactions + dummyAVSTransactions
        avsTransactionPublisher.send(dummyAVSTransactions)
        return Just(avsTransactions).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
    }

    func delete(avsTransactions: [AVSTransaction]) -> AnyPublisher<[AVSTransaction], LocalStoreError> {
        let allAVSTransactionIds = avsTransactions.map(\.id)
        dummyAVSTransactions = dummyAVSTransactions.filter { !allAVSTransactionIds.contains($0.id) }
        avsTransactionPublisher.send(dummyAVSTransactions)

        return Just(avsTransactions).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
    }
}
