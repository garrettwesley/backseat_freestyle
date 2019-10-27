//
//  ViewController.swift
//  backseat
//
//  Created by Garrett Wesley on 10/26/19.
//  Copyright © 2019 Garrett Wesley. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }

    @IBAction func loginPushed(_ sender: Any) {
        print("logging in to firebase")
        guard let email = emailInput.text else {
            print("Enter email")
            return
        }
        guard let password = passwordInput.text else {
            print("Enter password")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard self != nil else { return }
            if error != nil {
                let alertController = UIAlertController(title: "Password Incorrect", message: "Please re-type password", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Re-type", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self!.present(alertController, animated: true, completion: nil)
            } else {
                self!.performSegue(withIdentifier: "successLogin", sender: authResult?.user.uid)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "successLogin" {
            let user_uid = sender as? String
            if let destination = segue.destination as? MyCarsController {
                destination.user_uuid = user_uid!
            }
        }
    }
}

