//
//  Copyright (c) 2023 gematik GmbH
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

import SwiftUI

// swiftlint:disable missing_docs

public enum SFSymbolName {
    public static let checkmark = "checkmark"
    public static let cardIcon = "creditcard"
    public static var cardIconAnd123 = "creditcard.and.123"
    public static let back = "chevron.left"
    public static let threeDots = "ellipsis.circle"
    public static let ellipsis = "ellipsis"
    public static let plus = "plus"
    public static let barCode = "barcode.viewfinder"
    public static let list = "list.dash"
    public static let message = "message"
    public static let textBubble = "text.bubble"
    public static let bubbleLeft = "bubble.left"
    public static let magnifyingGlasCircle = "magnifyingglass.circle"
    public static let magnifyingGlas = "magnifyingglass"
    public static let magnifyingGlasPlus = "plus.magnifyingglass"
    public static let bell = "bell"
    public static let ant = "ant"
    public static let bicycle = "bicycle"
    public static let car = "car"
    public static let shippingbox = "shippingbox"
    public static let envelope = "envelope"
    public static let rollback = "arrow.counterclockwise"
    public static let crossIcon = "xmark.circle"
    public static let crossIconFill = "xmark.circle.fill"
    public static let crossIconPlain = "xmark"
    public static let info = "info.circle"
    public static let qrCode = "qrcode"
    public static let person = "person.crop.circle"
    public static let camera = "camera"
    public static let cameraViewfinder = "camera.viewfinder"
    public static let docTextViewfinder = "doc.text.viewfinder"
    public static let plusViewFinder = "plus.viewfinder"
    public static let rightDisclosureIndicator = "chevron.right"
    public static let rightDetailDisclosure = "chevron.right.circle.fill"
    public static let checkIcon = "checkmark.circle"
    public static let nfc = "radiowaves.right"
    public static let network = "network"
    public static let phone = "phone"
    public static let mail = "mail"
    public static let safari = "safari"
    public static let phoneSquare = "number.square"
    public static let flipPhone = "flipphone"
    public static let settings = "gearshape"
    public static let sliderHorizontal3 = "slider.horizontal.3"
    public static let refresh = "arrow.clockwise"
    public static let exclamationMark = "exclamationmark.triangle"
    public static let wandAndStars = "wand.and.stars"
    public static let waveformEcg = "waveform.path.ecg"
    public static let arrowRight = "arrow.right"
    public static let arrowRightCircleFill = "arrow.right.circle.fill"
    public static let pencil = "pencil"
    public static let squareAndPencil = "square.and.pencil"
    public static let share = "square.and.arrow.up"
    public static let shield = "shield"
    public static let heartTextSquare = "heart.text.square"
    public static let docPlaintext = "doc.plaintext"
    public static let copy = "doc.on.doc"
    public static let map = "map"
    public static let arrowUpForward = "arrow.up.forward"
    public static let house = "house"
    public static let key = "key"
    public static let arrowUpArrowDown = "arrow.up.arrow.down"
    public static let play = "play"
    public static let paperplane = "paperplane"
    public static let pills = "pills"
    public static let trayAndArrowDown = "tray.and.arrow.down"
    public static let clipboardDoc = "doc.text.below.ecg"
    public static let star = "star"
    public static let starFill = "star.fill"
    public static let photoOnRect = "photo.on.rectangle"

    public static let numbers1circle = "1.circle"
    public static let numbers2circle = "2.circle"
    public static let numbers3circle = "3.circle"

    public static let numbers1circleFill = "1.circle.fill"
    public static let numbers2circleFill = "2.circle.fill"
    public static let numbers3circleFill = "3.circle.fill"

    public static let cross = "multiply"
    public static let circle = "circle"
    public static let circleFill = "circle.fill"
    public static let checkmarkCircle = "checkmark.circle"
    public static let checkmarkCircleFill = "checkmark.circle.fill"
    public static let xmarkCircleFill = "xmark.circle.fill"
    public static let plusCircleFill = "plus.circle.fill"

    public static let faceId = "faceid"
    public static let touchId = "touchid"
    public static let lockOpen = "lock.open"
    public static let lockRotation = "lock.rotation"
    public static let trash = "trash"
    public static let bag = "bag"
    public static let location = "location"
    public static let locationFill = "location.fill"
    public static let chevronUp = "chevron.up"
    public static let chevronDown = "chevron.down"
    public static let chevronRight = "chevron.right"
    public static let chevronLeft = "chevron.left"
    public static let chevronForward = "chevron.forward"
    public static let chevronBackward = "chevron.backward"
    public static let lightbulb = "lightbulb"
    public static let lightbulbSlash = "lightbulb.slash"
    public static let questionmarkCircle = "questionmark.circle"
    public static let personCirclePlus = "person.crop.circle.badge.plus"
    public static let personCircle = "person.circle"
    public static let boltFill = "bolt.fill"
    public static let sparkles = "sparkles"
    public static let photo = "photo"
    public static var filter = "line.3.horizontal.decrease.circle"

    public static let rectangleAndPencilAndEllipsis = "rectangle.and.pencil.and.ellipsis"
    public static let eye = "eye"
    public static let eyeSlash = "eye.slash"
    public static let calendarClock = "calendar.badge.clock"
    public static var calendarWarning = "calendar.badge.exclamationmark"

    public static var clockWarning = "clock.badge.exclamationmark"
    public static var iPhonelocked = "lock.iphone"

    public static let hourglass = "hourglass"
    public static var euroSign: String {
        if #available(iOS 16.0, *) {
            return "eurosign"
        } else {
            return "eurosign.circle"
        }
    }
}

public enum UnicodeCharacter {
    public static let bullet = "\u{2022}"
}

// swiftlint:enable missing_docs
