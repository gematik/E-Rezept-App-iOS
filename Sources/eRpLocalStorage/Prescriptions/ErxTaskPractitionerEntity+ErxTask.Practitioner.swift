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

import CoreData
import eRpKit

extension ErxTaskPractitionerEntity {
    convenience init?(practitioner: ErxPractitioner?,
                      in context: NSManagedObjectContext) {
        guard let practitioner = practitioner else { return nil }

        self.init(context: context)

        lanr = practitioner.lanr
        zanr = practitioner.zanr
        name = practitioner.name
        qualification = practitioner.qualification
        email = practitioner.email
        address = practitioner.address
    }
}

extension ErxPractitioner {
    init?(entity: ErxTaskPractitionerEntity?) {
        guard let entity = entity else { return nil }

        self.init(lanr: entity.lanr,
                  zanr: entity.zanr,
                  name: entity.name,
                  qualification: entity.qualification,
                  email: entity.email,
                  address: entity.address)
    }
}
