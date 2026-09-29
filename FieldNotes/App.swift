import SwiftUI

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            let viewModel = HomeViewModel()
            HomeView(viewModel: viewModel)
        }
    }
}
