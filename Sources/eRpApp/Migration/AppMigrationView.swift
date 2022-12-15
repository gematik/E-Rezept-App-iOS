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

import ComposableArchitecture
import SwiftUI

struct AppMigrationView: View {
    let store: AppMigrationDomain.Store
    @ObservedObject
    var viewStore: ViewStore<AppMigrationDomain.State, AppMigrationDomain.Action>

    init(store: AppMigrationDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        HStack {
            if viewStore.state == .inProgress {
                ProgressView(L10n.amgTxtInProgress)
                    .progressViewStyle(CircularProgressViewStyle())
                    .accessibility(identifier: A11y.migration.amgTxtAndSpinner)
            }
        }
        .alert(store.scope(state: \.failedValue), dismiss: .nothing)
        .onAppear {
            viewStore.send(.loadCurrentModelVersion)
        }
    }
}

struct AppMigrationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppMigrationView(store: AppMigrationDomain.Dummies.store(for: .inProgress))
        }
    }
}
