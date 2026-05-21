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

// swiftlint:disable file_length

import ComposableArchitecture
import eRpKit
import eRpStyleKit
import MapKit
import Perception
import SwiftUI
import SwiftUIIntrospect

struct PharmacyDetailView: View {
    @Bindable var store: StoreOf<PharmacyDetailDomain>

    var body: some View {
        VStack(spacing: 0) {
            if store.inOrdersMessage {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()

                        Button(action: { store.send(.delegate(.close)) }, label: {
                            Image(systemName: SFSymbolName.crossIconPlain)
                                .font(Font.caption.weight(.bold))
                                .foregroundColor(Colors.primary)
                                .padding(12)
                                .background(Circle().foregroundColor(Colors.systemGray6))
                        })
                        .accessibilityIdentifier(A11y.pharmacyDetail.phaDetailBtnClose)
                    }
                }
                .padding(.top)
                .padding(.horizontal)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(store.pharmacy.name ?? L10n.phaDetailTxtSubtitleFallback.text)
                                .font(.title2)
                                .accessibility(identifier: A11y.pharmacyDetail.phaDetailTxtSubtitle)

                            if let address = store.pharmacy.address?.fullAddress {
                                Button {
                                    store.send(.openMapApp)
                                } label: {
                                    Label {
                                        Text(address)
                                    } icon: {
                                        Image(systemName: SFSymbolName.map)
                                    }
                                }
                                .accessibilityLabel(L10n.phaDetailLblLocation(address))
                                .labelStyle(.trailingIcon)
                                .buttonStyle(.tertiary(isEnabled: store.pharmacy.canBeDisplayedInMap))
                                .accessibility(identifier: A11y.pharmacyDetail.phaDetailBtnLocation)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Button(
                            action: { store.send(.toggleIsFavorite) },
                            label: {
                                Image(systemName: store.pharmacy.isFavorite
                                    ? SFSymbolName.starFill
                                    : SFSymbolName.star)
                                    .foregroundColor(
                                        store.pharmacy.isFavorite ? Colors.starYellow : Color.gray
                                    )
                                    .font(.title3)
                            }
                        )
                        .accessibilityValue(Text(
                            store.pharmacy.isFavorite
                                ? L10n.phaDetailBtnFavoriteA11yValueEnabled
                                : L10n.phaDetailBtnFavoriteA11yValueDisabled
                        ))
                        .accessibilityHint(Text(
                            store.pharmacy.isFavorite
                                ? L10n.phaDetailBtnFavoriteA11yValueEnabledHint
                                : L10n.phaDetailBtnFavoriteA11yValueDisabledHint
                        ))
                    }.padding(.bottom, 24)

                    if store.inOrdersMessage {
                        ContactOptionsView(store: store)
                    }

                    if !store.serviceOptionState.availableOptions.isEmpty, !store.inOrdersMessage {
                        ServiceOptionView(store: store.scope(
                            state: \.serviceOptionState,
                            action: \.serviceOption
                        ))
                    }

                    if !store.pharmacy.hoursOfOperation.isEmpty {
                        OpeningHoursView(dailyOpenHours: store.pharmacyViewModel.openingHours)
                            .padding(.bottom, 8)
                    }

                    // "Vor Ort"
                    if !store.pharmacy.physicalFeatures.isEmpty {
                        PhysicalFeaturesView(physicalFeatures: store.pharmacy.physicalFeatures)
                            .padding(.bottom, 8)
                    }

                    if !store.pharmacy.specialities.isEmpty {
                        SpecialitiesView(specialities: store.pharmacy.specialities)
                            .padding(.bottom, 8)
                    }

                    if !store.pharmacy.emergencyServiceHours.isEmpty {
                        EmergencyServiceView(specialOpening: store.pharmacyViewModel.emergencyServiceHours)
                            .padding(.bottom, 8)
                    }

                    if !store.pharmacy.specialClosingHours.isEmpty {
                        SpecialClosingView(specialClosings: store.pharmacyViewModel.specialClosingHours)
                            .padding(.bottom, 8)
                    }

                    ContactView(store: store)

                    Footer()
                        .padding(.top, 4)
                }.padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(store.inOrdersMessage)
        .task {
            await store.send(.task).finish()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if store.inRedeemProcess {
                    NavigationBarCloseItem {
                        store.send(.delegate(.close))
                    }
                }
            }
        }
        .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
        .toast($store.scope(state: \.destination?.toast, action: \.destination.toast))
    }

    struct ContactOptionsView: View {
        @Bindable var store: StoreOf<PharmacyDetailDomain>

        var body: some View {
            HStack {
                if store.pharmacy.position?.longitude?.doubleValue != nil,
                   store.pharmacy.position?.latitude?.doubleValue != nil {
                    Button {
                        store.send(.openMapApp)
                    } label: {
                        Label {
                            Text(L10n.phaDetailBtnOpenMap)
                        } icon: {
                            Image(systemName: SFSymbolName.mapPinEllipse)
                                .font(.title2)
                                .foregroundColor(Colors.primary700)
                        }
                    }
                    .buttonStyle(.picture(isActive: true))
                    .accessibilityIdentifier(A11y.pharmacyDetail.phaDetailBtnOpenMap)
                }

                if store.pharmacy.telecom?.phone != nil {
                    Button {
                        store.send(.openPhoneApp)
                    } label: {
                        Label {
                            Text(L10n.phaDetailBtnOpenPhone)
                        } icon: {
                            Image(systemName: SFSymbolName.phone)
                                .font(.title2)
                                .foregroundColor(Colors.primary700)
                        }
                    }
                    .buttonStyle(.picture(isActive: true))
                    .accessibilityIdentifier(A11y.pharmacyDetail.phaDetailBtnOpenPhone)
                }

                if store.pharmacy.telecom?.email != nil {
                    Button {
                        store.send(.openMailApp)
                    } label: {
                        Label {
                            Text(L10n.phaDetailBtnOpenMail)
                        } icon: {
                            Image(systemName: SFSymbolName.envelope)
                                .font(.title2)
                                .foregroundColor(Colors.primary700)
                        }
                    }
                    .buttonStyle(.picture(isActive: true))
                    .accessibilityIdentifier(A11y.pharmacyDetail.phaDetailBtnOpenMail)
                }
            }
            .padding(.bottom, 24)
        }
    }
}

