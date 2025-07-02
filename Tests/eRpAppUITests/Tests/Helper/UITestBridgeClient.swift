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

import Foundation
import Network
import OSLog

extension Logger {
    static let bridgeClient = Logger(subsystem: "de.gematik.erp4ios.eRezept.tests.bridge-server", category: "eRpApp")
}

// Singleton class that connects to a port of a UITestBridgeServer and sends messages to the UITest
@MainActor
class UITestBridgeClient {
    private let connection: NWConnection
    private var isConnected = false

    init() {
        Logger.bridgeClient.log(level: .debug, "Init")
        connection = NWConnection(to: .hostPort(host: "localhost", port: 9999), using: .tcp)
        connection.stateUpdateHandler = { [weak self] newState in
            Task { @MainActor in
                self?.handleStateUpdate(newState)
            }
        }
        connection.start(queue: .init(label: "UITestBridgeClient"))
    }

    private func handleStateUpdate(_ newState: NWConnection.State) {
        switch newState {
        case .ready:
            Logger.bridgeClient.log(level: .debug, "Client connected to server")
            isConnected = true
        case let .failed(error):
            Logger.bridgeClient.log(level: .error, "Connection failed with error: \(error)")
            isConnected = false
        default:
            break
        }
    }

    func sendMessage(_ message: UITestBridgeMessage) async {
        Logger.bridgeClient.log(level: .debug, "Send")
        guard let messageData = try? JSONEncoder().encode(message) else {
            Logger.bridgeClient.log(level: .error, "Error encoding message")
            return
        }
        Logger.bridgeClient.log(level: .debug, "Wait for Connection")

        await waitForConnection()

        Logger.bridgeClient.log(level: .debug, "Connection established")

        do {
            try await send(data: messageData)
            Logger.bridgeClient.log(level: .debug, "Sent message: \(messageData)")
        } catch {
            Logger.bridgeClient.log(level: .error, "Error sending message: \(error)")
        }

        try! await Task.sleep(nanoseconds: 100_000_000)
    }

    private func waitForConnection() async {
        while !isConnected {
            try! await Task.sleep(nanoseconds: 100_000_000) // Sleep for 100 milliseconds
        }
    }

    private func send(data: Data) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            connection.send(content: data, completion: .contentProcessed { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            })
        }
    }
}

enum UITestBridgeMessage: Codable {
    case hello
    case loginStatus(Bool)
    case scenarioStep(UInt)
}
