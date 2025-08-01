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

import CoreData
import eRpKit
import IDP

extension ProfileEntity {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }()

    static func from(profile: Profile,
                     encoder: JSONEncoder = ProfileEntity.encoder,
                     in context: NSManagedObjectContext) -> ProfileEntity {
        ProfileEntity(profile: profile, encoder: encoder, in: context)
    }

    convenience init(profile: Profile,
                     encoder: JSONEncoder = ProfileEntity.encoder,
                     in context: NSManagedObjectContext) {
        self.init(context: context)

        let gIdEntry = try? encoder.encode(profile.gIdEntry)

        identifier = profile.identifier
        name = profile.name
        created = profile.created
        givenName = profile.givenName
        familyName = profile.familyName
        displayName = profile.displayName
        insurance = profile.insurance
        insuranceId = profile.insuranceId
        insuranceIK = profile.insuranceIK
        insuranceType = profile.insuranceType.rawValue
        color = profile.color.rawValue
        image = profile.image.rawValue
        userImageData = profile.userImageData
        lastAuthenticated = profile.lastAuthenticated
        // Note: update of erxTasks is set when saving tasks in `save(tasks:)`
        hideWelcomeDrawerOnMainView = profile.hideWelcomeDrawerOnMainView
        hidePkvConsentDrawerOnMainView = profile.hidePkvConsentDrawerOnMainView
        shouldAutoUpdateNameAtNextLogin = profile.shouldAutoUpdateNameAtNextLogin
        self.gIdEntry = gIdEntry
    }
}

extension Profile {
    // swiftlint:disable function_body_length
    init?(entity: ProfileEntity,
          dateProvider: () -> Date,
          decoder: JSONDecoder = JSONDecoder()) {
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

        let hideWelcomeDrawerOnMainView = entity.hideWelcomeDrawerOnMainView
        let hidePkvConsentDrawerOnMainView = entity.hidePkvConsentDrawerOnMainView
        let shouldAutoUpdateNameAtNextLogin = entity.shouldAutoUpdateNameAtNextLogin

        let gIdEntry = try? decoder.decode(KKAppDirectory.Entry.self, from: entity.gIdEntry ?? Data())

        self.init(
            name: name,
            identifier: identifier,
            created: created,
            givenName: entity.givenName,
            familyName: entity.familyName,
            displayName: entity.displayName,
            insurance: entity.insurance,
            insuranceId: entity.insuranceId,
            insuranceIK: entity.insuranceIK,
            insuranceType: insuranceType,
            color: profileColor,
            image: profilePicture,
            userImageData: entity.userImageData,
            lastAuthenticated: entity.lastAuthenticated,
            erxTasks: tasks,
            hideWelcomeDrawerOnMainView: hideWelcomeDrawerOnMainView,
            hidePkvConsentDrawerOnMainView: hidePkvConsentDrawerOnMainView,
            shouldAutoUpdateNameAtNextLogin: shouldAutoUpdateNameAtNextLogin,
            gIdEntry: gIdEntry
        )
    }
    // swiftlint:enable function_body_length
}
