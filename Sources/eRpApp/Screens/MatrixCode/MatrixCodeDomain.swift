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

import Combine
import ComposableArchitecture
import eRpKit
import SwiftUI
import ZXingObjC

struct MatrixCodeDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    // sourcery: CodedError = "023"
    enum LoadingImageError: Error, Equatable, LocalizedError {
        // sourcery: errorCode = "01"
        case matrixCodeGenerationFailed
    }

    enum MatrixCodeType: Equatable {
        case erxTask
        case erxChargeItem
    }

    struct State: Equatable {
        let type: MatrixCodeType
        var isShowAlert = false
        var erxTasks: [ErxTask] = []
        var erxChargeItem: ErxChargeItem?
        var loadingState: LoadingState<UIImage, LoadingImageError> = .idle
        var isZoomedIn = false
    }

    enum Action: Equatable {
        case closeButtonTapped
        case zoomButtonTapped
        case closeZoomTapped
        case loadMatrixCodeImage(screenSize: CGSize)

        case response(Response)

        enum Response: Equatable {
            case matrixCodeImageReceived(LoadingState<UIImage, LoadingImageError>)
            case redeemedOnSavedReceived(Bool)
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    // [REQ:gemSpec_eRp_FdV:A_20603] Usages of matrixCodeGenerator for code generation. UserProfile is neither part of
    // the screen nor the state.
    @Dependency(\.erxMatrixCodeGenerator) var erxMatrixCodeGenerator: ErxMatrixCodeGenerator
    @Dependency(\.erxTaskRepository) var taskRepository: ErxTaskRepository
    @Dependency(\.fhirDateFormatter) var fhirDateFormatter: FHIRDateFormatter
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    private func core(state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .closeButtonTapped:
            return .run { _ in
                await dismiss()
            }
        case .zoomButtonTapped:
            state.isZoomedIn = true
            return .none
        case .closeZoomTapped:
            state.isZoomedIn = false
            return .none
        case let .loadMatrixCodeImage(screenSize):
            switch state.type {
            case .erxTask:
                return .publisher(
                    erxMatrixCodeGenerator.publishedMatrixCode(
                        for: state.erxTasks,
                        with: calcMatrixCodeSize(screenSize: screenSize)
                    )
                    .mapError { _ in
                        LoadingImageError.matrixCodeGenerationFailed
                    }
                    .catchToLoadingStateEffect()
                    .map { .response(.matrixCodeImageReceived($0)) }
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
                )
            case .erxChargeItem:
                guard let chargeItem = state.erxChargeItem
                else { return .none }

                return .publisher(
                    erxMatrixCodeGenerator.publishedMatrixCode(
                        for: chargeItem,
                        with: calcMatrixCodeSize(screenSize: screenSize)
                    )
                    .mapError { _ in
                        LoadingImageError.matrixCodeGenerationFailed
                    }
                    .catchToLoadingStateEffect()
                    .map { .response(.matrixCodeImageReceived($0)) }
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
                )
            }
        case let .response(.matrixCodeImageReceived(loadingState)):
            state.loadingState = loadingState
            switch state.type {
            case .erxTask:
                // User story defines that scanned erxTasks should be automatically
                // redeemed when this screen was successfully shown.
                return redeemAndSaveErxTasks(erxTasks: state.erxTasks)
            case .erxChargeItem:
                return .none
            }
        case .response(.redeemedOnSavedReceived):
            return .none
        }
    }
}

extension MatrixCodeDomain {
    /// Will calculate the size for the matrix code based on current screen size
    func calcMatrixCodeSize(screenSize: CGSize) -> CGSize {
        let padding: CGFloat = 16
        let minScreenDimension = min(screenSize.width, screenSize.height)
        let pixelDimension = Int(minScreenDimension - 2 * padding)
        return CGSize(width: pixelDimension, height: pixelDimension)
    }

    func redeemAndSaveErxTasks(erxTasks: [ErxTask])
        -> EffectTask<MatrixCodeDomain.Action> {
        let redeemedErxTasks = erxTasks
            .filter { $0.source == .scanner }
            .map { erxTask -> ErxTask in
                var copy = erxTask
                copy.redeemedOn = fhirDateFormatter.string(from: Date())
                return copy
            }
        return .publisher(
            taskRepository.save(erxTasks: redeemedErxTasks)
                .first()
                .receive(on: schedulers.main)
                .replaceError(with: false)
                .map { .response(.redeemedOnSavedReceived($0)) }
                .eraseToAnyPublisher
        )
    }
}

extension MatrixCodeDomain {
    enum Dummies {
        static let demoSessionContainer = DummyUserSessionContainer()
        static let erxTaskState = State(
            type: .erxTask,
            erxTasks: Prescription.Dummies.prescriptions.map(\.erxTask)
        )

        static let erxChargeItemState = State(
            type: .erxChargeItem,
            // swiftlint:disable:next force_unwrapping
            erxChargeItem: ErxChargeItem(identifier: "123", fhirData: "123".data(using: .utf8)!, accessCode: "321")
        )

        static let store = Store(
            initialState: erxTaskState
        ) {
            MatrixCodeDomain()
        }

        static func storeFor(_ state: State) -> Store {
            Store(
                initialState: state
            ) {
                MatrixCodeDomain()
            }
        }
    }
}
