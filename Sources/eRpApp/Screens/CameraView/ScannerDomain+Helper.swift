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

extension ScannerDomain {
    enum CodeAnalyser {
        static func analyse(scanOutput: [ScanOutput],
                            with previousTaskBatches: Set<[ScannedErxTask]>) throws -> [ScannedErxTask] {
            let scannedErxTasks = try createScannedErxTasks(from: scanOutput)

            if scannedErxTasks.isEmpty {
                throw Error.empty
            }

            let deduplicatedTasks = deduplicateTasks(codes: scannedErxTasks, previous: previousTaskBatches)

            if deduplicatedTasks.isEmpty {
                throw Error.duplicate
            }

            return deduplicatedTasks
        }

        static func createScannedErxTasks(from scanOutput: [ScanOutput]) throws -> [ScannedErxTask] {
            guard let firstCode = scanOutput.first else { // TODO: handle other scans // swiftlint:disable:this todo
                throw Error.empty
            }

            guard case let .erxCode(string) = firstCode,
                  let tasksString = string else {
                throw Error.empty
            }

            return try ScannedErxTask.from(tasks: tasksString)
        }

        static func deduplicateTasks(codes: [ScannedErxTask], previous: Set<[ScannedErxTask]>) -> [ScannedErxTask] {
            let scannedTasks = previous.flatMap { $0 }
            let result = codes.filter { !scannedTasks.contains($0) }

            return result
        }
    }

    enum Error: Swift.Error, Equatable, LocalizedError {
        case duplicate
        case empty
        case invalid
        case storeDuplicate
        case scannedErxTask(ScannedErxTask.Error)
        case unknown

        var isFailure: Bool {
            switch self {
            case .invalid, .empty, .scannedErxTask: return true
            default: return false
            }
        }

        var isDuplicate: Bool {
            switch self {
            case .duplicate, .storeDuplicate: return true
            default: return false
            }
        }

        var errorDescription: String? {
            switch self {
            case .duplicate: return NSLocalizedString("scn_msg_scanned_code_duplicate", comment: "")
            case .empty, .invalid: return NSLocalizedString("scn_msg_scanned_code_failed", comment: "")
            case .storeDuplicate: return NSLocalizedString("scn_msg_scanned_code_store_duplicate", comment: "")
            case let .scannedErxTask(error): return error.localizedDescription
            case .unknown: return NSLocalizedString("scn_msg_scanned_code_failed", comment: "")
            }
        }

        static func ==(lhs: ScannerDomain.Error, rhs: ScannerDomain.Error) -> Bool {
            switch (lhs, rhs) {
            case (.duplicate, .duplicate): return true
            case (.empty, .empty): return true
            case (.invalid, .invalid): return true
            case (.storeDuplicate, .storeDuplicate): return true
            case let (.scannedErxTask(lhsError), .scannedErxTask(rhsError)): return lhsError == rhsError
            case (.unknown, .unknown): return true
            default: return false
            }
        }
    }
}
