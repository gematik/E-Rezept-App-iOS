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

import AsyncHelpers
import Combine
import ComposableArchitecture
import eRpKit
import eRpResources
import ErxTaskRepository
import FeatureHelpers
import FHIRVZD
import MapKit
import Pharmacy
import Settings
import SwiftUI

@Reducer
struct OrderDetailDomain {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = orders_pickupCode
        case pickupCode(PickupCodeDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail
        case prescriptionDetail(PrescriptionDetailDomain)
        // sourcery: AnalyticsScreen = chargeItemDetails
        case chargeItem(ChargeItemDomain)
        // sourcery: AnalyticsScreen = orders_pharmacyDetail
        case pharmacyDetail(PharmacyDetailDomain)
        @ReducerCaseEphemeral
        // sourcery: AnalyticsScreen = alert
        case alert(ErpAlertState<Alert>)

        enum Alert: Equatable {
            case openMail(message: String)
        }
    }

    @ObservableState
    struct State: Equatable {
        var order: Order?
        var erxTasks: IdentifiedArrayOf<ErxTask> = []
        var openUrlSheetUrl: URL?
        var communicationMessage: CommunicationMessage
        var timelineEntries: [TimelineEntry]
        @Presents var destination: Destination.State?

        init(communicationMessage: CommunicationMessage,
             erxTasks: IdentifiedArrayOf<ErxTask> = [],
             openUrlSheetUrl: URL? = nil,
             destination: Destination.State? = nil) {
            self.communicationMessage = communicationMessage
            self.erxTasks = erxTasks
            self.openUrlSheetUrl = openUrlSheetUrl
            order = communicationMessage.order
            timelineEntries = communicationMessage.timelineEntries.sorted { $0.lastUpdated > $1.lastUpdated }
            self.destination = destination
        }
    }

    enum Action: Equatable {
        case task

        case didDisplayTimelineEntries
        case loadTasks
        case tasksReceived([ErxTask])
        case didSelectMedication(ErxTask)

        case showPickupCode(dmcCode: String?, hrCode: String?)

        case loadAndShowPharmacy
        case showChargeItem(ErxChargeItem)
        case showOpenUrlSheet(url: URL?)
        case openUrl(url: URL?)
        case openMail(message: String)
        case openMapApp
        case openPhoneApp
        case openPhoneAppWith(url: URL)
        case openMailApp
        case delegate(Delegate)

        case resetNavigation
        case destination(PresentationAction<Destination.Action>)
        case response(Response)

        enum Response: Equatable {
            case loadAndShowPharmacyReceived(Result<PharmacyLocation, PharmacyRepositoryError>)
            case showAlert(ErpAlertState<Destination.Alert>)
        }

        enum Delegate: Equatable {
            case close
        }
    }

