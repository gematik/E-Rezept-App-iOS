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

import ComposableArchitecture
import SwiftUI

// MARK: - SwiftUI View

extension View {
    func navigationBarTitle(
        _ stringAsset: StringAsset,
        displayMode: NavigationBarItem.TitleDisplayMode
    ) -> some View {
        navigationBarTitle(stringAsset.key, displayMode: displayMode)
    }

    func navigationTitle(_ stringAsset: StringAsset) -> some View {
        navigationTitle(stringAsset.key)
    }
}

extension ProgressView where CurrentValueLabel == EmptyView {
    init(_ stringAsset: StringAsset) where Label == Text {
        self.init(stringAsset.key)
    }
}

// MARK: Custom components

extension TextState {
    init(_ stringAsset: StringAsset) {
        self.init(stringAsset.key)
    }
}

extension SectionHeaderView {
    init(text: StringAsset, a11y: String) {
        self.init(text: text.key, a11y: a11y)
    }
}

extension ListCellView {
    init(sfSymbolName: String, text stringAsset: StringAsset) {
        self.init(sfSymbolName: sfSymbolName, text: stringAsset.key)
    }
}

extension GroupedPrescriptionListView.ListView.SectionPlaceholderView {
    init(text stringAsset: StringAsset) {
        self.init(text: stringAsset.key)
    }
}

extension GroupedPrescriptionListView.ListView.RefreshLoadingStateView {
    init(text stringAsset: StringAsset) {
        self.init(text: stringAsset.key)
    }
}

extension LegalNoticeView.LegalNoticeSectionView {
    init(title: StringAsset?, text: StringAsset) {
        self.init(title: title?.key, text: text.key)
    }
}

extension DestructiveTextButton {
    init(text stringAsset: StringAsset, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.init(text: stringAsset.key, isEnabled: isEnabled, action: action)
    }
}

extension OptInCell {
    init(text stringAsset: StringAsset, isOn: Binding<Bool>) {
        self.init(text: stringAsset.key, isOn: isOn)
    }
}

extension HeadernoteView {
    init(text stringAsset: StringAsset, a11y: String) {
        self.init(text: stringAsset.key, a11y: a11y)
    }
}

extension FootnoteView {
    init(text stringAsset: StringAsset, a11y: String) {
        self.init(text: stringAsset.key, a11y: a11y)
    }
}

extension IDPTokenView.TokenCell {
    init(title stringAsset: StringAsset, token: String) {
        self.init(title: stringAsset.key, token: token)
    }
}

extension LegalNoticeView.LegalNoticeContactView {
    init(
        title stringAsset: StringAsset,
        webLink: URL? = nil,
        emailLink: URL? = nil,
        phoneLink: URL? = nil
    ) {
        self.init(
            title: stringAsset.key,
            webLink: webLink,
            emailLink: emailLink,
            phoneLink: phoneLink
        )
    }
}

extension Hint {
    init(
        id: String, // swiftlint:disable:this identifier_name
        title: String? = nil,
        message: String? = nil,
        actionText stringAsset: StringAsset,
        action: Action? = nil,
        imageName: String,
        closeAction: Action? = nil,
        style: Style = .neutral,
        buttonStyle: ButtonStyle = .quaternary,
        imageStyle: ImageStyle = .topAligned
    ) {
        self.init(
            id: id,
            title: title,
            message: message,
            actionText: stringAsset.key,
            action: action,
            imageName: imageName,
            closeAction: closeAction,
            style: style,
            buttonStyle: buttonStyle,
            imageStyle: imageStyle
        )
    }
}

extension PrimaryTextButton {
    init(
        text stringAsset: StringAsset,
        a11y: String,
        image: Image? = nil,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.init(
            text: stringAsset.key,
            a11y: a11y,
            image: image,
            isEnabled: isEnabled,
            action: action
        )
    }
}

extension PrimaryTextButtonBorder {
    init(
        text stringAsset: StringAsset,
        image: Image? = nil,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.init(
            text: stringAsset.key,
            image: image,
            isEnabled: isEnabled,
            action: action
        )
    }
}

extension SecureFieldWithReveal {
    init(
        _ titleKey: StringAsset,
        accessibilityLabelKey: StringAsset? = nil,
        text: Binding<String>,
        textContentType: UITextContentType? = nil,
        onCommit: @escaping () -> Void
    ) {
        self.init(
            titleKey.key,
            accessibilityLabelKey: accessibilityLabelKey?.key,
            text: text,
            textContentType: textContentType,
            onCommit: onCommit
        )
    }
}

