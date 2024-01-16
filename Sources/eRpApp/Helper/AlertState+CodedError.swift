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

extension AlertState {
    init(
        for error: CodedError,
        title: (() -> TextState)? = nil,
        @ButtonStateBuilder<Action> actions: () -> [ButtonState<Action>] = { [] }
    ) {
        let resultTitle: () -> TextState
        let resultDescription: () -> TextState

        if let title = title {
            resultTitle = title
            resultDescription = { TextState(error.descriptionAndSuggestionWithErrorList) }
        } else {
            if error.recoverySuggestion != nil {
                resultTitle = { TextState(error.localizedDescription) }
                resultDescription = { TextState(error.recoverySuggestionWithErrorList) }
            } else {
                resultTitle = { TextState(L10n.errTitleGeneric) }
                resultDescription = { TextState(error.localizedDescriptionWithErrorList) }
            }
        }

        var actionsWithCancel = actions()
        if !actionsWithCancel.contains(where: { $0.role == .cancel }) {
            actionsWithCancel.insert(.cancel(TextState(L10n.alertBtnOk)), at: 0)
        }

        self.init(
            title: resultTitle,
            // swiftformat:disable:next --redundantReturn
            actions: { return actionsWithCancel },
            message: resultDescription
        )
    }
}

enum ErpAlertState<Action: Equatable>: Equatable {
    static func ==(lhs: ErpAlertState<Action>, rhs: ErpAlertState<Action>) -> Bool {
        switch (lhs, rhs) {
        case let (.info(lhsv), .info(rhsv)),
             let (.error(_, lhsv), .error(_, rhsv)):
            return lhsv == rhsv
        default:
            return false
        }
    }

    case info(AlertState<Action>)
    case error(error: CodedError, alertState: AlertState<Action>)

    var alert: AlertState<Action> {
        switch self {
        case let .info(alert):
            return alert
        case let .error(_, alertState):
            return alertState
        }
    }

    init(for error: CodedError, title: StringAsset) {
        self.init(for: error) {
            TextState(title.key)
        }
    }

    init(_ info: AlertState<Action>) {
        self = .info(info)
    }

    init(
        for error: CodedError,
        title: StringAsset,
        @ButtonStateBuilder<Action> actions: () -> [ButtonState<Action>] = { [] }
    ) {
        self.init(
            for: error,
            title: { TextState(title.key) },
            actions: actions
        )
    }

    init(
        for error: CodedError,
        title: (() -> TextState)? = nil,
        @ButtonStateBuilder<Action> actions: () -> [ButtonState<Action>] = { [] }
    ) {
        self = .error(
            error: error,
            alertState: .init(for: error, title: title, actions: actions)
        )
    }

    init(
        title: StringAsset,
        @ButtonStateBuilder<Action> actions: () -> [ButtonState<Action>] = { [] },
        message: StringAsset? = nil
    ) {
        if let message {
            self = .info(.init(
                title: { TextState(title.key) },
                actions: actions,
                message: { TextState(message.key) }
            ))
        } else {
            self = .info(.init(
                title: {
                    TextState(title.key)
                },
                actions: actions
            ))
        }
    }

    init(
        title: () -> TextState,
        @ButtonStateBuilder<Action> actions: () -> [ButtonState<Action>] = { [] },
        message: (() -> TextState)? = nil
    ) {
        self = .info(.init(
            title: title,
            actions: actions,
            message: message
        ))
    }

    func pullback<LocalAction>(_ pullback: (Action) -> LocalAction) -> ErpAlertState<LocalAction> {
        switch self {
        case let .info(alertState):
            return .info(
                alertState.map { $0.map { pullback($0) } }
            )
        case let .error(error: error, alertState: alertState):
            return .error(
                error: error,
                alertState: alertState.map { $0.map { pullback($0) } }
            )
        }
    }
}

import SwiftUI

extension View {
    /// Displays an alert when then store's state becomes non-`nil`, and dismisses it when it becomes
    /// `nil`.
    ///
    /// - Parameters:
    ///   - store: A store that is focused on ``PresentationState`` and ``PresentationAction`` for an
    ///     alert.
    ///   - toDestinationState: A transformation to extract alert state from the presentation state.
    ///   - fromDestinationAction: A transformation to embed alert actions into the presentation
    ///     action.
    @ViewBuilder func alert<State, Action, ButtonAction>(
        _ store: Store<PresentationState<State>, PresentationAction<Action>>,
        state toDestinationState: @escaping (State) -> ErpAlertState<ButtonAction>?,
        action fromDestinationAction: @escaping (ButtonAction) -> Action
    ) -> some View {
        alert(store: store, state: { toDestinationState($0)?.alert }, action: fromDestinationAction)
    }
}
