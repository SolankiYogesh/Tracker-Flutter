import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/models/user_update.dart';
import 'package:tracker/providers/auth_service_provider.dart';
import 'package:tracker/theme/app_colors.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdateController;
  
  // Socials
  late TextEditingController _instagramController;
  late TextEditingController _youtubeController;
  late TextEditingController _facebookController;
  late TextEditingController _snapchatController;

  String? _gender;
  String _countryCode = '+1';
  DateTime? _selectedBirthdate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthServiceProvider>().appUser;
    
    _usernameController = TextEditingController(text: user?.username);
    
    // Phone parsing
    String initialPhone = user?.phoneNumber ?? '';
    if (initialPhone.isNotEmpty) {
      if (initialPhone.contains(' ')) {
        final parts = initialPhone.split(' ');
        if (parts.length > 1 && parts[0].startsWith('+')) {
          _countryCode = parts[0];
          initialPhone = initialPhone.substring(parts[0].length).trim();
        }
      }
    }
    _phoneController = TextEditingController(text: initialPhone);
    
    _birthdateController = TextEditingController(
      text: user?.birthdate != null 
          ? DateFormat('yyyy-MM-dd').format(user!.birthdate!) 
          : ''
    );
    _selectedBirthdate = user?.birthdate;
    
    _gender = user?.gender;
    
    final socials = user?.socialMediaLinks ?? {};
    _instagramController = TextEditingController(text: socials['instagram'] as String?);
    _youtubeController = TextEditingController(text: socials['youtube'] as String?);
    _facebookController = TextEditingController(text: socials['facebook'] as String?);
    _snapchatController = TextEditingController(text: socials['snapchat'] as String?);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _birthdateController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    _facebookController.dispose();
    _snapchatController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthdate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: AppColors.darkSurface,
                    onSurface: AppColors.darkTextPrimary,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: AppColors.lightSurface,
                    onSurface: AppColors.lightTextPrimary,
                  ),
            dialogBackgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthdate) {
      setState(() {
        _selectedBirthdate = picked;
        _birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final socials = {
        if (_instagramController.text.isNotEmpty) 'instagram': _instagramController.text,
        if (_youtubeController.text.isNotEmpty) 'youtube': _youtubeController.text,
        if (_facebookController.text.isNotEmpty) 'facebook': _facebookController.text,
        if (_snapchatController.text.isNotEmpty) 'snapchat': _snapchatController.text,
      };

      // Combine country code and phone if phone is entered
      String? finalPhone;
      if (_phoneController.text.isNotEmpty) {
          final number = _phoneController.text.trim();
          if (number.startsWith('+')) {
             // Assume user provided full format, use as is (ignoring picker preference if mismatched)
             finalPhone = number;
          } else {
             finalPhone = '$_countryCode $number';
          }
      }

      final update = UserUpdate(
        username: _usernameController.text.isEmpty ? null : _usernameController.text,
        gender: _gender,
        birthdate: _selectedBirthdate,
        phoneNumber: finalPhone,
        socialMediaLinks: socials.isEmpty ? null : socials,
      );

      final provider = context.read<AuthServiceProvider>();
      if (provider.userId != null) {
          // We need to add updateUser method to provider or call repo directly
          // Best practice: Add to provider.
          // For now, let's assume we add `updateUserProfile` to AuthServiceProvider
          // OR call repo via provider.userRepo
          await provider.updateUserProfile(update);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
            Navigator.pop(context);
          }
      }
    } catch (e) {
      String message = 'Error updating profile';
      // Check for common error signatures from Dio/Backend
      final errorStr = e.toString();
      if (errorStr.contains('409') || errorStr.contains('Username is already taken')) {
        message = 'Username is already taken. Please choose another.';
      } else if (errorStr.contains('422')) {
        message = 'Invalid data provided. Please check your inputs.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthServiceProvider>().appUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: user?.picture != null ? NetworkImage(user!.picture!) : null,
                  child: user?.picture == null ? const Icon(Icons.person, size: 50) : null,
                ),
              ),
              const SizedBox(height: 24),
              
              // Username
              _buildLabel('Username'),
              TextFormField(
                controller: _usernameController,
                decoration: _inputDecoration('Enter username'),
                validator: (value) {
                  if (value != null && value.length > 30) return 'Max 30 characters';
                  if (value != null && value.isNotEmpty && !RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(value)) {
                    return 'Only letters, numbers, . _ - allowed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Gender
              _buildLabel('Gender'),
              Row(
                children: [
                  _buildGenderRadio('Male', '👨 Male'),
                  _buildGenderRadio('Female', '👩 Female'),
                  _buildGenderRadio('Other', '🌈 Other'),
                ],
              ),
              const SizedBox(height: 16),

              // Birthdate
              _buildLabel('Birthdate'),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _birthdateController,
                    decoration: _inputDecoration('Select birthdate').copyWith(
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Phone
              _buildLabel('Phone Number'),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CountryCodePicker(
                      textStyle: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        fontSize: 16,
                      ),
                      dialogTextStyle: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        fontSize: 16,
                      ),
                      searchStyle: TextStyle(
                         color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                         fontSize: 16,
                      ),
                      dialogBackgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      barrierColor: Colors.black.withValues(alpha: 0.5),
                      searchDecoration: _inputDecoration('Search country'),
                      boxDecoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      closeIcon: Icon(
                        Icons.close, 
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary
                      ),
                      onChanged: (code) => _countryCode = code.dialCode ?? '+1',
                      initialSelection: _countryCode,
                      favorite: const ['US', 'IN', 'GB'],
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
                      alignLeft: false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: _inputDecoration('Phone number'),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Socials
              const Text('Social Media', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              _buildSocialInput('Instagram', _instagramController, Icons.camera_alt),
              const SizedBox(height: 12),
              _buildSocialInput('YouTube', _youtubeController, Icons.play_arrow),
              const SizedBox(height: 12),
              _buildSocialInput('Facebook', _facebookController, Icons.facebook),
              const SizedBox(height: 12),
              _buildSocialInput('Snapchat', _snapchatController, Icons.snapchat), // Material doesn't have snapchat icon, assume default or add asset later

              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildGenderRadio(String value, String label) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: value,
            groupValue: _gender,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _gender = val),
            visualDensity: VisualDensity.compact,
          ),
          Flexible(child: Text(label, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildSocialInput(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label).copyWith(
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
