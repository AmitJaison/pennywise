import { useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useTransactions } from '../context/TransactionContext';
import SpendingAnalysisModal from './SpendingAnalysisModal';
import PassbookModal from './PassbookModal';

const BottomNavBar = ({ onAddPress }) => {
  const [analysisVisible, setAnalysisVisible] = useState(false);
  const [passbookVisible, setPassbookVisible] = useState(false);
  const { transactions } = useTransactions();

  const calculateDailyAverage = () => {
    if (transactions.length === 0) return 0;

    const expenses = transactions
      .filter(t => t.amount < 0)
      .map(t => Math.abs(t.amount));
    
    const totalExpense = expenses.reduce((sum, amount) => sum + amount, 0);

    // Get unique dates from transactions
    const uniqueDates = new Set(transactions.map(t => t.date));
    const numberOfDays = uniqueDates.size || 1;

    return totalExpense / numberOfDays;
  };

  const getSpendingPattern = () => {
    if (transactions.length === 0) return 'No data';

    const categories = {};
    transactions
      .filter(t => t.amount < 0)
      .forEach(t => {
        categories[t.category] = (categories[t.category] || 0) + Math.abs(t.amount);
      });

    const topCategory = Object.entries(categories)
      .sort(([,a], [,b]) => b - a)[0];

    return topCategory ? `Most spent on ${topCategory[0]}` : 'No pattern';
  };

  return (
    <>
      <View style={styles.container}>
        <TouchableOpacity 
          style={styles.section}
          onPress={() => setPassbookVisible(true)}
        >
          <Text style={styles.label}>Passbook</Text>
          <Text style={styles.value}>View All</Text>
        </TouchableOpacity>

        <TouchableOpacity 
          style={styles.addButton}
          onPress={onAddPress}
        >
          <Text style={styles.addButtonText}>+</Text>
        </TouchableOpacity>

        <TouchableOpacity 
          style={styles.section}
          onPress={() => setAnalysisVisible(true)}
        >
          <Text style={styles.label}>Analysis</Text>
          <Text style={styles.value}>View Stats</Text>
        </TouchableOpacity>
      </View>

      <SpendingAnalysisModal 
        visible={analysisVisible}
        onClose={() => setAnalysisVisible(false)}
      />

      <PassbookModal
        visible={passbookVisible}
        onClose={() => setPassbookVisible(false)}
      />
    </>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    backgroundColor: '#fff',
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderTopWidth: 1,
    borderTopColor: '#eee',
    height: 80,
  },
  section: {
    flex: 1,
    alignItems: 'center',
  },
  label: {
    fontSize: 12,
    color: '#666',
    marginBottom: 4,
  },
  value: {
    fontSize: 14,
    fontWeight: '600',
    color: '#2ecc71',
  },
  addButton: {
    backgroundColor: '#2ecc71',
    width: 56,
    height: 56,
    borderRadius: 28,
    justifyContent: 'center',
    alignItems: 'center',
    marginHorizontal: 20,
    elevation: 5,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
  },
  addButtonText: {
    fontSize: 32,
    color: '#fff',
    marginTop: -2,
  },
});

export default BottomNavBar; 