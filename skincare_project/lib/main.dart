import 'dart:ui';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    DevicePreview(enabled: true, builder: (context) => const SkincareApp()),
  );
}

class SkincareApp extends StatelessWidget {
  const SkincareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skincare Selection',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const AppWebFrame(child: SkincareSelectionPage()),
    );
  }
}

/// Widget khusus untuk membungkus halaman utama agar berbentuk seperti frame HP di Web Browser
class AppWebFrame extends StatelessWidget {
  final Widget child;
  const AppWebFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (DevicePreview.isEnabled(context)) {
      return child;
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Container(
          width: 412, // Standar lebar layar HP modern
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class SkincareSelectionPage extends StatefulWidget {
  const SkincareSelectionPage({super.key});

  @override
  State<SkincareSelectionPage> createState() => _SkincareSelectionPageState();
}

class _SkincareSelectionPageState extends State<SkincareSelectionPage> {
  late final PageController _pageController;
  int _currentIndex = 0;
  String _selectedSize =
      '30 ml'; // Mengubah default awal agar cocok dengan isi list

  // Variabel baru untuk animasi membal (kalkulator effect)
  double _buttonScale = 1.0;
  int _pressedSizeIndex = -1;
  final List<CartItem> _cartItems = [];

  final List<String> _sizes = const ['15 ml', '30 ml', '50 ml'];

  final List<SkincareItem> _items = [
    SkincareItem(
      name: 'Radiance Serum',
      subtitle: 'Intensive Glow & Nourish',
      imagePath: 'assets/images/serum.png',
      description:
          'Infused with Niacinamide and soft rose extracts for a radiant, healthy, and glowing skin.',
      price: 90000,
      rating: 4.8,
      accentColor: Color.fromARGB(255, 233, 31, 132),
      gradient: [Color(0xFFB56576), Color(0xFFFFAAA6), Color(0xFFFFE5D9)],
    ),
    SkincareItem(
      name: 'Brightening Facewash',
      subtitle: 'Gentle & Refreshing',
      imagePath: 'assets/images/facewash.png',
      description:
          'A gentle foaming cleanser with Vitamin C and Rose water to brighten and refresh your skin.',
      price: 120000,
      rating: 4.7,
      accentColor: Color.fromARGB(255, 233, 31, 132),
      gradient: [Color(0xFFB56576), Color(0xFFFFAAA6), Color(0xFFFFE5D9)],
    ),
    SkincareItem(
      name: 'Ceramide Moisturizer',
      subtitle: 'Barrier Repair & Hydration',
      imagePath: 'assets/images/moisturizer.png',
      description:
          'Formulated with 5X Ceramide and Hyaluronic Acid to lock in moisture for 24 hours and strengthen your skin barrier.',
      price: 85000,
      rating: 4.5,
      accentColor: Color.fromARGB(255, 233, 31, 132),
      gradient: [Color(0xFFB56576), Color(0xFFFFAAA6), Color(0xFFFFE5D9)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82, initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  SkincareItem get currentItem => _items[_currentIndex];

  @override
  Widget build(BuildContext context) {
    final item = currentItem;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: item.gradient,
          ),
        ),
        child: Stack(
          children: [
            _AnimatedBackgroundGlow(color: item.accentColor),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        InteractiveButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),

                        const SizedBox(width: 8),
                        // favorite button removed per request
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Find your perfect glow today?',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Skincare Selection',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InteractiveButton(
                          icon: Icons.shopping_cart_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AppWebFrame(
                                      child: CartPage(cartItems: _cartItems),
                                    ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    flex: 11,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _items.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final skincare = _items[index];
                        final isActive = index == _currentIndex;

                        return AnimatedPadding(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOut,
                          padding: EdgeInsets.only(
                            left: 6,
                            right: 6,
                            top: isActive ? 22 : 48,
                            bottom: isActive ? 0 : 50,
                          ),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: isActive ? 0.94 : 0.86,
                              end: isActive ? 1.0 : 0.88,
                            ),
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOut,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: child,
                              );
                            },
                            child: _SkincareSlideItem(
                              skincare: skincare,
                              isActive: isActive,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: Padding(
                      key: ValueKey(item.name),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.subtitle,
                            style: TextStyle(
                              color: item.accentColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // --- BAGIAN PILIHAN UKURAN (SUDAH INTERAKTIF & MEMBAL) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children:
                          _sizes.asMap().entries.map((entry) {
                            final index = entry.key;
                            final size = entry.value;
                            final selected = size == _selectedSize;
                            final isPressed = index == _pressedSizeIndex;

                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Listener(
                                  onPointerDown: (_) {
                                    setState(() {
                                      _pressedSizeIndex = index;
                                    });
                                  },
                                  onPointerUp: (_) {
                                    setState(() {
                                      _pressedSizeIndex = -1;
                                      _selectedSize = size;
                                    });
                                  },
                                  child: AnimatedScale(
                                    duration: const Duration(milliseconds: 100),
                                    scale: isPressed ? 0.92 : 1.0,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            selected
                                                ? item.accentColor
                                                : Colors.white.withValues(
                                                  alpha: 0.10,
                                                ),
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow:
                                            selected
                                                ? [
                                                  BoxShadow(
                                                    color: item.accentColor
                                                        .withValues(
                                                          alpha: 0.35,
                                                        ),
                                                    blurRadius: 18,
                                                    spreadRadius: 1,
                                                  ),
                                                ]
                                                : [],
                                      ),
                                      child: Text(
                                        size,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color:
                                              selected
                                                  ? Colors.black87
                                                  : Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _InfoBox(
                                  icon: Icons.local_offer,
                                  title: 'Price',
                                  value: 'Rp ${item.price}',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _InfoBox(
                                  icon: Icons.star_rounded,
                                  title: 'Rate',
                                  value: '${item.rating}',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- BAGIAN TOMBOL ADD TO CART (SUDAH INTERAKTIF & MEMBAL) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Listener(
                      onPointerDown: (_) {
                        setState(() {
                          _buttonScale = 0.94; // Melesek masuk 6%
                        });
                      },
                      onPointerUp: (_) {
                        setState(() {
                          _buttonScale = 1.0; // Membal keluar normal
                          _cartItems.add(
                            CartItem(product: item, size: _selectedSize),
                          );
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.black87,
                            content: Text(
                              '${item.name} - $_selectedSize added to cart',
                            ),
                          ),
                        );
                      },
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 100),
                        scale: _buttonScale,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: LinearGradient(
                              colors: [
                                item.accentColor,
                                Colors.white.withValues(alpha: 0.95),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: item.accentColor.withValues(alpha: 0.35),
                                blurRadius: 22,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Add To Cart',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;

  const CartPage({super.key, required this.cartItems});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int get totalPrice =>
      widget.cartItems.fold(0, (total, item) => total + item.product.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB56576), Color(0xFFFFAAA6), Color(0xFFFFE5D9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    InteractiveButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Your Cart',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 60),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child:
                    widget.cartItems.isEmpty
                        ? const Center(
                          child: Text(
                            'Cart is empty',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                        : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: widget.cartItems.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final cartItem = widget.cartItems[index];
                            final product = cartItem.product;

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 12,
                                  sigmaY: 12,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.12,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 78,
                                        height: 78,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.20,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        child: Image.asset(
                                          product.imagePath,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              cartItem.size,
                                              style: TextStyle(
                                                color: product.accentColor,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Rp ${product.price}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Delete product',
                                        onPressed: () {
                                          setState(() {
                                            widget.cartItems.removeAt(index);
                                          });
                                        },
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.white
                                              .withValues(alpha: 0.18),
                                          foregroundColor: Colors.white,
                                          fixedSize: const Size(42, 42),
                                        ),
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Rp $totalPrice',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkincareSlideItem extends StatelessWidget {
  final SkincareItem skincare;
  final bool isActive;

  const _SkincareSlideItem({required this.skincare, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isActive ? 1 : 0.55,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 36,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                width: isActive ? 210 : 170,
                height: isActive ? 210 : 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: skincare.accentColor.withValues(
                    alpha: isActive ? 0.14 : 0.08,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: skincare.accentColor.withValues(
                        alpha: isActive ? 0.22 : 0.10,
                      ),
                      blurRadius: 45,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedScale(
              duration: const Duration(milliseconds: 320),
              scale: isActive ? 1.0 : 0.88,
              child: Image.asset(
                skincare.imagePath,
                fit: BoxFit.contain,
                height: isActive ? 360 : 290,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'Image not found',
                    style: TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoBox({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.black.withValues(alpha: 0.14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedBackgroundGlow extends StatelessWidget {
  final Color color;
  const _AnimatedBackgroundGlow({required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -90,
          right: -60,
          child: _BlurCircle(size: 220, color: color.withValues(alpha: 0.20)),
        ),
        Positioned(
          bottom: -120,
          left: -60,
          child: _BlurCircle(size: 260, color: color.withValues(alpha: 0.16)),
        ),
        Positioned(
          top: 250,
          left: 50,
          child: _BlurCircle(
            size: 120,
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _BlurCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class SkincareItem {
  final String name;
  final String subtitle;
  final String imagePath;
  final String description;
  final int price;
  final double rating;
  final Color accentColor;
  final List<Color> gradient;

  const SkincareItem({
    required this.name,
    required this.subtitle,
    required this.imagePath,
    required this.description,
    required this.price,
    required this.rating,
    required this.accentColor,
    required this.gradient,
  });
}

class CartItem {
  final SkincareItem product;
  final String size;

  const CartItem({required this.product, required this.size});
}

// Letakkan ini di baris paling bawah file, di luar class utama
class InteractiveButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const InteractiveButton({super.key, required this.icon, required this.onTap});

  @override
  State<InteractiveButton> createState() => _InteractiveButtonState();
}

class _InteractiveButtonState extends State<InteractiveButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color:
                _isPressed
                    ? const Color(0xFFC2185B) // Pink gelap saat ditekan
                    : Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
