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

import eRpKit
import Foundation

extension ScannerDomain {
    enum CodeAnalyser {
        enum Output {
            case tasks([ScannedErxTask])
            case url(URL)
        }

        // [REQ:BSI-eRp-ePA:O.Source_1#3] validation
        static func analyse(scanOutput: [ScanOutput],
                            with previousTaskBatches: Set<[ScannedErxTask]>) throws -> Output {
            let scannedErxTasks: [ScannedErxTask]

            do {
                scannedErxTasks = try createScannedErxTasks(from: scanOutput)
            } catch {
                if let url = try? urlFromScanOutput(from: scanOutput) {
                    return .url(url)
                }
                throw error
            }

            if scannedErxTasks.isEmpty {
                throw Error.empty
            }

            let deduplicatedTasks = deduplicateTasks(codes: scannedErxTasks, previous: previousTaskBatches)

            if deduplicatedTasks.isEmpty {
                throw Error.duplicate
            }

            return .tasks(deduplicatedTasks)
        }

        static func createScannedErxTasks(from scanOutput: [ScanOutput]) throws -> [ScannedErxTask] {
            guard let firstCode = scanOutput.first else {
                throw Error.empty
            }

            guard case let .text(string) = firstCode,
                  let tasksString = string else {
                throw Error.empty
            }

            return try ScannedErxTask.from(tasks: tasksString)
        }

        static func urlFromScanOutput(from scanOutput: [ScanOutput]) throws -> URL {
            guard let firstCode = scanOutput.first else {
                throw Error.empty
            }

            guard case let .text(string) = firstCode,
                  let urlString = string,
                  let url = URL(string: urlString) else {
                throw Error.empty
            }

            return url
        }

        static func deduplicateTasks(codes: [ScannedErxTask], previous: Set<[ScannedErxTask]>) -> [ScannedErxTask] {
            let scannedTasks = previous.flatMap { $0 }
            let result = codes.filter { !scannedTasks.contains($0) }

            return result
        }
    }

    // sourcery: CodedError = "001"
    enum Error: Swift.Error, Equatable, LocalizedError {
        // sourcery: errorCode = "01"
        case duplicate
        // sourcery: errorCode = "02"
        case empty
        // sourcery: errorCode = "03"
        case invalid
        // sourcery: errorCode = "04"
        case storeDuplicate
        // sourcery: errorCode = "05"
        case scannedErxTask(ScannedErxTask.Error)
        // sourcery: errorCode = "06"
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
            case .duplicate: return L10n.scnMsgScannedCodeDuplicate.text
            case .empty, .invalid: return L10n.scnMsgScannedCodeFailed.text
            case .storeDuplicate: return L10n.scnMsgScannedCodeStoreDuplicate.text
            case let .scannedErxTask(error): return error.localizedDescription
            case .unknown: return L10n.scnMsgScannedCodeFailed.text
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