extension PharmacyDetailView {
    struct EmptyService: View {
        var body: some View {
            Button(
                action: {},
                label: {
                    Label {
                        Text("")
                    } icon: {
                        Image(systemName: "")
                            .resizable()
                            .padding(4)
                    }
                }
            ).buttonStyle(PictureButtonStyle(style: .supplyLarge, active: false, width: .narrow))
                .hidden()
        }
    }

    struct OpeningHoursView: View {
        let dailyOpenHours: [PharmacyLocationViewModel.OpeningHoursDay]

        @Dependency(\.date) var date

        var body: some View {
            HStack {
                Text(L10n.phaDetailOpeningTime)
                    .font(.headline)
                    .foregroundColor(Colors.systemLabel)
                    .accessibilityAddTraits(.isHeader)
                    .padding([.top])
                    .padding(.bottom, 8)
                Spacer()
            }

            // .weekday starts with 1 being sunday, +5 % 7 to let monday be 0 and the first day
            let todayWeekNumber = (Calendar.current.component(.weekday, from: date()) + 5) % 7

            // sorts open hours starting with today's weekday
            let sortedEntries = dailyOpenHours.sorted { lhs, rhs in
                let dayDiff = 7 - 2 * todayWeekNumber
                return (lhs.dayOfWeekNumber + todayWeekNumber + dayDiff) % 7
                    < (rhs.dayOfWeekNumber + todayWeekNumber + dayDiff) % 7
            }
            ForEach(sortedEntries, id: \.self) { dailyOpenHour in
                HStack(alignment: .top) {
                    let weekday: String = {
                        if todayWeekNumber == dailyOpenHour.dayOfWeekNumber {
                            return L10n.phaDetailTxtOpenHourToday.text
                        } else if (todayWeekNumber + 1) % 7 == dailyOpenHour.dayOfWeekNumber {
                            return L10n.phaDetailTxtOpenHourTomorrow.text
                        } else {
                            return dailyOpenHour.dayOfWeekLocalizedDisplayName
                        }
                    }()
                    Text(weekday)
                        .font(Font.body)
                        .foregroundColor(Colors.systemLabel)
                        .fontWeight(dailyOpenHour.openingState
                            .isOpen ? .semibold : .regular)
                        .accessibility(hint: dailyOpenHour.openingState
                            .isOpen ? Text(L10n.phaDetailOpeningToday) : Text(""))
                    Spacer(minLength: 0)
                    VStack(alignment: .trailing) {
                        ForEach(dailyOpenHour.entries, id: \.self) { hop in
                            Text("\(hop.openingTime ?? "") - \(hop.closingTime ?? "")")
                                .fontWeight(hop.openingState.isOpen ? .semibold : .regular)
                                .accessibility(label: makeAccessibilityText(opening: hop.openingTime ?? "",
                                                                            closing: hop.closingTime ?? ""))
                                .font(Font.monospacedDigit(.body)())
                                .foregroundColor(
                                    hop.openingState.isOpen ?
                                        Colors.secondary700 : Colors.systemLabelSecondary
                                )
                        }
                    }
                }
                .padding(.vertical, 8)
                Divider()
            }
        }

