//
//  Copyright (c) 2023 gematik GmbH
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
import eRpKit
import Foundation

struct DummyErxTaskRepository: ErxTaskRepository {
    func loadRemote(by _: ErxTask.ID, accessCode _: String?) -> AnyPublisher<ErxTask?, ErxRepositoryError> {
        Just(nil).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    }

    func loadLocal(by _: ErxTask.ID, accessCode _: String?) -> AnyPublisher<ErxTask?, ErxRepositoryError> {
        Just(nil).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    }

    func loadLocalAll() -> AnyPublisher<[ErxTask], ErxRepositoryError> {
        Just([]).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    }

    func loadRemoteAll(for _: String?) -> AnyPublisher<[ErxTask], ErxRepositoryError> {
        Just([]).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    }

    func save(erxTasks _: [ErxTask]) -> AnyPublisher<Bool, ErxRepositoryError> {
        Just(true).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    }

    func delete(erxTasks _: [ErxTask]) -> AnyPublisher<Bool, ErxRepositoryError> {
        Just(true).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    }

    func redeem(order: ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, ErxRepositoryError> {
        Just(order).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    }

    func loadLocalCommunications(for _: ErxTask.Communication
        .Profile) -> AnyPublisher<[ErxTask.Communication], ErxRepositoryError> {
        Just(
            ErxTask.Communication.Dummies.multipleCommunications1 +
                ErxTask.Communication.Dummies.multipleCommunications2
        ).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    }

    func saveLocal(communications _: [ErxTask.Communication]) -> AnyPublisher<Bool, ErxRepositoryError> {
        Just(true).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    }

    func countAllUnreadCommunications(for _: ErxTask.Communication.Profile) -> AnyPublisher<Int, ErxRepositoryError> {
        Just(0).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    }

    func loadLocal(by _: ErxSparseChargeItem.ID) -> AnyPublisher<ErxSparseChargeItem?, ErxRepositoryError> {
        Just(nil).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    }

    func loadLocalAll() -> AnyPublisher<[ErxSparseChargeItem], ErxRepositoryError> {
        Just([]).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    }

    func save(chargeItems _: [ErxSparseChargeItem]) -> AnyPublisher<Bool, ErxRepositoryError> {
        Just(true).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    }

    func delete(chargeItems _: [ErxSparseChargeItem]) -> AnyPublisher<Bool, ErxRepositoryError> {
        Just(true).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    }

    func loadRemoteChargeItems() -> AnyPublisher<[ErxSparseChargeItem], ErxRepositoryError> {
        Just([]).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    }

    func fetchConsents() -> AnyPublisher<[ErxConsent], ErxRepositoryError> {
        Just([]).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    }

    func grantConsent(_: ErxConsent) -> AnyPublisher<ErxConsent?, ErxRepositoryError> {
        Just(nil).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    }

    func revokeConsent(_: ErxConsent.Category) -> AnyPublisher<Bool, ErxRepositoryError> {
        Just(true).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    }
}
