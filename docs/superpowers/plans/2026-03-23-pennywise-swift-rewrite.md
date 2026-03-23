# PennyWise Swift Rewrite Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewrite PennyWise as a native SwiftUI/SwiftData iOS app with full feature parity to the React Native version.

**Architecture:** MVVM with `@Observable` ViewModels; SwiftData for persistence; Keychain + CryptoKit for credentials; `AppState` injected via `.environment()` gates auth/main navigation.

**Tech Stack:** Swift 5.9+, SwiftUI, SwiftData, LocalAuthentication, PDFKit, CryptoKit, Security framework. iOS 17+. No third-party dependencies. xcodegen for project generation.

**Spec:** `docs/superpowers/specs/2026-03-23-swift-rewrite-design.md`

**Working directory for all tasks:** `PennyWiseSwift/` (inside repo root)

---

## File Map

```
PennyWiseSwift/
├── project.yml                                  # xcodegen spec
├── PennyWise/
│   ├── PennyWiseApp.swift
│   ├── AppState.swift
│   ├── Models/
│   │   ├── TransactionType.swift
│   │   ├── User.swift
│   │   └── Transaction.swift
│   ├── ViewModels/
│   │   ├── AuthViewModel.swift
│   │   ├── TransactionViewModel.swift
│   │   └── ImportViewModel.swift
│   ├── Views/
│   │   ├── Auth/
│   │   │   ├── AuthView.swift
│   │   │   ├── SignInView.swift
│   │   │   └── SignUpView.swift
│   │   ├── Dashboard/
│   │   │   ├── DashboardView.swift
│   │   │   ├── ExpenseSummaryView.swift
│   │   │   └── RecentTransactionsView.swift
│   │   ├── Passbook/
│   │   │   └── PassbookView.swift
│   │   ├── Analysis/
│   │   │   └── AnalysisView.swift
│   │   └── Shared/
│   │       ├── MainTabView.swift
│   │       ├── TransactionFormSheet.swift
│   │       ├── ImportView.swift
│   │       ├── TransactionRowView.swift
│   │       ├── MonthPickerView.swift
│   │       └── PINEntryView.swift
│   └── Utils/
│       ├── CategoryPredictor.swift
│       ├── CurrencyFormatter.swift
│       ├── KeychainHelper.swift
│       └── PDFParser.swift
└── PennyWiseTests/
    ├── CategoryPredictorTests.swift
    ├── CurrencyFormatterTests.swift
    ├── TransactionViewModelTests.swift
    ├── AuthViewModelTests.swift
    └── PDFParserTests.swift
```

---

## Task 1: Xcode Project Scaffold

**Files:**
- Create: `PennyWiseSwift/project.yml`
- Create: `PennyWiseSwift/PennyWise/` (empty directory marker)
- Create: `PennyWiseSwift/PennyWiseTests/` (empty directory marker)

- [ ] **Step 1: Create project.yml**

```yaml
# PennyWiseSwift/project.yml
name: PennyWise
options:
  bundleIdPrefix: com.amitjaison
  deploymentTarget:
    iOS: "17.0"

settings:
  base:
    SWIFT_VERSION: "5.9"

targets:
  PennyWise:
    type: application
    platform: iOS
    sources:
      - PennyWise
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.amitjaison.pennywise
        GENERATE_INFOPLIST_FILE: YES
        INFOPLIST_KEY_NSFaceIDUsageDescription: "Use Face ID to sign in to PennyWise"
        DEVELOPMENT_TEAM: ""
        CODE_SIGN_STYLE: Automatic

  PennyWiseTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - PennyWiseTests
    dependencies:
      - target: PennyWise
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.amitjaison.pennywiseTests
```

- [ ] **Step 2: Create source directories and a placeholder to make xcodegen happy**

```bash
mkdir -p PennyWiseSwift/PennyWise/Models
mkdir -p PennyWiseSwift/PennyWise/ViewModels
mkdir -p PennyWiseSwift/PennyWise/Views/Auth
mkdir -p PennyWiseSwift/PennyWise/Views/Dashboard
mkdir -p PennyWiseSwift/PennyWise/Views/Passbook
mkdir -p PennyWiseSwift/PennyWise/Views/Analysis
mkdir -p PennyWiseSwift/PennyWise/Views/Shared
mkdir -p PennyWiseSwift/PennyWise/Utils
mkdir -p PennyWiseSwift/PennyWiseTests
```

Create `PennyWiseSwift/PennyWise/PennyWiseApp.swift` (temporary stub):

```swift
import SwiftUI

@main
struct PennyWiseApp: App {
    var body: some Scene {
        WindowGroup { Text("Loading...") }
    }
}
```

- [ ] **Step 3: Generate Xcode project**

```bash
cd PennyWiseSwift && xcodegen generate
```

Expected: `✓ Generated project at PennyWise.xcodeproj`

- [ ] **Step 4: Verify build (empty app)**

```bash
cd PennyWiseSwift && xcodebuild build -scheme PennyWise \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  -quiet 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 5: Commit**

```bash
git add PennyWiseSwift/
git commit -m "feat: scaffold native Swift iOS project with xcodegen"
```

---

## Task 2: Models

**Files:**
- Create: `PennyWiseSwift/PennyWise/Models/TransactionType.swift`
- Create: `PennyWiseSwift/PennyWise/Models/User.swift`
- Create: `PennyWiseSwift/PennyWise/Models/Transaction.swift`

No unit tests for pure data models — tested indirectly via ViewModel tests.

- [ ] **Step 1: Create TransactionType.swift**

```swift
// PennyWiseSwift/PennyWise/Models/TransactionType.swift
import Foundation

// SwiftData persists via rawValue — Codable is for JSON export only
enum TransactionType: String, Codable, CaseIterable {
    case expense
    case income
}
```

- [ ] **Step 2: Create User.swift**

```swift
// PennyWiseSwift/PennyWise/Models/User.swift
import Foundation
import SwiftData

