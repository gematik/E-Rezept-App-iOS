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
import Perception
import SwiftUI

struct AppMigrationView: View {
    @Perception.Bindable var store: StoreOf<AppMigrationDomain>

    init(store: StoreOf<AppMigrationDomain>) {
        self.store = store
    }

    var body: some View {
        WithPerceptionTracking {
            HStack {
                if store.migration == .inProgress {
                    ProgressView(L10n.amgTxtInProgress)
                        .progressViewStyle(CircularProgressViewStyle())
                        .accessibility(identifier: A11y.migration.amgTxtAndSpinner)
                }
            }
            .alert($store.scope(
                state: \.destination?.alert?.alert,
                action: \.destination.alert
            ))
            .onAppear {
                store.send(.loadCurrentModelVersion)
            }
        }
    }
}

struct AppMigrationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppMigrationView(store: AppMigrationDomain.Dummies.store(for: .init(migration: .inProgress)))
        }
    }
}
