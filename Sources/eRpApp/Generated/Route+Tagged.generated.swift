// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation



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
