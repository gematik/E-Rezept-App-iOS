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
import CoreData
import eRpKit

class PagedEntityController<Entity: NSManagedObject, Element> {
    let context: NSManagedObjectContext
    let baseRequest: NSFetchRequest<Entity>
    let mapping: (Entity) -> Element

    init(
        for request: NSFetchRequest<Entity>,
        mapping: @escaping (Entity) -> Element,
        in context: NSManagedObjectContext
    ) {
        self.context = context
        baseRequest = request
        self.mapping = mapping
    }

    func getPageContainer() -> PageContainer? {
        guard let numberOfElements = try? context.count(for: baseRequest) else {
            return nil
        }

        return PageContainer(forNumberOfElements: numberOfElements)
    }

    func getPage(_ page: Page) -> AnyPublisher<[Element], LocalStoreError> {
        let request = baseRequest.copy() as! NSFetchRequest<Entity> // swiftlint:disable:this force_cast
        request.fetchOffset = page.offset
        request.fetchLimit = page.size

        return context
            .publisher(for: request)
            .map { [mapping] in $0.map(mapping) }
            .mapError(LocalStoreError.read)
            .eraseToAnyPublisher()
    }
}
