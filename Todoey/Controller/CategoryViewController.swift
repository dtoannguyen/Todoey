//
//  CategoryViewControllerTableViewController.swift
//  Todoey
//
//  Created by Toan Nguyen on 15.01.18.
//  Copyright © 2018 Toan Nguyen. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    // MARK: - Declare Properties
    
    var categories: Results<Category>?
    let realm = try! Realm()
    
    // MARK: - Loading Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategory()
    }

    // MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Nil Coalescing Operator: if value = nil then change value to 1
        var rows = categories?.count ?? 1
        if categories?.isEmpty == true {
            rows = 1
        }
        return rows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
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
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
}
