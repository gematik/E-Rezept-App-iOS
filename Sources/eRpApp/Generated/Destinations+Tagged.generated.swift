// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation


extension AppDomain.Destinations.State {
    enum Tag: Int {
        case main
        case pharmacy
        case orders
        case messages
        case settings
    }

    var tag: Tag {
        switch self {
            case .main:
                return .main
            case .pharmacy:
                return .pharmacy
            case .orders:
                return .orders
            case .messages:
                return .messages
            case .settings:
                return .settings
        }
    }
}
