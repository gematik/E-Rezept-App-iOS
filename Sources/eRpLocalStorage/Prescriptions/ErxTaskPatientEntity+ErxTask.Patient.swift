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

extension ErxTaskPatientEntity {
    convenience init?(patient: ErxTask.Patient?,
                      in context: NSManagedObjectContext) {
        guard let patient = patient else { return nil }

        self.init(context: context)

        address = patient.address
        birthDate = patient.birthDate
        insurance = patient.insurance
        insuranceIdentifier = patient.insuranceId
        name = patient.name
        phone = patient.phone
        status = patient.status
    }
}

extension ErxTask.Patient {
    init?(entity: ErxTaskPatientEntity?) {
        guard let entity = entity else { return nil }

        self.init(
            name: entity.name,
            address: entity.address,
            birthDate: entity.birthDate,
            phone: entity.phone,
            status: entity.status,
            insurance: entity.insurance,
            insuranceId: entity.insuranceIdentifier
        )
    }
}
