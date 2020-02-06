//
//  FavoritesViewController.swift
//  WeMoov
//
//  Created by Victor on 27/12/2019.
//  Copyright © 2019 Elisa Gougerot. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import FirebaseDatabase

class FavoritesViewController: UIViewController {
    @IBOutlet var favTabBar: UITabBar!
    @IBOutlet var favBarItem: UITabBarItem!
    
    public static let MyEventsTableViewCellId = "metvc"

    @IBOutlet var AllFavoriteTableView: UITableView!
      var AllFavorite: [Event] = [] {
          didSet {
              self.AllFavoriteTableView.reloadData()
          }
      }
      
    
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
        
        self.favTabBar.delegate = self
        self.favTabBar.selectedItem = self.favBarItem
       
            
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "cancel")
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSignOut))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(singleTap)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: iv)
        navigationController?.navigationBar.barTintColor = UIColor.mainWhite()
            
        
            
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.favTabBar.delegate = self
        self.favTabBar.selectedItem = self.favBarItem
        self.favTabBar.tintColor = UIColor.mainBlack()
        
        
    }
    
    func getAllFavorite() {
        
        if self.AllFavorite.count > 0 {
            return
        }

        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.locale = Locale(identifier: "FR-fr")
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter2.locale = Locale(identifier: "FR-fr")
       
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
                    let startDate = dateFormatter.date(from: event["startDate"] as? String  ?? "")!
                    let endDate = dateFormatter2.date(from: event["endDate"] as? String  ?? "")!
                    let price = event["price"] as? String ?? "0"
                    let address = event["address"] as? String  ?? ""
                    let period = event["period"] as? String  ?? ""

                    
                    self.AllFavorite.append(Event(idEvent: id, idOrganizer: idOrganizer, name: name, content: content, coordinates: CLLocation(latitude: lat, longitude: lon), image: image, typeEvent: typeEvent, typePlace: typePlace, startDate: startDate, endDate: endDate, price: price, address: address, period: period, favorite: true))
                }
                self.AllFavorite.sort(by: { $0.startDate < $1.startDate })
            }
        }
    }

}

extension FavoritesViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if(item.tag == 1) {
            // Search Button test
            print("search")
            navigationController?.pushViewController(SearchViewController(), animated: false)
        } else if(item.tag == 2) {
            // Home Button
            print("home")
            navigationController?.pushViewController(HomeViewController(), animated: false)
        } else if(item.tag == 3) {
            // Favorite Button
            print("favorite")
        }
    }
}

extension FavoritesViewController: UITableViewDelegate {
        
}

extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.AllFavorite.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyEventsViewController.MyEventsTableViewCellId, for: indexPath) as! EventTableViewCell
        let event = self.AllFavorite[indexPath.row]
        cell.eventName.text = event.name
        cell.eventImageView.loadImage(urlString: event.image) // restore default image
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(self.AllFavorite[indexPath.row].name)")
        GlobalVariable.eventClicked = self.AllFavorite[indexPath.row]
        self.navigationController?.pushViewController(EventDetailViewController(), animated: true)
    }
}
