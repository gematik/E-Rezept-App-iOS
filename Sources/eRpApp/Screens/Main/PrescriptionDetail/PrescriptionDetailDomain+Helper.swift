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
import ComposableArchitecture
import eRpKit
import Foundation

extension PrescriptionDetailDomain {
    // TODO: Same func is in MatrixCodeDomain. swiftlint:disable:this todo
    // Maybe find a way to have only one implementation!
    /// Will calculate the size for the matrix code based on current screen size
    func calcMatrixCodeSize(screenSize: CGSize) -> CGSize {
        let padding: CGFloat = 16
        let minScreenDimension = min(screenSize.width, screenSize.height)
        let pixelDimension = Int(minScreenDimension - 2 * padding)
        return CGSize(width: pixelDimension, height: pixelDimension)
    }

    func save(erxTasks: [ErxTask], profileId: UUID?) -> Effect<PrescriptionDetailDomain.Action> {
        .run { send in
            do {
                try await erxTaskRepository.saveTask(erxTasks, profileId)
                await send(.response(.redeemedOnSavedReceived(true)))
            } catch {
                await send(.response(.redeemedOnSavedReceived(false)))
            }
        }
    }

    func delete(erxTask: ErxTask, profileId: UUID?) -> Effect<PrescriptionDetailDomain.Action> {
        .run { send in
            do {
                try await erxTaskRepository.deleteTask([erxTask], profileId)
                await send(.response(.taskDeletedReceived(.success(true))))
            } catch let error as ErxRepositoryError {
                await send(.response(.taskDeletedReceived(.failure(error))))
            }
        }
    }

    func deleteChargeItem(profileId: UUID, erxTask: ErxTask) -> Effect<PrescriptionDetailDomain.Action> {
        .run { send in
            let chargeItems = try await erxTaskRepository.loadRemoteChargeItems(profileId)
            if let sparseChargeItem = chargeItems.first(where: { $0.taskId == erxTask.id }) {
                if let chargeItem = sparseChargeItem.chargeItem {
                    do {
                        try await erxTaskRepository.deleteChargeItems([chargeItem], profileId)
                        await send(.response(.chargeItemDeletedReceived(.success(true))))
                    } catch let error as ErxRepositoryError {
                        await send(.response(.chargeItemDeletedReceived(.failure(error))))
                    }
                } else {
                    // Parsing failed, can't delete item
                    await send(.response(.chargeItemDeletedReceived(.success(false))))
                }
            } else {
                // Respond with success if no ChargeItem found e.g. nothing to delete
                await send(.response(.chargeItemDeletedReceived(.success(true))))
            }
        }
    }
}

extension PrescriptionDetailDomain.State {
    enum Field: Hashable {
        case medicationName
    }

    func createReportEmail(body: String) -> URL? {
        var urlString = URLComponents(string: "mailto:app-feedback@gematik.de")
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "subject", value: "Fehlerreport iOS App"))
        queryItems.append(URLQueryItem(name: "body", value: body))

        urlString?.queryItems = queryItems

        return urlString?.url
    }
}
