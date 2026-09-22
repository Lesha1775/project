import SwiftUI
import SwiftData

@main
struct HomePharmacyApp: App {
    var container: ModelContainer = {
        let schema = Schema([Medication.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Ошибка конфигурации контейнера SwiftData: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
