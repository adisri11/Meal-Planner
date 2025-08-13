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
    var selectedCategories: [String] = []
    var recipeCount: Int = 1
    
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
            guard let self = self else { return }
            
            // ✅ Deduplicate by idMeal
            let uniqueMeals = Array(Set(fetchedMeals))
            
            // ✅ Shuffle
            self.meals = uniqueMeals.shuffled()
            
            // ✅ Limit to requested number (max 10)
            let limit = min(self.recipeCount, 10, self.meals.count)
            self.meals = Array(self.meals.prefix(limit))
            
            print("✅ Showing \(self.meals.count) random recipes")
            
            // ✅ Save automatically
            SavedRecipesManager.shared.saveAllRecipes(self.meals)
            
            self.tableView.reloadData()
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
        func parseMeasurement(_ measurement: String) -> (value: Double?, unit: String) {
            let parts = measurement.split(separator: " ", maxSplits: 1).map { String($0) }
            guard !parts.isEmpty else { return (nil, "") }
            
            // Try to parse number (whole, decimal, fraction, or mixed)
            let numberPart = parts[0]
            let value = parseNumber(numberPart)
            let unit = parts.count > 1 ? parts[1] : ""
            return (value, unit)
        }
        
        func parseNumber(_ text: String) -> Double? {
            // Handle mixed numbers like "1 1/2"
            if text.contains(" ") {
                let comps = text.split(separator: " ")
                if comps.count == 2,
                   let whole = Double(comps[0]),
                   let frac = parseFraction(String(comps[1])) {
                    return whole + frac
                }
            }
            // Handle fractions like "1/2"
            if let frac = parseFraction(text) {
                return frac
            }
            // Handle normal doubles
            return Double(text)
        }
        
        func parseFraction(_ text: String) -> Double? {
            let comps = text.split(separator: "/")
            if comps.count == 2,
               let numerator = Double(comps[0]),
               let denominator = Double(comps[1]),
               denominator != 0 {
                return numerator / denominator
            }
            return nil
        }
        
        let firstParsed = parseMeasurement(first)
        let secondParsed = parseMeasurement(second)
        
        // Only merge if both have numbers and same unit
        if let v1 = firstParsed.value,
           let v2 = secondParsed.value,
           firstParsed.unit.lowercased() == secondParsed.unit.lowercased() {
            let sum = v1 + v2
            return "\(sum.cleanString()) \(firstParsed.unit)"
        }
        
        // Fallback: just append
        return "\(first), \(second)"
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
            print("🛠 Passing mealID: \(meal.idMeal) to MealDetailViewController")
        }
        else if segue.identifier == "ShowGroceryList",
                let groceryVC = segue.destination as? GroceryListViewController,
                let groceryItems = sender as? [String] {
            groceryVC.groceryItems = groceryItems
        }
    }

}

private extension Double {
    func cleanString() -> String {
        return self.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(self))
            : String(self)
    }
}
