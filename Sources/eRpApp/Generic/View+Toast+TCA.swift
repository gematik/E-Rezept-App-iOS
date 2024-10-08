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

import eRpStyleKit
import SwiftUI

@_spi(Presentation)
@_spi(Internals)
import ComposableArchitecture

struct ToastState<Action: Equatable>: Equatable, Identifiable {
    // Support for @Reducer enum macros
    typealias State = Self
    typealias Action = Action

    let uuid = UUID()

    var id: UUID { uuid }

    let style: Style

    enum Style: Equatable {
        case simple(LocalizedStringKey)
        case twoLines(LocalizedStringKey, LocalizedStringKey)
        case action(LocalizedStringKey, ButtonState<Action>)
    }
}

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
    @ViewBuilder func toast<State, Action, ToastAction>(
        _ store: Store<PresentationState<State>, PresentationAction<Action>>,
        state toDestinationState: @escaping (State) -> ToastState<ToastAction>?,
        action fromDestinationAction: @escaping (ToastAction) -> Action
    ) -> some View {
        overlay {
            self.presentation(
                store: store, state: toDestinationState, action: fromDestinationAction
            ) { _, $isPresented, _ in
                let toastState: ToastState<ToastAction>? = store.withState {
                    $0.wrappedValue.flatMap(toDestinationState)
                }
                let toast: Toast? = toastState.map { toast in
                    switch toast.style {
                    case let .simple(text):
                        return Toast(uuid: toast.uuid, style: .simple(text, 2, .module))
                    case let .twoLines(upper, lower):
                        return Toast(uuid: toast.uuid, style: .twoLines(upper, lower, 2, .module))
                    case let .action(text, buttonState):
                        return Toast(uuid: toast.uuid, style: .action(
                            text,
                            Text(buttonState.label),
                            .module
                        ) {
                            store.send(
                                buttonState.action.action.map { .presented(fromDestinationAction($0)) } ?? .dismiss,
                                animation: .easeInOut
                            )
                        })
                    }
                }
                ToastContainerView(isPresented: $isPresented.animation(.easeInOut), toast: toast)
            }
        }
    }

    func toast<Action>(_ item: Binding<Store<ToastState<Action>, Action>?>) -> some View {
        overlay {
            let store = item.wrappedValue
            let toastState: ToastState<Action>? = store?.withState { $0 }

            let toast: Toast? = toastState.map { toast in
                switch toast.style {
                case let .simple(text):
                    return Toast(uuid: toast.uuid, style: .simple(text, 2, .module))
                case let .twoLines(upper, lower):
                    return Toast(uuid: toast.uuid, style: .twoLines(upper, lower, 2, .module))
                case let .action(text, buttonState):
                    return Toast(uuid: toast.uuid, style: .action(
                        text,
                        Text(buttonState.label),
                        .module
                    ) {
                        if let action = buttonState.action.action {
                            store?.send(
                                action, // .map { .presented($0) } ?? .dismiss,
                                animation: .easeInOut
                            )
                        }
                    })
                }
            }
            ToastContainerView(isPresented: item.isPresent(), toast: toast)
        }
    }
}

struct TCAToast_PreviewProvider: PreviewProvider {
    // sourcery: SkipSourcery
    @Reducer
    struct Domain {
        @Reducer(state: .equatable, action: .equatable)
        enum Destination {
            // sourcery: AnalyticsScreen = alert
            @ReducerCaseEphemeral
            case toast(ToastState<Toast>)

            enum Toast: Equatable {
                case customAction
            }
        }

        @ObservableState
        struct State: Equatable {
            var someState = "123"

            @Presents var destination: Destination.State?
        }

        enum Action: Equatable {
            case simpleText
            case twoLines
            case action

            case destination(PresentationAction<Destination.Action>)
        }

        var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .simpleText:
                    state.destination = .toast(.init(style: .simple("Simple")))
                    return .none
                case .twoLines:
                    state.destination = .toast(.init(style: .twoLines("upper line", LocalizedStringKey("lower line"))))
                    return .none
                case .action:
                    state
                        .destination =
                        .toast(.init(style: .action("Action",
                                                    .init(action: .send(.customAction), label: { TextState("abc") }))))
                    return .none
                case .destination(.presented(.toast(.customAction))):
                    state.destination = nil
                    return .none
                case .destination:
                    return .none
                }
            }
            .ifLet(\.$destination, action: \.destination)
        }
    }

    struct TestView: View {
        @Perception.Bindable var store: StoreOf<Domain>

        var body: some View {
            WithPerceptionTracking {
                VStack {
                    Spacer()
                    Button {
                        store.send(.simpleText, animation: .easeInOut)
                    } label: {
                        Text("Simple Text")
                    }
                    Button {
                        store.send(.twoLines, animation: .easeInOut)
                    } label: {
                        Text("Two Lines")
                    }
                    Button {
                        store.send(.action, animation: .easeInOut)
                    } label: {
                        Text("Toast with action")
                    }

                    Spacer()
                }
                .onAppear {
                    store.send(.action, animation: .easeInOut)
                }
                .frame(maxWidth: .infinity)
                .toast($store.scope(state: \.destination?.toast, action: \.destination.toast))
            }
        }
    }

    static var previews: some View {
        TestView(store: Store(initialState: .init()) {
            Domain()
                ._printChanges()
        })
    }
}
