//
//  ConnectCar.swift
//  backseat
//
//  Created by Mark Scheble on 10/26/19.
//  Copyright © 2019 Garrett Wesley. All rights reserved.
//

import UIKit
import Firebase

class CarDataController: UIViewController, ProxyManagerDelegate {
    var proxyState = ProxyState.stopped
    @IBOutlet weak var connectButton: UIBarButtonItem!
    
    var car_name = ""
    var user_uuid = ""
    var ipAddress = ""
    var port = ""
    var speed = 0
    
    override func viewDidLoad() {
        title = car_name
        
        ProxyManager.sharedManager.delegate = self
        
        let db = Firestore.firestore();
        let docRef = db.collection("user_UUID").document(user_uuid).collection("cars").document(car_name)
                
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.ipAddress = document.get("ipAddress") as! String
                self.port = document.get("port") as! String
                self.speed = document.get("speed") as! Int
                self.initButton()
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func didChangeProxyState(_ newState: ProxyState) {
        proxyState = newState
        var newColor: UIColor? = nil
        var newTitle: String? = nil
        
        switch newState {
        case .stopped:
            newColor = UIColor.red
            newTitle = "Connect"
        case .searching:
            newColor = UIColor.blue
            newTitle = "Stop Searching"
        case .connected:
            newColor = UIColor.green
            newTitle = "Disconnect"
        }
        
        if (newColor != nil) || (newTitle != nil) {
            DispatchQueue.main.async(execute: {[weak self]() -> Void in
                self?.connectButton.title = newTitle
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initButton() {
        self.connectButton.title = "Connect"
        //self.connectButton.tintColor = "Orange"
    }
    
    @IBAction func connectButtonWasPressed(_ sender: Any) {
        if self.ipAddress != "" || self.port != "" {
            AppUserDefaults.shared.ipAddress = self.ipAddress
            AppUserDefaults.shared.port = self.port
            
            switch proxyState {
            case .stopped:
                ProxyManager.sharedManager.start(with: .tcp)
            case .searching:
                ProxyManager.sharedManager.stopConnection()
            case .connected:
                ProxyManager.sharedManager.stopConnection()
            }
        } else {
            let alertMessage = UIAlertController(title: "Missing Info!", message: "Make sure to set your IP Address and Port", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertMessage, animated: true, completion: nil)
        }
    }
    
}
