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

struct ProfileColorPicker: View {
    @Binding var color: ProfileColor

    var body: some View {
        HStack(spacing: 16) {
            ForEach(ProfileColor.allCases, id: \.self) { color in
                Image(systemName: SFSymbolName.checkmark)
                    .font(.headline)
                    .foregroundColor(Color(.secondaryLabel))
                    .opacity(color == self.color ? 1 : 0.01)
                    .frame(width: 40, height: 40, alignment: .center)
                    .background(
                        Circle()
                            .foregroundColor(color.background)
                            .border(color.border, width: 1, cornerRadius: 99)
                    )
                    .onTapGesture {
                        self.color = color
                    }
                    .accessibility(value: Text(color == self.color ? L10n.ctlTxtProfileColorPickerSelected
                            .key : ""))
                    .accessibility(label: Text(color.name, bundle: .module))
                    .accessibility(addTraits: .isButton)
            }
        }
        .accessibilityElement(children: .contain)
        .frame(maxWidth: .infinity, alignment: .center)
        .buttonStyle(BorderlessButtonStyle())
        .padding(.vertical, 24)
    }
}

struct ProfileColorPicker_Preview: PreviewProvider {
    static var previews: some View {
        ProfileColorPicker(color: .constant(ProfileColor.red))
    }
}

extension ProfileColor {
    var name: LocalizedStringKey {
        switch self {
        case .grey:
            return L10n.ctlTxtProfileColorPickerGrey.key
        case .yellow:
            return L10n.ctlTxtProfileColorPickerYellow.key
        case .red:
            return L10n.ctlTxtProfileColorPickerPink.key
        case .green:
            return L10n.ctlTxtProfileColorPickerGreen.key
        case .blue:
            return L10n.ctlTxtProfileColorPickerBlue.key
        }
    }
}
