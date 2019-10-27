////
////  ConnectCarController.swift
////  backseat
////
////  Created by Garrett Wesley on 10/26/19.
////  Copyright © 2019 Garrett Wesley. All rights reserved.
////
//
//import UIKit
//
//class ConnectCarController: UIViewController, ProxyManagerDelegate {
//
//    @IBOutlet weak var ipAddressInput: UITextField!
//    @IBOutlet weak var portInput: UITextField!
//    @IBOutlet weak var connectButton: UIButton!
//
//    var proxyState = ProxyState.stopped
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "Connect"
//
//        ProxyManager.sharedManager.delegate = self
//        ipAddressInput.text = AppUserDefaults.shared.ipAddress
//        portInput.text = AppUserDefaults.shared.port
//    }
//
//    @IBAction func connectToFord(_ sender: Any) {
//        let ipAddress = ipAddressInput.text
//        let port = portInput.text
//
//        if ipAddress != "" || port != "" {
////            AppUserDefaults.shared.ipAddress = ipAddress
////            AppUserDefaults.shared.port = port
//
//            switch proxyState {
//            case .stopped:
//                ProxyManager.sharedManager.start(with: .tcp)
//            case .searching:
//                ProxyManager.sharedManager.stopConnection()
//            case .connected:
//                ProxyManager.sharedManager.stopConnection()
//            }
//        } else {
//            let alertMessage = UIAlertController(title: "Missing Info!", message: "Make sure to set your IP Address and Port", preferredStyle: .alert)
//            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alertMessage, animated: true, completion: nil)
//        }
//    }
//    // MARK: - Delegate Functions
//    func didChangeProxyState(_ newState: ProxyState) {
//        proxyState = newState
//        var newColor: UIColor? = nil
//        var newTitle: String? = nil
//
//        switch newState {
//        case .stopped:
//            newColor = UIColor.red
//            newTitle = "Connect"
//        case .searching:
//            newColor = UIColor.blue
//            newTitle = "Stop Searching"
//        case .connected:
//            newColor = UIColor.green
//            newTitle = "Disconnect"
//        }
//
//        if (newColor != nil) || (newTitle != nil) {
//            DispatchQueue.main.async(execute: {[weak self]() -> Void in
//                self?.connectButton.setTitle(newTitle, for: .normal)
//                self?.connectButton.setTitleColor(.white, for: .normal)
//            })
//        }
//    }
//}