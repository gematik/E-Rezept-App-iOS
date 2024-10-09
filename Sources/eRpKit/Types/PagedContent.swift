//
//  Copyright (c) 2024 gematik GmbH
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

import Foundation

/// Container format for handling paged FHIR content.
public struct PagedContent<Content>: Equatable, Codable where Content: Equatable, Content: Codable {
    /// Initializes a PagedContent with a given content and an optional next page link.
    /// - Parameters:
    ///   - content: Actual content of this page.
    ///   - next: Set if the content of this page is not the last page, nil otherwise.
    public init(content: Content, next: URL?) {
        self.content = content
        self.next = next
    }

    /// Actual content of a page
    public let content: Content

    /// Link to the content of the next page
    public let next: URL?
}
