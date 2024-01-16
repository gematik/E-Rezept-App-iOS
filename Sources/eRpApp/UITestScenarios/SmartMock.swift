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

/// Helper Class used by generated SmartMocks
enum MockAnswer<T: Codable>: Codable {
    case none
    case delegate
    case repeated(T)
    case queue([T])

    mutating func next() -> T? {
        switch self {
        case .none:
            return nil
        case let .repeated(value):
            return value
        case let .queue(queue):
            let result = queue.first
            self = .queue(Array(queue.dropFirst(1)))
            return result
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
        default:
            throw Error.decodingError
        }
    }

    enum Error: Swift.Error {
        case decodingError
    }
}
