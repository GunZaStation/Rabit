import Foundation
import RealmSwift
import RxSwift

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

    func update<T: Persistable>(object: T) -> Single<T>  {
        let realm = realm
        let entity = object.toEntity()
        
        return Single.create { observer -> Disposable in
            
            do {
                try realm.write {
                    realm.add(entity, update: .modified)
                    observer(.success(object))
                }
            } catch {
                observer(.failure(error))
            }
            
            return Disposables.create { }
        }
    }
}
