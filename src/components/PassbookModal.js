import { useState } from 'react';
import { 
  Modal, 
  View, 
  Text, 
  StyleSheet, 
  TouchableOpacity, 
  ScrollView,
  TextInput
} from 'react-native';
import { useTransactions } from '../context/TransactionContext';

const PassbookModal = ({ visible, onClose }) => {
  const { transactions } = useTransactions();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedMonth, setSelectedMonth] = useState('all');

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-IN', {
      day: '2-digit',
      month: 'short',
      year: 'numeric'
    });
  };

  const formatAmount = (amount) => {
    return `₹${Math.abs(amount).toFixed(2)}`;
  };

  const getMonths = () => {
    const months = new Set();
    transactions.forEach(t => {
      const date = new Date(t.date);
      months.add(date.toLocaleDateString('en-IN', { month: 'short', year: 'numeric' }));
    });
    return Array.from(months).sort((a, b) => 
      new Date(b.split(' ')[1] + ' ' + b.split(' ')[0]) - 
      new Date(a.split(' ')[1] + ' ' + a.split(' ')[0])
    );
  };

  const filterTransactions = () => {
    return transactions
      .filter(t => {
        // Filter by search query
        if (searchQuery) {
          const query = searchQuery.toLowerCase();
          return (
            t.title.toLowerCase().includes(query) ||
            t.category.toLowerCase().includes(query)
          );
        }
        return true;
      })
      .filter(t => {
        // Filter by month
        if (selectedMonth !== 'all') {
          const date = new Date(t.date);
          const transactionMonth = date.toLocaleDateString('en-IN', { 
            month: 'short', 
            year: 'numeric' 
          });
          return transactionMonth === selectedMonth;
        }
        return true;
      })
      .sort((a, b) => new Date(b.date) - new Date(a.date));
  };

  const calculateBalance = (transactions) => {
    return transactions.reduce((sum, t) => sum + t.amount, 0);
  };

  return (
    <Modal
      visible={visible}
      animationType="slide"
      transparent={true}
      onRequestClose={onClose}
    >
      <View style={styles.modalContainer}>
        <View style={styles.modalContent}>
          <View style={styles.header}>
            <Text style={styles.title}>Passbook</Text>
            <TouchableOpacity onPress={onClose}>
              <Text style={styles.closeButton}>✕</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.searchContainer}>
            <TextInput
              style={styles.searchInput}
              placeholder="Search transactions..."
              value={searchQuery}
              onChangeText={setSearchQuery}
            />
          </View>

          <ScrollView 
            horizontal 
            showsHorizontalScrollIndicator={false}
            style={styles.monthsContainer}
          >
            <TouchableOpacity
              style={[
                styles.monthChip,
                selectedMonth === 'all' && styles.selectedMonthChip
              ]}
              onPress={() => setSelectedMonth('all')}
            >
              <Text style={[
                styles.monthChipText,
                selectedMonth === 'all' && styles.selectedMonthChipText
              ]}>All</Text>
            </TouchableOpacity>
            {getMonths().map(month => (
              <TouchableOpacity
                key={month}
                style={[
                  styles.monthChip,
                  selectedMonth === month && styles.selectedMonthChip
                ]}
                onPress={() => setSelectedMonth(month)}
              >
                <Text style={[
                  styles.monthChipText,
                  selectedMonth === month && styles.selectedMonthChipText
                ]}>{month}</Text>
              </TouchableOpacity>
            ))}
          </ScrollView>

          <View style={styles.balanceContainer}>
            <Text style={styles.balanceLabel}>Current Balance</Text>
            <Text style={styles.balanceAmount}>
              ₹{calculateBalance(filterTransactions()).toFixed(2)}
            </Text>
          </View>

          <ScrollView style={styles.transactionsList}>
            {filterTransactions().map(transaction => (
              <View key={transaction.id} style={styles.transactionItem}>
                <View style={styles.transactionLeft}>
                  <Text style={styles.transactionTitle}>{transaction.title}</Text>
                  <Text style={styles.transactionCategory}>{transaction.category}</Text>
                  <Text style={styles.transactionDate}>
                    {formatDate(transaction.date)}
                  </Text>
                </View>
                <View style={styles.transactionRight}>
                  <Text style={[
                    styles.transactionAmount,
                    transaction.amount < 0 ? styles.expense : styles.income
                  ]}>
                    {formatAmount(transaction.amount)}
                  </Text>
                </View>
              </View>
            ))}
          </ScrollView>
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  modalContainer: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
  },
  modalContent: {
    flex: 1,
    backgroundColor: '#fff',
    marginTop: 50,
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    padding: 20,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
  },
  closeButton: {
    fontSize: 24,
    color: '#666',
  },
  searchContainer: {
    marginBottom: 15,
  },
  searchInput: {
    backgroundColor: '#f5f5f5',
    padding: 12,
    borderRadius: 8,
    fontSize: 16,
  },
  monthsContainer: {
    flexDirection: 'row',
    marginBottom: 15,
  },
  monthChip: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    backgroundColor: '#f5f5f5',
    borderRadius: 16,
    marginRight: 8,
  },
  selectedMonthChip: {
    backgroundColor: '#2ecc71',
  },
  monthChipText: {
    color: '#666',
  },
  selectedMonthChipText: {
    color: '#fff',
  },
  balanceContainer: {
    alignItems: 'center',
    marginBottom: 20,
    paddingVertical: 15,
    borderRadius: 12,
    backgroundColor: '#f9f9f9',
  },
  balanceLabel: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
  },
  balanceAmount: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2ecc71',
  },
  transactionsList: {
    flex: 1,
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
  },
  expense: {
    color: '#e74c3c',
  },
  income: {
    color: '#2ecc71',
  },
});

export default PassbookModal; 