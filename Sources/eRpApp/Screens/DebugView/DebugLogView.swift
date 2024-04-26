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

import eRpStyleKit
import Foundation
import SwiftUI

#if ENABLE_DEBUG_VIEW
struct DebugLogView: View {
    @State var showShareSheet = false
    let log: DebugLiveLogger.RequestLog

    var body: some View {
        List {
            if log.responseStatus == .debug {
                Text(
                    """
                    This request only exists locally. The request body is decrypted
                    for debug purposes. Date and header fields can be different from the
                    original request.
                    """
                )
                .foregroundColor(Color.purple)
            }
            Text(log.id.uuidString)

            Section(header: Text("Request")) {
                HStack {
                    Text("URL")
                        .font(.headline)
                    Spacer()
                    Text(log.requestUrl)
                        .font(.system(.body, design: .monospaced))
                }.contextMenu(ContextMenu {
                    Button("Copy") {
                        UIPasteboard.general.string = log.requestUrl
                    }
                })

                LongProperty(title: "Request Body", text: log.requestBody)
                    .contextMenu(ContextMenu {
                        Button("Copy") {
                            UIPasteboard.general.string = log.requestBody
                        }
                    })

                Text("HTTP Header:")
                    .font(.headline)

                ForEach(log.requestHeader.keys.sorted(), id: \.self) { key in
                    VStack(alignment: .leading) {
                        Text("\(key):")
                            .font(.system(.subheadline, design: .monospaced))
                        Text(log.requestHeader[key] ?? "unset")
                            .font(.system(.body, design: .monospaced))
                            .multilineTextAlignment(.trailing)
                            .contextMenu(ContextMenu {
                                Button("Copy") {
                                    UIPasteboard.general.string = log.requestHeader[key]
                                }
                            })
                    }
                }
            }

            Section(header: Text("Response")) {
                HStack {
                    Text("Status Code")
                        .font(.headline)
                    Spacer()
                    Text("\(log.responseStatus?.rawValue ?? -1)")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(log.responseStatus?.isSuccessful ?? false ? .green : .red)
                }

                LongProperty(title: "Response Body", text: log.responseBody)
                    .contextMenu(ContextMenu {
                        Button("Copy") {
                            UIPasteboard.general.string = log.responseBody
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
                    ForEach(log.responseHeader.keys.compactMap { $0 as? String }.sorted(), id: \.self) { key in
                        Text("\(key):")
                            .font(.system(.body, design: .monospaced))
                        Text(log.responseHeader[key] as? String ?? "unset")
                            .multilineTextAlignment(.trailing)
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareViewController(itemsToShare: [log.shareText])
        }
        .navigationTitle("Logs")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    action: { showShareSheet = true },
                    label: { Image(systemName: "square.and.arrow.up") }
                )
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
            NavigationView {
                DebugLogView(log: DebugLogDomain.Dummies.log4)
            }
        }
    }
}
#endif
