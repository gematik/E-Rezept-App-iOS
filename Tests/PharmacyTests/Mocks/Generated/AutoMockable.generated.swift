// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

import Combine
import eRpKit
import OpenSSL

@testable import Pharmacy
























public class PharmacyLocalDataStoreMock: PharmacyLocalDataStore {

    public init() {}



    //MARK: - fetchPharmacy

    public var fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorCallsCount = 0
    public var fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorCalled: Bool {
        return fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorCallsCount > 0
    }
    public var fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorReceivedTelematikId: (String)?
    public var fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorReceivedInvocations: [(String)] = []
    public var fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorReturnValue: AnyPublisher<PharmacyLocation?, LocalStoreError>!
    public var fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorClosure: ((String) -> AnyPublisher<PharmacyLocation?, LocalStoreError>)?

    public func fetchPharmacy(by telematikId: String) -> AnyPublisher<PharmacyLocation?, LocalStoreError> {
        fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorCallsCount += 1
        fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorReceivedTelematikId = telematikId
        fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorReceivedInvocations.append(telematikId)
        if let fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorClosure = fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorClosure {
            return fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorClosure(telematikId)
        } else {
            return fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorReturnValue
        }
    }

    //MARK: - listPharmacies

    public var listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorCallsCount = 0
    public var listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorCalled: Bool {
        return listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorCallsCount > 0
    }
    public var listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorReceivedCount: (Int)?
    public var listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorReceivedInvocations: [(Int)?] = []
    public var listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorReturnValue: AnyPublisher<[PharmacyLocation], LocalStoreError>!
    public var listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorClosure: ((Int?) -> AnyPublisher<[PharmacyLocation], LocalStoreError>)?

    public func listPharmacies(count: Int?) -> AnyPublisher<[PharmacyLocation], LocalStoreError> {
        listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorCallsCount += 1
        listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorReceivedCount = count
        listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorReceivedInvocations.append(count)
        if let listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorClosure = listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorClosure {
            return listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorClosure(count)
        } else {
            return listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorReturnValue
        }
    }

    //MARK: - save

    public var savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReceivedPharmacies: ([PharmacyLocation])?
    public var savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReceivedInvocations: [([PharmacyLocation])] = []
    public var savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorClosure: (([PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError>)?

    public func save(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError> {
        savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorCallsCount += 1
        savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReceivedPharmacies = pharmacies
        savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReceivedInvocations.append(pharmacies)
        if let savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorClosure = savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorClosure {
            return savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorClosure(pharmacies)
        } else {
            return savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - delete

    public var deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReceivedPharmacies: ([PharmacyLocation])?
    public var deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReceivedInvocations: [([PharmacyLocation])] = []
    public var deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorClosure: (([PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError>)?

    public func delete(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError> {
        deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorCallsCount += 1
        deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReceivedPharmacies = pharmacies
        deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReceivedInvocations.append(pharmacies)
        if let deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorClosure = deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorClosure {
            return deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorClosure(pharmacies)
        } else {
            return deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - update

    public var updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorCallsCount = 0
    public var updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorCalled: Bool {
        return updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorCallsCount > 0
    }
    public var updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorReceivedArguments: (telematikId: String, mutating: (inout PharmacyLocation) -> Void)?
    public var updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorReceivedInvocations: [(telematikId: String, mutating: (inout PharmacyLocation) -> Void)] = []
    public var updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorReturnValue: AnyPublisher<PharmacyLocation, LocalStoreError>!
    public var updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorClosure: ((String, @escaping (inout PharmacyLocation) -> Void) -> AnyPublisher<PharmacyLocation, LocalStoreError>)?

    public func update(telematikId: String, mutating: @escaping (inout PharmacyLocation) -> Void) -> AnyPublisher<PharmacyLocation, LocalStoreError> {
        updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorCallsCount += 1
        updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorReceivedArguments = (telematikId: telematikId, mutating: mutating)
        updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorReceivedInvocations.append((telematikId: telematikId, mutating: mutating))
        if let updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorClosure = updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorClosure {
            return updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorClosure(telematikId, mutating)
        } else {
            return updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorReturnValue
        }
    }


}
