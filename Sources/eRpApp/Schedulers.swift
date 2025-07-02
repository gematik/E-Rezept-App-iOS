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
import IDP

struct Schedulers {
    let main: AnySchedulerOf<DispatchQueue>
    let networkIO: AnySchedulerOf<DispatchQueue>
    let serialIO: AnySchedulerOf<DispatchQueue>
    let compute: AnySchedulerOf<DispatchQueue>

    init(
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
    static var immediate = Schedulers(
        uiScheduler: .immediate,
        networkScheduler: .immediate,
        ioScheduler: .immediate,
        computeScheduler: .immediate
    )
}

extension Schedulers: IDPSchedulers {}

// MARK: TCA Dependency

extension Schedulers: DependencyKey {
    static let liveValue = Schedulers()

    static let previewValue = Schedulers()
}

extension DependencyValues {
    var schedulers: Schedulers {
        get { self[Schedulers.self] }
        set { self[Schedulers.self] = newValue }
    }
}
