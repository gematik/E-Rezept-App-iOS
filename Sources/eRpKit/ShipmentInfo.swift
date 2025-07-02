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

import Foundation

/// Represents the shipment information needed for redeeming a prescription in a pharmacy
public struct ShipmentInfo: Identifiable, Hashable, Equatable {
    public var id: UUID {
        identifier
    }

    public let identifier: UUID
    public var name: String?
    public var street: String?
    public var addressDetail: String?
    public var zip: String?
    public var city: String?
    public var phone: String?
    public var mail: String?
    public var deliveryInfo: String?

    public init(
        identifier: UUID = UUID(),
        name: String? = nil,
        street: String? = nil,
        addressDetail: String? = nil,
        zip: String? = nil,
        city: String? = nil,
        phone: String? = nil,
        mail: String? = nil,
        deliveryInfo: String? = nil
    ) {
        self.identifier = identifier
        self.name = name
        self.street = street
        self.addressDetail = addressDetail
        self.zip = zip
        self.city = city
        self.phone = phone
        self.mail = mail
        self.deliveryInfo = deliveryInfo
    }

    public var address: Address {
        Address(
            street: street,
            detail: addressDetail,
            zip: zip,
            city: city
        )
    }
}
