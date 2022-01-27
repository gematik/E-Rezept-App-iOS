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
import Pharmacy
import SwiftUI

struct PharmacySearchResultView: View {
    static let minimumOpenMinutesLeftBeforeWarn = 30

    let store: PharmacySearchDomain.Store

    var body: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.state.searchState {
            case .searchRunning where viewStore.state.pharmacies.isEmpty:
                VStack(alignment: .leading) {
                    HStack {
                        ProgressView()
                            .padding([.leading, .trailing])
                            .hidden(viewStore.state.searchState != .searchRunning)
                        Text(L10n.phaSearchTxtProgressSearch)
                            .padding()
                        Spacer()
                    }
                    Spacer()
                }
            case .localizingDevice:
                HStack {
                    ProgressView()
                        .padding([.leading, .trailing])
                        .hidden(viewStore.state.searchState != .localizingDevice)
                    Text(L10n.phaSearchTxtProgressLocating)
                        .padding()
                    Spacer()
                }
            case .startView:
                HStack {
                    Spacer()
                    Text(L10n.phaSearchTxtMinSearchChars)
                        .padding()
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            case .searchResultEmpty:
                NoResultsView()
                    .padding(.horizontal, 30)
            case .searchResultOk, .searchRunning:
                // swiftlint:disable:next todo
                // TODO: refactor in one of the next tickets
//                SortAndFilterActionView(store: store)
//                    .padding([.horizontal, .top], 8)
//
//                if viewStore.state.pharmacyFilterOptions.isEmpty {
//                    FilterItemsView(store: store)
//                        .padding([.horizontal, .bottom], 8)
//                }

                PharmacyListView(
                    store: viewStore.state.isLoading ?
                        .init(
                            initialState: PharmacySearchDomain.State(
                                erxTasks: [],
                                pharmacies: PharmacyLocationViewModel.placeholderPharmacies
                            ),
                            reducer: .empty,
                            environment: ()
                        )
                        : store
                )
                .redacted(
                    reason: viewStore.state.isLoading ? .placeholder : []
                )
                .accessibility(identifier: A11y.pharmacySearch.phaSearchTxtResultList)
            case .searchAfterLocalizationWasAuthorized:
                EmptyView()
            case .error:
                ErrorView(store: store)
            }
        }
    }

    private struct SortAndFilterActionView: View {
        let store: PharmacySearchDomain.Store

        var body: some View {
            WithViewStore(store) { _ in
                HStack {
                    /*
                      swiftlint:disable:next todo
                      TODO: This filter button is deactivated until the ApoVZD-Server
                      provides the necessary data.

                     Button(action: {
                         viewStore.send(.showPharmacyFilterView)
                     }, label: {
                         Image(systemName: SFSymbolName.filter)
                         Text(L10n.phaSearchBtnShowFilterView)

                     })
                     .foregroundColor(Colors.primary600)
                     .font(Font.subheadline.weight(.semibold))
                     .padding(.trailing, 2)
                      */
                }
            }
        }
    }

    private struct FilterItemsView: View {
        let store: PharmacySearchDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                HStack {
                    ForEach(viewStore.state.pharmacyFilterOptions, id: \.self) { filterOption in
                        Button(action: {
                            viewStore.send(.removeFilterOption(filterOption))
                        }, label: {
                            HStack {
                                Text(filterOption.localizedString())
                                    .font(.footnote)
                                Image(systemName: SFSymbolName.crossIconFill)
                            }
                            .padding([.top, .bottom], 4)
                            .padding([.leading, .trailing], 8)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Colors.backgroundSecondary))
                        })
                    }
                }
                .foregroundColor(Colors.systemLabelSecondary)
            }
        }
    }

    private struct NoResultsView: View {
        var body: some View {
            VStack {
                Text(L10n.phaSearchTxtNoResultsTitle)
                    .font(.headline)
                    .padding(.bottom, 1)
                Text(L10n.phaSearchTxtNoResults)
                    .font(.subheadline)
                    .foregroundColor(Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private struct ErrorView: View {
        let store: PharmacySearchDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                VStack {
                    Text(L10n.phaSearchTxtErrorNoServerResponseHeadline)
                        .font(.headline)
                        .padding(.bottom, 1)

                    Text(L10n.phaSearchTxtErrorNoServerResponseSubheadline)
                        .font(.subheadline)
                        .foregroundColor(Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 1)

                    Button(
                        action: {
                            viewStore.send(.performSearch)
                        },
                        label: {
                            Text(L10n.phaSearchBtnErrorNoServerResponse)
                                .font(.subheadline)
                        }
                    )
                }
            }
        }
    }

    struct PharmacyListView: View {
        let store: PharmacySearchDomain.Store
        var body: some View {
            WithViewStore(store) { viewStore in
                List {
                    ForEach(viewStore.state.pharmacies, id: \.self) { pharmacyViewModel in
                        Button(
                            action: { viewStore.send(.showDetails(pharmacyViewModel)) },
                            label: { PharmacyCell(pharmacy: pharmacyViewModel) }
                        ).listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }

    private struct PharmacyCell: View {
        let pharmacy: PharmacyLocationViewModel
        var timeOnlyFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            if let preferredLang = Locale.preferredLanguages.first,
               preferredLang.starts(with: "de") {
                dateFormatter.dateFormat = "HH:mm 'Uhr'"
            } else {
                dateFormatter.timeStyle = .short
                dateFormatter.dateStyle = .none
            }
            return dateFormatter
        }()

        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    if pharmacy.pharmacyLocation.isErxReady {
                        ErxReadinessBadge(detailedText: false)
                            .padding([.top, .bottom], 1)
                    }

                    Text("\(pharmacy.pharmacyLocation.name ?? "")")
                        .fontWeight(.semibold)
                        .foregroundColor(Colors.systemLabel)
                        .padding([.top, .bottom], 1)
                    HStack {
                        Text(pharmacy.pharmacyLocation.address?.fullAddress ?? "")
                    }
                    .foregroundColor(Colors.systemLabelSecondary)

                    Group {
                        if case let PharmacyOpenHoursCalculator.TodaysOpeningState
                            .open(minutesLeft, closingDateTime) = pharmacy.todayOpeningState {
                            if let minutesLeft = minutesLeft,
                               minutesLeft < PharmacySearchResultView.minimumOpenMinutesLeftBeforeWarn {
                                Group {
                                    Text(L10n.phaSearchTxtClosingSoon) +
                                        Text(" - \(timeOnlyFormatter.string(from: closingDateTime))")
                                }.foregroundColor(Colors.yellow700)
                            } else {
                                Group {
                                    Text(L10n.phaSearchTxtOpenUntil) +
                                        Text(" \(timeOnlyFormatter.string(from: closingDateTime))")
                                }.foregroundColor(Colors.secondary600)
                            }
                        } else if case let PharmacyOpenHoursCalculator.TodaysOpeningState
                            .willOpen(_, openingDateTime) = pharmacy.todayOpeningState {
                            Group {
                                Text(L10n.phaSearchTxtOpensAt) +
                                    Text(" \(timeOnlyFormatter.string(from: openingDateTime))")
                            }.foregroundColor(Colors.yellow700)
                        } else if case PharmacyOpenHoursCalculator.TodaysOpeningState.closed =
                            pharmacy.todayOpeningState {
                            Text(L10n.phaSearchTxtClosed)
                                .foregroundColor(Colors.systemLabelSecondary)
                        }
                    }
                    .padding(.top, 1)
                    .font(Font.subheadline.weight(.semibold))
                }
                .accessibilityElement(children: .combine)
                .padding([.top, .bottom], 8)

                Spacer()

                if let distance = pharmacy.distanceInKm {
                    Text(String(format: "%.2f km", distance))
                        .font(Font.footnote.weight(.semibold))
                        .foregroundColor(Colors.systemLabelSecondary)
                        .padding([.leading, .trailing], 8)
                }

                Image(systemName: SFSymbolName.rightDisclosureIndicator)
                    .foregroundColor(Colors.systemLabelTertiary)
                    .unredacted()
            }
            .padding(.horizontal, 16)
        }
    }
}

struct PharmacySearchResultView_Previews: PreviewProvider {
    static var previews: some View {
        // Search with result
        PharmacySearchResultView(store: PharmacySearchDomain.Dummies.store)

        // Search with empty Result
        PharmacySearchResultView(
            store: PharmacySearchDomain.Dummies.storeFor(
                PharmacySearchDomain.Dummies.stateEmpty
            )
        )

        // Search with error response
        PharmacySearchResultView(
            store: PharmacySearchDomain.Dummies.storeFor(
                PharmacySearchDomain.Dummies.stateError
            )
        )
    }
}
