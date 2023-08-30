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

import ASN1Kit
import Combine
import Foundation
import OpenSSL

protocol AVSMessageConverter {
    func convert(_ message: AVSMessage, recipients: [X509]) throws -> Data
}

// Refer to RFC 5083 https://datatracker.ietf.org/doc/html/rfc5083
struct AuthEnvelopedWithUnauthAttributes: AVSMessageConverter {
    static let encoder = JSONEncoder()
    let avsCmsEncrypter: AVSCmsEncrypter

    init(
        avsCmsEncrypter: AVSCmsEncrypter = RsaOnlyAVSCmsEncrypter()
    ) {
        self.avsCmsEncrypter = avsCmsEncrypter
    }

    // Refer to RFC 5083 https://datatracker.ietf.org/doc/html/rfc5083
    func convert(_ message: AVSMessage, recipients: [X509]) throws -> Data {
        // 0. Serialize to JSON
        let data = try Self.encoder.encode(message)

        // [REQ:gemSpec_eRp_FdV:A_22779#2] Encrypted message is of form of a PKCS#7 container (CMS)
        // 1. Create a CMS AuthenticatedEnvelopedData structure with help from OpenSSL-swift
        let cmsAuthEnvelopedData = try avsCmsEncrypter.cmsEncrypt(data, recipients: recipients)

        // 2. Create custom Recipient E-mail Unauthorized Attribute
        let recipientEmailsAttribute = try Self.recipientEmailsUnAuthAttribute(recipients: recipients)

        // 3. Create UnauthorizedAttributes (containing only the E-Mail attribute)
        let unauthAttr = try Self.createUnauthorizedAttributes([recipientEmailsAttribute])

        // 4. Embed UnauthorizedAttributes into CMS AuthenticatedEnvelopedData structure
        return try Self.embedInto(cmsAuthEnvelopedData: cmsAuthEnvelopedData, unauthorizedAttributes: unauthAttr)
    }

    static let oidRecipientEmail = "1.2.276.0.76.4.173"

    // For unauthAttr syntax, refer to gemSpec_KOMLE 2.2.5 Ungeschützte Attribute (unauthAttrs)
    static func recipientEmailsUnAuthAttribute(recipients: [X509]) throws -> Data {
        let recipientEmails = try recipients
            .map(Self.recipientEmail)
            .compactMap {
                $0
            } // == .filter { $0 != nil }
            .map(ASN1Decoder.decode)

        let idRecipientEmails = try ObjectIdentifier.from(string: Self.oidRecipientEmail)
            .asn1encode(tag: .universal(.objectIdentifier))

        return try create(
            tag: .universal(.sequence),
            data: .constructed(
                [
                    idRecipientEmails,
                    create(
                        tag: .universal(.set),
                        data: .constructed(recipientEmails)
                    ),
                ]
            )
        )
        .serialize()
    }

    static func recipientEmail(_ x509: X509) throws -> Data? {
        let serialNumberString = try x509.serialNumber()
        guard let holder = x509.issuerX500PrincipalDEREncoded(),
              let registrationNumber = try x509.extractTeleTrustAdmissionRegistrationNumber(),
              let serialNumber = Int(serialNumberString)
        else {
            return nil
        }

        return try create(
            tag: .universal(.sequence),
            data: .constructed(
                [
                    create(
                        tag: .universal(.ia5String),
                        data: ASN1Data.primitive(registrationNumber)
                    ),
                    create(
                        tag: .universal(.sequence),
                        data: .constructed(
                            [
                                try ASN1Decoder.decode(asn1: holder),
                                try serialNumber.asn1encode(tag: .universal(.integer)),
                            ]
                        )
                    ),
                ]
            )
        )
        .serialize()
    }

    static func createUnauthorizedAttributes(_ attributes: [Data]) throws -> Data {
        try create(
            tag: .taggedTag(2),
            data: .constructed(attributes.map(ASN1Decoder.decode))
        )
        .serialize()
    }