@Model
class User {
    @Attribute(.unique) var id: UUID
    var name: String
    @Attribute(.unique) var email: String  // unique — prevents Keychain key collision
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

- [ ] **Step 3: Create Transaction.swift**

```swift
// PennyWiseSwift/PennyWise/Models/Transaction.swift
import Foundation
import SwiftData

@Model
class Transaction {
    @Attribute(.unique) var id: UUID
    var title: String
    var amount: Double      // always positive; type determines income vs expense
    var type: TransactionType
    var category: String    // one of 13 canonical categories
    var date: Date
    var userId: UUID        // denormalized for #Predicate compatibility
    var user: User

    init(title: String, amount: Double, type: TransactionType,
         category: String, date: Date, user: User) {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.type = type
        self.category = category
        self.date = date
        self.userId = user.id
        self.user = user
    }
}
```

- [ ] **Step 4: Verify build**

```bash
cd PennyWiseSwift && xcodebuild build -scheme PennyWise \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  -quiet 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 5: Commit**

```bash
git add PennyWiseSwift/
git commit -m "feat: add SwiftData models — User, Transaction, TransactionType"
```

---

## Task 3: Utilities

**Files:**
- Create: `PennyWiseSwift/PennyWise/Utils/KeychainHelper.swift`
- Create: `PennyWiseSwift/PennyWise/Utils/CurrencyFormatter.swift`
- Create: `PennyWiseSwift/PennyWise/Utils/CategoryPredictor.swift`
- Create: `PennyWiseSwift/PennyWiseTests/CategoryPredictorTests.swift`
- Create: `PennyWiseSwift/PennyWiseTests/CurrencyFormatterTests.swift`

- [ ] **Step 1: Write failing tests**

```swift
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
```

```swift
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
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd PennyWiseSwift && xcodebuild test -scheme PennyWise \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  -quiet 2>&1 | grep -E "error:|FAILED|passed"
```

Expected: build error — `CategoryPredictor` not defined.

- [ ] **Step 3: Create KeychainHelper.swift**

```swift
// PennyWiseSwift/PennyWise/Utils/KeychainHelper.swift
import Security
import Foundation

enum KeychainHelper {
    static func store(value: Data, key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: value
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        return result as? Data
    }

    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
```

- [ ] **Step 4: Create CurrencyFormatter.swift**

```swift
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

    static func format(_ amount: Double) -> String {
        formatter.string(from: NSNumber(value: amount)) ?? "₹0.00"
    }
}
```

- [ ] **Step 5: Create CategoryPredictor.swift**

```swift
// PennyWiseSwift/PennyWise/Utils/CategoryPredictor.swift
import Foundation

enum CategoryPredictor {
    static let allCategories = [
        "food", "transport", "shopping", "entertainment", "bills",
        "health", "education", "groceries", "loans", "insurance",
        "family", "investment", "other"
    ]

    private static let keywords: [String: [String]] = [
        "food": ["restaurant", "cafe", "coffee", "pizza", "burger", "food", "eat",
                 "lunch", "dinner", "breakfast", "snack", "zomato", "swiggy",
                 "dominos", "mcdonalds", "kfc", "starbucks"],
        "transport": ["uber", "ola", "taxi", "auto", "bus", "metro", "train",
                      "fuel", "petrol", "diesel", "parking", "toll", "cab", "rapido"],
        "shopping": ["amazon", "flipkart", "myntra", "mall", "shop", "store",
                     "purchase", "cloth", "fashion", "apparel", "shoes"],
        "entertainment": ["netflix", "spotify", "prime", "movie", "theatre", "cinema",
                          "game", "music", "subscription", "youtube", "hotstar"],
        "bills": ["electricity", "water", "internet", "wifi", "mobile", "recharge",
                  "dth", "bill", "utility", "broadband"],
        "health": ["hospital", "doctor", "medicine", "pharmacy", "clinic", "medical",
                   "health", "gym", "fitness", "wellness", "apollo", "1mg"],
        "education": ["school", "college", "course", "book", "study", "tuition",
                      "fee", "udemy", "coursera", "education"],
        "groceries": ["grocery", "supermarket", "bigbasket", "blinkit", "zepto",
                      "vegetables", "fruits", "dairy", "milk", "bread"],
        "loans": ["emi", "loan", "credit", "repay", "installment", "mortgage"],
        "insurance": ["insurance", "premium", "lic", "policy", "cover"],
        "family": ["family", "gift", "birthday", "wedding", "festival", "diwali",
                   "christmas", "child", "kid", "parent"],
        "investment": ["mutual fund", "sip", "stocks", "zerodha", "groww",
                       "investment", "gold", "fd", "ppf", "nps"]
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
```

- [ ] **Step 6: Run tests and verify they pass**

```bash
cd PennyWiseSwift && xcodebuild test -scheme PennyWise \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  -quiet 2>&1 | grep -E "Test.*passed|Test.*failed|error:"
```

Expected: `Test Suite 'CategoryPredictorTests' passed`, `Test Suite 'CurrencyFormatterTests' passed`

- [ ] **Step 7: Commit**

```bash
git add PennyWiseSwift/
git commit -m "feat: add utilities — KeychainHelper, CurrencyFormatter, CategoryPredictor"
```

---

## Task 4: AppState

**Files:**
- Create: `PennyWiseSwift/PennyWise/AppState.swift`

- [ ] **Step 1: Create AppState.swift**

```swift
// PennyWiseSwift/PennyWise/AppState.swift
import Foundation
import SwiftData

@Observable
class AppState {
    var isAuthenticated: Bool = false
    var currentUserID: UUID?
    var currentUser: User?

    init() {
        if let idString = UserDefaults.standard.string(forKey: "activeUserID"),
           let id = UUID(uuidString: idString) {
            self.currentUserID = id
        }
    }

    var hasSavedSession: Bool { currentUserID != nil }

    func setCurrentUser(_ user: User) {
        currentUser = user
        currentUserID = user.id
        UserDefaults.standard.set(user.id.uuidString, forKey: "activeUserID")
        isAuthenticated = true
    }

    func signOut() {
        isAuthenticated = false
        currentUser = nil
        currentUserID = nil
        UserDefaults.standard.removeObject(forKey: "activeUserID")
    }
}
```

- [ ] **Step 2: Update PennyWiseApp.swift with ModelContainer + AppState**

```swift
// PennyWiseSwift/PennyWise/PennyWiseApp.swift
import SwiftUI
import SwiftData

@main
struct PennyWiseApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .modelContainer(for: [User.self, Transaction.self])
    }
}

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        if appState.isAuthenticated {
            Text("Main App")  // replaced in Task 12
        } else {
            Text("Auth")      // replaced in Task 6
        }
    }
}
```

- [ ] **Step 3: Build**

```bash
cd PennyWiseSwift && xcodebuild build -scheme PennyWise \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  -quiet 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: Commit**

```bash
git add PennyWiseSwift/
git commit -m "feat: add AppState with session persistence via UserDefaults"
```

---

## Task 5: AuthViewModel

**Files:**
- Create: `PennyWiseSwift/PennyWise/ViewModels/AuthViewModel.swift`
- Create: `PennyWiseSwift/PennyWiseTests/AuthViewModelTests.swift`

- [ ] **Step 1: Write failing tests**

