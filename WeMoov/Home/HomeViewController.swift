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
           navigationItem.title = "Firebase Login"
           
           navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "envelope"), style: .plain, target: self, action: #selector(handleSignOut))
           navigationItem.leftBarButtonItem?.tintColor = .white
           navigationController?.navigationBar.barTintColor = UIColor.mainOrange()
        
        self.pseudoLabel.text = "Welcome, \(GlobalVariable.username)"
        
        UIView.animate(withDuration: 0.5, animations: {
         self.pseudoLabel.alpha = 1
        })
 
 }
    
}

