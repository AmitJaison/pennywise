import { useState } from 'react';
import { 
  StyleSheet, 
  View, 
  Text, 
  TouchableOpacity, 
  Alert,
  SafeAreaView 
} from 'react-native';

const SetPINScreen = ({ onPINSet, onBack }) => {
  const [pin, setPin] = useState('');
  const [confirmPin, setConfirmPin] = useState('');
  const [stage, setStage] = useState('enter'); // 'enter' or 'confirm'

  const handleNumberPress = (number) => {
    if (stage === 'enter' && pin.length < 4) {
      const newPin = pin + number;
      setPin(newPin);
      
      if (newPin.length === 4) {
        setStage('confirm');
      }
    } else if (stage === 'confirm' && confirmPin.length < 4) {
      const newConfirmPin = confirmPin + number;
      setConfirmPin(newConfirmPin);
      
      if (newConfirmPin.length === 4) {
        validatePins(pin, newConfirmPin);
      }
    }
  };

  const handleDelete = () => {
    if (stage === 'enter') {
      setPin(pin.slice(0, -1));
    } else {
      setConfirmPin(confirmPin.slice(0, -1));
    }
  };

  const validatePins = (pin1, pin2) => {
    if (pin1 === pin2) {
      onPINSet(pin1);
    } else {
      Alert.alert('Error', 'PINs do not match. Please try again.');
      setPin('');
      setConfirmPin('');
      setStage('enter');
    }
  };

  const resetProcess = () => {
    setPin('');
    setConfirmPin('');
    setStage('enter');
  };

  return (
    <SafeAreaView style={styles.container}>
      <TouchableOpacity style={styles.backButton} onPress={onBack}>
        <Text style={styles.backButtonText}>← Back to Home</Text>
      </TouchableOpacity>

      <Text style={styles.title}>
        {stage === 'enter' ? 'Set Your PIN' : 'Confirm Your PIN'}
      </Text>
      
      <View style={styles.dotsContainer}>
        {[...Array(4)].map((_, index) => (
          <View
            key={index}
            style={[
              styles.dot,
              index < (stage === 'enter' ? pin : confirmPin).length && styles.dotFilled
            ]}
          />
        ))}
      </View>

      <View style={styles.keypad}>
        {[1, 2, 3, 4, 5, 6, 7, 8, 9].map((number) => (
          <TouchableOpacity
            key={number}
            style={styles.key}
            onPress={() => handleNumberPress(number.toString())}
          >
            <Text style={styles.keyText}>{number}</Text>
          </TouchableOpacity>
        ))}
        <TouchableOpacity
          style={styles.key}
          onPress={resetProcess}
        >
          <Text style={styles.keyText}>C</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.key}
          onPress={() => handleNumberPress('0')}
        >
          <Text style={styles.keyText}>0</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.key}
          onPress={handleDelete}
        >
          <Text style={styles.keyText}>←</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    padding: 20,
  },
  backButton: {
    marginBottom: 20,
  },
  backButtonText: {
    fontSize: 18,
    color: '#2ecc71',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 30,
  },
  dotsContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginBottom: 30,
  },
  dot: {
    width: 20,
    height: 20,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#2ecc71',
    marginHorizontal: 10,
  },
  dotFilled: {
    backgroundColor: '#2ecc71',
  },
  keypad: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
    width: '100%',
  },
  key: {
    width: '30%',
    aspectRatio: 1,
    justifyContent: 'center',
    alignItems: 'center',
    margin: '1.5%',
    borderRadius: 40,
    backgroundColor: '#f0f0f0',
  },
  keyText: {
    fontSize: 24,
    fontWeight: '500',
  },
});

export default SetPINScreen; 