    var deviceInfo = DeviceInformations()

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.erxTaskRepository) var erxTaskRepository: ErxTaskRepository
    @Dependency(\.pharmacyRepository) var pharmacyRepository: PharmacyRepository
    @Dependency(\.openURLHandler) var openURLHandler
    @Dependency(\.dateProvider) var date: () -> Date
    @Dependency(\.currentAppVersion) var version: AppVersion
    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.fhirDateFormatter) var fhirDateFormatter: FHIRDateFormatter
    @Dependency(\.uiDateFormatter) var uiDateFormatter: UIDateFormatter
    @Dependency(\.userDataStore) var userDataStore: UserDataStore

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return .merge(
                .send(.didDisplayTimelineEntries),
                .send(.loadTasks)
            )
        case let .didSelectMedication(erxTask):
            let prescription = Prescription(erxTask: erxTask)
            state.destination = .prescriptionDetail(
                PrescriptionDetailDomain.State(
                    prescription: prescription,
                    isArchived: prescription.isArchived
                )
            )
            return .none
        case .didDisplayTimelineEntries:
            if let order = state.order {
                return .run { [comms = order.communications.elements, chargeItems = order.chargeItems.elements] _ in
                    try await self.setReadState(for: comms)
                    try await self.setReadState(for: chargeItems)
                }
            }

            let internalMessages = state.timelineEntries.compactMap { entry in
                if case let .internalCommunication(message) = entry {
                    return message
                }
                return nil
            }

            let readMessageIDs = internalMessages
                .filter { !$0.isRead }
                .map(\.id)

            readMessageIDs.forEach { messageId in
                userDataStore.markInternalCommunicationAsRead(messageId: messageId)
            }

            return .none
        case .loadTasks:
            guard let order = state.order else { return .none }
            let taskIds = Set(order.communications.map(\.taskId))
            guard !taskIds.isEmpty else {
                return .none
            }
            return loadTasks(taskIds)
        case let .tasksReceived(tasks):
            state.erxTasks = IdentifiedArray(uniqueElements: tasks.sorted())
            state.timelineEntries = state.timelineEntries.updateChipTexts(with: tasks)
            return .none
        case let .showPickupCode(dmcCode: dmcCode, hrCode: hrCode):
            state.destination = .pickupCode(
                .init(pharmacyName: state.order?.pharmacy?.name, pickupCodeHR: hrCode, pickupCodeDMC: dmcCode)
            )
            return .none
        case let .showChargeItem(chargeItem):
            state.destination = .chargeItem(
                .init(profileId: userSession.profileId, chargeItem: chargeItem, showRouteToChargeItemListButton: true)
            )
            return .none
        case .loadAndShowPharmacy:
            guard let pharmacy = state.order?.pharmacy else { return .none }
            return .run { [pharmacy = pharmacy] send in
                do {
                    let remotePharamcy = try await pharmacyRepository.updateFromRemote(pharmacy.telematikID)
                    await send(.response(.loadAndShowPharmacyReceived(.success(remotePharamcy))))
                } catch let error as PharmacyRepositoryError {
                    await send(.response(.loadAndShowPharmacyReceived(.failure(error))))
                }
            }
        case let .response(.loadAndShowPharmacyReceived(result)):
            switch result {
            case let .success(pharmacy):
                guard let order = state.order else { return .none }
                state.order = Order.lens.pharmacy.set(pharmacy)(order)

                state.destination = .pharmacyDetail(
                    PharmacyDetailDomain.State(
                        prescriptions: Shared(value: []),
                        selectedPrescriptions: Shared(value: []),
                        inRedeemProcess: false,
                        inOrdersMessage: true,
                        pharmacyViewModel: .init(
                            pharmacy: pharmacy,
                            timeOnlyFormatter: uiDateFormatter.timeOnlyFormatter
                        )
                    )
                )
            case let .failure(error):
                state.destination = .alert(.init(for: error))
                if let pharmacy = state.order?.pharmacy, let order = state.order,
                   PharmacyRepositoryError.remote(.notFound) == error {
                    state.order = Order.lens.pharmacy.set(nil)(order)
                    return .run { _ in
                        _ = try await pharmacyRepository.delete(pharmacy: pharmacy)
                    }
                }
            }
            return .none
        case let .response(.showAlert(alertState)):
            state.destination = .alert(alertState)
            return .none
        case let .openUrl(url: url):
            return .run { send in
                guard let url = url else { return }
                guard await openURLHandler.canOpenURL(url) else {
                    await send(.response(.showAlert(Self.openUrlAlertState(for: url))))
                    return
                }

                await openURLHandler.open(url)
            }
        case let .openMail(message),
             let .destination(.presented(.alert(.openMail(message)))):
            state.destination = nil
            return .run { send in
                if let url = Self.createEmailUrl(
                    to: L10n.ordDetailTxtEmailSupport.text,
                    subject: L10n.ordDetailTxtMailSubject.text,
                    body: Self.eMailBody(
                        with: message,
                        date: date(),
                        deviceInfo: deviceInfo,
                        version: version.productVersion.description
                    )
                ), await openURLHandler.canOpenURL(url) {
                    await openURLHandler.open(url)
                } else {
                    await send(.response(.showAlert(Self.openMailAlertState)))
                }
            }
        case let .showOpenUrlSheet(url):
            state.openUrlSheetUrl = url
            return .none
        case .openMapApp:
            guard let pharmacy = state.order?.pharmacy,
                  let longitude = pharmacy.position?.longitude?.doubleValue,
                  let latitude = pharmacy.position?.latitude?.doubleValue else {
                return .none
            }
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)

            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
            mapItem.name = pharmacy.name
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            return .none
        case .openPhoneApp:
            guard let phone = state.order?.pharmacy?.telecom?.phone,
                  let url = URL(phoneNumber: phone) else {
                return .none
            }
            return .run { _ in
                await openURLHandler.open(url)
            }
        case let .openPhoneAppWith(url: url):
            return .run { _ in
                await openURLHandler.open(url)
            }
        case .openMailApp:
            guard let email = state.order?.pharmacy?.telecom?.email,
                  let url = Self.createEmailUrl(to: email) else {
                return .none
            }
            return .run { _ in
                await openURLHandler.open(url)
            }
        case .resetNavigation,
             .destination(.presented(.pharmacyDetail(.delegate(.close)))),
             .destination(.presented(.pickupCode(action: .delegate(.close)))),
             .destination(.presented(.prescriptionDetail(action: .delegate(.close)))):
            state.destination = nil
            return .none
        case .destination,
             .delegate:
            return .none
        }
    }
}

extension OrderDetailDomain {
    func loadTasks(_ erxTaskIds: Set<ErxTask.ID>) -> Effect<OrderDetailDomain.Action> {
        .publisher(
            Publishers.MergeMany(
                erxTaskIds.map { id in
                    erxTaskRepository.loadLocalTask(id, nil)
                        .first()
                        .catch { _ in Just(.none) }
                        .eraseToAnyPublisher()
                }
            )
            .collect(erxTaskIds.count) // wait for N first values; stalls if some never emit
            .map { .tasksReceived($0.compactMap { $0 }) }
            .receive(on: schedulers.main)
            .eraseToAnyPublisher
        )
    }

