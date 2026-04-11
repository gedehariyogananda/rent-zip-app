import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../viewmodels/auth_viewmodel.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _nikController = TextEditingController();
  final _noDaruratController = TextEditingController();

  File? _avatarFile;
  File? _ktpPhotoFile;
  File? _photoWithNikFile;

  String? _currentAvatarUrl;
  String? _currentKtpUrl;
  String? _currentPhotoWithNikUrl;

  final ImagePicker _picker = ImagePicker();
  bool _isLoadingData = true;

  final Color _textColor = const Color(0xFF3B5226);
  final Color _bgColor = const Color(0xFFCED8AF);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData() async {
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final data = await authVm.fetchProfile();

    if (data != null && mounted) {
      setState(() {
        _usernameController.text = data['username']?.toString() ?? '';
        _emailController.text = data['email']?.toString() ?? '';
        _phoneController.text = data['phone']?.toString() ?? '';
        _addressController.text = data['address']?.toString() ?? '';
        _currentAvatarUrl = data['avatar_url']?.toString();

        if (data['profile'] != null) {
          final profile = data['profile'];
          _nikController.text = profile['nik']?.toString() ?? '';
          _noDaruratController.text = profile['no_darurat']?.toString() ?? '';
          _currentKtpUrl = profile['ktp_url']?.toString();
          _currentPhotoWithNikUrl = profile['photo_with_nik']?.toString();
        }
        _isLoadingData = false;
      });
    } else {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authVm.errorMessage ?? 'Gagal memuat data profil.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _nikController.dispose();
    _noDaruratController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int type) async {
    // type: 0 = avatar, 1 = ktp, 2 = photo_nik
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        if (type == 0) {
          _avatarFile = File(image.path);
        } else if (type == 1) {
          _ktpPhotoFile = File(image.path);
        } else {
          _photoWithNikFile = File(image.path);
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authVm = Provider.of<AuthViewModel>(context, listen: false);

    final success = await authVm.updateProfileGeneral(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      nik: _nikController.text.trim(),
      noDarurat: _noDaruratController.text.trim(),
      avatarPath: _avatarFile?.path,
      ktpPhotoPath: _ktpPhotoFile?.path,
      photoWithNikPath: _photoWithNikFile?.path,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVm.errorMessage ?? 'Gagal memperbarui profil.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[300],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImagePickerBox(
    String title,
    File? file,
    String? currentUrl,
    int type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickImage(type),
          child: Container(
            height: type == 0 ? 100 : 150,
            width: type == 0 ? 100 : double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              border: Border.all(color: _textColor.withValues(alpha: 0.3)),
              shape: type == 0 ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: type == 0 ? null : BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: type == 0
                  ? BorderRadius.circular(50)
                  : BorderRadius.circular(16),
              child: _buildImageContent(file, currentUrl, type),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildImageContent(File? file, String? currentUrl, int type) {
    if (file != null) {
      return Image.file(file, fit: BoxFit.cover);
    } else if (currentUrl != null && currentUrl.isNotEmpty) {
      return Image.network(
        currentUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderIcon(type),
      );
    } else {
      return _placeholderIcon(type);
    }
  }

  Widget _placeholderIcon(int type) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          type == 0 ? Icons.person : Icons.camera_alt,
          size: type == 0 ? 40 : 40,
          color: _textColor,
        ),
        if (type != 0) const SizedBox(height: 8),
        if (type != 0)
          Text(
            'Tap untuk ubah foto',
            style: TextStyle(
              fontSize: 12,
              color: _textColor.withValues(alpha: 0.7),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text('Ubah Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: _textColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: _isLoadingData
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF3B5226)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: _buildImagePickerBox(
                          'Foto Profil',
                          _avatarFile,
                          _currentAvatarUrl,
                          0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Informasi Akun',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField('Username', _usernameController),
                      _buildTextField(
                        'Email',
                        _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: false,
                      ),
                      _buildTextField(
                        'Nomor Telepon',
                        _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Informasi Verifikasi (Profil)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        'NIK',
                        _nikController,
                        keyboardType: TextInputType.number,
                      ),
                      _buildTextField(
                        'Nomor Telepon Darurat',
                        _noDaruratController,
                        keyboardType: TextInputType.phone,
                      ),
                      _buildTextField(
                        'Alamat',
                        _addressController,
                        maxLines: 3,
                      ),
                      _buildImagePickerBox(
                        'Foto KTP',
                        _ktpPhotoFile,
                        _currentKtpUrl,
                        1,
                      ),
                      _buildImagePickerBox(
                        'Foto Selfie dengan KTP',
                        _photoWithNikFile,
                        _currentPhotoWithNikUrl,
                        2,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: authVm.isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _textColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: authVm.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Simpan Perubahan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
