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

import eRpKit
import Foundation

struct Globals {
    internal init(fhirDateFormatter: FHIRDateFormatter,
                  uiDateFormatter: DateFormatter,
                  schedulers: Schedulers) {
        self.fhirDateFormatter = fhirDateFormatter
        self.uiDateFormatter = uiDateFormatter
        self.schedulers = schedulers
    }

    let fhirDateFormatter: FHIRDateFormatter
    let uiDateFormatter: DateFormatter
    let schedulers: Schedulers

    static func live() -> Self {
        let uiDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            formatter.doesRelativeDateFormatting = true
            return formatter
        }()

        return Globals(
            fhirDateFormatter: FHIRDateFormatter.shared,
            uiDateFormatter: uiDateFormatter,
            schedulers: Schedulers()
        )
    }
}

let globals: Globals = .live()
