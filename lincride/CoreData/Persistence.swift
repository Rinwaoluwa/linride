import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    private let logger: Logger = DefaultLogger.shared

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = SavedLocation(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "lincride")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                DefaultLogger.shared.log(
                    "Failed to load persistent store: \(error.localizedDescription)",
                    level: .error,
                    category: .database,
                    file: #file,
                    function: #function,
                    line: #line
                )
                
                // For now, we'll still use fatalError in development
                #if DEBUG
                fatalError("Unresolved error \(error), \(error.userInfo)")
                #endif
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext
        
        guard context.hasChanges else {
            logger.debug("No changes to save", category: .database)
            return
        }
        
        do {
            try context.save()
            logger.info("Successfully saved context", category: .database)
        } catch {
            logger.log(
                "Failed to save context: \(error.localizedDescription)",
                level: .error,
                category: .database,
                file: #file,
                function: #function,
                line: #line
            )
        }
    }

}
