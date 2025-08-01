// swiftlint:disable:this file_name
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

import AVS
import BfArM
import Combine
@testable import eRpFeatures
import eRpKit
import eRpLocalStorage
import Foundation
import IDP
import OpenSSL
import Pharmacy
import TrustStore
import VAUClient

// NOTE: Use (and migrate to) `AutoMockable` rather than `ProtocolMock`.

// sourcery:begin: AutoMockable
extension JWTSigner {}
extension SearchHistory {}
extension BfArMService {}
// sourcery:end

// sourcery:begin: ProtocolMock
extension ActivityIndicating {}
extension AuthenticationChallengeProvider {}
extension AVSSession {}
extension AVSTransactionDataStore {}
extension ChargeItemListDomainService {}
extension DeviceSecurityManagerSessionStorage {}
extension ERPDateFormatter {}
extension IDPSession {}
extension FeedbackReceiver {}
extension LoginHandler {}
extension MatrixCodeGenerator {}
extension MedicationScheduleStore {}
extension ModelMigrating {}
extension NFCHealthCardPasswordController {}
extension NFCSignatureProvider {}
extension PasswordStrengthTester {}
extension PrescriptionRepository {}
extension ProfileBasedSessionProvider {}
extension ProfileDataStore {}
extension ProfileOnlineChecker {}
extension ProfileSecureDataWiper {}
extension RedeemService {}
extension RegisteredDevicesService {}
extension Routing {}
extension SecureEnclaveSignatureProvider {}
extension SecureUserDataStore {}
extension ShipmentInfoDataStore {}
extension Tracker {}
extension UserDataStore {}
extension UserProfileService {}
extension UsersSessionContainer {}
extension UserSessionProvider {}
extension PagedAuditEventsController {}
extension AuditEventsService {}
extension PharmacyRepository {}
extension OrdersRepository {}
extension AppSecurityManager {}
extension KeychainAccessHelper {}
extension InternalCommunicationProtocol {}
// sourcery:end
