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
import ComposableArchitecture
import eRpKit
import MapKit
import SwiftUI
import ZXingObjC

protocol ResourceHandler {
    func open(_ url: URL)
    func canOpenURL(_ url: URL) -> Bool
}

extension UIApplication: ResourceHandler {
    func open(_ url: URL) {
        open(url, options: [:], completionHandler: nil)
    }
}

enum OrderDetailDomain: Equatable {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        .concatenate(
            Effect.cancel(token: Token.self),
            cleanupSubDomains()
        )
    }

    private static func cleanupSubDomains<T>() -> Effect<T, Never> {
        PrescriptionDetailDomain.cleanup()
    }

    enum Token: CaseIterable, Hashable {
        case loadMedications
    }

    enum Route: Equatable {
        case pickupCode(PickupCodeDomain.State)
        case prescriptionDetail(PrescriptionDetailDomain.State)
        case alert(AlertState<Action>)

        enum Tag: Int {
            case pickupCode
            case prescriptionDetail
            case alert
        }

        var tag: Tag {
            switch self {
            case .pickupCode:
                return .pickupCode
            case .prescriptionDetail:
                return .prescriptionDetail
            case .alert:
                return .alert
            }
        }
    }

    struct State: Equatable {
        var order: OrderCommunications
        var erxTasks: IdentifiedArrayOf<ErxTask> = []
        var openUrlSheetUrl: URL?
        var route: Route?
    }

    enum Action: Equatable {
        case didSelectCommunication(String)
        case didReadCommunications
        case loadTasks
        case tasksReceived([ErxTask])
        case didSelectMedication(ErxTask)
        case prescriptionDetail(action: PrescriptionDetailDomain.Action)
        case setNavigation(tag: Route.Tag?)
        case showPickupCode(dmcCode: String?, hrCode: String?)
        case pickupCode(action: PickupCodeDomain.Action)
        case showOpenUrlSheet(url: URL?)
        case openUrl(url: URL?)
        case openMail(message: String)
        case openMapApp
        case openPhoneApp
        case openMailApp
    }

    struct Environment {
        internal init(schedulers: Schedulers,
                      userSession: UserSession,
                      fhirDateFormatter: FHIRDateFormatter,
                      erxTaskRepository: ErxTaskRepository,
                      application: ResourceHandler,
                      date: Date = Date(),
                      deviceInfo: OrderDetailDomain.DeviceInformations = DeviceInformations(),
                      version: String = AppVersion.current.description) {
            self.schedulers = schedulers
            self.userSession = userSession
            self.fhirDateFormatter = fhirDateFormatter
            self.erxTaskRepository = erxTaskRepository
            self.application = application
            self.date = date
            self.deviceInfo = deviceInfo
            self.version = version
        }

        let schedulers: Schedulers
        let erxTaskRepository: ErxTaskRepository
        let application: ResourceHandler
        let date: Date
        let deviceInfo: DeviceInformations
        let version: String
        let userSession: UserSession
        let fhirDateFormatter: FHIRDateFormatter
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case let .didSelectCommunication(identifier):
            guard let communication = state.order.displayedCommunications
                .first(where: { $0.identifier == identifier })
            else {
                return .none
            }
            return effect(for: communication)
        case let .didSelectMedication(erxTask):
            let prescription = GroupedPrescription.Prescription(erxTask: erxTask)
            state.route = .prescriptionDetail(
                PrescriptionDetailDomain.State(
                    prescription: prescription,
                    isArchived: prescription.isArchived
                )
            )
            return .none
        case .didReadCommunications:
            return environment.setReadState(for: state.order.communications.elements).fireAndForget()
        case .loadTasks:
            let taskIds = Set(state.order.communications.map(\.taskId))
            guard !taskIds.isEmpty else {
                return .none
            }
            return environment.loadTasks(taskIds)
                .cancellable(id: Token.loadMedications, cancelInFlight: true)
        case let .tasksReceived(tasks):
            state.erxTasks = IdentifiedArray(uniqueElements: tasks.sorted())
            return .none
        case let .showPickupCode(dmcCode: dmcCode, hrCode: hrCode):
            state.route = .pickupCode(
                .init(
                    pharmacyName: state.order.pharmacy?.name,
                    pickupCodeHR: hrCode,
                    pickupCodeDMC: dmcCode
                )
            )
            return .none
        case let .openUrl(url: url):
            guard let url = url else { return .none }
            if environment.application.canOpenURL(url) {
                environment.application.open(url)
            } else {
                state.route = .alert(openUrlAlertState(for: url))
            }
            return .none
        case let .openMail(message):
            state.route = nil
            if let url = createEmailUrl(
                to: L10n.ordDetailTxtEmailSupport.text,
                subject: L10n.ordDetailTxtMailSubject.text,
                body: eMailBody(
                    with: message,
                    date: environment.date,
                    deviceInfo: environment.deviceInfo,
                    version: environment.version
                )
            ), environment.application.canOpenURL(url) {
                environment.application.open(url)
            } else {
                state.route = .alert(openMailAlertState)
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
                UIApplication.shared.open(number)
            }
            return .none
        case .openMailApp:
            if let email = state.order.pharmacy?.telecom?.email,
               let url = createEmailUrl(to: email) {
                UIApplication.shared.open(url)
            }
            return .none
        case .setNavigation(tag: .none),
             .pickupCode(action: .close),
             .prescriptionDetail(action: .close):
            state.route = nil
            return cleanup()
        case .setNavigation,
             .pickupCode,
             .prescriptionDetail:
            return .none
        }
    }

    private static func effect(for communication: ErxTask.Communication) -> Effect<Action, Never> {
        guard let payload = communication.payload else {
            let payloadJSON = communication.payloadJSON
            return Effect(value: OrderDetailDomain.Action.openMail(message: payloadJSON))
        }

        switch payload.supplyOptionsType {
        case .onPremise:
            if !payload.isPickupCodeEmptyOrNil {
                return Effect(value: OrderDetailDomain.Action.showPickupCode(
                    dmcCode: payload.pickUpCodeDMC,
                    hrCode: payload.pickUpCodeHR
                ))
            }
            return .none
        case .delivery:
            return .none
        case .shipment:
            if let urlString = payload.url,
               !urlString.isEmpty,
               let url = URL(string: urlString) {
                return Effect(value: OrderDetailDomain.Action.showOpenUrlSheet(url: url))
            }
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        prescriptionDetailPullbackReducer,
        pickupCodeReducer,
        domainReducer
    )
}

