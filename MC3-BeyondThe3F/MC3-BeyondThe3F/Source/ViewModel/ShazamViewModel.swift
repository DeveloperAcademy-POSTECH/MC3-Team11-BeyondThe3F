//
//  ShazamManager.swift
//  MC3-BeyondThe3F
//
//  Created by Seungui Moon on 2023/07/25.
//


import AVKit
import ShazamKit
import Combine

@MainActor
class ShazamViewModel: NSObject, ObservableObject {
    @Published var currentItem: SHMediaItem? = nil
    @Published var shazaming = false

    private let session = SHSession()
    private let audioEngine = AVAudioEngine()

    override init() {
        super.init()
        session.delegate = self
    }

    private func prepareAudioRecording() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func generateSignature() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: .zero)

        inputNode.installTap(onBus: .zero, bufferSize: 1024, format: recordingFormat) { [weak session] buffer, _ in
            session?.matchStreamingBuffer(buffer, at: nil)
        }
    }

    private func startAudioRecording() throws {
        try audioEngine.start()
        shazaming = true
    }

    public func startRecognition() {
        do {
            if audioEngine.isRunning {
                stopRecognition()
                return
            }

            try prepareAudioRecording()
            generateSignature()
            try startAudioRecording()
        } catch {
            print(error.localizedDescription)
        }
    }

    public func stopRecognition() {
        shazaming = false
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: .zero)
    }
}

extension ShazamViewModel: SHSessionDelegate {
    func session(_ session: SHSession, didFind match: SHMatch) {
        guard let mediaItem = match.mediaItems.first else { return }

        Task {
            self.currentItem = mediaItem
        }
    }
}
