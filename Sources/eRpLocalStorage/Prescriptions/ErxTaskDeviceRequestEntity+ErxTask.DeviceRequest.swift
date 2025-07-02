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

extension ErxTaskDeviceRequestEntity {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }()

    convenience init?(request: ErxDeviceRequest?,
                      encoder: JSONEncoder = ErxTaskDeviceRequestEntity.encoder,
                      in context: NSManagedObjectContext) {
        guard let deviceRequest = request else { return nil }

        self.init(context: context)

        let status = try? encoder.encode(deviceRequest.status)
        let intent = try? encoder.encode(deviceRequest.intent)

        self.status = status
        self.intent = intent
        pzn = deviceRequest.pzn
        appName = deviceRequest.appName
        isSer = deviceRequest.isSER
        authoredOn = deviceRequest.authoredOn
        accidentInfo = ErxTaskAccidentInfoEntity(
            accident: deviceRequest.accidentInfo,
            in: context
        )
    }
}

extension ErxDeviceRequest {
    init?(entity: ErxTaskDeviceRequestEntity?,
          decoder: JSONDecoder = JSONDecoder()) {
        guard let entity = entity else { return nil }

        let status = try? decoder.decode(DeviceRequestStatus.self, from: entity.status ?? Data())
        let intent = try? decoder.decode(ErxDeviceRequest.DeviceRequestIntent.self, from: entity.intent ?? Data())

        self.init(
            status: status,
            intent: intent,
            pzn: entity.pzn,
            appName: entity.appName,
            isSER: entity.isSer,
            accidentInfo: AccidentInfo(entity: entity.accidentInfo),
            authoredOn: entity.authoredOn,
            diGaInfo: DiGaInfo(entity: entity.diGaInfo)
        )
    }
}
