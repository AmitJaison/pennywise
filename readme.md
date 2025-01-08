# ExpenseTracker

## Overview
ExpenseTracker is a comprehensive mobile application built with React Native and Expo that helps users track their daily expenses and manage their budget efficiently. The app features PIN-based authentication, transaction categorization with AI prediction, and PDF passbook import functionality.

## Features
- 🔐 Secure PIN-based Authentication
- 💰 Add, edit, and delete transactions
- 📊 Smart expense categorization with AI prediction
- 📱 Modern and intuitive user interface
- 📈 Spending analysis and reports
- 📑 PDF passbook import functionality
- 📅 Monthly expense tracking
- 💾 Local storage with AsyncStorage

## Tech Stack
- React Native
- Expo
- React Context for state management
- AsyncStorage for local data persistence
- Expo Document Picker for PDF handling
- React Native PDF for document processing
- Expo Local Authentication for security

## Prerequisites
- Node.js (v14 or higher)
- npm or yarn
- Expo CLI (`npm install -g expo-cli`)
- iOS Simulator (for Mac) or Android Studio (for Android development)

## Installation
1. Clone the repository:
    ```sh
    git clone https://github.com/yourusername/ExpenseTracker.git
    ```
2. Navigate to the project directory:
    ```sh
    cd ExpenseTracker
    ```
3. Install dependencies:
    ```sh
    npm install
    ```
4. Start the development server:
    ```sh
    npm start
    ```
5. Run on your preferred platform:
    - Press `a` for Android
    - Press `i` for iOS
    - Scan QR code with Expo Go app on your physical device

## Project Structure
```
src/
├── components/      # Reusable UI components
├── screens/         # Application screens
├── context/         # React Context providers
└── utils/          # Helper functions and utilities
```

## Key Features Implementation
- **Authentication**: Implements PIN-based authentication with local storage
- **Transaction Management**: Full CRUD operations for expenses
- **Smart Categorization**: AI-powered category prediction for transactions
- **PDF Import**: Support for importing bank statements
- **Data Visualization**: Spending analysis with visual representations

## Contributing
1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Environment Setup
1. Create a `.env` file in the root directory (if using environment variables)
2. Configure your environment variables

## Troubleshooting
- Ensure all dependencies are properly installed
- Clear npm cache if facing installation issues: `npm cache clean --force`
- For iOS, make sure CocoaPods are installed: `cd ios && pod install`

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments
- Expo team for the amazing framework
- React Native community for the robust ecosystem