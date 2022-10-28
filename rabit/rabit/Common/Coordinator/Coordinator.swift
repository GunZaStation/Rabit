import UIKit

protocol Coordinator: AnyObject {
    
    var parentCoordiantor: Coordinator? { get set }
    var children: [Coordinator] { get set }
    var navigationController: UINavigationController { get }
    
    func start()
}

extension Coordinator {
    func childDidFinish(_ child: Coordinator) {
        for (index, coordinator) in children.enumerated() {
            if child === coordinator {
                children.remove(at: index)
                break
            }
        }
    }
}
