//
//  AudioRecorderManager.swift
//  FieldNotes
//
//  Created by Olivia Lim on 10/1/26.
//

import Observation
import AVFAudio

@Observable
final class AudioRecorderManager {
    var permissionStatus: AVAudioApplication.recordPermission = AVAudioApplication.shared.recordPermission

    var activeRecordingNoteID: UUID? = nil
    private let audioEngine = AVAudioEngine()
    private var recordingFile: AVAudioFile?

    var isRecording: Bool {
        activeRecordingNoteID != nil
    }

    func requestMicrophonePermissions() async -> Bool {
        let granted = await AVAudioApplication.requestRecordPermission()
        print("granted \(granted)")
        self.permissionStatus = granted ? .granted : .denied
        return granted
    }

    func startRecording(id: UUID) {
        guard !isRecording else {
            print("already recording")
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)

            let format = audioEngine.inputNode.outputFormat(forBus: 0)
            /*
             • audioEngine.inputNode is the microphone's spot in the engine's plumbing. You don't create it; the engine already has one.
             • outputFormat asks what comes out of this node. Audio comes out of the mic node and flows toward your tap, so you want output.
             • forBus: 0 needs a word you haven't met: a bus is a numbered connection socket on a node. The mic node has one output socket, number 0.
             */
            print("Mic format: \(format)")

            activeRecordingNoteID = id
        } catch {
            print("error: \(error)")
        }
    }

    func stopRecording() {
        // trim audio

        self.activeRecordingNoteID = nil
        // should save the audio file locally

    }
}
