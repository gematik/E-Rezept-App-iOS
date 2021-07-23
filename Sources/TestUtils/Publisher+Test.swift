//
//  Copyright (c) 2021 gematik GmbH
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
import CombineSchedulers
import Foundation
import XCTest

extension Publisher {
    /// Convenience method for Combine Publisher tests that wait on the calling thread/queue and
    /// subscribe and receive on the global queue and only return from the method when either the
    /// Publisher has published (once) or the timeout time has been exceeded
    ///
    /// - Parameters:
    ///   - timeout: time in seconds
    ///   - file: filename
    ///   - line: line number
    ///   - expectations: assertion closure for the emitted/published Output
    public func test(
        timeout: TimeInterval = 2.0,
        file: StaticString = #file,
        line: UInt = #line,
        failure: @escaping (Failure) -> Void = { error in XCTFail("Publisher threw (unexpected) error: \(error)") },
        expectations: @escaping (Output) -> Void = { _ in },
        subscribeScheduler: AnySchedulerOf<DispatchQueue> = AnyScheduler.immediate,
        receivingScheduler: AnySchedulerOf<DispatchQueue> = AnyScheduler.immediate
    ) {
        let semaphore = DispatchSemaphore(value: 0)
        let cancellable = subscribe(on: subscribeScheduler)
            .receive(on: receivingScheduler)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    failure(error)
                }
                semaphore.signal()
            }, receiveValue: { value in
                expectations(value)
            })
        let timeoutTime = DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(timeout * 1000))
        if case .timedOut = semaphore.wait(timeout: timeoutTime) {
            cancellable.cancel()
            XCTFail("Test timed out", file: file, line: line)
        }
    }
}
