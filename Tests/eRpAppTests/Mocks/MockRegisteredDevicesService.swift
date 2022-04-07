//
//  Copyright (c) 2022 gematik GmbH
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

import Combine
@testable import eRpApp
import Foundation
import IDP

// MARK: - MockRegisteredDevicesService -

final class MockRegisteredDevicesService: RegisteredDevicesService {
    // MARK: - registeredDevices

    var registeredDevicesForCallsCount = 0
    var registeredDevicesForCalled: Bool {
        registeredDevicesForCallsCount > 0
    }

    var registeredDevicesForReceivedProfileId: UUID?
    var registeredDevicesForReceivedInvocations: [UUID] = []
    var registeredDevicesForReturnValue: AnyPublisher<PairingEntries, RegisteredDevicesServiceError>!
    var registeredDevicesForClosure: ((UUID) -> AnyPublisher<PairingEntries, RegisteredDevicesServiceError>)?

    func registeredDevices(for profileId: UUID) -> AnyPublisher<PairingEntries, RegisteredDevicesServiceError> {
        registeredDevicesForCallsCount += 1
        registeredDevicesForReceivedProfileId = profileId
        registeredDevicesForReceivedInvocations.append(profileId)
        return registeredDevicesForClosure.map { $0(profileId) } ?? registeredDevicesForReturnValue
    }

    // MARK: - deviceId

    var deviceIdForCallsCount = 0
    var deviceIdForCalled: Bool {
        deviceIdForCallsCount > 0
    }

    var deviceIdForReceivedProfileId: UUID?
    var deviceIdForReceivedInvocations: [UUID] = []
    var deviceIdForReturnValue: AnyPublisher<String?, Never>!
    var deviceIdForClosure: ((UUID) -> AnyPublisher<String?, Never>)?

    func deviceId(for profileId: UUID) -> AnyPublisher<String?, Never> {
        deviceIdForCallsCount += 1
        deviceIdForReceivedProfileId = profileId
        deviceIdForReceivedInvocations.append(profileId)
        return deviceIdForClosure.map { $0(profileId) } ?? deviceIdForReturnValue
    }

    // MARK: - deleteDevice

    var deleteDeviceOfCallsCount = 0
    var deleteDeviceOfCalled: Bool {
        deleteDeviceOfCallsCount > 0
    }

    var deleteDeviceOfReceivedArguments: (device: String, profileId: UUID)?
    var deleteDeviceOfReceivedInvocations: [(device: String, profileId: UUID)] = []
    var deleteDeviceOfReturnValue: AnyPublisher<Bool, RegisteredDevicesServiceError>!
    var deleteDeviceOfClosure: ((String, UUID) -> AnyPublisher<Bool, RegisteredDevicesServiceError>)?

    func deleteDevice(_ device: String, of profileId: UUID) -> AnyPublisher<Bool, RegisteredDevicesServiceError> {
        deleteDeviceOfCallsCount += 1
        deleteDeviceOfReceivedArguments = (device: device, profileId: profileId)
        deleteDeviceOfReceivedInvocations.append((device: device, profileId: profileId))
        return deleteDeviceOfClosure.map { $0(device, profileId) } ?? deleteDeviceOfReturnValue
    }

    // MARK: - cardWall

    var cardWallCallsCount = 0
    var cardWallCalled: Bool {
        cardWallCallsCount > 0
    }

    var cardWallForReceivedProfileId: UUID?
    var cardWallForReceivedInvocations: [UUID] = []
    var cardWallForReturnValue: AnyPublisher<IDPCardWallDomain.State, Never>!
    var cardWallForClosure: ((UUID) -> AnyPublisher<IDPCardWallDomain.State, Never>)?

    func cardWall(for profileId: UUID) -> AnyPublisher<IDPCardWallDomain.State, Never> {
        cardWallCallsCount += 1
        cardWallForReceivedProfileId = profileId
        cardWallForReceivedInvocations.append(profileId)
        return cardWallForClosure.map { $0(profileId) } ?? cardWallForReturnValue
    }
}
