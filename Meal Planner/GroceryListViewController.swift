//
//  GroceryListViewController.swift
//  Meal Planner
//
//  Created by Aditi  on 8/6/25.
//

import UIKit

class GroceryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var groceryItems: [String] = []
    var checkedItems: Set<String> = []
    
    private let checkedItemsKey = "checkedItemsKey"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Grocery List"
        tableView.dataSource = self
        tableView.delegate = self
        
        loadCheckedItems()
        reorderItems()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groceryItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryCell", for: indexPath)
        let item = groceryItems[indexPath.row]
        
        cell.textLabel?.text = item
        
        if checkedItems.contains(item) {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = .gray
        } else {
            cell.accessoryType = .none
            cell.textLabel?.textColor = .label
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = groceryItems[indexPath.row]
        
        if checkedItems.contains(item) {
            checkedItems.remove(item)
        } else {
            checkedItems.insert(item)
        }
        
        saveCheckedItems()
        reorderItems()
        tableView.reloadData()
    }
    
    private func reorderItems() {
        let unchecked = groceryItems.filter { !checkedItems.contains($0) }
        let checked = groceryItems.filter { checkedItems.contains($0) }
        groceryItems = unchecked + checked
    }
    
    /// Save checked items to UserDefaults
    private func saveCheckedItems() {
        let array = Array(checkedItems)
        UserDefaults.standard.set(array, forKey: checkedItemsKey)
    }
    
    /// Load checked items from UserDefaults
    private func loadCheckedItems() {
        if let savedArray = UserDefaults.standard.array(forKey: checkedItemsKey) as? [String] {
            checkedItems = Set(savedArray)
        }
    }


}