```swift
// PennyWiseSwift/PennyWiseTests/AuthViewModelTests.swift
import XCTest
import SwiftData
@testable import PennyWise

@MainActor
final class AuthViewModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var appState: AppState!
    var viewModel: AuthViewModel!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: User.self, Transaction.self,
                                       configurations: config)
        context = ModelContext(container)
        appState = AppState()
        viewModel = AuthViewModel(modelContext: context, appState: appState)
        // Clean up any test keychain entries
        KeychainHelper.delete(key: "password-test@example.com")
        KeychainHelper.delete(key: "password-dup@example.com")
    }

    override func tearDown() async throws {
        KeychainHelper.delete(key: "password-test@example.com")
        KeychainHelper.delete(key: "password-dup@example.com")
    }

    func test_signUp_createsUser_andSetsAuthenticated() throws {
        try viewModel.signUp(name: "Amit", email: "test@example.com", password: "secret")
        XCTAssertTrue(appState.isAuthenticated)
        XCTAssertEqual(appState.currentUser?.name, "Amit")
    }

    func test_signIn_withValidCredentials_succeeds() throws {
        try viewModel.signUp(name: "Amit", email: "test@example.com", password: "secret")
        appState.signOut()
        try viewModel.signIn(email: "test@example.com", password: "secret")
        XCTAssertTrue(appState.isAuthenticated)
    }

    func test_signIn_withWrongPassword_throws() throws {
        try viewModel.signUp(name: "Amit", email: "test@example.com", password: "secret")
        appState.signOut()
        XCTAssertThrowsError(try viewModel.signIn(email: "test@example.com", password: "wrong"))
    }

    func test_signUp_duplicateEmail_throws() throws {
        try viewModel.signUp(name: "Amit", email: "dup@example.com", password: "secret")
        appState.signOut()
        XCTAssertThrowsError(try viewModel.signUp(name: "Other", email: "dup@example.com", password: "pass"))
    }

    func test_signOut_clearsState() throws {
        try viewModel.signUp(name: "Amit", email: "test@example.com", password: "secret")
        viewModel.signOut()
        XCTAssertFalse(appState.isAuthenticated)
        XCTAssertNil(appState.currentUser)
    }

    func test_pin_setAndVerify() throws {
        try viewModel.signUp(name: "Amit", email: "test@example.com", password: "secret")
        let userID = appState.currentUser!.id
        viewModel.setPIN("1234", userID: userID)
        XCTAssertTrue(viewModel.hasPIN(userID: userID))
        XCTAssertTrue(viewModel.verifyPIN("1234", userID: userID))
        XCTAssertFalse(viewModel.verifyPIN("0000", userID: userID))
        KeychainHelper.delete(key: "pin-\(userID.uuidString)")
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd PennyWiseSwift && xcodebuild test -scheme PennyWise \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  -quiet 2>&1 | grep -E "error:|FAILED"
```

Expected: `error: 'AuthViewModel' is not defined`

- [ ] **Step 3: Create AuthViewModel.swift**

```swift
// PennyWiseSwift/PennyWise/ViewModels/AuthViewModel.swift
import Foundation
import SwiftData
import CryptoKit
import LocalAuthentication

enum AuthError: LocalizedError {
    case invalidCredentials
    case emailAlreadyExists
    case userNotFound

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid email or password"
        case .emailAlreadyExists: return "An account with this email already exists"
        case .userNotFound: return "Account not found"
        }
    }
}

@Observable
class AuthViewModel {
    private let modelContext: ModelContext
    private let appState: AppState

    init(modelContext: ModelContext, appState: AppState) {
        self.modelContext = modelContext
        self.appState = appState
    }

    // MARK: - Auth

    func signIn(email: String, password: String) throws {
        let lowerEmail = email.lowercased()
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.email == lowerEmail })
        guard let user = try modelContext.fetch(descriptor).first else {
            throw AuthError.invalidCredentials
        }
        let stored = KeychainHelper.load(key: "password-\(lowerEmail)") ?? Data()
        let input = Data(SHA256.hash(data: Data(password.utf8)))
        guard stored == input else { throw AuthError.invalidCredentials }
        appState.setCurrentUser(user)
    }

    func signUp(name: String, email: String, password: String) throws {
        let lowerEmail = email.lowercased()
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.email == lowerEmail })
        if let _ = try? modelContext.fetch(descriptor).first {
            throw AuthError.emailAlreadyExists
        }
        let user = User(name: name, email: lowerEmail)
        modelContext.insert(user)
        let hash = Data(SHA256.hash(data: Data(password.utf8)))
        KeychainHelper.store(value: hash, key: "password-\(lowerEmail)")
        try modelContext.save()
        appState.setCurrentUser(user)
    }

    func signOut() {
        appState.signOut()
    }

    // MARK: - Biometrics

    func authenticateWithBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                        error: &error) else { return false }
        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Sign in to PennyWise"
            )
        } catch {
            return false
        }
    }

    // MARK: - PIN

    func setPIN(_ pin: String, userID: UUID) {
        let hash = Data(SHA256.hash(data: Data(pin.utf8)))
        KeychainHelper.store(value: hash, key: "pin-\(userID.uuidString)")
    }

    func verifyPIN(_ pin: String, userID: UUID) -> Bool {
        guard let stored = KeychainHelper.load(key: "pin-\(userID.uuidString)") else { return false }
        let hash = Data(SHA256.hash(data: Data(pin.utf8)))
        return stored == hash
    }

    func hasPIN(userID: UUID) -> Bool {
        KeychainHelper.load(key: "pin-\(userID.uuidString)") != nil
    }

    // MARK: - Session Restore

    /// Call on cold launch when AppState.hasSavedSession == true.
    /// Returns true if session was restored via biometrics.
    /// Caller is responsible for showing PINEntryView if this returns false.
    func restoreSession() async -> Bool {
        guard let userID = appState.currentUserID else { return false }
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == userID })
        guard let user = (try? modelContext.fetch(descriptor))?.first else {
            appState.signOut()
            return false
        }
        if await authenticateWithBiometrics() {
            appState.setCurrentUser(user)
            return true
        }
        return false
    }
}
```

- [ ] **Step 4: Run tests and verify they pass**

```bash
cd PennyWiseSwift && xcodebuild test -scheme PennyWise \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  -quiet 2>&1 | grep -E "AuthViewModelTests.*passed|failed|error:"
```

Expected: `Test Suite 'AuthViewModelTests' passed`

- [ ] **Step 5: Commit**

```bash
git add PennyWiseSwift/
git commit -m "feat: add AuthViewModel with sign-in, sign-up, biometrics, PIN"
```

---

## Task 6: Auth Views

**Files:**
- Create: `PennyWiseSwift/PennyWise/Views/Auth/AuthView.swift`
- Create: `PennyWiseSwift/PennyWise/Views/Auth/SignInView.swift`
- Create: `PennyWiseSwift/PennyWise/Views/Auth/SignUpView.swift`
- Create: `PennyWiseSwift/PennyWise/Views/Shared/PINEntryView.swift`

- [ ] **Step 1: Create SignInView.swift**

```swift
// PennyWiseSwift/PennyWise/Views/Auth/SignInView.swift
import SwiftUI

struct SignInView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    let onSignUpTap: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "indianrupeesign.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    Text("PennyWise")
                        .font(.largeTitle.bold())
                    Text("Track your expenses")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 60)

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

                Button(action: signIn) {
                    Group {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Sign In")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(email.isEmpty || password.isEmpty ? Color.gray : Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                .padding(.horizontal)

                Button("Don't have an account? Sign up", action: onSignUpTap)
                    .font(.footnote)
                    .foregroundStyle(.blue)
            }
        }
    }

    private func signIn() {
        isLoading = true
        errorMessage = ""
        let vm = AuthViewModel(modelContext: modelContext, appState: appState)
        do {
            try vm.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
```

