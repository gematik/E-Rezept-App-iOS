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

import eRpKit
import FeatureEURedeem
import Foundation

extension EUPrescription {
    enum Fixtures {
        static let prescriptions: [EUPrescription] = withDependencies { dependencies in
            dependencies.date = .constant(Date.Fixtures.defaultReferenceDate)
        } operation: {
            [
                EUPrescription(erxTask: ErxTask(
                    identifier: "1",
                    status: .ready,
                    flowType: .tPrescription,
                    expiresOn: Date.Fixtures.defaultReferenceDate.advanced(by: 5 * 60).ISO8601Format(.iso8601),
                    medication: ErxMedication(name: "Ibuprofen 600"),
                    isEURedeemable: true
                )),
                EUPrescription(erxTask: ErxTask(
                    identifier: "2",
                    status: .ready,
                    flowType: .tPrescription,
                    expiresOn: Date.Fixtures.defaultReferenceDate.advanced(by: 5 * 60).ISO8601Format(.iso8601),
                    medication: ErxMedication(name: "Acnatac Lösung 3mg/g"),
                    isEURedeemable: true
                )),
                EUPrescription(erxTask: ErxTask(
                    identifier: "3",
                    status: .ready,
                    flowType: .tPrescription,
                    expiresOn: Date.Fixtures.defaultReferenceDate.advanced(by: 5 * 60).ISO8601Format(.iso8601),
                    medication: ErxMedication(name: "Ibuprofen 10mg/g"),
                    isEURedeemable: true
                )),
            ]
        }
    }
}
