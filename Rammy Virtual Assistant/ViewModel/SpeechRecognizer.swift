//
//  SpeechRecognizer.swift
//  Rammy Virtual Assistant
//
//  Created by Saravanakumar G on 13/07/23.
//

import Speech

final class SpeechRecognizer: NSObject {
    static let shared = SpeechRecognizer()
    private(set) var isEnable = false

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private override init() {}

    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            Task { @MainActor in
                switch status {
                case .authorized: self.isEnable = true
                case .denied: self.isEnable = false // User denied
                case .restricted: self.isEnable = false // Speech recognition restricted on this device.
                case .notDetermined: self.isEnable = false // Not yet authorized
                default: self.isEnable = false
                }
            }
        }
    }

    func startRecording(progressHandler: @escaping (String) -> Void = {_ in }) {
        guard !audioEngine.isRunning else { return }

        try? record(progressHandler: progressHandler)
    }

    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        } else {
            // do nothing
        }
    }

    private func record(progressHandler: @escaping (String) -> Void) throws {

        recognitionTask?.cancel()
        recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()


        try audioSession.setCategory(.playAndRecord, options: .mixWithOthers)

        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode

        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else {
            fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true

        // Keep speech recognition data on device
        //    if #available(iOS 13, *) {
        //        recognitionRequest.requiresOnDeviceRecognition = false
        //    }

        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false

            if let result {
                progressHandler(result.bestTranscription.formattedString)
                isFinal = result.isFinal
//                debugLog("Text \(result.bestTranscription.formattedString)")
            }

            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }

        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024,
                             format: recordingFormat) { (buffer: AVAudioPCMBuffer, _: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }
}

extension SpeechRecognizer: SFSpeechRecognizerDelegate {
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        isEnable = available
    }
}
