// PennyWiseSwift/PennyWiseTests/PDFParserTests.swift
import XCTest
import PDFKit
@testable import PennyWise

final class PDFParserTests: XCTestCase {

    func test_parseText_extractsTransaction() {
        let text = """
        Date        Description             Amount  Dr/Cr
        15/03/2026  ZOMATO ORDER            299.00  Dr
        16/03/2026  SALARY CREDIT         50000.00  Cr
        17/03/2026  UBER RIDE               150.00  Dr
        """
        let results = PDFParser.parseText(text)
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[0].title, "ZOMATO ORDER")
        XCTAssertEqual(results[0].amount, 299.0)
        XCTAssertEqual(results[0].type, .expense)
        XCTAssertEqual(results[1].type, .income)
        XCTAssertEqual(results[1].amount, 50000.0)
    }

    func test_malformedLines_areSkipped() {
        let text = """
        garbage line with no numbers
        15/03/2026  VALID ENTRY  500.00  Dr
        another garbage line
        """
        let results = PDFParser.parseText(text)
        XCTAssertEqual(results.count, 1)
    }

    func test_categoryPrediction_applied() {
        let text = "15/03/2026  ZOMATO ORDER  299.00  Dr"
        let results = PDFParser.parseText(text)
        XCTAssertEqual(results.first?.category, "food")
    }
}
