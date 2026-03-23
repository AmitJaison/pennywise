// PennyWiseSwift/PennyWise/Utils/PDFParser.swift
import Foundation
import PDFKit

enum PDFParser {

    static func parse(document: PDFDocument) -> [ParsedTransaction] {
        var fullText = ""
        for i in 0..<document.pageCount {
            fullText += document.page(at: i)?.string ?? ""
            fullText += "\n"
        }
        return parseText(fullText)
    }

    // Internal — also called by tests
    static func parseText(_ text: String) -> [ParsedTransaction] {
        var results: [ParsedTransaction] = []
        let lines = text.components(separatedBy: .newlines)
        let pattern = #"(\d{1,2}[/\-]\d{1,2}[/\-]\d{2,4})\s+(.+?)\s+([\d,]+\.?\d*)\s*(Dr|Cr|DR|CR)?"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return results
        }

        for line in lines {
            let range = NSRange(line.startIndex..., in: line)
            guard let match = regex.firstMatch(in: line, range: range),
                  let dateRange = Range(match.range(at: 1), in: line),
                  let descRange = Range(match.range(at: 2), in: line),
                  let amtRange  = Range(match.range(at: 3), in: line) else { continue }

            let dateStr = String(line[dateRange]).trimmingCharacters(in: .whitespaces)
            let desc    = String(line[descRange]).trimmingCharacters(in: .whitespaces)
            let amtStr  = String(line[amtRange]).replacingOccurrences(of: ",", with: "")

            guard let date   = parseDate(dateStr),
                  let amount = Double(amtStr),
                  !desc.isEmpty else { continue }

            var txType: TransactionType = .expense
            if match.range(at: 4).location != NSNotFound,
               let crRange = Range(match.range(at: 4), in: line),
               String(line[crRange]).uppercased() == "CR" {
                txType = .income
            }

            results.append(ParsedTransaction(
                title: desc,
                amount: amount,
                type: txType,
                date: date,
                category: CategoryPredictor.predict(title: desc)
            ))
        }
        return results
    }

    // MARK: - Date Parsing

    private static let formats = [
        "dd/MM/yyyy", "dd-MM-yyyy", "MM/dd/yyyy",
        "yyyy-MM-dd", "dd MMM yyyy", "dd/MM/yy"
    ]

    private static func parseDate(_ string: String) -> Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_IN")
        for format in formats {
            f.dateFormat = format
            if let d = f.date(from: string) { return d }
        }
        return nil
    }
}
