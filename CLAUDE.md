# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
npm start           # Start Expo development server
npm run android     # Build and run on Android
npm run ios         # Build and run on iOS
npm run web         # Start web version
```

No lint or test scripts are configured.

## Architecture

**PennyWise** is a React Native / Expo expense tracker targeting iOS, Android, and web.

### Navigation

There is no React Navigation library. Screen routing is done manually in `App.js` via a `currentScreen` state variable. Screens are rendered conditionally based on this state. Auth flow: SignIn ↔ SignUp → Dashboard.

### State Management

Two React Context providers (no Redux/Zustand):

- **`UserContext`** (`src/context/UserContext.js`) — authentication state, `signIn()`, `signUp()`, `signOut()`. Persists to AsyncStorage.
- **`TransactionContext`** (`src/context/TransactionContext.js`) — CRUD for transactions, stored per-user as `transactions_${user.id}` in AsyncStorage. Also handles PDF bank statement imports.

Access via custom hooks: `useUser()` and `useTransactions()`.

### Data Persistence

AsyncStorage only — no backend, no remote API.

### Key Utilities

- **`src/utils/categoryPredictor.js`** — keyword-based category prediction (`predictCategory(title)`), category icons (`getCategoryIcon`), and colors (`getCategoryColor`). 13 categories: food, transport, shopping, entertainment, bills, health, education, groceries, loans, insurance, family, investment, other.
- **`src/utils/formatCurrency.js`** — formats amounts in INR (Indian Rupees).
- **`src/utils/pdfProcessor.js`** — extracts transactions from PDF bank statements, including password-protected PDFs.
- **`src/utils/categories.js`** — category definitions with icons and subcategories.

### Screen / Component Split

- `src/screens/` — full-screen views (Dashboard, SignIn, SignUp, PIN flows)
- `src/components/` — modal and UI components used within screens (AddTransactionModal, PassbookModal, SpendingAnalysisModal, ImportPassbook, BottomNavBar, etc.)

### PDF Import Flow

`ImportPassbook` component → `pdfProcessor.js` → `TransactionContext.addTransaction()` in batch. `ImportProgressModal` tracks progress. Uses `expo-document-picker`, `expo-file-system`, and `react-native-pdf`.

### Biometric Auth

`expo-local-authentication` is configured in `app.json` with Android biometric permissions. PIN screens (`SetPINScreen`, `PINVerificationScreen`, `PINCode` component) are implemented but the auth flow integration point is in `src/screens/AuthScreen.js`.

### EAS Build

`eas.json` defines three profiles: `development`, `preview`, `production`. Project ID: `acc1302e-366a-499c-a92b-55203935e012`.
