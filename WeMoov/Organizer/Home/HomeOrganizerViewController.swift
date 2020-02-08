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
    
    @IBOutlet var createEventButton: UIButton!
    @IBOutlet var myEventButton: UIButton!
    @IBOutlet var welcomeLabel: UILabel!
    
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
        view.backgroundColor = UIColor.mainWhite()
        navigationController?.navigationBar.isHidden = false
        self.navigationItem.setHidesBackButton(true, animated:true);
              
        //Logout Button
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "logout-1")
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSignOut))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(singleTap)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: iv)
        
        self.title = "Organisateur"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.barTintColor = UIColor.mainWhite()
        
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.8
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 2
               
           
        // Welcome Label
        self.welcomeLabel.text = "Bonjour \(GlobalVariable.user.username) !"
        UIView.animate(withDuration: 0.5, animations: {
            self.welcomeLabel.alpha = 1
        })
    
        // Button
        self.createEventButton.layer.cornerRadius = 25.0
        self.myEventButton.layer.cornerRadius = 25.0
    
    }
    
    
    @IBAction func touchCreateEvent(_ sender: UIButton) {
//        self.navigationController?.pushViewController(CreateEventViewController(), animated: true)
        self.present(CreateEventViewController(), animated: true, completion: nil)
    }
    

    @IBAction func touchMyEvent(_ sender: UIButton) {
        self.navigationController?.pushViewController(MyEventsViewController(), animated: true)
    }
    
}
