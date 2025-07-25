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

import ComposableArchitecture
import eRpStyleKit
import SwiftUI

struct Backport<Content> {
    let content: Content
}

extension View {
    var backport: Backport<Self> { Backport(content: self) }
}

// Backport of NavigationLink with Bindings
// Source: https://pointfreeco.github.io/swift-composable-architecture/1.8.0/documentation/composablearchitecture/treebasednavigation#Backwards-compatible-availability
// swiftlint:disable:previous line_length
@available(iOS, introduced: 13, deprecated: 16)
@available(macOS, introduced: 10.15, deprecated: 13)
@available(tvOS, introduced: 13, deprecated: 16)
@available(watchOS, introduced: 6, deprecated: 9)
extension NavigationLink {
    init<D, C: View>(
        item: Binding<D?>,
        @ViewBuilder destination: (D) -> C,
        @ViewBuilder label: () -> Label
    ) where Destination == C? {
        self.init(
            destination: item.wrappedValue.map(destination),
            isActive: Binding(
                get: { item.wrappedValue != nil },
                set: { isActive, transaction in
                    if !isActive {
                        item.transaction(transaction).wrappedValue = nil
                    }
                }
            ),
            label: label
        )
    }
}

// Backport of NavigationLink with Bindings
// Slightly modified to support onTap action
// Source: https://pointfreeco.github.io/swift-composable-architecture/1.8.0/documentation/composablearchitecture/treebasednavigation#Backwards-compatible-availability
// swiftlint:disable:previous line_length
@available(iOS, introduced: 13, deprecated: 16)
@available(macOS, introduced: 10.15, deprecated: 13)
@available(tvOS, introduced: 13, deprecated: 16)
@available(watchOS, introduced: 6, deprecated: 9)
extension NavigationLink {
    init<D, C: View>(
        item: Binding<D?>,
        onTap: @escaping () -> Void,
        @ViewBuilder destination: (D) -> C,
        @ViewBuilder label: () -> Label
    ) where Destination == C? {
        self.init(
            destination: item.wrappedValue.map(destination),
            isActive: Binding(
                get: { item.wrappedValue != nil },
                set: { isActive, transaction in
                    if !isActive {
                        item.transaction(transaction).wrappedValue = nil
                    } else {
                        onTap()
                    }
                }
            ),
            label: label
        )
    }
}

extension Binding {
    func isPresent<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        // swiftformat:disable all
        self._isPresent
        // swiftformat:enable all
    }
}

extension Optional {
    // swiftlint:disable:next identifier_name
    var _isPresent: Bool {
        get { self != nil }
        set {
            guard !newValue else { return }
            self = nil
        }
    }
}

extension View {
    @MainActor
    func snapshot() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        if let image = renderer.uiImage {
            return image
        }
        return nil
    }
}
