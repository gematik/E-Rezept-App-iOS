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

import eRpKit
import Foundation
import ModelsR4

extension ModelsR4.Bundle {
    /// Parse and extract all found ErxTaskCommunications from `Self`
    ///
    /// - Returns: Array with all found and parsed communications
    /// - Throws: `ModelsR4.Bundle.Error`
    func parseErxTaskCommunications() throws -> [ErxTask.Communication] {
        try entry?.compactMap {
            guard let communication = $0.resource?.get(if: ModelsR4.Communication.self) else {
                return nil
            }
            return try Self.parse(communication, from: self)
        } ?? []
    }

    static func parse(_ communication: ModelsR4.Communication,
                      from _: ModelsR4.Bundle) throws -> ErxTask.Communication? {
        guard let identifier = communication.id?.value?.string else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse id from communication.")
        }

        guard let profileUrl = communication.meta?.profile?.first?.value?.url.absoluteString,
              let profile = ErxTask.Communication.Profile(rawValue: profileUrl) else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse the communication profile")
        }

        guard let reference = communication.basedOn?.first?.reference?.value?.string,
              let task = TaskCheck(taskString: reference) else {
            throw RemoteStorageBundleParsingError
                .parseError("Could not parse reference or extract task id and access code from communication.")
        }

        guard let telematikId = communication.telematikId(for: profile) else {
            return nil
        }

        guard let userKVID = communication.kvID(for: profile) else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse userKVID from communication")
        }

        guard let timestamp = communication.sent?.value?.description else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse sent value from communication")
        }

        guard let payloadContent = communication.payloadContent else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse payload value from communication")
        }

        return ErxTask.Communication(
            identifier: identifier,
            profile: profile,
            taskId: task.id,
            userId: userKVID,
            telematikId: telematikId,
            orderId: communication.orderId,
            timestamp: timestamp,
            payloadJSON: payloadContent,
            isRead: false
        )
    }
}

extension ModelsR4.Communication {
    func telematikId(for profile: ErxTask.Communication.Profile) -> String? {
        switch profile {
        case .reply:
            if Workflow.Key.telematikIdKeys.contains(
                where: { $0.value == sender?.identifier?.system?.value?.url.absoluteString }
            ) {
                return sender?.identifier?.value?.value?.string
            }
        case .dispReq:
            return recipient?.first { recipient in
                Workflow.Key.telematikIdKeys.contains {
                    $0.value == recipient.identifier?.system?.value?.url.absoluteString
                }
            }?.identifier?.value?.value?.string
        case .infoReq, .representative, .none, .all:
            return nil
        }

        return nil
    }

    func kvID(for profile: ErxTask.Communication.Profile) -> String? {
        switch profile {
        case .reply:
            return recipient?.first { recipient in
                Workflow.Key.kvIDKeys.contains {
                    $0.value == recipient.identifier?.system?.value?.url.absoluteString
                }
            }?.identifier?.value?.value?.string
        case .dispReq:
            if Workflow.Key.kvIDKeys.contains(
                where: { $0.value == sender?.identifier?.system?.value?.url.absoluteString }
            ) {
                return sender?.identifier?.value?.value?.string
            }
        case .infoReq, .representative, .none, .all:
            return nil
        }
        return nil
    }

    var orderId: String? {
        identifier?.first { identifier in
            Workflow.Key.orderIdKeys.contains {
                $0.value == identifier.system?.value?.url.absoluteString
            }
        }?.value?.value?.string
    }

    var payloadContent: String? {
        payload?.compactMap { payload -> String? in
            if case let .string(value) = payload.content,
               let content = value.value?.string {
                return content
            } else {
                return nil
            }
        }.first
    }
}

extension ErxTask.Communication.Profile {
    init?(rawValue: RawValue) {
        switch rawValue {
        case Workflow.Key.communicationReply[.v1_1_1],
             Workflow.Key.communicationReply[.v1_2_0]:
            self = .reply
        case Workflow.Key.communicationDispReq[.v1_1_1],
             Workflow.Key.communicationDispReq[.v1_2_0]:
            self = .dispReq
        case Workflow.Key.communicationInfoReq[.v1_1_1],
             Workflow.Key.communicationInfoReq[.v1_2_0]:
            self = .infoReq
        case Workflow.Key.communicationRepresentative[.v1_1_1],
             Workflow.Key.communicationRepresentative[.v1_2_0]:
            self = .representative
        default:
            self = .none
        }
    }
}

private struct TaskCheck: Identifiable, Hashable {
    /// Id of the task
    let id: String
    /// Access code authorizing for the task
    let accessCode: String?

    private static let taskIdPattern = "^Task\\/([A-Za-z0-9-.]{1,64})"
    private static let taskIdRegex = {
        try! NSRegularExpression(pattern: taskIdPattern) // swiftlint:disable:this force_try
    }()

    private static let accessCodePattern = "([0-9a-fA-F]{64})$"
    private static let accessCodeRegex = {
        try! NSRegularExpression(pattern: accessCodePattern) // swiftlint:disable:this force_try
    }()

    private static let taskStringPattern = "\(taskIdPattern)\\/\\$accept\\?ac=\(accessCodePattern)"
    private static let taskStringRegex = {
        try! NSRegularExpression(pattern: taskStringPattern) // swiftlint:disable:this force_try
    }()

    /// Initialize with an URL token. The initializer accepts one of the two formats:
    /// (1)     `Task/4711/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea`
    /// (2)       `Task/4711`
    ///
    /// - Parameter taskString:String that containing taskID and potentially accessCode
    init?(taskString: String) {
        guard Self.taskStringRegex.numberOfMatches(
            in: taskString,
            range: NSRange(location: 0, length: taskString.count)
        ) == 1 else {
            guard let taskId = taskString.match(pattern: Self.taskIdPattern) else { return nil }
            id = taskId
            accessCode = nil
            return
        }

        guard let taskId = taskString.match(pattern: Self.taskIdPattern) else { return nil }
        id = taskId
        accessCode = taskString.match(pattern: Self.accessCodePattern)
    }
}
