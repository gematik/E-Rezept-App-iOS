//
//  Copyright (c) 2021 gematik GmbH
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

import SwiftUI

struct PasswordStrengthView: View {
    let strength: PasswordStrength

    private var strengthColor: Color {
        switch strength {
        case .none,
             .veryWeak:
            return Color(.systemRed)
        case .weak:
            return Color(.systemOrange)
        case .medium:
            return Color(.systemYellow)
        case .strong,
             .veryStrong,
             .excellent:
            return Color(.systemGreen)
        }
    }

    private var strengthPercent: CGFloat {
        switch strength {
        case .none:
            return 0.05
        case .veryWeak:
            return 0.15
        case .weak:
            return 0.3
        case .medium:
            return 0.45
        case .strong:
            return 0.75
        case .veryStrong:
            return 1.0
        case .excellent:
            return 1.0
        }
    }

    private var strengthValue: LocalizedStringKey {
        switch strength {
        case .none,
             .veryWeak:
            return L10n.ctlTxtPasswordStrengthAccessiblityValueVeryWeak
        case .weak:
            return L10n.ctlTxtPasswordStrengthAccessiblityValueWeak
        case .medium:
            return L10n.ctlTxtPasswordStrengthAccessiblityValueMedium
        case .strong:
            return L10n.ctlTxtPasswordStrengthAccessiblityValueStrong
        case .veryStrong,
             .excellent:
            return L10n.ctlTxtPasswordStrengthAccessiblityValueVeryStrong
        }
    }

    private func width(for availableSpace: CGFloat) -> CGFloat {
        availableSpace * strengthPercent
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geometry in
                HStack {
                    Rectangle()
                        .frame(width: width(for: geometry.size.width), height: 8, alignment: .leading)
                        .cornerRadius(6)
                        .foregroundColor(strengthColor)

                    Spacer(minLength: 0)
                }
                .background(Colors.systemGray6)
                .cornerRadius(6)
            }
            .frame(
                minWidth: 100,
                idealWidth: nil,
                maxWidth: .infinity,
                minHeight: 8,
                idealHeight: 8,
                maxHeight: 8,
                alignment: .center
            )

            Text(L10n.ctlTxtPasswordStrengthHint)
                .font(.caption)
                .foregroundColor(Color(.secondaryLabel))
        }
        .accessibilityElement(children: .combine)
        .accessibility(value: Text(strengthValue))
    }
}

struct PasswordStrength_Preview: PreviewProvider {
    struct Wrapper: View {
        @State var strength: PasswordStrength = .none

        var body: some View {
            VStack {
                PasswordStrengthView(strength: strength)

                // swiftlint:disable:next multiline_arguments
                Stepper("Password strength: \(strength.rawValue)") {
                    withAnimation {
                        strength = PasswordStrength(rawValue: strength.rawValue + 1) ?? strength
                    }
                } onDecrement: {
                    withAnimation {
                        strength = PasswordStrength(rawValue: strength.rawValue - 1) ?? strength
                    }
                }
            }
        }
    }

    static var previews: some View {
        VStack(spacing: 0) {
            VStack {
                Wrapper()
                Text("All variations:")
                PasswordStrengthView(strength: .none)
                PasswordStrengthView(strength: .veryWeak)
                PasswordStrengthView(strength: .weak)
                PasswordStrengthView(strength: .medium)
                PasswordStrengthView(strength: .strong)
                PasswordStrengthView(strength: .veryStrong)
                PasswordStrengthView(strength: .excellent)
            }
        }
        .padding()
        .frame(width: nil, height: 500, alignment: .center)
    }
}
