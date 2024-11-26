import { useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Modal, FlatList } from 'react-native';
import CATEGORIES from '../utils/categories';

const CategorySelector = ({ selectedCategory, onSelectCategory }) => {
  const [modalVisible, setModalVisible] = useState(false);
  const [selectedMainCategory, setSelectedMainCategory] = useState(null);

  const handleCategorySelect = (category, subCategory) => {
    onSelectCategory({
      main: category.name,
      sub: subCategory,
      icon: category.icon
    });
    setModalVisible(false);
  };

  const renderSubCategories = () => {
    if (!selectedMainCategory) return null;

    return (
      <View style={styles.subCategoriesContainer}>
        <Text style={styles.subCategoryTitle}>Select Sub-category</Text>
        {CATEGORIES[selectedMainCategory].subCategories.map((sub) => (
          <TouchableOpacity
            key={sub}
            style={styles.subCategoryItem}
            onPress={() => handleCategorySelect(CATEGORIES[selectedMainCategory], sub)}
          >
            <Text style={styles.subCategoryText}>{sub}</Text>
          </TouchableOpacity>
        ))}
      </View>
    );
  };

  return (
    <>
      <TouchableOpacity
        style={styles.selector}
        onPress={() => setModalVisible(true)}
      >
        <Text style={styles.selectorText}>
          {selectedCategory ? 
            `${selectedCategory.icon} ${selectedCategory.main} - ${selectedCategory.sub}` : 
            'Select Category'}
        </Text>
      </TouchableOpacity>

      <Modal
        visible={modalVisible}
        transparent={true}
        animationType="slide"
        onRequestClose={() => setModalVisible(false)}
      >
        <View style={styles.modalContainer}>
          <View style={styles.modalContent}>
            <View style={styles.header}>
              <Text style={styles.title}>Select Category</Text>
              <TouchableOpacity onPress={() => setModalVisible(false)}>
                <Text style={styles.closeButton}>✕</Text>
              </TouchableOpacity>
            </View>

            <View style={styles.categoriesContainer}>
              <View style={styles.mainCategories}>
                {Object.values(CATEGORIES).map((category) => (
                  <TouchableOpacity
                    key={category.id}
                    style={[
                      styles.categoryItem,
                      selectedMainCategory === category.id && styles.selectedCategory
                    ]}
                    onPress={() => setSelectedMainCategory(category.id)}
                  >
                    <Text style={styles.categoryIcon}>{category.icon}</Text>
                    <Text style={styles.categoryName}>{category.name}</Text>
                  </TouchableOpacity>
                ))}
              </View>
              {renderSubCategories()}
            </View>
          </View>
        </View>
      </Modal>
    </>
  );
};

const styles = StyleSheet.create({
  selector: {
    borderWidth: 1,
    borderColor: '#ddd',
    padding: 15,
    borderRadius: 8,
    marginBottom: 15,
  },
  selectorText: {
    fontSize: 16,
    color: '#333',
  },
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
  categoriesContainer: {
    flexDirection: 'row',
  },
  mainCategories: {
    flex: 1,
    borderRightWidth: 1,
    borderRightColor: '#eee',
    paddingRight: 15,
  },
  categoryItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    borderRadius: 8,
    marginBottom: 8,
  },
  selectedCategory: {
    backgroundColor: '#f0f0f0',
  },
  categoryIcon: {
    fontSize: 24,
    marginRight: 10,
  },
  categoryName: {
    fontSize: 16,
  },
  subCategoriesContainer: {
    flex: 1,
    paddingLeft: 15,
  },
  subCategoryTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 15,
  },
  subCategoryItem: {
    padding: 12,
    borderRadius: 8,
    marginBottom: 8,
    backgroundColor: '#f8f8f8',
  },
  subCategoryText: {
    fontSize: 16,
  },
});

export default CategorySelector; 