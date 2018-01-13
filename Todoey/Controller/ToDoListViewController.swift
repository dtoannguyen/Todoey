//
//  ViewController.swift
//  Todoey
//
//  Created by Toan Nguyen on 08.01.18.
//  Copyright © 2018 Toan Nguyen. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    //TODO: Declare Properties
    
    var itemArray = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataFilePath)
        // Do any additional setup after loading the view, typically from a nib.
        
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
        //Ternary Operator: value = condition ? valueOfTrue : valueOfFalse
        cell.accessoryType = item.done ? .checkmark : .none
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
            let newItem = Item(context: self.context)
            newItem.title = textfield.text!
            newItem.done = false
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
    
    //Save itemArray to CoreData and reload tableView
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        tableView.reloadData()
    }
    
    //Load items
    func loadItems() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
    }
    
}

