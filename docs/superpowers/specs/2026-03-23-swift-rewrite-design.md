# PennyWise — Swift Rewrite Design Spec
**Date:** 2026-03-23
**Scope:** Full iOS rewrite of the React Native/Expo PennyWise expense tracker
**Platform:** iOS only (Android deferred)

---

## Overview

Rewrite PennyWise as a native Swift/SwiftUI app. Feature-parity with the existing React Native app. No third-party dependencies — use Apple-native frameworks throughout.

---

## Architecture

**Pattern:** MVVM
- Views are SwiftUI structs — purely declarative, no logic
- ViewModels are `@Observable` classes — hold state, drive business logic
- Models are SwiftData `@Model` classes — define persistence schema
- `AppState` is a top-level `@Observable` class injected via `.environment()` into the view hierarchy. It holds `isAuthenticated: Bool` and `currentUserID: UUID?`. `PennyWiseApp.swift` reads it to gate between `AuthView` and `MainTabView`.

---

## Tech Stack

| Concern | Solution |
|---|---|
| UI | SwiftUI |
| Persistence | SwiftData |
| Credentials & PIN | Keychain (Security framework) |
| Biometrics | LocalAuthentication framework |
| PDF import | PDFKit |
| Navigation | NavigationStack + `.sheet()` / `.fullScreenCover()` |
| Minimum iOS | iOS 17 (required for SwiftData + `@Observable`) |

---

## Data Models (SwiftData)

### TransactionType

```swift
// String-backed enum. SwiftData persists this via rawValue storage — NOT via Codable.
// Codable conformance is included only for JSON export convenience.
enum TransactionType: String, Codable, CaseIterable {
    case expense
    case income
}
```

### User
```swift
@Model class User {
    @Attribute(.unique) var id: UUID
    var name: String
    @Attribute(.unique) var email: String  // unique — prevents Keychain key collision on sign-up
    // Password hash stored in Keychain keyed by "password-\(email)"
    // PIN hash stored in Keychain keyed by "pin-\(id.uuidString)" — nil if not set
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var transactions: [Transaction]

    init(name: String, email: String) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.createdAt = Date()
        self.transactions = []
    }
}
```

### Transaction
```swift
@Model class Transaction {
    @Attribute(.unique) var id: UUID
    var title: String
    var amount: Double        // always positive; sign derived from `type`
    var type: TransactionType // .expense or .income
    var category: String      // one of the 13 canonical categories (see below)
    var date: Date
    var user: User

    init(title: String, amount: Double, type: TransactionType,
         category: String, date: Date, user: User) {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.type = type
        self.category = category
        self.date = date
        self.user = user
    }
}
```

`amount` is always stored as a positive value. `type` determines whether it's income or expense. Display as negative for expenses, positive for income. Balance = sum of income amounts − sum of expense amounts.

---

## Canonical Category List (13)

Source of truth: the `categoryPredictor.js` keyword map. Subcategories from `categories.js` are dropped in the Swift rewrite — category is a flat string.

```
food, transport, shopping, entertainment, bills,
health, education, groceries, loans, insurance,
family, investment, other
```

---

## Session Persistence

On sign-in or sign-up, the active user's `id` (UUID string) is written to `UserDefaults` under the key `"activeUserID"`. On cold launch, `AppState` reads this key; if present, it performs a SwiftData fetch for the matching `User` and sets `isAuthenticated = true`. On sign-out, the key is deleted.

---

## Navigation Structure

```
PennyWiseApp
├── AuthView                    (AppState.isAuthenticated == false)
│   ├── SignInView
│   └── SignUpView
└── MainTabView                 (AppState.isAuthenticated == true)
    ├── DashboardView           (tab 1)
    │   ├── ExpenseSummaryView
    │   ├── RecentTransactionsView
    │   └── TransactionFormSheet (add/edit — .sheet)
    ├── PassbookView            (tab 2)
    │   ├── TransactionRowView
    │   └── ImportView          (.sheet — file picker + progress)
    └── AnalysisView            (tab 3)
```

---

## ViewModels

### AuthViewModel

```swift
@Observable class AuthViewModel {
    func signIn(email: String, password: String) throws
    func signUp(name: String, email: String, password: String) throws
    func signOut()
    func authenticateWithBiometrics() async -> Bool
    func setPIN(_ pin: String)           // stores SHA-256(pin) in Keychain under "pin-\(userID)"
    func verifyPIN(_ pin: String) -> Bool
    func hasPIN() -> Bool
}
```

Password and PIN are both stored as SHA-256 hashes in Keychain using `CryptoKit` (`SHA256.hash(data:)`). Biometric authentication uses `LAContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics)` and, on success, auto-signs in the user whose ID is in `UserDefaults`.

### TransactionViewModel

