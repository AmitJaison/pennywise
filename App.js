import { useState, useEffect } from 'react';
import { StatusBar } from 'expo-status-bar';
import { ActivityIndicator } from 'react-native';
import { UserProvider, useUser } from './src/context/UserContext';
import { TransactionProvider } from './src/context/TransactionContext';
import DashboardScreen from './src/screens/DashboardScreen';
import SignInScreen from './src/screens/SignInScreen';
import SignUpScreen from './src/screens/SignUpScreen';

const AppContent = () => {
  const [currentScreen, setCurrentScreen] = useState('checking');
  const { user, isLoading } = useUser();

  useEffect(() => {
    if (isLoading) {
      setCurrentScreen('checking');
    } else if (!user) {
      setCurrentScreen('signin');
    } else {
      setCurrentScreen('dashboard');
    }
  }, [user, isLoading]);

  const handleSignInSuccess = () => {
    setCurrentScreen('dashboard');
  };

  const handleSignUpSuccess = () => {
    setCurrentScreen('dashboard');
  };

  if (currentScreen === 'checking') {
    return <ActivityIndicator size="large" color="#2ecc71" />;
  }

  return (
    <>
      <StatusBar style="auto" />
      {renderScreen()}
    </>
  );

  function renderScreen() {
    switch (currentScreen) {
      case 'signin':
        return (
          <SignInScreen 
            onSignInSuccess={handleSignInSuccess}
            onSignUpPress={() => setCurrentScreen('signup')}
          />
        );
      case 'signup':
        return (
          <SignUpScreen 
            onSignUpSuccess={handleSignUpSuccess}
            onBack={() => setCurrentScreen('signin')}
          />
        );
      case 'dashboard':
        return (
          <DashboardScreen 
            onLogout={() => setCurrentScreen('signin')}
          />
        );
      default:
        return null;
    }
  }
};

export default function App() {
  return (
    <UserProvider>
      <TransactionProvider>
        <AppContent />
      </TransactionProvider>
    </UserProvider>
  );
}
