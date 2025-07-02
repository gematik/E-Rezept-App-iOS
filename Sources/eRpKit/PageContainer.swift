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

import Foundation

public struct PageContainer: Equatable {
    let numberOfElements: Int
    let pageSize: Int

    public var numberOfPages: Int {
        pages.count
    }

    public let pages: [Page]

    public init(forNumberOfElements: Int, pageSize: Int = 25) {
        numberOfElements = forNumberOfElements
        self.pageSize = pageSize

        pages = stride(from: 0, through: numberOfElements, by: pageSize)
            .enumerated()
            .map { index, offset in
                Page(name: String(index + 1), offset: offset, size: pageSize)
            }
    }
}

public struct Page: Equatable, Identifiable, Hashable {
    public init(name: String, offset: Int, size: Int) {
        self.name = name
        self.offset = offset
        self.size = size
    }

    public let name: String
    public let offset: Int
    public let size: Int

    public let id = UUID()
}
