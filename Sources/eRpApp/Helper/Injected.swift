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

/// Will be deprecated soon, do not use it.
///
/// Use this property wrapper to  inject dependencies from a type conforming to the `AppContainerType` protocol.
/// Dependencies are resolved by passing a related `keyPath` for the service
///
/// To use `Injected` you provide a dependency injection container that should be used for the injection,
/// followed by the `keyPath` to the service to be inject, a name and the type of the service:
///
/// 	@Injected(container: YourDIContainer(), \.userStore) var userDefaultsStore: UserDataStore
///
/// If you omitted the dependency injection container the default container will be used
///
/// 	@Injected(\.userSessionProvider) var userSessionProvider: UserSessionProvider
///
@propertyWrapper
class Injected<Service> {
    private var service: Service?
    private var ref: Globals
    private var keyPath: KeyPath<Globals, Service>

    /// Initializer for the `Injected` property wrapper.
    ///
    /// - Parameters:
    ///   - container: dependency injection container that is used to load the dependency
    ///   - keyPath: keyPath that is used to resolve the injected service
    init(container _: Globals = globals, _ keyPath: KeyPath<Globals, Service>) {
        ref = globals
        self.keyPath = keyPath
    }

    /// value of the actual injection
    var wrappedValue: Service {
        get {
            guard let service = service else {
                let resolvedService = ref[keyPath: keyPath]
                self.service = resolvedService
                return resolvedService
            }
            return service
        }
        set {
            service = newValue
        }
    }
}
