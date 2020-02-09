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
import CoreLocation

class HomeViewController: UIViewController {
    
    public static let MyEventsTableViewCellId = "metvc"
           
    @IBOutlet var homeBarItem: UITabBarItem!
    @IBOutlet var homeTabBar: UITabBar!
    
    @IBOutlet var AllEventTableView: UITableView!
    var AllEvents: [Event] = [] {
        didSet {
            self.AllEventTableView.reloadData()
        }
    }
    
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
               /*guard let username = snapshot.value as? String else { return }
               
                self.pseudoLabel.text = "Welcome, \(username)"
               
               UIView.animate(withDuration: 0.5, animations: {
                self.pseudoLabel.alpha = 1
               })*/
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
        view.backgroundColor = UIColor.mainWhite()
        navigationController?.navigationBar.isHidden = false
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        //Disconect Button
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "logout-1")
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSignOut))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(singleTap)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: iv)
        
        
        self.title = "Evénement à venir"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.barTintColor = UIColor.mainWhite()
        

        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.8
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 2
        
        self.homeTabBar.delegate = self
        self.homeTabBar.selectedItem = self.homeBarItem
        self.homeTabBar.tintColor = UIColor.mainBlack()
        
        //Init TableView
        self.AllEventTableView.rowHeight = 120
        self.AllEventTableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: HomeViewController.MyEventsTableViewCellId)
        self.AllEventTableView.dataSource = self
        self.AllEventTableView.delegate = self
        
        if GlobalVariable.eventsSearch.count != 0 {
            // Event Search
            AllEvents = GlobalVariable.eventsSearch
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
           getAllEvents()
    }
    
    func getAllEvents() {
        
        if self.AllEvents.count > 0 {
            return
        }

        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "FR-fr")
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "dd/MM/yyyy HH:mm"
        dateFormatter2.locale = Locale(identifier: "FR-fr")

        Database.database().reference().child("events").observeSingleEvent(of: .value) { (snapshot) in

             if (snapshot.value is NSNull) {
                 print("not found")
             } else {
                for child in snapshot.children {
                    let data = child as! DataSnapshot
                    let event = data.value as! [String: AnyObject]
                    let id = event["idEvent"] as? String ?? ""
                    let idOrganizer = event["idOrganizer"] as? String ?? ""
                    let name = event["name"] as? String  ?? ""
                    let content = event["content"] as? String  ?? ""
                    let image = event["image"] as? String ?? "" //URL(string: event["image"] as? String ?? "")
                    let typeEvent = event["typeEvent"] as? String  ?? ""
                    let typePlace = event["typePlace"] as? String  ?? ""
                    let coordinates = event["coordinates"] as? [String: CLLocationDegrees]
                    let lat = coordinates?["lat"] ?? 0.0
                    let lon = coordinates?["lon"] ?? 0.0
                    let startDate = dateFormatter.date(from: event["startDate"] as? String  ?? "")!
                    let endDate = dateFormatter2.date(from: event["endDate"] as? String  ?? "")!
                    let price = event["price"] as? String ?? "0"
                    let address = event["address"] as? String  ?? ""
                    let period = event["period"] as? String  ?? ""

                    
                    self.AllEvents.append(Event(idEvent: id, idOrganizer: idOrganizer, name: name, content: content, coordinates: CLLocation(latitude: lat, longitude: lon), image: image, typeEvent: typeEvent, typePlace: typePlace, startDate: startDate, endDate: endDate, price: price, address: address, period: period))
                }
                self.AllEvents.sort(by: { $0.startDate < $1.startDate })
                self.getAllFavorites()
            }
        }
    }
    
    private func getAllFavorites() {
        Database.database().reference().child("favorite").child(GlobalVariable.user.id).child("favEventsID").observeSingleEvent(of: .value)  {
            (snapshot) in
            if (snapshot.value is NSNull) {
                print("Favorite not found")
            } else {
                GlobalVariable.favorites.removeAllFav()
                for child in snapshot.children {
                    let data = child as! DataSnapshot
                    let eventID = data.value as! String
                    GlobalVariable.favorites.addFavEvent(id: eventID)
                }
                self.AllEventTableView.reloadData()
            }
        }
    }
    
    public func removePost(withID: String) {
      
        let reference = Database.database().reference().child("favorite").child(withID)
          reference.removeValue { error, _ in
             print("error")
          }
    }
}

extension HomeViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if(item.tag == 1) {
            // Search Button test
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

extension HomeViewController: UITableViewDelegate {
        
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.AllEvents.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyEventsViewController.MyEventsTableViewCellId, for: indexPath) as! EventTableViewCell
        let event = self.AllEvents[indexPath.row]
        cell.eventName.text = event.name
        cell.eventImageView.loadImage(urlString: event.image) // restore default image
        cell.favButton.tag = indexPath.row // Donnez le numéro de la ligne
        cell.favButton.tintColor = GlobalVariable.favorites.contains(self.AllEvents[indexPath.row].idEvent) ? .red : .black
        cell.favButton.addTarget(self, action: #selector(handleFav), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(self.AllEvents[indexPath.row].name)")
        GlobalVariable.eventClicked = self.AllEvents[indexPath.row]
        self.navigationController?.pushViewController(EventDetailViewController(), animated: true)
    }
    
    @objc func handleFav(_ sender: Any){
        let button = sender as! UIButton
        let row = button.tag
        let idEvent = self.AllEvents[row].idEvent
        print("idevent: \(idEvent) + name: \(self.AllEvents[row].name)")
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


