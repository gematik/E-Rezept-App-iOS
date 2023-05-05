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

import ComposableArchitecture

extension MainDomain {
    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            case createProfile(CreateProfileDomain.State)
            case editProfilePicture(EditProfilePictureDomain.State)
            case editName(EditProfileNameDomain.State)
            case scanner(ScannerDomain.State)
            case deviceSecurity(DeviceSecurityDomain.State)
            case cardWall(CardWallIntroductionDomain.State)
            case prescriptionArchive(PrescriptionArchiveDomain.State)
            case prescriptionDetail(PrescriptionDetailDomain.State)
            case redeem(RedeemMethodsDomain.State)
            case welcomeDrawer
            case alert(ErpAlertState<MainDomain.Action>)
        }

        enum Action: Equatable {
            case createProfileAction(action: CreateProfileDomain.Action)
            case editProfilePictureAction(action: EditProfilePictureDomain.Action)
            case editProfileNameAction(action: EditProfileNameDomain.Action)
            case scanner(action: ScannerDomain.Action)
            case deviceSecurity(action: DeviceSecurityDomain.Action)
            case cardWall(action: CardWallIntroductionDomain.Action)
            case prescriptionArchiveAction(action: PrescriptionArchiveDomain.Action)
            case prescriptionDetailAction(action: PrescriptionDetailDomain.Action)
            case redeemMethods(action: RedeemMethodsDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.createProfile,
                action: /Action.createProfileAction
            ) {
                CreateProfileDomain()
            }
            Scope(
                state: /State.editProfilePicture,
                action: /Action.editProfilePictureAction
            ) {
                EditProfilePictureDomain()
            }
            Scope(
                state: /State.editName,
                action: /Action.editProfileNameAction
            ) {
                EditProfileNameDomain()
            }
            Scope(
                state: /State.scanner,
                action: /Action.scanner
            ) {
                ScannerDomain()
            }
            Scope(
                state: /State.deviceSecurity,
                action: /Action.deviceSecurity
            ) {
                DeviceSecurityDomain()
            }
            Scope(
                state: /State.cardWall,
                action: /Action.cardWall
            ) {
                CardWallIntroductionDomain()
            }
            Scope(
                state: /State.prescriptionArchive,
                action: /Action.prescriptionArchiveAction
            ) {
                PrescriptionArchiveDomain()
            }
            Scope(
                state: /State.prescriptionDetail,
                action: /Action.prescriptionDetailAction
            ) {
                PrescriptionDetailDomain()
            }
            Scope(
                state: /State.redeem,
                action: /Action.redeemMethods
            ) {
                RedeemMethodsDomain()
            }
        }
    }
}
