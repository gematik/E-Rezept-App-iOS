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

enum ProgressIndicator: CaseIterable, Equatable, Identifiable {
    case first
    case second
    case third

    var id: Self { self }

    var name: String {
        switch self {
        case .first: return "1"
        case .second: return "2"
        case .third: return "3"
        }
    }

    var last: Self {
        ProgressIndicator.allCases.last ?? .third
    }
}

struct OnboardingProgressView: View {
    var currentPage: ProgressIndicator

    var body: some View {
        HStack {
            ForEach(ProgressIndicator.allCases) { page in
                Capsule(style: .continuous)
                    .frame(width: 40, height: 12)
                    .foregroundColor(
                        currentPage == page ? Colors.primary : Colors.primary200
                    )
            }
        }
        .accessibility(identifier: A11y.onboarding.progress.onbAuthImgProgress)
        .accessibilityLabel(Text(L10n.onbTxtProgressOf(currentPage.name, currentPage.last.name)))
    }
}
