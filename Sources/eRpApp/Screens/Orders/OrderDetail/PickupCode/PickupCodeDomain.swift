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

import Combine
import ComposableArchitecture
import eRpKit
import SwiftUI
import ZXingObjC

struct PickupCodeDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

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

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
    }

    private func core(state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .delegate(.close):
            // handled by parent domain
            return .none
        case let .loadMatrixCodeImage(screenSize):
            guard let dmcCode = state.pickupCodeDMC, !dmcCode.isEmpty, state.dmcImage == nil else {
                return .none
            }
            let size = calcMatrixCodeSize(screenSize: screenSize)
            return matrixCodeGenerator.publishedMatrixCode(
                for: dmcCode,
                with: size,
                scale: screenScale,
                orientation: .up
            )
            .receive(on: schedulers.main.animation())
            .first()
            .catch { _ in Effect.none }
            .map { .response(.matrixCodeImageReceived($0)) }
            .eraseToEffect()
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
        static let store = Store(initialState: state,
                                 reducer: PickupCodeDomain())
        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: PickupCodeDomain())
        }
    }
}
