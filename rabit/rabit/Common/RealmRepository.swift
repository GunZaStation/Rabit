import Foundation
import RealmSwift

final class RealmRepository {
    
    let realm: Realm
    static var shared = RealmRepository()
    
    private init() {
        self.realm = try! Realm()
    }
 
    func write(entity: Object) {
        
        try! realm.write {
            realm.add(entity)
        }
    }
}
