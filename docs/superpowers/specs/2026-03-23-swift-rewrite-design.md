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

**No global app state object.** Dependencies are injected via `.environment()` and `.modelContainer()`.

---

## Tech Stack

| Concern | Solution |
|---|---|
| UI | SwiftUI |
| Persistence | SwiftData |
| Credentials | Keychain (Security framework) |
| Biometrics | LocalAuthentication framework |
| PDF import | PDFKit |
| Navigation | NavigationStack + `.sheet()` / `.fullScreenCover()` |
| Minimum iOS | iOS 17 (required for SwiftData + `@Observable`) |

---

## Data Models (SwiftData)

### User
```swift
@Model class User {
    var id: UUID
    var name: String
    var email: String
    // password hash stored in Keychain, not SwiftData
    var createdAt: Date
}
```

### Transaction
```swift
@Model class Transaction {
    var id: UUID
    var title: String
    var amount: Double        // negative = expense, positive = income
    var category: String
    var date: Date
    var user: User
}
```

---

## Navigation Structure

```
App
├── AuthView                    (not logged in)
│   ├── SignInView
│   └── SignUpView
└── MainTabView                 (logged in)
    ├── DashboardView           (tab 1)
    │   ├── ExpenseSummaryView
    │   ├── RecentTransactionsView
    │   └── TransactionFormSheet (add/edit)
    ├── PassbookView            (tab 2)
    │   └── TransactionRowView
    └── AnalysisView            (tab 3)
```

Navigation is driven by an `AppState` observable that holds `isAuthenticated`. Switching tabs uses SwiftUI's native `TabView`.

---

## ViewModels

### AuthViewModel
- `signIn(email, password)` — fetches user from SwiftData, validates password hash from Keychain
- `signUp(name, email, password)` — creates User in SwiftData, stores hashed password in Keychain
- `signOut()` — clears session
- `authenticateWithBiometrics()` — uses `LAContext` to authenticate, then auto-signs in last user

### TransactionViewModel
- `add(title, amount, type, category, date)`
- `update(transaction, ...fields)`
- `delete(transaction)`
- `transactions(for month: Date) -> [Transaction]` — filtered query
- `summary(for month: Date) -> (balance, income, expenses)`
- `categoryBreakdown(for month: Date) -> [(category, total, percent)]`

### ImportViewModel
- `importPDF(url, password?)` — extracts text from PDF via PDFKit, parses transaction lines, calls `TransactionViewModel.add()` in batch
- `progress: Double` — published for progress UI

---

## Features

### Authentication
- Email + password sign in / sign up
- Password stored as SHA-256 hash in Keychain (keyed by email)
- Biometric unlock (Face ID / Touch ID) for returning users — skips password entry
- PIN screen deferred (not in initial rewrite)

### Transactions
- Add / edit / delete
- Fields: title, amount, type (expense/income), category, date (DatePicker)
- Auto category prediction from title keywords (port existing `categoryPredictor.js` logic to Swift)
- 13 categories: food, transport, shopping, entertainment, bills, health, education, groceries, loans, insurance, family, investment, other

### Dashboard
- Header: user name + sign out button
- Monthly balance / income / expenses summary (month picker)
- Recent transactions list (last 10), swipe to delete, tap to edit

### Passbook
- Full transaction list for selected month
- Search bar (filters by title or category)
- Month picker

### Spending Analysis
- Category breakdown for selected month
- Percentage and amount per category
- Simple list view (charts optional in future)

### PDF Import
- File picker (`UIDocumentPickerViewController` via SwiftUI)
- PDFKit text extraction
- Password-protected PDF support
- Regex/line parsing to extract transaction rows
- Progress indicator during import

---

## Project Structure

```
PennyWise/
├── PennyWiseApp.swift          # App entry point, modelContainer setup
├── AppState.swift              # @Observable — isAuthenticated, currentUser
├── Models/
│   ├── User.swift
│   └── Transaction.swift
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
│   │   ├── RecentTransactionsView.swift
│   │   └── TransactionFormSheet.swift
│   ├── Passbook/
│   │   └── PassbookView.swift
│   ├── Analysis/
│   │   └── AnalysisView.swift
│   └── Shared/
│       ├── MonthPickerView.swift
│       └── TransactionRowView.swift
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
- PIN code auth
- iCloud sync
- Charts/graphs (just list-based analysis for now)
- Backend / remote API

---

## Success Criteria

1. All existing features working: auth, CRUD transactions, category prediction, date picker, passbook search/filter, spending analysis, PDF import, biometric auth
2. No Metro bundler — app runs fully standalone on device
3. No third-party dependencies
4. Xcode project builds and runs on iOS 17+
