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
import GeoFire

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    public static let MyEventsTableViewCellId = "metvc"
           
    @IBOutlet var homeBarItem: UITabBarItem!
    @IBOutlet var homeTabBar: UITabBar!
    
    @IBOutlet var AllEventTableView: UITableView!
    var AllEvents: [Event] = [] {
        didSet {
            self.AllEventTableView.reloadData()
        }
    }
    
    let locationManager = CLLocationManager()
    
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
        self.AllEventTableView.rowHeight = 100
        self.AllEventTableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: HomeViewController.MyEventsTableViewCellId)
        self.AllEventTableView.dataSource = self
        self.AllEventTableView.delegate = self
        
        // Geoloc
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        getAllEvents()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
           //getAllEvents()
    }
    
    func getAllEvents() {
        
        if self.AllEvents.count > 0 {
            return
        }

        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
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
                self.getAllDistance()
            }
        }
    }
    
    private func getAllDistance() {
        if GlobalVariable.userCoord.0 == 0 && GlobalVariable.userCoord.1 == 0 {
            // Default Location: ESGI
            GlobalVariable.userCoord = (48.8490674, 2.389729)
        }
//        let geofireRef = Database.database().reference().child("geoloc")
//       let geoFire = GeoFire(firebaseRef: geofireRef)
//        let center = CLLocation(latitude: GlobalVariable.userCoord.0, longitude: GlobalVariable.userCoord.1)
        // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
//        var circleQuery = geoFire.query(at: center, withRadius: 1.0)
//        var queryHandle = circleQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
//          print("Key '\(key)' entered the search area and is at location '\(location)'")
//        })
        
    }
    
    public func removePost(withID: String) {
      
        let reference = Database.database().reference().child("favorite").child(withID)
          reference.removeValue { error, _ in
             print("error")
          }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        GlobalVariable.userCoord = (locValue.latitude, locValue.longitude)
    }
}

extension HomeViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if(item.tag == 1) {
            // Search Button test
            navigationController?.pushViewController(SearchViewController(), animated: false)
        } else if(item.tag == 2) {
            // Home Button
        } else if(item.tag == 3) {
            // Favorite Button
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
        GlobalVariable.eventClicked = self.AllEvents[indexPath.row]
        self.navigationController?.pushViewController(EventDetailViewController(), animated: true)
    }
    
    @objc func handleFav(_ sender: Any){
        let button = sender as! UIButton
        let row = button.tag
        let idEvent = self.AllEvents[row].idEvent
        let fav = GlobalVariable.favorites.contains(idEvent)
        
        let ref = Database.database().reference(withPath: "favorite").child(GlobalVariable.user.id)
        
        if !fav {
            GlobalVariable.favorites.addFavEvent(id: idEvent)
            let dictEvent: [String: Any] = [
            "userID": GlobalVariable.user.id,
            "favEventsID": GlobalVariable.favorites.getFavEvents(),
            ]
            
            
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
            button.tintColor = GlobalVariable.favorites.contains(idEvent) ? .red : .black
        }
    }
}

