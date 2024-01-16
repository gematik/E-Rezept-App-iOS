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
import eRpLocalStorage
import SwiftUI

#if ENABLE_DEBUG_VIEW
struct DebugEnvironmentView: View {
    private class State: ObservableObject {
        @Published var environmentName: String = defaultConfiguration.name
        @Published var loggingEnabled = false
        @Published var virtualEGKEnabled = false

        private var disposeBag: Set<AnyCancellable> = []

        init() {
            UserDefaultsStore(userDefaults: UserDefaults.standard).serverEnvironmentConfiguration
                .sink { [weak self] value in
                    self?.environmentName = value ?? defaultConfiguration.name
                }
                .store(in: &disposeBag)

            UserDefaults.standard.publisher(for: \.isLoggingEnabled)
                .sink { [weak self] value in
                    self?.loggingEnabled = value
                }
                .store(in: &disposeBag)

            UserDefaults.standard.publisher(for: \.isVirtualEGKEnabled)
                .sink { [weak self] value in
                    self?.virtualEGKEnabled = value
                }
                .store(in: &disposeBag)
        }
    }

    @StateObject private var state = State()

    var body: some View {
        HStack {
            Spacer()
            ZStack(alignment: .topTrailing) {
                Text(state.environmentName)
                    .foregroundColor(Colors.systemColorWhite)
                    .padding(.horizontal, 16)
                    .background(Colors.red600)
                    .cornerRadius(4)
                    .font(Font.system(size: 16).bold())

                if state.loggingEnabled {
                    Circle()
                        .fill(Colors.red600)
                        .frame(width: 8, height: 8)
                        .offset(x: 12, y: 0)
                }
                if state.virtualEGKEnabled {
                    Text("v-eGK")
                        .font(.footnote)
                        .offset(x: 40, y: 8)
                        .foregroundColor(Colors.primary600)
                }
            }
            Spacer()
        }
    }
}

struct DebugEnvironmentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DebugEnvironmentView()
        }
    }
}

#endif
