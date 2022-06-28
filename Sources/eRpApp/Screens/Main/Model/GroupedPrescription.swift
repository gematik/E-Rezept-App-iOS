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

import eRpKit
import Foundation

/// GroupedPrescription acts as the view model for an array  of `Prescription`s,
/// which acts as the view model for `ErxTask`s
struct GroupedPrescription: Identifiable, Equatable, Hashable {
    init(
        id: String,
        title: String,
        authoredOn: String,
        isArchived: Bool = false,
        prescriptions: [Prescription],
        displayType: GroupedPrescription.DisplayType
    ) {
        self.id = id
        self.title = title
        self.authoredOn = authoredOn
        self.isArchived = isArchived
        self.prescriptions = prescriptions
        self.displayType = displayType
    }

    let id: String
    let title: String
    let authoredOn: String
    let isArchived: Bool
    let prescriptions: [Prescription]
    let displayType: DisplayType

    enum DisplayType {
        case lowDetail
        case fullDetail

        static func from(erxTaskSource: ErxTask.Source) -> DisplayType {
            switch erxTaskSource {
            case .scanner:
                return .lowDetail
            case .server:
                return .fullDetail
            }
        }
    }
}

extension Sequence where Self.Element == GroupedPrescription {
    var totalPrescriptionCount: Int {
        reduce(0) { acc, group in acc + group.prescriptions.count }
    }
}

extension GroupedPrescription {
    enum Dummies {
        static let prescriptions = GroupedPrescription(
            id: "1",
            title: "Hausarztpraxis Dr. med. Topp-Glücklich",
            authoredOn: "2020-02-03",
            prescriptions: Prescription.Dummies.prescriptions,
            displayType: .fullDetail
        )

        static let scannedPrescriptions = GroupedPrescription(
            id: "2",
            title: "Scanned Prescription",
            authoredOn: "2020-02-03",
            prescriptions: Prescription.Dummies.prescriptions,
            displayType: .lowDetail
        )

        static let faultyPrescription = GroupedPrescription(
            id: "3",
            title: "",
            authoredOn: "",
            prescriptions: [Prescription.Dummies.prescriptionError],
            displayType: .fullDetail
        )
    }
}
