// Generated using Sourcery 2.1.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation



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
extension ReadCardHelpDomain.State {
    enum Tag: Int {
        case first
        case second
        case third
        case fourth
    }

    var tag: Tag {
        switch self {
            case .first:
                return .first
            case .second:
                return .second
            case .third:
                return .third
            case .fourth:
                return .fourth
        }
    }
}
