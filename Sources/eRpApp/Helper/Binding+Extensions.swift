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

import SwiftUI

extension Binding {
    /// Filter the input of the binding
    /// - Parameter transformation: Transform all input on the binding with a given transformation.
    /// - Returns: A binding that transforms all input with the given closure.
    func transformInput(_ transformation: @escaping (Value) -> Value) -> Self {
        Binding<Value>(get: {
            self.wrappedValue
        }, set: { value in
            self.wrappedValue = transformation(value)
        })
    }
}

extension Binding {
    /// Trigger a closure whenever the value of the binding changes
    /// - Parameter onDidSet: Closure that is called, whenever a value is set.
    /// - Returns: A binding that will notify a closure `onDidSet` whenever the binding is set.
    func onDidSet(_ onDidSet: @escaping (Value) -> Void) -> Self {
        Binding<Value>(get: {
            self.wrappedValue
        }, set: { value in
            self.wrappedValue = value
            onDidSet(value)
        })
    }
}

extension Binding where Value == String {
    func filterCharacters(to characterSet: CharacterSet = CharacterSet.decimalDigits) -> Self {
        transformInput { value -> String in
            value.trimmingCharacters(in: characterSet.inverted)
        }
    }

    func prefix(_ prefix: Int) -> Self {
        transformInput { value -> String in
            String(value.prefix(prefix))
        }
    }
}
