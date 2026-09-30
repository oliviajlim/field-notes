import SwiftUI

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
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
    }
}
