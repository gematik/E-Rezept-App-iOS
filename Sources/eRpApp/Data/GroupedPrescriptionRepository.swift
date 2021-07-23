//
//  Copyright (c) 2021 gematik GmbH
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

protocol GroupedPrescriptionRepository {
    func loadLocal() -> AnyPublisher<[GroupedPrescription], ErxTaskRepositoryError>
    func loadRemoteAndSave(for locale: String?) -> AnyPublisher<[GroupedPrescription], ErxTaskRepositoryError>
}

struct GroupedPrescriptionInteractor: GroupedPrescriptionRepository {
    let erxTaskInteractor: ErxTaskRepositoryAccess

    func loadLocal() -> AnyPublisher<[GroupedPrescription], ErxTaskRepositoryError> {
        erxTaskInteractor.loadLocal().asGroupedPrescriptionSorted()
    }

    func loadRemoteAndSave(for locale: String?) -> AnyPublisher<[GroupedPrescription], ErxTaskRepositoryError> {
        erxTaskInteractor.loadRemoteAndSave(for: locale).asGroupedPrescriptionSorted()
    }
}

extension Sequence where Self.Element == ErxTask {
    func groupBySourceAndIssuerAndDate() -> [GroupedPrescription] {
        let byDisplayType = Dictionary(grouping: self) { $0.source }
        return byDisplayType.flatMap { source, prescriptions -> [GroupedPrescription] in
            let byDate = Dictionary(grouping: prescriptions) { $0.authoredOn }
            return byDate.flatMap { issueDate, erxTasks -> [GroupedPrescription] in
                let byAuthor = Dictionary(grouping: erxTasks) { $0.author ?? $0.practitioner?.name }
                return byAuthor.flatMap { author, erxTasks -> [GroupedPrescription] in
                    let byRedeemedState = Dictionary(grouping: erxTasks) { $0.redeemedOn != nil }
                    return byRedeemedState.compactMap { isRedeemed, prescriptions in
                        let sortedPrescriptions = prescriptions.sorted(by: <)
                        let identifier = sortedPrescriptions.map(\.identifier).joined(separator: "-")
                        return GroupedPrescription(
                            id: identifier,
                            title: author ?? "",
                            authoredOn: issueDate ?? "",
                            isRedeemed: isRedeemed,
                            prescriptions: sortedPrescriptions,
                            displayType: GroupedPrescription.DisplayType.from(erxTaskSource: source)
                        )
                    }
                }
            }
        }
    }
}

extension Publisher where Output == [ErxTask], Failure == ErxTaskRepositoryError {
    func asGroupedPrescriptionSorted() -> AnyPublisher<[GroupedPrescription], ErxTaskRepositoryError> {
        map { tasks in
            tasks.groupBySourceAndIssuerAndDate().sorted { $0.authoredOn > $1.authoredOn }
        }.eraseToAnyPublisher()
    }
}
