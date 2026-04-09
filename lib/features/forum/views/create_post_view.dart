import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../viewmodels/forum_viewmodel.dart';
import '../models/forum_post_model.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;

class CreatePostView extends StatefulWidget {
  final ForumViewModel viewModel;
  const CreatePostView({super.key, required this.viewModel});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _searchController = TextEditingController();
  
  String? _selectedCategory;
  Map<String, dynamic>? _selectedBrand;
  List<dynamic> _allBrands = [];
  List<dynamic> _filteredBrands = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    try {
      final String response = await rootBundle.loadString('assets/car.json');
      final List<dynamic> data = json.decode(response);
      
      // A'dan Z'ye sıralama
      data.sort((a, b) => (a['brand'] as String).compareTo(b['brand'] as String));
      
      setState(() {
        _allBrands = data;
        _filteredBrands = data;
      });
    } catch (e) {
      debugPrint('Brands error: $e');
    }
  }


  String _getLogoUrl(String brandName) {
    String slug = brandName.toLowerCase()
        .replaceAll(' /', '-')
        .replaceAll('/ ', '-')
        .replaceAll('/', '-')
        .replaceAll(' ', '-');
    
    // Özel durumlar
    if (slug == 'mercedes') slug = 'mercedes-benz';
    if (slug == 'renault-oyak') slug = 'renault';
    if (slug == 'renault-(oyak)') slug = 'renault';
    if (slug == 'tofas-fiat') slug = 'fiat';
    if (slug == 'range-rover') slug = 'land-rover';
    if (slug == 'dodge-usa') slug = 'dodge';
    if (slug == 'ford-otosan') slug = 'ford';
    if (slug == 'vw') slug = 'volkswagen';
    if (slug == 'daewoo') slug = 'daewoo';
    if (slug == 'chery') slug = 'chery';
    if (slug == 'geely') slug = 'geely';
    if (slug.contains('tesla')) slug = 'tesla';
    
    return 'https://www.thesvg.org/icons/$slug/default.svg';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Yeni Paylaşım', style: AppTypography.h3),
        leading: IconButton(
          icon: const iconoir.NavArrowLeft(color: AppColors.primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Kategori Seçin'),
              const SizedBox(height: 12),
              _buildCategorySelector(),
              const SizedBox(height: 28),
              
              _buildSectionTitle('Araç Markası'),
              const SizedBox(height: 12),
              _buildPremiumBrandSelector(),
              const SizedBox(height: 28),

              _buildTextField(
                controller: _titleController,
                label: 'Konu Başlığı',
                hint: 'Kısaca sorun veya önerinizi belirtin',
                validator: (v) => v?.isEmpty ?? true ? 'Lütfen başlık girin' : null,
              ),
              const SizedBox(height: 24),
              
              _buildTextField(
                controller: _contentController,
                label: 'Açıklama',
                hint: 'Detaylı bir şekilde anlatın...',
                maxLines: 5,
                validator: (v) => v?.isEmpty ?? true ? 'Lütfen içerik girin' : null,
              ),
              
              const SizedBox(height: 48),
              
              _buildSubmitButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.bodySmall.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.primaryNavy.withValues(alpha: 0.8),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ForumPostModel.categories
          .where((c) => c['key'] != 'genel')
          .map((cat) => _buildChoiceChip(cat))
          .toList(),
    );
  }

  Widget _buildChoiceChip(Map<String, String> category) {
    final isSelected = _selectedCategory == category['key'];
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category['key']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentBlue : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.accentBlue : AppColors.surfaceDivider,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.accentBlue.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Text(
          category['label']!,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBrandSelector() {
    return InkWell(
      onTap: _showBrandPicker,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _selectedBrand == null ? AppColors.surfaceDivider : AppColors.accentBlue,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            if (_selectedBrand != null) ...[
              Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.network(
                  _getLogoUrl(_selectedBrand!['brand']),
                  placeholderBuilder: (context) => const iconoir.Car(width: 16, height: 16, color: AppColors.textTertiary),
                ),
              ),
              const SizedBox(width: 12),
            ] else ...[
              const iconoir.Car(width: 24, height: 24, color: AppColors.textTertiary),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                _selectedBrand != null ? _selectedBrand!['brand'] : 'Marka Seçiniz',
                style: AppTypography.bodyLarge.copyWith(
                  color: _selectedBrand != null ? AppColors.primaryNavy : AppColors.textTertiary,
                  fontWeight: _selectedBrand != null ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            const iconoir.NavArrowDown(color: AppColors.textTertiary, width: 20),
          ],
        ),
      ),
    );
  }

  void _showBrandPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDivider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Marka Seçimi', style: AppTypography.h2),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        onChanged: (v) {
                          setModalState(() {
                            _filteredBrands = _allBrands
                                .where((brand) => (brand['brand'] as String)
                                    .toLowerCase()
                                    .contains(v.toLowerCase()))
                                .toList();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Marka ara...',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(12),
                            child: iconoir.Search(width: 20, height: 20),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _filteredBrands.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.surfaceDivider),
                    itemBuilder: (context, index) {
                      final brand = _filteredBrands[index];
                      return ListTile(
                        onTap: () {
                          setState(() => _selectedBrand = brand);
                          Navigator.pop(context);
                        },
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        leading: Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SvgPicture.network(
                            _getLogoUrl(brand['brand']),
                            placeholderBuilder: (context) => const iconoir.Car(width: 20, height: 20, color: AppColors.textTertiary),
                          ),
                        ),
                        title: Text(
                          brand['brand'],
                          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
                        ),
                        trailing: _selectedBrand?['id'] == brand['id']
                            ? const iconoir.Check(color: AppColors.accentBlue)
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          cursorColor: AppColors.accentBlue,
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textTertiary),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.surfaceDivider, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.surfaceDivider, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _submitPost,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Toplulukla Paylaş',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
      ),
    );
  }

  Future<void> _submitPost() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    if (_selectedCategory == null) {
      _showError('Lütfen bir kategori seçin');
      return;
    }

    if (_selectedBrand == null) {
      _showError('Lütfen bir araç markası seçin');
      return;
    }

    setState(() => _isSaving = true);
    final success = await widget.viewModel.createPost(
      title: _titleController.text,
      content: _contentController.text,
      category: _selectedCategory!,
      carBrand: _selectedBrand!['brand'],
    );

    if (success) {
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        setState(() => _isSaving = false);
        _showError('Paylaşım yapılamadı! Veritabanı bağlantısını kontrol edin.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
