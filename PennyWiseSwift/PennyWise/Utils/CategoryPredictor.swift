// PennyWiseSwift/PennyWise/Utils/CategoryPredictor.swift
import Foundation

enum CategoryPredictor {
    static let allCategories = [
        "food", "transport", "shopping", "entertainment", "bills",
        "health", "education", "groceries", "loans", "insurance",
        "family", "investment", "other"
    ]

    private static let keywords: [String: [String]] = [
        "food": ["restaurant", "cafe", "coffee", "pizza", "burger", "food", "eat",
                 "lunch", "dinner", "breakfast", "snack", "zomato", "swiggy",
                 "dominos", "mcdonalds", "kfc", "starbucks"],
        "transport": ["uber", "ola", "taxi", "auto", "bus", "metro", "train",
                      "fuel", "petrol", "diesel", "parking", "toll", "cab", "rapido"],
        "shopping": ["amazon", "flipkart", "myntra", "mall", "shop", "store",
                     "purchase", "cloth", "fashion", "apparel", "shoes"],
        "entertainment": ["netflix", "spotify", "prime", "movie", "theatre", "cinema",
                          "game", "music", "subscription", "youtube", "hotstar"],
        "bills": ["electricity", "water", "internet", "wifi", "mobile", "recharge",
                  "dth", "bill", "utility", "broadband"],
        "health": ["hospital", "doctor", "medicine", "pharmacy", "clinic", "medical",
                   "health", "gym", "fitness", "wellness", "apollo", "1mg"],
        "education": ["school", "college", "course", "book", "study", "tuition",
                      "fee", "udemy", "coursera", "education"],
        "groceries": ["grocery", "supermarket", "bigbasket", "blinkit", "zepto",
                      "vegetables", "fruits", "dairy", "milk", "bread"],
        "loans": ["emi", "loan", "credit", "repay", "installment", "mortgage"],
        "insurance": ["insurance", "premium", "lic", "policy", "cover"],
        "family": ["family", "gift", "birthday", "wedding", "festival", "diwali",
                   "christmas", "child", "kid", "parent"],
        "investment": ["mutual fund", "sip", "stocks", "zerodha", "groww",
                       "investment", "gold", "fd", "ppf", "nps"]
    ]

    static func predict(title: String) -> String {
        let lower = title.lowercased()
        for (category, words) in keywords {
            if words.contains(where: { lower.contains($0) }) {
                return category
            }
        }
        return "other"
    }
}
