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
    var itemArray = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist")
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(dataFilePath)
        // Do any additional setup after loading the view, typically from a nib.
        
        let item1 = Item()
        item1.title = "Eat"
        itemArray.append(item1)
        
        let item2 = Item()
        item2.title = "Take a shit"
        itemArray.append(item2)
        
        loadItems()
        
    }

    //MARK: TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
//      cell.textLabel?.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        /*Shorter Way by Using Ternary Operator for:
        if item.done == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }*/
        //Ternary Operator: value = condition ? valueOfTrue : valueOfFalse
        cell.accessoryType = item.done ? .checkmark : .none
        saveItems()
        return cell
    }
    
    
    
    //MARK: TableView Delegate Methods / DidSelectRow
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(itemArray[indexPath.row])
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Add new items to itemArray
    @IBAction func addButtonPresed(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        
        //"Declare" PopUp
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        //"Declare" Button and Add Textfield Input to List
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let newItem = Item()
            newItem.title = textfield.text!
            self.itemArray.append(newItem)
            self.saveItems()
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
    
    //MARK: Model Manipulation Methods
    
    //Save itemArray to Items.plist Using Encoding (NSCoder) and reload tableView
    func saveItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding items \(error)")
        }
        self.tableView.reloadData()
    }
    
    //Load items
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
            itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding items: \(error)")
            }
        }
    }
}

