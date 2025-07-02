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

import Combine
import ComposableArchitecture
import Foundation
import HTTPClient

#if ENABLE_DEBUG_VIEW
@Reducer
struct DebugLogsDomain {
    enum Token: CaseIterable, Hashable {}

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        case share(ShareSheetDomain)
        case logDetail(DebugLogDomain)
    }

    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?

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

    enum Action: BindableAction, Equatable {
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case loadLogs
        case resetLogMessages
        case share
        case showSingleLog(DebugLiveLogger.RequestLog)
    }

    let loggingStore: DebugLiveLogger

    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loadLogs:
            state.updateLogs(from: loggingStore)
            state.isLoggingEnabled = loggingStore.isLoggingEnabled
            return .none
        case .resetLogMessages:
            loggingStore.requests = []
            state.logs = []
            return .none
        case .share:
            state.destination = .share(ShareSheetDomain.State(string: DebugLiveLogger.shared.serializedHARFile()))
            return .none
        case let .showSingleLog(log):
            state.destination = .logDetail(DebugLogDomain.State(log: log))
            return .none
        case .binding(\.sort):
            state.updateLogs(from: loggingStore)
            return .none
        case .binding(\.filter):
            state.updateLogs(from: loggingStore)
            return .none
        case .binding(\.isLoggingEnabled):
            loggingStore.isLoggingEnabled = state.isLoggingEnabled
            return .none
        case .binding,
             .destination:
            return .none
        }
    }

    var body: some ReducerOf<DebugLogsDomain> {
        BindingReducer()
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }
}

extension DebugLogsDomain {
    enum Dummies {
        static let state = State(logs: multiple)
        static let store = Store(
            initialState: state
        ) {
            DebugLogsDomain(loggingStore: DebugLiveLogger.shared)
        }

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
                    Bundle.module.url(
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
