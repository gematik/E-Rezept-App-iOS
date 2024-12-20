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

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct InternalCommunicationsRepository {
    var load: @Sendable () async throws -> [InternalCommunication.Message]
}

// MARK: TCA Dependency

extension InternalCommunicationsRepository: DependencyKey {
    public static let liveValue = InternalCommunicationsRepository {
        guard let url = Bundle.module.url(forResource: "internal_messages", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            throw InternalCommunicationError.invalidURL
        }

        let jsonDecoder: JSONDecoder = {
            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            decoder.dateDecodingStrategy = .formatted(formatter)
            return decoder
        }()

        let decodedMessages: [InternalCommunication.Message]
        do {
            decodedMessages = try jsonDecoder.decode([InternalCommunication.Message].self, from: data)
        } catch {
            throw InternalCommunicationError.decodingError(error)
        }

        return decodedMessages
    }
}

extension DependencyValues {
    var internalCommunicationsRepository: InternalCommunicationsRepository {
        get { self[InternalCommunicationsRepository.self] }
        set { self[InternalCommunicationsRepository.self] = newValue }
    }
}
