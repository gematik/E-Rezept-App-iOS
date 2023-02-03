// swiftlint:disable:this file_name
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

import AVS
import Combine
@testable import eRpApp
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
extension PrescriptionRepository {}
extension AVSSession {}
extension AVSTransactionDataStore {}
extension DeviceSecurityManagerSessionStorage {}
extension ERPDateFormatter {}
extension LoginHandler {}
extension MatrixCodeGenerator {}
extension ModelMigrating {}
extension NFCHealthCardPasswordController {}
extension NFCSignatureProvider {}
extension RedeemService {}
extension RegisteredDevicesService {}
extension Routing {}
extension SearchHistory {}
extension SecureEnclaveSignatureProvider {}
extension ShipmentInfoDataStore {}
extension PrescriptionRepository {}
extension ProfileBasedSessionProvider {}
extension ProfileDataStore {}
extension ProfileOnlineChecker {}
extension ProfileSecureDataWiper {}
extension Tracker {}
extension UserDataStore {}
extension UserProfileService {}
extension UsersSessionContainer {}
extension UserSessionProvider {}
// sourcery:end
