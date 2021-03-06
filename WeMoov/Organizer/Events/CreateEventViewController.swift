//
//  CreateEventViewController.swift
//  WeMoov
//
//  Created by Victor on 26/12/2019.
//  Copyright © 2019 Elisa Gougerot. All rights reserved.
//

import UIKit
import iOSDropDown
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseDatabase
import CoreLocation
import GeoFire

class CreateEventViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    /**
                Définition des variables
     */
    
    @IBOutlet weak var closeButton: UIButton!
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var typeEventList: DropDown!
    
    @IBOutlet weak var addressList: UITextField!
    
    @IBOutlet weak var dateTF: UITextField!
    var startDateBDD = ""
    
    @IBOutlet weak var timeEndTF: UITextField!
    
    @IBOutlet weak var priceTF: UITextField!
    
    
    @IBOutlet weak var periodList: DropDown!
    
    
    @IBOutlet weak var typePlaceList: DropDown!
    
    
    @IBOutlet weak var descriptionTV: UITextView!
    
    let datePicker = UIDatePicker()
    
    let imagePicker = UIImagePickerController()
    
    let timeEnd = UIDatePicker()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //self.imageView.image = UIImage(named: ("upload"))
        self.typeEventList.optionArray = ["","AfterWork", "Bar", "Jeux"]
        self.typeEventList.selectedRowColor = .lightGray
        self.typeEventList.delegate = self
        
        self.periodList.optionArray = ["","Matin", "Après-Midi", "Soir"]
        self.periodList.selectedRowColor = .lightGray
        self.periodList.delegate = self
        
        self.typePlaceList.optionArray = ["","Bar", "Restaurant", "Musée", "Appartement", "Rooftop"]
        self.typePlaceList.selectedRowColor = .lightGray
        self.typePlaceList.delegate = self
        
        self.dateTF.delegate = self
        self.timeEndTF.delegate = self
        
        showDatePicker()
        showTimePicker()
        
        self.descriptionTV.layer.borderWidth = 1
        
        self.descriptionTV.placeholder = "Description"
        
        //Cacher le clavier quand on touche la view
        self.hideKeyboardWhenTappedAround()
        
        // Listener état clavier
        NotificationCenter.default.addObserver(self, selector: #selector(CreateEventViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CreateEventViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    // Passer au textfield suivant
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1

        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return true
    }
    
    // Remonte la vue si clavier ouvert
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y == 0{
            self.view.frame.origin.y -= keyboardFrame.height - 50
        }
    }
    
    // Remet la vue par défaut si clavier fermé
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    /**
                Fermer le present quand on clique sur le bouton close.
     */
    
    @IBAction func closePresent(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Choisir la photo depuis la gallerie
    @IBAction func chooseImage(_ sender: Any) {
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary //On specifie gallery (autre: camera)
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //Remplacer l'image par celle choisie
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imageV = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = imageV
        }
        //Faire disparaitre la popup de choix
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    
    func showDatePicker(){
        //Format de la Date
        datePicker.datePickerMode = .dateAndTime
        datePicker.locale = Locale(identifier: "FR-fr")
        
        //Bouton done et cancel.
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        dateTF.inputAccessoryView = toolbar
        dateTF.inputView = datePicker
    }
    
    /**
                DatePicker de la date de début.
     */
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateTF.text = formatter.string(from: datePicker.date)
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        startDateBDD = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    func showTimePicker(){
        //Format Date
        timeEnd.datePickerMode = .dateAndTime
    
        timeEnd.locale = Locale(identifier: "FR-fr")

        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action:#selector(doneTimePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTimePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        timeEndTF.inputAccessoryView = toolbar
        timeEndTF.inputView = timeEnd
    }
    
    @objc func doneTimePicker(){
        
        let formatterEnd = DateFormatter()
        formatterEnd.dateFormat = "dd/MM/yyyy HH:mm"
        formatterEnd.locale = Locale(identifier: "FR-fr")
        timeEndTF.text = formatterEnd.string(from: timeEnd.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelTimePicker(){
        self.view.endEditing(true)
    }
    
    
    /**
                Upload des données sur Firebase.
                    - Pour l'image, on save l'image sur FirebaseStorage qui génère un lien. On upload ensuite ce lien sur Firebase dans notre bdd.
                    - Si tout les champs sont vides ont envoie une erreur sous forme d'Alert.
     */
    
    @IBAction func uploadEvent(_ sender: Any) {
        
        let name = nameTF.text ?? ""
        let address = addressList.text ?? ""
        let date = dateTF.text ?? ""
        let description = descriptionTV.text ?? ""
        let eventTypeChoice = typeEventList.text ?? ""
        let timeEnd = timeEndTF.text ?? ""
        let price = priceTF.text ?? ""
        let eventPlaceChoice = typePlaceList.text ?? ""
        let period = periodList.text ?? ""
        
        if(name == "" || address == "" || date == "" || description == "" || eventTypeChoice == "" || eventPlaceChoice == ""
            || period == "" || timeEnd == "") {
            
            let alert = UIAlertController(title: "Champ(s) Incorrect", message: "Veuillez rentrez tous les champs ! ",         preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Réessayer", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            
            let geofireRef = Database.database().reference(withPath: "geoloc")
            let geoFire = GeoFire(firebaseRef: geofireRef)
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location?.coordinate
                else {
                    // handle no location found
                    let alert = UIAlertController(title: "Addresse Incorrect", message: "Veuillez modifier l'adresse ! ",         preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Réessayer", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                let uuid = UUID().uuidString
                
                // Create GeoFire Geolocation
                geoFire.setLocation(CLLocation(latitude: location.latitude, longitude: location.longitude), forKey: uuid)
                
                // Create Event
                let ref = Database.database().reference(withPath: "events").child(uuid)
                let dictEvent: [String: Any] = [
                    "content": description,
                    "idEvent":uuid,
                    "endTime": timeEnd,
                    "idOrganizer": Auth.auth().currentUser!.uid,
                    "image":"",
                    "name": name,
                    "price":price,
                    "startDate": self.startDateBDD,
                    "endDate": timeEnd,
                    "typeEvent":eventTypeChoice,
                    "typePlace":eventPlaceChoice,
                    "address": address,
                    "period": period]
                
                ref.setValue(dictEvent) {
                    (error:Error?, ref:DatabaseReference) in
                    if let error = error {
                        print("Data could not be saved: \(error).")
                    } else {
                        print("Data saved successfully!")
                    }
                }
                
                // Upload & Update Picture
                self.imageView.image!.upload(with: "image \(name)", completion: {(url: URL?) in
                    Database.database().reference(withPath: "events").child(uuid).updateChildValues(["image": url?.absoluteString])
                })
                
                self.dismiss(animated: true, completion: nil)
                
            }
        }
                
    }
}

extension UITextView :UITextViewDelegate {
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// ajoute un placeholder à la description (de type UITextViewl)
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.count > 0
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
}

/**
        Extension permettant d'upload l'image sur FirebaseStorage et de télécharger l'url de l'image.
 */
extension UIImage {
    func upload(with name: String, completion: @escaping (URL?) -> Void) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        //let fileName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        guard let data = self.jpegData(compressionQuality: 0.4) else { return }
        let storage = Storage.storage().reference().child("\(Auth.auth().currentUser!.uid)").child("images")
        storage.child(name).putData(data, metadata: metadata) { meta, error in
            if let error = error {
                print(error)
                completion(nil)
                return
            }
            
            storage.child(name).downloadURL { url, error in
                if let error = error {
                    // Handle any errors
                    print(error)
                    completion(nil)
                }
                else {
                    completion(url)
                }
            }
        }
    }
}
