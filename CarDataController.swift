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

class CarDataController: UIViewController, ProxyManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    var proxyState = ProxyState.stopped
    private var dataTable: UITableView!

    @IBOutlet weak var connectButton: UIBarButtonItem!
    
    var carData = ["", "", "" ,"" ,"" ,"" ,"", ""] {
        didSet {
            dataTable.reloadData()
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
        
        dataTable = UITableView()
        dataTable.register(UITableViewCell.self, forCellReuseIdentifier: "DataCell")
        dataTable.dataSource = self
        dataTable.delegate = self
        view.addSubview(dataTable)
        
        dataTable.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
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
        getData()
    }
    
    func getData() {
        print("Fetching data from firebase")
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child(car_name).observe(.value, with:{ snapshot in
            print("Observing")
            if !(snapshot.value is NSNull) {
                let values = snapshot.value as! [String: Any]
                print(values)
                var x = 0
                if values["speed"] != nil {
                    let speed = values["speed"] as! NSArray
                    let totalLength = speed.count
                    print(speed)
                    let speed1 = speed[totalLength - 1]
                    self.carData[x] = "Current Speed: \(speed1) km/h"
                    x += 1
                    var summar = 0
                    for i in speed {
                        summar += i as! Int
                    }
                    print(summar)
                    let avgspeed = summar / totalLength
                    print(avgspeed)
                    self.carData[x] = "Average Speed of Trip: \(avgspeed) km/h"
                    x += 1
                }
                if values["rpm"] != nil {
                    let rpm = values["rpm"] as! Int
                    self.carData[x] = "RPM: \(rpm) rev/min"
                    x += 1
                }
                if values["fuelLevel"] != nil {
                    let fuelLevel = values["fuelLevel"] as! Double
                    self.carData[x] = "Fuel Level: \(fuelLevel * 100)%"
                    x += 1
                }
                if values["fuelRange"] != nil {
                    let fuelRange = values["fuelRange"] as! Double
                    self.carData[x] = "Fuel Range: \(fuelRange) km"
                    x += 1
                }
                if values["odometer"] != nil {
                    let odometer = values["odometer"] as! Int
                    self.carData[x] = "Total Miles: \(odometer) miles"
                    x += 1
                }
                if values["gps"] != nil {
                    let gps = values["gps"] as! String
                    self.carData[x] = "GPS Coordinates: \(gps)"
                    x += 1
                }
                if values["externalTemperature"] != nil {
                    let externalTemperature = values["externalTemperature"] as! Int
                    self.carData[x] = "External Temperature: \(externalTemperature) degrees Celsius"
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
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dataTable.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath)
        cell.textLabel?.text = carData[indexPath.row]
        return cell
    }
    
}
