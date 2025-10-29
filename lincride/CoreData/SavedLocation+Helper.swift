import Foundation
import CoreData


extension SavedLocation {
    
    var name: String {
        get { name_ ?? ""  }
        set { name_ = newValue }
    }
    var address: String {
        get { address_ ?? ""  }
        set { address_ = newValue }
    }
    
    var timestamp: Date {
        get { timestamp_ ?? Date() }
        set { timestamp_ = newValue }
    }
    var locationId: String {
        get { locationId_ ?? "" }
        set { locationId_ = newValue }
    }
    
    convenience init(
        name: String,
        address: String,
        locationId: String,
        timestamp: Date,
        context: NSManagedObjectContext) {
            self.init(context: context)
            self.name = name
            self.address = address
            self.timestamp = timestamp
            self.locationId = locationId
        }
    
    static func delete(location: SavedLocation) {
        guard let context = location.managedObjectContext else {
            DefaultLogger.shared.warning("No managed object context for deletion", category: .database)
            return
        }
        context.delete(location)
        DefaultLogger.shared.info("Location deleted successfully", category: .database)
    }
    
    static func fetch(_ predicate: NSPredicate = .all) -> NSFetchRequest<SavedLocation> {
        let request = SavedLocation.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SavedLocation.timestamp_, ascending: true),
                                   NSSortDescriptor(keyPath: \SavedLocation.name_, ascending: true)]
        request.predicate = predicate
    
        return request
    }
    
}
