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

import Combine
import ComposableArchitecture
import eRpKit
import MapKit
import SwiftUI
import ZXingObjC

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
        @ReducerCaseEphemeral
        // sourcery: AnalyticsScreen = alert
        case alert(ErpAlertState<Alert>)

        enum Alert: Equatable {
            case openMail(message: String)
        }
    }

    @ObservableState
    struct State: Equatable {
        var order: Order
        var erxTasks: IdentifiedArrayOf<ErxTask> = []
        var openUrlSheetUrl: URL?
        var timelineEntries: [TimelineEntry] = []

        @Presents var destination: Destination.State?
    }

    enum Action: Equatable {
        case task

        case didDisplayTimelineEntries
        case loadTasks
        case loadTimeline
        case tasksReceived([ErxTask])
        case didSelectMedication(ErxTask)

        case showPickupCode(dmcCode: String?, hrCode: String?)

        case showChargeItem(ErxChargeItem)
        case showOpenUrlSheet(url: URL?)
        case openUrl(url: URL?)
        case openMail(message: String)
        case openMapApp
        case openPhoneApp
        case openMailApp

        case resetNavigation
        case destination(PresentationAction<Destination.Action>)
    }

    var deviceInfo = DeviceInformations()

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.erxTaskRepository) var erxTaskRepository: ErxTaskRepository
    @Dependency(\.resourceHandler) var application: ResourceHandler
    @Dependency(\.dateProvider) var date: () -> Date
    @Dependency(\.currentAppVersion) var version: AppVersion
    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.fhirDateFormatter) var fhirDateFormatter: FHIRDateFormatter
    @Dependency(\.uiDateFormatter) var uiDateFormatter: UIDateFormatter

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
                .send(.loadTasks),
                .send(.loadTimeline)
            )
        case .loadTimeline:
            state.timelineEntries = Self.loadTimeline(for: state.order)
            return .none
        case let .didSelectMedication(erxTask):
            let prescription = Prescription(erxTask: erxTask, dateFormatter: uiDateFormatter)
            state.destination = .prescriptionDetail(
                PrescriptionDetailDomain.State(
                    prescription: prescription,
                    isArchived: prescription.isArchived
                )
            )
            return .none
        case .didDisplayTimelineEntries:
            let communications = state.order.communications.elements
            let chargeItems = state.order.chargeItems.elements
            return .run { _ in
                _ = try await self.setReadState(for: communications).async()
                _ = try await self.setReadState(for: chargeItems).async()
            }
        case .loadTasks:
            let taskIds = Set(state.order.communications.map(\.taskId))
            guard !taskIds.isEmpty else {
                return .none
            }
            return loadTasks(taskIds)
        case let .tasksReceived(tasks):
            state.erxTasks = IdentifiedArray(uniqueElements: tasks.sorted())
            return .none
        case let .showPickupCode(dmcCode: dmcCode, hrCode: hrCode):
            state.destination = .pickupCode(
                .init(
                    pharmacyName: state.order.pharmacy?.name,
                    pickupCodeHR: hrCode,
                    pickupCodeDMC: dmcCode
                )
            )
            return .none
        case let .showChargeItem(chargeItem):
            state.destination = .chargeItem(
                .init(
                    profileId: userSession.profileId,
                    chargeItem: chargeItem,
                    showRouteToChargeItemListButton: true
                )
            )
            return .none
        case let .openUrl(url: url):
            guard let url = url else { return .none }
            if application.canOpenURL(url) {
                application.open(url)
            } else {
                state.destination = .alert(Self.openUrlAlertState(for: url))
            }
            return .none
        case let .openMail(message),
             let .destination(.presented(.alert(.openMail(message)))):
            state.destination = nil
            if let url = Self.createEmailUrl(
                to: L10n.ordDetailTxtEmailSupport.text,
                subject: L10n.ordDetailTxtMailSubject.text,
                body: Self.eMailBody(
                    with: message,
                    date: date(),
                    deviceInfo: deviceInfo,
                    version: version.productVersion.description
                )
            ), application.canOpenURL(url) {
                application.open(url)
            } else {
                state.destination = .alert(Self.openMailAlertState)
            }
            return .none
        case let .showOpenUrlSheet(url):
            state.openUrlSheetUrl = url
            return .none
        case .openMapApp:
            guard let pharmacy = state.order.pharmacy,
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
            if let phone = state.order.pharmacy?.telecom?.phone,
               let number = URL(phoneNumber: phone) {
                application.open(number)
            }
            return .none
        case .openMailApp:
            if let email = state.order.pharmacy?.telecom?.email,
               let url = Self.createEmailUrl(to: email) {
                application.open(url)
            }
            return .none
        case .resetNavigation,
             .destination(.presented(.pickupCode(action: .delegate(.close)))),
             .destination(.presented(.prescriptionDetail(action: .delegate(.close)))):
            state.destination = nil
            return .none
        case .destination:
            return .none
        }
    }
}