- [ ] **Step 2: Create SignUpView.swift**

```swift
// PennyWiseSwift/PennyWise/Views/Auth/SignUpView.swift
import SwiftUI

struct SignUpView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    let onSignInTap: () -> Void

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    var passwordsMatch: Bool { password == confirmPassword }
    var canSubmit: Bool { !name.isEmpty && !email.isEmpty && !password.isEmpty && passwordsMatch && !isLoading }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "indianrupeesign.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    Text("Create Account")
                        .font(.largeTitle.bold())
                }
                .padding(.top, 60)

                VStack(spacing: 16) {
                    TextField("Full Name", text: $name)
                        .textContentType(.name)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)

                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)

                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)

                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)

                    if !password.isEmpty && !confirmPassword.isEmpty && !passwordsMatch {
                        Text("Passwords do not match")
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
                .padding(.horizontal)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

                Button(action: signUp) {
                    Group {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Create Account")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canSubmit ? Color.blue : Color.gray)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
                .disabled(!canSubmit)
                .padding(.horizontal)

                Button("Already have an account? Sign in", action: onSignInTap)
                    .font(.footnote)
                    .foregroundStyle(.blue)
            }
        }
    }

    private func signUp() {
        isLoading = true
        errorMessage = ""
        let vm = AuthViewModel(modelContext: modelContext, appState: appState)
        do {
            try vm.signUp(name: name, email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
```

- [ ] **Step 3: Create PINEntryView.swift**

```swift
// PennyWiseSwift/PennyWise/Views/Shared/PINEntryView.swift
import SwiftUI
import SwiftData

struct PINEntryView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    let userID: UUID
    let onSuccess: () -> Void
    let onFallback: () -> Void  // user chooses to sign in with password

    @State private var pin = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Enter PIN")
                .font(.title2.bold())

            SecureField("PIN", text: $pin)
                .keyboardType(.numberPad)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal, 60)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Button("Verify PIN") { verifyPIN() }
                .disabled(pin.count < 4)
                .buttonStyle(.borderedProminent)

            Button("Use Password Instead", action: onFallback)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }

    private func verifyPIN() {
        let vm = AuthViewModel(modelContext: modelContext, appState: appState)
        if vm.verifyPIN(pin, userID: userID) {
            let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == userID })
            if let user = (try? modelContext.fetch(descriptor))?.first {
                appState.setCurrentUser(user)
                onSuccess()
            }
        } else {
            errorMessage = "Incorrect PIN"
            pin = ""
        }
    }
}
```

- [ ] **Step 4: Create AuthView.swift**

```swift
// PennyWiseSwift/PennyWise/Views/Auth/AuthView.swift
import SwiftUI

struct AuthView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var screen: Screen = .signIn

    enum Screen { case signIn, signUp, pin }

    var body: some View {
        switch screen {
        case .signIn:
            SignInView(onSignUpTap: { screen = .signUp })
        case .signUp:
            SignUpView(onSignInTap: { screen = .signIn })
        case .pin:
            if let userID = appState.currentUserID {
                PINEntryView(
                    userID: userID,
                    onSuccess: {},     // AppState.isAuthenticated handles navigation
                    onFallback: { screen = .signIn }
                )
            } else {
                SignInView(onSignUpTap: { screen = .signUp })
            }
        }
    }
    .task { await handleColdLaunch() }   // ← add this modifier in the outer view
}

// Fix: task modifier must be on the view returned by body. Restructure:
// Actually, the switch expression is the body — wrap in a Group:
```

> **Note:** `AuthView` needs a `Group` wrapper to attach `.task`. Rewrite as:

```swift
// PennyWiseSwift/PennyWise/Views/Auth/AuthView.swift
import SwiftUI

struct AuthView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var screen: Screen = .signIn

    enum Screen { case signIn, signUp, pin }

    var body: some View {
        Group {
            switch screen {
            case .signIn:
                SignInView(onSignUpTap: { screen = .signUp })
            case .signUp:
                SignUpView(onSignInTap: { screen = .signIn })
            case .pin:
                if let userID = appState.currentUserID {
                    PINEntryView(
                        userID: userID,
                        onSuccess: {},
                        onFallback: { screen = .signIn }
                    )
                } else {
                    SignInView(onSignUpTap: { screen = .signUp })
                }
            }
        }
        .task { await handleColdLaunch() }
    }

    private func handleColdLaunch() async {
        guard appState.hasSavedSession, let userID = appState.currentUserID else { return }
        let vm = AuthViewModel(modelContext: modelContext, appState: appState)
        let restored = await vm.restoreSession()
        if !restored {
            // Biometrics failed or not available
            if vm.hasPIN(userID: userID) {
                screen = .pin
            }
            // else stay on .signIn
        }
    }
}
```

- [ ] **Step 5: Update ContentView in PennyWiseApp.swift**

```swift
struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        if appState.isAuthenticated {
            Text("Main App (Task 12)")
        } else {
            AuthView()
        }
    }
}
```

- [ ] **Step 6: Build**

```bash
cd PennyWiseSwift && xcodebuild build -scheme PennyWise \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  -quiet 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 7: Commit**

```bash
git add PennyWiseSwift/
git commit -m "feat: add auth views — SignIn, SignUp, PIN, AuthView with cold-launch handling"
```

---

## Task 7: TransactionViewModel

**Files:**
- Create: `PennyWiseSwift/PennyWise/ViewModels/TransactionViewModel.swift`
- Create: `PennyWiseSwift/PennyWiseTests/TransactionViewModelTests.swift`

- [ ] **Step 1: Write failing tests**

```swift
// PennyWiseSwift/PennyWiseTests/TransactionViewModelTests.swift
import XCTest
import SwiftData
@testable import PennyWise

