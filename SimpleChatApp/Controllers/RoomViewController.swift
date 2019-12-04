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
        
        let room1 = Room(name: "test", documentId: "123")
        let room2 = Room(name: "test", documentId: "123")
        
        rooms.append(room1)
        rooms.append(room2)
        
        tableView.delegate = self
        tableView.dataSource = self
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
        return cell
    }
    
    
}
