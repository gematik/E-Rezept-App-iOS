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
import eRpKit
import Foundation
import HTTPClient

/// Interface for the app to the BfArM endpoint
public protocol BfArMService {
    /// Loads the `BfArMDiGaDetails` by its pzn from the endpoint
    ///
    /// - Parameters:
    ///   - pzn: The pzn of the DiGa
    /// - Returns: `BfArMDiGaDetails` or thorws error
    func fetchBfArMInfo(pzn: String) async throws -> BfArMDiGaDetails?
}

/// Repository for the app to the BfArM layer
public struct DefaultBfArMService: BfArMService {
    private let session: BfArMSession

    /// Default initializer of `DefaultBfArMService`
    /// - Parameters:
    ///   - session: `BfArMSession` session
    public init(
        session: BfArMSession
    ) {
        self.session = session
    }

    public func fetchBfArMInfo(pzn: String) async throws -> BfArMDiGaDetails? {
        var bfarmInfo = try await session.fetchBfArMInfo(pzn: pzn)
        guard let url = bfarmInfo?.iconUrl else { return bfarmInfo }
        bfarmInfo?.iconData = try await session.fetchCachedImage(url: url)
        return bfarmInfo
    }
}
