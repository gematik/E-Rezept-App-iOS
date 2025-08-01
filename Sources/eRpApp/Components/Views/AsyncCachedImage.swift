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

import Dependencies
import Sharing
import SwiftUI

@MainActor
struct AsyncCachedImage<ImageView: View, PlaceholderView: View>: View {
    var url: URL?
    @ViewBuilder var content: (Image) -> ImageView
    @ViewBuilder var placeholder: () -> PlaceholderView

    @State var image: UIImage?

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> ImageView,
        @ViewBuilder placeholder: @escaping () -> PlaceholderView
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        VStack {
            if let uiImage = image {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .onAppear {
                        Task {
                            image = await loadImage(url: url)
                        }
                    }
            }
        }
    }
}

extension AsyncCachedImage {
    /// Loads image from cache otherwise from remote url
    public func loadImage(url: URL?) async -> UIImage? {
        @Dependency(\.urlSession) var urlSession
        @Shared(.asyncImageCache) var cache
        do {
            guard let url else { return nil }
            // Check if the image is cached already
            if let cachedData = cache[url] {
                return UIImage(data: cachedData)
            } else {
                let (data, _) = try await urlSession.data(from: url)
                // Save image into cache
                _ = $cache.withLock { $0.updateValue(data, forKey: url) }
                guard let image = UIImage(data: data) else { return nil }
                return image
            }
        } catch {
            return nil
        }
    }
}

extension SharedReaderKey
    where Self == InMemoryKey<[URL: Data]>.Default {
    /// stored in memory
    public static var asyncImageCache: Self {
        Self[.inMemory("async_cached_images"), default: [:]]
    }
}
