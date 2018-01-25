//
//  CategoryViewControllerTableViewController.swift
//  Todoey
//
//  Created by Toan Nguyen on 15.01.18.
//  Copyright © 2018 Toan Nguyen. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    // MARK: - Declare Properties
    
    var categories: Results<Category>?
    let realm = try! Realm()
    
    // MARK: - View Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
//        print("viewDidLoad 1 is called")
        loadCategory()
//        print("viewDidLoad 2 is called")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }

    // MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("numberOfRows Method is called")
        // Nil Coalescing Operator: if value = nil then change value to 1
        var rows = categories?.count ?? 1
        if categories?.isEmpty == true {
            rows = 1
        }
        return rows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
//        print("cellForRow Method is called")
        if categories?.isEmpty == true {
            print("Setting cell for empty categories")
            cell.textLabel?.text = "No categories added yet."
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.black
            cell.backgroundColor = UIColor.white
        } else {
            print("Setting cell for category with color")
            cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added yet."
            cell.accessoryType = .disclosureIndicator
            if let color = UIColor(hexString: (categories?[indexPath.row].color) ?? "00B6FA") {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        }
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if categories?.isEmpty == true {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            performSegue(withIdentifier: "goToItems", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    // MARK: - Add new categories to list
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        
        let alert = UIAlertController(title: "Add a new category", message: "", preferredStyle: .alert)
        
        let createNewCategory = UIAlertAction(title: "Add Category", style: .default) { (button) in
            let newCategory = Category()
            newCategory.name = textfield.text!
            newCategory.color = UIColor.randomFlat.hexValue()
            print("Setting color for new category: \(newCategory.color)")
            self.save(category: newCategory)
            print("List in CategoryVC is: \(String(describing: self.listIsEmpty))")
            print("Added \(newCategory.name) to list")
        }
        
        alert.addAction(createNewCategory)
        
        alert.addTextField { (closureTextfield) in
            closureTextfield.placeholder = "Add New Category"
            textfield = closureTextfield
        }
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Database Methods
    
    // Save Items
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
            print("Category saved")
            listIsEmpty = categories!.isEmpty
        } catch {
            print("Saving category error: \(error)")
        }
        tableView.reloadData()
        
    }
    
    // Load Items
    func loadCategory() {
        print("Loading Categories from realm")
        categories = realm.objects(Category.self).sorted(byKeyPath: "dateAdded", ascending: true)
        listIsEmpty = categories!.isEmpty
        print("CategoryList is empty: \(String(describing: listIsEmpty))")
        tableView.reloadData()
    }
    
    // Delete Items
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categories?[indexPath.row] {
            do {
                print("\(category.name) deleted")
                try self.realm.write {
                    self.realm.delete(category)
                }
                listIsEmpty = categories!.isEmpty
            } catch {
                print("Could not delete category")
            }
        }
    }

}

