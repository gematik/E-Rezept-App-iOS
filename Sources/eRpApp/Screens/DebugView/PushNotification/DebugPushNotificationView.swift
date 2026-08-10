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

#if ENABLE_DEBUG_VIEW

import ComposableArchitecture
import eRpStyleKit
import HTTPClient
import HTTPClientLive
import OSLog
import SwiftUI

// swiftlint:disable:next type_body_length
struct DebugPushNotificationView: View {
    let store: StoreOf<DebugDomain>

    @State private var notificationPlainText = """
    {
        \"ChannelId\": \"erp.task.activate\",
        \"Identifier\": \"Task.identifier.PrescriptionID\",
        \"IdentifierType\": \"TaskId\"
    }
    """
    @State private var iss = "f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2"
    @State private var keyIdentifier: String = "123e4567-e89b-12d3-a456-426614174000"
    @State private var sendResult: String = ""
    @State private var isSending: Bool = false
    @State private var showScanPushCert = false

    /// push gateway URL
    @Shared(.pushGatewayURL) var pushGatewayURL
    /// mTLS client certificate (PEM)
    @Shared(.pushClientCertPEM) var clientCertPEM
    /// mTLS client private key (PEM)
    @Shared(.pushClientKeyPEM) var clientKeyPEM

    private var appIdentifier: String {
        "\(Bundle.main.bundleIdentifier ?? "dummy.app.identifier").apns"
    }

    private var notificationFD2Gateway: String {
        """
        {
          "notifications": [
            {
              "id": "debug_push_1",
              "notification": {
                "ciphertext": "\(store.encryptedCiphertext)",
                "time_message_encrypted": "\(store.timeMessageEncrypted)",
                "key_identifier": "\(keyIdentifier)",
                "prio": "high",
                "device": {
                  "app_id": "\(appIdentifier)",
                  "pushkey": "\(store.deviceToken)",
                  "pushkey_ts": \(Int(Date().timeIntervalSince1970)),
                  "data": {}
                }
              }
            }
          ]
        }
        """
    }

    private var notifyEndpoint: String {
        let base = pushGatewayURL.hasSuffix("/") ? String(pushGatewayURL.dropLast()) : pushGatewayURL
        return base + "/push/v1/notifyEncrypted/batch"
    }

    private var curlCommand: String {
        """
        curl -X POST \\
          '\(notifyEndpoint)' \\
          -H 'Content-Type: application/json' \\
          --cert <(printf '%s' '\(clientCertPEM)') --key <(printf '%s' '\(clientKeyPEM)') \\
          -d '\(notificationFD2Gateway)'
        """
    }

