import { StyleSheet, View, Text } from 'react-native';
import { formatCurrency } from '../utils/formatCurrency';

const ExpenseSummary = ({ transactions }) => {
  const calculateTotals = () => {
    return transactions.reduce(
      (acc, transaction) => {
        if (transaction.amount > 0) {
          acc.income += transaction.amount;
        } else {
          acc.expenses += Math.abs(transaction.amount);
        }
        return acc;
      },
      { income: 0, expenses: 0 }
    );
  };

  const { income, expenses } = calculateTotals();
  const balance = income - expenses;

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Total Balance</Text>
      <Text style={[styles.amount, balance < 0 && styles.negativeAmount]}>
        {formatCurrency(balance)}
      </Text>
      
      <View style={styles.statsContainer}>
        <View style={styles.statBox}>
          <Text style={styles.statLabel}>Income</Text>
          <Text style={[styles.statAmount, styles.incomeText]}>
            +{formatCurrency(income)}
          </Text>
        </View>
        <View style={styles.statBox}>
          <Text style={styles.statLabel}>Expenses</Text>
          <Text style={[styles.statAmount, styles.expenseText]}>
            -{formatCurrency(expenses)}
          </Text>
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#fff',
    padding: 20,
    margin: 16,
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  title: {
    fontSize: 16,
    color: '#666',
  },
  amount: {
    fontSize: 32,
    fontWeight: 'bold',
    marginVertical: 10,
  },
  statsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 20,
  },
  statBox: {
    flex: 1,
  },
  statLabel: {
    fontSize: 14,
    color: '#666',
  },
  statAmount: {
    fontSize: 18,
    fontWeight: '600',
    marginTop: 5,
  },
  incomeText: {
    color: '#2ecc71',
  },
  expenseText: {
    color: '#e74c3c',
  },
  negativeAmount: {
    color: '#e74c3c',
  },
});

export default ExpenseSummary; 