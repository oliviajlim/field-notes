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
            if note.audioPath == nil {
                Button("Record") {
                    guard !audioManager.isRecording else {
                        // close it
                        audioManager.stopRecording()
                        return
                    }

                    // decide where the file lives, create an empty file

                    Task {
                        if await audioManager.requestMicrophonePermissions() {

                            audioManager.startRecording(id: note.id)
                            // write each buffer into it
                        }
                    }
                }
                .padding(.horizontal, 20)
            } else {
                Button("Play") {
                    print("play: \(String(describing: note.audioPath))")

                }
                .padding(.horizontal, 20)
            }

            if audioManager.activeRecordingNoteID == note.id != nil {
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
