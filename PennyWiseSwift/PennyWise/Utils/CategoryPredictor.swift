// PennyWiseSwift/PennyWise/Utils/CategoryPredictor.swift
import Foundation

enum CategoryPredictor {
    static let allCategories = [
        "food", "transport", "shopping", "entertainment", "bills",
        "health", "education", "groceries", "loans", "insurance",
        "family", "investment", "other"
    ]

    // Ordered — first match wins. Priority order is intentional.
    private static let keywords: [(String, [String])] = [
        ("food", ["restaurant", "cafe", "coffee", "pizza", "burger", "food", "eat",
                  "lunch", "dinner", "breakfast", "snack", "zomato", "swiggy",
                  "dominos", "mcdonalds", "kfc", "starbucks", "meal", "hotel"]),
        ("transport", ["uber", "ola", "taxi", "auto", "bus", "metro", "train",
                       "fuel", "petrol", "diesel", "parking", "toll", "cab", "rapido",
                       "flight", "airline"]),
        ("groceries", ["grocery", "supermarket", "bigbasket", "blinkit", "zepto",
                       "vegetables", "fruits", "dairy", "milk", "bread", "mart"]),
        ("shopping", ["amazon", "flipkart", "myntra", "mall", "shop", "store",
                      "purchase", "cloth", "fashion", "apparel", "shoes"]),
        ("entertainment", ["netflix", "spotify", "prime", "movie", "theatre", "cinema",
                           "game", "music", "subscription", "youtube", "hotstar", "disney"]),
        ("bills", ["electricity", "water", "internet", "wifi", "mobile", "recharge",
                   "dth", "bill", "utility", "broadband", "gas", "phone", "rent",
                   "maintenance", "cable"]),
        ("health", ["hospital", "doctor", "medicine", "pharmacy", "clinic", "medical",
                    "health", "gym", "fitness", "wellness", "apollo", "1mg",
                    "dental", "checkup"]),
        ("education", ["school", "college", "course", "book", "study", "tuition",
                       "fee", "udemy", "coursera", "education", "university", "training",
                       "workshop", "class"]),
        ("loans", ["emi", "loan", "credit", "repay", "installment", "mortgage"]),
        ("insurance", ["insurance", "premium", "lic", "policy", "cover", "renewal"]),
        ("family", ["family", "gift", "birthday", "wedding", "festival", "diwali",
                    "christmas", "child", "kid", "parent", "mother", "father",
                    "anniversary"]),
        ("investment", ["mutual fund", "sip", "stocks", "zerodha", "groww",
                        "investment", "gold", "fd", "ppf", "nps", "shares",
                        "demat", "trading", "savings"])
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
