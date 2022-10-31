import UIKit

protocol Coordinator: AnyObject {
    
    var parentCoordiantor: Coordinator? { get set }
    var children: [Coordinator] { get set }
    var navigationController: UINavigationController { get }
    
    func start()
}

extension Coordinator {
    func addChild(_ child: Coordinator) {
        child.parentCoordiantor = self
        children.append(child)
    }

    func childDidFinish(_ child: Coordinator) {
        if let childIndex = children.enumerated()
            .first(where: {$1 === child} )?.offset {

            children.remove(at: childIndex)
        }
    }
}
