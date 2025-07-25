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
extension DefaultTextButton {
    init(text: StringAsset, a11y: String, style: Style = .primary, action: @escaping () -> Void) {
        self.init(text: text.key, a11y: a11y, style: style, action: action)
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
extension FormTextFieldView {
    init(placeholder: String? = nil, subtitle: StringAsset? = nil, text: Binding<String>, showSeparator: Bool = true) {
    self.init(placeholder: placeholder, subtitle: subtitle?.key, text: text, showSeparator: showSeparator)
    }
}
extension HeadernoteView {
    init(text: StringAsset, a11y: String) {
        self.init(text: text.key, a11y: a11y)
    }
}
extension Hint {
    init(id: String, title: String? = nil, message: String? = nil, actionText: StringAsset, actionImageName: String? = nil, action: Action? = nil, image: AccessibilityImage, closeAction: Action? = nil, style: Style = .neutral, buttonStyle: ButtonStyle = .quaternary, imageStyle: ImageStyle = .topAligned) {
        self.init(id: id, title: title, message: message, actionText: actionText.key, actionImageName: actionImageName, action: action, image: image, closeAction: closeAction, style: style, buttonStyle: buttonStyle, imageStyle: imageStyle)
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
extension ListCellView {
    init(iconSize: CGFloat = 22, sfSymbolName: String, text: StringAsset) {
        self.init(iconSize: iconSize, sfSymbolName: sfSymbolName, text: text.key)
    }
}
extension LoadingPrimaryButton {
    init(text: StringAsset, isLoading: Bool, action: @escaping () -> Void) {
        self.init(text: text.key, isLoading: isLoading, action: action)
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
extension PrimaryTextButton {
    init(text: StringAsset, a11y: String, image: Image? = nil, isEnabled: Bool = true, useFullWidth: Bool = true, action: @escaping () -> Void) {
        self.init(text: text.key, a11y: a11y, image: image, isEnabled: isEnabled, useFullWidth: useFullWidth, action: action)
    }
}
extension PrimaryTextButtonBorder {
    init(text: StringAsset, note: StringAsset? = nil, image: Image? = nil, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.init(text: text.key, note: note?.key, image: image, isEnabled: isEnabled, action: action)
    }
}
extension PrimaryTextFieldView {
    init(placeholder: StringAsset, text: Binding<String>, a11y: String) {
        self.init(placeholder: placeholder.key, text: text, a11y: a11y)
    }
}
extension ProgressTile {
    init(icon: String, title: StringAsset, description: String? = nil, state: State) {
        self.init(icon: icon, title: title.key, description: description, state: state)
    }
}
extension SectionHeaderView {
    init(text: StringAsset, a11y: String) {
        self.init(text: text.key, a11y: a11y)
    }
}
extension SecureFieldWithReveal {
    init(titleKey: StringAsset, accessibilityLabelKey: StringAsset? = nil, text: Binding<String>, textContentType: UITextContentType? = nil, backgroundColor: Color = Color(.systemBackground), onCommit: @escaping () -> Void) {
    self.init(titleKey: titleKey.key, accessibilityLabelKey: accessibilityLabelKey?.key, text: text, textContentType: textContentType, backgroundColor: backgroundColor, onCommit: onCommit)
    }
}
extension SelectionCell {
    init(text: StringAsset, description: StringAsset? = nil, a11y: String, iconSize: CGFloat = 22, systemImage: String? = nil, isOn: Binding<Bool>) {
        self.init(text: text.key, description: description?.key, a11y: a11y, iconSize: iconSize, systemImage: systemImage, isOn: isOn)
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
extension TertiaryListButton {
    init(text: StringAsset, imageName: String? = SFSymbolName.refresh, accessibilityIdentifier: String, action: @escaping () -> Void) {
        self.init(text: text.key, imageName: imageName, accessibilityIdentifier: accessibilityIdentifier, action: action)
    }
}
extension Tile {
    init(iconSystemName: String? = nil, iconName: String? = nil, title: StringAsset, description: StringAsset? = nil, discloseIcon: String, isDisabled: Bool = false) {
        self.init(iconSystemName: iconSystemName, iconName: iconName, title: title.key, description: description?.key, discloseIcon: discloseIcon, isDisabled: isDisabled)
    }
}
extension ToggleCell {
    init(text: StringAsset, a11y: String, systemImage: String? = nil, textColor: Color = Colors.text, iconColor: Color = Colors.primary500, backgroundColor: Color = Colors.systemBackgroundTertiary, isToggleOn: Binding<Bool> = .constant(false), isDisabled: Binding<Bool> = .constant(false)) {
    self.init(text: text.key, a11y: a11y, systemImage: systemImage, textColor: textColor, iconColor: iconColor, backgroundColor: backgroundColor, isToggleOn: isToggleOn, isDisabled: isDisabled)
    }
}
