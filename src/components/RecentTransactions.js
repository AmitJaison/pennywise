import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { getCategoryIcon, getCategoryColor } from '../utils/categoryPredictor';

const RecentTransactions = ({ transactions, onDelete, onEdit }) => {
  const formatAmount = (amount) => {
    return `₹${Math.abs(amount).toFixed(2)}`;
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-IN', {
      day: '2-digit',
      month: 'short'
    });
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Recent Transactions</Text>
      
      <ScrollView 
        style={styles.transactionsList}
        showsVerticalScrollIndicator={false}
      >
        {transactions.length === 0 ? (
          <Text style={styles.emptyText}>No transactions yet</Text>
        ) : (
          transactions.map((transaction) => (
            <View key={transaction.id} style={styles.transactionItem}>
              <View style={styles.transactionLeft}>
                <Text style={styles.categoryIcon}>
                  {getCategoryIcon(transaction.category)}
                </Text>
                <View>
                  <Text style={styles.transactionTitle}>{transaction.title}</Text>
                  <Text style={[
                    styles.transactionCategory,
                    { color: getCategoryColor(transaction.category) }
                  ]}>
                    {transaction.category}
                  </Text>
                  <Text style={styles.transactionDate}>
                    {formatDate(transaction.date)}
                  </Text>
                </View>
              </View>
              
              <View style={styles.transactionRight}>
                <Text style={[
                  styles.transactionAmount,
                  transaction.amount < 0 ? styles.expense : styles.income
                ]}>
                  {formatAmount(transaction.amount)}
                </Text>
                <View style={styles.actionButtons}>
                  <TouchableOpacity 
                    onPress={() => onEdit(transaction)}
                    style={styles.actionButton}
                  >
                    <Text style={styles.editButton}>Edit</Text>
                  </TouchableOpacity>
                  <TouchableOpacity 
                    onPress={() => onDelete(transaction.id)}
                    style={styles.actionButton}
                  >
                    <Text style={styles.deleteButton}>Delete</Text>
                  </TouchableOpacity>
                </View>
              </View>
            </View>
          ))
        )}
        <View style={styles.bottomPadding} />
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginTop: 16,
  },
  title: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 16,
    color: '#333',
  },
  transactionsList: {
    flex: 1,
  },
  bottomPadding: {
    height: 20,
  },
  emptyText: {
    textAlign: 'center',
    color: '#666',
    fontStyle: 'italic',
    marginTop: 20,
  },
  transactionItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  transactionLeft: {
    flex: 1,
  },
  transactionTitle: {
    fontSize: 16,
    fontWeight: '500',
    color: '#333',
    marginBottom: 4,
  },
  transactionCategory: {
    fontSize: 14,
    color: '#666',
    marginBottom: 2,
  },
  transactionDate: {
    fontSize: 12,
    color: '#999',
  },
  transactionRight: {
    alignItems: 'flex-end',
  },
  transactionAmount: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 4,
  },
  expense: {
    color: '#e74c3c',
  },
  income: {
    color: '#2ecc71',
  },
  actionButtons: {
    flexDirection: 'row',
    gap: 8,
  },
  actionButton: {
    paddingHorizontal: 8,
    paddingVertical: 4,
  },
  editButton: {
    color: '#3498db',
    fontSize: 12,
  },
  deleteButton: {
    color: '#e74c3c',
    fontSize: 12,
  },
  categoryIcon: {
    fontSize: 20,
    marginRight: 8,
  },
});

export default RecentTransactions; 