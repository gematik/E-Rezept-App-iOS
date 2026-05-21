// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import SwiftUI
import eRpStyleKit

/// AUTO GENERATED – DO NOT EDIT
///
/// use sourcery to update this file.

/// # StringAssetInitialized
///
/// Creates Extensions with initializer overloads to accept `StringAsset` parameters for all `LocalizedStringKey`.
///
/// # Usage
///
/// - Add `/// sourcery: StringAssetInitialized` to any struct that should be extended.
/// - Run `$ sourcery` to update or add extensions.






extension AnnotationBadge {
    init(text: StringAsset, bundle: Bundle? = nil) {
    self.init(text: text.key, bundle: bundle)
    }
}
extension AnnotationBadgeModifier {
    init(text: StringAsset, bundle: Bundle? = nil) {
    self.init(text: text.key, bundle: bundle)
    }
}
extension DetailedIconCellView {
    init(title: StringAsset, value: String, imageName: String, a11y: String) {
        self.init(title: title.key, value: value, imageName: imageName, a11y: a11y)
    }
}
extension FootnoteView {
    init(text: StringAsset, a11y: String) {
        self.init(text: text.key, a11y: a11y)
    }
}
extension KeyValuePair {
    init(key: StringAsset, value: StringAsset, bundle: Bundle? = nil) {
    self.init(key: key.key, value: value.key, bundle: bundle)
    }
    init(key: StringAsset, value: String, bundle: Bundle? = nil) {
    self.init(key: key.key, value: value, bundle: bundle)
    }
}
extension LegalNoticeView.LegalNoticeContactView {
    init(iconSize: CGFloat = 22, title: StringAsset, webLink: URL? = nil, emailLink: URL? = nil, phoneLink: URL? = nil) {
        self.init(iconSize: iconSize, title: title.key, webLink: webLink, emailLink: emailLink, phoneLink: phoneLink)
    }
}
extension LegalNoticeView.LegalNoticeSectionView {
    init(title: StringAsset? = nil, text: StringAsset) {
        self.init(title: title?.key, text: text.key)
    }
}
extension MedicationRedeemView {
    init(text: StringAsset, a11y: String, isEnabled: Bool = false, action: @escaping () -> Void) {
        self.init(text: text.key, a11y: a11y, isEnabled: isEnabled, action: action)
    }
}
extension OptInCell {
    init(text: StringAsset, isOn: Binding<Bool>) {
        self.init(text: text.key, isOn: isOn)
    }
}
extension ProgressTile {
    init(icon: String, title: StringAsset, description: String? = nil, state: State) {
        self.init(icon: icon, title: title.key, description: description, state: state)
    }
}
extension StatusView {
    init(title: StringAsset, foregroundColor: Color = Colors.systemLabel, backgroundColor: Color = Colors.systemBackgroundSecondary) {
        self.init(title: title.key, foregroundColor: foregroundColor, backgroundColor: backgroundColor)
    }
}
extension SubTitle {
    init(title: StringAsset, description: StringAsset? = nil, details: StringAsset? = nil, bundle: Bundle? = nil) {
    self.init(title: title.key, description: description?.key, details: details?.key, bundle: bundle)
    }
    init(title: String, details: StringAsset, bundle: Bundle? = nil) {
    self.init(title: title, details: details.key, bundle: bundle)
    }
    init(title: String, description: StringAsset, bundle: Bundle? = nil) {
    self.init(title: title, description: description.key, bundle: bundle)
    }
    init(title: StringAsset, description: String, bundle: Bundle? = nil) {
    self.init(title: title.key, description: description, bundle: bundle)
    }
}
extension SubTitleTop {
    init(subject: StringAsset, title: StringAsset? = nil, bundle: Bundle) {
    self.init(subject: subject.key, title: title?.key, bundle: bundle)
    }
}
extension Tile {
    init(iconSystemName: String? = nil, iconName: String? = nil, title: StringAsset, description: StringAsset? = nil, discloseIcon: String, isDisabled: Bool = false) {
        self.init(iconSystemName: iconSystemName, iconName: iconName, title: title.key, description: description?.key, discloseIcon: discloseIcon, isDisabled: isDisabled)
    }
}
