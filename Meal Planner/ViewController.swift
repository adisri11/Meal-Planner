//
//  ViewController.swift
//  Meal Planner
//
//  Created by Aditi  on 8/1/25.
//

import UIKit

class ViewController: UIViewController {
    

    @IBOutlet weak var saladSwitch: UISwitch!
    @IBOutlet weak var riceSwitch: UISwitch!
    @IBOutlet weak var pastaSwitch: UISwitch!
    @IBOutlet weak var vegetarianSwitch: UISwitch!
    
    
    @IBOutlet weak var recipeCountLabel: UILabel!
    @IBOutlet weak var recipeCountStepper: UIStepper!
    var maxRecipeCount: Int = 5
    
    @IBOutlet weak var createList: UIButton!
    
    
    var selectedCategories: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Meal Planner"
        recipeCountStepper.minimumValue = 1
        recipeCountStepper.maximumValue = 14
        recipeCountStepper.value = 5
        recipeCountLabel.text = "Recipes: 5"
    }
    
    
    @IBAction func recipeCountChanged(_ sender: UIStepper) {
        maxRecipeCount = Int(sender.value)
        recipeCountLabel.text = "Recipes: \(maxRecipeCount)"
    }
    
    @IBAction func createListTapped(_ sender: Any) {
        selectedCategories.removeAll()
               
           if saladSwitch.isOn { selectedCategories.append("Salad") }
           if riceSwitch.isOn { selectedCategories.append("Rice") }
           if vegetarianSwitch.isOn { selectedCategories.append("Vegetarian") }
           if pastaSwitch.isOn { selectedCategories.append("Pasta") } 
           
           if selectedCategories.isEmpty {
               print("⚠️ No categories selected")
               return
           }
           
           // Pass selected categories to MealListViewController
           performSegue(withIdentifier: "ShowMealList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "ShowMealList",
          let destinationVC = segue.destination as? MealListViewController {
           destinationVC.selectedCategories = selectedCategories
           destinationVC.recipeCount = maxRecipeCount
       }
    }
}

