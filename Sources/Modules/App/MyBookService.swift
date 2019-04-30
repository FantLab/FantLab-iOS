import Foundation
import RxSwift
import RxRelay
import FLKit
import FLModels
import FLExtendedModels

struct MyBookModel: Codable {
    enum Group: Int, Codable, CaseIterable, CustomStringConvertible {
        case favorites = 1
        case wantToRead

        var description: String {
            switch self {
            case .favorites:
                return "Избранное"
            case .wantToRead:
                return "Хочу почитать"
            }
        }
    }

    let id: Int
    let group: Group
    let date: Date
}

final class MyBookService {
    enum Event {
        case add(workId: Int, group: MyBookModel.Group)
        case remove(workId: Int)
    }

    private let disposeBag = DisposeBag()
    private let fileStorage: FileStorage<[Int: MyBookModel]>
    private let eventRelay = PublishRelay<Event>()

    init(fileName: String) {
        fileStorage = FileStorage(fileName: fileName, defaultValue: [:])

        eventRelay.asObservable()
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .scan(into: fileStorage.value) { (table, event) in
                switch event {
                case let .add(workId: workId, group: group):
                    table[workId] = MyBookModel(
                        id: workId,
                        group: group,
                        date: Date()
                    )
                case let .remove(workId: workId):
                    table[workId] = nil
                }
            }
            .subscribe(onNext: { [fileStorage] table in
                fileStorage.value = table
            })
            .disposed(by: disposeBag)
    }

    // MARK: -

    var eventStream: Observable<Event> {
        return eventRelay.asObservable()
    }

    func contains(workId: Int) -> Bool {
        return fileStorage.value[workId] != nil
    }

    func add(workId: Int, group: MyBookModel.Group) {
        eventRelay.accept(.add(workId: workId, group: group))
    }

    func remove(workId: Int) {
        eventRelay.accept(.remove(workId: workId))
    }

    func itemsIn(group: MyBookModel.Group) -> [MyBookModel] {
        return fileStorage.value.values.filter({
            $0.group == group
        })
    }
}
