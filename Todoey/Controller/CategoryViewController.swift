//
//  CategoryViewControllerTableViewController.swift
//  Todoey
//
//  Created by Toan Nguyen on 15.01.18.
//  Copyright © 2018 Toan Nguyen. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: UITableViewController {
    
    // MARK: - Declare Properties
    
    var categories: Results<Category>?
    let realm = try! Realm()
    
    // MARK: - Loading Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad 1 is called")
        loadCategory()
        print("viewDidLoad 2 is called")
        tableView.rowHeight = 80.0
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }

    // MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRows Method is called")
        //Nil Coalescing Operator: if value = nil then change value to 1
        var rows = categories?.count ?? 1
        if categories?.isEmpty == true {
            rows = 1
        }
        return rows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRow Method is called")
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        if categories?.isEmpty == true {
            cell.textLabel?.text = "No categories added yet."
        } else {
            cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added yet."
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if categories?.isEmpty == true {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            performSegue(withIdentifier: "goToItems", sender: self)
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
        
        let alert = UIAlertController(title: "Add a new category", message: "Please type in your new category", preferredStyle: .alert)
        
        let createNewCategory = UIAlertAction(title: "Add", style: .default) { (button) in
            let newCategory = Category()
            newCategory.name = textfield.text!
            print(newCategory)
            self.save(category: newCategory)
        }
        
        alert.addAction(createNewCategory)
        
        alert.addTextField { (closureTextfield) in
            textfield = closureTextfield
        }
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Database Methods
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
                print("Category saved")
            }
        } catch {
            print("Saving category error: \(error)")
        }
        tableView.reloadData()
        
    }
    
    func loadCategory() {
        print("Loading Categories from realm")
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
}

// MARK: - SwipeCellKit Methods
extension CategoryViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        print("editActionsOptions Method is called")
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive(automaticallyDelete: false)
        return options
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        print("editActions Method is called")
        guard orientation == .right else { return nil }
        

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // Update model
            if self.categories?.isEmpty == true {
                print("categories are already empty")
                self.tableView.beginUpdates()
                action.fulfill(with: .reset)
                self.tableView.endUpdates()
            } else {
                if let category = self.categories?[indexPath.row] {
                    do {
                        print("\(category.name) deleted")
                        try self.realm.write {
                            self.realm.delete(category)
                        }
                    } catch {
                        print("Could not delete category")
                    }

                    // Coordinate table view update animations
                    self.tableView.beginUpdates()
                    if self.categories?.isEmpty == true {
                        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .right)
                    }
                    action.fulfill(with: .delete)
                    self.tableView.endUpdates()
                }
            }
        }
        deleteAction.image = UIImage(named: "trash-icon")
        return [deleteAction]
    }
    

}
