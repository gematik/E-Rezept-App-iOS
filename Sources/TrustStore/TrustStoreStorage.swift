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

    /// Retrieve the previously saved PKICertificates
    func getPKICertificates() -> PKICertificates?

    /// Set and save the TrustStore PKICertificates
    ///
    /// - Parameter pkiCertificates: PKICertificates to save. Pass in nil to unset.
    func set(pkiCertificates: PKICertificates?)

    /// Retrieve the previously saved VAU certificate
    func getVauCertificate() -> Data?

    /// Set and save the VAU certificate
    ///
    /// - Parameter vauCertificate: Data of the VAU certificate to save. Pass in nil
    func set(vauCertificate: Data?)

    /// Retrieve the previously saved OCSP response for the VAU certificate
    func getVauCertificateOcspResponse() -> Data?

    /// Set and save the OCSP response for the VAU certificate
    ///
    /// - Parameter vauCertificateOcspResponse: Data of the OCSP response to save. Pass in nil
    func set(vauCertificateOcspResponse: Data?)
}

public class TrustStoreFileStorage: TrustStoreStorage {
    let certListFilePath: URL
    let ocspListFilePath: URL
    let pkiCertificatesFilePath: URL
    let vauCertificateFilePath: URL
    let vauCertificateOcspResponseFilePath: URL
    let writingOptions: Data.WritingOptions = [.atomicWrite, .completeFileProtectionUnlessOpen]

    public init(trustStoreStorageBaseFilePath: URL) {
        certListFilePath = trustStoreStorageBaseFilePath.appendingPathComponent("trustStoreCertList")
        ocspListFilePath = trustStoreStorageBaseFilePath.appendingPathComponent("trustStoreOCSPList")
        pkiCertificatesFilePath = trustStoreStorageBaseFilePath.appendingPathComponent("trustStorePKICertificates")
        vauCertificateFilePath = trustStoreStorageBaseFilePath.appendingPathComponent("vauCertificate")
        vauCertificateOcspResponseFilePath = trustStoreStorageBaseFilePath
            .appendingPathComponent("vauCertificateOcspResponse")
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

    public func getPKICertificates() -> PKICertificates? {
        guard let data = try? Data(contentsOf: pkiCertificatesFilePath),
              let pkiCertificates = try? Self.jsonDecoder.decode(PKICertificates.self, from: data)
        else {
            return nil
        }
        return pkiCertificates
    }

    public func set(pkiCertificates: PKICertificates?) {
        do {
            if let pkiCertificates {
                _ = try Self.jsonEncoder.encode(pkiCertificates)
                    .save(to: pkiCertificatesFilePath, options: writingOptions)
            } else {
                try FileManager.default.removeItem(at: pkiCertificatesFilePath)
            }
        } catch {
            // no feedback
        }
    }

    public func getVauCertificate() -> Data? {
        guard let data = try? Data(contentsOf: vauCertificateFilePath) else {
            return nil
        }
        return data
    }

    public func set(vauCertificate: Data?) {
        do {
            if let vauCertificate {
                _ = vauCertificate.save(to: vauCertificateFilePath, options: writingOptions)
            } else {
                try FileManager.default.removeItem(at: vauCertificateFilePath)
            }
        } catch {
            // no feedback
        }
    }

    public func getVauCertificateOcspResponse() -> Data? {
        guard let data = try? Data(contentsOf: vauCertificateOcspResponseFilePath) else {
            return nil
        }
        return data
    }

    public func set(vauCertificateOcspResponse: Data?) {
        do {
            if let vauCertificateOcspResponse {
                _ = vauCertificateOcspResponse.save(to: vauCertificateOcspResponseFilePath, options: writingOptions)
            } else {
                try FileManager.default.removeItem(at: vauCertificateOcspResponseFilePath)
            }
        } catch {
            // no feedback
        }
    }

    private static let jsonDecoder = JSONDecoder()

    private static let jsonEncoder = JSONEncoder()
}

extension Data {
    /// Result Tuple/Pair with information about the write action.
    /// Where it was written and what was written.
    typealias WriteResult = (url: URL, data: Data)

    /**
        Save Data to file and capture response/exception in Result

        - Parameters:
            - file: the URL file/path to write to
            - options: Writing settings. Default: .atomicWrite

        - Returns: Result of the write by returning the URL and self upon success.
     */
    func save(to file: URL, options: WritingOptions = .atomicWrite) -> Result<WriteResult, Error> {
        Result {
            try FileManager.default.createDirectory(
                at: file.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try self.write(to: file, options: options)
            return (file, self)
        }
    }
}
