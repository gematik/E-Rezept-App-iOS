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
