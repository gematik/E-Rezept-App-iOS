// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation



extension AppMigrationDomain.State {
    enum Tag: Int {
        case none
        case inProgress
        case finished
        case failed
    }

    var tag: Tag {
        switch self {
            case .none:
                return .none
            case .inProgress:
                return .inProgress
            case .finished:
                return .finished
            case .failed:
                return .failed
        }
    }
}
extension AppStartDomain.State {
    enum Tag: Int {
        case loading
        case onboarding
        case app
    }

    var tag: Tag {
        switch self {
            case .loading:
                return .loading
            case .onboarding:
                return .onboarding
            case .app:
                return .app
        }
    }
}
extension CardWallReadCardHelpDomain.State {
    enum Tag: Int {
        case first
        case second
        case third
    }

    var tag: Tag {
        switch self {
            case .first:
                return .first
            case .second:
                return .second
            case .third:
                return .third
        }
    }
}
extension ExtAuthPendingDomain.State {
    enum Tag: Int {
        case empty
        case pendingExtAuth
        case extAuthReceived
        case extAuthSuccessful
        case extAuthFailed
    }

    var tag: Tag {
        switch self {
            case .empty:
                return .empty
            case .pendingExtAuth:
                return .pendingExtAuth
            case .extAuthReceived:
                return .extAuthReceived
            case .extAuthSuccessful:
                return .extAuthSuccessful
            case .extAuthFailed:
                return .extAuthFailed
        }
    }
}
