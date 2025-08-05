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
    
    var meals: [Meal] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Find Recipes"

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self

        // Optional: Start with a default search (e.g., "noodle")
        searchForMeals(keyword: "noodle")
    }

    // Search API Call
    func searchForMeals(keyword: String) {
        MealAPI.fetchMealsByKeyword(keyword) { [weak self] meals in
            self?.meals = meals
            self?.tableView.reloadData()
        }
    }

    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else { return }
        searchForMeals(keyword: text)
        searchBar.resignFirstResponder()
    }

    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath)
        let meal = meals[indexPath.row]
        cell.textLabel?.text = meal.strMeal
        return cell
    }

    // MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMeal = meals[indexPath.row]
        performSegue(withIdentifier: "ShowMealDetail", sender: selectedMeal)
    }

    // Prepare segue to detail view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMealDetail",
           let detailVC = segue.destination as? MealDetailViewController,
           let meal = sender as? Meal {
            detailVC.mealID = meal.idMeal
        }
    }
}

