import 'package:flutter/material.dart';
import '../models/art_repository.dart';
import 'my_art_page.dart';

class AddYourArtPage extends StatefulWidget {
  const AddYourArtPage({super.key});

  @override
  State<AddYourArtPage> createState() => _AddYourArtPageState();
}

class _AddYourArtPageState extends State<AddYourArtPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minController = TextEditingController();
  final _maxController = TextEditingController();
  String _category = 'Monocrome';
  String? _imageUrl;

  Future<void> _askForImageUrl() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter image URL'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'https://...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('OK')),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() => _imageUrl = result);
    }
  }

  void _submit() {
    final title = _titleController.text.isNotEmpty ? _titleController.text : 'Untitled';
    final image = _imageUrl ?? '';
    final item = ArtItem(
      title: title,
      imageUrl: image.isNotEmpty ? image : 'https://via.placeholder.com/800x600.png?text=Artwork',
      startPrice: _minController.text.isNotEmpty ? _minController.text : '\$0',
      currentPrice: _maxController.text.isNotEmpty ? _maxController.text : '\$0',
      peopleCount: '0',
      timeRemaining: '00:00',
    );
    ArtRepository.instance.add(item);

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyArtPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Art Auction',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Painting Name',
                hintText: 'Leonardo',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Painting Description',
                hintText: 'This is an exquisite painting.',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Category',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              initialValue: _category,
              items: const [
                DropdownMenuItem(value: 'Monocrome', child: Text('Monocrome')),
                DropdownMenuItem(value: 'Abstract', child: Text('Abstract')),
                DropdownMenuItem(value: 'Realistic', child: Text('Realistic')),
              ],
              onChanged: (value) => setState(() => _category = value ?? _category),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _minController,
              decoration: InputDecoration(
                labelText: 'Minimum Bid',
                hintText: '10 \$',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _maxController,
              decoration: InputDecoration(
                labelText: 'Maximum Bid',
                hintText: '10000 \$',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _askForImageUrl,
              child: Center(
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _imageUrl == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey[600]),
                            const SizedBox(height: 8),
                            Text(
                              'Upload Image',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(_imageUrl!, fit: BoxFit.cover, width: double.infinity, height: 150,
                              errorBuilder: (context, error, st) {
                            return Center(child: Text('Failed to load image', style: TextStyle(color: Colors.grey[600])));
                          }),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
