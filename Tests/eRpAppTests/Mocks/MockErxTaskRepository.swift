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
import eRpKit
import XCTest

class MockErxTaskRepository: ErxTaskRepository {
    var loadLocalAllPublisher: AnyPublisher<[ErxTask], ErxRepositoryError>
    var loadLocalAllCallsCount = 0
    var loadLocalAllCalled: Bool {
        loadLocalCallsCount > 0
    }

    var loadRemoteAndSavedPublisher: AnyPublisher<[ErxTask], ErxRepositoryError>
    var loadRemoteAndSavedCallsCount = 0
    var loadRemoteAndSavedCalled: Bool {
        loadRemoteAndSavedCallsCount > 0
    }

    var savePublisher: AnyPublisher<Bool, ErxRepositoryError>
    var saveCallsCount = 0
    var saveCalled: Bool {
        saveCallsCount > 0
    }

    var deletePublisher: AnyPublisher<Bool, ErxRepositoryError>
    var deleteCallsCount = 0
    var deleteCalled: Bool {
        deleteCallsCount > 0
    }

    var loadLocalPublisher: AnyPublisher<ErxTask?, ErxRepositoryError>
    var loadLocalCallsCount = 0
    var loadLocalCalled: Bool {
        loadLocalCallsCount > 0
    }

