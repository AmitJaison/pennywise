import { Modal, View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { useTransactions } from '../context/TransactionContext';

const SpendingAnalysisModal = ({ visible, onClose }) => {
  const { transactions } = useTransactions();

  const getCategoryAnalysis = () => {
    const categoryTotals = {};
    let totalSpending = 0;

    // Calculate totals for each category
    transactions
      .filter(t => t.amount < 0) // Only expenses
      .forEach(t => {
        const amount = Math.abs(t.amount);
        categoryTotals[t.category] = (categoryTotals[t.category] || 0) + amount;
        totalSpending += amount;
      });

    // Convert to array and calculate percentages
    return Object.entries(categoryTotals)
      .map(([category, amount]) => ({
        category,
        amount,
        percentage: (amount / totalSpending) * 100
      }))
      .sort((a, b) => b.amount - a.amount); // Sort by amount descending
  };

  const formatAmount = (amount) => `₹${amount.toFixed(0)}`;

  const getBarColor = (index) => {
    const colors = ['#2ecc71', '#3498db', '#e74c3c', '#f1c40f', '#9b59b6', '#1abc9c', '#e67e22', '#34495e'];
    return colors[index % colors.length];
  };

  const analysis = getCategoryAnalysis();

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
            <Text style={styles.title}>Spending Analysis</Text>
            <TouchableOpacity onPress={onClose}>
              <Text style={styles.closeButton}>✕</Text>
            </TouchableOpacity>
          </View>

          <ScrollView showsVerticalScrollIndicator={false}>
            {analysis.length === 0 ? (
              <Text style={styles.emptyText}>No spending data available</Text>
            ) : (
              <>
                <View style={styles.totalContainer}>
                  <Text style={styles.totalLabel}>Total Spending</Text>
                  <Text style={styles.totalAmount}>
                    {formatAmount(analysis.reduce((sum, cat) => sum + cat.amount, 0))}
                  </Text>
                </View>

                <View style={styles.categoriesContainer}>
                  {analysis.map((item, index) => (
                    <View key={item.category} style={styles.categoryItem}>
                      <View style={styles.categoryHeader}>
                        <Text style={styles.categoryName}>{item.category}</Text>
                        <Text style={styles.categoryAmount}>
                          {formatAmount(item.amount)}
                        </Text>
                      </View>
                      
                      <View style={styles.barContainer}>
                        <View 
                          style={[
                            styles.bar, 
                            { 
                              width: `${item.percentage}%`,
                              backgroundColor: getBarColor(index)
                            }
                          ]} 
                        />
                      </View>
                      
                      <Text style={styles.percentage}>
                        {item.percentage.toFixed(1)}%
                      </Text>
                    </View>
                  ))}
                </View>
              </>
            )}
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
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: '#fff',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    padding: 20,
    maxHeight: '80%',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
  },
  closeButton: {
    fontSize: 24,
    color: '#666',
  },
  totalContainer: {
    alignItems: 'center',
    marginBottom: 30,
  },
  totalLabel: {
    fontSize: 16,
    color: '#666',
    marginBottom: 5,
  },
  totalAmount: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#2ecc71',
  },
  categoriesContainer: {
    gap: 20,
  },
  categoryItem: {
    marginBottom: 15,
  },
  categoryHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  categoryName: {
    fontSize: 16,
    fontWeight: '500',
  },
  categoryAmount: {
    fontSize: 16,
    fontWeight: '600',
  },
  barContainer: {
    height: 8,
    backgroundColor: '#f0f0f0',
    borderRadius: 4,
    overflow: 'hidden',
    marginBottom: 4,
  },
  bar: {
    height: '100%',
    borderRadius: 4,
  },
  percentage: {
    fontSize: 12,
    color: '#666',
    textAlign: 'right',
  },
  emptyText: {
    textAlign: 'center',
    color: '#666',
    fontStyle: 'italic',
    marginTop: 20,
  },
});

export default SpendingAnalysisModal; 