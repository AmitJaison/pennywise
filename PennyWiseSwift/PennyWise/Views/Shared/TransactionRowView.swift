import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(categoryColor.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay { Text(categoryIcon).font(.title3) }

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title).font(.subheadline.weight(.medium)).lineLimit(1)
                Text(transaction.category.capitalized).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(amountString)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(transaction.type == .expense ? .red : .green)
                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var amountString: String {
        let prefix = transaction.type == .expense ? "-" : "+"
        return prefix + CurrencyFormatter.format(transaction.amount)
    }

    private var categoryIcon: String {
        switch transaction.category {
        case "food": return "🍔"
        case "transport": return "🚗"
        case "shopping": return "🛍️"
        case "entertainment": return "🎬"
        case "bills": return "📄"
        case "health": return "❤️"
        case "education": return "📚"
        case "groceries": return "🛒"
        case "loans": return "💰"
        case "insurance": return "🛡️"
        case "family": return "👨‍👩‍👧"
        case "investment": return "📈"
        default: return "💸"
        }
    }

    private var categoryColor: Color {
        switch transaction.category {
        case "food": return .orange
        case "transport": return .blue
        case "shopping": return .purple
        case "entertainment": return .pink
        case "bills": return .yellow
        case "health": return .red
        case "education": return .indigo
        case "groceries": return .green
        case "loans": return .brown
        case "insurance": return .teal
        case "family": return .mint
        case "investment": return .cyan
        default: return .gray
        }
    }
}
