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
import eRpStyleKit
import SwiftUI

extension MedicationReminderSetupView {
    struct RepetitionView: View {
        var store: StoreOf<MedicationReminderSetupDomain>

        var body: some View {
            WithViewStore(store) { $0 } content: { viewStore in
                VStack {
                    Form {
                        Section {
                            Button {
                                viewStore.send(.repetitionTypeChanged(.infinite))
                            } label: {
                                HStack {
                                    Text(L10n.medReminderTxtRepetitionTypeInfinite)
                                        .foregroundColor(Colors.text)
                                    Spacer()
                                    if viewStore.medicationSchedule.repetitionType == .infinite {
                                        Image(systemName: SFSymbolName.checkmark)
                                            .font(.body.weight(.semibold))
                                            .foregroundColor(Colors.primary)
                                    }
                                }
                            }
                            .accessibilityIdentifier(A11y.medicationReminder.medReminderBtnRepetitionInfinite)

                            Button {
                                viewStore.send(.repetitionTypeChanged(.finite))
                            } label: {
                                HStack {
                                    Text(L10n.medReminderTxtRepetitionTypeFinite)
                                        .foregroundColor(Colors.text)
                                    Spacer()
                                    if viewStore.medicationSchedule.repetitionType == .finite {
                                        Image(systemName: SFSymbolName.checkmark)
                                            .font(.body.weight(.semibold))
                                            .foregroundColor(Colors.primary)
                                    }
                                }
                            }
                            .accessibilityIdentifier(A11y.medicationReminder.medReminderBtnRepetitionFinite)

                            if viewStore.medicationSchedule.repetitionType == .finite {
                                DatePicker(
                                    L10n.medReminderBtnRepetitionDatepickerStart.text,
                                    selection: viewStore.$medicationSchedule.start,
                                    in: Date() ... Date.distantFuture,
                                    displayedComponents: .date
                                )
                                .accessibilityIdentifier(A11y.medicationReminder.medReminderBtnRepetitionDateStart)

                                DatePicker(
                                    L10n.medReminderBtnRepetitionDatepickerEnd.text,
                                    selection: viewStore.$medicationSchedule.end,
                                    in: viewStore.medicationSchedule.start ... Date.distantFuture,
                                    displayedComponents: .date
                                )
                                .accessibilityIdentifier(A11y.medicationReminder.medReminderBtnRepetitionDateEnd)
                            }
                        }
                    }
                }
                .navigationTitle(L10n.medReminderTxtRepetitionTitle)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
