// PennyWiseSwift/PennyWise/Utils/CurrencyFormatter.swift
import Foundation

enum CurrencyFormatter {
    private static let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "INR"
        f.locale = Locale(identifier: "en_IN")
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 2
        return f
    }()

    // @MainActor ensures single-threaded access — NumberFormatter is not thread-safe
    @MainActor
    static func format(_ amount: Double) -> String {
        formatter.string(from: NSNumber(value: amount)) ?? "₹0.00"
    }
}
