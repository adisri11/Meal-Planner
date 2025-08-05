//
//  Meals.swift
//  Meal Planner
//
//  Created by Aditi  on 8/2/25.
//

import Foundation

struct MealResponse: Codable {
    let meals: [Meal]?
}

struct Meal: Codable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String
}
