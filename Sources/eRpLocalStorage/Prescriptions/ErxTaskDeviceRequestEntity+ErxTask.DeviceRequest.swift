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
        accidentInfo = ErxTaskAccidentInfoEntity(
            accident: deviceRequest.accidentInfo,
            in: context
        )
        authoredOn = deviceRequest.authoredOn
    }
}

extension ErxDeviceRequest {
    init?(entity: ErxTaskDeviceRequestEntity?,
          decoder: JSONDecoder = JSONDecoder()) {
        guard let entity = entity else { return nil }

        let status = try? decoder.decode(DeviceRequestStatus.self, from: entity.status ?? Data())
        let intent = try? decoder.decode(ErxDeviceRequest.Intent.self, from: entity.intent ?? Data())

        self.init(
            status: status,
            intent: intent,
            pzn: entity.pzn,
            appName: entity.appName,
            isSER: entity.isSer,
            accidentInfo: AccidentInfo(entity: entity.accidentInfo),
            authoredOn: entity.authoredOn
        )
    }
}
