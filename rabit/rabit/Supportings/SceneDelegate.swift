import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: Coordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        self.window?.rootViewController = navigationController

        self.appCoordinator = AppCoordinator(navigationController: navigationController)
        self.appCoordinator?.start()
        
        self.window?.makeKeyAndVisible()
    }
}

