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

import Foundation
import Network
import OSLog

extension Logger {
    static let bridgeClient = Logger(subsystem: "de.gematik.erp4ios.eRezept.tests.bridge-server", category: "eRpApp")
}

// Singleton class that connects to a port of a UITestBridgeServer and sends messages to the UITest
@MainActor
class UITestBridgeClient {
    private static let sharedInst = UITestBridgeClient()

    static func shared() -> UITestBridgeClient {
        sharedInst
    }

    private let connection: NWConnection

    private init() {
        connection = NWConnection(to: .hostPort(host: "localhost", port: 9999), using: .tcp)
        connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                Logger.bridgeClient.log(level: .debug, "Client connected to server")
            case let .failed(error):
                Logger.bridgeClient.log(level: .error, "Connection failed with error: \(error)")
            default:
                break
            }
        }
        connection.start(queue: .init(label: "UITestBridgeClient"))
    }

    func sendMessage(_ message: UITestBridgeMessage) {
        guard let message = try? JSONEncoder().encode(message) else {
            Logger.bridgeClient.log(level: .error, "Error encoding message")
            return
        }
        connection.send(content: message, completion: .contentProcessed { error in
            if let error = error {
                Logger.bridgeClient.log(level: .error, "Error sending message: \(error)")
            } else {
                Logger.bridgeClient.log(level: .debug, "Sent message: \(message)")
            }
        })
    }
}

enum UITestBridgeMessage: Codable {
    case hello
    case loginStatus(Bool)
    case scenarioStep(UInt)
}
