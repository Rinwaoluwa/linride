import SwiftUI

@main
struct lincrideApp: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext) .onChange(of: scenePhase) { oldValue, newValue in
                    if newValue == .background {
                        persistenceController.save()
                    }
                }
        }
    }
}