    func setReadState(for communications: [ErxTask.Communication]) async throws {
        let readCommunications = communications.filter { !$0.isRead }
            .map { comm -> ErxTask.Communication in
                var readComm = comm
                readComm.isRead = true
                return readComm
            }
        guard !readCommunications.isEmpty else { return }
        try await erxTaskRepository.saveLocalCommunications(readCommunications, nil)
    }

    func setReadState(for chargeItems: [ErxChargeItem]) async throws {
        let readChargeItems = chargeItems.filter { !$0.isRead }
            .map { chargeItem -> ErxChargeItem in
                var readChargeItem = chargeItem
                readChargeItem.isRead = true
                return readChargeItem
            }
        guard !readChargeItems.isEmpty else { return }
        try await erxTaskRepository.saveChargeItems(readChargeItems.map(\.sparseChargeItem), nil)
    }
}

extension Array where Element == TimelineEntry {
    func updateChipTexts(with tasks: [ErxTask]) -> [TimelineEntry] {
        map { entry in
            switch entry {
            case let .dispReq(communication, pharmacy, _):
                let relatedTasks = tasks.compactMap { $0.medication?.displayName }
                var chipTexts: [String] = []
                if relatedTasks.count == 1 {
                    chipTexts = relatedTasks
                } else {
                    chipTexts = [L10n.ordDetailTxtChipAll.text]
                }
                return TimelineEntry.dispReq(communication, pharmacy: pharmacy, chipTexts: chipTexts)
            case let .reply(communication, _),
                 let .diga(communication, _):
                let relatedTasks = tasks.filter { task in communication.taskIds.contains(task.identifier) }
                    .compactMap { $0.medication?.displayName }
                var chipTexts: [String] = []
                if relatedTasks.count > 1, relatedTasks.count == tasks.count {
                    chipTexts = [L10n.ordDetailTxtChipAll.text]
                } else {
                    chipTexts = relatedTasks
                }
                return TimelineEntry.reply(communication, chipTexts: chipTexts)
            case .chargeItem,
                 .internalCommunication:
                return entry
            }
        }
    }
}

extension OrderDetailDomain {
    struct DeviceInformations {
        let model: String
        let systemName: String
        let version: String

        init(model: String = UIDevice.current.model,
             systemName: String = UIDevice.current.systemName,
             version: String = UIDevice.current.systemVersion) {
            self.model = model
            self.systemName = systemName
            self.version = version
        }

        var description: String {
            """
            Model: \(model),
            OS:\(systemName) \(version)
            """
        }
    }

    private static func eMailBody(
        with message: String,
        date: Date,
        deviceInfo: DeviceInformations,
        version: String
    ) -> String {
        """
        \(L10n.ordDetailTxtMailBody1.text)

        \(L10n.ordDetailTxtMailBody2.text)

        \(message)

        \(L10n.ordDetailTxtMailError.text)
        \(version)
        \(date.fhirFormattedString(with: .yearMonthDayTime))
        \(deviceInfo.description)
        """
    }

    private static func createEmailUrl(to email: String, subject: String? = nil, body: String? = nil) -> URL? {
        var urlString = URLComponents(string: "mailto:\(email)")
        var queryItems = [URLQueryItem]()

        if let subject = subject {
            queryItems.append(URLQueryItem(name: "subject", value: subject))
        }

        if let body = body {
            queryItems.append(URLQueryItem(name: "body", value: body))
        }

        urlString?.queryItems = queryItems

        return urlString?.url
    }

    static var openMailAlertState: ErpAlertState<Destination.Alert> = {
        .init(
            title: L10n.ordDetailTxtOpenMailErrorTitle,
            actions: {
                ButtonState(role: .cancel) {
                    .init(L10n.alertBtnClose)
                }
            },
            message: L10n.ordDetailTxtOpenMailError
        )
    }()

    static func openUrlAlertState(for url: URL) -> ErpAlertState<Destination.Alert> {
        .init(
            title: L10n.ordDetailTxtErrorTitle,
            actions: {
                ButtonState(role: .cancel) {
                    .init(L10n.alertBtnClose)
                }
                ButtonState(action: .openMail(message: url.absoluteString)) {
                    .init(L10n.ordDetailBtnError)
                }
            },
            message: L10n.ordDetailTxtError
        )
    }
}

extension OrderDetailDomain {
    enum Dummies {
        static let state = State(
            communicationMessage: CommunicationMessage.order(Order.Dummies.orderCommunications1),
            erxTasks: [ErxTask.Demo.erxTask1, ErxTask.Demo.erxTask13]
        )

        static let store = StoreOf<OrderDetailDomain>(initialState: state) {
            OrderDetailDomain()
        }

        static func storeFor(_ state: State) -> StoreOf<OrderDetailDomain> {
            Store(initialState: state) {
                OrderDetailDomain()
            }
        }
    }
}