extension OrderDetailDomain.Environment {
    func loadTasks(_ erxTaskIds: Set<ErxTask.ID>) -> Effect<OrderDetailDomain.Action, Never> {
        let publishers: [AnyPublisher<ErxTask?, Never>] = erxTaskIds.map {
            erxTaskRepository.loadLocal(by: $0, accessCode: nil)
                .catch { _ in Just(.none) }
                .eraseToAnyPublisher()
        }

        return Publishers.MergeMany(publishers)
            .collect(publishers.count)
            .map { .tasksReceived($0.compactMap { $0 }) }
            .receive(on: schedulers.main)
            .eraseToEffect()
    }

    func setReadState(for communications: [ErxTask.Communication]) -> Effect<Bool, ErxRepositoryError> {
        let readCommunications = communications.filter { !$0.isRead }
            .map { comm -> ErxTask.Communication in
                var readComm = comm
                readComm.isRead = true
                return readComm
            }
        return erxTaskRepository.saveLocal(communications: readCommunications)
            .receive(on: schedulers.main)
            .eraseToEffect()
    }
}

extension OrderDetailDomain {
    private static let prescriptionDetailPullbackReducer: Reducer =
        PrescriptionDetailDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.prescriptionDetail),
            action: /OrderDetailDomain.Action.prescriptionDetail(action:)
        ) { environment in
            PrescriptionDetailDomain.Environment(
                schedulers: environment.schedulers,
                taskRepository: environment.userSession.erxTaskRepository,
                fhirDateFormatter: environment.fhirDateFormatter,
                userSession: environment.userSession
            )
        }

    private static let pickupCodeReducer: Reducer =
        PickupCodeDomain.reducer
            ._pullback(
                state: (\State.route).appending(path: /OrderDetailDomain.Route.pickupCode),
                action: /OrderDetailDomain.Action.pickupCode(action:)
            ) { messagesEnvironment in
                PickupCodeDomain.Environment(
                    schedulers: messagesEnvironment.schedulers,
                    matrixCodeGenerator: ZXDataMatrixWriter()
                )
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

    static var openMailAlertState: AlertState<Action> = {
        AlertState(
            title: TextState(L10n.ordDetailTxtOpenMailErrorTitle),
            message: TextState(L10n.ordDetailTxtOpenMailError),
            dismissButton: .cancel(TextState(L10n.alertBtnClose))
        )
    }()

    static func openUrlAlertState(for url: URL) -> AlertState<Action> {
        AlertState(
            title: TextState(L10n.ordDetailTxtErrorTitle),
            message: TextState(L10n.ordDetailTxtError),
            primaryButton: .cancel(TextState(L10n.alertBtnClose)),
            secondaryButton: .default(
                TextState(L10n.ordDetailBtnError),
                action: .send(Action.openMail(message: url.absoluteString))
            )
        )
    }
}

extension OrderDetailDomain {
    enum Dummies {
        static let state = State(
            order: OrderCommunications(orderId: "testID",
                                       communications: [OrdersDomain.Dummies.communicationOnPremise,
                                                        OrdersDomain.Dummies.communicationShipment,
                                                        OrdersDomain.Dummies.communicationDelivery]),
            erxTasks: [ErxTask.Demo.erxTask1, ErxTask.Demo.erxTask13]
        )

        static let demoSessionContainer = DummyUserSessionContainer()
        static let environment = Environment(
            schedulers: Schedulers(),
            userSession: DummySessionContainer(),
            fhirDateFormatter: globals.fhirDateFormatter,
            erxTaskRepository: demoSessionContainer.userSession.erxTaskRepository,
            application: UIApplication.shared
        )

        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: OrderDetailDomain.Reducer.empty,
                  environment: environment)
        }
    }
}
