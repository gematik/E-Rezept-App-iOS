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

import eRpStyleKit
import SnapshotTesting
import SwiftUI
import XCTest

final class FlagLabelSnapshotTests: XCTestCase {
    override class func setUp() {
        super.setUp()

        diffTool = "open"
    }

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

        assertSnapshots(matching: sut, as: snapshotModi())
    }
}
