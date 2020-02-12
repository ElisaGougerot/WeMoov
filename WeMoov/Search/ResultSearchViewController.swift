//
//  ResultSearchViewController.swift
//  WeMoov
//
//  Created by Victor on 12/02/2020.
//  Copyright © 2020 Elisa Gougerot. All rights reserved.
//

import UIKit
import Firebase

class ResultSearchViewController: UIViewController {
    
    public static let MyEventsTableViewCellId = "metvc"
    
    @IBOutlet var resultSearchTableView: UITableView!
    var resultEvents: [Event] = [] {
        didSet {
            self.resultSearchTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
    }
    
    func configureViewComponents() {
        view.backgroundColor = UIColor.mainWhite()
        navigationController?.navigationBar.isHidden = false
        
        //Back Button
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "back")
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleBack))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(singleTap)
         navigationItem.leftBarButtonItem = UIBarButtonItem(customView: iv)
        
        //Disconect Button
        let iv2 = UIImageView()
        iv2.contentMode = .scaleAspectFit
        iv2.clipsToBounds = true
        iv2.image = #imageLiteral(resourceName: "logout-1")
        
        let singleTap2 = UITapGestureRecognizer(target: self, action: #selector(handleSignOut))
        iv2.isUserInteractionEnabled = true
        iv2.addGestureRecognizer(singleTap2)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: iv2)
        
        
        self.title = "Résultats"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.barTintColor = UIColor.mainWhite()
        

        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.8
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 2
      
        //Init TableView
        self.resultSearchTableView.rowHeight = 100
        self.resultSearchTableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: ResultSearchViewController.MyEventsTableViewCellId)
        self.resultSearchTableView.dataSource = self
        self.resultSearchTableView.delegate = self
        
        if GlobalVariable.eventsSearch.count != 0 {
            // Event Search
            resultEvents = GlobalVariable.eventsSearch
        }
        
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
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

}

extension ResultSearchViewController: UITableViewDelegate {
        
}

extension ResultSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultEvents.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyEventsViewController.MyEventsTableViewCellId, for: indexPath) as! EventTableViewCell
        let event = self.resultEvents[indexPath.row]
        cell.eventName.text = event.name
        cell.eventImageView.loadImage(urlString: event.image) // restore default image
        cell.favButton.tag = indexPath.row // Donnez le numéro de la ligne
        cell.favButton.tintColor = GlobalVariable.favorites.contains(self.resultEvents[indexPath.row].idEvent) ? .red : .black
        cell.favButton.addTarget(self, action: #selector(handleFav), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(self.resultEvents[indexPath.row].name)")
        GlobalVariable.eventClicked = self.resultEvents[indexPath.row]
        self.navigationController?.pushViewController(EventDetailViewController(), animated: true)
    }
    
    @objc func handleFav(_ sender: Any){
        let button = sender as! UIButton
        let row = button.tag
        let idEvent = self.resultEvents[row].idEvent
        print("idevent: \(idEvent) + name: \(self.resultEvents[row].name)")
        let fav = GlobalVariable.favorites.contains(idEvent)
        
        let ref = Database.database().reference(withPath: "favorite").child(GlobalVariable.user.id)
        
        if !fav {
            GlobalVariable.favorites.addFavEvent(id: idEvent)
            let dictEvent: [String: Any] = [
            "userID": GlobalVariable.user.id,
            "favEventsID": GlobalVariable.favorites.getFavEvents(),
            ]
            
            print("fav add: \(idEvent)")
            
            ref.setValue(dictEvent) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Data could not be saved: \(error).")
                } else {
                    print("Data saved successfully!")
                    button.tintColor = GlobalVariable.favorites.contains(idEvent) ? .red : .black
                }
            }
        } else {
            GlobalVariable.favorites.removeFavEvent(id: idEvent)
            ref.updateChildValues(["favEventsID": GlobalVariable.favorites.getFavEvents()])
            print("fav update delete")
            button.tintColor = GlobalVariable.favorites.contains(idEvent) ? .red : .black
        }
    }
    

}

