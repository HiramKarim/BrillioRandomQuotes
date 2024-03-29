//
//  SceneDelegate.swift
//  RandomQuotesBrillio
//
//  Created by Hiram Castro on 26/12/23.
//

/*
 His take home challenge is very good as well,
 - Good modularization.
 - Good choice of Coordinators for managing screens.
 - Good understanding of layout constraints.
 - Good with HTTPClientResult wrapper for cleaner code.
 - Good handling of input constraints for the text field.
  == Overall good understanding of memory handling with correct use of [weak self] ==
 Noticed there was no removeCoordinator function, which would lead to memory leaks, be careful with that. Some parts for code could be DRYer (eg parsing JSON could be added to a more generic network/parsing layer or common VC/UI setup behavior added to extensions/base class).
 Minor: Would have liked to see a more robust error handling as a take home. Also noticed an inconsistent coding style, easily solved with a linter
 */

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let window = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: window)
        
        let navController = UINavigationController()
        appCoordinator = AppCoordinator(navigationController: navController)
        
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
        
        appCoordinator?.start()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

