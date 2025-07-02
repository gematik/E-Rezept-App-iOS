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
import Foundation

extension ErxAuditEvent {
    enum Fixtures {
        static let auditEvents: [ErxAuditEvent] = {
            [
                ErxAuditEvent(identifier: "100",
                              locale: "de",
                              text: """
                              Das Rezept wurde gelöscht, und dieser Audit-Event ist \
                              extra sehr lang und sehr ausführlich geschrieben, \
                              um zu schauen, ob er trotzdem richtig angezeigt wird.
                              """,
                              timestamp: "2021-05-01T14:22:15.444555666+00:00",
                              taskId: "6390f983-1e67-11b2-8555-63bf44e44fb8"),
                ErxAuditEvent(identifier: "101",
                              locale: "fr",
                              text: "Cette recette a déjà été utilisée.",
                              timestamp: "2021-04-11T12:45:34.123473321+00:00",
                              taskId: "7390f983-1e67-11b2-8555-63bf44e44fb8"),
                ErxAuditEvent(identifier: "102",
                              locale: "en",
                              text: "Read operation was performed.",
                              timestamp: "2021-04-07T09:05:45.382873913+00:00",
                              taskId: "2390f983-1e67-11b2-8555-63bf44e44fb8"),
            ]
        }()
    }
}