@MainActor
final class TransactionViewModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var viewModel: TransactionViewModel!
    var user: User!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: User.self, Transaction.self,
                                       configurations: config)
        context = ModelContext(container)
        user = User(name: "Amit", email: "amit@test.com")
        context.insert(user)
        try context.save()
        viewModel = TransactionViewModel()
        viewModel.setup(modelContext: context, user: user)
    }

    func test_add_createsTransaction() {
        viewModel.add(title: "Zomato", amount: 250, type: .expense,
                      category: "food", date: Date())
        let txns = viewModel.recentTransactions()
        XCTAssertEqual(txns.count, 1)
        XCTAssertEqual(txns.first?.title, "Zomato")
    }

    func test_delete_removesTransaction() {
        viewModel.add(title: "Zomato", amount: 250, type: .expense,
                      category: "food", date: Date())
        let txns = viewModel.recentTransactions()
        viewModel.delete(txns[0])
        XCTAssertEqual(viewModel.recentTransactions().count, 0)
    }

    func test_update_modifiesTransaction() {
        viewModel.add(title: "Old", amount: 100, type: .expense,
                      category: "other", date: Date())
        let t = viewModel.recentTransactions()[0]
        viewModel.update(t, title: "New", amount: 200, type: .income,
                         category: "food", date: Date())
        let updated = viewModel.recentTransactions()[0]
        XCTAssertEqual(updated.title, "New")
        XCTAssertEqual(updated.amount, 200)
        XCTAssertEqual(updated.type, .income)
    }

    func test_summary_calculatesCorrectly() {
        let now = Date()
        viewModel.add(title: "Salary", amount: 50000, type: .income,
                      category: "other", date: now)
        viewModel.add(title: "Rent", amount: 15000, type: .expense,
                      category: "bills", date: now)
        let summary = viewModel.summary(for: now)
        XCTAssertEqual(summary.totalIncome, 50000)
        XCTAssertEqual(summary.totalExpenses, 15000)
        XCTAssertEqual(summary.balance, 35000)
    }

    func test_search_filtersByTitle() {
        let now = Date()
        viewModel.add(title: "Zomato", amount: 250, type: .expense,
                      category: "food", date: now)
        viewModel.add(title: "Uber", amount: 100, type: .expense,
                      category: "transport", date: now)
        let results = viewModel.transactions(for: now, query: "zom")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Zomato")
    }

    func test_categoryBreakdown_percentages() {
        let now = Date()
        viewModel.add(title: "Rent", amount: 10000, type: .expense,
                      category: "bills", date: now)
        viewModel.add(title: "Food", amount: 5000, type: .expense,
                      category: "food", date: now)
        let breakdown = viewModel.categoryBreakdown(for: now)
        XCTAssertEqual(breakdown.count, 2)
        // bills = 10000/15000 = 66.67%, food = 5000/15000 = 33.33%
        let billsItem = breakdown.first { $0.category == "bills" }!
        XCTAssertEqual(billsItem.percentage, 66.67, accuracy: 0.1)
    }
}
```

- [ ] **Step 2: Run to verify failure**

```bash
cd PennyWiseSwift && xcodebuild test -scheme PennyWise \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  -quiet 2>&1 | grep "error:" | head -5
```

Expected: `error: 'TransactionViewModel' is not defined`

- [ ] **Step 3: Create TransactionViewModel.swift**

```swift
// PennyWiseSwift/PennyWise/ViewModels/TransactionViewModel.swift
import Foundation
import SwiftData

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

@Observable
class TransactionViewModel {
    var modelContext: ModelContext?
    var currentUser: User?

    func setup(modelContext: ModelContext, user: User?) {
        self.modelContext = modelContext
        self.currentUser = user
    }

    // MARK: - Date Helpers

    private func dateRange(for month: Date) -> (start: Date, end: Date) {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: month))!
        let end = cal.date(byAdding: .month, value: 1, to: start)!
        return (start, end)
    }

    // MARK: - Queries

    func transactions(for month: Date) -> [Transaction] {
        guard let modelContext, let user = currentUser else { return [] }
        let (start, end) = dateRange(for: month)
        let uid = user.id
        let descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate<Transaction> { t in
                t.userId == uid && t.date >= start && t.date < end
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func transactions(for month: Date, query: String) -> [Transaction] {
        let all = transactions(for: month)
        guard !query.isEmpty else { return all }
        let lower = query.lowercased()
        return all.filter {
            $0.title.lowercased().contains(lower) ||
            $0.category.lowercased().contains(lower)
        }
    }

    func recentTransactions(limit: Int = 10) -> [Transaction] {
        guard let modelContext, let user = currentUser else { return [] }
        let uid = user.id
        var descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate<Transaction> { t in t.userId == uid },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Aggregates

    func summary(for month: Date) -> MonthlySummary {
        let txns = transactions(for: month)
        let income = txns.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let expenses = txns.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        return MonthlySummary(balance: income - expenses,
                              totalIncome: income,
                              totalExpenses: expenses)
    }

    func categoryBreakdown(for month: Date) -> [CategoryBreakdown] {
        let txns = transactions(for: month).filter { $0.type == .expense }
        let total = txns.reduce(0.0) { $0 + $1.amount }
        guard total > 0 else { return [] }
        var grouped: [String: Double] = [:]
        for t in txns { grouped[t.category, default: 0] += t.amount }
        return grouped.map { cat, amt in
            CategoryBreakdown(category: cat, total: amt, percentage: (amt / total) * 100)
        }.sorted { $0.total > $1.total }
    }

    // MARK: - Mutations

    func add(title: String, amount: Double, type: TransactionType,
             category: String, date: Date) {
        guard let modelContext, let user = currentUser else { return }
        let t = Transaction(title: title, amount: amount, type: type,
                            category: category, date: date, user: user)
        modelContext.insert(t)
        try? modelContext.save()
    }

    func update(_ transaction: Transaction, title: String, amount: Double,
                type: TransactionType, category: String, date: Date) {
        transaction.title = title
        transaction.amount = amount
        transaction.type = type
        transaction.category = category
        transaction.date = date
        try? modelContext?.save()
    }

    func delete(_ transaction: Transaction) {
        modelContext?.delete(transaction)
        try? modelContext?.save()
    }
}
```

- [ ] **Step 4: Run tests and verify they pass**

```bash
cd PennyWiseSwift && xcodebuild test -scheme PennyWise \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  -quiet 2>&1 | grep -E "TransactionViewModelTests.*passed|failed"
```

Expected: `Test Suite 'TransactionViewModelTests' passed`

- [ ] **Step 5: Commit**

```bash
git add PennyWiseSwift/
git commit -m "feat: add TransactionViewModel with CRUD, search, summary, breakdown"
```

---

## Task 8: Shared Views

**Files:**
- Create: `PennyWiseSwift/PennyWise/Views/Shared/MonthPickerView.swift`
- Create: `PennyWiseSwift/PennyWise/Views/Shared/TransactionRowView.swift`
- Create: `PennyWiseSwift/PennyWise/Views/Shared/TransactionFormSheet.swift`

- [ ] **Step 1: Create MonthPickerView.swift**

```swift
// PennyWiseSwift/PennyWise/Views/Shared/MonthPickerView.swift
import SwiftUI

struct MonthPickerView: View {
    @Binding var selectedMonth: Date

    private var label: String {
        selectedMonth.formatted(.dateTime.month(.wide).year())
    }

    var body: some View {
        HStack {
            Button {
                selectedMonth = Calendar.current
                    .date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.blue)
            }

            Text(label)
                .font(.headline)
                .frame(minWidth: 160)

            Button {
                selectedMonth = Calendar.current
                    .date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.blue)
            }
        }
        .padding(.horizontal)
    }
}
```

- [ ] **Step 2: Create TransactionRowView.swift**

```swift
// PennyWiseSwift/PennyWise/Views/Shared/TransactionRowView.swift
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
                Text(transaction.title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Text(transaction.category.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(amountString)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(transaction.type == .expense ? .red : .green)
                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
```

- [ ] **Step 3: Create TransactionFormSheet.swift**

```swift
// PennyWiseSwift/PennyWise/Views/Shared/TransactionFormSheet.swift
import SwiftUI

struct TransactionFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: TransactionViewModel
    var editingTransaction: Transaction? = nil

    @State private var title = ""
    @State private var amount = ""
    @State private var type: TransactionType = .expense
    @State private var category = "other"
    @State private var date = Date()

    var canSave: Bool { !title.isEmpty && Double(amount) != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                        .onChange(of: title) { _, new in
                            category = CategoryPredictor.predict(title: new)
                        }

                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)

                    Picker("Type", selection: $type) {
                        Text("Expense").tag(TransactionType.expense)
                        Text("Income").tag(TransactionType.income)
                    }
                    .pickerStyle(.segmented)

                    Picker("Category", selection: $category) {
                        ForEach(CategoryPredictor.allCategories, id: \.self) { cat in
                            Text(cat.capitalized).tag(cat)
                        }
                    }

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle(editingTransaction == nil ? "Add Transaction" : "Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(!canSave)
                }
            }
            .onAppear(perform: loadIfEditing)
        }
    }

    private func loadIfEditing() {
        guard let t = editingTransaction else { return }
        title = t.title
        amount = String(t.amount)
        type = t.type
        category = t.category
        date = t.date
    }

    private func save() {
        guard let amt = Double(amount) else { return }
        if let t = editingTransaction {
            viewModel.update(t, title: title, amount: amt, type: type,
                             category: category, date: date)
        } else {
            viewModel.add(title: title, amount: amt, type: type,
                          category: category, date: date)
        }
        dismiss()
    }
}
```

- [ ] **Step 4: Build**

```bash
cd PennyWiseSwift && xcodebuild build -scheme PennyWise \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  -quiet 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 5: Commit**

