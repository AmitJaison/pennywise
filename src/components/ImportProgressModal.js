import { Modal, View, Text, StyleSheet, ActivityIndicator } from 'react-native';

const ImportProgressModal = ({ visible, progress }) => {
  return (
    <Modal
      visible={visible}
      transparent={true}
      animationType="fade"
    >
      <View style={styles.container}>
        <View style={styles.content}>
          <ActivityIndicator size="large" color="#2ecc71" />
          <Text style={styles.text}>Importing Transactions...</Text>
          <Text style={styles.progress}>{progress}%</Text>
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  content: {
    backgroundColor: '#fff',
    padding: 20,
    borderRadius: 12,
    alignItems: 'center',
  },
  text: {
    marginTop: 10,
    fontSize: 16,
  },
  progress: {
    marginTop: 5,
    fontSize: 14,
    color: '#666',
  },
});

export default ImportProgressModal; 