        func makeAccessibilityText(opening: String, closing: String) -> Text {
            Text("""
            \(opening)
            \(L10n.phaDetailOpeningTimeVoice.text)
            \(L10n.phaDetailOpeningUntil.text)
            \(closing)
            \(L10n.phaDetailOpeningTimeVoice.text)
            """)
        }
    }

    /// "Vor Ort"
    struct PhysicalFeaturesView: View {
        let physicalFeatures: [PharmacyLocation.PhysicalFeature]

        var body: some View {
            HStack {
                Text("Vor Ort")
                    .font(.headline)
                    .foregroundColor(Colors.systemLabel)
                    .accessibilityAddTraits(.isHeader)
                    .padding([.top])
                Spacer()
            }

            // Bullet points sorted alphabetically by their localized display name
            VStack(alignment: .leading, spacing: 8) {
                let sortedEntries = physicalFeatures.sorted { lhs, rhs in
                    lhs.localizedDisplayName.text < rhs.localizedDisplayName.text
                }
                ForEach(sortedEntries, id: \.self) { feature in
                    HStack(spacing: 4) {
                        Image(systemName: SFSymbolName.checkmarkCircleFill)
                            .font(.subheadline)
                            .foregroundColor(Colors.secondary600)
                            .accessibility(hidden: true)

                        Text(feature.localizedDisplayName.text)
                            .font(.body)
                            .foregroundColor(Colors.systemLabel)
                    }
                }
            }
        }
    }

    struct SpecialitiesView: View {
        let specialities: [PharmacyLocation.Speciality]

        var body: some View {
            HStack {
                Text(L10n.phaDetailSpecialities)
                    .font(.headline)
                    .foregroundColor(Colors.systemLabel)
                    .accessibilityAddTraits(.isHeader)
                    .padding([.top])
                Spacer()
            }

            let sorted = specialities.sorted { $0.localizedDisplayName.text < $1.localizedDisplayName.text }
            PharmacySearchFlowLayout(spacing: 8) {
                ForEach(sorted, id: \.self) { speciality in
                    ServiceChip(text: speciality.localizedDisplayName.text)
                }
            }
        }

        private struct ServiceChip: View {
            let text: String

            var body: some View {
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(Colors.primary900)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                    .background(Colors.primary100)
                    .cornerRadius(8)
            }
        }
    }

    struct EmergencyServiceView: View {
        let specialOpening: [PharmacyLocationViewModel.SpecialOperationHoursPeriod]
        var body: some View {
            HStack {
                Text(L10n.phaDetailEmergencyService)
                    .font(.headline)
                    .foregroundColor(Colors.systemLabel)
                    .accessibilityAddTraits(.isHeader)
                    .padding([.top])
                Spacer()
            }

            ForEach(specialOpening, id: \.self) { specialHours in
                HStack(spacing: 16) {
                    VStack {
                        Image(systemName: specialHours.imageName.symbolName)
                            .font(Font.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(specialHours.imageName.color)
                            .accessibilityHidden(true)

                        Spacer(minLength: 0)
                    }
                    HStack(spacing: 4) {
                        Text(specialHours.displayPeriod)
                            .font(Font.body)
                            .foregroundColor(specialHours.isActive ? Colors.secondary700 : Colors
                                .systemLabelSecondary)
                            .fontWeight(specialHours.isActive ? .semibold : .regular)
                            .accessibility(label: Text(specialHours.accessiblilityLabel))
                        Spacer(minLength: 0)
                    }
                }.padding(.leading, 16)
                Divider()
            }
        }
    }

    struct SpecialClosingView: View {
        let specialClosings: [PharmacyLocationViewModel.SpecialOperationHoursPeriod]
        var body: some View {
            HStack {
                Text(L10n.phaDetailSpecialClosing)
                    .font(.headline)
                    .foregroundColor(Colors.systemLabel)
                    .accessibilityAddTraits(.isHeader)
                    .padding([.top])
                Spacer()
            }

            ForEach(specialClosings, id: \.self) { closing in
                VStack(alignment: .leading, spacing: 4) {
                    Text(closing.reason)
                        .font(.footnote)
                        .italic()
                        .foregroundColor(closing.isActive ? Colors.secondary700 : Colors.systemLabelSecondary)
                        .fontWeight(closing.isActive ? .semibold : .regular)

                    HStack {
                        Text(closing.displayPeriod)
                            .font(Font.body)
                            .foregroundColor(closing.isActive ? Colors.secondary700 : Colors
                                .systemLabelSecondary)
                            .fontWeight(closing.isActive ? .semibold : .regular)
                            .accessibility(label: Text(closing.accessiblilityLabel))
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    Spacer(minLength: 0)
                }.padding([.vertical, .leading], 8)
                Divider()
            }
        }
    }

