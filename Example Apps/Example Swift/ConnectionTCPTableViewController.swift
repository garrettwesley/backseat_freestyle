//
//  ConnectionTCPTableViewController.swift
//  SmartDeviceLink-ExampleSwift
//
//  Copyright © 2017 smartdevicelink. All rights reserved.
//
import UIKit
import Firebase

class ConnectionTCPController: UIViewController, ProxyManagerDelegate {
    
    @IBOutlet weak var carName: UITextField!
    @IBOutlet weak var ipAddressInput: UITextField!
    @IBOutlet weak var portInput: UITextField!
    @IBOutlet weak var connectButton: UIButton!
    var user_uuid = ""
    
    
    var proxyState = ProxyState.stopped

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Connect"
        ProxyManager.sharedManager.delegate = self
        ipAddressInput.text = AppUserDefaults.shared.ipAddress
        portInput.text = AppUserDefaults.shared.port
        initButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initButton() {
        self.connectButton.setTitle("Connect", for: .normal)
        self.connectButton.setTitleColor(.orange, for: .normal)
    }
    
    
    @IBAction func connectButtonWasPressed(_ sender: Any) {
        let ipAddress = ipAddressInput.text
        let port = portInput.text
        let carsName = carName.text as! String

        if ipAddress != "" || port != "" {
            AppUserDefaults.shared.ipAddress = ipAddress
            AppUserDefaults.shared.port = port
            
            switch proxyState {
            case .stopped:
                ProxyManager.sharedManager.start(with: .tcp, carName: carsName)
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
            print("should've connected");
            addCars();
        }
        
        if (newColor != nil) || (newTitle != nil) {
            DispatchQueue.main.async(execute: {[weak self]() -> Void in
                self?.connectButton.setTitle(newTitle, for: .normal)
                self?.connectButton.setTitleColor(.orange, for: .normal)
            })
        }
    }
    
    func addCars() {
        print("querying cars");
        let db = Firestore.firestore();
        db.collection("user_UUID").document(user_uuid).collection("cars").document(carName.text!).setData([
            "name": carName.text!,
            "ipAddress": ipAddressInput.text!,
            "port": portInput.text!,
            "speed": 100
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }

    }
}
