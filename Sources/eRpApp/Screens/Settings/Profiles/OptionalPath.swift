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

// The following is heavily inspired by https://github.com/pointfreeco/isowords ❤️

import CasePaths
import ComposableArchitecture
import Foundation

protocol TCAPath {
    associatedtype Root
    associatedtype Value
    func extract(from root: Root) -> Value?
    func set(into root: inout Root, _ value: Value)
}

extension WritableKeyPath: TCAPath {
    func extract(from root: Root) -> Value? {
        root[keyPath: self]
    }

    func set(into root: inout Root, _ value: Value) {
        root[keyPath: self] = value
    }
}

extension CasePath: TCAPath {
    func set(into root: inout Root, _ value: Value) {
        root = embed(value)
    }
}

struct OptionalPath<Root, Value>: TCAPath {
    private let _extract: (Root) -> Value?
    private let _set: (inout Root, Value) -> Void

    init(
        extract: @escaping (Root) -> Value?,
        set: @escaping (inout Root, Value) -> Void
    ) {
        _extract = extract
        _set = set
    }

    func extract(from root: Root) -> Value? {
        _extract(root)
    }

    func set(into root: inout Root, _ value: Value) {
        _set(&root, value)
    }

    init(
        _ keyPath: WritableKeyPath<Root, Value?>
    ) {
        self.init(
            extract: { $0[keyPath: keyPath] },
            set: { $0[keyPath: keyPath] = $1 }
        )
    }

    init(
        _ casePath: CasePath<Root, Value>
    ) {
        self.init( // swiftlint:disable:this trailing_closure
            extract: casePath.extract(from:),
            set: { $0 = casePath.embed($1) }
        )
    }

    func appending<AppendedValue>(
        path: OptionalPath<Value, AppendedValue>
    ) -> OptionalPath<Root, AppendedValue> {
        .init(
            extract: { self.extract(from: $0).flatMap(path.extract(from:)) },
            set: { root, appendedValue in
                guard var value = self.extract(from: root) else { return }
                path.set(into: &value, appendedValue)
                self.set(into: &root, value)
            }
        )
    }

    func appending<AppendedValue>(
        path: CasePath<Value, AppendedValue>
    ) -> OptionalPath<Root, AppendedValue> {
        appending(path: .init(path))
    }

    func appending<AppendedValue>(
        path: WritableKeyPath<Value, AppendedValue>
    ) -> OptionalPath<Root, AppendedValue> {
        .init(
            extract: { self.extract(from: $0).map { $0[keyPath: path] } },
            set: { root, appendedValue in
                guard var value = self.extract(from: root) else { return }
                value[keyPath: path] = appendedValue
                self.set(into: &root, value)
            }
        )
    }
}

extension CasePath {
    func appending<AppendedValue>(
        path: OptionalPath<Value, AppendedValue>
    ) -> OptionalPath<Root, AppendedValue> {
        OptionalPath(self).appending(path: path)
    }

    func appending<AppendedValue>(
        path: WritableKeyPath<Value, AppendedValue>
    ) -> OptionalPath<Root, AppendedValue> {
        OptionalPath(self).appending(path: path)
    }
}

extension WritableKeyPath {
    func appending<AppendedValue>(
        path: OptionalPath<Value, AppendedValue>
    ) -> OptionalPath<Root, AppendedValue> {
        OptionalPath(
            extract: { path.extract(from: $0[keyPath: self]) },
            set: { root, appendedValue in path.set(into: &root[keyPath: self], appendedValue) }
        )
    }

    func appending<AppendedValue>(
        path: CasePath<Value, AppendedValue>
    ) -> OptionalPath<Root, AppendedValue> {
        appending(path: .init(path))
    }
}

extension OptionalPath where Root == Value {
    static var `self`: OptionalPath {
        .init(.self)
    }
}

extension OptionalPath where Root == Value? {
    static var some: OptionalPath {
        .init(/Optional.some)
    }
}

// This file will probably be removed when transitioning to pointfree navigation
// swiftlint:disable identifier_name function_body_length
extension Reducer {
    func _pullback<GlobalState, GlobalAction, GlobalEnvironment, StatePath, ActionPath>(
        state toLocalState: StatePath,
        action toLocalAction: ActionPath,
        environment toLocalEnvironment: @escaping (GlobalEnvironment) -> Environment,
        breakpointOnNil: Bool = true,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Reducer<GlobalState, GlobalAction, GlobalEnvironment>
        where
        StatePath: TCAPath, StatePath.Root == GlobalState, StatePath.Value == State,
        ActionPath: TCAPath, ActionPath.Root == GlobalAction, ActionPath.Value == Action {
        .init { globalState, globalAction, globalEnvironment in

            guard let localAction = toLocalAction.extract(from: globalAction)
            else { return .none }

            guard var localState = toLocalState.extract(from: globalState)
            else {
                #if DEBUG
                if breakpointOnNil {
                    fputs(
                        """
                        ---
                        Warning: Reducer._pullback@\(file):\(line)

                        "\(globalAction)" was received by an optional reducer when its state was \
                        "nil". This can happen for a few reasons:

                        * The optional reducer was combined with or run from another reducer that set \
                        "\(State.self)" to "nil" before the optional reducer ran. Combine or run optional \
                        reducers before reducers that can set their state to "nil". This ensures that \
                        optional reducers can handle their actions while their state is still non-"nil".

                        * An active effect emitted this action while state was "nil". Make sure that effects
                        for this optional reducer are canceled when optional state is set to "nil".

                        * This action was sent to the store while state was "nil". Make sure that actions \
                        for this reducer can only be sent to a view store when state is non-"nil". In \
                        SwiftUI applications, use "IfLetStore".
                        ---

                        """,
                        stderr
                    )
                    raise(SIGTRAP)
                }
                #endif
                return .none
            }

            let effect =
                self.run(&localState, localAction, toLocalEnvironment(globalEnvironment))
                    .map { localAction -> GlobalAction in
                        var globalAction = globalAction
                        toLocalAction.set(into: &globalAction, localAction)
                        return globalAction
                    }
            toLocalState.set(into: &globalState, localState)
            return effect
        }
    }
}