```bash
git add PennyWiseSwift/
git commit -m "feat: add shared views — MonthPicker, TransactionRow, TransactionFormSheet"
```

---

## Task 9: Dashboard

**Files:**
- Create: `PennyWiseSwift/PennyWise/Views/Dashboard/ExpenseSummaryView.swift`
- Create: `PennyWiseSwift/PennyWise/Views/Dashboard/RecentTransactionsView.swift`
- Create: `PennyWiseSwift/PennyWise/Views/Dashboard/DashboardView.swift`

- [ ] **Step 1: Create ExpenseSummaryView.swift**

```swift
// PennyWiseSwift/PennyWise/Views/Dashboard/ExpenseSummaryView.swift
import SwiftUI

struct ExpenseSummaryView: View {
    let summary: MonthlySummary

    var body: some View {
        HStack(spacing: 0) {
            item(title: "Balance",
                 amount: summary.balance,
                 color: summary.balance >= 0 ? .blue : .red)
            Divider().frame(height: 40)
            item(title: "Income", amount: summary.totalIncome, color: .green)
            Divider().frame(height: 40)
            item(title: "Expenses", amount: summary.totalExpenses, color: .red)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private func item(title: String, amount: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(CurrencyFormatter.format(amount))
                .font(.system(.subheadline, design: .rounded).bold())
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
    }
}
```

- [ ] **Step 2: Create RecentTransactionsView.swift**

```swift
// PennyWiseSwift/PennyWise/Views/Dashboard/RecentTransactionsView.swift
import SwiftUI

struct RecentTransactionsView: View {
    let transactions: [Transaction]
    let onEdit: (Transaction) -> Void
    let onDelete: (Transaction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Transactions")
                .font(.headline)
                .padding(.horizontal)

            if transactions.isEmpty {
                ContentUnavailableView(
                    "No Transactions",
                    systemImage: "tray",
                    description: Text("Tap + to add your first transaction")
                )
            } else {
                ForEach(transactions) { transaction in
                    TransactionRowView(transaction: transaction)
                        .padding(.horizontal)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                onDelete(transaction)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                onEdit(transaction)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                }
            }
        }
    }
}
```

- [ ] **Step 3: Create DashboardView.swift**

```swift
// PennyWiseSwift/PennyWise/Views/Dashboard/DashboardView.swift
import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = TransactionViewModel()
    @State private var selectedMonth = Date()
    @State private var showForm = false
    @State private var editingTransaction: Transaction? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    MonthPickerView(selectedMonth: $selectedMonth)

                    ExpenseSummaryView(summary: viewModel.summary(for: selectedMonth))

                    RecentTransactionsView(
                        transactions: viewModel.recentTransactions(),
                        onEdit: { t in editingTransaction = t; showForm = true },
                        onDelete: { viewModel.delete($0) }
                    )
                }
                .padding(.vertical)
            }
            .navigationTitle("PennyWise")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if let name = appState.currentUser?.name {
                        Text("Hi, \(name)!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            editingTransaction = nil
                            showForm = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                        }
                        Button("Sign Out") { appState.signOut() }
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .sheet(isPresented: $showForm, onDismiss: { editingTransaction = nil }) {
                TransactionFormSheet(viewModel: viewModel,
                                     editingTransaction: editingTransaction)
            }
        }
        .onAppear {
            viewModel.setup(modelContext: modelContext, user: appState.currentUser)
        }
    }
}
```

- [ ] **Step 4: Build**

```bash
cd PennyWiseSwift && xcodebuild build -scheme PennyWise \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  -quiet 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 5: Commit**

```bash
git add PennyWiseSwift/
git commit -m "feat: add dashboard — ExpenseSummary, RecentTransactions, DashboardView"
```

---

## Task 10: Passbook

**Files:**
- Create: `PennyWiseSwift/PennyWise/Views/Passbook/PassbookView.swift`

- [ ] **Step 1: Create PassbookView.swift**

```swift
// PennyWiseSwift/PennyWise/Views/Passbook/PassbookView.swift
import SwiftUI

struct PassbookView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = TransactionViewModel()
    @State private var selectedMonth = Date()
    @State private var searchQuery = ""
    @State private var showImport = false
    @State private var editingTransaction: Transaction? = nil
    @State private var showEditForm = false

    var filteredTransactions: [Transaction] {
        viewModel.transactions(for: selectedMonth, query: searchQuery)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                MonthPickerView(selectedMonth: $selectedMonth)
                    .padding(.vertical, 8)

                List {
                    if filteredTransactions.isEmpty {
                        ContentUnavailableView(
                            "No Transactions",
                            systemImage: "tray",
                            description: Text(searchQuery.isEmpty ?
                                "No transactions for this month" :
                                "No results for \"\(searchQuery)\"")
                        )
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(filteredTransactions) { transaction in
                            TransactionRowView(transaction: transaction)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        viewModel.delete(transaction)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    Button {
                                        editingTransaction = transaction
                                        showEditForm = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchQuery, prompt: "Search by title or category")
            }
            .navigationTitle("Passbook")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showImport = true
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
            }
            .sheet(isPresented: $showImport) {
                ImportView(transactionViewModel: viewModel)
            }
            .sheet(isPresented: $showEditForm, onDismiss: { editingTransaction = nil }) {
                TransactionFormSheet(viewModel: viewModel,
                                     editingTransaction: editingTransaction)
            }
        }
        .onAppear {
            viewModel.setup(modelContext: modelContext, user: appState.currentUser)
        }
    }
}
```

- [ ] **Step 2: Build** (ImportView stub needed — create a temporary one)

Create `PennyWiseSwift/PennyWise/Views/Shared/ImportView.swift` with a stub:

```swift
// PennyWiseSwift/PennyWise/Views/Shared/ImportView.swift (STUB — replaced in Task 14)
import SwiftUI

