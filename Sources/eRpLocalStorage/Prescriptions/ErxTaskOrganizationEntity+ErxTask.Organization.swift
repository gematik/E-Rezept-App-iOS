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

import CoreData
import eRpKit

extension ErxTaskOrganizationEntity {
    convenience init?(organization: ErxTask.Organization?,
                      in context: NSManagedObjectContext) {
        guard let organization = organization else { return nil }

        self.init(context: context)

        organizationIdentifier = organization.identifier
        name = organization.name
        phone = organization.phone
        email = organization.email
        address = organization.address
    }
}

extension ErxTask.Organization {
    init?(entity: ErxTaskOrganizationEntity?) {
        guard let entity = entity else { return nil }

        self.init(identifier: entity.organizationIdentifier,
                  name: entity.name,
                  phone: entity.phone,
                  email: entity.email,
                  address: entity.address)
    }
}
