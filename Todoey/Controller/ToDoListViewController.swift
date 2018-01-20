//
//  ViewController.swift
//  Todoey
//
//  Created by Toan Nguyen on 08.01.18.
//  Copyright © 2018 Toan Nguyen. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

protocol ChangedController {
    func backToCategoryVC()
}

class ToDoListViewController: SwipeTableViewController {
    
    //MARK: - Declare Properties
    
    @IBOutlet weak var searchBar: UISearchBar!
    var delegate: ChangedController?
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
        
        if toDoItems?.count == 0 {
            defaults.set(true, forKey: listIsEmpty)
            print("List in ToDoListVC is: \(defaults.bool(forKey: listIsEmpty))")
        } else {
            defaults.set(false, forKey: listIsEmpty)
            print("List in ToDoListVC is: \(defaults.bool(forKey: listIsEmpty))")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        navigationItem.largeTitleDisplayMode = .never
        guard let categoryColor = selectedCategory?.color else {fatalError()}
        updateNavBar(withHexCode: categoryColor)
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor(hexString: categoryColor)?.cgColor
        searchBar.barTintColor = UIColor(hexString: categoryColor)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        let originalNavBarColor = "00B6FA"
//        updateNavBar(withHexCode: originalNavBarColor)
//    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        let originalNavBarColor = "00B6FA"
        updateNavBar(withHexCode: originalNavBarColor)
        delegate?.backToCategoryVC()
    }

    // MARK: - Nav Bar Setup Methods
    func updateNavBar(withHexCode colorHexCode: String) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.") }
        guard let navBarColor = UIColor(hexString: colorHexCode) else { fatalError("Not a correct HexCode.") }
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
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
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if toDoItems?.isEmpty == true {
            cell.textLabel?.text = "No items added yet."
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.black
            cell.backgroundColor = UIColor.white
        } else {
            if let item = toDoItems?[indexPath.row] {
                cell.textLabel?.text = item.title
                //Ternary Operator: value = condition ? valueOfTrue : valueOfFalse
                cell.accessoryType = item.done ? .checkmark : .none
                if let color = navigationController?.navigationBar.barTintColor {
                    cell.backgroundColor = color.darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) * 0.35)
                    print((CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) * 0.35)
                    cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                }
            } else {
                cell.textLabel?.text = "No items added"
            }
        }
        return cell
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
                        self.defaults.set(false, forKey: self.listIsEmpty)
                        print("List in ToDoListVC is: \(self.defaults.bool(forKey: self.listIsEmpty))")
                    }
                } catch {
                    print("Error saving context: \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        //Textfield
        alert.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "Add New Item"
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
    
    //Delete items
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.toDoItems?[indexPath.row] {
            do {
                print("\(item.title) deleted")
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Could not delete item")
            }
        }
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

