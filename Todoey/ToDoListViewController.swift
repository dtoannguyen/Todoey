//
//  ViewController.swift
//  Todoey
//
//  Created by Toan Nguyen on 08.01.18.
//  Copyright © 2018 Toan Nguyen. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
    //TODO: Declare Properties
    
    //UserDefaults: An interface to the user’s defaults database, where you store key-value pairs persistently across launches of your app, allowing an app to customize its behavior to match a user’s preferences.

    let userDefault = UserDefaults.standard
    var itemArray = ["Find Mike", "Buy Eggs", "Eat"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Load saved .plist
        if let items = userDefault.array(forKey: "ToDoListArray") as? [String] {
            itemArray = items
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    //MARK: TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row]
//      cell.textLabel?.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        return cell
    }
    
    //MARK: TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(itemArray[indexPath.row])
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Add new items to list
    @IBAction func addButtonPresed(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        
        //"Declare" PopUp
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        //"Declare" Button and Add Textfield Input to List
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            self.itemArray.append(textfield.text!)
            //Save itemArray to .plist with Key
            self.userDefault.set(self.itemArray, forKey: "ToDoListArray")
            self.tableView.reloadData()
            print(textfield.text!)
        }
        //Textfield
        alert.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "Create new item"
            textfield = alertTextfield
        }
        //Add Button to PopUp
        alert.addAction(action)
        //"Init" PopUp with Button
        present(alert, animated: true, completion: nil)
    }
}

