import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../../providers/locale_provider.dart';
import 'favorites_provider.dart';
import 'gallery_selection_provider.dart';

import 'gallery_data.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  // Categories
  final List<CategoryItem> _categories = galleryCategories;

  Map<String, int> _categoryCounts = {};
  Map<String, bool> _hasNewItems = {}; 

  @override
  void initState() {
    super.initState();
    _scanAssets();
  }
  
  // Helper function to get localized category title
  String _getCategoryTitle(String id, AppStrings strings) {
    switch (id) {
      case 'christmas': return strings.galleryChristmas;
      case 'newyear': return strings.galleryNewYear;
      case 'birthday': return strings.galleryBirthday;
      case 'thanks': return strings.galleryThanks;
      case 'motherDay': return strings.galleryMothersDay;
      case 'teachersDay': return strings.galleryTeachersDay;
      case 'tour': return strings.galleryTravel;
      case 'hobby': return strings.galleryHobby;
      case 'sports': return strings.gallerySports;
      case 'my_photos': return strings.galleryMyPhotos;
      case 'favorites': return strings.contactsFavorites;
      default: return id;
    }
  }

  Future<void> _scanAssets() async {
    List<String> allAssets = [];
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      allAssets = manifest.listAssets();
    } catch (e) {
      try {
        final manifestContent = await rootBundle.loadString('AssetManifest.json');
        final Map<String, dynamic> manifestMap = json.decode(manifestContent);
        allAssets = manifestMap.keys.toList();
      } catch (e2) {
        return;
      }
    }

    Map<String, int> counts = {};
    Map<String, bool> newFlags = {};

    for (var cat in _categories) {
       // my_photos: 기기 갤러리의 사진 수 가져오기
       if (cat.id == 'my_photos') {
         try {
           final permission = await PhotoManager.requestPermissionExtend();
           if (permission.isAuth) {
             final albums = await PhotoManager.getAssetPathList(
               type: RequestType.image,
               filterOption: FilterOptionGroup(
                 imageOption: const FilterOption(sizeConstraint: SizeConstraint(ignoreSize: true)),
               ),
             );
             // 전체 이미지 수 계산
             int totalCount = 0;
             for (var album in albums) {
               totalCount += await album.assetCountAsync;
             }
             counts[cat.id] = totalCount;
             if (totalCount > 0) {
               newFlags[cat.id] = true;
             }
           } else {
             counts[cat.id] = 0;
           }
         } catch (e) {
           debugPrint('Error getting my_photos count: $e');
           counts[cat.id] = 0;
         }
         continue;
       }
       
       // favorites: 하트 표시한 이미지 수
       if (cat.id == 'favorites') {
         final favorites = ref.read(favoritesProvider);
         counts[cat.id] = favorites.length;
         if (favorites.isNotEmpty) {
           newFlags[cat.id] = true;
         }
         continue;
       }
       
       final targetPath = 'assets/images/cards/${cat.id}/';
       // Normalize paths to be safe
       final matchingKeys = allAssets
           .where((k) => k.toLowerCase().contains(targetPath.toLowerCase()))
           .toList();
       
       counts[cat.id] = matchingKeys.length;
       if (matchingKeys.isNotEmpty) {
          newFlags[cat.id] = true; 
       }
    }
    
    if (mounted) {
      setState(() {
        _categoryCounts = counts;
        _hasNewItems = newFlags;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(strings.navGallery, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ReorderableGridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), 
        onReorder: (oldIndex, newIndex) {
          setState(() {
            final element = _categories.removeAt(oldIndex);
            _categories.insert(newIndex, element);
          });
        },
        children: _categories.map((cat) => _buildCategoryItem(cat, strings)).toList(),
      ),
    );
  }

  Widget _buildCategoryItem(CategoryItem cat, AppStrings strings) {
    // favorites 카테고리는 실시간 watch로 카운트
    final count = cat.id == 'favorites' 
        ? ref.watch(favoritesProvider).length 
        : (_categoryCounts[cat.id] ?? 0);
    final isNew = _hasNewItems[cat.id] ?? false;
    final localizedTitle = _getCategoryTitle(cat.id, strings);

    return GestureDetector(
      key: ValueKey(cat.id),
      onTap: () {
         Navigator.push(context, MaterialPageRoute(builder: (_) => GalleryDetailScreen(category: cat)));
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: cat.color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat.icon, size: 36, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  localizedTitle, 
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 13,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(0,1))]
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "$count",
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                )
              ],
            ),
          ),
          
          if (isNew && count > 0)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("N", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- Detail Screen ---
class GalleryDetailScreen extends ConsumerStatefulWidget {
  final CategoryItem category;
  const GalleryDetailScreen({super.key, required this.category});

  @override
  ConsumerState<GalleryDetailScreen> createState() => _GalleryDetailScreenState();
}

class _GalleryDetailScreenState extends ConsumerState<GalleryDetailScreen> {
  List<String> _images = [];
  List<AssetEntity> _deviceAssets = []; // 기기 갤러리 사진용
  bool _isLoading = true;
  bool _isDeviceGallery = false; // 기기 갤러리 여부

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  // 기기 갤러리에서 사진 로드
  Future<void> _loadDevicePhotos() async {
    setState(() {
      _isLoading = true;
      _isDeviceGallery = true;
    });
    
    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        // 권한 거부 시 설정으로 이동 안내
        if (mounted) {
          setState(() => _isLoading = false);
          _showPermissionDeniedDialog();
        }
        return;
      }
      
      // 모든 이미지 앨범 가져오기
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        filterOption: FilterOptionGroup(
          imageOption: const FilterOption(
            sizeConstraint: SizeConstraint(ignoreSize: true),
          ),
          orders: [
            const OrderOption(type: OrderOptionType.createDate, asc: false),
          ],
        ),
      );
      
      if (albums.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }
      
      // 첫 번째 앨범 (보통 "최근 항목" 또는 "전체 사진")에서 가져오기
      // 또는 모든 앨범을 합쳐서 가져오기
      List<AssetEntity> allAssets = [];
      
      for (var album in albums) {
        final count = await album.assetCountAsync;
        if (count > 0) {
          final assets = await album.getAssetListRange(start: 0, end: count);
          for (var asset in assets) {
            // 중복 제거
            if (!allAssets.any((a) => a.id == asset.id)) {
              allAssets.add(asset);
            }
          }
        }
      }
      
      // 최신순 정렬
      allAssets.sort((a, b) => (b.createDateTime).compareTo(a.createDateTime));
      
      // 최대 200개만 가져오기 (성능 고려)
      if (allAssets.length > 200) {
        allAssets = allAssets.sublist(0, 200);
      }
      
      setState(() {
        _deviceAssets = allAssets;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading device photos: $e');
      setState(() => _isLoading = false);
    }
  }
  
  void _showPermissionDeniedDialog() {
    final strings = ref.read(appStringsProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(FontAwesomeIcons.images, color: Colors.orange, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(strings.photoPermissionTitle, style: const TextStyle(fontSize: 17))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.photoPermissionDesc,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              // 권한 설정 방법
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.photoPermissionHowTo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(strings.photoPermissionStep1, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(strings.photoPermissionStep2, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(strings.photoPermissionStep3, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(strings.photoPermissionStep4, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 안내 메시지
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(FontAwesomeIcons.circleCheck, color: Colors.green, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        strings.photoPermissionNote,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              PhotoManager.openSetting();
            },
            icon: const Icon(Icons.settings, size: 18),
            label: Text(strings.openSettings),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCoral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadImages() async {
    // favorites 카테고리: 하트 표시한 이미지만 로드
    if (widget.category.id == 'favorites') {
      final favorites = ref.read(favoritesProvider);
      setState(() {
        _images = favorites.toList();
        _isLoading = false;
      });
      return;
    }

    // my_photos 카테고리: 기기 갤러리에서 사진 로드
    if (widget.category.id == 'my_photos') {
      await _loadDevicePhotos();
      return;
    }

    // 일반 카테고리: assets에서 로드
    List<String> allAssets = [];
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      allAssets = manifest.listAssets();
    } catch (e) {
      // Fallback
      try {
        final manifestContent = await rootBundle.loadString('AssetManifest.json');
        final Map<String, dynamic> manifestMap = json.decode(manifestContent);
        allAssets = manifestMap.keys.toList();
      } catch (e2) {
        setState(() => _isLoading = false);
        return;
      }
    }

    try {
      final targetPath = 'assets/images/cards/${widget.category.id}/';
      final paths = allAssets
          .where((key) => key.toLowerCase().contains(targetPath.toLowerCase()) && 
                (key.toLowerCase().endsWith('.png') || key.toLowerCase().endsWith('.jpg') || key.toLowerCase().endsWith('.jpeg')))
          .toList();
          
      setState(() {
        _images = paths;
        _isLoading = false;
      });
    } catch(e) {
       setState(() => _isLoading = false);
    }
  }

  void _openImageViewer(int index) {
     Navigator.push(context, MaterialPageRoute(builder: (_) => 
       _FullScreenViewer(
         images: _images, 
         initialIndex: index, 
         categoryName: widget.category.title,
         categoryId: widget.category.id,
       )
     ));
  }

  @override
  Widget build(BuildContext context) {
    // 기기 갤러리인 경우 _deviceAssets 사용
    final isEmpty = _isDeviceGallery ? _deviceAssets.isEmpty : _images.isEmpty;
    final itemCount = _isDeviceGallery ? _deviceAssets.length : _images.length;
    final strings = ref.watch(appStringsProvider);
    
    // 카테고리 제목 다국어 처리
    String localizedTitle;
    switch (widget.category.id) {
      case 'christmas': localizedTitle = strings.galleryChristmas; break;
      case 'newyear': localizedTitle = strings.galleryNewYear; break;
      case 'birthday': localizedTitle = strings.galleryBirthday; break;
      case 'thanks': localizedTitle = strings.galleryThanks; break;
      case 'motherDay': localizedTitle = strings.galleryMothersDay; break;
      case 'teachersDay': localizedTitle = strings.galleryTeachersDay; break;
      case 'tour': localizedTitle = strings.galleryTravel; break;
      case 'hobby': localizedTitle = strings.galleryHobby; break;
      case 'sports': localizedTitle = strings.gallerySports; break;
      case 'my_photos': localizedTitle = strings.galleryMyPhotos; break;
      case 'favorites': localizedTitle = strings.contactsFavorites; break;
      default: localizedTitle = widget.category.title;
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          localizedTitle,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0, 
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : isEmpty 
           ? Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                    Icon(widget.category.icon, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(ref.watch(appStringsProvider).galleryNoImages, style: TextStyle(color: Colors.grey[500])),
                 ],
               ))
           : GridView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                // 기기 갤러리인 경우
                if (_isDeviceGallery) {
                  return _buildDevicePhotoTile(index);
                }
                
                // 일반 assets 또는 파일 이미지
                final imagePath = _images[index];
                final isFilePath = imagePath.startsWith('/') || imagePath.contains(':\\');
                final isFavorite = ref.watch(favoritesProvider).contains(imagePath);
                
                return GestureDetector(
                  onTap: () => _openImageViewer(index),
                  child: Hero(
                    tag: imagePath,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            image: DecorationImage(
                              image: isFilePath 
                                  ? FileImage(File(imagePath)) as ImageProvider
                                  : AssetImage(imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (isFavorite)
                          const Positioned(
                            top: 8,
                            left: 8,
                            child: Stack(
                              children: [
                                Icon(FontAwesomeIcons.solidHeart, color: Color(0xFFFF7043), size: 18),
                                Icon(FontAwesomeIcons.heart, color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
           ),
    );
  }
  
  // 기기 사진 썸네일 빌더
  Widget _buildDevicePhotoTile(int index) {
    final asset = _deviceAssets[index];
    
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
        asset.file,
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && 
            snapshot.data != null && 
            snapshot.data![0] != null) {
          final thumbnailData = snapshot.data![0] as Uint8List;
          final file = snapshot.data![1] as File?;
          final filePath = file?.path ?? '';
          final isFavorite = ref.watch(favoritesProvider).contains(filePath);
          
          return GestureDetector(
            onTap: () => _openDevicePhotoViewer(index),
            child: Hero(
              tag: asset.id,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      image: DecorationImage(
                        image: MemoryImage(thumbnailData),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (isFavorite)
                    const Positioned(
                      top: 6,
                      left: 6,
                      child: Stack(
                        children: [
                          Icon(FontAwesomeIcons.solidHeart, color: Color(0xFFFF7043), size: 16),
                          Icon(FontAwesomeIcons.heart, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        }
        return Container(color: Colors.grey[300]);
      },
    );
  }
  
  // 기기 사진 전체화면 뷰어
  void _openDevicePhotoViewer(int index) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => 
      _DevicePhotoViewer(
        assets: _deviceAssets, 
        initialIndex: index, 
        categoryName: widget.category.title,
      )
    ));
  }
}

// --- Full Screen Viewer (Stateful for Nav & Buttons) ---
class _FullScreenViewer extends ConsumerStatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String categoryName;
  final String categoryId;

  const _FullScreenViewer({
    required this.images, 
    required this.initialIndex, 
    required this.categoryName,
    required this.categoryId,
  });

  @override
  ConsumerState<_FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends ConsumerState<_FullScreenViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    // Sync initial selection and category info
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentSelectionProvider.notifier).state = widget.images[_currentIndex];
      ref.read(currentCategoryProvider.notifier).state = widget.categoryId;
      ref.read(currentCategoryImagesProvider.notifier).state = widget.images;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Sync selection on change
    ref.read(currentSelectionProvider.notifier).state = widget.images[index];
  }

  @override
  void dispose() {
    _pageController.dispose();
    // FAB에서 카드 화면으로 이동할 때 선택 정보가 필요하므로 초기화하지 않음
    // 갤러리 상세 화면으로 돌아올 때 새로운 선택으로 덮어씌워짐
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen size for arrow positioning
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false, // Hide default back button
        title: Text(
          widget.categoryName,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Favorite Heart
          Consumer(
            builder: (context, ref, child) {
              final favorites = ref.watch(favoritesProvider);
              final isFav = favorites.contains(widget.images[_currentIndex]);
              
              return IconButton(
                icon: isFav
                    ? const Stack(
                        children: [
                          Icon(FontAwesomeIcons.solidHeart, color: Color(0xFFFF7043), size: 24),
                          Icon(FontAwesomeIcons.heart, color: Colors.white, size: 24),
                        ],
                      )
                    : const Icon(FontAwesomeIcons.heart, color: Colors.white, size: 24),
                onPressed: () {
                  ref.read(favoritesProvider.notifier).toggleFavorite(widget.images[_currentIndex]);
                },
              );
            },
          ),
          // Close/Back Button moved to right
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // 1. Photo Gallery
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            pageController: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.images.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: AssetImage(widget.images[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(tag: widget.images[index]),
              );
            },
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),


          // 2. Navigation Arrows (Left/Right)
          if (_currentIndex > 0)
            Positioned(
              left: 10,
              top: size.height / 2 - 80,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 36),
                onPressed: () {
                  _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
              ),
            ),
          if (_currentIndex < widget.images.length - 1)
            Positioned(
              right: 10,
              top: size.height / 2 - 80,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 36),
                onPressed: () {
                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
              ),
            ),


          
          // 4. Image Counter (Bottom of AppBar area)
          Positioned(
            top: 0,
            left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${_currentIndex + 1} / ${widget.images.length}",
                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- Device Photo Full Screen Viewer ---
class _DevicePhotoViewer extends ConsumerStatefulWidget {
  final List<AssetEntity> assets;
  final int initialIndex;
  final String categoryName;

  const _DevicePhotoViewer({
    required this.assets, 
    required this.initialIndex, 
    required this.categoryName,
  });

  @override
  ConsumerState<_DevicePhotoViewer> createState() => _DevicePhotoViewerState();
}

class _DevicePhotoViewerState extends ConsumerState<_DevicePhotoViewer> {
  late PageController _pageController;
  late int _currentIndex;
  File? _currentFile;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _loadCurrentFile();
  }
  
  Future<void> _loadCurrentFile() async {
    final file = await widget.assets[_currentIndex].file;
    if (mounted && file != null) {
      setState(() => _currentFile = file);
      // selection provider에 파일 경로 설정
      ref.read(currentSelectionProvider.notifier).state = file.path;
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _loadCurrentFile();
  }

  @override
  void dispose() {
    _pageController.dispose();
    // FAB에서 카드 화면으로 이동할 때 선택 정보가 필요하므로 초기화하지 않음
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.categoryName,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Favorite Heart Button
          if (_currentFile != null)
            IconButton(
              icon: ref.watch(favoritesProvider).contains(_currentFile!.path)
                  ? const Stack(
                      children: [
                        Icon(FontAwesomeIcons.solidHeart, color: Color(0xFFFF7043), size: 24),
                        Icon(FontAwesomeIcons.heart, color: Colors.white, size: 24),
                      ],
                    )
                  : const Icon(FontAwesomeIcons.heart, color: Colors.white, size: 24),
              onPressed: () {
                if (_currentFile != null) {
                  ref.read(favoritesProvider.notifier).toggleFavorite(_currentFile!.path);
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Photo Gallery
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.assets.length,
            itemBuilder: (context, index) {
              return _DevicePhotoPage(asset: widget.assets[index]);
            },
          ),

          // Navigation Arrows
          if (_currentIndex > 0)
            Positioned(
              left: 10,
              top: size.height / 2 - 80,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 36),
                onPressed: () {
                  _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
              ),
            ),
          if (_currentIndex < widget.assets.length - 1)
            Positioned(
              right: 10,
              top: size.height / 2 - 80,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 36),
                onPressed: () {
                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
              ),
            ),

          // Image Counter
          Positioned(
            top: 0,
            left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${_currentIndex + 1} / ${widget.assets.length}",
                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Individual device photo page with async loading
class _DevicePhotoPage extends StatefulWidget {
  final AssetEntity asset;
  
  const _DevicePhotoPage({required this.asset});
  
  @override
  State<_DevicePhotoPage> createState() => _DevicePhotoPageState();
}

class _DevicePhotoPageState extends State<_DevicePhotoPage> {
  File? _file;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadFile();
  }
  
  Future<void> _loadFile() async {
    final file = await widget.asset.file;
    if (mounted) {
      setState(() {
        _file = file;
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading || _file == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    
    return PhotoView(
      imageProvider: FileImage(_file!),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 2,
      heroAttributes: PhotoViewHeroAttributes(tag: widget.asset.id),
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      loadingBuilder: (context, event) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
