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
import ModelsR4

extension ErxChargeItemEntity {
    static func from(
        chargeItem: ErxSparseChargeItem,
        encoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            return encoder
        }(),
        in context: NSManagedObjectContext
    ) -> ErxChargeItemEntity? {
        ErxChargeItemEntity(
            chargeItem: chargeItem,
            encoder: encoder,
            in: context
        )
    }

    convenience init?(
        chargeItem: ErxSparseChargeItem,
        encoder: JSONEncoder = JSONEncoder(),
        in context: NSManagedObjectContext
    ) {
        self.init(context: context)

        let medicationData = try? encoder.encode(chargeItem.medication)
        let invoiceData = try? encoder.encode(chargeItem.invoice)

        identifier = chargeItem.identifier
        fhirData = chargeItem.fhirData
        enteredDate = chargeItem.enteredDate
        medication = medicationData
        invoice = invoiceData
    }
}

extension ErxSparseChargeItem {
    init?(
        entity: ErxChargeItemEntity?,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        guard let entity = entity,
              let identifier = entity.identifier,
              let fhirData = entity.fhirData else {
            return nil
        }

        let medication = try? decoder.decode(ErxMedication.self, from: entity.medication ?? Data())
        let invoice = try? decoder.decode(DavInvoice.self, from: entity.invoice ?? Data())

        self.init(
            identifier: identifier,
            fhirData: fhirData,
            enteredDate: entity.enteredDate,
            medication: medication,
            invoice: invoice
        )
    }
}
