import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ImagePickerWidget extends StatelessWidget {
  final List<ProductImage> images;
  final Function(List<ProductImage>) onImagesChanged;

  const ImagePickerWidget({
    Key? key,
    required this.images,
    required this.onImagesChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isNotEmpty) ...[
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: image.isPrimary ? Colors.blue : Colors.grey.shade300,
                      width: image.isPrimary ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          image.imageUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                      
                      // Primary badge
                      if (image.isPrimary)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Primary',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      
                      // Remove button
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      
                      // Set as primary button
                      if (!image.isPrimary)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _setPrimaryImage(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Set Primary',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Add Image Button
        GestureDetector(
          onTap: _showAddImageDialog,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Add Image URL',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        Text(
          'Note: For demo purposes, use image URLs. In production, implement proper image upload.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  void _showAddImageDialog() {
    final BuildContext context = onImagesChanged as BuildContext;
    final urlController = TextEditingController();
    final altTextController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Image URL *',
                hintText: 'https://example.com/image.jpg',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: altTextController,
              decoration: const InputDecoration(
                labelText: 'Alt Text (Optional)',
                hintText: 'Image description',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.trim().isNotEmpty) {
                final newImage = ProductImage(
                  imageUrl: urlController.text.trim(),
                  altText: altTextController.text.trim().isNotEmpty 
                      ? altTextController.text.trim() 
                      : null,
                  isPrimary: images.isEmpty, // First image is primary by default
                  order: images.length,
                );
                
                final updatedImages = List<ProductImage>.from(images)..add(newImage);
                onImagesChanged(updatedImages);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeImage(int index) {
    final updatedImages = List<ProductImage>.from(images);
    final removedImage = updatedImages.removeAt(index);
    
    // If we removed the primary image, set the first remaining image as primary
    if (removedImage.isPrimary && updatedImages.isNotEmpty) {
      updatedImages[0] = ProductImage(
        id: updatedImages[0].id,
        imageUrl: updatedImages[0].imageUrl,
        altText: updatedImages[0].altText,
        isPrimary: true,
        order: updatedImages[0].order,
      );
    }
    
    // Reorder remaining images
    for (int i = 0; i < updatedImages.length; i++) {
      updatedImages[i] = ProductImage(
        id: updatedImages[i].id,
        imageUrl: updatedImages[i].imageUrl,
        altText: updatedImages[i].altText,
        isPrimary: updatedImages[i].isPrimary,
        order: i,
      );
    }
    
    onImagesChanged(updatedImages);
  }

  void _setPrimaryImage(int index) {
    final updatedImages = List<ProductImage>.from(images);
    
    // Remove primary from all images
    for (int i = 0; i < updatedImages.length; i++) {
      updatedImages[i] = ProductImage(
        id: updatedImages[i].id,
        imageUrl: updatedImages[i].imageUrl,
        altText: updatedImages[i].altText,
        isPrimary: i == index,
        order: updatedImages[i].order,
      );
    }
    
    onImagesChanged(updatedImages);
  }
}