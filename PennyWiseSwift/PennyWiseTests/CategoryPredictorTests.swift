// PennyWiseSwift/PennyWiseTests/CategoryPredictorTests.swift
import XCTest
@testable import PennyWise

final class CategoryPredictorTests: XCTestCase {
    func test_food_keywords() {
        XCTAssertEqual(CategoryPredictor.predict(title: "Zomato order"), "food")
        XCTAssertEqual(CategoryPredictor.predict(title: "Starbucks coffee"), "food")
    }

    func test_transport_keywords() {
        XCTAssertEqual(CategoryPredictor.predict(title: "Uber ride"), "transport")
        XCTAssertEqual(CategoryPredictor.predict(title: "Petrol"), "transport")
    }

    func test_unknown_returns_other() {
        XCTAssertEqual(CategoryPredictor.predict(title: "xyz12345"), "other")
    }

    func test_all_categories_covered() {
        XCTAssertEqual(CategoryPredictor.allCategories.count, 13)
    }
}
