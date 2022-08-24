import RealmSwift

protocol Persistable {
    associatedtype Entity: RealmSwift.Object

    init(entity: Entity)
    func toEntity() -> Entity
}
