import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.dependencies) private var dependencies

    var body: some View {
        TabView {
            if let deps = dependencies {
                HomeView(queryViewModel: QueryViewModel(brain: deps.itemFinder))
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                ItemsView(viewModel: ItemsViewModel(
                    repository: deps.itemsRepository,
                    mutableRepository: deps.itemsRepository
                ))
                .tabItem {
                    Label("Items", systemImage: "list.bullet")
                }

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("App settings")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    let dependencies = try! DependencyContainer.preview()
    return ContentView()
        .environment(\.dependencies, dependencies)
}
