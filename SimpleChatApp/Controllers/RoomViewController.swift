//
//  RoomViewController.swift
//  SimpleChatApp
//
//  Created by shunya on 2019/12/04.
//  Copyright © 2019 shunya. All rights reserved.
//

import UIKit
import Firebase

class RoomViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var rooms: [Room] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let db = Firestore.firestore()
        
        db.collection("rooms").order(by: "createdAt", descending: true).addSnapshotListener({ (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                return
            }
            
            var results: [Room] = []
            
            for document in documents {
//                let name = document.data()["name"] as! String
                let name = document.get("name") as! String
                let room = Room(name: name, documentId: document.documentID)
                results.append(room)
            }
            self.rooms = results
        })
    }

    @IBAction func didClickButton(_ sender: UIButton) {
        guard let roomName = textField.text else {
            return
        }
        if textField.text!.isEmpty {
            return
        }
        
        var ref: DocumentReference? = nil
        let db = Firestore.firestore()
        
        ref = db.collection("rooms").addDocument(data: [
            "name": roomName,
            "createdAt": FieldValue.serverTimestamp()
        ]) { err in
            if let error = err {
                print("error: \(err?.localizedDescription)")
            } else {
                print("added: \(ref!.documentID)")
            }
        }
        
        textField.text = ""
    }
}

extension RoomViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = rooms[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let db = Firestore.firestore()

            db.collection("rooms").document(rooms[indexPath.row].documentId).delete(){ err in
                if let error = err {
                    print(err.debugDescription)
                } else {
                    print("deleted")
                }
            }
        }
    }
}
