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

import eRpStyleKit
import Sharing
import SwiftUI

/// Threshold used to decide whether a scanned PEM value is the client key or the client certificate.
/// A PEM-encoded EC/Brainpool private key is typically well below 400 characters, while a
/// certificate is considerably larger.
private let pushClientPEMKeyLengthThreshold = 400

struct DebugPushCertScannerView: View {
    @Binding var show: Bool

    /// mTLS client certificate (PEM)
    @Shared(.pushClientCertPEM) var pushClientCertPEM
    /// mTLS client private key (PEM)
    @Shared(.pushClientKeyPEM) var pushClientKeyPEM
    /// push gateway URL
    @Shared(.pushGatewayURL) var pushGatewayURL

    @State var validKeyFound = false
    @State var validCertFound = false
    @State var validURLFound = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AVScannerView(erxCodeTypes: [.qr, .dataMatrix],
                          supportedCodeTypes: [.qr, .dataMatrix],
                          scanning: show) { output in
                guard case let .text(scannedWrapped) = output.first,
                      let scanned = scannedWrapped?
                      .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                      !scanned.isEmpty
                else { return }

                let lowercased = scanned.lowercased()
                if applyCombinedConfig(from: scanned) {
                    return
                } else if lowercased.hasPrefix("http://") || lowercased.hasPrefix("https://") {
                    validURLFound = true
                    $pushGatewayURL.withLock { $0 = scanned }
                } else if scanned.count < pushClientPEMKeyLengthThreshold {
                    validKeyFound = true
                    $pushClientKeyPEM.withLock { $0 = scanned }
                } else {
                    validCertFound = true
                    $pushClientCertPEM.withLock { $0 = scanned }
                }
            }

            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: validURLFound ? SFSymbolName.checkmark : SFSymbolName.crossIcon)
                            .foregroundColor(validURLFound ? Colors.secondary600 : Colors.red700)
                        Text("Gateway URL")
                    }
                    .accessibilityIdentifier("debug_push_scanner_status_url")
                    HStack {
                        Image(systemName: validKeyFound ? SFSymbolName.checkmark : SFSymbolName.crossIcon)
                            .foregroundColor(validKeyFound ? Colors.secondary600 : Colors.red700)
                        Text("Client Key")
                    }
                    .accessibilityIdentifier("debug_push_scanner_status_key")
                    HStack {
                        Image(systemName: validCertFound ? SFSymbolName.checkmark : SFSymbolName.crossIcon)
                            .foregroundColor(validCertFound ? Colors.secondary600 : Colors.red700)
                        Text("Client Certificate")
                    }
                    .accessibilityIdentifier("debug_push_scanner_status_cert")
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)

                Button {
                    show = false
                } label: {
                    Text("Accept")
                }
                .accessibilityIdentifier("debug_push_scanner_btn_accept")
            }
            .padding()
        }
    }

    /// Attempts to interpret the scanned string as a combined push configuration JSON holding
    /// the gateway URL and the base64-encoded PEM client certificate and key. On success the
    /// present fields are populated at once. Returns `false` if the string is not such a JSON.
    private func applyCombinedConfig(from scanned: String) -> Bool {
        guard let data = scanned.data(using: .utf8),
              let config = try? JSONDecoder().decode(ScannedPushConfig.self, from: data),
              config.containsKnownField
        else { return false }

        if let url = config.url?.trimmingCharacters(in: .whitespacesAndNewlines), !url.isEmpty {
            validURLFound = true
            $pushGatewayURL.withLock { $0 = url }
        }
        if let key = Self.decodeBase64PEM(config.keyBase64) {
            validKeyFound = true
            $pushClientKeyPEM.withLock { $0 = key }
        }
        if let cert = Self.decodeBase64PEM(config.crtBase64) {
            validCertFound = true
            $pushClientCertPEM.withLock { $0 = cert }
        }
        return true
    }

    /// Decodes a base64 string into a UTF-8 PEM string. Returns `nil` if the input is missing
    /// or cannot be decoded.
    private static func decodeBase64PEM(_ base64: String?) -> String? {
        guard let base64 = base64?.trimmingCharacters(in: .whitespacesAndNewlines),
              !base64.isEmpty,
              let data = Data(base64Encoded: base64),
              let pem = String(data: data, encoding: .utf8)
        else { return nil }
        return pem
    }
}

/// Combined push configuration that can be encoded in a single QR code to populate the
/// gateway URL, the client certificate and the client key at once.
private struct ScannedPushConfig: Decodable {
    let url: String?
    let crtBase64: String?
    let keyBase64: String?

    enum CodingKeys: String, CodingKey {
        case url
        case crtBase64 = "crt_base64"
        case keyBase64 = "key_base64"
    }

    var containsKnownField: Bool {
        url != nil || crtBase64 != nil || keyBase64 != nil
    }
}

extension SharedReaderKey
    where Self == AppStorageKey<String>.Default {
    /// mTLS client certificate (PEM) used by the debug push notification curl command
    static var pushClientCertPEM: Self {
        Self[.appStorage(.kPushClientCertPEMKey), default: ""]
    }

    /// mTLS client private key (PEM) used by the debug push notification curl command
    static var pushClientKeyPEM: Self {
        Self[.appStorage(.kPushClientKeyPEMKey), default: ""]
    }

    /// push gateway URL used by the debug push notification curl command
    static var pushGatewayURL: Self {
        Self[
            .appStorage(.kPushGatewayURLKey),
            default: "https://push-gateway.example.gematik.solutions/notifications"
        ]
    }
}

extension String {
    static let kPushClientCertPEMKey = "kPushClientCertPEM"
    static let kPushClientKeyPEMKey = "kPushClientKeyPEM"
    static let kPushGatewayURLKey = "kPushGatewayURL"
}

#endif
