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

import Combine
import ComposableArchitecture
import Foundation
import HTTPClient

#if ENABLE_DEBUG_VIEW
enum DebugLogDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.AnyReducer<State, Action, Environment>

    enum Token: CaseIterable, Hashable {}

    struct State: Equatable {
        var isLoggingEnabled = false

        var logs: [DebugLiveLogger.RequestLog]

        var sort: Sort = .bySentDesc

        var filter: String = ""

        enum Sort: String, Equatable, CaseIterable, Identifiable {
            var id: Sort { self }

            case byNameAsc = "by name ↑"
            case byNameDesc = "by name ↓"
            case bySentAsc = "by sent ↑"
            case bySentDesc = "by sent ↓"

            var comparator: (DebugLiveLogger.RequestLog, DebugLiveLogger.RequestLog) -> Bool {
                switch self {
                case .byNameAsc:
                    return { $0.requestUrl < $1.requestUrl }
                case .byNameDesc:
                    return { $0.requestUrl > $1.requestUrl }
                case .bySentAsc:
                    return { $0.sentAt < $1.sentAt }
                case .bySentDesc:
                    return { $0.sentAt > $1.sentAt }
                }
            }
        }

        mutating func updateLogs(from store: DebugLiveLogger) {
            var logs = store.requests

            let filter = self.filter.lowercased()

            if filter.lengthOfBytes(using: .utf8) > 0 {
                logs = logs.filter { $0.requestUrl.lowercased().contains(filter) }
            }

            self.logs = logs.sorted(by: sort.comparator)
        }
    }

    enum Action: Equatable {
        case loadLogs
        // swiftlint:disable:next identifier_name
        case sort(by: State.Sort)

        case setFilter(String)
        case toggleLogging(isEnabled: Bool)
    }

    struct Environment {
        var loggingStore: DebugLiveLogger
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .loadLogs:
            state.updateLogs(from: environment.loggingStore)
            state.isLoggingEnabled = environment.loggingStore.isLoggingEnabled
            return .none
        case let .sort(by: property):
            state.sort = property

            state.updateLogs(from: environment.loggingStore)
            return .none
        case let .setFilter(filter):
            state.filter = filter

            state.updateLogs(from: environment.loggingStore)
            return .none
        case let .toggleLogging(isEnabled: isEnabled):
            state.isLoggingEnabled = isEnabled
            environment.loggingStore.isLoggingEnabled = isEnabled
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        domainReducer
    )
}

extension DebugLogDomain {
    enum Dummies {
        static let state = State(logs: multiple)
        static let store = Store(
            initialState: state,
            reducer: DebugLogDomain.Reducer.empty,
            environment: Environment(loggingStore: DebugLiveLogger.shared)
        )

        static var multiple: [DebugLiveLogger.RequestLog] = [
            log1,
            log2,
            log3,
            log4,
            log1,
            log1,
            log1,
            log1,
        ]

        // swiftlint:disable force_unwrapping
        static var log1: DebugLiveLogger.RequestLog {
            var request = URLRequest(url: URL(string: "http://google.com")!)
            request.setValue("12345", forHTTPHeaderField: "X-api-key")
            let response: HTTPResponse = (
                data: "abcdef".data(using: .utf8)!,
                response: HTTPURLResponse(
                    url: URL(string: "http://google.com")!,
                    statusCode: 200,
                    httpVersion: "1.1",
                    headerFields: ["abc": "def"]
                )!,
                status: HTTPStatusCode.ok
            )

            return DebugLiveLogger.RequestLog(
                request: request,
                sentAt: Date(),
                response: response,
                receivedAt: Date().addingTimeInterval(0.3)
            )
        }

        static var log2: DebugLiveLogger.RequestLog {
            var request = URLRequest(url: URL(string: "http://google.com")!)
            request.setValue("12345", forHTTPHeaderField: "X-api-key")
            let response: HTTPResponse = (
                data: "abcdef".data(using: .utf8)!,
                response: HTTPURLResponse(
                    url: URL(string: "http://google.com")!,
                    statusCode: HTTPStatusCode.found.rawValue,
                    httpVersion: "1.1",
                    headerFields: ["abc": "def"]
                )!,
                status: HTTPStatusCode.found
            )

            return DebugLiveLogger.RequestLog(
                request: request,
                sentAt: Date(),
                response: response,
                receivedAt: Date().addingTimeInterval(0.3)
            )
        }

        static var log3: DebugLiveLogger.RequestLog {
            var request = URLRequest(url: URL(string: "http://google.com")!)
            request.setValue("12345", forHTTPHeaderField: "X-api-key")
            let response: HTTPResponse = (
                data: "abcdef".data(using: .utf8)!,
                response: HTTPURLResponse(
                    url: URL(string: "http://google.com")!,
                    statusCode: HTTPStatusCode.forbidden.rawValue,
                    httpVersion: "1.1",
                    headerFields: ["abc": "def"]
                )!,
                status: HTTPStatusCode.forbidden
            )

            return DebugLiveLogger.RequestLog(
                request: request,
                sentAt: Date(),
                response: response,
                receivedAt: Date().addingTimeInterval(0.3)
            )
        }

        static var log4: DebugLiveLogger.RequestLog {
            var request = URLRequest(url: URL(string: "http://google.com")!)
            request.setValue("12345", forHTTPHeaderField: "X-api-key")
            let response: HTTPResponse = (
                // swiftlint:disable:next force_try
                data: try! Data(contentsOf:
                    Bundle.main.url(
                        forResource: "FOSS",
                        withExtension: "html"
                    )!),
                response: HTTPURLResponse(
                    url: URL(string: "http://google.com")!,
                    statusCode: HTTPStatusCode.serverError.rawValue,
                    httpVersion: "1.1",
                    headerFields: ["abc": "def"]
                )!,
                status: HTTPStatusCode.serverError
            )

            return DebugLiveLogger.RequestLog(
                request: request,
                sentAt: Date(),
                response: response,
                receivedAt: Date().addingTimeInterval(0.3)
            )
        }

        // swiftlint:enable force_unwrapping
    }
}
#endif