    static func embedInto(cmsAuthEnvelopedData: Data, unauthorizedAttributes: Data) throws -> Data {
        let cmsAuthEnveloped = try ASN1Decoder.decode(asn1: cmsAuthEnvelopedData)
        guard let authEnvelopedDataItems = cmsAuthEnveloped.data.items,
              let authEnvelopedDataOid = authEnvelopedDataItems.first,
              let authEnvelopedDataSequence = authEnvelopedDataItems.last?.data.items?.first,
              let asn1Items = authEnvelopedDataSequence.data.items
        else {
            throw AVSError.internal(error: .cmsContentCreation)
        }
        let unauthAttr = try ASN1Decoder.decode(asn1: unauthorizedAttributes)
        let asn1ItemsAppended = asn1Items + [unauthAttr]
        return try create(
            tag: .universal(.sequence),
            data: .constructed(
                [
                    authEnvelopedDataOid,
                    create(
                        tag: .taggedTag(0),
                        data: .constructed(
                            [
                                create(
                                    tag: .universal(.sequence),
                                    data: .constructed(asn1ItemsAppended)
                                ),
                            ]
                        )
                    ),
                ]
            )
        )
        .serialize()
    }
}

extension X509 {
    /// Tries to extract the Telematik-ID from the certificate
    ///
    /// - Returns:
    /// - Throws:
    func extractTeleTrustAdmissionRegistrationNumber() throws -> Data? {
        /* looking for extension entry

         Professional Information or basis for Admission:
             admissionAuthority:
               DirName:C = DE, O = gematik Berlin
             Entry 1:
               Profession Info Entry 1:
                 registrationNumber: 3-SMC-B-Testkarte-883110000116873
                 Info Entries:
                   ..ffentliche Apotheke
                 Profession OIDs:
                   undefined (1.2.276.0.76.4.54)

         where the value holds an ASN1 object containing the registration number string
         */
        guard let derBytes = derBytes else {
            throw AVSError.invalidX509Input
        }
        let decoded = try ASN1Decoder.decode(asn1: derBytes)

        // Get X509 extensions
        // For X.509 v3 certificate basic syntax, refer to https://datatracker.ietf.org/doc/html/rfc2459#section-4
        guard let tbsCertificate = decoded.data.items?.first,
              let extensions = tbsCertificate.data.items?.last,
              extensions.tag == ASN1DecodedTag.taggedTag(3),
              let firstExtension = extensions.data.items?.first
        else {
            // Certificate (unexpectedly?) doesn't carry extensions
            return nil
        }

        // id-isismtt-at-admission(3) TeleTrust admission 1.3.36.8.3.3
        let filteredForTeleTrustAdmission = try firstExtension.data.items?.filter { asn1object in
            if asn1object.tag == ASN1DecodedTag.universal(.sequence),
               let first = asn1object.data.items?.first,
               first.tag == ASN1DecodedTag.universal(.objectIdentifier),
               try ObjectIdentifier(from: first) == ObjectIdentifier.from(string: "1.3.36.8.3.3") {
                return true
            }
            return false
        }

        guard filteredForTeleTrustAdmission?.count == 1,
              let extnValue = filteredForTeleTrustAdmission?.first?.data.items?.last,
              extnValue.tag == ASN1DecodedTag.universal(.octetString),
              let teleTrustAdmissionOctetStringValue = extnValue.data.primitive else {
            return nil
        }

        // Generate a new ASN1 object from the extension entry's value.
        let teleTrustAdmission = try ASN1Decoder.decode(asn1: teleTrustAdmissionOctetStringValue)

        // For syntax, refer to https://www.teletrust.de/fileadmin/files/ISIS-MTT_Core_Specification_v1.1.pdf p.42
        guard let contentsOfAdmissions = teleTrustAdmission.data.items?.last,
              let admission = contentsOfAdmissions.data.items?.first, // Only one contentsOfAdmissions entry
              let professionInfos = admission.data.items?.last,
              let professionInfo = professionInfos.data.items?.first, // Only one professionInfos entry
              let registrationNumber = professionInfo.data.items?.first(
                  where: { $0.tag == ASN1DecodedTag.universal(.printableString) }
              ),
              let registrationNumberPrimitive = registrationNumber.data.primitive
        else {
            return nil
        }
        return registrationNumberPrimitive
    }
}
