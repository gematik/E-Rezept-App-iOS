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

import AVKit
import SwiftUI

struct LoopingVideoPlayerContainerView: UIViewRepresentable {
    typealias UIViewType = PlayerView

    let url: URL

    init(withURL url: URL) {
        self.url = url
    }

    func makeUIView(context _: Context) -> PlayerView {
        PlayerView(withURL: url)
    }

    func updateUIView(_: PlayerView, context _: Context) {}

    final class PlayerView: UIView {
        var player: AVPlayer? {
            get {
                playerLayer?.player
            }
            set {
                playerLayer?.player = newValue
            }
        }

        #if targetEnvironment(simulator)
        lazy var placeholerLabel: UILabel = {
            let label = UILabel(frame: CGRect(x: 16, y: 0, width: 200, height: 40))
            label.text = "VideoPlayer Placeholder"
            label.textAlignment = .center
            label.font = UIFont.preferredFont(forTextStyle: .footnote)
            label.textColor = .white
            return label
        }()

        override func layoutSubviews() {
            super.layoutSubviews()

            placeholerLabel.frame = bounds
        }
        #endif

        init(withURL url: URL) {
            super.init(frame: .zero)

            #if targetEnvironment(simulator)
            if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
                backgroundColor = UIColor.gray
                addSubview(placeholerLabel)
            }
            #endif

            #if DEBUG
            // Enable Subtitles
            let playerItem = AVPlayerItem(url: url)
            let asset = playerItem.asset

            if let group = asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible) {
                let locale = Locale(identifier: "eng")
                let options =
                    AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
                if let option = options.first {
                    // Select Spanish-language subtitle option
                    playerItem.select(option, in: group)
                }
            }

            player = AVPlayer(playerItem: playerItem)
            player?.appliesMediaSelectionCriteriaAutomatically = true
            #else

            player = AVPlayer(playerItem: AVPlayerItem(url: url))

            #endif

            if player?.currentItem?.currentTime() == player?.currentItem?.duration {
                player?.currentItem?.seek(to: .zero, completionHandler: nil)
            }
            player?.play()

            playerLayer?.contentsGravity = .resizeAspectFill
            playerLayer?.videoGravity = .resizeAspectFill

            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(playerItemDidReachEnd(notification:)),
                                                   name: .AVPlayerItemDidPlayToEndTime,
                                                   object: player?.currentItem)
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        var playerLayer: AVPlayerLayer? {
            layer as? AVPlayerLayer
        }

        override static var layerClass: AnyClass {
            AVPlayerLayer.self
        }

        @objc
        func playerItemDidReachEnd(notification _: Notification) {
            player?.currentItem?.seek(to: .zero, completionHandler: nil)
            player?.play()
        }
    }
}
