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

import Combine
import Foundation

/// VAU Storage protocol
public protocol VAUStorage {
    /// Retrieve a previously saved UserPseudonym
    ///
    /// [REQ:gemSpec_Krypt:A_20175]
    var userPseudonym: AnyPublisher<String?, Never> { get }

    /// Set and save a user pseudonym
    ///
    /// [REQ:gemSpec_Krypt:A_20175]
    ///
    /// - Parameter userPseudonym: value to save. Pass in nil to unset
    func set(userPseudonym: String?)
}

public class FileVAUStorage: VAUStorage {
    let userPseudonymFilePath: URL
    #if os(iOS)
    let writingOptions: Data.WritingOptions = [.atomicWrite, .completeFileProtectionUnlessOpen]
    #else
    // TODO: .completeFileProtectionUnlessOpen not available in macOS 10.15 // swiftlint:disable:this todo
    let writingOptions: Data.WritingOptions = [.atomicWrite]
    #endif

    public init(vauStorageBaseFilePath: URL) {
        userPseudonymFilePath = vauStorageBaseFilePath.appendingPathComponent("userPseudonym")
    }

    public var userPseudonym: AnyPublisher<String?, Never> {
        retrieveUserPseudonym()
    }

    public func set(userPseudonym: String?) {
        let success: Bool
        do {
            if let userPseudonym = userPseudonym {
                let writeResult = try Self.jsonEncoder.encode(userPseudonym)
                    .save(to: userPseudonymFilePath, options: writingOptions)
                switch writeResult {
                case .success: success = true
                case .failure: success = false
                }
            } else {
                try FileManager.default.removeItem(at: userPseudonymFilePath)
                success = true
            }
        } catch {
            success = false
        }
        if success {
            userPseudonymPassthrough.send(userPseudonym)
        }
    }

    private func retrieveUserPseudonym() -> AnyPublisher<String?, Never> {
        Deferred { [weak self] () -> AnyPublisher<String?, Never> in
            guard let self = self,
                  let userPseudonymData = try? Data(contentsOf: self.userPseudonymFilePath),
                  let userPseudonym = try? Self.jsonDecoder.decode(String.self, from: userPseudonymData)
            else {
                return Just(nil).eraseToAnyPublisher()
            }
            return Just(userPseudonym).eraseToAnyPublisher()
        }
        .merge(with: userPseudonymPassthrough)
        .eraseToAnyPublisher()
    }

    private let userPseudonymPassthrough = PassthroughSubject<String?, Never>()

    private static let jsonDecoder = JSONDecoder()

    private static let jsonEncoder = JSONEncoder()
}
