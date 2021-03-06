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
import GeoFire


class SearchViewController: UIViewController {

    @IBOutlet var searchTabBar: UITabBar!
    @IBOutlet var searchBarItem: UITabBarItem!
    @IBOutlet var searchByDate: UITextField!
    var startDate = ""
    
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
    var eventSearchDistance: [Event] = []
    let reference = Database.database().reference(withPath: "events")
    let geofireRef = Database.database().reference().child("geoloc")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
        showDatePicker()
        self.hideKeyboardWhenTappedAround()

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
        
        self.typeEventList.optionArray = ["","AfterWork", "Bar", "Jeux"]
        self.typeEventList.selectedRowColor = .lightGray
        self.typeEventList.delegate = self
        
        self.typePlaceList.optionArray = ["","Bar", "Restaurant", "Musée", "Appartement", "Rooftop"]
        self.typePlaceList.selectedRowColor = .lightGray
        self.typePlaceList.delegate = self
 
        self.searchByDate.delegate = self
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
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        startDate = dateFormatter.string(from: searchDatePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    @IBAction func distanceSliderValueChanged(_ sender: UISlider) {
        let step: Float = 50
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        distanceLabel.text = "\(Int(roundedValue))  m"
        dataSearch["distance"] = "\(Float(roundedValue / 1000))"
    }
    
    
    @IBAction func clickSearchButton(_ sender: UIButton) {
        // Get Data
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.locale = Locale(identifier: "FR-fr")
        if searchByDate.text != "" {
            dataSearch["startDate"] = startDate
        }
        
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
            displayError(message: "Remplis des champs pour faire une recherche", title: "Erreur")
            return
        }
        
        if dataSearch["distance"] != nil {
            self.distanceQuery()
        }
        else {
            self.startDateQuery()
        }
    }
    
    private func startDateQuery() {
        if dataSearch["startDate"] != nil {
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
                        self.eventsSearch.append(event)
                    }
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
                self.eventsSearch = self.eventsSearch.filter({ $0.typeEvent == dataSearch["typeEvent"] })
                self.typePlaceQuery()
            }
            else {
                // Query
                let typeEvent: String = dataSearch["typeEvent"]!
                reference.queryOrdered(byChild: "typeEvent").queryEqual(toValue: typeEvent).observeSingleEvent(of: .value) {
                    (snapshot) in

                    if snapshot.value is NSNull {
                        print("not found type event")
                        self.typePlaceQuery()
                    }
                    else {
                        for child in snapshot.children {
                            let event = self.extractEvent(child: child)
                            self.eventsSearch.append(event)
                        }
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
                self.eventsSearch = self.eventsSearch.filter({ $0.typePlace == dataSearch["typePlace"] })
                self.sendDataToHome()
            }
            else {
                // Query
                let typePlace: String = dataSearch["typePlace"]!
                reference.queryOrdered(byChild: "typePlace").queryEqual(toValue: typePlace).observeSingleEvent(of: .value) {
                    (snapshot) in

                    if snapshot.value is NSNull {
                        print("not found type place")
                        self.sendDataToHome()
                    }
                    else {
                        for child in snapshot.children {
                            let event = self.extractEvent(child: child)
                            self.eventsSearch.append(event)
                        }
                        self.sendDataToHome()
                    }
                }
            }
        }
        else {
            self.sendDataToHome()
        }
    }
    