extension OrderDetailDomain {
    func loadTasks(_ erxTaskIds: Set<ErxTask.ID>) -> Effect<OrderDetailDomain.Action> {
        let publishers: [AnyPublisher<ErxTask?, Never>] = erxTaskIds.map {
            erxTaskRepository.loadLocal(by: $0, accessCode: nil)
                .first()
                .catch { _ in Just(.none) }
                .eraseToAnyPublisher()
        }

        return .publisher(
            publishers
                .combineLatest()
                .first()
                .map { .tasksReceived($0.compactMap { $0 }) }
                .receive(on: schedulers.main)
                .eraseToAnyPublisher
        )
    }

    func setReadState(for communications: [ErxTask.Communication]) -> AnyPublisher<Bool, ErxRepositoryError> {
        let readCommunications = communications.filter { !$0.isRead }
            .map { comm -> ErxTask.Communication in
                var readComm = comm
                readComm.isRead = true
                return readComm
            }
        guard !readCommunications.isEmpty else {
            return Just(true)
                .setFailureType(to: ErxRepositoryError.self)
                .receive(on: schedulers.main)
                .eraseToAnyPublisher()
        }
        return erxTaskRepository.saveLocal(communications: readCommunications)
            .receive(on: schedulers.main)
            .eraseToAnyPublisher()
    }

    func setReadState(for chargeItems: [ErxChargeItem]) -> AnyPublisher<Bool, ErxRepositoryError> {
        let readChargeItems = chargeItems.filter { !$0.isRead }
            .map { chargeItem -> ErxChargeItem in
                var readChargeItem = chargeItem
                readChargeItem.isRead = true
                return readChargeItem
            }
        guard !readChargeItems.isEmpty else {
            return Just(true)
                .setFailureType(to: ErxRepositoryError.self)
                .receive(on: schedulers.main)
                .eraseToAnyPublisher()
        }
        return erxTaskRepository.save(chargeItems: readChargeItems.map(\.sparseChargeItem))
            .receive(on: schedulers.main)
            .eraseToAnyPublisher()
    }

    static func loadTimeline(for order: Order) -> [TimelineEntry] {
        let displayedCommunications = IdentifiedArray(uniqueElements: order.communications.filterUnique())
        var timelineEntries: [TimelineEntry] = displayedCommunications.compactMap { communication in
            switch communication.profile {
            case .dispReq:
                return .dispReq(communication, pharmacy: order.pharmacy)
            case .reply:
                return .reply(communication)
            default:
                return nil
            }
        }
        timelineEntries.append(contentsOf: order.chargeItems.map { TimelineEntry.chargeItem($0) })
        return timelineEntries.sorted { $0.lastUpdated > $1.lastUpdated }
    }
}

extension OrderDetailDomain {
    struct Timeline<T> {
        let value: T
        let name: String
    }

    enum TimelineEntry: Equatable, Identifiable {
        case dispReq(ErxTask.Communication, pharmacy: PharmacyLocation?)
        case reply(ErxTask.Communication)
        case chargeItem(ErxChargeItem)

        var id: String {
            switch self {
            case let .dispReq(communication, _):
                return communication.identifier
            case let .reply(communication):
                return communication.identifier
            case let .chargeItem(chargeItem):
                return chargeItem.identifier
            }
        }

        var lastUpdated: String {
            switch self {
            case let .dispReq(communication, _):
                return communication.timestamp
            case let .reply(communication):
                return communication.timestamp
            case let .chargeItem(chargeItem):
                return chargeItem.enteredDate ?? ""
            }
        }

        var isRead: Bool {
            switch self {
            case let .dispReq(communication, _):
                return communication.isRead
            case let .reply(communication):
                return communication.isRead
            case let .chargeItem(chargeItem):
                return chargeItem.isRead
            }
        }

        var text: String {
            switch self {
            case let .dispReq(_, pharmacy):
                return L10n.ordDetailTxtSendTo(
                    L10n.ordDetailTxtPresc(1).text,
                    pharmacy?.name ?? L10n.ordTxtNoPharmacyName.text
                ).text
            case let .reply(communication):
                guard let payload = communication.payload else {
                    return L10n.ordDetailTxtError.text
                }

                if let text = payload.infoText, !text.isEmpty {
                    return text
                } else {
                    return L10n.ordDetailMsgsTxtEmpty.text
                }
            case let .chargeItem(chargeItem):
                return L10n.ordDetailTxtChargeItem(chargeItem.medication?.name ?? "").text
            }
        }

        var actions: [String: OrderDetailDomain.Action] {
            switch self {
            case .dispReq:
                return [:]
            case let .reply(communication):
                guard let payload = communication.payload else {
                    return [L10n.ordDetailBtnError.text: .openMail(message: communication.payloadJSON)]
                }
                var actions: [String: OrderDetailDomain.Action] = [:]
                if !payload.isPickupCodeEmptyOrNil {
                    actions[L10n.ordDetailBtnOnPremise.text] = .showPickupCode(dmcCode: payload.pickUpCodeDMC,
                                                                               hrCode: payload.pickUpCodeHR)
                }
                if let urlString = payload.url,
                   !urlString.isEmpty,
                   let url = URL(string: urlString) {
                    actions[L10n.ordDetailBtnLink.text] = .openUrl(url: url)
                }
                return actions
            case let .chargeItem(chargeItem):
                return [L10n.ordDetailBtnChargeItem.text: .showChargeItem(chargeItem)]
            }
        }
    }

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
            order: Order.Dummies.orderCommunications1,
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
