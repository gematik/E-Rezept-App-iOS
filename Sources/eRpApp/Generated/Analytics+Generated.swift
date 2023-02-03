// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

protocol AnalyticsScreen {
    var name: String { get }
}
typealias AnalyticsEvent = String

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - YAML Files












// swiftlint:disable identifier_name line_length number_separator type_body_length
 enum Analytics {
  enum Screens {
    static let alert = Alert()
    struct Alert: AnalyticsScreen {
      let name = "General Alert Dialog"
    }
    static let cardWallExtAuth = CardWallExtAuth()
    struct CardWallExtAuth: AnalyticsScreen {
      let name = "CardWall ExtAuth"
    }
    static let cardWallExtAuthConfirm = CardWallExtAuthConfirm()
    struct CardWallExtAuthConfirm: AnalyticsScreen {
      let name = "CardWall ExtAuth Confirm"
    }
    static let cardWallReadCard = CardWallReadCard()
    struct CardWallReadCard: AnalyticsScreen {
      let name = "CardWall / Connect"
    }
    static let cardWallReadCardHelp1 = CardWallReadCardHelp1()
    struct CardWallReadCardHelp1: AnalyticsScreen {
      let name = "CardWall Read Card Help 1"
    }
    static let cardWallReadCardHelp2 = CardWallReadCardHelp2()
    struct CardWallReadCardHelp2: AnalyticsScreen {
      let name = "CardWall Read Card Help 2"
    }
    static let cardWallReadCardHelp3 = CardWallReadCardHelp3()
    struct CardWallReadCardHelp3: AnalyticsScreen {
      let name = "CardWall Read Card Help 3"
    }
    static let cardwallCAN = CardwallCAN()
    struct CardwallCAN: AnalyticsScreen {
      let name = "CardWall / CAN"
    }
    static let cardwallContactInsuranceCompany = CardwallContactInsuranceCompany()
    struct CardwallContactInsuranceCompany: AnalyticsScreen {
      let name = "CardWall Contact Insurance Company"
    }
    static let cardwallContactInsuranceCompanySelectKK = CardwallContactInsuranceCompanySelectKK()
    struct CardwallContactInsuranceCompanySelectKK: AnalyticsScreen {
      let name = "CardWall Contact Insurance Company Select KK"
    }
    static let cardwallIntroduction = CardwallIntroduction()
    struct CardwallIntroduction: AnalyticsScreen {
      let name = "CardWall / Welcome"
    }
    static let cardwallNotCapable = CardwallNotCapable()
    struct CardwallNotCapable: AnalyticsScreen {
      let name = "CardWall / Not Capable"
    }
    static let cardwallPIN = CardwallPIN()
    struct CardwallPIN: AnalyticsScreen {
      let name = "CardWall / PIN"
    }
    static let cardwallSaveLogin = CardwallSaveLogin()
    struct CardwallSaveLogin: AnalyticsScreen {
      let name = "CardWall / SaveCredentials / Initial"
    }
    static let cardwallSaveLoginSecurityInfo = CardwallSaveLoginSecurityInfo()
    struct CardwallSaveLoginSecurityInfo: AnalyticsScreen {
      let name = "CardWall / SaveCredentials / Information"
    }
    static let cardwallScanCAN = CardwallScanCAN()
    struct CardwallScanCAN: AnalyticsScreen {
      let name = "CardWall Scan CAN"
    }
    static let errorAlert = ErrorAlert()
    struct ErrorAlert: AnalyticsScreen {
      let name = "Error Alert - "
    }
    static let main = Main()
    struct Main: AnalyticsScreen {
      let name = "Main Screen"
    }
  }
}
// swiftlint:enable identifier_name line_length number_separator type_body_length
