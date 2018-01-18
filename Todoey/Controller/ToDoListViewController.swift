//
//  ViewController.swift
//  Todoey
//
//  Created by Toan Nguyen on 08.01.18.
//  Copyright © 2018 Toan Nguyen. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {
    
    //MARK: - Declare Properties
    
    @IBOutlet weak var searchBar: UISearchBar!
    var toDoItems: Results<Item>?
    let realm = try! Realm()
    var selectedCategory: Category? {
        // if selectedCategory gets set then loadItems()
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchBar.delegate = self
        tableView.rowHeight = 80.0
        navigationItem.largeTitleDisplayMode = .never
    }

    //MARK: - TableView Datasource Methods / numberOfRowsInSelection, cellForRow
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = toDoItems?.count ?? 1
        if toDoItems?.isEmpty == true {
            rows = 1
        }
        return rows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        if toDoItems?.isEmpty == true {
            cell.textLabel?.text = "No items added yet."
        } else {
            if let item = toDoItems?[indexPath.row] {
                cell.textLabel?.text = item.title
                //Ternary Operator: value = condition ? valueOfTrue : valueOfFalse
                cell.accessoryType = item.done ? .checkmark : .none
            } else {
                cell.textLabel?.text = "No items added"
            }
        }
        return cell
    }
        
    //MARK: - Swipe Cell Methods
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            if let item = self.toDoItems?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(item)
                    }
                    print("Item deleted")
                    completionHandler(true)
                    self.tableView.reloadData()
                } catch {
                    print("Could not delete item")
                }
            }
        }
        delete.image = UIImage(named: "trash-icon")
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    //MARK: - TableView Delegate Methods / DidSelectRow
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status: ", error)
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add new items to itemArray
    @IBAction func addButtonPresed(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        
        //"Declare" PopUp
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        //"Declare" Button and Add Textfield Input to List
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    //Save new item to realm
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textfield.text!
                        print(textfield.text!)
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving context: \(error)")
                }
            }
            self.tableView.reloadData()
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
    
    //MARK: - Model Manipulation Methods

    //Load items
    func loadItems() {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "dateAdded", ascending: true)
        tableView.reloadData()
    }

}

//MARK: - Searchbar Delegate Methods

extension ToDoListViewController: UISearchBarDelegate {

    //Add Cancel Button to Search Bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        loadItems()
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchInputLength = searchBar.text?.count {
            if searchInputLength == 0 {
                loadItems()
                //Searchbar should no longer be the thing that is currently selected
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                }
            } else {
                toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
                tableView.reloadData()
            }
        }
    }

}

