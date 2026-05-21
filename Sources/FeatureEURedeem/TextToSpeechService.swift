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

import AVFoundation
import Dependencies
import DependenciesMacros

/// A service that turns localized text into speech
@DependencyClient
public struct TextToSpeechService {
    /// Uses text to speech synthesizer for the given `String`.
    ///
    /// - Warning: Do not use this inside a concurrent context (unsafeForcedSync).
    ///
    /// For more information, see:
    /// [Apple Developer Forums](https://developer.apple.com/forums/thread/802423)
    @available(*, noasync)
    public var speakText: @Sendable (_ text: String, _ countryCode: String) throws -> Void
}

extension TextToSpeechService: DependencyKey {
    public static var liveValue: TextToSpeechService = {
        let ttsManager = TextToSpeechManager()
        return TextToSpeechService { text, countryCode in
            ttsManager.speakText(text, voice: AVSpeechSynthesisVoice(language: countryCode))
        }
    }()
}

extension DependencyValues {
    /// Service to use text to speech
    public var textToSpeechService: TextToSpeechService {
        get { self[TextToSpeechService.self] }
        set { self[TextToSpeechService.self] = newValue }
    }
}

@Observable
final class TextToSpeechManager {
    var error: Error?
    private let synthesizer = AVSpeechSynthesizer()
    private let audioSession = AVAudioSession.sharedInstance()

    init() {
        do {
            try setupAudioSession()
        } catch {
            self.error = error
        }
    }

    deinit {
        try? self.restoreAudioSession()
    }

    private func setupAudioSession() throws {
        try audioSession.setCategory(.playback, mode: .voicePrompt, options: [.duckOthers])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func restoreAudioSession() throws {
        try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
    }

    func speakText(
        _ string: String,
        voice: AVSpeechSynthesisVoice? = nil,
        rate: Float = AVSpeechUtteranceDefaultSpeechRate,
        pitchMultiplier: Float = 1.0,
        volume: Float = 1.0,
        preUtteranceDelay: TimeInterval = 0.0,
        postUtteranceDelay: TimeInterval = 0.0
    ) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = voice
        utterance.rate = rate
        utterance.pitchMultiplier = pitchMultiplier
        utterance.volume = volume
        utterance.preUtteranceDelay = preUtteranceDelay
        utterance.postUtteranceDelay = postUtteranceDelay

        speak(utterance)
    }

    private func speak(_ utterance: AVSpeechUtterance) {
        synthesizer.speak(utterance)
    }
}
