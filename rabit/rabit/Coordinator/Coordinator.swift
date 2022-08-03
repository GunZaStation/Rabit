import UIKit

/*
    자식 화면에서 작업한 데이터를 부모 화면으로 전달해야 되기 때문에,
    자식 코디네이터에서 부모 코디네이터의 참조를 알고 있어야 함
 
    예를 들어, 화면 버튼이 눌렸다는 입력을 VC가 받고 이를
    최상위코디에티터가 가진 다른 코디네이터로 알려야하는 상황이 있는 것
 */

protocol Coordinator: AnyObject {
    
    var parentCoordiantor: Coordinator? { get set }
    var children: [Coordinator] { get }
    var navigationController: UINavigationController { get }
    
    func start()
}
