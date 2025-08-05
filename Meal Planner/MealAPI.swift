//
//  MealAPI.swift
//  Meal Planner
//
//  Created by Aditi  on 8/2/25.
//


import Foundation

class MealAPI {
    static let baseURL = "https://www.themealdb.com/api/json/v1/1"
    
    // Fetch meals by keyword (e.g. "noodle", "rice")
    static func fetchMealsByKeyword(_ keyword: String, completion: @escaping ([Meal]) -> Void) {
        let urlString = "\(baseURL)/search.php?s=\(keyword)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching meals: \(error)")
                completion([])
                return
            }

            guard let data = data else { return }

            do {
                let response = try JSONDecoder().decode(MealResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(response.meals ?? [])
                }
            } catch {
                print("Decoding error: \(error)")
                completion([])
            }
        }.resume()
    }
    
    // Fetch meals by category (e.g. "Seafood", "Vegetarian")
    static func fetchMealsByCategory(_ category: String, completion: @escaping ([Meal]) -> Void) {
        let urlString = "\(baseURL)/filter.php?c=\(category)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching category meals: \(error)")
                completion([])
                return
            }

            guard let data = data else { return }

            do {
                let response = try JSONDecoder().decode(MealResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(response.meals ?? [])
                }
            } catch {
                print("Decoding error: \(error)")
                completion([])
            }
        }.resume()
    }

    // Fetch meal details by ID
    static func fetchMealDetails(_ mealID: String, completion: @escaping (MealDetail?) -> Void) {
        let urlString = "\(baseURL)/lookup.php?i=\(mealID)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching meal details: \(error)")
                completion(nil)
                return
            }

            guard let data = data else { return }

            do {
                let response = try JSONDecoder().decode(MealDetailResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(response.meals?.first)
                }
            } catch {
                print("Decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
