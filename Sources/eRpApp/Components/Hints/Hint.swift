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

import eRpStyleKit
import SwiftUI

@dynamicMemberLookup
/// sourcery: StringAssetInitialized
struct Hint<Action: Equatable>: Equatable, Identifiable { // swiftlint:disable:this attributes
    let id: String
    var title: String?
    var message: String?
    var actionText: LocalizedStringKey?
    var actionImageName: String?
    var action: Action?
    let image: AccessibilityImage
    var closeAction: Action?
    var style: Style = .neutral
    var buttonStyle: ButtonStyle = .quaternary
    var imageStyle: ImageStyle = .topAligned

    subscript<A>(dynamicMember keyPath: KeyPath<Style, A>) -> A {
        style[keyPath: keyPath]
    }

    subscript<A>(dynamicMember keyPath: KeyPath<ImageStyle, A>) -> A {
        imageStyle[keyPath: keyPath]
    }

    enum Style {
        case important
        case awareness
        case neutral

        var textColor: Color {
            switch self {
            case .important: return Colors.systemLabel
            case .awareness: return Colors.systemLabel
            case .neutral: return Colors.systemLabel
            }
        }

        var actionColor: Color {
            switch self {
            case .important: return Colors.red900
            case .awareness: return Colors.primary700
            case .neutral: return Colors.primary700
            }
        }

        var borderColor: Color {
            switch self {
            case .important: return Colors.red100
            case .awareness: return Colors.primary100
            case .neutral: return Colors.separator
            }
        }

        var fillColor: Color {
            switch self {
            case .important: return Colors.red100
            case .awareness: return Colors.primary100
            case .neutral: return Colors.systemBackgroundTertiary
            }
        }
    }

    enum ButtonStyle {
        case quaternary
        case tertiary
    }

    enum ImageStyle {
        case topAligned
        case bottomAligned

        var isTopAligned: Bool {
            switch self {
            case .topAligned: return true
            case .bottomAligned: return false
            }
        }

        var isBottomAligned: Bool {
            switch self {
            case .topAligned: return false
            case .bottomAligned: return true
            }
        }
    }
}

extension Hint {
    var hasAction: Bool {
        actionText != nil && action != nil
    }

    var hasCloseAction: Bool {
        closeAction != nil
    }
}
