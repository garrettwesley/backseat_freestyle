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

    @IBOutlet weak var typewriterLabel: UILabel!
    var emailInput: UITextField = {
        let input = UITextField()
        input.layer.borderColor = UIColor.lightGray.cgColor
        input.layer.borderWidth = 1
        input.layer.cornerRadius = 10
        input.borderStyle = .roundedRect
        input.placeholder = "email"
        input.autocorrectionType = .no
        input.autocapitalizationType = .none
        return input
    }()
    var passwordInput: UITextField = {
        let input = UITextField()
        input.layer.borderColor = UIColor.lightGray.cgColor
        input.layer.borderWidth = 1
        input.layer.cornerRadius = 10
        input.borderStyle = .roundedRect
        input.placeholder = "password"
        input.isSecureTextEntry = true
        input.autocorrectionType = .no
        input.autocapitalizationType = .none
        return input
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "successLogin", sender: Auth.auth().currentUser?.uid)
        }
        
        view.addSubview(emailInput)
        view.addSubview(passwordInput)
        
        emailInput.snp.makeConstraints { (make) in
            make.width.equalTo(view).multipliedBy(0.8)
            make.height.equalTo(50)
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(-40)
        }
        passwordInput.snp.makeConstraints { (make) in
            make.width.equalTo(view).multipliedBy(0.8)
            make.height.equalTo(50)
            make.centerX.equalTo(view)
            make.top.equalTo(emailInput.snp.bottom).offset(10)
        }
        
        
        typewriterLabel.lineBreakMode = .byWordWrapping
        typewriterLabel.numberOfLines = 0
        if #available(iOS 8.2, *) {
            typewriterLabel.font = UIFont.systemFont(ofSize: 21, weight: .bold)
        }
        typewriterLabel.setTextWithTypeAnimation(typedText: "your eyes on the road")
        
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



extension UILabel {
    func setTextWithTypeAnimation(typedText: String, characterDelay: TimeInterval = 5.0) {
        text = ""
        var writingTask: DispatchWorkItem?
        writingTask = DispatchWorkItem { [weak weakSelf = self] in
            for character in typedText {
                DispatchQueue.main.async {
                    weakSelf?.text!.append(character)
                }
                Thread.sleep(forTimeInterval: characterDelay/100)
            }
        }
        
        if let task = writingTask {
            let queue = DispatchQueue(label: "typespeed", qos: DispatchQoS.userInteractive)
            queue.asyncAfter(deadline: .now() + 0.05, execute: task)
        }
    }
    
}
