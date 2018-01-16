//
//  CategoryViewControllerTableViewController.swift
//  Todoey
//
//  Created by Toan Nguyen on 15.01.18.
//  Copyright © 2018 Toan Nguyen. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    // MARK: - Declare Properties
    
    var categoryArray = [Category]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Loading Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategory()
    }

    // MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
        
    }
    
    // MARK: - Add new categories to list
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        let category = Category(context: self.context)
        let alert = UIAlertController(title: "Add a new category", message: "Please type in your new category", preferredStyle: .alert)
        
        let createNewCategory = UIAlertAction(title: "Add", style: .default) { (button) in
            category.name = textfield.text!
            self.categoryArray.append(category)
            print(category)
            self.saveCategory()
        }
        
        alert.addAction(createNewCategory)
        
        alert.addTextField { (closureTextfield) in
            textfield = closureTextfield
        }
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Database Methods
    
    func saveCategory() {
        do {
            try context.save()
            print("Category saved")
        } catch {
            print("Saving category error: \(error)")
        }
        tableView.reloadData()
        
    }
    
    func loadCategory() {
        let result: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            try categoryArray = context.fetch(result)
            print("Categories loaded")
        } catch {
            print("Loading categories errors: \(error)")
        }
    }
    
}
