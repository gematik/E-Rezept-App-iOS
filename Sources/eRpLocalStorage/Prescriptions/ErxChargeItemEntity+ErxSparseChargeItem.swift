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

import CoreData
import eRpKit
import ModelsR4

extension ErxChargeItemEntity {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }()

    static func from(
        chargeItem: ErxSparseChargeItem,
        encoder: JSONEncoder = ErxChargeItemEntity.encoder,
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
        encoder: JSONEncoder = ErxChargeItemEntity.encoder,
        in context: NSManagedObjectContext
    ) {
        self.init(context: context)

        let medicationData = try? encoder.encode(chargeItem.medication)
        let invoiceData = try? encoder.encode(chargeItem.invoice)

        identifier = chargeItem.identifier
        taskId = chargeItem.taskId
        isRead = chargeItem.isRead
        fhirData = chargeItem.fhirData
        enteredDate = chargeItem.enteredDate
        medication = medicationData
        invoice = invoiceData
    }

    func update(
        with sparceChargeItem: ErxSparseChargeItem,
        profileEntity: ProfileEntity?,
        encoder: JSONEncoder = ErxChargeItemEntity.encoder
    ) {
        identifier = sparceChargeItem.identifier
        taskId = sparceChargeItem.taskId
        // only update read state if it changes to true
        if isRead == false {
            isRead = sparceChargeItem.isRead
        }
        fhirData = sparceChargeItem.fhirData
        enteredDate = sparceChargeItem.enteredDate
        medication = try? encoder.encode(sparceChargeItem.medication)
        invoice = try? encoder.encode(sparceChargeItem.invoice)
        profile = profileEntity
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
            taskId: entity.taskId,
            fhirData: fhirData,
            enteredDate: entity.enteredDate,
            isRead: entity.isRead,
            medication: medication,
            invoice: invoice
        )
    }
}