struct ImportView: View {
    let transactionViewModel: TransactionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ContentUnavailableView("Import Coming Soon", systemImage: "doc.badge.plus")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}
```

```bash
cd PennyWiseSwift && xcodebuild build -scheme PennyWise \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  -quiet 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Commit**

```bash
git add PennyWiseSwift/
git commit -m "feat: add PassbookView with search, month filter, edit/delete swipe actions"
```

---

## Task 11: Analysis

**Files:**
- Create: `PennyWiseSwift/PennyWise/Views/Analysis/AnalysisView.swift`

- [ ] **Step 1: Create AnalysisView.swift**

```swift
// PennyWiseSwift/PennyWise/Views/Analysis/AnalysisView.swift
import SwiftUI

struct AnalysisView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = TransactionViewModel()
    @State private var selectedMonth = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                MonthPickerView(selectedMonth: $selectedMonth)
                    .padding(.vertical, 8)

                let summary = viewModel.summary(for: selectedMonth)
                let breakdown = viewModel.categoryBreakdown(for: selectedMonth)

                List {
                    Section {
                        HStack {
                            Text("Total Income")
                            Spacer()
                            Text(CurrencyFormatter.format(summary.totalIncome))
                                .foregroundStyle(.green).bold()
                        }
                        HStack {
                            Text("Total Expenses")
                            Spacer()
                            Text(CurrencyFormatter.format(summary.totalExpenses))
                                .foregroundStyle(.red).bold()
                        }
                        HStack {
                            Text("Balance")
                            Spacer()
                            Text(CurrencyFormatter.format(summary.balance))
                                .foregroundStyle(summary.balance >= 0 ? .blue : .red)
                                .bold()
                        }
                    }

                    Section("Expenses by Category") {
                        if breakdown.isEmpty {
                            ContentUnavailableView(
                                "No Expenses",
                                systemImage: "chart.pie",
                                description: Text("No expense data for this month")
                            )
                            .listRowBackground(Color.clear)
                        } else {
                            ForEach(breakdown, id: \.category) { item in
                                HStack {
                                    Text(item.category.capitalized)
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(CurrencyFormatter.format(item.total))
                                            .font(.subheadline.bold())
                                        Text(String(format: "%.1f%%", item.percentage))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Analysis")
        }
        .onAppear {
            viewModel.setup(modelContext: modelContext, user: appState.currentUser)
        }
    }
}
```

- [ ] **Step 2: Build**

```bash
cd PennyWiseSwift && xcodebuild build -scheme PennyWise \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  -quiet 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Commit**

```bash
git add PennyWiseSwift/
git commit -m "feat: add AnalysisView with monthly summary and category breakdown"
```

---

## Task 12: MainTabView + Wire Everything

**Files:**
- Create: `PennyWiseSwift/PennyWise/Views/Shared/MainTabView.swift`
- Modify: `PennyWiseSwift/PennyWise/PennyWiseApp.swift` (update ContentView)

- [ ] **Step 1: Create MainTabView.swift**

```swift
// PennyWiseSwift/PennyWise/Views/Shared/MainTabView.swift
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "house.fill") }

            PassbookView()
                .tabItem { Label("Passbook", systemImage: "book.fill") }

            AnalysisView()
                .tabItem { Label("Analysis", systemImage: "chart.pie.fill") }
        }
    }
}
```

- [ ] **Step 2: Update ContentView in PennyWiseApp.swift**

```swift
// PennyWiseSwift/PennyWise/PennyWiseApp.swift
import SwiftUI
import SwiftData

@main
struct PennyWiseApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .modelContainer(for: [User.self, Transaction.self])
    }
}

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        if appState.isAuthenticated {
            MainTabView()
        } else {
            AuthView()
        }
    }
}
```

- [ ] **Step 3: Full build**

```bash
cd PennyWiseSwift && xcodebuild build -scheme PennyWise \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  -quiet 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: Run on simulator to smoke-test**

```bash
open PennyWiseSwift/PennyWise.xcodeproj
```

In Xcode: select iPhone 16 Pro simulator → ▶ Run. Verify: sign up, add transactions, view passbook, view analysis.

Manually verify: sign up, add transactions, view passbook, view analysis.

- [ ] **Step 5: Commit**

```bash
git add PennyWiseSwift/
git commit -m "feat: add MainTabView and wire full app navigation"
```

---

## Task 13: PDFParser + ParsedTransaction

**Files:**
- Create: `PennyWiseSwift/PennyWise/ViewModels/ImportViewModel.swift` (ParsedTransaction struct only — full ViewModel added in Task 14)
- Create: `PennyWiseSwift/PennyWise/Utils/PDFParser.swift`
- Create: `PennyWiseSwift/PennyWiseTests/PDFParserTests.swift`

> `ParsedTransaction` must be defined before Task 13's tests compile. It is declared here and the rest of `ImportViewModel` is completed in Task 14.

- [ ] **Step 1: Create ParsedTransaction + ImportViewModel stub**

```swift
// PennyWiseSwift/PennyWise/ViewModels/ImportViewModel.swift
import Foundation

// Full ImportViewModel is added in Task 14. This file exists here so
// PDFParser and its tests can reference ParsedTransaction at compile time.

struct ParsedTransaction {
    let title: String
    let amount: Double
    let type: TransactionType
    let date: Date
    let category: String
}
```

- [ ] **Step 2: Write failing tests**

```swift
// PennyWiseSwift/PennyWiseTests/PDFParserTests.swift
import XCTest
import PDFKit
@testable import PennyWise

final class PDFParserTests: XCTestCase {

    func test_parseText_extractsTransaction() {
        // Sample bank statement text
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
```

- [ ] **Step 3: Run to verify failure**

```bash
cd PennyWiseSwift && xcodebuild test -scheme PennyWise \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  -quiet 2>&1 | grep "error:" | head -3
```

Expected: `error: 'PDFParser' is not defined`

- [ ] **Step 4: Create PDFParser.swift**

```swift
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

    // Internal — also used by tests
    static func parseText(_ text: String) -> [ParsedTransaction] {
        var results: [ParsedTransaction] = []
        let lines = text.components(separatedBy: .newlines)
        let pattern = #"(\d{1,2}[/\-]\d{1,2}[/\-]\d{2,4})\s+(.+?)\s+([\d,]+\.?\d*)\s*(Dr|Cr|DR|CR)?"#
        guard let regex = try? NSRegularExpression(pattern: pattern,
                                                    options: .caseInsensitive) else {
            return results
        }

        for line in lines {
            let range = NSRange(line.startIndex..., in: line)
            guard let match = regex.firstMatch(in: line, range: range),
                  let dateRange = Range(match.range(at: 1), in: line),
                  let descRange = Range(match.range(at: 2), in: line),
                  let amtRange  = Range(match.range(at: 3), in: line) else { continue }

            let dateStr  = String(line[dateRange]).trimmingCharacters(in: .whitespaces)
            let desc     = String(line[descRange]).trimmingCharacters(in: .whitespaces)
            let amtStr   = String(line[amtRange]).replacingOccurrences(of: ",", with: "")

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
```

