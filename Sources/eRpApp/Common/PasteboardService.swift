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

import Dependencies
import DependenciesMacros
import SwiftUI

@DependencyClient
struct PasteboardService {
    var copy: (_ string: String) -> Void = { _ in reportIssue("unimplemented") }
}

extension PasteboardService: DependencyKey {
    static let liveValue: PasteboardService = .init { value in
        UIPasteboard.general.string = value
    }

    static var testValue = Self()
}

extension DependencyValues {
    var pasteboardService: PasteboardService {
        get { self[PasteboardService.self] }
        set { self[PasteboardService.self] = newValue }
    }
}
