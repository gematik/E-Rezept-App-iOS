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

import Combine
import CombineSchedulers
import Foundation
import XCTest

extension XCTestCase {
    /// Convenient method to wait for the passed publisher to ether return one result or throw with an error.
    /// If you would like to receive more than one value call `collectNext(_ count: Int)`
    /// on the publisher you test in advance.
    ///
    /// - Parameters:
    ///   - publisher: The publisher to test
    ///   - timeout: Time in seconds to wait for a result
    ///   - file: Filename of the calling file
    ///   - line: Line number of the calling function
    ///   - subscribeScheduler: Scheduler to subscribe on. Defaults to immediate
    ///   - receivingScheduler: Scheduler to subscribe on. Defaults to immediate
    /// - Throws: When no result has been received
    /// - Returns: the actual result of the publisher
    public func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 2.0,
        file: StaticString = #file,
        line: UInt = #line,
        subscribeScheduler: AnySchedulerOf<DispatchQueue> = .immediate,
        receivingScheduler: AnySchedulerOf<DispatchQueue> = .immediate
    ) throws -> T.Output {
        var result: Result<T.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")

        let cancellable = publisher
            .subscribe(on: subscribeScheduler)
            .receive(on: receivingScheduler)
            .sink(receiveCompletion: { completion in
                      switch completion {
                      case let .failure(error):
                          result = .failure(error)
                      case .finished:
                          break
                      }

                      expectation.fulfill()
                  },
                  receiveValue: { value in
                      result = .success(value)
                  })

        waitForExpectations(timeout: timeout)
        cancellable.cancel()

        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )

        return try unwrappedResult.get()
    }
}

extension Publisher {
    /// Collects the next `count` results before returning. Note that the first element is dropped!
    /// - Parameter count: Number of results to receive
    /// - Returns: Publisher with an array `count` results
    public func collectNext(_ count: Int) -> AnyPublisher<[Output], Failure> {
        dropFirst()
            .collect(count)
            .first()
            .eraseToAnyPublisher()
    }
}
