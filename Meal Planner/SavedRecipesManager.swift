import Foundation

class SavedRecipesManager {
    static let shared = SavedRecipesManager()
    private let savedRecipesKey = "savedRecipes"
    private init() {}

    func getSavedRecipes() -> [Meal] {
        guard let data = UserDefaults.standard.data(forKey: savedRecipesKey) else {
            print("📭 No saved recipes found in UserDefaults")
            return []
        }
        do {
            let decoded = try JSONDecoder().decode([Meal].self, from: data)
            print("📥 Loaded \(decoded.count) saved recipes")
            return decoded
        } catch {
            print("❌ Failed to decode saved recipes:", error)
            return []
        }
    }

    func saveAllRecipes(_ meals: [Meal]) {
        do {
            let encoded = try JSONEncoder().encode(meals)
            UserDefaults.standard.set(encoded, forKey: savedRecipesKey)
            print("💾 Saved \(meals.count) recipes to UserDefaults")
        } catch {
            print("❌ Failed to encode/save recipes:", error)
        }
    }

    func saveRecipe(_ meal: Meal) {
        var current = getSavedRecipes()
        if !current.contains(meal) {
            current.append(meal)
            saveAllRecipes(current)
        }
    }

    func removeRecipe(_ meal: Meal) {
        var current = getSavedRecipes()
        current.removeAll { $0.idMeal == meal.idMeal }
        saveAllRecipes(current)
    }
}

