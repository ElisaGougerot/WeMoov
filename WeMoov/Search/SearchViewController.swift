//
//  SearchViewController.swift
//  WeMoov
//
//  Created by Victor on 27/12/2019.
//  Copyright © 2019 Elisa Gougerot. All rights reserved.
//

import UIKit
import iOSDropDown
import Firebase
import FirebaseDatabase
import CoreLocation


class SearchViewController: UIViewController {

    @IBOutlet var searchTabBar: UITabBar!
    @IBOutlet var searchBarItem: UITabBarItem!
    @IBOutlet var searchByDate: UITextField!
    
    //@IBOutlet var searchTextFieldDate: UITextField!
    @IBOutlet var searchEventButton: UIButton!
    
    @IBOutlet var searchDistanceSlider: UISlider!
    @IBOutlet var distanceLabel: UILabel!
    
    @IBOutlet var typeEventList: DropDown!
    @IBOutlet var typePlaceList: DropDown!
    
    @IBOutlet var buttonSearch: UIButton!
    
    let searchDatePicker =  UIDatePicker()
    var dataSearch = [String: String]()
    var eventsSearch: [Event] = []
    let reference = Database.database().reference().child("events")
    
    override func viewDidLoad() {
          super.viewDidLoad()
          configureViewComponents()
          showDatePicker()
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
        
        self.searchTabBar.delegate = self
        self.searchTabBar.selectedItem = self.searchBarItem
        
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "logout-1")
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSignOut))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(singleTap)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: iv)
        self.title = "Trouver un événement"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.barTintColor = UIColor.mainWhite()

        self.navigationItem.setHidesBackButton(true, animated:true);
        self.searchTabBar.delegate = self
        self.searchTabBar.selectedItem = self.searchBarItem
        self.searchTabBar.tintColor = UIColor.mainBlack()
        
        // Button
        self.searchEventButton.layer.cornerRadius = 15.0
        self.searchEventButton.layer.cornerRadius = 15.0
        
        self.distanceLabel.text = ""
        
        self.typeEventList.optionArray = ["AfterWork", "Bar", "Jeux"]
        self.typeEventList.selectedRowColor = .lightGray
        
        self.typePlaceList.optionArray = ["Bar", "Restaurant", "Musée", "Appartement", "Rooftop"]
        self.typePlaceList.selectedRowColor = .lightGray
 
    }
    
    func showDatePicker(){
        //Formate Date
        searchDatePicker.datePickerMode = .dateAndTime
        
        searchDatePicker.locale = Locale(identifier: "FR-fr")
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        searchByDate.inputAccessoryView = toolbar
        searchByDate.inputView = searchDatePicker
    }

    @objc func donedatePicker(){

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "FR-fr")
        searchByDate.text = dateFormatter.string(from: searchDatePicker.date)
        self.view.endEditing(true)
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "FR-fr")
        dataSearch["startDate"] = dateFormatter.string(from: searchDatePicker.date)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    @IBAction func distanceSliderValueChanged(_ sender: UISlider) {
        let step: Float = 50
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        distanceLabel.text = "\(Int(roundedValue))  m"
        dataSearch["distance"] = "\(Int(roundedValue))"
    }
    
    
    @IBAction func clickSearchButton(_ sender: UIButton) {
        // Get Data
        let eventType = typeEventList.text ?? ""
        if eventType != "" {
            dataSearch["typeEvent"] = eventType
        }
        let eventPlace = typePlaceList.text ?? ""
        if eventPlace != "" {
            dataSearch["typePlace"] = eventPlace
        }
        searchEvent()
    }
    
    func searchEvent() {
        if dataSearch.isEmpty {
            print("no data")
            return
        }
        print(dataSearch)
        
        if dataSearch["startDate"] != nil {
            print(dataSearch["startDate"])
            let  date : String = dataSearch["startDate"]!
            reference.queryOrdered(byChild: "startDate").queryStarting(atValue: date).observeSingleEvent(of: .value) {
                (snapshot) in

                if snapshot.value is NSNull {
                    print("not found start date")
                    self.typeEventQuery()
                }
                else {
                    for child in snapshot.children {
                        let event = self.extractEvent(child: child)
                        print(event.startDate)
                        self.eventsSearch.append(event)
                    }
                    print("Nb Start Date: \(self.eventsSearch.count)")
                    self.typeEventQuery()
                }
            }
        }
        else {
            self.typeEventQuery()
        }
    }
    
    private func typeEventQuery() {
        if dataSearch["typeEvent"] != nil {
            // test type event
            if eventsSearch.count != 0 {
                // Existe type event => Filtrer
                print("FILTRE")
                self.eventsSearch = self.eventsSearch.filter({ $0.typeEvent == dataSearch["typeEvent"] })
                print("Nb Type Event: \(self.eventsSearch.count)")
                self.typePlaceQuery()
            }
            else {
                // Query
                print("QUERY type event")
                let typeEvent: String = dataSearch["typeEvent"]!
                reference.queryOrdered(byChild: "typeEvent").queryEqual(toValue: typeEvent).observeSingleEvent(of: .value) {
                    (snapshot) in

                    if snapshot.value is NSNull {
                        print("not found type event")
                    }
                    else {
                        for child in snapshot.children {
                            let event = self.extractEvent(child: child)
                            print(event.typeEvent)
                            self.eventsSearch.append(event)
                        }
                        print("Nb Type Event: \(self.eventsSearch.count)")
                        self.typePlaceQuery()
                    }
                }
            }
        }
        else {
            self.typePlaceQuery()
        }
    }
    
    private func typePlaceQuery() {
        if dataSearch["typePlace"] != nil {
            // test type place
            if eventsSearch.count != 0 {
                // Existe type place => Filtrer
                print("FILTRE")
                self.eventsSearch = self.eventsSearch.filter({ $0.typePlace == dataSearch["typePlace"] })
                print("Nb Type Place: \(self.eventsSearch.count)")
              //  typePlaceQuery()
            }
            else {
                // Query
                print("QUERY type place")
                let typePlace: String = dataSearch["typePlace"]!
                reference.queryOrdered(byChild: "typePlace").queryEqual(toValue: typePlace).observeSingleEvent(of: .value) {
                    (snapshot) in

                    if snapshot.value is NSNull {
                        print("not found type place")
                        //self.typePlaceQuery() : distance
                        print("TOTAL == \(self.eventsSearch.count)")
                        self.sendDataToHome()
                    }
                    else {
                        for child in snapshot.children {
                            let event = self.extractEvent(child: child)
                            print(event.typePlace)
                            self.eventsSearch.append(event)
                        }
                        print("Nb Type Place: \(self.eventsSearch.count)")
                        //self.typePlaceQuery()
                        print("TOTAL == \(self.eventsSearch.count)")
                        self.sendDataToHome()
                    }
                }
            }
        }
        else {
            print("TOTAL == \(self.eventsSearch.count)")
            self.sendDataToHome()
        }
    }
    
    
    private func extractEvent(child: NSEnumerator.Element) -> Event {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "FR-fr")
        
        let dateFormatterStartDate = DateFormatter()
        dateFormatterStartDate.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatterStartDate.locale = Locale(identifier: "FR-fr")
        
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
        
        return Event(idEvent: id, idOrganizer: idOrganizer, name: name, content: content, coordinates: CLLocation(latitude: lat, longitude: lon), image: image, typeEvent: typeEvent, typePlace: typePlace, startDate: startDate, endDate: endDate, price: price, address: address, period: period)
    }
    
    private func sendDataToHome() {
        GlobalVariable.eventsSearch = self.eventsSearch
        self.eventsSearch = []
        navigationController?.pushViewController(HomeViewController(), animated: false)
    }
    
    
}
    


extension SearchViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if(item.tag == 1) {
            // Search Button
            print("search")
        } else if(item.tag == 2) {
            // Home Button test
            print("home")
            navigationController?.pushViewController(HomeViewController(), animated: false)
        } else if(item.tag == 3) {
            // Favorite Button
            print("favorite")
            navigationController?.pushViewController(FavoritesViewController(), animated: false)
        }
    }
}
