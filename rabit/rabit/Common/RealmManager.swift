import Foundation
import RealmSwift

final class RealmManager {
    
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
 
    func write(entity: Object) throws {
        try? realm.write {
            realm.add(entity)
        }
    }

    func update<T: Object>(entity: T) throws {
        try? realm.write {
            realm.add(entity, update: .modified)
        }
    }
    
    func delete<T: Object>(entity: T) throws {
        try? realm.write {
            realm.delete(entity)
        }
    }
}
