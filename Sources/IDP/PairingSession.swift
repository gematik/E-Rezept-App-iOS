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

import ASN1Kit
import Combine
import Foundation
import OpenSSL

/// Represents a Biometrics PairingSession that may be reset when registration of a biometric key failed.
public class PairingSession {
    let tempKeyIdentifier: Data
    let deviceInformation: RegistrationData.DeviceInformation
    private(set) var certificate: X509?

    internal init(tempKeyIdentifier: Data,
                  deviceInformation: RegistrationData.DeviceInformation) {
        self.tempKeyIdentifier = tempKeyIdentifier
        self.deviceInformation = deviceInformation
    }

    func pairingData(certificate: X509, privateKeyContainer: PrivateKeyContainer) throws -> JWT {
        guard let authCertSubjectPublicKeyInfoRaw = try? certificate.brainpoolP256r1VerifyPublicKey()?.asn1Encoded(),
              let encoded = authCertSubjectPublicKeyInfoRaw.encodeBase64UrlSafe(),
              let authCertSubjectPublicKeyInfo = String(data: encoded, encoding: .utf8)
        else {
            throw SecureEnclaveSignatureProviderError.packagingAuthCertificate
        }

        // Secure Enclave Public Key and signing certificate's issuer data
        guard let seSubjectPublicKeyInfoRaw = try? privateKeyContainer.asn1PublicKey(),
              let base64seSubjectPublicKeyInfoRaw = seSubjectPublicKeyInfoRaw.encodeBase64UrlSafe(),
              let seSubjectPublicKeyInfo = String(data: base64seSubjectPublicKeyInfoRaw, encoding: .utf8),
              let base64Issuer = certificate.issuerX500PrincipalDEREncoded()?.encodeBase64UrlSafe(),
              let issuer = String(data: base64Issuer, encoding: .utf8)
        else {
            throw SecureEnclaveSignatureProviderError.packagingSeCertificate
        }

        do {
            let pairingData = PairingData(authCertSubjectPublicKeyInfo: authCertSubjectPublicKeyInfo,
                                          notAfter: Int(try certificate.notAfter().timeIntervalSince1970),
                                          product: deviceInformation.deviceType.product,
                                          serialnumber: try certificate.serialNumber(),
                                          keyIdentifier: privateKeyContainer.tag,
                                          seSubjectPublicKeyInfo: seSubjectPublicKeyInfo,
                                          issuer: issuer)
            let pairingDataHeader = JWT.Header(alg: JWT.Algorithm.bp256r1, typ: "JWT")
            return try JWT(header: pairingDataHeader, payload: pairingData)
        } catch {
            throw SecureEnclaveSignatureProviderError.gatheringPairingData(error)
        }
    }

    func sign(with signer: JWTSigner, certificate: X509, privateKeyContainer: PrivateKeyContainer)
        -> AnyPublisher<RegistrationData, SecureEnclaveSignatureProviderError> {
        self.certificate = certificate

        guard let authCertRaw = certificate.derBytes,
              let base64authCertRaw = authCertRaw.encodeBase64UrlSafe(),
              let authCert = String(data: base64authCertRaw, encoding: .utf8) else {
            return Fail(error: SecureEnclaveSignatureProviderError.packagingAuthCertificate).eraseToAnyPublisher()
        }
        do {
            return try pairingData(certificate: certificate, privateKeyContainer: privateKeyContainer)
                .sign(with: signer)
                .map { [self] signatureJWT -> RegistrationData in
                    RegistrationData(
                        authCert: authCert,
                        signedParingData: signatureJWT.serialize(),
                        deviceInformation: self.deviceInformation
                    )
                }
                .mapError(SecureEnclaveSignatureProviderError.signing)
                .eraseToAnyPublisher()
        } catch let error as SecureEnclaveSignatureProviderError {
            return Fail(error: error).eraseToAnyPublisher()
        } catch {
            return Fail(error: SecureEnclaveSignatureProviderError.internal("Unexpected error", error))
                .eraseToAnyPublisher()
        }
    }
}

extension BrainpoolP256r1.Verify.PublicKey {
    func asn1Encoded() throws -> Data {
        let asn1 = ASN1Data.constructed(
            [
                create(tag: .universal(.sequence), data: ASN1Data.constructed(
                    [
                        try ObjectIdentifier.from(string: "1.2.840.10045.2.1").asn1encode(),
                        try ObjectIdentifier.from(string: "1.3.36.3.3.2.8.1.1.7").asn1encode(),
                    ]
                )),

                try x962Value().asn1bitStringEncode(),
            ]
        )
        return try create(tag: .universal(.sequence), data: asn1).serialize()
    }
}
