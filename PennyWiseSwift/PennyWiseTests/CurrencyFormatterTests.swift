// PennyWiseSwift/PennyWiseTests/CurrencyFormatterTests.swift
import XCTest
@testable import PennyWise

final class CurrencyFormatterTests: XCTestCase {
    func test_format_positive() {
        let result = CurrencyFormatter.format(1000)
        XCTAssertTrue(result.contains("1,000") || result.contains("1000"))
        XCTAssertTrue(result.contains("₹") || result.contains("INR"))
    }

    func test_format_zero() {
        XCTAssertFalse(CurrencyFormatter.format(0).isEmpty)
    }
}
