//
//  SearchViewController.swift
//  WeMoov
//
//  Created by Victor on 27/12/2019.
//  Copyright © 2019 Elisa Gougerot. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase



class SearchViewController: UIViewController {

    @IBOutlet var searchTabBar: UITabBar!
    @IBOutlet var searchBarItem: UITabBarItem!
    
    @IBOutlet var searchTextFieldDate: UITextField!
    @IBOutlet var searchEventButton: UIButton!
    
    @IBOutlet var searchTypeEventTextField: UITextField!
    
    @IBOutlet var searchDistanceSlider: UISlider!
    @IBOutlet var searchPlaceEventTextField: UITextField!
    
    let searchDatePicker =  UIDatePicker()
    
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
        iv.image = #imageLiteral(resourceName: "cancel")
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSignOut))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(singleTap)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: iv)
        navigationController?.navigationBar.barTintColor = UIColor.mainWhite()

        self.navigationItem.setHidesBackButton(true, animated:true);
        self.searchTabBar.delegate = self
        self.searchTabBar.selectedItem = self.searchBarItem
        self.searchTabBar.tintColor = UIColor.mainBlack()
        
        // Button
        self.searchEventButton.layer.cornerRadius = 15.0
        self.searchEventButton.layer.cornerRadius = 15.0
        
        
 
    }
    
    func showDatePicker(){
        //Formate Date
        searchDatePicker.datePickerMode = .date
        
          //ToolBar
          let toolbar = UIToolbar();
          toolbar.sizeToFit()
          let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
          let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));

        toolbar.setItems([doneButton,cancelButton], animated: false)

        searchTextFieldDate.inputView = searchDatePicker
    }

    @objc func donedatePicker(){

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.locale = Locale(identifier: "FR-fr")
        searchTextFieldDate.text = dateFormatter.string(from: searchDatePicker.date)
        self.view.endEditing(true)
        
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
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