```swift
struct MonthlySummary {
    var balance: Double
    var totalIncome: Double
    var totalExpenses: Double
}

struct CategoryBreakdown {
    var category: String
    var total: Double
    var percentage: Double
}

@Observable class TransactionViewModel {
    func add(title: String, amount: Double, type: TransactionType, category: String, date: Date)
    func update(_ transaction: Transaction, title: String, amount: Double, type: TransactionType, category: String, date: Date)
    func delete(_ transaction: Transaction)
    func transactions(for month: Date) -> [Transaction]                           // all transactions in same calendar month/year as `month`
    func transactions(for month: Date, query: String) -> [Transaction]            // filtered by title or category (case-insensitive contains); empty query returns all
    func recentTransactions(limit: Int = 10) -> [Transaction]
    func summary(for month: Date) -> MonthlySummary
    func categoryBreakdown(for month: Date) -> [CategoryBreakdown]
}
```

`for month: Date` — match on `Calendar.current.component(.month)` and `.year` of the given date.

### ImportViewModel

```swift
struct ParsedTransaction {
    var title: String
    var amount: Double
    var type: TransactionType
    var date: Date
    var category: String      // predicted via CategoryPredictor
}

@Observable class ImportViewModel {
    var progress: Double = 0.0
    var isImporting: Bool = false

    // transactionViewModel is injected at init
    init(transactionViewModel: TransactionViewModel) { ... }

    func importPDF(url: URL, password: String?) async throws -> [ParsedTransaction]
    func commitImport(_ transactions: [ParsedTransaction])  // calls transactionViewModel.add() for each
}
```

`PDFParser.swift` extracts raw text from each PDF page via `PDFKit`, then applies regex to identify lines matching a transaction pattern (date + description + amount). This is best-effort — malformed lines are silently skipped. Each parsed record runs through `CategoryPredictor.predict(title:)` to assign a category.

---

## Utilities

### KeychainHelper.swift
```swift
// store(value: Data, key: String)
// load(key: String) -> Data?
// delete(key: String)
```

### CategoryPredictor.swift
Port of `categoryPredictor.js`. `predict(title: String) -> String` returns one of the 13 canonical categories based on keyword matching.

### CurrencyFormatter.swift
Hardcoded to `en-IN` locale and `INR` currency. `format(_ amount: Double) -> String`.

### PDFParser.swift
Takes a `PDFDocument` and returns `[ParsedTransaction]`. Password-protected documents are unlocked via `PDFDocument.unlock(withPassword:)`.

---

## Authentication Flow (including PIN)

1. **Cold launch** — `AppState` checks `UserDefaults["activeUserID"]`. If found:
   - If biometrics available → show biometric prompt.
     - **Success** → go to `MainTabView`.
     - **Failure or cancellation** (Face ID denied, cancelled, locked out) → fall through: show PIN entry if `hasPIN()`, else show `SignInView`.
   - If no biometrics → show PIN entry if `hasPIN()`, else show `SignInView`.
   - If `activeUserID` not found → show `SignInView`.
2. **Sign in** — email + password → hash + compare → set `activeUserID` in `UserDefaults`.
3. **Sign up** — create `User` in SwiftData → store password hash in Keychain → set `activeUserID`.
4. **Set PIN** — after sign-in/up, user may optionally set a PIN. Stored as SHA-256 hash in Keychain.
5. **Sign out** — delete `UserDefaults["activeUserID"]`, go to `AuthView`.

---

## Project Structure

```
PennyWise/
├── PennyWiseApp.swift          # App entry, modelContainer, AppState env injection
├── AppState.swift              # @Observable — isAuthenticated, currentUserID
├── Models/
│   ├── User.swift
│   ├── Transaction.swift
│   └── TransactionType.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── TransactionViewModel.swift
│   └── ImportViewModel.swift
├── Views/
│   ├── Auth/
│   │   ├── AuthView.swift
│   │   ├── SignInView.swift
│   │   └── SignUpView.swift
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   ├── ExpenseSummaryView.swift
│   │   └── RecentTransactionsView.swift
│   ├── Passbook/
│   │   └── PassbookView.swift
│   ├── Analysis/
│   │   └── AnalysisView.swift
│   └── Shared/
│       ├── TransactionFormSheet.swift  # used by both Dashboard and Passbook
│       ├── ImportView.swift            # file picker + progress UI; presented as .sheet from PassbookView
│       ├── TransactionRowView.swift
│       ├── MonthPickerView.swift       # interface: @Binding<Date> selectedMonth
│       └── PINEntryView.swift
├── Utils/
│   ├── CategoryPredictor.swift
│   ├── CurrencyFormatter.swift
│   ├── KeychainHelper.swift
│   └── PDFParser.swift
└── Resources/
    └── Assets.xcassets
```

---

## Out of Scope (Initial Rewrite)

- Android support
- iCloud sync
- Charts/graphs (list-based analysis only)
- Backend / remote API

---

## Success Criteria

1. All features working: auth (email/password + biometrics + PIN), CRUD transactions, category prediction, date picker, passbook search/filter, spending analysis, PDF import
2. App runs fully standalone — no Metro bundler
3. No third-party dependencies
4. Builds and runs on iOS 17+
