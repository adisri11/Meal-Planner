//
//  ViewController.swift
//  Meal Planner
//
//  Created by Aditi  on 8/1/25.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var saladButton: UIButton!
    @IBOutlet weak var riceButton: UIButton!
    @IBOutlet weak var vegetarianButton: UIButton!
    @IBOutlet weak var noodlesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Meal Planner"
    }
    
    @IBAction func saladButtonTapped(_ sender: UIButton) {
        print("\nFetching meals for: Salad)...")
        MealAPI.fetchMealsByKeyword("Salad") { meals in
            if meals.isEmpty {
                print("No meals found for Salad.")
            } else {
                print("Fetched meals (\(meals.count)):")
                for meal in meals {
                    print("• \(meal.strMeal)")
                }
            }
        }
    }
    
    @IBAction func riceButtonTapped(_ sender: UIButton) {
        MealAPI.fetchMealsByKeyword("Rice") {meals in
            if meals.isEmpty {
                print("No meals found for Rice.")
            } else {
                print("Fetched meals (\(meals.count)):")
                for meal in meals {
                    print("• \(meal.strMeal)")
                }
            }
        }
    }
    
    @IBAction func noddlesButtonTapped(_ sender: UIButton) {
        MealAPI.fetchMealsByKeyword("Noodles") {meals in
            if meals.isEmpty {
                print("No meals found for Noodles.")
            } else {
                print("Fetched meals (\(meals.count)):")
                for meal in meals {
                    print("• \(meal.strMeal)")
                }
            }
        }
    }
    
    @IBAction func vegetarianButtonTapped(_ sender: UIButton) {
        MealAPI.fetchMealsByCategory("Vegetarian"){meals in
            if meals.isEmpty {
                print("No meals found for Vegetarian.")
            } else {
                print("Fetched meals (\(meals.count)):")
                for meal in meals {
                    print("• \(meal.strMeal)")
                }
            }
        }
    }
}

