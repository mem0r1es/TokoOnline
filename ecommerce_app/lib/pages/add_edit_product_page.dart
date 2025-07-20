import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/image_picker_widget.dart';

class AddEditProductPage extends StatefulWidget {
  final Product? product;

  const AddEditProductPage({Key? key, this.product}) : super(key: key);

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _sizeController = TextEditingController();
  final _weightController = TextEditingController();

  String _selectedCondition = 'good';
  Category? _selectedCategory;
  List<ProductImage> _images = [];
  List<ProductAttribute> _attributes = [];

  final List<String> _conditions = [
    'new',
    'like_new',
    'good', 
    'fair',
    'poor'
  ];

  final Map<String, String> _conditionLabels = {
    'new': 'New',
    'like_new': 'Like New',
    'good': 'Good',
    'fair': 'Fair',
    'poor': 'Poor',
  };

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.product != null) {
      _populateFields();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _loadCategories() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    if (authProvider.accessToken != null) {
      productProvider.loadCategories(authProvider.accessToken!);
    }
  }

  void _populateFields() {
    final product = widget.product!;
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toString();
    _stockController.text = product.stockQuantity.toString();
    _brandController.text = product.brand ?? '';
    _modelController.text = product.model ?? '';
    _colorController.text = product.color ?? '';
    _sizeController.text = product.size ?? '';
    _weightController.text = product.weight?.toString() ?? '';
    _selectedCondition = product.condition;
    _selectedCategory = product.category;
    _images = product.images ?? [];
    _attributes = product.attributes ?? [];
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    if (authProvider.accessToken == null) return;

    final productData = CreateProductRequest(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      categoryId: _selectedCategory?.id,
      condition: _selectedCondition,
      stockQuantity: int.parse(_stockController.text),
      brand: _brandController.text.trim().isNotEmpty ? _brandController.text.trim() : null,
      model: _modelController.text.trim().isNotEmpty ? _modelController.text.trim() : null,
      color: _colorController.text.trim().isNotEmpty ? _colorController.text.trim() : null,
      size: _sizeController.text.trim().isNotEmpty ? _sizeController.text.trim() : null,
      weight: _weightController.text.trim().isNotEmpty ? double.parse(_weightController.text) : null,
      images: _images,
      attributes: _attributes,
    );

    bool success;
    if (widget.product == null) {
      success = await productProvider.createProduct(authProvider.accessToken!, productData);
    } else {
      success = await productProvider.updateProduct(
        authProvider.accessToken!,
        widget.product!.id,
        productData,
      );
    }

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.product == null 
            ? 'Product created successfully' 
            : 'Product updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(productProvider.errorMessage ?? 'Failed to save product'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Add Product' : 'Edit Product',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: _saveProduct,
            child: const Text(
              'Save',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Section
                  _buildSectionCard(
                    title: 'Basic Information',
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        hintText: 'Product Name *',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      CustomTextField(
                        controller: _descriptionController,
                        hintText: 'Product Description *',
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter product description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _priceController,
                              hintText: 'Price *',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter price';
                                }
                                final price = double.tryParse(value);
                                if (price == null || price <= 0) {
                                  return 'Please enter valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _stockController,
                              hintText: 'Stock Quantity *',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter stock quantity';
                                }
                                final stock = int.tryParse(value);
                                if (stock == null || stock < 0) {
                                  return 'Please enter valid stock';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Category and Condition Section
                  _buildSectionCard(
                    title: 'Category & Condition',
                    children: [
                      // Category Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade50,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Category>(
                            value: _selectedCategory,
                            hint: const Text('Select Category'),
                            isExpanded: true,
                            onChanged: (Category? newValue) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            },
                            items: productProvider.categories.map((Category category) {
                              return DropdownMenuItem<Category>(
                                value: category,
                                child: Text(category.name),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Condition Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade50,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCondition,
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCondition = newValue!;
                              });
                            },
                            items: _conditions.map((String condition) {
                              return DropdownMenuItem<String>(
                                value: condition,
                                child: Text(_conditionLabels[condition]!),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Product Details Section
                  _buildSectionCard(
                    title: 'Product Details (Optional)',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _brandController,
                              hintText: 'Brand',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _modelController,
                              hintText: 'Model',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _colorController,
                              hintText: 'Color',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _sizeController,
                              hintText: 'Size',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      CustomTextField(
                        controller: _weightController,
                        hintText: 'Weight (kg)',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Images Section
                  _buildSectionCard(
                    title: 'Product Images',
                    children: [
                      ImagePickerWidget(
                        images: _images,
                        onImagesChanged: (List<ProductImage> newImages) {
                          setState(() {
                            _images = newImages;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Attributes Section
                  _buildSectionCard(
                    title: 'Additional Attributes',
                    children: [
                      _buildAttributesList(),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _addAttribute,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Attribute'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Save Button
                  CustomButton(
                    text: widget.product == null ? 'Create Product' : 'Update Product',
                    onPressed: _saveProduct,
                    isLoading: productProvider.isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAttributesList() {
    return Column(
      children: _attributes.asMap().entries.map((entry) {
        final index = entry.key;
        final attribute = entry.value;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text('${attribute.name}: ${attribute.value}'),
              ),
              IconButton(
                onPressed: () => _removeAttribute(index),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _addAttribute() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final valueController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Add Attribute'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Attribute Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: 'Attribute Value',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && valueController.text.isNotEmpty) {
                  setState(() {
                    _attributes.add(ProductAttribute(
                      name: nameController.text.trim(),
                      value: valueController.text.trim(),
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeAttribute(int index) {
    setState(() {
      _attributes.removeAt(index);
    });
  }
}