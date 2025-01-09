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
import ModelsR4

extension ErxEpaMedicationEntity {
    // Glue code to `vaccine: NSNumber` work around in `ErxEpaMedicationEntity`
    // This is a workaround to store an optional boolean value in `ErxEpaMedicationEntity`
    // (CoreData does not support optional boolean values (`@NSManaged does not))
    var isVaccine: Bool? {
        get {
            guard let vaccine else { return nil }
            return Bool(exactly: vaccine)
        }
        set {
            if let newValue {
                vaccine = NSNumber(booleanLiteral: newValue) // swiftlint:disable:this compiler_protocol_init
            } else {
                vaccine = nil
            }
        }
    }

    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }()

    static func from(
        epaMedication: ErxEpaMedication,
        encoder: JSONEncoder = ErxEpaMedicationEntity.encoder,
        in context: NSManagedObjectContext
    ) -> ErxEpaMedicationEntity? {
        ErxEpaMedicationEntity(
            epaMedication: epaMedication,
            encoder: encoder,
            in: context
        )
    }

    convenience init?(
        epaMedication: ErxEpaMedication?,
        encoder: JSONEncoder = ErxEpaMedicationEntity.encoder,
        in context: NSManagedObjectContext
    ) {
        guard let epaMedication else { return nil }

        self.init(context: context)

        let epaMedicationTypeData = try? encoder.encode(epaMedication.epaMedicationType)
        let drugCategoryData = try? encoder.encode(epaMedication.drugCategory)
        let codeData = try? encoder.encode(epaMedication.code)
        let statusData = try? encoder.encode(epaMedication.status)
        let formData = try? encoder.encode(epaMedication.form)
        let amountData = try? encoder.encode(epaMedication.amount)
        let batchData = try? encoder.encode(epaMedication.batch)
        let ingredientsData = try? encoder.encode(epaMedication.ingredients)

        epaMedicationType = epaMedicationTypeData
        drugCategory = drugCategoryData
        code = codeData
        status = statusData
        isVaccine = epaMedication.isVaccine
        form = formData
        amount = amountData
        normSizeCode = epaMedication.normSizeCode
        batch = batchData
        packaging = epaMedication.packaging
        manufacturingInstructions = epaMedication.manufacturingInstructions
        ingredients = ingredientsData
    }
}

extension ErxEpaMedication {
    init?(
        entity: ErxEpaMedicationEntity?,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        guard let entity = entity
        else { return nil }

        let epaMedicationType = try? decoder.decode(EpaMedicationType.self, from: entity.epaMedicationType ?? Data())
        let drugCategory = try? decoder.decode(EpaMedicationDrugCategory.self, from: entity.drugCategory ?? Data())
        let code = try? decoder.decode(EpaMedicationCodeCodableConcept.self, from: entity.code ?? Data())
        let status = try? decoder.decode(EpaMedicationStatus.self, from: entity.status ?? Data())
        let form = try? decoder.decode(EpaMedicationFormCodableConcept.self, from: entity.form ?? Data())
        let amount = try? decoder.decode(EpaMedicationRatio.self, from: entity.amount ?? Data())
        let batch = try? decoder.decode(EpaMedicationBatch.self, from: entity.batch ?? Data())
        let ingredients = try? decoder.decode([EpaMedicationIngredient].self, from: entity.ingredients ?? Data())

        self.init(
            epaMedicationType: epaMedicationType,
            drugCategory: drugCategory,
            code: code,
            status: status,
            isVaccine: entity.isVaccine,
            amount: amount,
            form: form,
            normSizeCode: entity.normSizeCode,
            batch: batch,
            packaging: entity.packaging,
            manufacturingInstructions: entity.manufacturingInstructions,
            ingredients: ingredients ?? []
        )
    }
}
