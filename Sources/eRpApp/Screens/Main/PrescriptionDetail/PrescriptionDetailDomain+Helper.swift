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

    func save(erxTasks: [ErxTask]) -> Effect<PrescriptionDetailDomain.Action> {
        .run { send in
            let result = try await erxTaskRepository.save(erxTasks: erxTasks).async(\.self)
            await send(.response(.redeemedOnSavedReceived(result)))
        }
    }

    func delete(erxTask: ErxTask) -> Effect<PrescriptionDetailDomain.Action> {
        .run { send in
            let result = try await erxTaskRepository.delete(erxTasks: [erxTask]).asyncResult(\.self)
            await send(.response(.taskDeletedReceived(result)))
        }
    }

    func deleteChargeItem(erxTask: ErxTask) -> Effect<PrescriptionDetailDomain.Action> {
        .run { send in
            let chargeItems = try await erxTaskRepository.loadRemoteChargeItems().async(\.self)
            if let sparseChargeItem = chargeItems.first(where: { $0.taskId == erxTask.id }) {
                if let chargeItem = sparseChargeItem.chargeItem {
                    let result = try await erxTaskRepository.delete(chargeItems: [chargeItem])
                        .asyncResult(\.self)
                    await send(.response(.chargeItemDeletedReceived(result)))
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
