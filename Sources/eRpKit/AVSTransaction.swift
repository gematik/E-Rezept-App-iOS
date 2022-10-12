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

import Foundation

/// Represents the information of a transaction with the AVS
public struct AVSTransaction: Identifiable, Hashable, Equatable {
    public var id: UUID {
        transactionID
    }

    /// ID of transaction for a sole ErxTask. May be used to track service communication
    public let transactionID: UUID
    /// States the HTTP status code the transaction terminated with
    public let httpStatusCode: Int32
    /// Timestamp of transaction
    public let groupedRedeemTime: Date
    /// ID for multiple ErxTasks that are redeemed at once
    public let groupedRedeemID: UUID
    /// ID of receiving AVS (Apothekenverzeichnisdienst)
    public let telematikID: String?

    public let taskId: String?

    public init(
        transactionID: UUID = UUID(),
        httpStatusCode: Int32,
        groupedRedeemTime: Date,
        groupedRedeemID: UUID,
        telematikID: String? = nil,
        taskId: String
    ) {
        self.transactionID = transactionID
        self.httpStatusCode = httpStatusCode
        self.groupedRedeemTime = groupedRedeemTime
        self.groupedRedeemID = groupedRedeemID
        self.telematikID = telematikID
        self.taskId = taskId
    }
}
