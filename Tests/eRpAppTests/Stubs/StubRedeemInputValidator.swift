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

@testable import eRpFeatures
import eRpKit
import Foundation

struct StubRedeemInputValidator: RedeemInputValidator {
    var service: RedeemServiceOption = .noService

    func isValid(version _: Int) -> Validity {
        .valid
    }

    func isValid(name _: String?) -> Validity {
        .valid
    }

    func isValid(street _: String?) -> Validity {
        .valid
    }

    func isValid(zip _: String?) -> Validity {
        .valid
    }

    func isValid(city _: String?) -> Validity {
        .valid
    }

    func isValid(hint _: String?) -> Validity {
        .valid
    }

    func isValid(text _: String?) -> Validity {
        .valid
    }

    func isValid(phone _: String?) -> Validity {
        .valid
    }

    func isValid(mail _: String?) -> Validity {
        .valid
    }

    func ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
        optionType _: RedeemOption,
        phone _: String?,
        mail _: String?
    ) -> Validity {
        .valid
    }

    func onPremiseOrElseIsNonEmptyContactData( // swiftlint:disable:this function_parameter_count
        optionType _: eRpKit.RedeemOption,
        name _: String?,
        street _: String?,
        zip _: String?,
        city _: String?,
        phone _: String?
    ) -> Bool {
        true
    }
}
