//
//  Copyright (c) 2024 gematik GmbH
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

import eRpKit
import Foundation
import SwiftUI

public enum ProfilePicture: String, CaseIterable {
    case baby
    case boyWithCard
    case developer
    case doctorFemale
    case pharmacist
    case manWithPhone
    case oldDoctor
    case oldMan
    case oldWoman
    case doctorMale
    case pharmacist2
    case wheelchair
    case womanWithPhone
    case none

    var description: ImageAsset? {
        switch self {
        case .baby:
            return Asset.Profile.baby
        case .boyWithCard:
            return Asset.Profile.boyWithCard
        case .developer:
            return Asset.Profile.developer
        case .doctorFemale:
            return Asset.Profile.doctor
        case .pharmacist:
            return Asset.Profile.doctor2
        case .manWithPhone:
            return Asset.Profile.manWithPhone
        case .oldDoctor:
            return Asset.Profile.oldDoctor
        case .oldMan:
            return Asset.Profile.oldMan
        case .oldWoman:
            return Asset.Profile.oldWoman
        case .doctorMale:
            return Asset.Profile.pharmacist
        case .pharmacist2:
            return Asset.Profile.pharmacist2
        case .wheelchair:
            return Asset.Profile.wheelchair
        case .womanWithPhone:
            return Asset.Profile.womanWithPhone
        case .none:
            return .none
        }
    }

    var accessibility: StringAsset {
        switch self {
        case .baby:
            return L10n.profileTxtBaby
        case .boyWithCard:
            return L10n.profileTxtBoy
        case .developer:
            return L10n.profileTxtDeveloper
        case .doctorFemale:
            return L10n.profileTxtDoctorW
        case .pharmacist:
            return L10n.profileTxtPharmacist
        case .manWithPhone:
            return L10n.profileTxtMann
        case .oldDoctor:
            return L10n.profileTxtOldDoctor
        case .oldMan:
            return L10n.profileTxtOldMan
        case .oldWoman:
            return L10n.profileTxtOldWoman
        case .doctorMale:
            return L10n.profileTxtDoctor
        case .pharmacist2:
            return L10n.profileTxtPharmacistHandy
        case .wheelchair:
            return L10n.profileTxtBlindMan
        case .womanWithPhone:
            return L10n.profileTxtWoman
        case .none:
            return L10n.profileTxtNone
        }
    }
}

extension ProfilePicture {
    var erxPicture: Profile.ProfilePictureType {
        switch self {
        case .baby:
            return .baby
        case .boyWithCard:
            return .boyWithCard
        case .developer:
            return .developer
        case .doctorFemale:
            return .doctorFemale
        case .pharmacist:
            return .pharmacist
        case .manWithPhone:
            return .manWithPhone
        case .oldDoctor:
            return .oldDoctor
        case .oldMan:
            return .oldMan
        case .oldWoman:
            return .oldWoman
        case .doctorMale:
            return .doctorMale
        case .pharmacist2:
            return .pharmacist2
        case .wheelchair:
            return .wheelchair
        case .womanWithPhone:
            return .womanWithPhone
        case .none:
            return .none
        }
    }
}
