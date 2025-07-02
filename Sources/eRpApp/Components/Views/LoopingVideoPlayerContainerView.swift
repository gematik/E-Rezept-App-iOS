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

import AVKit
import SwiftUI

struct LoopingVideoPlayerContainerView: UIViewRepresentable {
    typealias UIViewType = PlayerView

    let url: URL

    init(withURL url: URL) {
        self.url = url
    }

    func makeUIView(context _: Context) -> PlayerView {
        PlayerView()
    }

    func updateUIView(_ playerView: PlayerView, context _: Context) {
        playerView.updateWith(url: url)
    }

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

        init() {
            super.init(frame: .zero)

            #if targetEnvironment(simulator)
            if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
                backgroundColor = UIColor.gray
                addSubview(placeholerLabel)
            }
            #endif

            playerLayer?.contentsGravity = .resizeAspectFill
            playerLayer?.videoGravity = .resizeAspectFill

            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(playerItemDidReachEnd(notification:)),
                                                   name: .AVPlayerItemDidPlayToEndTime,
                                                   object: player?.currentItem)
        }

        func updateWith(url: URL) {
            #if DEBUG
            // Enable Subtitles
            let playerItem = AVPlayerItem(url: url)
            let asset = playerItem.asset

            asset.loadMediaSelectionGroup(for: .legible) { group, _ in
                guard let group else { return }
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
