//
//  CustomTabBarController.swift
//  messenger
//
//  Created by Paul Dong on 21/10/17.
//  Copyright © 2017 Paul Dong. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [
            createDummyNavControllerWithTitle(controller: FriendsController(collectionViewLayout: UICollectionViewFlowLayout()), title: "Recent", imageName: "recent"),
            createDummyNavControllerWithTitle(controller: UIViewController(),title: "Calls", imageName: "calls"),
            createDummyNavControllerWithTitle(controller: UIViewController(),title: "Groups", imageName: "groups"),
            createDummyNavControllerWithTitle(controller: UIViewController(),title: "People", imageName: "people"),
            createDummyNavControllerWithTitle(controller: UIViewController(),title: "Settings", imageName: "settings")
        ]
    }
    
    private func createDummyNavControllerWithTitle(controller: UIViewController, title: String, imageName: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: controller)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        return navController
    }
}
