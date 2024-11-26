import { StyleSheet, View, Text, TouchableOpacity, SafeAreaView, Alert } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { useState } from 'react';
import ExpenseSummary from '../components/ExpenseSummary';
import RecentTransactions from '../components/RecentTransactions';
import AddTransactionModal from '../components/AddTransactionModal';
import BottomNavBar from '../components/BottomNavBar';
import { useUser } from '../context/UserContext';
import { useTransactions } from '../context/TransactionContext';

const DashboardScreen = ({ onLogout }) => {
  const [modalVisible, setModalVisible] = useState(false);
  const [editingTransaction, setEditingTransaction] = useState(null);
  const { user } = useUser();
  const { transactions, deleteTransaction } = useTransactions();

  const handleDeleteTransaction = (transactionId) => {
    Alert.alert(
      "Delete Transaction",
      "Are you sure you want to delete this transaction?",
      [
        {
          text: "Cancel",
          style: "cancel"
        },
        { 
          text: "Delete", 
          onPress: async () => {
            try {
              await deleteTransaction(transactionId);
            } catch (error) {
              Alert.alert('Error', 'Failed to delete transaction');
            }
          },
          style: 'destructive'
        }
      ]
    );
  };

  const handleEditTransaction = (transaction) => {
    setEditingTransaction(transaction);
    setModalVisible(true);
  };

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaView style={styles.container}>
        <View style={styles.header}>
          <Text style={styles.headerTitle}>PennyWise</Text>
          <View style={styles.headerRight}>
            <Text style={styles.userName}>{user?.name}</Text>
            <TouchableOpacity onPress={onLogout}>
              <Text style={styles.logoutText}>Logout</Text>
            </TouchableOpacity>
          </View>
        </View>

        <View style={styles.content}>
          <ExpenseSummary transactions={transactions} />
          <RecentTransactions 
            transactions={transactions}
            onDelete={handleDeleteTransaction}
            onEdit={handleEditTransaction}
          />
        </View>

        <BottomNavBar 
          onAddPress={() => {
            setEditingTransaction(null);
            setModalVisible(true);
          }}
        />

        <AddTransactionModal
          visible={modalVisible}
          onClose={() => {
            setModalVisible(false);
            setEditingTransaction(null);
          }}
          editingTransaction={editingTransaction}
        />
      </SafeAreaView>
    </GestureHandlerRootView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
  },
  headerRight: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  userName: {
    marginRight: 15,
    fontSize: 16,
    color: '#666',
  },
  logoutText: {
    color: '#e74c3c',
    fontSize: 16,
  },
  content: {
    flex: 1,
    padding: 16,
  },
});

export default DashboardScreen; 