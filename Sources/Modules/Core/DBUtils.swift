import Foundation
import GRDB

public final class DBUtils {
    private init() {}

    public static let sharedDBPool = try! makeDBPool("db", "shared", "sqlite")

    private static func makeDBPool(_ dir: String, _ file: String, _ ext: String) throws -> DatabasePool {
        let dbDir = URL(fileURLWithPath: FileUtils.docDir, isDirectory: true)
            .appendingPathComponent(dir, isDirectory: true)

        try FileManager.default.createDirectory(
            at: dbDir,
            withIntermediateDirectories: true,
            attributes: nil
        )

        let dbPath = dbDir
            .appendingPathComponent(file, isDirectory: false)
            .appendingPathExtension(ext)
            .path

        let pool = try DatabasePool(path: dbPath)

        pool.setupMemoryManagement(in: UIApplication.shared)

        return pool
    }
}

extension DatabaseWriter {
    public func registerMigration(_ identifier: String, migrate: @escaping (Database) throws -> Void) throws {
        var migrator = DatabaseMigrator()
        migrator.registerMigration(identifier, migrate: migrate)
        try migrator.migrate(self)
    }
}
