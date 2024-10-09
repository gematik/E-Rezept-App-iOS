//
//  Copyright (c) 2024 gematik GmbH
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

#if DEBUG

import Dependencies
import Foundation

protocol SmartMock: AnyObject {
    func recordedData() throws -> CodableMock
}

struct CodableMock: Codable {
    let jsonData: Data
    let name: String

    init<T>(_ name: String, _ mock: T) throws where T: Codable {
        self.name = name
        jsonData = try JSONEncoder().encode(mock)
    }
}

struct SmartMockState: DependencyKey {
    private static var _step: Int = 0

    var step: Int {
        Self._step
    }

    func setStep(_ step: Int) {
        Self._step = step
    }

    private static var _loginStatus = true

    var loginStatus: Bool {
        Self._loginStatus
    }

    func setLoginStatus(_ loginStatus: Bool) {
        Self._loginStatus = loginStatus
    }

    static let liveValue = Self()
    static let testValue = Self()
}

extension DependencyValues {
    var smartMockState: SmartMockState {
        get { self[SmartMockState.self] }
        set { self[SmartMockState.self] = newValue }
    }
}

/// Helper Class used by generated SmartMocks
enum MockAnswer<T: Codable>: Codable {
    case none
    case delegate
    case repeated(T)
    case queue([T])
    case steps([T])

    mutating func next() -> T? {
        @Dependency(\.smartMockState) var smartMockState

        switch self {
        case .none:
            return nil
        case let .repeated(value):
            return value
        case let .queue(queue):
            let result = queue.first
            self = .queue(Array(queue.dropFirst(1)))
            return result
        case let .steps(steps):
            if smartMockState.step < steps.count {
                return steps[smartMockState.step]
            }
            return steps.first
        case .delegate:
            return nil
        }
    }

    mutating func record(_ element: T) {
        switch self {
        case var .queue(queue):
            queue.append(element)
            self = .queue(queue)
        default:
            self = .queue([element])
        }
    }

    enum CodingKeys: String, CodingKey {
        case type
        case payload
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .none:
            try container.encode("none", forKey: .type)
        case .delegate:
            try container.encode("delegate", forKey: .type)
        case let .repeated(value):
            try container.encode("repeated", forKey: .type)
            try container.encode(value, forKey: .payload)
        case let .queue(values):
            try container.encode("queue", forKey: .type)
            try container.encode(values, forKey: .payload)
        case let .steps(values):
            try container.encode("steps", forKey: .type)
            try container.encode(values, forKey: .payload)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "none":
            self = .none
        case "delegate":
            self = .delegate
        case "repeated":
            let value = try container.decode(T.self, forKey: .payload)
            self = .repeated(value)
        case "queue":
            let values = try container.decode([T].self, forKey: .payload)
            self = .queue(values)
        case "steps":
            let values = try container.decode([T].self, forKey: .payload)
            self = .steps(values)
        default:
            throw Error.unkownType(type: type, path: decoder.codingPath.map(\.stringValue).joined(separator: "."))
        }
    }

    enum Error: Swift.Error, LocalizedError {
        case decodingError
        case unkownType(type: String, path: String)

        var errorDescription: String? {
            switch self {
            case .decodingError:
                return "Decoding Error"
            case let .unkownType(type, path):
                return "Unknown type '\(type)' at '\(path)'. " +
                    "Expeced one of 'none', 'delegate', 'repeated', 'queue', 'steps'"
            }
        }
    }
}

#endif
