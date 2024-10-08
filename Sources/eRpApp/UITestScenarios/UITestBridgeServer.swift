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

#if DEBUG

import Dependencies
import Foundation
import Network
import OSLog

extension Logger {
    static let bridgeServer = Logger(subsystem: "de.gematik.erp4ios.eRezept.tests.bridge-server", category: "eRpApp")
}

// Singleton class that openes a port any UITest can connect to and send messages to the app
class UITestBridgeServer {
    private static var sharedInst: UITestBridgeServer?

    static func shared() throws -> UITestBridgeServer {
        if let sharedInst {
            return sharedInst
        }
        let inst = try UITestBridgeServer()
        sharedInst = inst
        return inst
    }

    private let listener: NWListener

    private init() throws {
        Logger.bridgeServer.debug("Message Bridge Server: Init")

        listener = try NWListener(using: .tcp, on: 9999)
        listener.newConnectionHandler = { [weak self] connection in
            Logger.bridgeServer.log(level: .debug, "New Connection")
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    self?.addReceive(connection: connection)
                default:
                    break
                }
            }
            connection.start(queue: .main)
        }
        listener.stateUpdateHandler = { state in
            switch state {
            case .ready:
                Logger.bridgeServer.log(level: .debug, "Listener ready")
            case let .failed(error):
                Logger.bridgeServer.log(level: .error, "Listener failed with error: \(error)")
            default:
                break
            }
        }
        listener.start(queue: .main)
    }

    func addReceive(connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65535) { [weak self] data, _, isComplete, error in
            if let data = data,
               !data.isEmpty {
                if let message = try? JSONDecoder().decode(UITestBridgeMessage.self, from: data) {
                    Logger.bridgeServer.log(level: .debug, "Received message: \(message)")
                    self?.handleMessage(message)
                } else {
                    Logger.bridgeServer.log(level: .error, "Error decoding message")
                }
            }
            if isComplete {
                connection.cancel()
            } else if let error = error {
                Logger.bridgeServer.log(level: .error, "Error receiving data: \(error)")
            } else {
                self?.addReceive(connection: connection)
            }
        }
    }

    func handleMessage(_ message: UITestBridgeMessage) {
        @Dependency(\.smartMockState) var smartMockState
        switch message {
        case .hello:
            break
        case let .loginStatus(loginStatus):
            smartMockState.setLoginStatus(loginStatus)
        case let .scenarioStep(step):
            smartMockState.setStep(Int(step))
        }
    }
}

enum UITestBridgeMessage: Codable, CustomStringConvertible {
    var description: String {
        switch self {
        case .hello:
            return "hello"
        case let .loginStatus(status):
            return "loginStatus(\(status))"
        case let .scenarioStep(step):
            return "scenarioStep(\(step))"
        }
    }

    case hello
    case loginStatus(Bool)
    case scenarioStep(UInt)
}

#endif
