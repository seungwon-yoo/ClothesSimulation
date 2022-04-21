//
//  TabBarController.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/04/21.
//

import UIKit
import SideMenu

class TabBarController: UITabBarController {
    
    var menu: SideMenuNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        menu = SideMenuNavigationController(rootViewController: SideMenuViewController())
//        menu?.leftSide = true
//        // SideMenuManager.default.addPanGestureToPresent(toView: view)
//        SideMenuManager.default.leftMenuNavigationController = menu

        // side menu button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem( image: UIImage(systemName: "line.3.horizontal"),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(sideMenuPressed))

        self.navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    @objc
    func sideMenuPressed() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "Nav") as! CustomSideMenuNavigation
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.hidesBackButton = true
    }
}
