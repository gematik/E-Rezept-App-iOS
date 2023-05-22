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

import CoreData
import eRpKit

extension ProfileEntity {
    static func from(profile: Profile,
                     in context: NSManagedObjectContext) -> ProfileEntity {
        ProfileEntity(profile: profile, in: context)
    }

    convenience init(profile: Profile, in context: NSManagedObjectContext) {
        self.init(context: context)
        identifier = profile.identifier
        name = profile.name
        created = profile.created
        givenName = profile.givenName
        familyName = profile.familyName
        insurance = profile.insurance
        insuranceId = profile.insuranceId
        insuranceType = profile.insuranceType.rawValue
        color = profile.color.rawValue
        image = profile.image.rawValue
        userImageData = profile.userImageData
        lastAuthenticated = profile.lastAuthenticated
        // Note: update of erxTasks is set when saving tasks in `save(tasks:)`
    }
}

extension Profile {
    init?(entity: ProfileEntity, dateProvider: () -> Date) {
        guard let identifier = entity.identifier,
              let name = entity.name,
              let created = entity.created else {
            return nil
        }
        var profilePicture: Profile.ProfilePictureType = .none
        if let picture = entity.image {
            profilePicture = Profile.ProfilePictureType(rawValue: picture) ?? .none
        }

        var profileColor: Profile.Color = .grey
        if let color = entity.color {
            profileColor = Profile.Color(rawValue: color) ?? .grey
        }
        let insuranceType: Profile.InsuranceType
        if let rawInsuranceType = entity.insuranceType {
            insuranceType = Profile.InsuranceType(rawValue: rawInsuranceType) ?? .unknown
        } else {
            insuranceType = .unknown
        }

        let tasks: [ErxTask]

        if let inputTasks = entity.erxTasks {
            let mapped: [ErxTask] = inputTasks.compactMap { erxTaskEntity in
                if let entity = erxTaskEntity as? ErxTaskEntity {
                    return ErxTask(entity: entity, dateProvider: dateProvider)
                }
                return nil
            }
            tasks = mapped
        } else {
            tasks = []
        }

        self.init(
            name: name,
            identifier: identifier,
            created: created,
            givenName: entity.givenName,
            familyName: entity.familyName,
            insurance: entity.insurance,
            insuranceId: entity.insuranceId,
            insuranceType: insuranceType,
            color: profileColor,
            image: profilePicture,
            userImageData: entity.userImageData,
            lastAuthenticated: entity.lastAuthenticated,
            erxTasks: tasks
        )
    }
}
