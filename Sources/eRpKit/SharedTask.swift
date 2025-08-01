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

import Foundation

public struct SharedTask: Equatable, Codable {
    public let id: String
    public let accessCode: String
    public let name: String?

    public init(id: String, accessCode: String, name: String? = nil) {
        self.id = id
        self.accessCode = accessCode
        self.name = name
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        if let name = name {
            try container.encode("\(id)|\(accessCode)|\(name)")
        } else {
            try container.encode("\(id)|\(accessCode)")
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        let combined = try container.decode(String.self)

        let split = combined.split(separator: "|")

        guard split.count >= 2, split.count <= 3 else {
            if split.isEmpty {
                throw Error.failedDecodingEmptyString(combined)
            }
            if split.count == 1 {
                throw Error.missingSeparator(combined)
            }
            throw Error.tooManyComponents(combined)
        }

        let id = String(split[0])
        let accessCode = String(split[1])
        let name = split.count == 3 ? String(split[2]) : nil

        self.init(id: id, accessCode: accessCode, name: name)
    }

    // sourcery: CodedError = "207"
    public enum Error: Swift.Error {
        // sourcery: errorCode = "01"
        case missingSeparator(String)
        // sourcery: errorCode = "02"
        case failedDecodingEmptyString(String)
        // sourcery: errorCode = "03"
        case tooManyComponents(String)
    }
}

extension Sequence where Element == SharedTask {
    /// Converts an Array of `SharedTask`s into an Array of `ErxTask`s
    /// - Parameters:
    ///   - status: The status the `ErxTask` should be created with
    ///   - authoredOn: The authored on date the `ErxTask` should be created with
    ///   - author: The author the `ErxTask` should be created with
    ///   - mediationNameForIndex: The medication name the task should receive, parameterized by Index
    /// - Returns: An Array of `ErxTask`s
    public func asErxTasks(status: ErxTask.Status,
                           with authoredOn: String,
                           author: String,
                           mediationNameForIndex: (String) -> String) -> [ErxTask] {
        var prescriptionCount = 1
        var tasks = [ErxTask]()
        for sharedTask in self {
            let task = ErxTask(
                identifier: sharedTask.id,
                status: status,
                flowType: ErxTask.FlowType(taskId: sharedTask.id),
                accessCode: sharedTask.accessCode,
                authoredOn: authoredOn,
                author: author,
                source: .scanner,
                medication: ErxMedication(name: mediationNameForIndex(String(prescriptionCount)))
            )
            tasks.append(task)
            prescriptionCount += 1
        }

        return tasks
    }
}

extension SharedTask {
    /// Initializes a `SharedTask` with an `ErxTask`.
    /// - Parameter task: The `ErxTaks` that should be converted
    public init(with task: ErxTask) {
        self.init(id: task.id, accessCode: task.accessCode ?? "", name: task.medication?.name)
    }

    /// Creates a string of `ErxTask`'s id, accessCode, and optionally name.
    public var asString: String {
        if let name = name {
            return "\(id)|\(accessCode)|\(name)"
        } else {
            return "\(id)|\(accessCode)"
        }
    }
}
