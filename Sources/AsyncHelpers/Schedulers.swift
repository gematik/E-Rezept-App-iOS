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

import CombineSchedulers
import Dependencies
import Foundation

/// A structure holding various schedulers for different types of work.
public struct Schedulers {
    /// The main (UI) scheduler
    public let main: AnySchedulerOf<DispatchQueue>
    /// The network I/O scheduler
    public let networkIO: AnySchedulerOf<DispatchQueue>
    /// The serial I/O scheduler
    public let serialIO: AnySchedulerOf<DispatchQueue>
    /// The compute scheduler
    public let compute: AnySchedulerOf<DispatchQueue>

    /// Initializes the schedulers
    public init(
        uiScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler(),
        networkScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global(qos: .default).eraseToAnyScheduler(),
        ioScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue(label: "serial").eraseToAnyScheduler(),
        computeScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue(label: "compute", attributes: .concurrent)
            .eraseToAnyScheduler()
    ) {
        main = uiScheduler
        networkIO = networkScheduler
        serialIO = ioScheduler
        compute = computeScheduler
    }
}

extension Schedulers {
    /// A scheduler set that uses immediate schedulers for all types of work, suitable for use in tests.
    public static var immediate = Schedulers(
        uiScheduler: .immediate,
        networkScheduler: .immediate,
        ioScheduler: .immediate,
        computeScheduler: .immediate
    )
}

// MARK: TCA Dependency

extension Schedulers: DependencyKey {
    /// The live value of the schedulers, using appropriate dispatch queues.
    public static let liveValue = Schedulers()

    /// A preview value of the schedulers, using appropriate dispatch queues.
    public static let previewValue = Schedulers()

    /// A test value of the schedulers, using immediate schedulers.
    public static let testValue = Schedulers()
}

extension DependencyValues {
    /// Access to the schedulers dependency.
    public var schedulers: Schedulers {
        get { self[Schedulers.self] }
        set { self[Schedulers.self] = newValue }
    }
}
