// swiftlint:disable:this file_name
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

import AVS
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
extension SearchHistory {}
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
extension JWTSigner {}
extension AppSecurityManager {}
extension KeychainAccessHelper {}
// sourcery:end
