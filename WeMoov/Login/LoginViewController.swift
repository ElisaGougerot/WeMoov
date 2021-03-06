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
    
    /**
                Définition des éléments qui vont être présent dans la View:
                - Logo
                - EmailTF
                - PasswordTF
                - loginButton
                - DonthaveAccount
     */
    
    let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "logo2")
        return iv
    }()
    
    
    lazy var emailContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "mail"), emailTextField)
    }()
    
    lazy var passwordContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "mdp"), passwordTextField)
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
        button.setTitleColor(UIColor.mainBlack(), for: .normal)
        button.backgroundColor = .white
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
    
    /**
                Function Firebase qui gère l'auto connexion
     */
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
    }
    
    @objc func handleShowSignUp(){
        navigationController?.pushViewController(InscriptionViewController(), animated: true)
    }
    
    
    func logUserIn(withEmail email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let err = error {
                print("Erreur, impossible de se connecter :", err.localizedDescription)
                self.displayError(message: "\(err.localizedDescription)")
                return
            }
            
        }
        loadUserData()
    }
    
    /**
                Sauvegarde des données de l'user dans la database et push de la nouvelle View
                    - Si isOrganizer = true, alors push de la view Organizer
                    - Si false, alors push de la view Home.
     */
    func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("user").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let user = snapshot.value as? NSDictionary else { return }
            let uid = user["uid"] as? String ?? uid
            let username = user["firstname"] as? String ?? ""
            let email = user["email"] as? String  ?? ""
            let isOrganizer = user["isOrganizer"] as? Bool ?? false
            GlobalVariable.user = User(id: uid, email: email, username: username, isOrganizer: isOrganizer)
            GlobalVariable.favorites.setUserID(id: uid)
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
    
    
    /**
                Initialisation de la view : Ajout des composants en fonction des contraintes.
     */
    func viewComponentConfigure(){
        self.hideKeyboardWhenTappedAround()
        view.backgroundColor = UIColor.mainBlack() // Set la valeur de l'arrière plan avec .mainOrange défini dans Extensions.swift
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoImageView)
        logoImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 70, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 400, height: 150)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(emailContainerView)
        emailContainerView.anchor(top: logoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 100, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        view.addSubview(passwordContainerView)
        passwordContainerView.anchor(top: emailContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        view.addSubview(loginButton)
        loginButton.anchor(top: passwordContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
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
