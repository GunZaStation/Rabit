import UIKit

protocol Coordinator: AnyObject {
    
    var parentCoordiantor: Coordinator? { get set }
    var children: [Coordinator] { get }
    var navigationController: UINavigationController { get }
    
    func start()
}
