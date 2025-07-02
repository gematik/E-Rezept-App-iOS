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
import CombineSchedulers
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import IDP
import Nimble
import Pharmacy
import Sharing
import XCTest

@MainActor
final class DiGaInsuranceListDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.immediate
    let mockPharmacyRepository = MockPharmacyRepository()

    typealias TestStore = TestStoreOf<DiGaInsuranceListDomain>

    func testStore(
        _ state: DiGaInsuranceListDomain.State,
        withDependencies prepareDependencies: (inout DependencyValues) -> Void = { _ in }
    ) -> TestStore {
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        return TestStore(initialState: state) {
            DiGaInsuranceListDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = schedulers
            dependencies.pharmacyRepository = mockPharmacyRepository
            prepareDependencies(&dependencies)
        }
    }

    func digaInsuranceListHappyPath() async {
        let store = testStore(.init())
        let result = [Insurance(id: UUID(), name: "TestInsurance", telematikId: "123123"),
                      Insurance(id: UUID(), name: "AInsurance", telematikId: "321321"),
                      Insurance(id: UUID(), name: "ZInsurance", telematikId: "213213")]

        mockPharmacyRepository.fetchAllInsurancesReturnValue = Just(result)
            .setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()

        let task = await store.send(.task) { state in
            state.isLoading = true
        }

        await store.receive(.response(.receivedInsurances(.success(result)))) { state in
            state.isLoading = true
            state.insurances = result
            state.filteredinsurances = result
        }

        await task.cancel()
    }

    func digaInsuranceListError() async {
        let store = testStore(.init())
        let error = PharmacyRepositoryError.remote(.notFound)

        mockPharmacyRepository.fetchAllInsurancesReturnValue = Fail(error: error).eraseToAnyPublisher()

        let task = await store.send(.task) { state in
            state.isLoading = true
        }

        await store.receive(.response(.receivedInsurances(.failure(error)))) { state in
            state.isLoading = true
            state.destination = .alert(.init(for: error))
        }

        await task.cancel()
    }

    func digaInsuranceListSearch() async {
        let store = testStore(.init())
        let searchResult = Insurance(id: UUID(), name: "Versicherung2", telematikId: "321321")
        let result = [Insurance(id: UUID(), name: "TestInsurance", telematikId: "123123"),
                      searchResult]

        mockPharmacyRepository.fetchAllInsurancesReturnValue = Just(result)
            .setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()

        let task = await store.send(.task) { state in
            state.isLoading = true
        }

        await store.receive(.response(.receivedInsurances(.success(result)))) { state in
            state.isLoading = true
            state.insurances = result
            state.filteredinsurances = result
        }

        await store.send(.searchList("Versicherung")) { state in
            state.filteredinsurances = [searchResult]
        }

        await task.cancel()
    }
}
