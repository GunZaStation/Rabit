import Foundation
import RealmSwift

final class RealmManager {
    
    private let realmSerialQueue = DispatchQueue(label: "realm-serial-queue")
    private let configuration = Realm.Configuration.defaultConfiguration
    private let semaphore = DispatchSemaphore(value: 0)
    static var shared = RealmManager()
    
    private init() { }
        
    func read<T: Object>(entity: T.Type, filter query: String? = nil) -> [T] {
        var result: [T] = []
        
        realmSerialQueue.async { [weak self] in
            guard let self = self else {
                self?.semaphore.signal()
                return
            }
            
            let realm = try! Realm(configuration: self.configuration, queue: self.realmSerialQueue)
            
            if let query = query {
                result = realm.objects(entity).filter(query).toArray(ofType: entity)
            } else {
                result = realm.objects(entity).toArray(ofType: entity)
            }
            
            self.semaphore.signal()
        }
        
        semaphore.wait()
        
        return result
    }
 
    func write(entity: Object) throws {
        let configuration = configuration
        
        realmSerialQueue.async {
            let realm = try! Realm(configuration: configuration)

            try? realm.write {
                realm.add(entity)
            }
        }
    }

    func update<T: Object>(entity: T) throws {
        let configuration = configuration

        realmSerialQueue.async {
            let realm = try! Realm(configuration: configuration)

            try? realm.write {
                realm.add(entity, update: .modified)
            }
        }
    }
}
