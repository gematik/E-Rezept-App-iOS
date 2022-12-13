//
//  Copyright (c) 2022 gematik GmbH
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

#if ENABLE_DEBUG_VIEW

import SwiftUI

struct EditUrlView: View {
    @Binding
    var endpoint: DebugPharmacy.Endpoint

    @State
    var error: Error?
    @State
    var httpStatusCode: Int?

    var body: some View {
        ScrollView {
            Text("URL:")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextEditor(text: $endpoint.url)
                .padding()
                .frame(minHeight: 100, maxHeight: .infinity)
                .foregroundColor(Colors.systemLabel)
                .keyboardType(.URL)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .font(.system(.footnote, design: .monospaced))
                .border(Colors.separator, width: 1.0, cornerRadius: 16)

            HStack {
                Text("Add Supported Placeholders: ")
                    .font(.footnote.bold())

                Button {
                    endpoint.url += "<ti_id>"
                } label: {
                    Text("<ti_id>")
                        .padding(4)
                        .background(Colors.primary)
                        .foregroundColor(Colors.systemColorWhite)
                        .cornerRadius(16)
                }

                Button {
                    endpoint.url += "<transactionID>"
                } label: {
                    Text("<transactionID>")
                        .padding(4)
                        .background(Colors.primary)
                        .foregroundColor(Colors.systemColorWhite)
                        .cornerRadius(16)
                }
            }
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("Additional Header:")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach($endpoint.additionalHeaders) { $header in
                HStack {
                    TextField("Key", text: $header.key)
                    TextField("Value", text: $header.value)
                }
            }

            HStack {
                Button {
                    endpoint.additionalHeaders.append(.init())
                } label: {
                    Text("Add")
                }

                Spacer()

                Button {
                    endpoint.additionalHeaders = endpoint.additionalHeaders.dropLast()
                } label: {
                    Text("Remove last")
                }
            }

            URLTester(url: $endpoint.url, headers: $endpoint.additionalHeaders)
        }
        .padding()
        .navigationTitle("URL")
    }
}

struct URLTester: View {
    class URLTesterViewModel: ObservableObject {
        var url: String = "" {
            didSet {
                isValidUrl = URL(string: sanatizedUrl) != nil
            }
        }

        var headers: [DebugPharmacy.Endpoint.Header] = []

        @Published
        var error: Error?
        @Published
        var httpStatusCode: Int?
        @Published
        var loading = false

        @Published
        var isValidUrl = true

        @Published
        var method: Method = .post

        enum Method: String {
            case post = "POST"
            case get = "GET"
        }

        var sanatizedUrl: String {
            url
                .replacingOccurrences(of: "<ti_id>", with: "%3Cti_id%3E")
                .replacingOccurrences(of: "<transactionID>", with: "%3CtransactionID%3E")
        }

        func test() {
            error = nil
            httpStatusCode = nil
            loading = false

            guard let url = URL(string: sanatizedUrl) else {
                return
            }

            loading = true

            var request = URLRequest(url: url)

            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
            request.httpMethod = method.rawValue
            let task = URLSession.shared.dataTask(with: request) { [weak self] _, urlresponse, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }

                    if let urlresponse = urlresponse as? HTTPURLResponse {
                        self.httpStatusCode = urlresponse.statusCode
                    }
                    self.error = error
                    self.loading = false
                }
            }
            task.resume()
        }
    }

    @StateObject
    var viewModel = URLTesterViewModel()

    @Binding var url: String
    @Binding var headers: [DebugPharmacy.Endpoint.Header]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Connectivity Test:")
                .font(.headline)

            HStack {
                Button {
                    viewModel.method = .post
                } label: {
                    if viewModel.method == .post {
                        Text("\(Image(systemName: SFSymbolName.checkmarkCircleFill)) POST")
                    } else {
                        Text("\(Image(systemName: SFSymbolName.circle)) POST")
                    }
                }

                Button {
                    viewModel.method = .get
                } label: {
                    if viewModel.method == .get {
                        Text("\(Image(systemName: SFSymbolName.checkmarkCircleFill)) GET")
                    } else {
                        Text("\(Image(systemName: SFSymbolName.circle)) GET")
                    }
                }
            }

            if viewModel.isValidUrl {
                Button {
                    viewModel.test()
                } label: {
                    Text("Start")
                }
                .buttonStyle(.primary)
            } else {
                Text("Ungültige URL, bitte URLEncoden sie alle Sonderzeichen abseits der vorgegebenen Platzhalter.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Colors.red600)
                    .font(.footnote)
            }

            if let error = viewModel.error {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fehler:")
                        .font(.callout)

                    Text(error.localizedDescription)
                        .font(.footnote)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .border(Colors.separator, width: 1.0, cornerRadius: 16)
            }

            if viewModel.loading {
                ProgressView()
            }

            if let statusCode = viewModel.httpStatusCode {
                Text("Response Code: '\(statusCode)'")
            }
        }
        .padding(.top)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            viewModel.url = url
            viewModel.headers = headers
        }
        .onChange(of: url) { newValue in
            viewModel.url = newValue
        }
        .onChange(of: headers) { newValue in
            viewModel.headers = newValue
        }
    }
}

struct EditUrlView_Previews: PreviewProvider {
    struct DynPreview: View {
        @State
        var endpoint = DebugPharmacy.Endpoint(
            url: "https://intern.gematik.de/url/test/preview",
            additionalHeaders: []
        )

        var body: some View {
            EditUrlView(endpoint: $endpoint)
        }
    }

    static var previews: some View {
        Group {
            DynPreview()
            DynPreview()
                .preferredColorScheme(.dark)
        }
    }
}

#endif
