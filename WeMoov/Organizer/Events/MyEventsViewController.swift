//
//  MyEventsViewController.swift
//  WeMoov
//
//  Created by Victor on 26/12/2019.
//  Copyright © 2019 Elisa Gougerot. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreLocation

class MyEventsViewController: UIViewController {
    
    ///Id de la cellule personnalisée.
    public static let MyEventsTableViewCellId = "metvc"
    
   ///myEvents : array contenant les events.
    @IBOutlet var myEventTableView: UITableView!
    var myEvents: [Event] = [] {
        didSet {
            self.myEventTableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
    }

    ///Revenir sur l'écran précédent
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
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
        self.title = "Evènement à venir"
        navigationController?.navigationBar.barTintColor = UIColor.mainWhite()
        
        // Init TableView
        self.myEventTableView.rowHeight = 100
        self.myEventTableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: MyEventsViewController.MyEventsTableViewCellId)
        self.myEventTableView.dataSource = self
        self.myEventTableView.delegate = self

        getAllEvents()
        
    }


    override func viewDidAppear(_ animated: Bool) {
        //getAllEvents()
    }
    
    func getAllEvents() {
        if self.myEvents.count > 0 {
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.locale = Locale(identifier: "FR-fr")
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "dd/MM/yyyy HH:mm"
        dateFormatter2.locale = Locale(identifier: "FR-fr")
        
        // .queryOrdered(byChild: "idOrganizer").queryEqual(toValue: GlobalVariable.user.id)
        Database.database().reference().child("events").queryOrdered(byChild: "idOrganizer").queryEqual(toValue: GlobalVariable.user.id).observeSingleEvent(of: .value) { (snapshot) in
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
                
                self.myEvents.append(Event(idEvent: id, idOrganizer: idOrganizer, name: name, content: content, coordinates: CLLocation(latitude: lat, longitude: lon), image: image, typeEvent: typeEvent, typePlace: typePlace, startDate: startDate, endDate: endDate, price: price, address: address, period: period))
                
            }
                self.myEvents.sort(by: { $0.startDate < $1.startDate })
    
        }
            
            
        }
    }
}

extension MyEventsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myEvents.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyEventsViewController.MyEventsTableViewCellId, for: indexPath) as! EventTableViewCell
        let event = self.myEvents[indexPath.row]
        cell.eventName.text = event.name
        cell.eventName.adjustsFontSizeToFitWidth = true
        cell.eventImageView.loadImage(urlString: event.image) // restore default image
        /*if let pictureURL = event.image {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: pictureURL) {
                    DispatchQueue.main.sync {
                        cell.eventImageView.image = UIImage(data: data)
                    }
                }
            }
        }*/
        //cell.price.text = "\(event.price)€"
        cell.favButton.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(self.myEvents[indexPath.row].name)")
        GlobalVariable.eventClicked = self.myEvents[indexPath.row]
        self.navigationController?.pushViewController(EventDetailViewController(), animated: true)
    }
}

extension MyEventsViewController: UITableViewDelegate {
        
}

extension UIImageView {

    func loadImage(urlString: String) {
        
        if let cacheImage = GlobalVariable.imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cacheImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.sync {
                    self.image = UIImage(data: data)
                }
            }
        }
    }
}
