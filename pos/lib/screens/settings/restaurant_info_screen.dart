import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/database_helper.dart';
import '../../services/api_data_service.dart';

class RestaurantInfoScreen extends StatefulWidget {
  const RestaurantInfoScreen({super.key});

  @override
  State<RestaurantInfoScreen> createState() => _RestaurantInfoScreenState();
}

class _RestaurantInfoScreenState extends State<RestaurantInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ApiDataService _apiDataService = ApiDataService();
  bool _isLoading = true;
  bool _isSaving = false;

  // Controllers for form fields
  final _restaurantNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _panController = TextEditingController();
  final _websiteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRestaurantInfo();
  }

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _panController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Restaurant Information',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Configure your restaurant details and contact information',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Restaurant Name
              _buildFormField(
                label: 'Restaurant Name',
                controller: _restaurantNameController,
                hint: 'Enter restaurant name',
                icon: Icons.restaurant,
              ),

              // Address
              _buildFormField(
                label: 'Address',
                controller: _addressController,
                hint: 'Enter restaurant address',
                icon: Icons.location_on,
                maxLines: 3,
              ),

              // Phone
              _buildFormField(
                label: 'Phone Number',
                controller: _phoneController,
                hint: 'Enter phone number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),

              // Email
              _buildFormField(
                label: 'Email',
                controller: _emailController,
                hint: 'Enter email address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),

              // PAN Number
              _buildFormField(
                label: 'PAN Number',
                controller: _panController,
                hint: 'Enter PAN number',
                icon: Icons.credit_card,
              ),

              // Website
              _buildFormField(
                label: 'Website (Optional)',
                controller: _websiteController,
                hint: 'Enter website URL',
                icon: Icons.language,
                keyboardType: TextInputType.url,
                isOptional: true,
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Saving...'),
                          ],
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: (value) {
              if (!isOptional && (value == null || value.trim().isEmpty)) {
                return 'Please enter $label';
              }
              if (keyboardType == TextInputType.emailAddress && 
                  value != null && value.trim().isNotEmpty) {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid email address';
                }
              }
              if (keyboardType == TextInputType.phone && 
                  value != null && value.trim().isNotEmpty) {
                if (value.trim().length < 10) {
                  return 'Please enter a valid phone number';
                }
              }
              if (keyboardType == TextInputType.url && 
                  value != null && value.trim().isNotEmpty) {
                final urlRegex = RegExp(r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$');
                if (!urlRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid website URL';
                }
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ],
      ),
    );
  }

  void _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final restaurant = Restaurant(
          name: _restaurantNameController.text.trim(),
          address: _addressController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          panNumber: _panController.text.trim(),
          website: _websiteController.text.trim().isEmpty 
              ? null 
              : _websiteController.text.trim(),
        );

        // Try to update via API first
        Restaurant updatedRestaurant;
        try {
          updatedRestaurant = await _apiDataService.updateRestaurantSettings(restaurant);
          
          // Update local database with the server response
          await _databaseHelper.upsertRestaurant(updatedRestaurant);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Restaurant information saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (apiError) {
          // If API fails, try to save locally
          debugPrint('API error: $apiError');
          await _databaseHelper.upsertRestaurant(restaurant);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Saved locally. Server sync failed: ${apiError.toString()}'
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
        
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving restaurant information: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  Future<void> _loadRestaurantInfo() async {
    try {
      Restaurant? restaurant;
      
      // Try to fetch from API first
      try {
        restaurant = await _apiDataService.getRestaurantSettings();
        
        // Update local database with server data
        await _databaseHelper.upsertRestaurant(restaurant);
        
      } catch (apiError) {
        // If API fails, fall back to local database
        debugPrint('API error during load: $apiError');
        restaurant = await _databaseHelper.getRestaurant();
        
        if (mounted && restaurant == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to connect to server. Loading offline data.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
      
      if (restaurant != null && mounted) {
        setState(() {
          _restaurantNameController.text = restaurant!.name;
          _addressController.text = restaurant.address;
          _phoneController.text = restaurant.phone;
          _emailController.text = restaurant.email;
          _panController.text = restaurant.panNumber;
          _websiteController.text = restaurant.website ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading restaurant information: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
