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
    
    public static let MyEventsTableViewCellId = "metvc"
    
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

    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }

    func configureViewComponents() {
        view.backgroundColor = UIColor.mainOrange()
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Mes évenements"
        
        //Back Button
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "back")
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleBack))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(singleTap)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: iv)
        navigationController?.navigationBar.barTintColor = UIColor.mainOrange()
        
        // Init TableView
        self.myEventTableView.rowHeight = 120
        self.myEventTableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: MyEventsViewController.MyEventsTableViewCellId)
        self.myEventTableView.dataSource = self
        self.myEventTableView.delegate = self

    }


    override func viewDidAppear(_ animated: Bool) {
        getAllEvents()
    }
    
    func getAllEvents() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.locale = Locale(identifier: "FR-fr")
        
        // .queryOrdered(byChild: "idOrganizer").queryEqual(toValue: GlobalVariable.user.id)
        Database.database().reference().child("events").queryOrdered(byChild: "idOrganizer").queryEqual(toValue: GlobalVariable.user.id).observeSingleEvent(of: .value) { (snapshot) in
            if (snapshot.value is NSNull) {
                print("not found")
           } else {
            for child in snapshot.children {
                let data = child as! DataSnapshot
                let event = data.value as! [String: AnyObject]
                let id = event["id"] as? String ?? ""
                let idOrganizer = event["idOrganizer"] as? String ?? ""
                print("data id organizer: \(idOrganizer) / user id: \(GlobalVariable.user.id)")
                let name = event["name"] as? String  ?? ""
                let content = event["content"] as? String  ?? ""
                let image = URL(string: event["image"] as? String ?? "")
                let typeEvent = event["typeEvent"] as? String  ?? ""
                let typePlace = event["typePlace"] as? String  ?? ""
                let coordinates = event["coordinates"] as? [String: CLLocationDegrees]
                let lat = coordinates?["lat"] ?? 0.0
                let lon = coordinates?["lon"] ?? 0.0
                let startDate = dateFormatter.date(from: event["startDate"] as? String  ?? "")!
                let endDate = dateFormatter.date(from: event["endDate"] as? String  ?? "")!
                let price = event["price"] as? Int ?? 0
                
                self.myEvents.append(Event(id: id, idOrganizer: idOrganizer, name: name, content: content, coordinates: CLLocation(latitude: lat, longitude: lon), image: image, typeEvent: typeEvent, typePlace: typePlace, startDate: startDate, endDate: endDate, price: price))
                
            }
    
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
        cell.eventImageView.image = nil // restore default image
        if let pictureURL = event.image {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: pictureURL) {
                    DispatchQueue.main.sync {
                        cell.eventImageView.image = UIImage(data: data)
                    }
                }
            }
        }
        return cell
    }
}

extension MyEventsViewController: UITableViewDelegate {
        
}
