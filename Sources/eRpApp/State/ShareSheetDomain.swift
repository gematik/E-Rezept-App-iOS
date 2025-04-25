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

import ComposableArchitecture
import Foundation
import UIKit

@Reducer
struct ShareSheetDomain {
    @ObservableState
    struct State: Equatable {
        let string: String?
        let url: URL?
        let dataMatrixCodeImage: UIImage?
        var servicesToShareItem: [UIActivity] = []

        init(string: String? = nil, url: URL? = nil, dataMatrixCodeImage: UIImage? = nil) {
            self.string = string
            self.url = url
            self.dataMatrixCodeImage = dataMatrixCodeImage
        }

        func shareItems() -> [Any] {
            [string as Any, url as Any, dataMatrixCodeImage as Any].compactMap { $0 }
        }
    }

    enum Action: Equatable {
        case delegate(Delegate)

        enum Delegate: Equatable {
            case close(Error?)
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .delegate:
                return .none
            }
        }
    }

    // sourcery: CodedError = "043"
    enum Error: Swift.Error, Equatable, LocalizedError {
        // sourcery: errorCode = "01"
        case shareFailure(String)

        var errorDescription: String? {
            switch self {
            case let .shareFailure(description):
                return description
            }
        }
    }
}
