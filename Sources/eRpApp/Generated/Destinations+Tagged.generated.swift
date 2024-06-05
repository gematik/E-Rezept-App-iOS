// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation


extension AppDomain.Destinations.State {
    enum Tag: Int {
        case main
        case pharmacySearch
        case orders
        case settings
    }

    var tag: Tag {
        switch self {
            case .main:
                return .main
            case .pharmacySearch:
                return .pharmacySearch
            case .orders:
                return .orders
            case .settings:
                return .settings
        }
    }
}
