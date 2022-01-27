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

import Foundation
import SwiftUI

extension View {
    /// Generate several variations of device / display modes for SwiftUI `PreviewProvider` views.
    ///
    /// - Parameters:
    ///   - selection: Selection of parameters you want to draw your preview view variations from
    ///   - oneDark: display also one device (default configuration) set to dark mode
    /// - Returns: `Group` of views that display `self` in multiple variations.
    func generateVariations(selection: PreviewsVariations.Options = .all, oneDark: Bool = true) -> some View {
        let devices = (selection.rawValue & PreviewsVariations.Options.devices.rawValue) != 0 ?
            PreviewsVariations.Devices.all : [PreviewsVariations.Devices.main]
        let contentSizes = (selection.rawValue & PreviewsVariations.Options.contentSizes.rawValue) != 0 ?
            PreviewsVariations.ContentSizeCategories.all : [PreviewsVariations.ContentSizeCategories.main]

        return
            Group {
                if oneDark {
                    self.previewDevice(PreviewDevice(rawValue: PreviewsVariations.Devices.main))
                        .environment(\.sizeCategory, PreviewsVariations.ContentSizeCategories.main)
                        .previewDisplayName("\(PreviewsVariations.Devices.main) dark mode")
                        .preferredColorScheme(.dark)
                }

                ForEach(contentSizes, id: \.self) { contentSize in
                    ForEach(devices, id: \.self) { device in
                        self.previewDevice(PreviewDevice(rawValue: device))
                            .environment(\.sizeCategory, contentSize)
                            .previewDisplayName("\(device) \(contentSize)")
                    }
                }
            }
    }
}

enum PreviewsVariations {
    struct Options: OptionSet {
        let rawValue: Int

        static let devices = Options(rawValue: 1 << 0)
        static let contentSizes = Options(rawValue: 1 << 1)
        static let all: Options = [.devices, .contentSizes]
    }

    enum Devices: String, CaseIterable {
        case iPhone11 = "iPhone 11"
        case iPhoneSE1stGen = "iPhone SE (1st generation)"
        case iPhone8Plus = "iPhone 8 Plus"

        static var all: [String] {
            Devices.allCases.map(\.rawValue)
        }

        static var main: String {
            Devices.iPhone11.rawValue
        }
    }

    enum ContentSizeCategories {
        static var all: [ContentSizeCategory] {
            [
                ContentSizeCategory.medium,
                ContentSizeCategory.extraSmall,
                ContentSizeCategory.accessibilityExtraExtraExtraLarge,
            ]
        }

        static var main: ContentSizeCategory {
            ContentSizeCategory.medium
        }
    }
}
