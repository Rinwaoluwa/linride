import Foundation

// MARK: - Logger Levels
enum LoggerLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    
    var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
}

// MARK: - Logger Categories
/// Log categories for organizing logs (Firefox pattern)
enum LoggerCategory: String {
    case location = "LOCATION"
    case search = "SEARCH"
    case database = "DATABASE"
    case ui = "UI"
    case general = "GENERAL"
}

// MARK: - Logger Protocol
protocol Logger: Sendable {
    func log(
        _ message: String,
        level: LoggerLevel,
        category: LoggerCategory,
        file: String,
        function: String,
        line: Int
    )
    
    func logError(error: Error, category: LoggerCategory, file: String, function: String, line: Int)
}

// MARK: - Default Logger Implementation
/// Simple console-based logger
/// In production, this could write to files or send to analytics
final class DefaultLogger: Logger {
    static let shared = DefaultLogger()
    
    private init() {}
    
    func log(
        _ message: String,
        level: LoggerLevel,
        category: LoggerCategory,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        
        // Format: [TIME] [LEVEL] [CATEGORY] Message (File:Line)
        print("\(level.emoji) [\(timestamp)] [\(level.rawValue)] [\(category.rawValue)] \(message) (\(fileName):\(line))")
    }
    
    func logError(
        error: Error,
        category: LoggerCategory,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let errorMessage: String
        
        if let customError = error as? CustomStringConvertible {
            errorMessage = customError.description
        } else {
            errorMessage = error.localizedDescription
        }
        
        log(errorMessage, level: .error, category: category, file: file, function: function, line: line)
    }
}

// MARK: - Convenience Extension
extension Logger {
    /// Convenience method for quick logging
    func debug(_ message: String, category: LoggerCategory = .general) {
        log(message, level: .debug, category: category, file: #file, function: #function, line: #line)
    }
    
    func info(_ message: String, category: LoggerCategory = .general) {
        log(message, level: .info, category: category, file: #file, function: #function, line: #line)
    }
    
    func warning(_ message: String, category: LoggerCategory = .general) {
        log(message, level: .warning, category: category, file: #file, function: #function, line: #line)
    }
    
    func error(_ message: String, category: LoggerCategory = .general) {
        log(message, level: .error, category: category, file: #file, function: #function, line: #line)
    }
}
