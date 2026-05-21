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

import Combine
import Foundation

/// TrustStore storage protocol
public protocol TrustStoreStorage {
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

    /// Retrieve the previously saved OCSP response for a specific certificate
    /// - Parameters:
    ///   - issuerCn: The common name of the issuer certificate
    ///   - serialNr: The serial number of the certificate
    func getOcspResponse(issuerCn: String, serialNr: String) -> Data?

    /// Set and save the OCSP response for a specific certificate
    /// - Parameters:
    ///  - issuerCn: The common name of the issuer certificate
    ///  - serialNr: The serial number of the certificate
    func setOcspResponse(issuerCn: String, serialNr: String, ocspResponse: Data?)

    /// Reset all stored OCSP responses
    func resetOcspResponses()
}

public class TrustStoreFileStorage: TrustStoreStorage {
    let pkiCertificatesFilePath: URL
    let vauCertificateFilePath: URL
    let writingOptions: Data.WritingOptions = [.atomicWrite, .completeFileProtectionUnlessOpen]

    public init(trustStoreStorageBaseFilePath: URL) {
        pkiCertificatesFilePath = trustStoreStorageBaseFilePath.appendingPathComponent("trustStorePKICertificates")
        vauCertificateFilePath = trustStoreStorageBaseFilePath.appendingPathComponent("vauCertificate")
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

    private static let ocspResponseDirectoryName = "ocspResponses"
    public func getOcspResponse(issuerCn: String, serialNr: String) -> Data? {
        do {
            let ocspResponseDirectory = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent(Self.ocspResponseDirectoryName)
            let fileName = "\(issuerCn)_\(serialNr).ocsp"
            let fileURL = ocspResponseDirectory.appendingPathComponent(fileName)
            return try Data(contentsOf: fileURL)
        } catch {
            return nil
        }
    }

    public func setOcspResponse(issuerCn: String, serialNr: String, ocspResponse: Data?) {
        do {
            let ocspResponseDirectory = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent(Self.ocspResponseDirectoryName)
            try FileManager.default.createDirectory(
                at: ocspResponseDirectory,
                withIntermediateDirectories: true
            )
            let fileName = "\(issuerCn)_\(serialNr).ocsp"
            let fileURL = ocspResponseDirectory.appendingPathComponent(fileName)

            if let ocspResponse {
                _ = ocspResponse.save(to: fileURL, options: writingOptions)
            } else {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            // no feedback
        }
    }

    public func resetOcspResponses() {
        do {
            let ocspResponseDirectory = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent(Self.ocspResponseDirectoryName)
            if FileManager.default.fileExists(atPath: ocspResponseDirectory.path) {
                let fileURLs = try FileManager.default.contentsOfDirectory(
                    at: ocspResponseDirectory,
                    includingPropertiesForKeys: nil
                )
                for url in fileURLs where url.pathExtension == "ocsp" {
                    try? FileManager.default.removeItem(at: url)
                }
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
