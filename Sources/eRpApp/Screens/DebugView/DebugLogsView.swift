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
import eRpStyleKit
import HTTPClient
import Perception
import SwiftUI

#if ENABLE_DEBUG_VIEW
struct DebugLogsView: View {
    @Perception.Bindable var store: StoreOf<DebugLogsDomain>
    @State var showShareSheet = false

    func background(for log: DebugLiveLogger.RequestLog) -> Color {
        guard let statusCode = log.responseStatus?.rawValue else {
            return Colors.backgroundNeutral
        }
        switch statusCode {
        case -100 ..< 0:
            return Colors.systemGray5
        case 300 ..< 400:
            return Colors.yellow200
        case 400 ..< 500:
            return Colors.red200
        case 500 ..< 600:
            return Colors.primary200
        default:
            return Colors.backgroundNeutral
        }
    }

    var body: some View {
        WithPerceptionTracking {
            List {
                Section(header: Text("Sort/Filter")) {
                    Toggle("Logging enabled", isOn: $store.isLoggingEnabled)

                    if !store.logs.isEmpty {
                        HStack {
                            Text("Reset Log Messages")
                            Spacer()
                            Button("Reset") {
                                store.send(.resetLogMessages, animation: .easeInOut)
                            }
                        }
                    }

                    TextField("Filter Domain", text: $store.filter)
                    Picker("Sortierung", selection: $store.sort) {
                        ForEach(DebugLogsDomain.State.Sort.allCases, id: \.id) { sortMethod in
                            Text(sortMethod.rawValue).tag(sortMethod)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Logs")) {
                    ForEach(store.logs) { log in
                        WithPerceptionTracking {
                            Button {
                                store.send(.showSingleLog(log))
                            } label: {
                                LogHeader(log: log)
                            }
                            .listRowBackground(self.background(for: log))
                        }
                    }
                }
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.logDetail, action: \.destination.logDetail)
            ) { store in
                DebugLogView(store: store)
            }
            .sheet(item: $store
                .scope(state: \.destination?.share,
                       action: \.destination.share)) { store in
                    ShareViewController(store: store)
            }
            .onAppear {
                store.send(.loadLogs)
            }
        }
        .navigationTitle("Logs")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    action: { store.send(.share) },
                    label: { Image(systemName: "square.and.arrow.up") }
                )
            }
        }
    }

    struct LogHeader: View {
        let log: DebugLiveLogger.RequestLog

        static var uiDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateStyle = .none
            formatter.timeStyle = .medium
            formatter.doesRelativeDateFormatting = false
            return formatter
        }()

        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    if log.responseStatus == .debug {
                        Text("Copy")
                    } else {
                        Text("\(log.responseStatus?.rawValue ?? -1)")
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(log.responseStatus?.isSuccessful ?? false ? .green : .red)
                    }

                    if let method = log.request.httpMethod {
                        Text("\(method) \(log.requestUrl)")
                            .font(.headline)
                    } else {
                        Text(log.requestUrl)
                            .font(.headline)
                    }
                }

                HStack {
                    Text(DebugLogsView.LogHeader.uiDateFormatter.string(from: log.sentAt))
                    Spacer()
                    Text(DebugLogsView.LogHeader.uiDateFormatter.string(from: log.receivedAt))
                }
                .font(.footnote)
            }
        }
    }
}

struct DebugLogsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DebugLogsView(store: DebugLogsDomain.Dummies.store)
        }
    }
}
#endif
