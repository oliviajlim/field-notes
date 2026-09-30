import AVFAudio
import SwiftUI
import Playgrounds

@Observable
final class HomeViewModel {
    var notes: [FieldNote]

    init(notes: [FieldNote] = []) {
        self.notes = notes
    }
}

@Observable
final class AudioRecorderManager {
    var permissionStatus: AVAudioApplication.recordPermission = AVAudioApplication.shared.recordPermission

    var activeRecordingNoteID: UUID? = nil
    var recorder: AVAudioRecorder? = nil

    func requestMicrophonePermissions() async -> Bool {
        let granted = await AVAudioApplication.requestRecordPermission()
        print("granted \(granted)")
        self.permissionStatus = granted ? .granted : .denied
        return granted
    }

    func startRecording(id: UUID) {
        self.activeRecordingNoteID = id
//        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        self.recorder = AVAudioRecorder()
        recorder?.prepareToRecord()
    }

    func stopRecording() {
        self.activeRecordingNoteID = nil
        self.recorder = nil
    }
}

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    @State var audioManager = AudioRecorderManager()

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            ScrollView(.horizontal, showsIndicators: true) {
                LazyHStack(spacing: 0) {
                    ForEach($viewModel.notes) { $note in
                        FieldCard(note: $note, audioManager: audioManager)
                    }

                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .navigationTitle("Field Notes")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FieldCard: View {
    @Binding var note: FieldNote
    let audioManager: AudioRecorderManager

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(note.imagePath)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .containerRelativeFrame(.horizontal)
            Button(note.audioPath != nil ? "Play" : "Record") {
                Task {
                    if await audioManager.requestMicrophonePermissions() {
                        print("play: \(String(describing: note.audioPath))")

                        audioManager.startRecording(id: note.id)
                    }
                }
            }
            .padding(.horizontal, 20)

            if audioManager.activeRecordingNoteID != nil {
                Text("Recording...")
                    .padding(.horizontal, 20)
            }

            Text(note.createdAt, format: .dateTime.month(.abbreviated).day().year())
                .padding(.horizontal, 20)
            TextField("Caption", text: $note.text)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
    }
}

#Preview {
    let viewModel = HomeViewModel(notes: [
        FieldNote(
            createdAt: Date(),
            imagePath: "sample-image",
            audioPath: nil,
            text: "Sun and dance"
        ),
        FieldNote(
            createdAt: Date(),
            imagePath: "sample-image-2",
            audioPath: nil,
            text: "Sleep"
        )
    ])
    HomeView(viewModel: viewModel)
}
