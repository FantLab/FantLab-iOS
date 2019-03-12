import Foundation
import RxSwift
import GRDB
import RxGRDB
import FLModels
import FLKit

public final class MyBookService {
    public static let shared = try! MyBookService(dbPool: DBUtils.sharedDBPool)

    private let dbPool: DatabasePool

    private init(dbPool: DatabasePool) throws {
        self.dbPool = dbPool

        try dbPool.registerMigration("1.0 - my books") { db in
            try MyBookModel.createTable(in: db)
        }
    }

    public func observeWorkIsMine(id: Int) -> Observable<Bool> {
        return MyBookModel.filter(key: id).rx.fetchCount(in: dbPool).map({ $0 > 0 })
    }

    public func markWorkAsMine(id: Int, group: MyBookModel.Group) {
        DispatchQueue.global().async {
            try? self.dbPool.write { db in
                try? MyBookModel(id: id, group: group, date: Date()).save(db)
            }
        }
    }

    public func removeWorkFromMine(id: Int) {
        DispatchQueue.global().async {
            try? self.dbPool.write { db in
                _ = try? MyBookModel.deleteOne(db, key: id)
            }
        }
    }
}

extension MyBookModel.Group: DatabaseValueConvertible {}

extension MyBookModel: FetchableRecord, PersistableRecord {
    static let idColumn = Column("id")
    static let groupColumn = Column("group")
    static let dateColumn = Column("date")

    public static var databaseTableName: String {
        return "my_books"
    }

    static func createTable(in db: Database) throws {
        try db.create(table: MyBookModel.databaseTableName, body: { table in
            table.column(MyBookModel.idColumn.name, .integer).primaryKey().notNull()
            table.column(MyBookModel.groupColumn.name, .integer).notNull()
            table.column(MyBookModel.dateColumn.name, .datetime).notNull()
        })
    }

    public convenience init(row: Row) {
        self.init(
            id: row[MyBookModel.idColumn],
            group: row[MyBookModel.groupColumn],
            date: row[MyBookModel.dateColumn]
        )
    }

    public func encode(to container: inout PersistenceContainer) {
        container[MyBookModel.idColumn] = id
        container[MyBookModel.groupColumn] = group
        container[MyBookModel.dateColumn] = date
    }
}
