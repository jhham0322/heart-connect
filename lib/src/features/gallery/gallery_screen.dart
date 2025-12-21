import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:go_router/go_router.dart';

// --- Model ---
class CategoryItem {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  CategoryItem({required this.id, required this.title, required this.icon, required this.color});
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // Categories
  final List<CategoryItem> _categories = [
    CategoryItem(id: 'christmas', title: 'Christmas', icon: FontAwesomeIcons.tree, color: const Color(0xFFEF9A9A)), 
    CategoryItem(id: 'newyear', title: 'New Year', icon: FontAwesomeIcons.champagneGlasses, color: const Color(0xFF90CAF9)), 
    CategoryItem(id: 'birthday', title: 'Birthday', icon: FontAwesomeIcons.cakeCandles, color: const Color(0xFFF48FB1)), 
    CategoryItem(id: 'thanks', title: 'Thanks', icon: FontAwesomeIcons.heart, color: const Color(0xFFFFF59D)), 
    CategoryItem(id: 'motherDay', title: 'Parents Day', icon: FontAwesomeIcons.personBreastfeeding, color: const Color(0xFFCE93D8)), 
    CategoryItem(id: 'teachersDay', title: 'Teachers Day', icon: FontAwesomeIcons.chalkboardUser, color: const Color(0xFFBCAAA4)), 
    CategoryItem(id: 'tour', title: 'Travel', icon: FontAwesomeIcons.plane, color: const Color(0xFFA5D6A7)), 
    CategoryItem(id: 'halloween', title: 'Halloween', icon: FontAwesomeIcons.ghost, color: const Color(0xFFFFAB91)), 
    CategoryItem(id: 'thanksgiving', title: 'Harvest', icon: FontAwesomeIcons.wheatAwn, color: const Color(0xFFFFCC80)), 
    CategoryItem(id: 'my_photos', title: 'My Photos', icon: FontAwesomeIcons.images, color: const Color(0xFF90A4AE)), 
    CategoryItem(id: 'favorites', title: 'Favorites', icon: FontAwesomeIcons.star, color: const Color(0xFFFFF176)), 
    CategoryItem(id: 'letters', title: 'Letters', icon: FontAwesomeIcons.envelopeOpenText, color: const Color(0xFFB0BEC5)), 
  ];

  Map<String, int> _categoryCounts = {};
  Map<String, bool> _hasNewItems = {}; 

  @override
  void initState() {
    super.initState();
    _scanAssets();
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
       if (cat.id == 'my_photos') {
         counts[cat.id] = 0; 
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Gallery", style: TextStyle(fontWeight: FontWeight.bold)),
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
        children: _categories.map((cat) => _buildCategoryItem(cat)).toList(),
      ),
    );
  }

  Widget _buildCategoryItem(CategoryItem cat) {
    final count = _categoryCounts[cat.id] ?? 0;
    final isNew = _hasNewItems[cat.id] ?? false;

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
                  cat.title, 
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 13,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(0,1))]
                  )
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
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("N", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
class GalleryDetailScreen extends StatefulWidget {
  final CategoryItem category;
  const GalleryDetailScreen({super.key, required this.category});

  @override
  State<GalleryDetailScreen> createState() => _GalleryDetailScreenState();
}

class _GalleryDetailScreenState extends State<GalleryDetailScreen> {
  List<String> _images = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
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
      if (widget.category.id == 'my_photos') {
          setState(() { _isLoading = false; });
          return;
      }

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
       _FullScreenViewer(images: _images, initialIndex: index)
     ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.category.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _images.isEmpty 
           ? Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                    Icon(widget.category.icon, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text("No images in ${widget.category.title}", style: TextStyle(color: Colors.grey[500])),
                 ],
               ))
           : GridView.builder(
              padding: const EdgeInsets.only(bottom: 50),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _openImageViewer(index),
                  child: Hero(
                    tag: _images[index],
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        image: DecorationImage(
                          image: AssetImage(_images[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
           ),
    );
  }
}

// --- Full Screen Viewer (Stateful for Nav & Buttons) ---
class _FullScreenViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenViewer({required this.images, required this.initialIndex});

  @override
  State<_FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<_FullScreenViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen size for arrow positioning
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Photo Gallery (Tap background to close)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: PhotoViewGallery.builder(
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
          ),

          // 2. Favorite Button (Top Left)
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(FontAwesomeIcons.heart, color: Colors.white, size: 28),
              onPressed: () {
                // TODO: Toggle favorite logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Added to favorites (Demo)"), duration: Duration(milliseconds: 500)),
                );
              },
            ),
          ),

          // 3. Navigation Arrows (Left/Right)
          if (_currentIndex > 0)
            Positioned(
              left: 10,
              top: size.height / 2 - 24,
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
              top: size.height / 2 - 24,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 36),
                onPressed: () {
                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
              ),
            ),

          // 4. Pencil FAB (Bottom Center)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  // Navigate to write screen with current image
                  context.push('/write', extra: widget.images[_currentIndex]);
                },
                child: Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7043), // Vibrant Orange
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    // Using penNib to mimic the user's image
                    child: Icon(FontAwesomeIcons.penNib, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ),
          
          // Image Counter (Optional, Top Center)
          Positioned(
            top: 50,
            left: 0, right: 0,
            child: Center(
              child: Text(
                "${_currentIndex + 1} / ${widget.images.length}",
                style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
