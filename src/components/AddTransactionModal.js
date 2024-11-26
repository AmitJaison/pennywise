import { useState, useEffect } from 'react';
import {
  Modal,
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  KeyboardAvoidingView,
  Platform,
  Alert
} from 'react-native';
import { useTransactions } from '../context/TransactionContext';
import { predictCategory } from '../utils/categoryPredictor';
import ImportPassbook from './ImportPassbook';

const AddTransactionModal = ({ visible, onClose, editingTransaction = null }) => {
  const [activeTab, setActiveTab] = useState('manual');
  const [title, setTitle] = useState('');
  const [amount, setAmount] = useState('');
  const [type, setType] = useState('expense');
  const [category, setCategory] = useState('');
  const { addTransaction, updateTransaction } = useTransactions();

  // Set initial values if editing
  useEffect(() => {
    if (editingTransaction) {
      setTitle(editingTransaction.title);
      setAmount(Math.abs(editingTransaction.amount).toString());
      setType(editingTransaction.amount < 0 ? 'expense' : 'income');
      setCategory(editingTransaction.category);
    }
  }, [editingTransaction]);

  // Auto-predict category when title changes
  useEffect(() => {
    if (title.trim()) {
      const predicted = predictCategory(title);
      setCategory(predicted);
    }
  }, [title]);

  const resetForm = () => {
    setTitle('');
    setAmount('');
    setType('expense');
    setCategory('');
    setActiveTab('manual');
  };

  const handleClose = () => {
    resetForm();
    onClose();
  };

  const handleSubmit = () => {
    if (!title || !amount) {
      Alert.alert('Error', 'Please fill in all required fields');
      return;
    }

    const transaction = {
      id: editingTransaction?.id || Date.now().toString(),
      title,
      amount: type === 'expense' ? -Number(amount) : Number(amount),
      category,
      date: new Date().toISOString().split('T')[0]
    };

    if (editingTransaction) {
      updateTransaction(transaction);
    } else {
      addTransaction(transaction);
    }

    handleClose();
  };

  return (
    <Modal
      visible={visible}
      animationType="slide"
      transparent={true}
      onRequestClose={handleClose}
    >
      <SafeAreaView style={styles.modalContainer}>
        <KeyboardAvoidingView
          behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
          style={styles.keyboardView}
        >
          <View style={styles.modalContent}>
            <View style={styles.header}>
              <Text style={styles.title}>
                {editingTransaction ? 'Edit Transaction' : 'Add Transaction'}
              </Text>
              <TouchableOpacity onPress={handleClose}>
                <Text style={styles.closeButton}>✕</Text>
              </TouchableOpacity>
            </View>

            {!editingTransaction && (
              <View style={styles.tabs}>
                <TouchableOpacity
                  style={[styles.tab, activeTab === 'manual' && styles.activeTab]}
                  onPress={() => setActiveTab('manual')}
                >
                  <Text style={[styles.tabText, activeTab === 'manual' && styles.activeTabText]}>
                    Manual Entry
                  </Text>
                </TouchableOpacity>
                <TouchableOpacity
                  style={[styles.tab, activeTab === 'import' && styles.activeTab]}
                  onPress={() => setActiveTab('import')}
                >
                  <Text style={[styles.tabText, activeTab === 'import' && styles.activeTabText]}>
                    Import Statement
                  </Text>
                </TouchableOpacity>
              </View>
            )}

            {activeTab === 'manual' ? (
              <>
                <View style={styles.typeSelector}>
                  <TouchableOpacity
                    style={[styles.typeButton, type === 'expense' && styles.selectedType]}
                    onPress={() => setType('expense')}
                  >
                    <Text style={[styles.typeText, type === 'expense' && styles.selectedTypeText]}>
                      Expense
                    </Text>
                  </TouchableOpacity>
                  <TouchableOpacity
                    style={[styles.typeButton, type === 'income' && styles.selectedType]}
                    onPress={() => setType('income')}
                  >
                    <Text style={[styles.typeText, type === 'income' && styles.selectedTypeText]}>
                      Income
                    </Text>
                  </TouchableOpacity>
                </View>

                <TextInput
                  style={styles.input}
                  placeholder="Title"
                  value={title}
                  onChangeText={setTitle}
                />

                <TextInput
                  style={styles.input}
                  placeholder="Amount (₹)"
                  value={amount}
                  onChangeText={setAmount}
                  keyboardType="numeric"
                />

                <TextInput
                  style={styles.input}
                  placeholder="Category (Auto-predicted)"
                  value={category}
                  onChangeText={setCategory}
                />

                <TouchableOpacity
                  style={styles.submitButton}
                  onPress={handleSubmit}
                >
                  <Text style={styles.submitButtonText}>
                    {editingTransaction ? 'Update' : 'Add'} Transaction
                  </Text>
                </TouchableOpacity>
              </>
            ) : (
              <ImportPassbook onClose={handleClose} />
            )}
          </View>
        </KeyboardAvoidingView>
      </SafeAreaView>
    </Modal>
  );
};

const styles = StyleSheet.create({
  modalContainer: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
  },
  keyboardView: {
    flex: 1,
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: '#fff',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    padding: 20,
    maxHeight: '90%',
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
  typeSelector: {
    flexDirection: 'row',
    marginBottom: 20,
  },
  typeButton: {
    flex: 1,
    padding: 10,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#ddd',
  },
  selectedType: {
    backgroundColor: '#2ecc71',
    borderColor: '#2ecc71',
  },
  typeText: {
    color: '#666',
  },
  selectedTypeText: {
    color: '#fff',
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    padding: 15,
    borderRadius: 8,
    marginBottom: 15,
    fontSize: 16,
  },
  submitButton: {
    backgroundColor: '#2ecc71',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
  },
  submitButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  categoryContainer: {
    marginBottom: 15,
  },
  categoryInput: {
    marginBottom: 5,
  },
  predictedCategory: {
    fontSize: 12,
    color: '#666',
    fontStyle: 'italic',
    paddingLeft: 5,
  },
  tabs: {
    flexDirection: 'row',
    marginBottom: 20,
    borderRadius: 8,
    backgroundColor: '#f0f0f0',
    padding: 4,
  },
  tab: {
    flex: 1,
    paddingVertical: 8,
    alignItems: 'center',
    borderRadius: 6,
  },
  activeTab: {
    backgroundColor: '#fff',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowOpacity: 0.2,
    shadowRadius: 1.41,
    elevation: 2,
  },
  tabText: {
    fontSize: 14,
    color: '#666',
  },
  activeTabText: {
    color: '#2ecc71',
    fontWeight: '500',
  },
});

export default AddTransactionModal; 