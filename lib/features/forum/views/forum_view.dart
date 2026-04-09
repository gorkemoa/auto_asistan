import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../viewmodels/forum_viewmodel.dart';
import '../models/forum_post_model.dart';
import './create_post_view.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;

class ForumView extends StatefulWidget {
  const ForumView({super.key});

  @override
  State<ForumView> createState() => _ForumViewState();
}

class _ForumViewState extends State<ForumView> {
  late final ForumViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ForumViewModel();
    _viewModel.loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.surfaceLight,
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Forum', style: AppTypography.h1),
                          IconButton(
                            onPressed: () => _navigateToCreatePost(context),
                            icon: const iconoir.Plus(
                              color: AppColors.accentBlue,
                              width: 28,
                              height: 28,
                            ),
                          ),
                        ],
                      ),
                      Text('Topluluğuna sor, paylaş, danış.',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 20),
                      _buildCategoryFilter(),
                    ],
                  ),
                ),
              ),
            ],
            body: Consumer<ForumViewModel>(
              builder: (context, vm, _) {
                if (vm.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.accentBlue),
                  );
                }

                if (vm.posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const iconoir.ChatBubbleEmpty(
                          width: 64,
                          height: 64,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text('Henüz bir paylaşım yok.',
                            style: AppTypography.bodyLarge
                                .copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _navigateToCreatePost(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('İlk Gönderiyi Sen Paylaş'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: vm.posts.length,
                  itemBuilder: (context, index) {
                    final post = vm.posts[index];
                    return _buildPostCard(post);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('Hepsi', 'genel'),
          const SizedBox(width: 8),
          ...ForumPostModel.categories.where((c) => c['key'] != 'genel').map(
                (cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(cat['label']!, cat['key']!),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String key) {
    return Consumer<ForumViewModel>(
      builder: (context, vm, _) {
        final isSelected = vm.selectedCategory == key;
        return GestureDetector(
          onTap: () => vm.filterByCategory(key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accentBlue : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.accentBlue : AppColors.surfaceDivider,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.accentBlue.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostCard(ForumPostModel post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceDivider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            // Detay sayfasına git (Opsiyonel, şimdilik basit tutalım)
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(post.category).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        post.categoryDisplayName,
                        style: AppTypography.caption.copyWith(
                          color: _getCategoryColor(post.category),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(post.createdAt),
                      style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (post.carBrand != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: SvgPicture.network(
                            _getLogoUrl(post.carBrand!),
                            placeholderBuilder: (context) => const iconoir.Car(width: 12, height: 12, color: AppColors.textTertiary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          post.carBrand!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.accentBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(post.title, style: AppTypography.h3),
                const SizedBox(height: 8),
                Text(
                  post.content,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.surfaceDivider),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.surfaceDivider,
                      child: iconoir.User(width: 14, height: 14, color: AppColors.textTertiary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.userEmail.split('@').first,
                      style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    const iconoir.Message(width: 16, height: 16, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      'Cevap Ver',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'sikayet':
        return Colors.redAccent;
      case 'oneri':
        return Colors.amber.shade700;
      case 'soru':
        return AppColors.accentBlue;
      default:
        return Colors.teal;
    }
  }

  String _getLogoUrl(String brandName) {
    String slug = brandName.toLowerCase()
        .replaceAll(' /', '-')
        .replaceAll('/ ', '-')
        .replaceAll('/', '-')
        .replaceAll(' ', '-');
    
    // Özel durumlar (thesvg.org slug eşleştirmeleri)
    if (slug == 'mercedes') slug = 'mercedes-benz';
    if (slug == 'renault-oyak') slug = 'renault';
    if (slug == 'renault-(oyak)') slug = 'renault';
    if (slug == 'tofas-fiat') slug = 'fiat';
    if (slug == 'range-rover') slug = 'land-rover';
    if (slug == 'dodge-usa') slug = 'dodge';
    if (slug == 'ford-otosan') slug = 'ford';
    if (slug == 'chery') slug = 'chery';
    if (slug == 'geely') slug = 'geely';
    
    return 'https://www.thesvg.org/icons/$slug/default.svg';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} sa önce';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  void _navigateToCreatePost(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreatePostView(viewModel: _viewModel),
      ),
    );
  }
}
