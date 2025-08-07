//
//  MealListViewController.swift
//  Meal Planner
//
//  Created by Aditi  on 8/2/25.
//

import UIKit

class MealListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var groceryList: UIButton!
    
    var meals: [Meal] = []
    var selectedCategories: [String] = [] // Passed from ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Meal List"
        tableView.delegate = self
        tableView.dataSource = self
        fetchCombinedMeals()
    }
    
    func fetchCombinedMeals() {
        meals.removeAll()
        let group = DispatchGroup()
        var fetchedMeals: [Meal] = []
        
        for category in selectedCategories {
                if category == "Rice" || category == "Salad" {
                    group.enter()
                    MealAPI.fetchMealsByKeyword(category) { keywordMeals in
                        fetchedMeals.append(contentsOf: keywordMeals)
                        group.leave()
                    }
                } else if category == "Pasta" || category == "Vegetarian" {
                    group.enter()
                    MealAPI.fetchMealsByCategory(category) { categoryMeals in
                        fetchedMeals.append(contentsOf: categoryMeals)
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) { [weak self] in
                var seenIDs = Set<String>()
                self?.meals = fetchedMeals.filter { meal in
                    if seenIDs.contains(meal.idMeal) {
                        return false
                    } else {
                        seenIDs.insert(meal.idMeal)
                        return true
                    }
                }
                
                print("✅ Deduplicated meals: \(self?.meals.count ?? 0)")
                self?.tableView.reloadData()
            }
    }


    @IBAction func groceryListTapped(_ sender: Any) {
        generateGroceryList()
    }

    func generateGroceryList() {
        let group = DispatchGroup()
        var allIngredients: [String] = []

        for meal in meals {
            group.enter()
            MealAPI.fetchMealDetails(meal.idMeal) { detail in
                if let detail = detail {
                    allIngredients.append(contentsOf: detail.ingredientsWithMeasurements)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            let combinedIngredients = self.combineIngredients(allIngredients)
            self.performSegue(withIdentifier: "ShowGroceryList", sender: combinedIngredients)
        }
    }
    
    private func combineIngredients(_ ingredients: [String]) -> [String] {
        var ingredientDict: [String: String] = [:]

        for entry in ingredients {
            let parts = entry.split(separator: "-").map { $0.trimmingCharacters(in: .whitespaces) }
            guard parts.count == 2 else { continue }

            let ingredient = parts[0]
            let measurement = parts[1]

            if let existing = ingredientDict[ingredient] {
                // Combine measurements if numeric
                let newMeasurement = mergeMeasurements(existing, measurement)
                ingredientDict[ingredient] = newMeasurement
            } else {
                ingredientDict[ingredient] = measurement
            }
        }

        // Convert back to ["Ingredient - Measurement"]
        return ingredientDict.map { "\($0.key) - \($0.value)" }.sorted()
    }
    
    private func mergeMeasurements(_ first: String, _ second: String) -> String {
        // Extract numbers if present
        let firstValue = Double(first.components(separatedBy: " ").first ?? "") ?? 0
        let secondValue = Double(second.components(separatedBy: " ").first ?? "") ?? 0
        
        if firstValue > 0 && secondValue > 0 {
            // Use unit from the first measurement
            let unit = first.replacingOccurrences(of: "\(firstValue)", with: "").trimmingCharacters(in: .whitespaces)
            return "\(firstValue + secondValue) \(unit)"
        } else {
            // If parsing fails, just append both
            return "\(first), \(second)"
        }
    }

    // TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        meals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath)
        cell.textLabel?.text = meals[indexPath.row].strMeal
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMeal = meals[indexPath.row]
        performSegue(withIdentifier: "ShowMealDetail", sender: selectedMeal)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMealDetail",
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
