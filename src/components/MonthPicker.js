import { StyleSheet, View, Text, TouchableOpacity, ScrollView } from 'react-native';

const MonthPicker = ({ selectedDate, onSelectMonth }) => {
  const months = [
    { label: 'All', value: 'all' },
    { label: 'January', value: '01' },
    { label: 'February', value: '02' },
    { label: 'March', value: '03' },
    { label: 'April', value: '04' },
    { label: 'May', value: '05' },
    { label: 'June', value: '06' },
    { label: 'July', value: '07' },
    { label: 'August', value: '08' },
    { label: 'September', value: '09' },
    { label: 'October', value: '10' },
    { label: 'November', value: '11' },
    { label: 'December', value: '12' }
  ];

  return (
    <ScrollView 
      horizontal 
      showsHorizontalScrollIndicator={false}
      style={styles.container}
    >
      {months.map((month) => (
        <TouchableOpacity
          key={month.value}
          style={[
            styles.monthButton,
            selectedDate === month.value && styles.selectedMonth
          ]}
          onPress={() => onSelectMonth(month.value)}
        >
          <Text style={[
            styles.monthText,
            selectedDate === month.value && styles.selectedMonthText
          ]}>
            {month.label}
          </Text>
        </TouchableOpacity>
      ))}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flexGrow: 0,
    marginBottom: 10,
  },
  monthButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    marginRight: 8,
    borderRadius: 20,
    backgroundColor: '#f0f0f0',
  },
  selectedMonth: {
    backgroundColor: '#2ecc71',
  },
  monthText: {
    color: '#666',
    fontSize: 14,
  },
  selectedMonthText: {
    color: '#fff',
    fontWeight: '600',
  },
});

export default MonthPicker; 