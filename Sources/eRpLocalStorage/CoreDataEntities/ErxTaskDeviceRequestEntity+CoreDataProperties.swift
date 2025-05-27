//
//  Copyright (c) 2025 gematik GmbH
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

extension ErxTaskDeviceRequestEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ErxTaskDeviceRequestEntity> {
        NSFetchRequest<ErxTaskDeviceRequestEntity>(entityName: "ErxTaskDeviceRequestEntity")
    }

    @NSManaged public var appName: String?
    @NSManaged public var authoredOn: String?
    @NSManaged public var intent: Data?
    @NSManaged public var isSer: Bool
    @NSManaged public var pzn: String?
    @NSManaged public var status: Data?
    @NSManaged public var accidentInfo: ErxTaskAccidentInfoEntity?
    @NSManaged public var task: ErxTaskEntity?
    @NSManaged public var diGaInfo: DiGaInfoEntity?
}

extension ErxTaskDeviceRequestEntity: Identifiable {}
