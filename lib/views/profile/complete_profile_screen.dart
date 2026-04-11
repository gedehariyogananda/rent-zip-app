import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../viewmodels/auth_viewmodel.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _addressController = TextEditingController();
  final _noDaruratController = TextEditingController();

  File? _ktpPhoto;
  File? _selfiePhoto;
  final ImagePicker _picker = ImagePicker();

  final Color _textColor = const Color(0xFF3B5226);
  final Color _bgColor = const Color(0xFFCED8AF);

  @override
  void dispose() {
    _nikController.dispose();
    _addressController.dispose();
    _noDaruratController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isKtp) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        if (isKtp) {
          _ktpPhoto = File(image.path);
        } else {
          _selfiePhoto = File(image.path);
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_ktpPhoto == null || _selfiePhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto KTP dan foto Selfie dengan KTP wajib diunggah.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authVm = Provider.of<AuthViewModel>(context, listen: false);

    final success = await authVm.updateProfile(
      nik: _nikController.text.trim(),
      address: _addressController.text.trim(),
      noDarurat: _noDaruratController.text.trim(),
      ktpPhotoPath: _ktpPhoto!.path,
      photoWithNikPath: _selfiePhoto!.path,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil dilengkapi! Silakan lanjutkan sewa.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // Return true indicating success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVm.errorMessage ?? 'Gagal memperbarui profil.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildImagePicker(String title, File? imageFile, bool isKtp) {
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
          onTap: () => _pickImage(isKtp),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              border: Border.all(color: _textColor.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(imageFile, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 40, color: _textColor),
                      const SizedBox(height: 8),
                      Text(
                        'Tap untuk upload foto',
                        style: TextStyle(color: _textColor.withOpacity(0.7)),
                      ),
                    ],
                  ),
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
        title: const Text('Lengkapi Profil'),
        backgroundColor: _textColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verifikasi Identitas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Untuk dapat melakukan penyewaan, Anda harus melengkapi data identitas berikut.',
                  style: TextStyle(
                    fontSize: 14,
                    color: _textColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),

                // NIK Field
                TextFormField(
                  controller: _nikController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nomor Induk Kependudukan (NIK)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NIK tidak boleh kosong';
                    }
                    if (value.length < 16) {
                      return 'NIK harus terdiri dari 16 digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Address Field
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Alamat Lengkap Sesuai KTP',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alamat tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Emergency Number Field
                TextFormField(
                  controller: _noDaruratController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor Telepon Darurat',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor darurat tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Image Pickers
                _buildImagePicker('Foto KTP', _ktpPhoto, true),
                const SizedBox(height: 16),
                _buildImagePicker(
                  'Foto Selfie Memegang KTP',
                  _selfiePhoto,
                  false,
                ),

                const SizedBox(height: 32),

                // Submit Button
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
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Kirim Data Profil',
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
