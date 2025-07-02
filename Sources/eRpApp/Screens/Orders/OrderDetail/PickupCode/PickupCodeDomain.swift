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
import eRpKit
import SwiftUI

@Reducer
struct PickupCodeDomain {
    @ObservableState
    struct State: Equatable {
        var pharmacyName: String?
        var pickupCodeHR: String?
        var pickupCodeDMC: String?
        var dmcImage: UIImage?
    }

    enum Action: Equatable {
        case loadMatrixCodeImage(screenSize: CGSize)

        case response(Response)
        case delegate(Delegate)

        enum Response: Equatable {
            case matrixCodeImageReceived(UIImage?)
        }

        enum Delegate: Equatable {
            case close
        }
    }

    let screenScale = UIScreen.main.scale

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.matrixCodeGenerator) var matrixCodeGenerator: MatrixCodeGenerator

    var body: some Reducer<State, Action> {
        Reduce(self.core)
    }

    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .delegate(.close):
            // handled by parent domain
            return .none
        case let .loadMatrixCodeImage(screenSize):
            guard let dmcCode = state.pickupCodeDMC, !dmcCode.isEmpty, state.dmcImage == nil else {
                return .none
            }
            let size = calcMatrixCodeSize(screenSize: screenSize)
            return .publisher(
                matrixCodeGenerator.matrixCodePublisher(
                    for: dmcCode,
                    with: size,
                    scale: screenScale,
                    orientation: .up
                )
                .receive(on: schedulers.main.animation())
                .first()
                .map { .response(.matrixCodeImageReceived($0)) }
                .catch { _ in Empty() }
                .eraseToAnyPublisher
            )
        case let .response(.matrixCodeImageReceived(matrixCodeImage)):
            if let image = matrixCodeImage {
                UIScreen.main.brightness = CGFloat(1.0)
                state.dmcImage = image
            }
            return .none
        }
    }

    /// Will calculate the size for the matrix code based on current screen size
    private func calcMatrixCodeSize(screenSize: CGSize) -> CGSize {
        let padding: CGFloat = 16
        let minScreenDimension = min(screenSize.width, screenSize.height)
        let pixelDimension = Int(minScreenDimension - 2 * padding)
        return CGSize(width: pixelDimension, height: pixelDimension)
    }
}

extension PickupCodeDomain {
    enum Dummies {
        static let demoSessionContainer = DummyUserSessionContainer()
        static let state = State(pickupCodeHR: "1234",
                                 pickupCodeDMC: "123456789")
        static let store = StoreOf<PickupCodeDomain>(
            initialState: state
        ) {
            PickupCodeDomain()
        }

        static func storeFor(_ state: State) -> StoreOf<PickupCodeDomain> {
            Store(
                initialState: state
            ) {
                PickupCodeDomain()
            }
        }
    }
}
