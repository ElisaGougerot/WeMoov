//
//  SignUpViewController.swift
//  WeMoov
//
//  Created by Taj Singh on 20/12/2019.
//  Copyright © 2019 Elisa Gougerot. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SignUpViewController: UIViewController {

       //Définition du logo
    let logoImageView: UIImageView = {
         let iv = UIImageView()
         iv.contentMode = .scaleToFill
         iv.clipsToBounds = true
         iv.image = #imageLiteral(resourceName: "WeMoov")
         return iv
     }()
     
     //Définition du container du champ email
     lazy var emailContainerView: UIView = {
            let view = UIView()
            return view.textContainerView(view: view, #imageLiteral(resourceName: "envelope"), emailTextField)
        }()
     
     //Définition du container du champ pseudo
     lazy var pseudoContainerView: UIView = {
         let view = UIView()
         return view.textContainerView(view: view, #imageLiteral(resourceName: "anonymous") , pseudoTextField)
     }()
     
     //Définition du container du champ password
     lazy var passwordContainerView: UIView = {
         let view = UIView()
         return view.textContainerView(view: view, #imageLiteral(resourceName: "lock"), passwordTextField)
     }()
     
     //Définition du textfield email
     lazy var emailTextField: UITextField = {
         let tf = UITextField()
         tf.keyboardType = .emailAddress
         return tf.textField(withPlaceolder: "Email", isSecureTextEntry: false)
     }()
     
     //Définition du textfield password
     lazy var passwordTextField: UITextField = {
         let tf = UITextField()
         tf.passwordRules = UITextInputPasswordRules(descriptor: "required: upper; required: digit; minlength: 6;")
         return tf.textField(withPlaceolder: "Mot de passe", isSecureTextEntry: false)
     }()
     
     //Définition du textfield pseudo
     lazy var pseudoTextField: UITextField = {
         let tf = UITextField()
         return tf.textField(withPlaceolder: "Prénom", isSecureTextEntry: false)
     }()
     
     //Définition du bouton S'inscrire
     let loginButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("S'INSCRIRE", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            button.setTitleColor(UIColor.mainOrange(), for: .normal)
            button.backgroundColor = .black
        button.addTarget(self, action: #selector(handleLogin), for: .allEvents)
            button.layer.cornerRadius = 10
            return button
        }()
     
     //Définition du bouton permettant de revenir à la page connexion
     let dontHaveAccountButton: UIButton = {
            let button = UIButton(type: .system)
            let attributedTitle = NSMutableAttributedString(string: "Tu as un compte?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white])
            attributedTitle.append(NSAttributedString(string: "Se connecter", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.red]))
            button.setAttributedTitle(attributedTitle, for: .normal)
            button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
            return button
        }()
     
     
     override func viewDidLoad() {
         super.viewDidLoad()
         viewComponentConfigure()
     }
    
    //Func gerant le clic sur bouton Connexion
    
    @objc func handleLogin(){
       guard let email = emailTextField.text else { return }
       guard let password = passwordTextField.text else { return }
       guard let pseudo = pseudoTextField.text else { return }
       
       createUser(email: email, password: password, pseudo: pseudo)

    }
    
    //Func emmenant vers la page connexion si le bouton se connecter est pressé.
    @objc func handleShowSignUp(){
        print("signup")
        //Retourner au précedent écran.
       navigationController?.popViewController(animated: true)

    }
    
    func createUser(email:String, password: String, pseudo:String){
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            if let err = error {
                print("Impossible de vous authentifier", err.localizedDescription)
                return
            }
            guard let uid = result?.user.uid else { return }
            
            let valDict = ["email" : email, "firstname": pseudo]
            Database.database().reference().child("user").child(uid).updateChildValues(valDict, withCompletionBlock: { (error, ref) in
                if let err = error {
                    print("Impossible de mettre à jour la bdd", err.localizedDescription)
                    return
                }
                
            
            self.dismiss(animated: true, completion: nil)

        })
    }
  }

     //Func affichant les éléments suivant les contraintes ( définient en utilisant l'extension)
     func viewComponentConfigure(){
        self.hideKeyboardWhenTappedAround()
         view.backgroundColor = UIColor.mainOrange() // Set la valeur de l'arrière plan avec .mainOrange défini dans Extensions.swift
         navigationController?.navigationBar.isHidden = true
         
         view.addSubview(logoImageView)
         logoImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 60, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150)
         logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
         
         view.addSubview(emailContainerView)
         emailContainerView.anchor(top: logoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
         
         view.addSubview(pseudoContainerView)
         pseudoContainerView.anchor(top: emailContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
         
         view.addSubview(passwordContainerView)
         passwordContainerView.anchor(top: pseudoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
                
         view.addSubview(loginButton)
                loginButton.anchor(top: passwordContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
         view.addSubview(dontHaveAccountButton)
                dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 32, paddingBottom: 12, paddingRight: 32, width: 0, height: 50)
         
     }
}
