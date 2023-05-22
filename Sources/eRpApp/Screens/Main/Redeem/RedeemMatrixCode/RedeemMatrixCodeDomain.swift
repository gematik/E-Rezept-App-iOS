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

struct RedeemMatrixCodeDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    /// Provides an Effect that need to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> EffectTask<T> {
        EffectTask<T>.cancel(ids: Token.allCases)
    }

    enum Token: CaseIterable, Hashable {
        case cancelMatrixCodeGeneration
        case redeemAndSaveErxTasks
    }

    // sourcery: CodedError = "023"
    enum LoadingImageError: Error, Equatable, LocalizedError {
        // sourcery: errorCode = "01"
        case matrixCodeGenerationFailed
    }

    struct State: Equatable {
        var isShowAlert = false
        var erxTasks: [ErxTask]
        var loadingState: LoadingState<UIImage, LoadingImageError> = .idle
    }

    enum Action: Equatable {
        case closeButtonTapped
        case loadMatrixCodeImage(screenSize: CGSize)

        case response(Response)
        case delegate(Delegate)

        enum Response: Equatable {
            case matrixCodeImageReceived(LoadingState<UIImage, LoadingImageError>)
            case redeemedOnSavedReceived(Bool)
        }

        enum Delegate: Equatable {
            case close
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.erxTaskMatrixCodeGenerator) var matrixCodeGenerator: ErxTaskMatrixCodeGenerator
    @Dependency(\.erxTaskRepository) var taskRepository: ErxTaskRepository
    @Dependency(\.fhirDateFormatter) var fhirDateFormatter: FHIRDateFormatter

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
    }

    private func core(state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .closeButtonTapped:
            return .task { .delegate(.close) }
        case let .loadMatrixCodeImage(screenSize):
            return matrixCodeGenerator.publishedMatrixCode(
                for: state.erxTasks,
                with: calcMatrixCodeSize(screenSize: screenSize)
            )
            .mapError { _ in
                LoadingImageError.matrixCodeGenerationFailed
            }
            .catchToLoadingStateEffect()
            .map { .response(.matrixCodeImageReceived($0)) }
            .cancellable(id: Token.cancelMatrixCodeGeneration, cancelInFlight: true)
            .receive(on: schedulers.main)
            .eraseToEffect()

        case let .response(.matrixCodeImageReceived(loadingState)):
            state.loadingState = loadingState
            UIScreen.main.brightness = CGFloat(1.0)
            // User story defines that scanned erxTasks should be automatically
            // redeemed when this screen was successfully shown.
            return redeemAndSaveErxTasks(erxTasks: state.erxTasks)
        case .response(.redeemedOnSavedReceived):
            return .none
        case .delegate(.close):
            return .cancel(id: Token.cancelMatrixCodeGeneration)
        }
    }
}

extension RedeemMatrixCodeDomain {
    /// Will calculate the size for the matrix code based on current screen size
    func calcMatrixCodeSize(screenSize: CGSize) -> CGSize {
        let padding: CGFloat = 16
        let minScreenDimension = min(screenSize.width, screenSize.height)
        let pixelDimension = Int(minScreenDimension - 2 * padding)
        return CGSize(width: pixelDimension, height: pixelDimension)
    }

    func redeemAndSaveErxTasks(erxTasks: [ErxTask])
        -> EffectTask<RedeemMatrixCodeDomain.Action> {
        let redeemedErxTasks = erxTasks
            .filter { $0.source == .scanner }
            .map { erxTask -> ErxTask in
                var copy = erxTask
                copy.redeemedOn = fhirDateFormatter.string(from: Date())
                return copy
            }
        return taskRepository.save(erxTasks: redeemedErxTasks)
            .first()
            .receive(on: schedulers.main)
            .replaceError(with: false)
            .map { .response(.redeemedOnSavedReceived($0)) }
            .eraseToEffect()
            .cancellable(id: RedeemMatrixCodeDomain.Token.redeemAndSaveErxTasks)
    }
}

extension RedeemMatrixCodeDomain {
    enum Dummies {
        static let demoSessionContainer = DummyUserSessionContainer()
        static let state = State(
            erxTasks: Prescription.Dummies.prescriptions.map(\.erxTask)
        )

        static let store = Store(initialState: state,
                                 reducer: RedeemMatrixCodeDomain())

        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: RedeemMatrixCodeDomain())
        }
    }
}
