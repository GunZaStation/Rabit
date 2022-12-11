import Foundation
import RealmSwift

protocol RealmManagable {
    static var shared: Self { get }
    
    func read<T: Object>(entity: T.Type, filter query: String?) -> [T]
    func write<T: Object>(entity: T) throws
    func update<T: Object>(entity: T) throws
}

final class RealmManager: RealmManagable {
    
    private let realm: Realm
    static var shared = RealmManager()
    
    private init() {
        self.realm = try! Realm()
    }
    
    func read<T: Object>(entity: T.Type, filter query: String? = nil) -> [T] {
        if let query = query {
            return realm.objects(entity).filter(query).toArray(ofType: entity)
        } else {
            return realm.objects(entity).toArray(ofType: entity)
        }
    }
 
    func write<T: Object>(entity: T) throws {
        try? realm.write {
            realm.add(entity)
        }
    }

    func update<T: Object>(entity: T) throws {
        try? realm.write {
            realm.add(entity, update: .modified)
        }
    }
}
