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

class CreateEventViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var typeEventList: DropDown!
    
    @IBOutlet weak var addressList: UITextField!
    
    @IBOutlet weak var dateTF: UITextField!
    
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
        self.imageView.image = UIImage(named: ("upload"))
        
        self.typeEventList.optionArray = ["AfterWork", "Bar", "Jeux"]
        self.typeEventList.selectedRowColor = .lightGray
        
        self.periodList.optionArray = ["Matin", "Après-Midi", "Soir"]
        self.periodList.selectedRowColor = .lightGray
        
        self.typePlaceList.optionArray = ["Bar", "Restaurant", "Musée", "Appartement", "Rooftop"]
        self.typePlaceList.selectedRowColor = .lightGray
        
        showDatePicker()
        showTimePicker()
        
        self.descriptionTV.layer.borderWidth = 1
        
        self.descriptionTV.placeholder = "Description"
        
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    //Choisir la photo depuis la gallerie
    @IBAction func chooseImage(_ sender: Any) {
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
        print("choose")
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
        //Formate Date
        datePicker.datePickerMode = .dateAndTime
        
        datePicker.locale = Locale(identifier: "FR-fr")
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        dateTF.inputAccessoryView = toolbar
        dateTF.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateTF.text = formatter.string(from: datePicker.date)
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
    
            let uuid = UUID().uuidString
            imageView.image!.upload(with: "image \(name)", completion: {(url: URL?) in
                print(url)
                Database.database().reference(withPath: "events").child(uuid).updateChildValues(["image": url?.absoluteString])
            })
            
            let ref = Database.database().reference(withPath: "events").child(uuid)
            
            let dictEvent: [String: Any] = [
                "content": description,
                "endTime": timeEnd,
                "idOrganizer": Auth.auth().currentUser!.uid,
                "image":"",
                "name": name,
                "price":price,
                "startDate": date,
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
            
            dismiss(animated: true, completion: nil)
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
    
    /// The UITextView placeholder text
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
