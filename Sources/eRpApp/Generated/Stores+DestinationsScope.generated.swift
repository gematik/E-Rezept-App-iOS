// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import ComposableArchitecture
import Foundation




























extension Store where State == CardWallCANDomain.State, Action == CardWallCANDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<CardWallCANDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> CardWallCANDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \CardWallCANDomain.State.destination, action: CardWallCANDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<CardWallCANDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \CardWallCANDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}










extension Store where State == CardWallExtAuthSelectionDomain.State, Action == CardWallExtAuthSelectionDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<CardWallExtAuthSelectionDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> CardWallExtAuthSelectionDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \CardWallExtAuthSelectionDomain.State.destination, action: CardWallExtAuthSelectionDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<CardWallExtAuthSelectionDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \CardWallExtAuthSelectionDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}








extension Store where State == CardWallIntroductionDomain.State, Action == CardWallIntroductionDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<CardWallIntroductionDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> CardWallIntroductionDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \CardWallIntroductionDomain.State.destination, action: CardWallIntroductionDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<CardWallIntroductionDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \CardWallIntroductionDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}








extension Store where State == CardWallLoginOptionDomain.State, Action == CardWallLoginOptionDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<CardWallLoginOptionDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> CardWallLoginOptionDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \CardWallLoginOptionDomain.State.destination, action: CardWallLoginOptionDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<CardWallLoginOptionDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \CardWallLoginOptionDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}








extension Store where State == CardWallPINDomain.State, Action == CardWallPINDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<CardWallPINDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> CardWallPINDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \CardWallPINDomain.State.destination, action: CardWallPINDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<CardWallPINDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \CardWallPINDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}








extension Store where State == CardWallReadCardDomain.State, Action == CardWallReadCardDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<CardWallReadCardDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> CardWallReadCardDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \CardWallReadCardDomain.State.destination, action: CardWallReadCardDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<CardWallReadCardDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \CardWallReadCardDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}










extension Store where State == ChargeItemListDomain.State, Action == ChargeItemListDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<ChargeItemListDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> ChargeItemListDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \ChargeItemListDomain.State.destination, action: ChargeItemListDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<ChargeItemListDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \ChargeItemListDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}


















extension Store where State == EditProfileDomain.State, Action == EditProfileDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<EditProfileDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> EditProfileDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \EditProfileDomain.State.destination, action: EditProfileDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<EditProfileDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \EditProfileDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}


















extension Store where State == HealthCardPasswordDomain.State, Action == HealthCardPasswordDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<HealthCardPasswordDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> HealthCardPasswordDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \HealthCardPasswordDomain.State.destination, action: HealthCardPasswordDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<HealthCardPasswordDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \HealthCardPasswordDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}








extension Store where State == HealthCardPasswordReadCardDomain.State, Action == HealthCardPasswordReadCardDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<HealthCardPasswordReadCardDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> HealthCardPasswordReadCardDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \HealthCardPasswordReadCardDomain.State.destination, action: HealthCardPasswordReadCardDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<HealthCardPasswordReadCardDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \HealthCardPasswordReadCardDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}












extension Store where State == MainDomain.State, Action == MainDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<MainDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> MainDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \MainDomain.State.destination, action: MainDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<MainDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \MainDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}








extension Store where State == MedicationDomain.State, Action == MedicationDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<MedicationDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> MedicationDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \MedicationDomain.State.destination, action: MedicationDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<MedicationDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \MedicationDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}








extension Store where State == MedicationOverviewDomain.State, Action == MedicationOverviewDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<MedicationOverviewDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> MedicationOverviewDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \MedicationOverviewDomain.State.destination, action: MedicationOverviewDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<MedicationOverviewDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \MedicationOverviewDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}












extension Store where State == OrderDetailDomain.State, Action == OrderDetailDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<OrderDetailDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> OrderDetailDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \OrderDetailDomain.State.destination, action: OrderDetailDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<OrderDetailDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \OrderDetailDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}








extension Store where State == OrderHealthCardDomain.State, Action == OrderHealthCardDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<OrderHealthCardDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> OrderHealthCardDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \OrderHealthCardDomain.State.destination, action: OrderHealthCardDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<OrderHealthCardDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \OrderHealthCardDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}








extension Store where State == OrdersDomain.State, Action == OrdersDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<OrdersDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> OrdersDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \OrdersDomain.State.destination, action: OrdersDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<OrdersDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \OrdersDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}










extension Store where State == PharmacyDetailDomain.State, Action == PharmacyDetailDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<PharmacyDetailDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> PharmacyDetailDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \PharmacyDetailDomain.State.destination, action: PharmacyDetailDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<PharmacyDetailDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \PharmacyDetailDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}








extension Store where State == PharmacyRedeemDomain.State, Action == PharmacyRedeemDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<PharmacyRedeemDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> PharmacyRedeemDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \PharmacyRedeemDomain.State.destination, action: PharmacyRedeemDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<PharmacyRedeemDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \PharmacyRedeemDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}








extension Store where State == PharmacySearchDomain.State, Action == PharmacySearchDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<PharmacySearchDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> PharmacySearchDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \PharmacySearchDomain.State.destination, action: PharmacySearchDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<PharmacySearchDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \PharmacySearchDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}












extension Store where State == PrescriptionArchiveDomain.State, Action == PrescriptionArchiveDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<PrescriptionArchiveDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> PrescriptionArchiveDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \PrescriptionArchiveDomain.State.destination, action: PrescriptionArchiveDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<PrescriptionArchiveDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \PrescriptionArchiveDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}








extension Store where State == PrescriptionDetailDomain.State, Action == PrescriptionDetailDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<PrescriptionDetailDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> PrescriptionDetailDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \PrescriptionDetailDomain.State.destination, action: PrescriptionDetailDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<PrescriptionDetailDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \PrescriptionDetailDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}










extension Store where State == ProfileSelectionDomain.State, Action == ProfileSelectionDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<ProfileSelectionDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> ProfileSelectionDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \ProfileSelectionDomain.State.destination, action: ProfileSelectionDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<ProfileSelectionDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \ProfileSelectionDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}












extension Store where State == RedeemMethodsDomain.State, Action == RedeemMethodsDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<RedeemMethodsDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> RedeemMethodsDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \RedeemMethodsDomain.State.destination, action: RedeemMethodsDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<RedeemMethodsDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \RedeemMethodsDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}












extension Store where State == RegisteredDevicesDomain.State, Action == RegisteredDevicesDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<RegisteredDevicesDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> RegisteredDevicesDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \RegisteredDevicesDomain.State.destination, action: RegisteredDevicesDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<RegisteredDevicesDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \RegisteredDevicesDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}












extension Store where State == SettingsDomain.State, Action == SettingsDomain.Action {
    func destinationsScope<ChildState, ChildAction>(
        state: CasePath<SettingsDomain.Destinations.State?, ChildState>,
        action: @escaping (ChildAction) -> SettingsDomain.Destinations.Action
    ) -> Store<ChildState?, ChildAction> {
        self.scope(state: \SettingsDomain.State.destination, action: SettingsDomain.Action.destination)
            .scope(
                state: state.extract(from:),
                action: action
            )
    }

    func destinationsScope<ChildState>(
        state: CasePath<SettingsDomain.Destinations.State?, ChildState>
    ) -> Store<ChildState?, Action> {
        self.scope(state: \SettingsDomain.State.destination)
            .scope(state: state.extract(from:))
    }
}
