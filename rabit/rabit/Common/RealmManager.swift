import Foundation
import RealmSwift

final class RealmManager {
    
    private let realm: Realm
    static var shared = RealmManager()
    
    private init() {
        self.realm = try! Realm()
    }
    
    func read<T: Object>(entity: T.Type, filter query: String = "") -> Results<T> {
        if query.isEmpty {
            return realm.objects(entity)
        } else {
            return realm.objects(entity).filter(query)
        }
    }
 
    func write(entity: Object) throws {
        try? realm.write {
            realm.add(entity)
        }
    }
}
