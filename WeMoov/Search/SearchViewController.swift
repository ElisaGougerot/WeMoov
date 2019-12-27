//
//  SearchViewController.swift
//  WeMoov
//
//  Created by Victor on 27/12/2019.
//  Copyright © 2019 Elisa Gougerot. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet var searchTabBar: UITabBar!
    @IBOutlet var searchBarItem: UITabBarItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
    }

    func configureViewComponents() {
        view.backgroundColor = UIColor.mainOrange()
        navigationController?.navigationBar.isHidden = true
        
        self.searchTabBar.delegate = self
        self.searchTabBar.selectedItem = self.searchBarItem
    }

}


extension SearchViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if(item.tag == 1) {
            // Search Button
            print("search")
        } else if(item.tag == 2) {
            // Home Button
            print("home")
            navigationController?.pushViewController(HomeViewController(), animated: false)
        } else if(item.tag == 3) {
            // Favorite Button
            print("favorite")
            navigationController?.pushViewController(FavoritesViewController(), animated: false)
        }
    }
}
