import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/alert_model.dart';
import '../../providers/app_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../services/localization_service.dart';

class CreateAlertScreen extends StatefulWidget {
  const CreateAlertScreen({super.key});

  @override
  State<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends State<CreateAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();

  AlertCategory _selectedCategory = AlertCategory.suspectedCase;
  LatLng? _selectedLocation;
  List<File> _selectedImages = [];
  List<File> _selectedVideos = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((image) => File(image.path)));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video =
          await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _selectedVideos.add(File(video.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking video: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeVideo(int index) {
    setState(() {
      _selectedVideos.removeAt(index);
    });
  }

  void _selectLocationOnMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _MapPickerScreen(
          initialLocation: _selectedLocation,
          onLocationSelected: (location, address) {
            setState(() {
              _selectedLocation = location;
              _addressController.text = address;
            });
          },
        ),
      ),
    );
  }

  Future<void> _submitAlert() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final currentUser = appProvider.currentUser!;

      // Create temporary alert ID for file uploads
      final tempAlertId = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload images
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        imageUrls = await _storageService.uploadMultipleImages(
            _selectedImages, tempAlertId);
      }

      // Upload videos
      List<String> videoUrls = [];
      if (_selectedVideos.isNotEmpty) {
        videoUrls = await _storageService.uploadMultipleVideos(
            _selectedVideos, tempAlertId);
      }

      // Create alert
      final alert = AlertModel(
        id: '', // Will be set by Firestore
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        status: AlertStatus.open,
        location: AlertLocation(
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          address: _addressController.text.trim(),
        ),
        imageUrls: imageUrls,
        videoUrls: videoUrls,
        createdBy: currentUser.uid,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createAlert(alert);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocalizationService.translate('alert_created')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating alert: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.translate('create_alert')),
        backgroundColor: const Color(0xFF1E2328),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Alert Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: LocalizationService.translate('alert_title'),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocalizationService.translate('field_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selection
              DropdownButtonFormField<AlertCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: LocalizationService.translate('category'),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: AlertCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(_getCategoryDisplayName(category)),
                  );
                }).toList(),
                onChanged: (AlertCategory? value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: LocalizationService.translate('description'),
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocalizationService.translate('field_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocalizationService.translate('location'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return LocalizationService.translate(
                                'field_required');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _selectLocationOnMap,
                        icon: const Icon(Icons.map),
                        label: Text(_selectedLocation == null
                            ? 'Select Location on Map'
                            : 'Change Location'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedLocation == null
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                      if (_selectedLocation != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                            'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Media Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Media Attachments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Image upload buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickImages,
                              icon: const Icon(Icons.photo_library),
                              label: Text(
                                  LocalizationService.translate('add_images')),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _takePhoto,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Take Photo'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Video upload button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _pickVideo,
                          icon: const Icon(Icons.videocam),
                          label:
                              Text(LocalizationService.translate('add_videos')),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Selected images
                      if (_selectedImages.isNotEmpty) ...[
                        Text(
                          'Selected Images (${_selectedImages.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _selectedImages[index],
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
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
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Selected videos
                      if (_selectedVideos.isNotEmpty) ...[
                        Text(
                          'Selected Videos (${_selectedVideos.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(_selectedVideos.length, (index) {
                          return ListTile(
                            leading:
                                const Icon(Icons.videocam, color: Colors.blue),
                            title: Text('Video ${index + 1}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeVideo(index),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitAlert,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF2196F3),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        LocalizationService.translate('create_alert'),
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryDisplayName(AlertCategory category) {
    switch (category) {
      case AlertCategory.suspectedCase:
        return LocalizationService.translate('suspected_case');
      case AlertCategory.confirmedCase:
        return LocalizationService.translate('confirmed_case');
      case AlertCategory.outbreak:
        return LocalizationService.translate('outbreak');
    }
  }
}

// Map picker screen for location selection
class _MapPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;
  final Function(LatLng, String) onLocationSelected;

  const _MapPickerScreen({
    this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  State<_MapPickerScreen> createState() => __MapPickerScreenState();
}

class __MapPickerScreenState extends State<_MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(-4.4419, 15.2663); // Kinshasa, DRC
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation!;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: const Color(0xFF1E2328),
        actions: [
          TextButton(
            onPressed: () {
              final address = _addressController.text.trim();
              if (address.isNotEmpty) {
                widget.onLocationSelected(_selectedLocation, address);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter an address'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('SELECT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Address input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address/Description',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Map
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation,
                zoom: 14,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              onTap: (LatLng location) {
                setState(() {
                  _selectedLocation = location;
                });
              },
              markers: {
                Marker(
                  markerId: const MarkerId('selected_location'),
                  position: _selectedLocation,
                  draggable: true,
                  onDragEnd: (LatLng location) {
                    setState(() {
                      _selectedLocation = location;
                    });
                  },
                ),
              },
            ),
          ),

          // Location info
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Latitude: ${_selectedLocation.latitude.toStringAsFixed(6)}\n'
              'Longitude: ${_selectedLocation.longitude.toStringAsFixed(6)}',
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
