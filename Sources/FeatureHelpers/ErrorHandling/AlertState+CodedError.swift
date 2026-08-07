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

import CodedError
import ComposableArchitecture
import eRpResources

extension AlertState {
    /// Creates an alert state for the given error.
    public init(
        for error: CodedError,
        title: (() -> TextState)? = nil,
        @ButtonStateBuilder<Action> actions: () -> [ButtonState<Action>] = { [] }
    ) {
        let resultTitle: () -> TextState
        let resultDescription: () -> TextState

        if let title {
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
            actionsWithCancel.insert(.init(role: .cancel) { TextState(L10n.alertBtnOk) }, at: 0)
        }

        self.init(
            title: resultTitle,
            // swiftformat:disable:next --redundantReturn
            actions: { return actionsWithCancel },
            message: resultDescription
        )
    }
}

/// An alert state that can represent either an informational alert or an error alert with an
public enum ErpAlertState<Action: Equatable>: Equatable {
    // Support for @Reducer enum macros

    /// Needed for @Reducer enum macros
    public typealias State = Self
    /// Needed for @Reducer enum macros
    public typealias Action = Action

    public static func ==(lhs: ErpAlertState<Action>, rhs: ErpAlertState<Action>) -> Bool {
        switch (lhs, rhs) {
        case let (.info(lhsv), .info(rhsv)),
             let (.error(_, lhsv), .error(_, rhsv)):
            return lhsv == rhsv
        default:
            return false
        }
    }

    /// An informational alert
    case info(AlertState<Action>)
    /// An error alert with an associated error
    case error(error: CodedError, alertState: AlertState<Action>)

    /// The underlying alert state
    public var alert: AlertState<Action> {
        switch self {
        case let .info(alert):
            return alert
        case let .error(_, alertState):
            return alertState
        }
    }

    /// Creates an error alert state for the given error with a title from a string asset.
    public init(for error: CodedError, title: StringAsset) {
        self.init(for: error) {
            TextState(title)
        }
    }

    /// Creates an informational alert state from the given alert state.
    public init(_ info: AlertState<Action>) {
        self = .info(info)
    }

    /// Creates an error alert state for the given error with a title from a string asset.
    public init(
        for error: CodedError,
        title: StringAsset,
        @ButtonStateBuilder<Action> actions: () -> [ButtonState<Action>] = { [] }
    ) {
        self.init(
            for: error,
            title: { TextState(title) },
            actions: actions
        )
    }

    /// Creates an error alert state for the given error.
    public init(
        for error: CodedError,
        title: (() -> TextState)? = nil,
        @ButtonStateBuilder<Action> actions: () -> [ButtonState<Action>] = { [] }
    ) {
        self = .error(
            error: error,
            alertState: .init(for: error, title: title, actions: actions)
        )
    }

    /// Creates an informational alert state with a title from a string asset.
    public init(
        title: StringAsset,
        @ButtonStateBuilder<Action> actions: () -> [ButtonState<Action>] = { [] },
        message: StringAsset? = nil
    ) {
        if let message {
            self = .info(
                .init(
                    title: { TextState(title) },
                    actions: actions,
                    message: { TextState(message) } // swiftlint:disable:this trailing_closure
                )
            )
        } else {
            self = .info(.init(
                title: {
                    TextState(title)
                },
                actions: actions
            ))
        }
    }

    /// Creates an informational alert state.
    public init(
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

    /// Transforms the action of this alert state to a local action.
    public func pullback<LocalAction>(_ pullback: (Action) -> LocalAction) -> ErpAlertState<LocalAction> {
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
