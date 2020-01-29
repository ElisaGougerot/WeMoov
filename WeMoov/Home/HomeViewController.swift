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
        iv.image = #imageLiteral(resourceName: "cancel")
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSignOut))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(singleTap)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: iv)
        self.title = "Events"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.barTintColor = UIColor.mainWhite()
        
        /*self.pseudoLabel.text = "Welcome, \(GlobalVariable.user.username)"
        
        UIView.animate(withDuration: 0.5, animations: {
         self.pseudoLabel.alpha = 1
        })*/
        
        self.homeTabBar.delegate = self
        self.homeTabBar.selectedItem = self.homeBarItem
        self.homeTabBar.tintColor = UIColor.mainBlack()
        
        //Init TableView
        self.AllEventTableView.rowHeight = 120
        self.AllEventTableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: HomeViewController.MyEventsTableViewCellId)
        self.AllEventTableView.dataSource = self
        self.AllEventTableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
           getAllEvents()
    }
    
    func getAllEvents() {
        
        if self.AllEvents.count > 0 {
            return
        }

        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "FR-fr")
        
        let dateFormatterStartDate = DateFormatter()
        dateFormatterStartDate.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatterStartDate.locale = Locale(identifier: "FR-fr")
       
        Database.database().reference().child("events").observeSingleEvent(of: .value) { (snapshot) in

             if (snapshot.value is NSNull) {
                 print("not found")
             } else {
                for child in snapshot.children {
                    let data = child as! DataSnapshot
                    let event = data.value as! [String: AnyObject]
                    let id = event["id"] as? String ?? ""
                    let idOrganizer = event["idOrganizer"] as? String ?? ""
                    let name = event["name"] as? String  ?? ""
                    let content = event["content"] as? String  ?? ""
                    let image = event["image"] as? String ?? "" //URL(string: event["image"] as? String ?? "")
                    let typeEvent = event["typeEvent"] as? String  ?? ""
                    let typePlace = event["typePlace"] as? String  ?? ""
                    let coordinates = event["coordinates"] as? [String: CLLocationDegrees]
                    let lat = coordinates?["lat"] ?? 0.0
                    let lon = coordinates?["lon"] ?? 0.0
                    let startDate = dateFormatterStartDate.date(from: event["startDate"] as? String  ?? "")!
                    let endDate = dateFormatter.date(from: event["endDate"] as? String  ?? "")!
                    let price = event["price"] as? String ?? "0"
                    let address = event["address"] as? String  ?? ""
                    let period = event["period"] as? String  ?? ""

                    
                    self.AllEvents.append(Event(id: id, idOrganizer: idOrganizer, name: name, content: content, coordinates: CLLocation(latitude: lat, longitude: lon), image: image, typeEvent: typeEvent, typePlace: typePlace, startDate: startDate, endDate: endDate, price: price, address: address, period: period))
                }
                self.AllEvents.sort(by: { $0.startDate < $1.startDate })
            }
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(self.AllEvents[indexPath.row].name)")
        GlobalVariable.eventClicked = self.AllEvents[indexPath.row]
        self.navigationController?.pushViewController(EventDetailViewController(), animated: true)
    }
}


