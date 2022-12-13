//
//  Copyright (c) 2022 gematik GmbH
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
import Foundation

extension ErxTaskEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ErxTaskEntity> {
        NSFetchRequest<ErxTaskEntity>(entityName: "ErxTaskEntity")
    }

    @NSManaged public var acceptedUntil: String?
    @NSManaged public var accessCode: String?
    @NSManaged public var author: String?
    @NSManaged public var authoredOn: String?
    @NSManaged public var dispenseValidityEnd: String?
    @NSManaged public var expiresOn: String?
    @NSManaged public var flowType: String?
    @NSManaged public var form: String?
    @NSManaged public var fullUrl: String?
    @NSManaged public var identifier: String?
    @NSManaged public var lastModified: String?
    @NSManaged public var noctuFeeWaiver: Bool
    @NSManaged public var prescriptionId: String?
    @NSManaged public var redeemedOn: String?
    @NSManaged public var source: String?
    @NSManaged public var status: String?
    @NSManaged public var substitutionAllowed: Bool
    @NSManaged public var auditEvents: NSSet?
    @NSManaged public var avsTransaction: NSSet?
    @NSManaged public var communications: NSSet?
    @NSManaged public var medication: ErxTaskMedicationEntity?
    @NSManaged public var medicationDispenses: NSSet?
    @NSManaged public var organization: ErxTaskOrganizationEntity?
    @NSManaged public var patient: ErxTaskPatientEntity?
    @NSManaged public var practitioner: ErxTaskPractitionerEntity?
    @NSManaged public var profile: ProfileEntity?
    @NSManaged public var workRelatedAccident: ErxTaskWorkRelatedAccidentEntity?
    @NSManaged public var multiplePrescription: ErxTaskMultiplePrescriptionEntity?
}

// MARK: Generated accessors for auditEvents

extension ErxTaskEntity {
    @objc(addAuditEventsObject:)
    @NSManaged public func addToAuditEvents(_ value: ErxAuditEventEntity)

    @objc(removeAuditEventsObject:)
    @NSManaged public func removeFromAuditEvents(_ value: ErxAuditEventEntity)

    @objc(addAuditEvents:)
    @NSManaged public func addToAuditEvents(_ values: NSSet)

    @objc(removeAuditEvents:)
    @NSManaged public func removeFromAuditEvents(_ values: NSSet)
}

// MARK: Generated accessors for avsTransaction

extension ErxTaskEntity {
    @objc(addAvsTransactionObject:)
    @NSManaged public func addToAvsTransaction(_ value: AVSTransactionEntity)

    @objc(removeAvsTransactionObject:)
    @NSManaged public func removeFromAvsTransaction(_ value: AVSTransactionEntity)

    @objc(addAvsTransaction:)
    @NSManaged public func addToAvsTransaction(_ values: NSSet)

    @objc(removeAvsTransaction:)
    @NSManaged public func removeFromAvsTransaction(_ values: NSSet)
}

// MARK: Generated accessors for communications

extension ErxTaskEntity {
    @objc(addCommunicationsObject:)
    @NSManaged public func addToCommunications(_ value: ErxTaskCommunicationEntity)

    @objc(removeCommunicationsObject:)
    @NSManaged public func removeFromCommunications(_ value: ErxTaskCommunicationEntity)

    @objc(addCommunications:)
    @NSManaged public func addToCommunications(_ values: NSSet)

    @objc(removeCommunications:)
    @NSManaged public func removeFromCommunications(_ values: NSSet)
}

// MARK: Generated accessors for medicationDispenses

extension ErxTaskEntity {
    @objc(addMedicationDispensesObject:)
    @NSManaged public func addToMedicationDispenses(_ value: ErxTaskMedicationDispenseEntity)

    @objc(removeMedicationDispensesObject:)
    @NSManaged public func removeFromMedicationDispenses(_ value: ErxTaskMedicationDispenseEntity)

    @objc(addMedicationDispenses:)
    @NSManaged public func addToMedicationDispenses(_ values: NSSet)

    @objc(removeMedicationDispenses:)
    @NSManaged public func removeFromMedicationDispenses(_ values: NSSet)
}
