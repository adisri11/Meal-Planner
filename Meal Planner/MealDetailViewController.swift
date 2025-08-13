//
//  MealDetailViewController.swift
//  Meal Planner
//
//  Created by Aditi  on 8/2/25.
//

import UIKit

class MealDetailViewController: UIViewController {
    var mealID: String? // Passed from MealListViewController

    @IBOutlet weak var mealTitleLabel: UILabel!
    @IBOutlet weak var mealImageView: UIImageView!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var instructionsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMealDetails()
    }

    func fetchMealDetails() {
       guard let mealID = mealID else { return }
       MealAPI.fetchMealDetails(mealID) { [weak self] detail in
           guard let self = self, let detail = detail else { return }
           self.mealTitleLabel.text = detail.strMeal
           self.instructionsTextView.text = detail.strInstructions

           // Display ingredients & measurements
           let ingredientsList = detail.ingredientsWithMeasurements.joined(separator: "\n")
           self.ingredientsTextView.text = "Ingredients:\n\(ingredientsList)"

           // Load meal image
           if let url = URL(string: detail.strMealThumb) {
               DispatchQueue.global().async {
                   if let data = try? Data(contentsOf: url) {
                       DispatchQueue.main.async {
                           self.mealImageView.image = UIImage(data: data)
                       }
                   }
               }
           }
       }
   }
}
