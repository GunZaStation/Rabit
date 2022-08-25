import Foundation
import RealmSwift

final class RealmRepository {
    
    private let realm: Realm
    static var shared = RealmRepository()
    
    private init() {
        self.realm = try! Realm()
    }
    
    func read<T: Object>(entity: T.Type) -> Results<T> {
        return realm.objects(entity)
    }
 
    func write(entity: Object) {
        
        try! realm.write {
            realm.add(entity)
        }
    }
}
