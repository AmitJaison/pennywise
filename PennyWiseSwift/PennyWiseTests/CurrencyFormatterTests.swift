// PennyWiseSwift/PennyWiseTests/CurrencyFormatterTests.swift
import XCTest
@testable import PennyWise

final class CurrencyFormatterTests: XCTestCase {
    @MainActor
    func test_format_positive() {
        let result = CurrencyFormatter.format(1000)
        XCTAssertTrue(result.contains("1,000") || result.contains("1000"))
        XCTAssertTrue(result.contains("₹") || result.contains("INR"))
    }

    @MainActor
    func test_format_zero_contains_zero() {
        let result = CurrencyFormatter.format(0)
        XCTAssertTrue(result.contains("0"), "Zero amount should contain '0', got: \(result)")
    }

    @MainActor
    func test_format_decimal_precision() {
        let result = CurrencyFormatter.format(1000.5)
        XCTAssertTrue(result.contains("1,000.50") || result.contains("1000.50"),
                      "Expected 2 decimal places, got: \(result)")
    }
}