    var redeemClosure: ((ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, ErxRepositoryError>)?
    var redeemPublisher: AnyPublisher<ErxTaskOrder, ErxRepositoryError>
    var redeemCallsCount = 0
    var redeemCalled: Bool {
        redeemCallsCount > 0
    }

    var listCommunicationsPublisher: AnyPublisher<[ErxTask.Communication], ErxRepositoryError>
    var listCommunicationsCallsCount = 0
    var listCommunicationsCalled: Bool {
        listCommunicationsCallsCount > 0
    }

    var countUnreadCommunicationsPublisher: AnyPublisher<Int, ErxRepositoryError>
    var countUnreadCommunicationsCallsCount = 0
    var countUnreadCommunicationsCalled: Bool {
        countUnreadCommunicationsCallsCount > 0
    }

    var saveCommunicationsPublisher: AnyPublisher<Bool, ErxRepositoryError>
    var saveCommunicationsCallsCount = 0
    var saveCommunicationsCalled: Bool {
        saveCommunicationsCallsCount > 0
    }

    var loadRemoteLastAuditEventsPublisher: AnyPublisher<PagedContent<[ErxAuditEvent]>, ErxRepositoryError>
    var loadRemoteLastAuditEventsCallsCount = 0
    var loadRemoteLastAuditEventsCalled: Bool {
        loadRemoteLastAuditEventsCallsCount > 0
    }

    var loadRemoteAuditEventsPagePublisher: AnyPublisher<PagedContent<[ErxAuditEvent]>, ErxRepositoryError>
    var loadRemoteAuditEventsPageCallsCount = 0
    var loadRemoteAuditEventsPageCalled: Bool {
        loadRemoteAuditEventsPageCallsCount > 0
    }

    var loadRemoteAndSaveChargeItemsPublisher: AnyPublisher<[ErxSparseChargeItem], ErxRepositoryError>
    var loadRemoteAndSaveChargeItemsCallsCount = 0
    var loadRemoteAndSaveChargeItemsCalled: Bool {
        loadRemoteAndSaveChargeItemsCallsCount > 0
    }

    var saveChargeItemsPublisher: AnyPublisher<Bool, ErxRepositoryError>
    var saveChargeItemsCallsCount = 0
    var saveChargeItemsCalled: Bool {
        saveChargeItemsCallsCount > 0
    }

    var deleteChargeItemsPublisher: AnyPublisher<Bool, ErxRepositoryError>
    var deleteChargeItemsCallsCount = 0
    var deleteChargeItemsCalled: Bool {
        deleteChargeItemsCallsCount > 0
    }

    var deleteLocalChargeItemsPublisher: AnyPublisher<Bool, ErxRepositoryError>
    var deleteLocalChargeItemsCallsCount = 0
    var deleteLocalChargeItemsCalled: Bool {
        deleteLocalChargeItemsCallsCount > 0
    }

    var loadLocalChargeItemsPublisher: AnyPublisher<ErxSparseChargeItem?, ErxRepositoryError>
    var loadLocalChargeItemsCallsCount = 0
    var loadLocalChargeItemsCalled: Bool {
        loadLocalChargeItemsCallsCount > 0
    }

    var loadLocalAllChargeItemsPublisher: AnyPublisher<[ErxSparseChargeItem], ErxRepositoryError>
    var loadLocalAllChargeItemsCallsCount = 0
    var loadLocalAllChargeItemsCalled: Bool {
        loadLocalAllChargeItemsCallsCount > 0
    }

    init(stored erxTasks: [ErxTask] = [],
         chargeItems: [ErxSparseChargeItem] = [],
         loadRemoteById: AnyPublisher<ErxTask?, ErxRepositoryError> = failing(),
         saveErxTasks: AnyPublisher<Bool, ErxRepositoryError> = failing(),
         deleteErxTasks: AnyPublisher<Bool, ErxRepositoryError> = failing(),
         find: AnyPublisher<ErxTask?, ErxRepositoryError> = failing(),
         redeemOrder: AnyPublisher<ErxTaskOrder, ErxRepositoryError> = failing(),
         listCommunications: AnyPublisher<[ErxTask.Communication], ErxRepositoryError> = failing(),
         countCommunications: AnyPublisher<Int, ErxRepositoryError> = failing(),
         saveCommunications: AnyPublisher<Bool, ErxRepositoryError> = failing(),
         loadRemoteAuditEvents: AnyPublisher<PagedContent<[ErxAuditEvent]>, ErxRepositoryError> = failing(),
         loadRemoteAuditEventsPage: AnyPublisher<PagedContent<[ErxAuditEvent]>, ErxRepositoryError> = failing(),
         findChargeItem: AnyPublisher<ErxSparseChargeItem?, ErxRepositoryError> = failing(),
         saveChargeItems: AnyPublisher<Bool, ErxRepositoryError> = failing(),
         deleteChargeItems: AnyPublisher<Bool, ErxRepositoryError> = failing(),
         deleteLocalChargeItems: AnyPublisher<Bool, ErxRepositoryError> = failing(),
         updateLocalDiGaInfo: AnyPublisher<Bool, ErxRepositoryError> = failing()) {
        loadLocalAllPublisher = Just(erxTasks)
            .setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()
        loadRemoteAndSavedPublisher = Just(erxTasks)
            .setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()
        savePublisher = saveErxTasks
        deletePublisher = deleteErxTasks
        loadLocalPublisher = find
        redeemPublisher = redeemOrder
        listCommunicationsPublisher = listCommunications
        countUnreadCommunicationsPublisher = countCommunications
        saveCommunicationsPublisher = saveCommunications
        loadRemoteLastAuditEventsPublisher = loadRemoteAuditEvents
        loadRemoteAuditEventsPagePublisher = loadRemoteAuditEventsPage
        loadRemoteByIdPublisher = loadRemoteById
        loadLocalChargeItemsPublisher = findChargeItem
        loadLocalAllChargeItemsPublisher = Just(chargeItems)
            .setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()
        loadRemoteAndSaveChargeItemsPublisher = Just(chargeItems)
            .setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()
        saveChargeItemsPublisher = saveChargeItems
        deleteChargeItemsPublisher = deleteChargeItems
        deleteLocalChargeItemsPublisher = deleteLocalChargeItems
        updateLocalDiGaInfoReturnValue = updateLocalDiGaInfo
    }

    var loadRemoteByIdPublisher: AnyPublisher<ErxTask?, ErxRepositoryError>
    var loadRemoteByIdCallsCount = 0
    var loadRemoteByIdCalled: Bool {
        loadLocalCallsCount > 0
    }

    func loadRemote(by _: ErxTask.ID, accessCode _: String?) -> AnyPublisher<ErxTask?, ErxRepositoryError> {
        loadRemoteByIdCallsCount += 1
        return loadRemoteByIdPublisher
    }

    func loadLocalAll() -> AnyPublisher<[ErxTask], ErxRepositoryError> {
        loadLocalAllCallsCount += 1
        return loadLocalAllPublisher
    }

    func loadRemoteAll(for _: String?) -> AnyPublisher<[ErxTask], ErxRepositoryError> {
        loadRemoteAndSavedCallsCount += 1
        return loadRemoteAndSavedPublisher
    }

    func save(erxTasks _: [ErxTask]) -> AnyPublisher<Bool, ErxRepositoryError> {
        saveCallsCount += 1
        return savePublisher
    }

    func delete(erxTasks _: [ErxTask]) -> AnyPublisher<Bool, ErxRepositoryError> {
        deleteCallsCount += 1
        return deletePublisher
    }

    func loadLocal(by _: ErxTask.ID, accessCode _: String?) -> AnyPublisher<ErxTask?, ErxRepositoryError> {
        loadLocalCallsCount += 1
        return loadLocalPublisher
    }

    func redeem(order: ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, ErxRepositoryError> {
        redeemCallsCount += 1
        return redeemClosure.map { $0(order) } ?? redeemPublisher
    }

    func loadLocalCommunications(
        for _: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], ErxRepositoryError> {
        listCommunicationsCallsCount += 1
        return listCommunicationsPublisher
    }

    func saveLocal(communications _: [ErxTask.Communication]) -> AnyPublisher<Bool, ErxRepositoryError> {
        saveCommunicationsCallsCount += 1
        return saveCommunicationsPublisher
    }

    func countAllUnreadCommunicationsAndChargeItems(
        for _: ErxTask.Communication.Profile
    ) -> AnyPublisher<Int, ErxRepositoryError> {
        countUnreadCommunicationsCallsCount += 1
        return countUnreadCommunicationsPublisher
    }

    // MARK: - AuditEvents

    func loadRemoteLatestAuditEvents(for _: String?)
        -> AnyPublisher<PagedContent<[ErxAuditEvent]>, ErxRepositoryError> {
        loadRemoteLastAuditEventsCallsCount += 1
        return loadRemoteLastAuditEventsPublisher
    }

    func loadRemoteAuditEventsPage(from _: URL,
                                   locale _: String?) -> AnyPublisher<
        PagedContent<[ErxAuditEvent]>,
        eRpKit.ErxRepositoryError
    > {
        loadRemoteAuditEventsPageCallsCount += 1
        return loadRemoteAuditEventsPagePublisher
    }

    // MARK: - ChargeItem

    func loadRemoteChargeItems()
        -> AnyPublisher<[ErxSparseChargeItem], ErxRepositoryError> {
        loadRemoteAndSaveChargeItemsCallsCount += 1
        return loadRemoteAndSaveChargeItemsPublisher
    }

    func loadLocal(by _: ErxSparseChargeItem.ID) -> AnyPublisher<ErxSparseChargeItem?, ErxRepositoryError> {
        loadLocalChargeItemsCallsCount += 1
        return loadLocalChargeItemsPublisher
    }

    func loadLocalAll() -> AnyPublisher<[ErxSparseChargeItem], ErxRepositoryError> {
        loadLocalAllChargeItemsCallsCount += 1
        return loadLocalAllChargeItemsPublisher
    }

    func save(chargeItems _: [ErxSparseChargeItem]) -> AnyPublisher<Bool, ErxRepositoryError> {
        saveChargeItemsCallsCount += 1
        return saveChargeItemsPublisher
    }

    func delete(chargeItems _: [ErxChargeItem]) -> AnyPublisher<Bool, ErxRepositoryError> {
        deleteChargeItemsCallsCount += 1
        return deleteChargeItemsPublisher
    }

    func deleteLocal(chargeItems _: [ErxChargeItem]) -> AnyPublisher<Bool, ErxRepositoryError> {
        deleteLocalChargeItemsCallsCount += 1
        return deleteLocalChargeItemsPublisher
    }

    static func failing() -> AnyPublisher<ErxTask?, ErxRepositoryError> {
        Deferred { () -> AnyPublisher<ErxTask?, ErxRepositoryError> in
            XCTFail("This publisher should not have run")
            return Just(nil).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    static func failing() -> AnyPublisher<Bool, ErxRepositoryError> {
        Deferred { () -> AnyPublisher<Bool, ErxRepositoryError> in
            XCTFail("This publisher should not have run")
            return Just(false).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    static func failing() -> AnyPublisher<ErxTaskOrder, ErxRepositoryError> {
        Deferred { () -> AnyPublisher<ErxTaskOrder, ErxRepositoryError> in
            XCTFail("This publisher should not have run")
            return Fail(error: ErxRepositoryError.remote(.notImplemented)).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    static func failing() -> AnyPublisher<[ErxTask.Communication], ErxRepositoryError> {
        Deferred { () -> AnyPublisher<[ErxTask.Communication], ErxRepositoryError> in
            XCTFail("This publisher should not have run")
            return Just([]).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    static func failing() -> AnyPublisher<PagedContent<[ErxAuditEvent]>, ErxRepositoryError> {
        Deferred { () -> AnyPublisher<PagedContent<[ErxAuditEvent]>, ErxRepositoryError> in
            XCTFail("This publisher should not have run")
            return Just(PagedContent(content: [], next: nil)).setFailureType(to: ErxRepositoryError.self)
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    static func failing() -> AnyPublisher<Int, ErxRepositoryError> {
        Deferred { () -> AnyPublisher<Int, ErxRepositoryError> in
            XCTFail("This publisher should not have run")
            return Just(0).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    static func failing() -> AnyPublisher<ErxSparseChargeItem?, ErxRepositoryError> {
        Deferred { () -> AnyPublisher<ErxSparseChargeItem?, ErxRepositoryError> in
            XCTFail("This publisher should not have run")
            return Just(nil).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    // MARK: - fetchConsents

    var fetchConsentsCallsCount = 0
    var fetchConsentsCalled: Bool {
        fetchConsentsCallsCount > 0
    }

    var fetchConsentsReturnValue: AnyPublisher<[ErxConsent], ErxRepositoryError>!
    var fetchConsentsClosure: (() -> AnyPublisher<[ErxConsent], ErxRepositoryError>)?

    func fetchConsents() -> AnyPublisher<[ErxConsent], ErxRepositoryError> {
        fetchConsentsCallsCount += 1
        if let fetchConsentsClosure = fetchConsentsClosure {
            return fetchConsentsClosure()
        } else {
            return fetchConsentsReturnValue
        }
    }

    // MARK: - grantConsent

    var grantConsentCallsCount = 0
    var grantConsentCalled: Bool {
        grantConsentCallsCount > 0
    }

    var grantConsentReceivedConsent: ErxConsent?
    var grantConsentReceivedInvocations: [ErxConsent] = []
    var grantConsentReturnValue: AnyPublisher<ErxConsent?, ErxRepositoryError>!
    var grantConsentClosure: ((ErxConsent) -> AnyPublisher<ErxConsent?, ErxRepositoryError>)?

    func grantConsent(_ consent: ErxConsent) -> AnyPublisher<ErxConsent?, ErxRepositoryError> {
        grantConsentCallsCount += 1
        grantConsentReceivedConsent = consent
        grantConsentReceivedInvocations.append(consent)
        if let grantConsentClosure = grantConsentClosure {
            return grantConsentClosure(consent)
        } else {
            return grantConsentReturnValue
        }
    }

    // MARK: - revokeConsent

    var revokeConsentCallsCount = 0
    var revokeConsentCalled: Bool {
        revokeConsentCallsCount > 0
    }

    var revokeConsentReceivedCategory: ErxConsent.Category?
    var revokeConsentReceivedInvocations: [ErxConsent.Category] = []
    var revokeConsentReturnValue: AnyPublisher<Bool, ErxRepositoryError>!
    var revokeConsentClosure: ((ErxConsent.Category) -> AnyPublisher<Bool, ErxRepositoryError>)?

    func revokeConsent(_ category: ErxConsent.Category) -> AnyPublisher<Bool, ErxRepositoryError> {
        revokeConsentCallsCount += 1
        revokeConsentReceivedCategory = category
        revokeConsentReceivedInvocations.append(category)
        if let revokeConsentClosure = revokeConsentClosure {
            return revokeConsentClosure(category)
        } else {
            return revokeConsentReturnValue
        }
    }

    // MARK: - ErxDeviceRequest.DiGaInfo

    var updateLocalDiGaInfoCallsCount = 0
    var updateLocalDiGaInfoCalled: Bool {
        updateLocalDiGaInfoCallsCount > 0
    }

    var updateLocalDiGaInfoReceivedCategory: DiGaInfo?
    var updateLocalDiGaInfoReceivedInvocations: [DiGaInfo] = []
    var updateLocalDiGaInfoReturnValue: AnyPublisher<Bool, ErxRepositoryError>!
    var updateLocalDiGaInfoClosure: ((DiGaInfo) -> AnyPublisher<Bool, ErxRepositoryError>)?

    func updateLocal(diGaInfo _: DiGaInfo) -> AnyPublisher<Bool, ErxRepositoryError> {
        updateLocalDiGaInfoCallsCount += 1
        return updateLocalDiGaInfoReturnValue
    }
}
