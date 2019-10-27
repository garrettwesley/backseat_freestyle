//
//  ConnectCar.swift
//  backseat
//
//  Created by Mark Scheble on 10/26/19.
//  Copyright © 2019 Garrett Wesley. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SnapKit

class CarDataController: UIViewController, ProxyManagerDelegate {
    var proxyState = ProxyState.stopped
    var keys = ["speed", "avg speed", "rpm", "fuel level", "fuel range", "odometer", "coordinates", "temperature"]
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        cv.register(DataCell.self, forCellWithReuseIdentifier: "DataCell")
        cv.delegate = self
        cv.dataSource = self
        cv.alwaysBounceVertical = true
        cv.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0)
        return cv
    }()

    @IBOutlet weak var connectButton: UIBarButtonItem!
    
    var carData = ["", "", "" ,"" ,"" ,"" ,"", ""] {
        didSet {
            collectionView.reloadData()
        }
    }
    var car_name = ""
    var user_uuid = ""
    var ipAddress = ""
    var port = ""
    var speed = 0
    
    override func viewDidLoad() {
        title = car_name
        let row = UIView()
        
        ProxyManager.sharedManager.delegate = self
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0)
        view.addSubview(row)
        view.addSubview(collectionView)

        row.snp.makeConstraints { make in
            make.top.left.right.equalTo(view)
            make.height.equalTo(100)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(row.snp.bottom)
            make.centerX.bottom.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.9)
        }

        let db = Firestore.firestore();
        let docRef = db.collection("user_UUID").document(user_uuid).collection("cars").document(car_name)
                
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.ipAddress = document.get("ipAddress") as! String
                self.port = document.get("port") as! String
                self.speed = document.get("speed") as! Int
            } else {
                print("Document does not exist")
            }
        }
        getData()
    }
    
    func getData() {
        print("Fetching data from firebase")
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child(car_name).observe(.value, with:{ snapshot in
            if !(snapshot.value is NSNull) {
                let values = snapshot.value as! [String: Any]
                var x = 0
                if values["speed"] != nil {
                    let speed = values["speed"] as! NSArray
                    let totalLength = speed.count
                    let speed1 = speed[totalLength - 1]
                    self.carData[x] = "\(speed1) km/h"
                    x += 1
                    var summar = 0
                    for i in speed {
                        summar += i as! Int
                    }
                    let avgspeed = summar / totalLength
                    self.carData[x] = "\(avgspeed) km/h"
                    x += 1
                }
                if values["rpm"] != nil {
                    let rpm = values["rpm"] as! Int
                    self.carData[x] = "\(rpm) rev/min"
                    x += 1
                }
                if values["fuelLevel"] != nil {
                    let fuelLevel = values["fuelLevel"] as! Double
                    self.carData[x] = "\(fuelLevel * 100)%"
                    x += 1
                }
                if values["fuelRange"] != nil {
                    let fuelRange = values["fuelRange"] as! Double
                    self.carData[x] = "\(fuelRange) km"
                    x += 1
                }
                if values["odometer"] != nil {
                    let odometer = values["odometer"] as! Int
                    self.carData[x] = "\(odometer) miles"
                    x += 1
                }
                if values["gps"] != nil {
                    let gps = values["gps"] as! String
                    self.carData[x] = "\(gps)"
                    x += 1
                }
                if values["externalTemperature"] != nil {
                    let externalTemperature = values["externalTemperature"] as! Int
                    self.carData[x] = "\(externalTemperature) C"
                    x += 1
                }
            }
        })
        
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

    
    @IBAction func connectButtonWasPressed(_ sender: Any) {
        if self.ipAddress != "" || self.port != "" {
            AppUserDefaults.shared.ipAddress = self.ipAddress
            AppUserDefaults.shared.port = self.port
            
            switch proxyState {
            case .stopped:
                ProxyManager.sharedManager.start(with: .tcp, carName: car_name)
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


class DataCell: UICollectionViewCell {
    let valueLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .boldSystemFont(ofSize: 35)
        l.textColor = .darkGray
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.5
        return l
    }()
    
    let keyLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.font = .systemFont(ofSize: 20)
        l.textColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        return l
    }()
    
    var key: String? {
        didSet {
            display()
        }
    }
    var value: String? {
        didSet {
            display()
        }
    }
    
    func display() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 15
        contentView.addSubview(valueLabel)
        contentView.addSubview(keyLabel)
        
        valueLabel.text = value
        keyLabel.text = key
        
        keyLabel.snp.makeConstraints { make in
            make.width.equalTo(contentView).offset(-10)
            make.top.left.equalTo(contentView).offset(10)
            make.height.equalTo(20)
        }
        valueLabel.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(contentView)
            make.top.equalTo(keyLabel.snp.bottom)
        }
    }
}

extension CarDataController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return carData.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DataCell", for: indexPath as IndexPath) as? DataCell else {
            fatalError("Cell not exists in storyboard")
        }
        
        cell.key = keys[indexPath.item]
        cell.value = carData[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  30
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize / 2, height: collectionViewSize / 2)
    }
}
