// Generated using Sourcery 1.6.1 — https://github.com/krzysztofzablocki/Sourcery
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






extension AltRegistrationView.BiometryButton {
    init(text: StringAsset, image: Image, backgroundColor: Color, action: @escaping () -> Void) {
        self.init(text: text.key, image: image, backgroundColor: backgroundColor, action: action)
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
extension GroupedPrescriptionListView.ListView.RefreshLoadingStateView {
    init(scale: CGFloat = 1, text: StringAsset) {
        self.init(scale: scale, text: text.key)
    }
}
extension GroupedPrescriptionListView.ListView.SectionPlaceholderView {
    init(text: StringAsset) {
        self.init(text: text.key)
    }
}
extension HeadernoteView {
    init(text: StringAsset, a11y: String) {
        self.init(text: text.key, a11y: a11y)
    }
}
extension Hint {
    init(id: String, title: String? = nil, message: String? = nil, actionText: StringAsset, action: Action? = nil, imageName: String, closeAction: Action? = nil, style: Style = .neutral, buttonStyle: ButtonStyle = .quaternary, imageStyle: ImageStyle = .topAligned) {
        self.init(id: id, title: title, message: message, actionText: actionText.key, action: action, imageName: imageName, closeAction: closeAction, style: style, buttonStyle: buttonStyle, imageStyle: imageStyle)
    }
}
extension IDPTokenView.TokenCell {
    init(title: StringAsset, token: String) {
        self.init(title: title.key, token: token)
    }
}
extension KeyValuePair {
    init(key: StringAsset, value: StringAsset) {
    self.init(key: key.key, value: value.key)
    }
    init(key: StringAsset, value: String) {
    self.init(key: key.key, value: value)
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
extension MedicationDetailCellView {
    init(value: String? = nil, subtitle: String? = nil, title: StringAsset, isLastInSection: Bool = false) {
        self.init(value: value, subtitle: subtitle, title: title.key, isLastInSection: isLastInSection)
    }
}
extension MedicationInfoView.CodeInfo {
    init(code: String? = nil, codeTitle: StringAsset, accessibilityId: String) {
        self.init(code: code, codeTitle: codeTitle.key, accessibilityId: accessibilityId)
    }
}
extension MedicationRedeemView {
    init(text: StringAsset, a11y: String, isEnabled: Bool = false, action: @escaping () -> Void) {
        self.init(text: text.key, a11y: a11y, isEnabled: isEnabled, action: action)
    }
}
extension OnboardingRegisterAuthenticationView.BiometryButton {
    init(text: StringAsset, image: Image, backgroundColor: Color, action: @escaping () -> Void) {
        self.init(text: text.key, image: image, backgroundColor: backgroundColor, action: action)
    }
}
extension OptInCell {
    init(text: StringAsset, isOn: Binding<Bool>) {
        self.init(text: text.key, isOn: isOn)
    }
}
extension PrimaryTextButton {
    init(text: StringAsset, a11y: String, image: Image? = nil, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.init(text: text.key, a11y: a11y, image: image, isEnabled: isEnabled, action: action)
    }
}
extension PrimaryTextButtonBorder {
    init(text: StringAsset, image: Image? = nil, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.init(text: text.key, image: image, isEnabled: isEnabled, action: action)
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
    init(titleKey: StringAsset, accessibilityLabelKey: StringAsset? = nil, text: Binding<String>, textContentType: UITextContentType? = nil, onCommit: @escaping () -> Void) {
    self.init(titleKey: titleKey.key, accessibilityLabelKey: accessibilityLabelKey?.key, text: text, textContentType: textContentType, onCommit: onCommit)
    }
}
extension SelectionCell {
    init(text: StringAsset, description: StringAsset? = nil, a11y: String, iconSize: CGFloat = 22, systemImage: String? = nil, isOn: Binding<Bool>) {
        self.init(text: text.key, description: description?.key, a11y: a11y, iconSize: iconSize, systemImage: systemImage, isOn: isOn)
    }
}
extension SubTitle {
    init(title: StringAsset, description: StringAsset? = nil, details: StringAsset? = nil) {
    self.init(title: title.key, description: description?.key, details: details?.key)
    }
    init(title: String, description: StringAsset) {
    self.init(title: title, description: description.key)
    }
    init(title: StringAsset, description: String) {
    self.init(title: title.key, description: description)
    }
}
extension SubTitleTop {
    init(subject: StringAsset, title: StringAsset? = nil) {
    self.init(subject: subject.key, title: title?.key)
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
