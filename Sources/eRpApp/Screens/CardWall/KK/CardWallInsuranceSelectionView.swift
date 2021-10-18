//
//  Copyright (c) 2021 gematik GmbH
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

struct CardWallInsuranceSelectionView: View {
    let store: CardWallInsuranceSelectionDomain.Store
    @ObservedObject
    var viewStore: ViewStore<CardWallInsuranceSelectionDomain.State, CardWallInsuranceSelectionDomain.Action>

    init(store: CardWallInsuranceSelectionDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack {
            Text("Bitte wählen Sie Ihre Krankenversicherung aus")
                .font(Font.title3.bold())
            List {
                if viewStore.kkList == nil {
                    Section {
                        ActivityIndicator(shouldAnimate: viewStore.kkList == nil, hideWhenStopped: true)
                    }
                }
                if let errorMessage = viewStore.state.errorMessage {
                    Section {
                        Text(errorMessage)
                            .background(Colors.red900)
                            .border(Colors.red600)
                    }
                }
                Section {
                    ForEach(viewStore.kkList?.apps ?? []) { app in
                        Button(action: {
                            viewStore.send(.selectKK(app))
                        }, label: {
                            HStack {
                                Text(app.name)

                                Spacer()

                                if viewStore.selectedKK?.identifier == app.identifier {
                                    Image(systemName: SFSymbolName.checkmark)
                                }
                            }.contentShape(Rectangle())
                        })
                    }
                }
            }.listStyle(PlainListStyle())

            Spacer()

            PrimaryTextButton(text: "Weiter", a11y: "weiter", isEnabled: viewStore.state.selectedKK != nil) {
                viewStore.send(.confirmKK)
            }
            .padding()
        }
        .navigationBarItems(
            trailing: NavigationBarCloseItem {
                viewStore.send(.close)
            }
            .accessibility(identifier: A11y.cardWall.intro.cdwBtnIntroCancel)
            .accessibility(label: Text(L10n.cdwBtnIntroCancelLabel))
        )
        .onAppear {
            viewStore.send(.loadKKList)
        }
    }
}

struct CardWallInsuranceSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CardWallInsuranceSelectionView(store: CardWallInsuranceSelectionDomain.Dummies.store)
    }
}