extension ToggleCell {
    init(
        text: StringAsset,
        a11y: String,
        systemImage: String? = nil,
        textColor: Color = Colors.text,
        iconColor: Color = Colors.primary500,
        backgroundColor: Color = Colors.systemBackgroundTertiary,
        isToggleOn: Binding<Bool> = .constant(false),
        isDisabled: Binding<Bool> = .constant(false)
    ) {
        self.init(
            text: text.key,
            a11y: a11y,
            systemImage: systemImage,
            textColor: textColor,
            iconColor: iconColor,
            backgroundColor: backgroundColor,
            isToggleOn: isToggleOn,
            isDisabled: isDisabled
        )
    }
}

extension SelectionCell {
    init(text: StringAsset,
         description: StringAsset? = nil,
         a11y: String,
         systemImage: String? = nil,
         isOn: Binding<Bool>) {
        self.init(
            text: text.key,
            description: description?.key,
            a11y: a11y,
            systemImage: systemImage,
            isOn: isOn
        )
    }
}

extension TertiaryListButton {
    init(
        text stringAsset: StringAsset,
        imageName: String? = SFSymbolName.refresh,
        accessibilityIdentifier: String,
        action: @escaping () -> Void
    ) {
        self.init(
            text: stringAsset.key,
            imageName: imageName,
            accessibilityIdentifier: accessibilityIdentifier,
            action: action
        )
    }
}

extension ProgressTile {
    init(
        icon: String,
        title stringAsset: StringAsset,
        description: String? = nil,
        state: State
    ) {
        self.init(
            icon: icon,
            title: stringAsset.key,
            description: description,
            state: state
        )
    }
}

extension AltRegistrationView.BiometryButton {
    init(
        text stringAsset: StringAsset,
        image: Image,
        backgroundColor: Color,
        action: @escaping () -> Void
    ) {
        self.init(
            text: stringAsset.key,
            image: image,
            backgroundColor: backgroundColor,
            action: action
        )
    }
}

extension OnboardingRegisterAuthenticationView.BiometryButton {
    init(
        text stringAsset: StringAsset,
        image: Image,
        backgroundColor: Color,
        action: @escaping () -> Void
    ) {
        self.init(
            text: stringAsset.key,
            image: image,
            backgroundColor: backgroundColor,
            action: action
        )
    }
}

extension MedicationRedeemView {
    init(
        text stringAsset: StringAsset,
        a11y: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) {
        self.init(
            text: stringAsset.key,
            a11y: a11y,
            isEnabled: isEnabled,
            action: action
        )
    }
}

extension MedicationDetailCellView {
    init(
        value: String? = nil,
        subtitle: String? = nil,
        title stringAsset: StringAsset,
        isLastInSection: Bool = false
    ) {
        self.init(
            value: value,
            subtitle: subtitle,
            title: stringAsset.key,
            isLastInSection: isLastInSection
        )
    }
}

extension MedicationInfoView.CodeInfo {
    init(code: String?, codeTitle stringAsset: StringAsset) {
        self.init(code: code, codeTitle: stringAsset.key)
    }
}

extension LoadingPrimaryButton {
    init(
        text stringAsset: StringAsset,
        isLoading: Bool,
        action: @escaping () -> Void
    ) {
        self.init(
            text: stringAsset.key,
            isLoading: isLoading,
            action: action
        )
    }
}

extension PrimaryTextFieldView {
    init(placeholder stringAsset: StringAsset, text: Binding<String>, a11y: String) {
        self.init(placeholder: stringAsset.key, text: text, a11y: a11y)
    }
}

extension Tile {
    init(
        iconSystemName: String?,
        title: StringAsset,
        description: StringAsset?,
        discloseIcon: String
    ) {
        self.init(
            iconSystemName: iconSystemName,
            title: title.key,
            description: description?.key,
            discloseIcon: discloseIcon
        )
    }
}

extension DetailedIconCellView {
    init(
        title stringAsset: StringAsset,
        value: String,
        imageName: String,
        a11y: String
    ) {
        self.init(
            title: stringAsset.key,
            value: value,
            imageName: imageName,
            a11y: a11y
        )
    }
}

extension DefaultTextButton {
    init(
        text stringAsset: StringAsset,
        a11y: String,
        style: Style,
        action: @escaping () -> Void
    ) {
        self.init(
            text: stringAsset.key,
            a11y: a11y,
            style: style,
            action: action
        )
    }
}
