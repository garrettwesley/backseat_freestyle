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
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        cv.register(DataCell.self, forCellWithReuseIdentifier: "DataCell")
        cv.delegate = self
        cv.dataSource = self
        cv.alwaysBounceVertical = true
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
        
        ProxyManager.sharedManager.delegate = self
        
        collectionView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.edges.equalTo(view.safeAreaLayoutGuide)
            }
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
            print("Observing")
            if snapshot.value != nil {
                let values = snapshot.value as! [String: Any]
                print(values)
                if values["speed"] != nil {
                    let speed = values["speed"] as! Int
                    self.carData[0] = "Current Speed: \(speed) km/h"
                }
                if values["avgspeed"] != nil {
                    let avgspeed = values["avgspeed"] as! Int
                    self.carData[1] = "Average Speed of Trip: \(avgspeed) km/h"
                }
                if values["rpm"] != nil {
                    let rpm = values["rpm"] as! Int
                    self.carData[2] = "RPM: \(rpm) rev/min"
                }
                if values["fuelLevel"] != nil {
                    let fuelLevel = values["fuelLevel"] as! Double
                    self.carData[3] = "Fuel Level: \(fuelLevel * 100)%"
                }
                if values["fuelRange"] != nil {
                    let fuelRange = values["fuelRange"] as! Double
                    self.carData[4] = "Fuel Range: \(fuelRange) km"
                }
                if values["odometer"] != nil {
                    let odometer = values["odometer"] as! Int
                    self.carData[5] = "Total Miles: \(odometer) miles"
                }
                if values["gps"] != nil {
                    let gps = values["gps"] as! String
                    self.carData[6] = "GPS Coordinates: \(gps)"
                }
                if values["externalTemperature"] != nil {
                    let externalTemperature = values["externalTemperature"] as! Int
                    self.carData[7] = "External Temperature: \(externalTemperature) degrees Celsius"
                }
            }
            
//            let totalLength = speed.count
//            print(totalLength)
//            let speed1 = speed.index(forKey: totalLength)
//            var summar = 0
//            for i in speed {
//                summar = 0
//                summar += i.value
//            }
//            let avgspeed = summar / totalLength
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
        let title = UILabel()
        title.textAlignment = .center
        title.font = .systemFont(ofSize: 30)
        title.textColor = .blue
        return title
    }()
    
    let keyLabel: UILabel = {
        let date = UILabel()
        date.textAlignment = .left
        date.font = .systemFont(ofSize: 14)
        date.textColor = .gray
        return date
    }()
    
    var key: String? {
        didSet {
            display()
        }
    }
    var value: String?
    
    func display() {
        contentView.addSubview(valueLabel)
        contentView.addSubview(keyLabel)
        
        setupConstraints()
    }

    func setupConstraints() {
        keyLabel.snp.makeConstraints { make in
            make.top.width.equalTo(contentView)
            make.height.equalTo(20)
        }
        valueLabel.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(contentView)
            make.top.equalTo(keyLabel.snp.bottom)
        }
    }
}

extension CarDataController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return carData.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DataCell", for: indexPath as IndexPath) as? DataCell else {
            fatalError("Cell not exists in storyboard")
        }
        
        cell.key = "speed"
        cell.value = String(77)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  50
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize / 2, height: collectionViewSize / 2)
    }
}
