//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Toan Nguyen on 19.01.18.
//  Copyright © 2018 Toan Nguyen. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    var listIsEmpty: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        // Removes hairline/shadow of navigation bar
        navigationController?.hidesNavigationBarHairline = true
    }
    
    // MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("cellForRow Method is called")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        return cell
    }
    // MARK: - SwipeCellKit Methods
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
//        print("editActionsOptions Method is called")
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive(automaticallyDelete: false)
        return options
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//        print("editActions Method is called")
        guard orientation == .right else { return nil }
        if listIsEmpty == true {
            return []
        } else {
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                print("number of rows != 1 oder listIsEmpty = false")
                // Update model
                self.updateModel(at: indexPath)
                
                // Coordinate table view update animations
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                if self.listIsEmpty == true {
                    tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .right)
                    print("List is now empty")
                }
                action.fulfill(with: .delete)
                self.tableView.endUpdates()
            }
            deleteAction.image = UIImage(named: "trash-icon")
            return [deleteAction]
        }
    }
    
    func updateModel(at indexPath: IndexPath) {
        // Update our data model by overriding this method in CategoryVC/ToDoListVC
    }

}
