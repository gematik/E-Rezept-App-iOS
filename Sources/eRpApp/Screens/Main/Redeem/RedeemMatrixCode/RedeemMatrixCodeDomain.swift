//
//  Copyright (c) 2021 gematik GmbH
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

enum RedeemMatrixCodeDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    /// Provides an Effect that need to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case cancelMatrixCodeGeneration
        case redeemAndSaveErxTasks
    }

    enum LoadingImageError: Error, Equatable, LocalizedError {
        case matrixCodeGenerationFailed
    }

    struct State: Equatable {
        var isShowAlert = false
        var groupedPrescription: GroupedPrescription
        var loadingState: LoadingState<UIImage, LoadingImageError> = .idle
    }

    enum Action: Equatable {
        case close
        case loadMatrixCodeImage(screenSize: CGSize)
        case matrixCodeImageReceived(LoadingState<UIImage, LoadingImageError>)
        case redeemedOnSavedReceived(Bool)
    }

    struct Environment {
        var schedulers: Schedulers
        let matrixCodeGenerator: ErxTaskMatrixCodeGenerator
        let taskRepositoryAccess: ErxTaskRepositoryAccess
        let fhirDateFormatter: FHIRDateFormatter
    }

    static let reducer = Reducer { state, action, environment in

        switch action {
        case let .loadMatrixCodeImage(screenSize):
            return environment.matrixCodeGenerator.publishedMatrixCode(
                for: state.groupedPrescription.prescriptions,
                with: environment.calcMatrixCodeSize(screenSize: screenSize)
            )
            .mapError { _ in
                LoadingImageError.matrixCodeGenerationFailed
            }
            .catchToLoadingStateEffect()
            .map(RedeemMatrixCodeDomain.Action.matrixCodeImageReceived)
            .cancellable(id: Token.cancelMatrixCodeGeneration, cancelInFlight: true)
            .receive(on: environment.schedulers.main)
            .eraseToEffect()

        case let .matrixCodeImageReceived(loadingState):
            state.loadingState = loadingState
            UIScreen.main.brightness = CGFloat(1.0)
            // User story defines that scanned erxTasks should be automatically
            // redeemed when this screen was successfully shown.
            return environment.redeemAndSaveErxTasks(erxTasks: state.groupedPrescription.prescriptions)
        case let .redeemedOnSavedReceived(success):
            return .none
        case .close:
            return .cancel(id: Token.cancelMatrixCodeGeneration)
        }
    }
}

extension RedeemMatrixCodeDomain.Environment {
    /// Will calculate the size for the matrix code based on current screen size
    func calcMatrixCodeSize(screenSize: CGSize) -> CGSize {
        let padding: CGFloat = 16
        let minScreenDimension = min(screenSize.width, screenSize.height)
        let pixelDimension = Int(minScreenDimension - 2 * padding)
        return CGSize(width: pixelDimension, height: pixelDimension)
    }

    func redeemAndSaveErxTasks(erxTasks: [ErxTask])
    -> Effect<RedeemMatrixCodeDomain.Action, Never> {
        let redeemedErxTasks = erxTasks
            .filter { $0.source == .scanner }
            .map { erxTask -> ErxTask in
                var copy = erxTask
                copy.redeemedOn = fhirDateFormatter.string(from: Date())
                return copy
            }
        return taskRepositoryAccess.save(redeemedErxTasks)
            .first()
            .receive(on: schedulers.main)
            .replaceError(with: false)
            .map(RedeemMatrixCodeDomain.Action.redeemedOnSavedReceived)
            .eraseToEffect()
            .cancellable(id: RedeemMatrixCodeDomain.Token.redeemAndSaveErxTasks)
    }
}

extension RedeemMatrixCodeDomain {
    enum Dummies {
        static let demoSessionContainer = ChangeableUserSessionContainer(
            initialUserSession: DemoSessionContainer(),
            schedulers: Schedulers()
        )
        static let state = State(groupedPrescription: GroupedPrescription.Dummies.twoPrescriptions)
        static let environment = Environment(
            schedulers: Schedulers(),
            matrixCodeGenerator: DefaultErxTaskMatrixCodeGenerator(),
            taskRepositoryAccess: demoSessionContainer.userSession.erxTaskRepository,
            fhirDateFormatter: FHIRDateFormatter.shared
        )
        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: RedeemMatrixCodeDomain.Reducer.empty,
                  environment: environment)
        }
    }
}
