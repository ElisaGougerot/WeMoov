//
//  EventDetailViewController.swift
//  WeMoov
//
//  Created by Victor on 26/12/2019.
//  Copyright © 2019 Elisa Gougerot. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController {

    
    @IBOutlet var eventImageView: UIImageView!
    @IBOutlet var eventName: UILabel!
    @IBOutlet var eventTypePlace: UILabel!
    @IBOutlet var eventTypeEvent: UILabel!
    //@IBOutlet var eventContent: UILabel!
    @IBOutlet var eventStartDate: UILabel!
    @IBOutlet var eventPrice: UILabel!
    @IBOutlet weak var eventContent: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
        eventContent.isEditable = false;
    }

    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func touchMapButton() {
        let mapViewController = MapViewController()
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    func configureViewComponents() {
        view.backgroundColor = UIColor.mainWhite()
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "\(GlobalVariable.eventClicked.name)"
        
              
        //Back Button
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "back")
        
        let iv2 = UIImageView()
        iv2.contentMode = .scaleAspectFit
        iv2.clipsToBounds = true
        iv2.image = #imageLiteral(resourceName: "pin")
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleBack))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(singleTap)
        
        let singleTap2 = UITapGestureRecognizer(target: self, action: #selector(touchMapButton))
        iv2.isUserInteractionEnabled = true
        iv2.addGestureRecognizer(singleTap2)
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: iv)
        navigationController?.navigationBar.barTintColor = UIColor.mainWhite()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: iv2)
        
        
        let event = GlobalVariable.eventClicked
        // Event ImageView
        self.eventImageView.loadImage(urlString: event.image)
        /*if let pictureURL = event.image {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: pictureURL) {
                    DispatchQueue.main.sync {
                        self.eventImageView.image = UIImage(data: data)
                    }
                }
            }
        }*/
        UIView.animate(withDuration: 0.5, animations: {
            self.eventImageView.alpha = 1
        })
        
        let dateFormatter       = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy - HH'h'mm"
        dateFormatter.locale    = Locale(identifier: "FR-fr")
        
        // Event Labels
        self.eventName.text = event.name
        self.eventTypePlace.text = event.typePlace
        self.eventTypeEvent.text = event.typeEvent
        self.eventContent.text = event.content
        self.eventStartDate.text = "\(dateFormatter.string(from: event.startDate))"
        if event.price == "0" {
            self.eventPrice.text = "Gratuit"
        } else {
            self.eventPrice.text = "\(event.price) €"
        }
        
    
    }
    
    @objc func touchFavButton() {
       //Ajouter ici traitement de mise en favoris
    }

}
