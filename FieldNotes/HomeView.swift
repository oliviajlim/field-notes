import SwiftUI
import Playgrounds

@Observable
class HomeViewModel {
    var notes: [FieldNote]

    init(notes: [FieldNote] = []) {
        self.notes = notes
    }
}

struct HomeView: View {
    @State var viewModel: HomeViewModel
    let items: [Color] = [.red, .blue, .green, .orange, .purple]

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 15){
                ScrollView(.horizontal, showsIndicators: true) {
                    LazyHStack(spacing: 0) {
                        ForEach(viewModel.notes) { note in
                            Image(note.imagePath)
                                .frame(height: 500)
                                .padding(.horizontal, 20)
                                .containerRelativeFrame(.horizontal)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
            }
            .navigationTitle("FieldNotes")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let viewModel = HomeViewModel(notes: [
        FieldNote(
            imagePath: "sample-image",
            audioPath: "",
            text: "Text"
        )
        ]
    )
    HomeView(viewModel: viewModel)
}

#Playground {
    _ = 1 + 2
}