    struct ContactView: View {
        @Bindable var store: StoreOf<PharmacyDetailDomain>

        var body: some View {
            VStack {
                HStack {
                    Text(L10n.phaDetailContact)
                        .font(.headline)
                        .foregroundColor(Colors.systemLabel)
                        .accessibilityIdentifier(A11y.pharmacyDetail.phaDetailContact)
                        .accessibilityAddTraits(.isHeader)
                        .padding([.top])
                    Spacer()
                }

                if let phone = store.pharmacy.telecom?.phone {
                    Button(action: { store.send(.openPhoneApp) }, label: {
                        DetailedIconCellView(title: L10n.phaDetailPhone,
                                             value: phone,
                                             imageName: SFSymbolName.phone,
                                             a11y: A11y.pharmacyDetail.phaDetailPhone)
                    })
                }
                if let email = store.pharmacy.telecom?.email {
                    Button(action: { store.send(.openMailApp) }, label: {
                        DetailedIconCellView(title: L10n.phaDetailMail,
                                             value: email,
                                             imageName: SFSymbolName.mail,
                                             a11y: A11y.pharmacyDetail.phaDetailMail)
                    })
                }
                if let web = store.pharmacy.telecom?.web {
                    Button(action: { store.send(.openBrowserApp) }, label: {
                        DetailedIconCellView(title: L10n.phaDetailWeb,
                                             value: web,
                                             imageName: SFSymbolName.arrowUpForward,
                                             a11y: A11y.pharmacyDetail.phaDetailWeb)
                    })
                }
            }
        }
    }

    struct Footer: View {
        var text: Text = .init(L10n.phaDetailTxtFooterStart)
            .foregroundColor(Colors.systemLabelSecondary) +
            Text(L10n.phaDetailTxtFooterMid)
            .foregroundColor(Colors.primary)
            .underline() +
            Text(L10n.phaDetailTxtFooterEnd)
            .foregroundColor(Colors.systemLabelSecondary)

        var body: some View {
            VStack(alignment: .trailing, spacing: 8) {
                Button(action: {
                    guard let url = URL(string: "https://www.verzeichnis-ti.de/"),
                          UIApplication.shared.canOpenURL(url) else { return }

                    UIApplication.shared.open(url)
                }, label: {
                    text
                        .multilineTextAlignment(.leading)
                        .accentColor(Colors.primary)
                })
                Button(action: {
                    guard let url = URL(string: "https://www.gematik.de/anwendungen/e-rezept/faq/meine-apotheke/"),
                          UIApplication.shared.canOpenURL(url) else { return }

                    UIApplication.shared.open(url)
                }, label: {
                    Label {
                        Text(L10n.phaDetailBtnFooter)
                    } icon: {
                        Image(systemName: SFSymbolName.arrowUpForward)
                    }
                })
                .accessibilityLabel(L10n.phaDetailLblFooter)
                .labelStyle(.trailingIcon)
                .buttonStyle(.tertiary)
            }
            .font(.footnote)
        }
    }
}

struct PharmacyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PharmacyDetailView(store: PharmacyDetailDomain.Dummies.store)
        }

        NavigationStack {
            PharmacyDetailView(
                store: StoreOf<PharmacyDetailDomain>(
                    initialState: PharmacyDetailDomain.State(
                        prescriptions: Shared(value: PharmacyDetailDomain.Dummies.prescriptions),
                        selectedPrescriptions: Shared(value: []),
                        inRedeemProcess: false,
                        pharmacyViewModel: PharmacyDetailDomain.Dummies.pharmacyInactiveViewModel
                    )
                ) {
                    PharmacyDetailDomain()
                }
            )
        }

        NavigationStack {
            PharmacyDetailView(
                store: StoreOf<PharmacyDetailDomain>(
                    initialState: PharmacyDetailDomain.State(
                        prescriptions: Shared(value: PharmacyDetailDomain.Dummies.prescriptions),
                        selectedPrescriptions: Shared(value: []),
                        inRedeemProcess: false,
                        pharmacyViewModel: PharmacyDetailDomain.Dummies.pharmacyInactiveViewModel
                    )
                ) {
                    PharmacyDetailDomain()
                }
            )
        }
    }
}

#Preview("Specialities - Large Font") {
    ScrollView {
        PharmacyDetailView.SpecialitiesView(specialities: [
            .vaccination,
            .bodyMeasurements,
            .sterileCompounding,
            .allergyTest,
            .travelMedicineConsultation,
            .oralCancerTherapy,
            .organTransplantation,
            .polymedication,
            .inhalationTechnique,
            .hypertension,
        ])
        .padding()
    }
    .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}
