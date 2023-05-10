import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let viewModel: ListViewModelProtocol = ListViewModel()
        let navigationController = UINavigationController(rootViewController: ListViewController(viewModel: viewModel))
        
        navigationController.navigationBar.prefersLargeTitles = true
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }
}
