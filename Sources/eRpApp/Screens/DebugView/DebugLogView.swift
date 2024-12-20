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

import ComposableArchitecture
import eRpStyleKit
import Foundation
import Perception
import SwiftUI

#if ENABLE_DEBUG_VIEW
struct DebugLogView: View {
    @Perception.Bindable var store: StoreOf<DebugLogDomain>

    var body: some View {
        WithPerceptionTracking {
            List {
                if store.log.responseStatus == .debug {
                    Text(
                        """
                        This request only exists locally. The request body is decrypted
                        for debug purposes. Date and header fields can be different from the
                        original request.
                        """
                    )
                    .foregroundColor(Color.purple)
                }
                Text(store.log.id.uuidString)

                Section(header: Text("Request")) {
                    if let method = store.log.request.httpMethod {
                        HStack {
                            Text("Method")
                                .font(.headline)
                            Spacer()
                            Text(method)
                                .font(.system(.body, design: .monospaced))
                        }
                    }

                    HStack {
                        Text("URL")
                            .font(.headline)
                        Spacer()
                        Text(store.log.requestUrl)
                            .font(.system(.body, design: .monospaced))
                    }.contextMenu(ContextMenu {
                        Button("Copy") {
                            UIPasteboard.general.string = store.log.requestUrl
                        }
                    })

                    LongProperty(title: "Request Body", text: store.log.requestBody)
                        .contextMenu(ContextMenu {
                            Button("Copy") {
                                UIPasteboard.general.string = store.log.requestBody
                            }
                        })

                    Text("HTTP Header:")
                        .font(.headline)

                    ForEach(store.log.requestHeader.keys.sorted(), id: \.self) { key in
                        WithPerceptionTracking {
                            VStack(alignment: .leading) {
                                Text("\(key):")
                                    .font(.system(.subheadline, design: .monospaced))
                                Text(store.log.requestHeader[key] ?? "unset")
                                    .font(.system(.body, design: .monospaced))
                                    .multilineTextAlignment(.trailing)
                                    .contextMenu(ContextMenu {
                                        Button("Copy") {
                                            UIPasteboard.general.string = store.log.requestHeader[key]
                                        }
                                    })
                            }
                        }
                    }
                }

                Section(header: Text("Response")) {
                    HStack {
                        Text("Status Code")
                            .font(.headline)
                        Spacer()
                        Text("\(store.log.responseStatus?.rawValue ?? -1)")
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(store.log.responseStatus?.isSuccessful ?? false ? .green : .red)
                    }

                    LongProperty(title: "Response Body", text: store.log.responseBody)
                        .contextMenu(ContextMenu {
                            Button("Copy") {
                                UIPasteboard.general.string = store.log.responseBody
                            }
                        })
                    Text("HTTP Header:")
                        .font(.headline)

                    LazyVGrid(columns: [
                        GridItem(
                            .flexible(minimum: 100, maximum: .infinity),
                            spacing: 8,
                            alignment: .topLeading
                        ),
                        GridItem(
                            .flexible(minimum: 100, maximum: .infinity),
                            spacing: 8,
                            alignment: .topTrailing
                        ),
                    ], spacing: 8) {
                        ForEach(
                            store.log.responseHeader.keys.compactMap { $0 as? String }.sorted(),
                            id: \.self
                        ) { key in
                            Text("\(key):")
                                .font(.system(.body, design: .monospaced))
                            Text(store.log.responseHeader[key] as? String ?? "unset")
                                .multilineTextAlignment(.trailing)
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                }
            }
            .sheet(item: $store
                .scope(state: \.destination?.share,
                       action: \.destination.share)) { store in
                    ShareViewController(store: store)
            }
            .navigationTitle("Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        action: { store.send(.share) },
                        label: { Image(systemName: "square.and.arrow.up") }
                    )
                }
            }
        }
    }

    struct LongProperty: View {
        let title: String
        let text: String

        var detailed: Bool {
            text.lengthOfBytes(using: .utf8) > 20
        }

        var body: some View {
            VStack(alignment: .leading) {
                if detailed {
                    Text(title)
                        .font(.headline)
                    TextEditor(text: .constant(text))
                        .foregroundColor(Colors.systemLabel)
                        .font(.system(.footnote, design: .monospaced))
                        .background(Colors.systemGray5)
                        .frame(minHeight: 100, maxHeight: 300)
                        .border(Color.black, width: 1)
                        .listRowBackground(Colors.systemGray5)

                } else {
                    HStack {
                        Text(title)
                            .font(.headline)
                        Spacer()
                        Text(text)
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
            .listRowBackground(detailed ? Colors.backgroundSecondary : Colors.backgroundNeutral)
        }
    }
}

struct DebugLogView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                DebugLogView(store: .init(initialState: .init(log: DebugLogsDomain.Dummies.log4)) {
                    DebugLogDomain()
                })
            }
        }
    }
}
#endif
