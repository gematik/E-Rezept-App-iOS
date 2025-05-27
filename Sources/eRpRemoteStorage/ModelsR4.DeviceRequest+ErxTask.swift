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

import eRpKit
import Foundation
import ModelsR4

extension ModelsR4.DeviceRequest {
    var deviceRequestStatus: ErxDeviceRequest.DeviceRequestStatus? {
        if let rawStatus = status?.value?.rawValue {
            return ErxDeviceRequest.DeviceRequestStatus(rawValue: rawStatus)
        }
        return nil
    }

    var deviceRequestIntent: ErxDeviceRequest.DeviceRequestIntent? {
        if let rawStatus = intent.value?.rawValue {
            return ErxDeviceRequest.DeviceRequestIntent(rawValue: rawStatus)
        }
        return nil
    }

    // According to the definition of codeableConcept, "text" can only be the name of the DiGa
    // https://simplifier.net/evdga/kbv_pr_evdga_healthapprequest
    var appName: String? {
        if case let DeviceRequest.CodeX.codeableConcept(codeX) = code {
            return codeX.text?.value?.string
        }
        return nil
    }

    // According to the definition of codeableConcept, "code" can only be the PZN of the DiGa
    // https://simplifier.net/evdga/kbv_pr_evdga_healthapprequest
    var pzn: String? {
        if case let DeviceRequest.CodeX.codeableConcept(codeX) = code {
            return codeX.coding?.first?.code?.value?.string
        }
        return nil
    }

    var isSer: Bool? {
        `extension`?.first {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.DeviceRequest.serInfoKey
        }
        .map {
            if let valueX = $0.value,
               case Extension.ValueX.boolean(true) = valueX {
                return true
            }
            return false
        }
    }

    var accidentInfo: AccidentInfo? {
        guard let accident = `extension`?.first(where: {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.DeviceRequest.accidentInfoKey
        }) else {
            return nil
        }

        let identifier: String? = accident.extension?.first {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.DeviceRequest.accidentTypeKey
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.coding(coding) = valueX {
                return coding.code?.value?.string
            }
            return nil
        }

        let place: String? = accident.extension?.first {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.DeviceRequest.accidentPlaceKey
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.string(str) = valueX {
                return str.value?.string
            }
            return nil
        }

        let date: String? = accident.extension?.first {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.DeviceRequest.accidentDateKey
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.date(date) = valueX,
               let dateString = date.value?.description {
                return dateString
            }
            return nil
        }

        var accidentType: AccidentInfo.AccidentType?
        if let type = identifier {
            accidentType = .init(type: type)
        }

        return AccidentInfo(
            type: accidentType,
            workPlaceIdentifier: place,
            date: date
        )
    }
}
