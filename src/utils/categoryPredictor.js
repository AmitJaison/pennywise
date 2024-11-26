// Predefined category mappings
const categoryKeywords = {
  food: ['food', 'meal', 'restaurant', 'lunch', 'dinner', 'breakfast', 'cafe', 'grocery', 'snack', 'swiggy', 'zomato', 'pizza', 'burger', 'hotel'],
  transport: ['uber', 'ola', 'taxi', 'bus', 'train', 'metro', 'fuel', 'petrol', 'diesel', 'parking', 'auto', 'flight', 'car', 'bike'],
  shopping: ['mall', 'clothes', 'shirt', 'shoes', 'amazon', 'flipkart', 'myntra', 'shopping', 'purchase', 'buy'],
  entertainment: ['movie', 'netflix', 'prime', 'hotstar', 'theatre', 'game', 'spotify', 'music', 'concert', 'show', 'disney'],
  bills: ['electricity', 'water', 'gas', 'internet', 'wifi', 'phone', 'bill', 'recharge', 'rent', 'maintenance', 'dth', 'cable'],
  health: ['medical', 'medicine', 'doctor', 'hospital', 'clinic', 'pharmacy', 'health', 'dental', 'eye', 'checkup', 'test'],
  education: ['book', 'course', 'tuition', 'class', 'school', 'college', 'university', 'fees', 'training', 'workshop'],
  groceries: ['vegetables', 'fruits', 'milk', 'bread', 'grocery', 'supermarket', 'mart', 'store', 'market'],
  loans: [
    'loan', 'emi', 'mortgage', 'credit', 'payment', 'installment', 'finance',
    'home loan', 'car loan', 'personal loan', 'education loan',
    'hdfc', 'sbi', 'icici', 'axis', 'bank', 'lending'
  ],
  insurance: [
    'insurance', 'premium', 'policy', 'life insurance', 'health insurance',
    'car insurance', 'vehicle insurance', 'medical insurance',
    'lic', 'policy bazaar', 'renewal'
  ],
  family: [
    'family', 'parents', 'mother', 'father', 'sister', 'brother', 'relative',
    'gift', 'celebration', 'festival', 'wedding', 'birthday', 'anniversary',
    'pocket money', 'allowance', 'support'
  ],
  investment: [
    'investment', 'mutual fund', 'stocks', 'shares', 'fd', 'fixed deposit',
    'ppf', 'nps', 'trading', 'zerodha', 'groww', 'upstox', 'demat',
    'gold', 'crypto', 'bitcoin', 'savings'
  ],
  other: []
};

export const predictCategory = (title) => {
  const lowercaseTitle = title.toLowerCase();
  
  // First check for exact matches
  for (const [category, keywords] of Object.entries(categoryKeywords)) {
    if (keywords.some(keyword => lowercaseTitle === keyword)) {
      return category;
    }
  }
  
  // Then check for partial matches
  for (const [category, keywords] of Object.entries(categoryKeywords)) {
    if (keywords.some(keyword => lowercaseTitle.includes(keyword))) {
      return category;
    }
  }
  
  // Check for common EMI patterns
  if (lowercaseTitle.match(/emi|loan|payment/i) && 
      lowercaseTitle.match(/\d{2}\/\d{2}|\d{2}-\d{2}/)) {
    return 'loans';
  }
  
  return 'other';
};

// Helper function to get category icon
export const getCategoryIcon = (category) => {
  const icons = {
    food: '🍽️',
    transport: '🚗',
    shopping: '🛍️',
    entertainment: '🎬',
    bills: '📱',
    health: '⚕️',
    education: '📚',
    groceries: '🛒',
    loans: '💰',
    insurance: '🛡️',
    family: '👨‍👩‍👧‍👦',
    investment: '📈',
    other: '📝'
  };
  return icons[category] || icons.other;
};

// Helper function to get category color
export const getCategoryColor = (category) => {
  const colors = {
    food: '#FF6B6B',
    transport: '#4ECDC4',
    shopping: '#45B7D1',
    entertainment: '#96CEB4',
    bills: '#FF9F1C',
    health: '#2ECC71',
    education: '#9B59B6',
    groceries: '#58B19F',
    loans: '#D35400',
    insurance: '#3498DB',
    family: '#E056FD',
    investment: '#26ae60',
    other: '#95A5A6'
  };
  return colors[category] || colors.other;
}; 