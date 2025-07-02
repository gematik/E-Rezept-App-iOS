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

import eRpStyleKit
import SnapshotTesting
import SwiftUI
import XCTest

final class FlagLabelSnapshotTests: ERPSnapshotTestCase {
    func testFlagLabeSytles() {
        let sut = VStack {
            Button(action: {}, label: {
                Label("Blue Flag Label as Button", systemImage: SFSymbolName.ant)
                    .labelStyle(.blueFlag)
            })

            Button(action: {}, label: {
                Label("Red Flag Label as Button", systemImage: SFSymbolName.ant)
                    .labelStyle(.redFlag)
            })

            Label("Blue Flag Label", systemImage: SFSymbolName.ant)
                .labelStyle(.blueFlag)

            Label("Red Flag Label", systemImage: SFSymbolName.ant)
                .labelStyle(.redFlag)
        }
        .frame(width: 375)

        assertSnapshots(of: sut, as: snapshotModi())
    }
}
