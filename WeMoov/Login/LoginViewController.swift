//
//  LoginViewController.swift
//  WeMoov
//
//  Created by Taj Singh on 19/12/2019.
//  Copyright © 2019 Elisa Gougerot. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    
    let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "WeMoov")
        return iv
    }()
    
    
    lazy var emailContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "envelope"), emailTextField)
    }()
    
    lazy var passwordContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "lock"), passwordTextField)
    }()
    
    lazy var emailTextField: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .emailAddress
        return tf.textField(withPlaceolder: "Email", isSecureTextEntry: false)
    }()
    
    lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceolder: "Mot de passe", isSecureTextEntry: true)
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SE CONNECTER", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(UIColor.mainOrange(), for: .normal)
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.layer.cornerRadius = 10
        return button
    }()
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Pas encore de compte?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string: "S'enregistrer", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.red]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewComponentConfigure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            guard user != nil else { return }
            self.loadUserData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @objc func handleLogin(){
        guard let email = emailTextField.text,
            let password = passwordTextField.text ,
            password.count > 0,
            email.count > 0 else { return }
        logUserIn(withEmail: email, password: password)
        
        //navigationController?.pushViewController(SignUpViewController(), animated: false)
        
    }
    
    @objc func handleShowSignUp(){
        print("signup")
        navigationController?.pushViewController(InscriptionViewController(), animated: true)
    }
    
    
    func logUserIn(withEmail email: String, password: String){
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let err = error {
                print("Erreur, impossible de se connecter :", err.localizedDescription)
                self.displayError(message: "\(err.localizedDescription)")
                return
            } /*else {
             self.navigationController?.pushViewController(HomeViewController(), animated: true)
             self.dismiss(animated: true, completion: nil)
             }*/
            
        }
        print("login")
        loadUserData()
        // let homeViewController = HomeViewController()
        // self.navigationController?.pushViewController(homeViewController, animated: true)
        //self.dismiss(animated: true, completion: nil)
    }
    
    func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("user").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let user = snapshot.value as? NSDictionary else { return }
            let username = user["username"] as? String ?? ""
            let isOrganizer = user["isOrganizer"] as? Bool ?? false
            GlobalVariable.username = username
            if isOrganizer {
                self.navigationController?.pushViewController(HomeOrganizerViewController(), animated: true)
            } else {
                let homeViewController = HomeViewController()
                //homeViewController.pseudoLabel.text = username
                self.navigationController?.pushViewController(homeViewController, animated: true)
            }
        }
    }
    
    func displayError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        if presentedViewController == nil {
            self.present(alert, animated: true, completion: nil)
        } /*else{
         self.dismiss(animated: false) { () -> Void in
         self.present(alert, animated: true, completion: nil)
         }
         }*/
    }
    
    func viewComponentConfigure(){
        self.hideKeyboardWhenTappedAround()
        view.backgroundColor = UIColor.mainOrange() // Set la valeur de l'arrière plan avec .mainOrange défini dans Extensions.swift
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoImageView)
        logoImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 60, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(emailContainerView)
        emailContainerView.anchor(top: logoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        view.addSubview(passwordContainerView)
        passwordContainerView.anchor(top: emailContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        view.addSubview(loginButton)
        loginButton.anchor(top: passwordContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 32, paddingBottom: 12, paddingRight: 32, width: 0, height: 50)
        
    }
    
}

// Dans toute l'app: Permet de fermer le clavier en cliquant en dehors du clavier
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
