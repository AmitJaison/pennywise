import { createContext, useContext, useState, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useUser } from './UserContext';

const TransactionContext = createContext();

export const TransactionProvider = ({ children }) => {
  const [transactions, setTransactions] = useState([]);
  const { user } = useUser();

  // Load transactions whenever user changes
  useEffect(() => {
    if (user?.id) {
      loadTransactions();
    } else {
      setTransactions([]); // Clear transactions when no user is logged in
    }
  }, [user?.id]);

  const loadTransactions = async () => {
    try {
      const key = `transactions_${user.id}`;
      const storedTransactions = await AsyncStorage.getItem(key);
      if (storedTransactions) {
        setTransactions(JSON.parse(storedTransactions));
      } else {
        setTransactions([]); // Initialize empty array for new users
      }
    } catch (error) {
      console.error('Error loading transactions:', error);
      setTransactions([]);
    }
  };

  const saveTransactions = async (newTransactions) => {
    try {
      const key = `transactions_${user.id}`;
      await AsyncStorage.setItem(key, JSON.stringify(newTransactions));
      setTransactions(newTransactions);
    } catch (error) {
      console.error('Error saving transactions:', error);
    }
  };

  const addTransaction = async (newTransaction) => {
    if (!user?.id) return; // Prevent adding transactions if no user is logged in
    
    const updatedTransactions = [
      {
        ...newTransaction,
        userId: user.id, // Add user ID to transaction
        createdAt: new Date().toISOString()
      },
      ...transactions
    ];
    await saveTransactions(updatedTransactions);
  };

  const updateTransaction = async (updatedTransaction) => {
    if (!user?.id) return;

    const updatedTransactions = transactions.map(t => 
      t.id === updatedTransaction.id ? { ...updatedTransaction, userId: user.id } : t
    );
    await saveTransactions(updatedTransactions);
  };

  const deleteTransaction = async (transactionId) => {
    if (!user?.id) return;

    const updatedTransactions = transactions.filter(t => t.id !== transactionId);
    await saveTransactions(updatedTransactions);
  };

  // Clear transactions on logout
  const clearTransactions = () => {
    setTransactions([]);
  };

  const importHistoricalTransactions = async (transactions) => {
    try {
      // Validate and format transactions
      const formattedTransactions = transactions.map(t => ({
        ...t,
        id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
        imported: true
      }));

      // Merge with existing transactions
      const updatedTransactions = [...transactions, ...formattedTransactions];
      
      // Sort by date
      updatedTransactions.sort((a, b) => new Date(b.date) - new Date(a.date));

      // Save to storage
      await saveTransactions(updatedTransactions);
      
      return true;
    } catch (error) {
      console.error('Error importing transactions:', error);
      throw error;
    }
  };

  return (
    <TransactionContext.Provider value={{
      transactions,
      addTransaction,
      updateTransaction,
      deleteTransaction,
      clearTransactions
    }}>
      {children}
    </TransactionContext.Provider>
  );
};

export const useTransactions = () => useContext(TransactionContext); 