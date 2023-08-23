//
//  Copyright (c) 2023 gematik GmbH
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

/// Represents a scanned eRx task holding the information of its ID and accessCode
public struct ScannedErxTask: Identifiable, Hashable {
    /// Id of the task
    public let id: String

    /// Access code authorizing for the task
    public let accessCode: String

    private static let taskIdPattern = "^Task\\/([A-Za-z0-9-.]{1,64})\\/"
    private static let taskIdRegex = {
        try! NSRegularExpression(pattern: taskIdPattern) // swiftlint:disable:this force_try
    }()

    private static let accessCodePattern = "([0-9a-fA-F]{64})$"
    private static let accessCodeRegex = {
        try! NSRegularExpression(pattern: accessCodePattern) // swiftlint:disable:this force_try
    }()

    private static let taskStringPattern = "\(taskIdPattern)\\$accept\\?ac=\(accessCodePattern)"
    private static let taskStringRegex = {
        try! NSRegularExpression(pattern: taskStringPattern) // swiftlint:disable:this force_try
    }()

    init(id: String, accessCode: String) {
        self.id = id
        self.accessCode = accessCode
    }

    /// Initialize with an URL token
    /// e.g. "Task/4711/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"
    /// - Parameter taskString: URL token string conforming to specification "Datenmodell E-Rezept"
    public init(taskString: String) throws {
        // check validity
        guard Self.taskStringRegex.numberOfMatches(
            in: taskString,
            range: NSRange(location: 0, length: taskString.count)
        ) == 1 else {
            throw Error.format
        }

        // [REQ:gemSpec_eRp_FdV:A_19984] parse task id and access code
        guard let taskId = taskString.match(pattern: Self.taskIdRegex) else {
            throw Error.invalidID
        }
        guard let accessCode = taskString.match(pattern: Self.accessCodeRegex) else {
            throw Error.invalidAccessCode
        }
        self.init(id: taskId, accessCode: accessCode)
    }
}

extension ScannedErxTask {
    // sourcery: CodedError = "205"
    /// Error cases for the ScannedErxTask
    public enum Error: Swift.Error, LocalizedError, Equatable {
        // sourcery: errorCode = "01"
        case format
        // sourcery: errorCode = "02"
        case invalidID
        // sourcery: errorCode = "03"
        case invalidAccessCode
        // sourcery: errorCode = "04"
        case invalidJSON(Swift.Error)

        public var errorDescription: String? {
            switch self {
            case .invalidID, .format, .invalidAccessCode, .invalidJSON:
                return NSLocalizedString("scn_msg_scanned_code_failed", comment: "")
            }
        }

        public static func ==(lhs: ScannedErxTask.Error, rhs: ScannedErxTask.Error) -> Bool {
            switch (lhs, rhs) {
            case (format, format): return true
            case (invalidID, invalidID): return true
            case (invalidAccessCode, invalidAccessCode): return true
            default: return false
            }
        }
    }

    /// Initialize from an json of (an array of) URL tokens of form
    ///  {"urls": ["Task/4711/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"]}
    /// - Parameter tasks: token of above mentioned form
    /// - Returns: Array of `ScannedErxTask`s parsed from given URLs.
    public static func from(
        tasks codeContent: String,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) throws -> [ScannedErxTask] {
        guard let jsonData = codeContent.data(using: .utf8) else {
            throw Error.format
        }
        var erxToken: ErxToken
        do {
            // [REQ:gemSpec_eRp_FdV:A_19984] validate data matrix code structure
            // [REQ:BSI-eRp-ePA:O.Source_1#4] actual validation by decoding into predefined structure
            erxToken = try jsonDecoder.decode(ErxToken.self, from: jsonData)
        } catch {
            if let url = URL(string: codeContent),
               let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
               let fragment = components.fragment?.data(using: .utf8),
               let codes = try? jsonDecoder.decode([SharedTask].self, from: fragment) {
                return codes.compactMap { ScannedErxTask(id: $0.id, accessCode: $0.accessCode) }
            }
            throw Error.invalidJSON(error)
        }
        return try erxToken.urls.compactMap(ScannedErxTask.init)
    }
}

private struct ErxToken: Decodable {
    let urls: [String]
}

extension String {
    func match(pattern: NSRegularExpression) -> String? {
        guard let match = pattern.firstMatch(
            in: self,
            options: [],
            range: NSRange(location: 0, length: count)
        ) else {
            return nil
        }

        let taskIdRange = match.range(at: 1)
        return (self as NSString).substring(with: taskIdRange)
    }
}