    private func distanceQuery() {
        if dataSearch["distance"] != nil {
            let distanceSearch = Double(self.dataSearch["distance"]!)!
            // test distance event
            if eventsSearch.count != 0 {
                // Existe type event => Filtrer
                extractAddressToCoordAndFiltrer(distanceSearch: distanceSearch) {
                    self.eventsSearch = eventSearchDistance
                    self.startDateQuery()
                }
            }
            else {
                // Query
                if GlobalVariable.userCoord.0 == 0 && GlobalVariable.userCoord.1 == 0 {
                      // Default Location: ESGI
                      GlobalVariable.userCoord = (48.8490674, 2.389729)
                  }
                  let geoFire = GeoFire(firebaseRef: geofireRef)
                  let center = CLLocation(latitude: GlobalVariable.userCoord.0, longitude: GlobalVariable.userCoord.1)
                  let circleQuery = geoFire.query(at: center, withRadius: distanceSearch)
                
        
                var eventDistance: [String] = []

                    circleQuery.observeReady {
                        self.getAllEventDistanceByKey(array: eventDistance)
                    }
                    circleQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
                        eventDistance.append(key!)
                    })
                
                
            }
        }
        else {
            self.startDateQuery()
        }
    }
    
    private func getAllEventDistanceByKey(array: [String]) {
        if array.count == 0 {
            self.startDateQuery()
        }
        else {
            var cmpt = 0
            array.forEach { key in
                cmpt += 1
                self.reference.child(key).observeSingleEvent(of: .value) {
                    (snapshot) in
                 
                    if snapshot.value is NSNull {
                        print("not found distance event")
                        if cmpt == array.count {
                            self.startDateQuery()
                        }
                    }
                    else {
                        let event = self.extractEvent(child: snapshot)
                        self.eventsSearch.append(event)
                        if self.eventsSearch.count == array.count {
                            self.startDateQuery()
                        }
                    }
                }
            }
        }
        
    }
    
    private func extractAddressToCoordAndFiltrer(distanceSearch: Double, completionHandler:()->()) {
        let coordinateUser = CLLocation(latitude: GlobalVariable.userCoord.0, longitude: GlobalVariable.userCoord.1)
        
        let geoCoder = CLGeocoder()
        let geoFire = GeoFire(firebaseRef: geofireRef)
        
        self.eventsSearch.forEach { (event) in
            
            geoFire.getLocationForKey(event.idEvent) { (location, error) in
              if (error != nil) {
                print("An error occurred getting the location for \"firebase-hq\": \(error!.localizedDescription)")
              } else if (location != nil) {
                let coordinateEvent = CLLocation(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
                let distanceInMeters = coordinateEvent.distance(from: coordinateUser)
                if distanceInMeters <= distanceSearch {
                    self.eventSearchDistance.append(event)
                }
              } else {
                print("GeoFire does not contain a location for \"firebase-hq\"")
              }
            }
            sleep(1)
        }
        completionHandler()
    }
    
    
    private func extractEvent(child: NSEnumerator.Element) -> Event {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "FR-fr")
        
        let dateFormatterStartDate = DateFormatter()
        dateFormatterStartDate.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatterStartDate.locale = Locale(identifier: "FR-fr")
        
        let data = child as! DataSnapshot
        let event = data.value as! [String: AnyObject]
        let idEvent = event["idEvent"] as? String ?? ""
        let idOrganizer = event["idOrganizer"] as? String ?? ""
        let name = event["name"] as? String  ?? ""
        let content = event["content"] as? String  ?? ""
        let image = event["image"] as? String ?? ""
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
        
        return Event(idEvent: idEvent, idOrganizer: idOrganizer, name: name, content: content, coordinates: CLLocation(latitude: lat, longitude: lon), image: image, typeEvent: typeEvent, typePlace: typePlace, startDate: startDate, endDate: endDate, price: price, address: address, period: period)
    }
    
    private func checkResultSearch() -> Bool {
        if self.eventsSearch.count == 0 {
            displayError(message: "Aucun résultat pour cette recherche ! Réessayer", title:"Aucun résultat" )
            return false
        }
        return true
    }
    
    private func sendDataToHome() {
        if checkResultSearch() {
            GlobalVariable.eventsSearch = self.eventsSearch
            self.eventsSearch = []
            self.eventSearchDistance = []
           
            navigationController?.pushViewController(ResultSearchViewController(), animated: false)
        }
    }
    
    func displayError(message: String, title:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        if presentedViewController == nil {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
    


extension SearchViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if(item.tag == 1) {
            // Search Button
        } else if(item.tag == 2) {
            // Home Button test
            navigationController?.pushViewController(HomeViewController(), animated: false)
        } else if(item.tag == 3) {
            // Favorite Button
            navigationController?.pushViewController(FavoritesViewController(), animated: false)
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}
