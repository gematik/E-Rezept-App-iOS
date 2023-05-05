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

/// Acts as the intermediate data model from a `ModelsR4.Organization` resource response
/// and the local store representation
///
/// A formally or informally recognized grouping of people or organizations
/// formed for the purpose of achieving some form of collective action.
/// Includes companies, institutions, corporations, departments, community groups,
/// healthcare practice groups, payer/insurer, etc.
/// Profile: https://simplifier.net/packages/de.abda.erezeptabgabedaten/1.3.0/files/805901
public struct DavOrganization: Hashable, Codable {
    public init(
        identifier: String,
        name: String,
        address: String,
        country: String
    ) {
        self.identifier = identifier
        self.name = name
        self.address = address
        self.country = country
    }

    /// unique identifier in each `DavOrganization`
    public let identifier: String
    /// name of the organization as a label
    public let name: String
    /// address containing city and postalCode
    public let address: String
    /// country name (ISO 3166 3 letter codes can be used in place of a human readable name)
    public let country: String
}
