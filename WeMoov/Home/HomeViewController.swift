//
//  HomeViewController.swift
//  WeMoov
//
//  Created by Taj Singh on 20/12/2019.
//  Copyright © 2019 Elisa Gougerot. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class HomeViewController: UIViewController {
           
    @IBOutlet var pseudoLabel: UILabel!
    @IBOutlet var homeBarItem: UITabBarItem!
    @IBOutlet var homeTabBar: UITabBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //AuthCheck()
        configureViewComponents()
    }
    
    
    @objc func handleSignOut(){
        let alert = UIAlertController(title: nil, message: "Voulez-vous vraiment vous déconnecter ?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Oui", style: .destructive, handler: { (_) in
            self.signOut()
        }))
        alert.addAction(UIAlertAction(title: "Non", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        print("deco")
    }
    
    
    
    func signOut(){
        do {
        try Auth.auth().signOut()
            self.navigationController?.pushViewController(LoginViewController(), animated: true)
        } catch let err {
            print("Erreur, impossible de se déconnecter", err)
        }
    }
    
    
    
    func loadUserData() {
           guard let uid = Auth.auth().currentUser?.uid else { return }
           Database.database().reference().child("user").child(uid).child("firstname").observeSingleEvent(of: .value) { (snapshot) in
               guard let username = snapshot.value as? String else { return }
               self.pseudoLabel.text = "Welcome, \(username)"
               
               UIView.animate(withDuration: 0.5, animations: {
                self.pseudoLabel.alpha = 1
               })
           }
       }
    
    func AuthCheck(){
        
        if Auth.auth().currentUser == nil {
            //Check si un user est connecté
            DispatchQueue.main.async { //Si nil, alors on affiche la page login
               self.navigationController?.pushViewController(LoginViewController(), animated: true)
            }
        } else {
            loadUserData()
        }
        
    }
    
    
    func configureViewComponents() {
        view.backgroundColor = UIColor.mainOrange()
        navigationController?.navigationBar.isHidden = false
           navigationItem.title = "Home User"
        
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "logout")
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSignOut))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(singleTap)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: iv)
        navigationController?.navigationBar.barTintColor = UIColor.mainOrange()
        
        self.pseudoLabel.text = "Welcome, \(GlobalVariable.user.email)"
        
        UIView.animate(withDuration: 0.5, animations: {
         self.pseudoLabel.alpha = 1
        })
        
        self.homeTabBar.delegate = self
        self.homeTabBar.selectedItem = self.homeBarItem
    }
}

extension HomeViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if(item.tag == 1) {
            // Search Button
            print("search")
            navigationController?.pushViewController(SearchViewController(), animated: false)
        } else if(item.tag == 2) {
            // Home Button
            print("home")
        } else if(item.tag == 3) {
            // Favorite Button
            print("favorite")
            navigationController?.pushViewController(FavoritesViewController(), animated: false)
        }
    }
}

