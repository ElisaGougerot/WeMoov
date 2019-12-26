//
//  CreateEventViewController.swift
//  WeMoov
//
//  Created by Victor on 26/12/2019.
//  Copyright © 2019 Elisa Gougerot. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController {
    
    //Définition du container du champ Nom
    lazy var nameContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "anonymous"), nameTextField)
    }()
    
    //Définition du textfield pseudo
    lazy var nameTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceolder: "Nom de l'événement", isSecureTextEntry: false)
    }()

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
        navigationItem.title = "Créer un évenement"
        
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
        
        
        
    }

}
