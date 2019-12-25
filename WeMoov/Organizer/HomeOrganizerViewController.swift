//
//  HomeOrganizerViewController.swift
//  WeMoov
//
//  Created by Victor on 25/12/2019.
//  Copyright © 2019 Elisa Gougerot. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class HomeOrganizerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func configureViewComponents() {
           view.backgroundColor = UIColor.mainOrange()
           navigationController?.navigationBar.isHidden = false
              navigationItem.title = "Home Organizer"
              
           let iv = UIImageView()
           iv.contentMode = .scaleAspectFit
           iv.clipsToBounds = true
           iv.image = #imageLiteral(resourceName: "logout")
           let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSignOut))
           iv.isUserInteractionEnabled = true
           iv.addGestureRecognizer(singleTap)

           navigationItem.leftBarButtonItem = UIBarButtonItem(customView: iv)
           navigationController?.navigationBar.barTintColor = UIColor.mainOrange()
           
          /* self.pseudoLabel.text = "Welcome, \(GlobalVariable.username)"
           
           UIView.animate(withDuration: 0.5, animations: {
            self.pseudoLabel.alpha = 1
           })
    */
    
    }

}
