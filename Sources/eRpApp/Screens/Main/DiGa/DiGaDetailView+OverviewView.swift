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

import ComposableArchitecture
import eRpKit
import eRpStyleKit
import SwiftUI

extension DiGaDetailView {
    struct OverviewView: View {
        @Perception.Bindable var store: StoreOf<DiGaDetailDomain>
        @Dependency(\.uiDateFormatter) var uiDateFormatter: UIDateFormatter

        var body: some View {
            WithPerceptionTracking {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.digaDtlTxtOverviewHeader)

                    Text(store.patientInfoText)
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))

                    ProgressListView(store: store)

                    if store.diGaInfo.diGaState == .insurance {
                        VStack(alignment: .center, spacing: 4) {
                            Button {
                                store.send(.refreshTask(silent: false))
                            } label: {
                                HStack(spacing: 4) {
                                    Text(L10n.digaDtlTxtOverviewRefresh)
                                        .foregroundColor(Colors.primary700)
                                        .font(Font.body)
                                    if store.refresh {
                                        ProgressView()
                                            .foregroundColor(Colors.primary700)
                                            .progressViewStyle(CircularProgressViewStyle())
                                    } else {
                                        Image(systemName: SFSymbolName.refresh)
                                            .foregroundColor(Colors.primary700)
                                    }
                                }
                            }.padding(.bottom, 4)
                                .accessibilityIdentifier(A11y.digaDetail.digaDtlBtnRefresh)
                            if let refreshTime = store.refreshTime {
                                HStack(spacing: 4) {
                                    Text(L10n.digaDtlTxtOverviewRefreshUpdate.text)
                                        .font(.subheadline)
                                        .foregroundColor(Color(.secondaryLabel))
                                    let localizedString = uiDateFormatter.relativeTime(
                                        from: refreshTime,
                                        formattingContext: .middleOfSentence
                                    )
                                    Text(localizedString)
                                        .font(.subheadline)
                                        .foregroundColor(Color(.secondaryLabel))
                                }
                                Text(L10n.digaDtlTxtOverviewRefreshWait)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color(.secondaryLabel))
                            }
                        }.frame(maxWidth: .infinity, alignment: .center)
                    }

                    GreyDivider()
                        .padding(.top, 40)
                        .padding(.bottom, 16)

                    FooterView(store: store)

                }.padding()
            }
        }

        struct ProgressListView: View {
            @Perception.Bindable var store: StoreOf<DiGaDetailDomain>
            @ScaledMetric var iconHeight: CGFloat = 20

            var body: some View {
                WithPerceptionTracking {
                    VStack(alignment: .leading) {
                        Text(L10n.digaDtlTxtOverviewListHeader)
                            .font(Font.body.weight(.semibold))

                        ForEach(store.displayDiGaStates, id: \.self) { status in
                            WithPerceptionTracking {
                                HStack(spacing: 4) {
                                    switch status.getLeadingItem(currentState: store.diGaInfo.diGaState) {
                                    case let .text(text):
                                        Text(text)
                                    case let .symbol(sfsymbolName):
                                        Image(systemName: sfsymbolName)
                                            .offset(x: -4)
                                            .foregroundStyle(status
                                                .foregroundColor(currentState: store.diGaInfo.diGaState))
                                    }
                                    if let code = store.diGaDispense?.redeemCode, status == .insurance {
                                        Text(L10n.digaDtlTxtOverviewListRecieved)
                                        Button {
                                            store.send(.copyCode(code), animation: .bouncy)
                                        } label: {
                                            HStack {
                                                Text(code).fontWeight(.bold)
                                                Image(systemName: store.successCopied ? SFSymbolName
                                                    .checkmark : SFSymbolName.copy).frame(
                                                    height: iconHeight,
                                                    alignment: .leading
                                                )
                                            }.foregroundColor(Colors.systemLabel)
                                        }
                                        .buttonStyle(.borderless)
                                    } else if let description = status.description {
                                        if status == .insurance, store.diGaInfo.diGaState == .insurance {
                                            Text(L10n.diGaDtlTxtOverviewListWaiting)
                                                .foregroundStyle(Colors.yellow900)
                                        } else if status == .insurance, store.diGaInfo.diGaState == .noInformation {
                                            Text(L10n.digaDtlTxtOverviewListInsuranceCompanyMessage)
                                        } else {
                                            Text(description)
                                                .foregroundStyle(status
                                                    .foregroundColor(currentState: store.diGaInfo.diGaState))
                                        }
                                    }
                                }
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel(status.accessiblilityText)
                                .accessibilityHint(status.getAccessibilityHint(currentState: store.diGaInfo.diGaState))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                                .background(status.backgroundColor(currentState: store.diGaInfo.diGaState))
                                .cornerRadius(8)

                                if let dispense = store.diGaTask.erxTask.medicationDispenses.first,
                                   dispense.diGaDispense?.isMissingData ?? false, status == .insurance,
                                   let note = dispense.noteText {
                                    VStack(alignment: .leading) {
                                        Text(note)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(8)
                                            .multilineTextAlignment(.leading)
                                            .background(Colors.red100)
                                            .cornerRadius(8)
                                            .accessibilityIdentifier(A11y.digaDetail.digaDtlTxtDeclineNote)
                                    }
                                    .padding(.leading, 24)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                }
                            }
                        }
                    }.padding(.top, 24)
                }
            }
        }

        struct FooterView: View {
            @Perception.Bindable var store: StoreOf<DiGaDetailDomain>
            @ScaledMetric var iconWidth: CGFloat = 24

            var body: some View {
                WithPerceptionTracking {
                    VStack(alignment: .leading, spacing: 16) {
                        if store.bfarmDiGaDetails?.description != nil {
                            Button {
                                store.send(.setNavigation(tag: .descriptionDiGA))
                            } label: {
                                HStack {
                                    Image(systemName: SFSymbolName.lightbulbMax)
                                        .frame(width: iconWidth, alignment: .center)
                                        .foregroundColor(Colors.systemLabel)
                                    Text(L10n.digaDtlBtnOverviewDescription)
                                        .padding(.leading, 4)
                                        .foregroundColor(Colors.systemLabel)
                                        .font(Font.body)
                                    Image(systemName: SFSymbolName.chevronRight)
                                        .padding(.leading, 8)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Colors.primary700)
                                }
                            }
                            .navigationDestination(
                                item: $store.scope(state: \.destination?.descriptionDiGA,
                                                   action: \.destination.descriptionDiGA)
                            ) { _ in
                                DiGaDescriptionView(store: store)
                            }
                        }

                        if store.diGaDispense?.redeemCode != nil,
                           store.bfArMDisplayInfo?.supportText != nil {
                            Button {
                                store.send(.setNavigation(tag: .supportDiGa))
                            } label: {
                                HStack {
                                    Image(systemName: SFSymbolName.infoBubble)
                                        .frame(width: iconWidth, alignment: .center)
                                        .foregroundColor(Colors.systemLabel)
                                    Text(L10n.digaDtlBtnOverviewSupport)
                                        .padding(.leading, 4)
                                        .foregroundColor(Colors.systemLabel)
                                        .font(Font.body)
                                    Image(systemName: SFSymbolName.info)
                                        .padding(.leading, 8)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Colors.primary700)
                                }
                            }
                            .smallSheet(
                                $store.scope(state: \.destination?.supportDiGa, action: \.destination.supportDiGa)
                            ) { _ in
                                DiGaSupportView(store: store)
                            }
                        }

                        switch store.diGaInfo.diGaState {
                        case .request:
                            Button {
                                store.send(.setNavigation(tag: .validDiGa))
                            } label: {
                                HStack {
                                    Image(systemName: SFSymbolName.calendarClock)
                                        .frame(width: iconWidth, alignment: .center)
                                        .foregroundColor(Colors.systemLabel)
                                    Text(store.diGaTask.expiresUntilDisplayDate)
                                        .foregroundColor(Colors.systemLabel)
                                        .padding(.horizontal, 4)
                                    Image(systemName: SFSymbolName.info)
                                        .frame(width: iconWidth, alignment: .center)
                                        .padding(.leading, 4)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Colors.primary700)
                                }
                            }
                            .smallSheet(
                                $store.scope(state: \.destination?.validDiGa, action: \.destination.validDiGa)
                            ) { _ in
                                DiGaValidView(store: store)
                            }
                        case .insurance:
                            HStack {
                                Image(systemName: SFSymbolName.checkmark)
                                    .fontWeight(.semibold)
                                    .frame(width: iconWidth, alignment: .center)
                                Text(store.diGaTask.requestedAtDate)
                                    .padding(.leading, 4)
                            }
                        case .download, .activate, .completed, .archive:
                            HStack {
                                Image(systemName: SFSymbolName.checkmark)
                                    .fontWeight(.semibold)
                                    .frame(width: iconWidth, alignment: .center)
                                Text(store.diGaTask.completedDate)
                                    .padding(.leading, 4)
                            }
                        case .noInformation:
                            HStack(spacing: 4) {
                                Image(systemName: SFSymbolName.checkmark)
                                Text(store.diGaTask.declinedDate)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DiGaDetailView.OverviewView(store: DiGaDetailDomain.Dummies.store)
    }
}
