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
import OpenSSL
import SwiftASN1

struct X500Name {
    let countryName: X500RelativeDistinguishedName
    let organizationName: X500RelativeDistinguishedName
    let organizationalUnitName: X500RelativeDistinguishedName
    let commonName: X500RelativeDistinguishedName
}

struct X500RelativeDistinguishedName {
    // let attributeType: not encoded since we don't need it for our purpose
    let value: ASN1UTF8String
}

extension X500Name: DERImplicitlyTaggable {
    static var defaultIdentifier: SwiftASN1.ASN1Identifier {
        .sequence
    }

    init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        do {
            self = try DER.sequence(rootNode, identifier: identifier) { nodes in
                let countryName = try X500RelativeDistinguishedName(derEncoded: &nodes)
                let organizationName = try X500RelativeDistinguishedName(derEncoded: &nodes)
                let organizationalUnitName = try X500RelativeDistinguishedName(derEncoded: &nodes)
                let commonName = try X500RelativeDistinguishedName(derEncoded: &nodes)

                return X500Name(
                    countryName: countryName,
                    organizationName: organizationName,
                    organizationalUnitName: organizationalUnitName,
                    commonName: commonName
                )
            }
        } catch {
            throw TrustStoreError.malformedCertificate
        }
    }

    func serialize(into _: inout SwiftASN1.DER.Serializer, withIdentifier _: SwiftASN1.ASN1Identifier) throws {
        // not implemented since we don't need it here for our purpose
        throw TrustStoreError.internal(error: .notImplemented)
    }
}

extension X500RelativeDistinguishedName: DERImplicitlyTaggable {
    static var defaultIdentifier: SwiftASN1.ASN1Identifier {
        .set
    }

    init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(rootNode, identifier: identifier) { nodes in
            guard let sequence = nodes.next() else {
                throw SwiftASN1.ASN1Error.truncatedASN1Field()
            }

            // (constructed) sequence here is expected to be
            // {
            //      OBJECT IDENTIFIER,
            //      UTF8String
            // }
            switch sequence.content {
            case let .constructed(collection):
                var iter = collection.makeIterator()
                _ = iter.next() // ignore O.ID
                guard
                    let utf8StringContent = iter.next()?.content,
                    case let .primitive(utf8StringBytes) = utf8StringContent
                else {
                    throw TrustStoreError.malformedCertificate
                }
                let ret = ASN1UTF8String(contentBytes: utf8StringBytes)
                return X500RelativeDistinguishedName(value: ret)
            case .primitive:
                throw TrustStoreError.malformedCertificate
            }
        }
    }

    func serialize(into _: inout SwiftASN1.DER.Serializer, withIdentifier _: SwiftASN1.ASN1Identifier) throws {
        // not implemented since we don't need it here for our purpose
        throw TrustStoreError.internal(error: .notImplemented)
    }
}

extension X509 {
    func issuerCn() throws -> String {
        guard
            let issuerX500PrincipalDEREncoded = self.issuerX500PrincipalDEREncoded(),
            let x500Name = try? X500Name(derEncoded: issuerX500PrincipalDEREncoded.bytes)
        else {
            throw TrustStoreError.malformedCertificate
        }

        return String(x500Name.commonName.value)
    }

    func subjectCN() throws -> String {
        guard
            let subjectX500PrincipalDEREncoded = self.subjectX500PrincipalDEREncoded(),
            let x500Name = try? X500Name(derEncoded: subjectX500PrincipalDEREncoded.bytes)
        else {
            throw TrustStoreError.malformedCertificate
        }

        return String(x500Name.commonName.value)
    }
}

extension Data {
    var bytes: [UInt8] {
        [UInt8](self)
    }
}
