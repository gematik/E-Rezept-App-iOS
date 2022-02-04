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

import Combine
import ComposableArchitecture
import eRpKit
import SwiftUI
import ZXingObjC

enum PickupCodeDomain: Equatable {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    struct State: Equatable {
        var pickupCodeHR: String?
        var pickupCodeDMC: String?
        var dmcImage: UIImage?
    }

    enum Action: Equatable {
        case close
        case loadMatrixCodeImage(screenSize: CGSize)
        case matrixCodeImageReceived(UIImage?)
    }

    struct Environment {
        let schedulers: Schedulers
        let matrixCodeGenerator: MatrixCodeGenerator
        let screenScale = UIScreen.main.scale
    }

    static let reducer = Reducer { state, action, environment in
        switch action {
        case .close:
            // handled by parent domain
            return .none
        case let .loadMatrixCodeImage(screenSize):
            guard let dmcCode = state.pickupCodeDMC, !dmcCode.isEmpty, state.dmcImage == nil else {
                return .none
            }
            let size = environment.calcMatrixCodeSize(screenSize: screenSize)
            return environment.matrixCodeGenerator.publishedMatrixCode(
                for: dmcCode,
                with: size,
                scale: environment.screenScale,
                orientation: .up
            )
            .receive(on: environment.schedulers.main.animation())
            .first()
            .catch { _ in Effect.none }
            .map(PickupCodeDomain.Action.matrixCodeImageReceived)
            .eraseToEffect()
        case let .matrixCodeImageReceived(matrixCodeImage):
            if let image = matrixCodeImage {
                UIScreen.main.brightness = CGFloat(1.0)
                state.dmcImage = image
            }
            return .none
        }
    }
}

extension PickupCodeDomain.Environment {
    /// Will calculate the size for the matrix code based on current screen size
    func calcMatrixCodeSize(screenSize: CGSize) -> CGSize {
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
        static let environment = Environment(
            schedulers: Schedulers(),
            matrixCodeGenerator: ZXDataMatrixWriter()
        )
        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: PickupCodeDomain.Reducer.empty,
                  environment: environment)
        }
    }
}
