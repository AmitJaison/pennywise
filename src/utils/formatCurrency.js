export const formatCurrency = (amount) => {
  const absAmount = Math.abs(amount);
  const formattedAmount = new Intl.NumberFormat('en-IN', {
    style: 'currency',
    currency: 'INR',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(absAmount);
  
  return amount >= 0 ? formattedAmount : `-${formattedAmount}`;
}; 