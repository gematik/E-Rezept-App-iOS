//
//  Copyright (c) 2025 gematik GmbH
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

import Foundation

public struct DiGaInfo: Hashable, Codable, Sendable {
    /// state of DiGa progress
    public var diGaState: DiGaState
    /// Indicates if the bfarmDiGaDetails has been opened by the user
    public var isRead: Bool
    /// Date of when the task got last refreshed
    public var refreshDate: Date?
    /// taskId of related erxTask
    public var taskId: String

    public init(
        diGaState: DiGaState,
        isRead: Bool = false,
        refreshDate: Date? = nil,
        taskId: String? = nil
    ) {
        self.diGaState = diGaState
        self.isRead = isRead
        self.refreshDate = refreshDate
        self.taskId = taskId ?? ""
    }

    public indirect enum DiGaState: Hashable, Equatable, Codable, Sendable {
        /// DiGa redeem code can be requested
        case request
        /// DiGa redeem code is requested and waiting for response
        case insurance
        /// DiGa can be downloaded
        /// We don't know if it is actually downloaded the user just pressed the button on `DiGaDetailsView`
        case download
        /// DiGa is downloaded but not yet activated
        /// We don't know if it is actually activated the user just pressed the button on `DiGaDetailsView`
        case activate
        /// All steps are done and DiGa is completed
        case completed
        /// DiGa is archived 1
        case archive(_ previous: DiGaState)
        /// when the dispense does not include a redeem code
        case noInformation

        public func encoding(encoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            return encoder
        }()) -> Data? {
            try? encoder.encode(self)
        }

        public var isArchive: Bool {
            switch self {
            case .archive:
                return true
            default:
                return false
            }
        }

        public var archivable: Bool {
            switch self {
            case .download, .activate, .completed, .noInformation:
                return true
            default:
                return false
            }
        }

        public var unarchivable: Bool {
            switch self {
            case .archive:
                return true
            default:
                return false
            }
        }
    }

    public func with(
        diGaState: DiGaState? = nil,
        isRead: Bool? = nil,
        refreshDate: Date? = nil,
        taskId: String? = nil
    ) -> DiGaInfo {
        DiGaInfo(
            diGaState: diGaState ?? self.diGaState,
            isRead: isRead ?? self.isRead,
            refreshDate: refreshDate ?? self.refreshDate,
            taskId: taskId ?? self.taskId
        )
    }
}
