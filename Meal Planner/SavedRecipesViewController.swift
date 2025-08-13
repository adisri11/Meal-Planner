//
//  SavedRecipesViewController.swift
//  Meal Planner
//
//  Created by Aditi  on 8/12/25.
//

import UIKit

class SavedRecipesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var savedMeals: [Meal] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        savedMeals = SavedRecipesManager.shared.getSavedRecipes()
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedMeals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedMealCell", for: indexPath)
        cell.textLabel?.text = savedMeals[indexPath.row].strMeal
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMeal = savedMeals[indexPath.row]
        performSegue(withIdentifier: "ShowMealDetails", sender: selectedMeal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMealDetails",
           let detailVC = segue.destination as? MealDetailViewController,
           let meal = sender as? Meal {
            detailVC.mealID = meal.idMeal
        }
        else if segue.identifier == "ShowGroceryList",
                let groceryVC = segue.destination as? GroceryListViewController,
                let groceryItems = sender as? [String] {
            groceryVC.groceryItems = groceryItems
        }
    }

}
