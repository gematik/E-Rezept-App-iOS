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

import Combine
import Foundation

/// TrustStore storage protocol
public protocol TrustStoreStorage {
    /// Retrieve a previously saved TrustStore CertList
    var certList: AnyPublisher<CertList?, Never> { get }

    /// Set and save the TrustStore CertList
    ///
    /// - Parameter certList: CertList of certificates to save. Pass in nil to unset.
    func set(certList: CertList?)

    /// Retrieve a previously saved OCSPList
    var ocspList: AnyPublisher<OCSPList?, Never> { get }

    /// Set and save the TrustStore OCSPList
    ///
    /// - Parameter ocspList: OCSPList to save. Pass in nil to unset.
    func set(ocspList: OCSPList?)
}

public class TrustStoreFileStorage: TrustStoreStorage {
    let certListFilePath: URL
    let ocspListFilePath: URL
    #if os(iOS)
    let writingOptions: Data.WritingOptions = [.atomicWrite, .completeFileProtectionUnlessOpen]
    #else
    // TODO: .completeFileProtectionUnlessOpen not available in macOS 10.15 // swiftlint:disable:this todo
    let writingOptions: Data.WritingOptions = [.atomicWrite]
    #endif

    public init(trustStoreStorageBaseFilePath: URL) {
        certListFilePath = trustStoreStorageBaseFilePath.appendingPathComponent("trustStoreCertList")
        ocspListFilePath = trustStoreStorageBaseFilePath.appendingPathComponent("trustStoreOCSPList")
    }

    public var certList: AnyPublisher<CertList?, Never> {
        retrieveCertList()
    }

    public func set(certList: CertList?) {
        let success: Bool
        do {
            if let certList = certList {
                let writeResult = try Self.jsonEncoder.encode(certList)
                    .save(to: certListFilePath, options: writingOptions)
                switch writeResult {
                case .success: success = true
                case .failure: success = false
                }
            } else {
                try FileManager.default.removeItem(at: certListFilePath)
                success = true
            }
        } catch {
            success = false
        }
        if success {
            certListPassthrough.send(certList)
        }
    }

    private let certListPassthrough = PassthroughSubject<CertList?, Never>()

    private func retrieveCertList() -> AnyPublisher<CertList?, Never> {
        Deferred { [weak self] () -> AnyPublisher<CertList?, Never> in
            guard let self = self,
                  let certListData = try? Data(contentsOf: self.certListFilePath),
                  let certList = try? Self.jsonDecoder.decode(CertList.self, from: certListData)
            else {
                return Just(nil).eraseToAnyPublisher()
            }
            return Just(certList).eraseToAnyPublisher()
        }
        .merge(with: certListPassthrough)
        .eraseToAnyPublisher()
    }

    public var ocspList: AnyPublisher<OCSPList?, Never> {
        retrieveOCSPList()
    }

    public func set(ocspList: OCSPList?) {
        let success: Bool
        do {
            if let ocspList = ocspList {
                let writeResult = try Self.jsonEncoder.encode(ocspList)
                    .save(to: ocspListFilePath, options: writingOptions)
                switch writeResult {
                case .success: success = true
                case .failure: success = false
                }
            } else {
                try FileManager.default.removeItem(at: ocspListFilePath)
                success = true
            }
        } catch {
            success = false
        }
        if success {
            ocspListPassthrough.send(ocspList)
        }
    }

    private let ocspListPassthrough = PassthroughSubject<OCSPList?, Never>()

    private func retrieveOCSPList() -> AnyPublisher<OCSPList?, Never> {
        Deferred { [weak self] () -> AnyPublisher<OCSPList?, Never> in
            guard let self = self,
                  let data = try? Data(contentsOf: self.ocspListFilePath),
                  let ocspList = try? Self.jsonDecoder.decode(OCSPList.self, from: data)
            else {
                return Just(nil).eraseToAnyPublisher()
            }
            return Just(ocspList).eraseToAnyPublisher()
        }
        .merge(with: ocspListPassthrough)
        .eraseToAnyPublisher()
    }

    private static let jsonDecoder = JSONDecoder()

    private static let jsonEncoder = JSONEncoder()
}