    var body: some View {
        List {
            apnsTokenSection
            payloadSection
            encryptSection
            pushConnectionSection
            fd2GatewayPayloadSection
            curlSection
            sendSection
        }
        .navigationTitle("Push Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var apnsTokenSection: some View {
        Section {
            Button("Request Permission & Register") {
                store.send(.requestPushPermissionAndRegister)

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM"
                let yearMonthNow = formatter.string(from: Date())

                store.send(.initializePushNotificationKeyChain(
                    iss: iss,
                    timeISSCreated: yearMonthNow,
                    keyIdentifier: keyIdentifier
                ))
            }
            .accessibilityIdentifier("debug_push_btn_register")

            if !store.deviceToken.isEmpty {
                HStack {
                    Text(store.deviceToken)
                        .font(.footnote.monospaced())
                        .lineLimit(3)
                        .accessibilityIdentifier("debug_push_txt_device_token")
                    Spacer()
                    Button {
                        UIPasteboard.general.string = store.deviceToken
                        Logger.eRpApp.debug("APNS device token copied to clipboard: \n\n \(store.deviceToken)")
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .accessibilityIdentifier("debug_push_btn_copy_device_token")
                }
            }

            if !store.tokenError.isEmpty {
                Text(store.tokenError)
                    .font(.footnote)
                    .foregroundColor(.red)
            }
        } header: {
            Text("APNS Device Token")
        } footer: {
            Text("Requests notification permission and registers for remote notifications. "
                + "The device token is captured from AppDelegate.")
        }
    }

    private var payloadSection: some View {
        Section {
            TextEditor(text: $notificationPlainText)
                .font(.body.monospacedDigit())
                .accessibilityIdentifier("debug_push_txt_plaintext")
        } header: {
            Text("Input")
        } footer: {
            Text("This plaintext is the payload of the notification that will be encrypted within `ciphertext`")
        }
    }

    private var encryptSection: some View {
        Section {
            Button("Encrypt Payload") {
                store.send(.encryptPushNotificationPayload(
                    plaintext: notificationPlainText,
                    keyIdentifier: keyIdentifier
                ))
            }
            .accessibilityIdentifier("debug_push_btn_encrypt")

            if !store.encryptedCiphertext.isEmpty {
                HStack {
                    Text(store.encryptedCiphertext)
                        .font(.footnote.monospaced())
                        .lineLimit(4)
                        .foregroundColor(.secondary)
                        .accessibilityIdentifier("debug_push_txt_ciphertext")
                    Spacer()
                    Button {
                        UIPasteboard.general.string = store.encryptedCiphertext
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .accessibilityIdentifier("debug_push_btn_copy_ciphertext")
                }

                LabeledContent("time_message_encrypted", value: store.timeMessageEncrypted)
                    .font(.footnote.monospaced())
            }
        } header: {
            Text("Encrypt")
        } footer: {
            Text("Encrypts the plaintext using AES/GCM with PNM1 framing and the latest stored key generation.")
        }
    }

    private var pushConnectionSection: some View {
        Section {
            Button {
                showScanPushCert = true
            } label: {
                HStack {
                    Text("Scan Gateway URL, Client Cert & Key")
                    Image(systemName: SFSymbolName.qrCode)
                }
            }
            .accessibilityIdentifier("debug_push_btn_scan_cert")
            .navigationDestination(isPresented: $showScanPushCert) {
                DebugPushCertScannerView(show: $showScanPushCert)
            }

            TextField("Push Gateway URL", text: Binding($pushGatewayURL))
                .font(.footnote.monospaced())
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .accessibilityIdentifier("debug_push_txt_gateway_url")

            VStack {
                TextEditor(text: Binding($clientKeyPEM))
                    .accessibility(identifier: "debug_push_txt_client_key")
                    .font(.footnote.monospaced())
                    .frame(minHeight: 100, maxHeight: 100)
                    .foregroundColor(Colors.systemLabel)
                    .border(Colors.separator)
                    .keyboardType(.default)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)

                FootnoteView(text: "Client Key (PEM)", a11y: "debug_push_client_key_footnote")
            }

            VStack {
                TextEditor(text: Binding($clientCertPEM))
                    .accessibility(identifier: "debug_push_txt_client_cert")
                    .font(.footnote.monospaced())
                    .frame(minHeight: 100, maxHeight: 100)
                    .foregroundColor(Colors.systemLabel)
                    .border(Colors.separator)
                    .keyboardType(.default)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)

                FootnoteView(text: "Client Certificate (PEM)", a11y: "debug_push_client_cert_footnote")
            }
        } header: {
            Text("Push Gateway Connection")
        } footer: {
            Text("Scan the gateway URL and the mTLS client key and certificate (PEM) via QR code. "
                + "A scanned value starting with http(s):// is treated as the URL, "
                + "a value shorter than 400 characters as the key, otherwise as the certificate. "
                + "Alternatively scan a single JSON QR code holding \"url\", \"crt_base64\" and "
                + "\"key_base64\" to populate all three fields at once. "
                + "These values are injected into the curl command below.")
        }
    }

    private var fd2GatewayPayloadSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                Text(notificationFD2Gateway)
                    .font(.footnote.monospaced())
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("Payload: Fachdienst → Push Gateway")
        } footer: {
            Button {
                UIPasteboard.general.string = notificationFD2Gateway
            } label: {
                Label("Copy to clipboard", systemImage: "doc.on.doc")
                    .font(.footnote)
            }
            .accessibilityIdentifier("debug_push_btn_copy_fd2_payload")
        }
    }

    private var curlSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                Text(curlCommand)
                    .font(.footnote.monospaced())
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("cURL Command (needs .crt and .key files)")
        } footer: {
            Button {
                UIPasteboard.general.string = curlCommand
                print("cURL command copied to clipboard: \n\n \(curlCommand)")
            } label: {
                Label("Copy to clipboard", systemImage: "doc.on.doc")
                    .font(.footnote)
            }
            .accessibilityIdentifier("debug_push_btn_copy_curl")
        }
    }

    private var canSend: Bool {
        !isSending
            && !pushGatewayURL.isEmpty
            && !clientCertPEM.isEmpty
            && !clientKeyPEM.isEmpty
    }

    private var sendSection: some View {
        Section {
            Button {
                Task { await sendPush() }
            } label: {
                HStack {
                    if isSending {
                        ProgressView()
                    }
                    Text(isSending ? "Sending…" : "Send Push Request")
                }
            }
            .disabled(!canSend)
            .accessibilityIdentifier("debug_push_btn_send")

            if !sendResult.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(sendResult)
                        .font(.footnote.monospaced())
                        .foregroundColor(.secondary)
                        .accessibilityIdentifier("debug_push_txt_send_result")
                }
            }
        } header: {
            Text("Send via mTLS")
        } footer: {
            Text("Sends the payload above to the gateway URL using the HTTP client with the scanned "
                + "client certificate and key for mutual TLS.")
        }
    }

    // MARK: - Actions

    private func sendPush() async {
        guard let url = URL(string: notifyEndpoint) else {
            sendResult = "Error: Invalid URL"
            return
        }
        guard let body = notificationFD2Gateway.data(using: .utf8) else {
            sendResult = "Error: Failed to encode payload"
            return
        }

        isSending = true
        sendResult = ""
        defer { isSending = false }

        let identity: SecIdentity
        do {
            identity = try DebugPushClientIdentity.makeIdentity(
                certPEM: clientCertPEM,
                keyPEM: clientKeyPEM
            )
        } catch {
            sendResult = "Error: \(error.localizedDescription)"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        let client = DefaultHTTPClient(
            urlSessionConfiguration: .ephemeral,
            clientIdentity: identity
        )

        do {
            let response = try await client.send(request: request)
            let responseBody = String(data: response.data, encoding: .utf8) ?? ""
            sendResult = "HTTP \(response.status.rawValue)\n\(responseBody)"
        } catch {
            sendResult = "Error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Helpers

private struct LabeledTextField: View {
    let label: String
    @Binding var text: String

    init(_ label: String, text: Binding<String>) {
        self.label = label
        _text = text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            TextField(label, text: $text)
                .font(.body.monospaced())
        }
    }
}

#Preview {
    NavigationStack {
        DebugPushNotificationView(store: DebugDomain.Dummies.store)
    }
}

#endif