- [ ] **Step 5: Run tests and verify they pass**

```bash
cd PennyWiseSwift && xcodebuild test -scheme PennyWise \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  -quiet 2>&1 | grep -E "PDFParserTests.*passed|failed"
```

Expected: `Test Suite 'PDFParserTests' passed`

- [ ] **Step 6: Commit**

```bash
git add PennyWiseSwift/
git commit -m "feat: add ParsedTransaction, PDFParser with regex extraction and category prediction"
```

---

## Task 14: ImportViewModel + ImportView

**Files:**
- Modify: `PennyWiseSwift/PennyWise/ViewModels/ImportViewModel.swift` (replace stub from Task 13 with full implementation)
- Modify: `PennyWiseSwift/PennyWise/Views/Shared/ImportView.swift` (replace stub)

- [ ] **Step 1: Replace ImportViewModel.swift with full implementation**

> `ParsedTransaction` is already defined in this file from Task 13. Replace the entire file — keep the struct, add the rest.

```swift
// PennyWiseSwift/PennyWise/ViewModels/ImportViewModel.swift
import Foundation
import PDFKit

enum ImportError: LocalizedError {
    case passwordRequired
    case fileAccessDenied
    case parsingFailed

    var errorDescription: String? {
        switch self {
        case .passwordRequired:  return "This PDF is password protected. Enter the password to continue."
        case .fileAccessDenied:  return "Could not access the selected file."
        case .parsingFailed:     return "Could not extract transactions from this PDF."
        }
    }
}

struct ParsedTransaction {
    let title: String
    let amount: Double
    let type: TransactionType
    let date: Date
    let category: String
}

@Observable
class ImportViewModel {
    var progress: Double = 0.0
    var isImporting: Bool = false

    func importPDF(url: URL, password: String?) async throws -> [ParsedTransaction] {
        isImporting = true
        progress = 0.1
        defer { isImporting = false; progress = 0 }

        guard url.startAccessingSecurityScopedResource() else {
            throw ImportError.fileAccessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }

        guard let document = PDFDocument(url: url) else {
            throw ImportError.parsingFailed
        }

        progress = 0.3

        if document.isLocked {
            guard let pwd = password, document.unlock(withPassword: pwd) else {
                throw ImportError.passwordRequired
            }
        }

        progress = 0.6
        let results = PDFParser.parse(document: document)
        progress = 1.0

        guard !results.isEmpty else { throw ImportError.parsingFailed }
        return results
    }

    func commitImport(_ transactions: [ParsedTransaction],
                      using viewModel: TransactionViewModel) {
        for t in transactions {
            viewModel.add(title: t.title, amount: t.amount, type: t.type,
                          category: t.category, date: t.date)
        }
    }
}
```

- [ ] **Step 2: Replace ImportView stub with full implementation**

```swift
// PennyWiseSwift/PennyWise/Views/Shared/ImportView.swift
import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {
    @Environment(\.dismiss) private var dismiss
    let transactionViewModel: TransactionViewModel

    @State private var importViewModel = ImportViewModel()
    @State private var showFilePicker = false
    @State private var parsedTransactions: [ParsedTransaction] = []
    @State private var showPasswordAlert = false
    @State private var pdfPassword = ""
    @State private var selectedURL: URL? = nil
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if importViewModel.isImporting {
                    VStack(spacing: 12) {
                        ProgressView(value: importViewModel.progress)
                            .padding(.horizontal)
                        Text("Parsing PDF…")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 60)
                } else if !parsedTransactions.isEmpty {
                    List(parsedTransactions, id: \.title) { t in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(t.title)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                Text(t.category.capitalized)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text((t.type == .expense ? "-" : "+") +
                                     CurrencyFormatter.format(t.amount))
                                    .foregroundStyle(t.type == .expense ? .red : .green)
                                    .font(.subheadline.bold())
                                Text(t.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Button("Import \(parsedTransactions.count) Transactions") {
                        importViewModel.commitImport(parsedTransactions,
                                                     using: transactionViewModel)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                } else {
                    Spacer()
                    ContentUnavailableView(
                        "Import Bank Statement",
                        systemImage: "doc.badge.plus",
                        description: Text("Select a PDF bank statement to import transactions")
                    )

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button("Select PDF") { showFilePicker = true }
                        .buttonStyle(.borderedProminent)
                    Spacer()
                }
            }
            .navigationTitle("Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                if !parsedTransactions.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Re-select") {
                            parsedTransactions = []
                            errorMessage = ""
                        }
                    }
                }
            }
            .fileImporter(isPresented: $showFilePicker,
                          allowedContentTypes: [.pdf]) { result in
                switch result {
                case .success(let url):
                    selectedURL = url
                    Task { await processPDF(url: url, password: nil) }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
            .alert("Password Required", isPresented: $showPasswordAlert) {
                SecureField("PDF Password", text: $pdfPassword)
                Button("Cancel", role: .cancel) {}
                Button("Unlock") {
                    if let url = selectedURL {
                        Task { await processPDF(url: url, password: pdfPassword) }
                    }
                }
            } message: {
                Text("This PDF is password protected.")
            }
        }
    }

    private func processPDF(url: URL, password: String?) async {
        errorMessage = ""
        do {
            parsedTransactions = try await importViewModel.importPDF(url: url,
                                                                      password: password)
        } catch ImportError.passwordRequired {
            showPasswordAlert = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

- [ ] **Step 3: Full build and all tests pass**

```bash
cd PennyWiseSwift && xcodebuild test -scheme PennyWise \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  -quiet 2>&1 | grep -E "passed|failed|error:"
```

Expected: All test suites pass. `** TEST SUCCEEDED **`

- [ ] **Step 4: Regenerate Xcode project (new files added)**

```bash
cd PennyWiseSwift && xcodegen generate
```

- [ ] **Step 5: Final build**

```bash
cd PennyWiseSwift && xcodebuild build -scheme PennyWise \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" \
  -quiet 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 6: Commit**

```bash
git add PennyWiseSwift/
git commit -m "feat: add ImportViewModel and ImportView — PDF import feature complete"
```

---

## Task 15: Push

- [ ] **Step 1: Push to remote**

```bash
git push origin master
```

---

## Done ✓

All features implemented:
- ✅ Email/password auth + biometrics + PIN
- ✅ CRUD transactions with category prediction and date picker
- ✅ Dashboard with monthly summary and recent transactions
- ✅ Passbook with search and month filter
- ✅ Spending analysis by category
- ✅ PDF bank statement import
- ✅ Fully standalone — no Metro bundler
- ✅ No third-party dependencies
- ✅ iOS 17+
