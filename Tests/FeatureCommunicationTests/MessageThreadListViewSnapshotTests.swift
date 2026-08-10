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

import Combine
import ComposableArchitecture
@testable import FeatureCommunication
import FeatureHelpers
import IDP
import Nimble
import SnapshotTesting
import SwiftUI
import Synchronization
import TestUtils
import XCTest

@MainActor
final class MessageThreadListViewSnapshotTests: ERPSnapshotTestCase {
    func testMessagesListViewSnapshot() {
        let sut = MessageThreadListView(
            store: StoreOf<MessageThreadListDomain>(initialState: Self.fixtureState) {
                MessageThreadListDomain()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    private static let fixtureState: MessageThreadListDomain.State = {
        var state = MessageThreadListDomain.State(communicationMessage: Shared(value: [
            CommunicationMessage.order(Order.Dummies.orderCommunications1),
            CommunicationMessage.internalCommunication(InternalCommunication(
                messages: [
                    InternalCommunication.Message(
                        id: "welcome-1",
                        timestamp: Date(timeIntervalSinceReferenceDate: 0), // fixed 2001-01-01, deterministic
                        text: "Willkommen bei der E-Rezept App!",
                        version: "0.0.0",
                        isRead: false
                    ),
                ]
            )),
            CommunicationMessage.order(Order.Dummies.orderCommunications2),
        ]))
        state.profileName = "Ada Muster"
        return state
    }()
}
