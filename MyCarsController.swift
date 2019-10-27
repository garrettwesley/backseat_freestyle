//
//  MyCarsController.swift
//  backseat
//
//  Created by Garrett Wesley on 10/26/19.
//  Copyright © 2019 Garrett Wesley. All rights reserved.
//


import UIKit
import Firebase
import SnapKit

class MyCarsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var carTable: UITableView!
    var myCars = [String]() {
        didSet {
            carTable?.reloadData()
        }
    }
    var user_uuid = ""
    
    func queryCars() {
        print("querying cars")
        let db = Firestore.firestore()
        let docRef = db.collection("user_UUID").document(user_uuid).collection("cars")
        docRef.getDocuments() { (q, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                print("got some docs")
                for document in q!.documents {
                    let name = document.data()["name"] as! String
                    if !self.myCars.contains(name) {
                        self.myCars.append(name)
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        title = "My Cars"
        navigationItem.setHidesBackButton(true, animated:true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        
        carTable = UITableView()
        carTable.register(UITableViewCell.self, forCellReuseIdentifier: "CarCell")
        carTable.dataSource = self
        carTable.delegate = self
        carTable.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0)
        view.addSubview(carTable)
        
        carTable.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        queryCars()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Car Num: \(indexPath.row)")
        self.performSegue(withIdentifier: "carpushed", sender: myCars[indexPath.row])
        carTable.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myCars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = carTable.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath)
        cell.textLabel?.text = myCars[indexPath.row]
        cell.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0)
        return cell
    }
    
    @objc func addTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "connectToCar", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            myCars.remove(at: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0)
    }
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "carpushed" {
            let name = sender as! String
            if let destination = segue.destination as? CarDataController {
                destination.car_name = name;
                destination.user_uuid = user_uuid;
            }
        } else if segue.identifier == "connectToCar" {
            if let destination = segue.destination as? ConnectionTCPController {
                destination.user_uuid = user_uuid
            }
        }
    }
    
}
