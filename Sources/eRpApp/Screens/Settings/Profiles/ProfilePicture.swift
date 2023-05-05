//
//  Copyright (c) 2023 gematik GmbH
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
    case doctor
    case doctor2
    case manWithPhone
    case oldDoctor
    case oldMan
    case oldWoman
    case pharmacist
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
        case .doctor:
            return Asset.Profile.doctor
        case .doctor2:
            return Asset.Profile.doctor2
        case .manWithPhone:
            return Asset.Profile.manWithPhone
        case .oldDoctor:
            return Asset.Profile.oldDoctor
        case .oldMan:
            return Asset.Profile.oldMan
        case .oldWoman:
            return Asset.Profile.oldWoman
        case .pharmacist:
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
        case .doctor:
            return .doctor
        case .doctor2:
            return .doctor2
        case .manWithPhone:
            return .manWithPhone
        case .oldDoctor:
            return .oldDoctor
        case .oldMan:
            return .oldMan
        case .oldWoman:
            return .oldMan
        case .pharmacist:
            return .pharmacist
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
